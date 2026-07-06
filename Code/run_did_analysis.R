# Diff-in-Diff Analysis with Never-Exposed Controls (Committee Phase 3)
#
# Implements the third econometric committee item: "we are looking for some
# smaller scale 'natural experiments' so we can do diff-in-diffs. Are there
# never exposed counties?"
#
# Phase 0 (`Analysis/did/did_feasibility_memo.md`) selected:
#   - 2012 Midwest drought as the primary natural-experiment cohort
#     (139 treated counties, 2,534 never-exposed controls)
#   - 2013 HDD onset as secondary candidate (407 treated, 2,303 controls)
#   - Callaway-Sant'Anna ATT(g,t) with never-treated controls for
#     Drought / HDD / CDD (AQI dropped — 3% never-exposed too thin).
#
# Outputs:
#   Analysis/did/did_2x2_drought_2012.csv
#   Analysis/did/did_2x2_hdd_2013.csv
#   Analysis/did/did_pretrends_event_study.csv
#   Analysis/did/did_cs_att_gt.csv          (cohort-time ATTs)
#   Analysis/did/did_cs_event_time.csv      (aggregated event-time profiles)
#   Analysis/plots/did/*.png
#
# Implementation note: `did::att_gt` could not be installed in this R env
# (downstream dep `recipes` failed). We instead implement Callaway-Sant'Anna
# (2021) manually using fixest::feols, which is also CLAUDE.md-compliant.
# For each treatment cohort g, ATT(g,t) is estimated on the sub-panel of
# cohort g + never-treated using two-way FE with the post-treatment dummy.

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(fixest)
  library(ggplot2)
})

dir.create("Analysis/did", showWarnings = FALSE, recursive = TRUE)
dir.create("Analysis/plots/did", showWarnings = FALSE, recursive = TRUE)

# ===========================================================================
# Data load and dedupe
# ===========================================================================

county_df <- read_csv("Data/county_level_master.csv",
                     show_col_types = FALSE, progress = FALSE)

# Apply debt reporting exclusion (CO, 2023 only; per CLAUDE.md note).
if ("State" %in% names(county_df) && "Year" %in% names(county_df)) {
  excl_mask <- toupper(trimws(as.character(county_df$State))) == "CO" &
               as.integer(county_df$Year) == 2023L
  for (v in intersect(c("Medical_Debt_Share", "Medical_Debt_Median_2023"), names(county_df))) {
    county_df[[v]][excl_mask] <- NA_real_
  }
}

# Per capita hospital bad debt.
if ("Population" %in% names(county_df) && !all(is.na(county_df$Population)) &&
    "Hosp_BadDebt_Total_Real" %in% names(county_df)) {
  county_df$Hosp_BadDebt_PerCapita <- county_df$Hosp_BadDebt_Total_Real / county_df$Population
}

# Construct High_AQI_Max here for symmetry (not used as DiD treatment per
# Phase 0 memo, but useful as a cohort variable summary).
if ("Max_AQI" %in% names(county_df)) {
  county_df$High_AQI_Max <- as.integer(county_df$Max_AQI > 100)
}

# Dedupe to one row per (fips_code, Year) on the columns we need.
# County master has multi-rating-area duplicates (~3% of rows).
keep_cols <- c("fips_code", "Year", "State",
               "Is_Extreme_Drought", "High_CDD", "High_HDD", "High_AQI_Max",
               "Medical_Debt_Share", "Medical_Debt_Median_2023",
               "Benchmark_Silver_Real", "Hosp_BadDebt_PerCapita",
               "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed",
               "Population", "Household_Income_2023", "Uninsured_Rate")
keep_cols <- intersect(keep_cols, names(county_df))
## Phase 0 inventory and feasibility memo are defined over 2011-2023.
## County master extends back to 1990 for climate baselining (CLAUDE.md).
## Restrict to the analysis window so "first event year" and "never-exposed"
## semantics match the memo's cohort design.
panel <- county_df %>%
  distinct(across(all_of(keep_cols))) %>%
  filter(Year >= 2011L, Year <= 2023L)

cat(sprintf("Panel: %d unique (county-year) rows from %d county-years.\n",
            nrow(panel), n_distinct(paste0(panel$fips_code, "-", panel$Year))))

# ===========================================================================
# Treatment cohort construction
# ===========================================================================

# A county is in cohort g for shock s if its first event year is g.
# Never-exposed = zero events 2011-2023.
build_first_event <- function(d, shock_var) {
  d %>%
    filter(!is.na(.data[[shock_var]])) %>%
    group_by(fips_code) %>%
    summarise(first_event = suppressWarnings(min(Year[.data[[shock_var]] == 1], na.rm = TRUE)),
              n_events    = sum(.data[[shock_var]] == 1, na.rm = TRUE),
              .groups = "drop") %>%
    ## Two-step coercion avoids the `as.integer(Inf)` warning: replace Inf
    ## with NA_real_ first, then coerce.
    mutate(first_event = if_else(is.finite(first_event), first_event, NA_real_),
           first_event = as.integer(first_event),
           cohort      = if_else(is.na(first_event), 0L, first_event),  # 0 = never-treated
           ever_exposed = as.integer(n_events > 0))
}

cohorts_drought <- build_first_event(panel, "Is_Extreme_Drought")
cohorts_hdd     <- build_first_event(panel, "High_HDD")
cohorts_cdd     <- build_first_event(panel, "High_CDD")

cat("Drought cohort sizes (first-event year):\n")
print(table(cohorts_drought$cohort, useNA = "ifany"))

# ===========================================================================
# Phase 3a: Canonical 2x2 DiD for a single event year
# ===========================================================================
#
# Treatment: counties whose FIRST drought event is in `event_year`.
# Control:   never-exposed counties.
# Pre-period (1 year): event_year - 1.
# Post-period: every post-event year up to 2023 (inclusive).
#
# Model: Y_{i,t} = alpha_i + gamma_t + tau * (Treated_i * Post_t) + epsilon.

run_2x2 <- function(panel, cohort_df, event_year, outcomes, label,
                    cluster_var = "State") {
  treated_fips <- cohort_df %>%
    filter(cohort == event_year) %>%
    pull(fips_code)
  control_fips <- cohort_df %>%
    filter(cohort == 0L) %>%
    pull(fips_code)
  cat(sprintf("\n[%s] event=%d: treated=%d, control=%d\n",
              label, event_year, length(treated_fips), length(control_fips)))

  d <- panel %>%
    filter(fips_code %in% c(treated_fips, control_fips)) %>%
    mutate(Treated = as.integer(fips_code %in% treated_fips),
           Post    = as.integer(Year >= event_year),
           Treated_x_Post = Treated * Post)

  rows <- list()
  for (y in outcomes) {
    if (!y %in% names(d)) next
    d_y <- d %>% filter(!is.na(.data[[y]]))
    if (n_distinct(d_y$fips_code[d_y$Treated == 1]) < 5 ||
        n_distinct(d_y$fips_code[d_y$Treated == 0]) < 5) next
    f <- as.formula(paste(y, "~ Treated_x_Post | fips_code + Year"))
    m <- tryCatch(feols(f, data = d_y, cluster = cluster_var),
                  error = function(e) { cat("  ", y, "failed:", conditionMessage(e), "\n"); NULL })
    if (is.null(m)) next
    ct <- as.data.frame(coeftable(m))
    rows[[y]] <- data.frame(
      Event = label,
      Event_Year = event_year,
      Outcome = y,
      Term = "Treated_x_Post",
      Estimate = ct[1, 1],
      Std_Error = ct[1, 2],
      t_value = ct[1, 3],
      p_value = ct[1, 4],
      N = nobs(m),
      N_Treated = n_distinct(d_y$fips_code[d_y$Treated == 1]),
      N_Control = n_distinct(d_y$fips_code[d_y$Treated == 0]),
      Cluster = cluster_var,
      stringsAsFactors = FALSE
    )
    cat(sprintf("  %s: ATT=%.4f (SE=%.4f, p=%.4f, N=%d)\n",
                y, ct[1, 1], ct[1, 2], ct[1, 4], nobs(m)))
  }
  do.call(rbind, rows)
}

outcomes_2x2 <- c("Medical_Debt_Share", "Medical_Debt_Median_2023",
                  "Benchmark_Silver_Real", "Hosp_BadDebt_PerCapita",
                  "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed")

cat("\n=== Phase 3a: 2x2 DiD ===\n")
res_drought_2012 <- run_2x2(panel, cohorts_drought, 2012,
                            outcomes_2x2, "Drought_2012")
res_hdd_2013     <- run_2x2(panel, cohorts_hdd,     2013,
                            outcomes_2x2, "HDD_2013")

if (!is.null(res_drought_2012)) write_csv(res_drought_2012, "Analysis/did/did_2x2_drought_2012.csv")
if (!is.null(res_hdd_2013))     write_csv(res_hdd_2013,     "Analysis/did/did_2x2_hdd_2013.csv")

# ===========================================================================
# Phase 3a (continued): Event-study with leads/lags (pre-trends)
# ===========================================================================
#
# Y_{i,t} = alpha_i + gamma_t + sum_{k != -1} beta_k * 1{event_time = k} * Treated_i + eps
# Reference period: k = -1 (one year pre).

run_event_study <- function(panel, cohort_df, event_year, outcomes, label,
                            leads = 2, lags = 3, cluster_var = "State") {
  treated_fips <- cohort_df %>% filter(cohort == event_year) %>% pull(fips_code)
  control_fips <- cohort_df %>% filter(cohort == 0L) %>% pull(fips_code)
  d <- panel %>%
    filter(fips_code %in% c(treated_fips, control_fips)) %>%
    mutate(Treated = as.integer(fips_code %in% treated_fips),
           event_time = Year - event_year)
  d <- d %>% filter(event_time >= -leads, event_time <= lags)
  # Build event-time dummies relative to k = -1.
  for (k in setdiff(-leads:lags, -1)) {
    nm <- paste0("ev_", ifelse(k < 0, paste0("m", abs(k)), paste0("p", k)))
    d[[nm]] <- as.integer(d$event_time == k & d$Treated == 1)
  }
  ev_terms <- grep("^ev_", names(d), value = TRUE)

  rows <- list()
  for (y in outcomes) {
    if (!y %in% names(d)) next
    d_y <- d %>% filter(!is.na(.data[[y]]))
    if (n_distinct(d_y$fips_code[d_y$Treated == 1]) < 5) next
    f <- as.formula(paste(y, "~", paste(ev_terms, collapse = " + "),
                          "| fips_code + Year"))
    m <- tryCatch(feols(f, data = d_y, cluster = cluster_var),
                  error = function(e) NULL)
    if (is.null(m)) next
    ct <- as.data.frame(coeftable(m))
    ct$Term <- rownames(ct)
    ct$Event_Time <- as.integer(sub("ev_m", "-", sub("ev_p", "", ct$Term)))
    rows[[y]] <- data.frame(
      Event = label,
      Event_Year = event_year,
      Outcome = y,
      Term = ct$Term,
      Event_Time = ct$Event_Time,
      Estimate = ct[, 1],
      Std_Error = ct[, 2],
      t_value = ct[, 3],
      p_value = ct[, 4],
      N = nobs(m),
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, rows)
}

cat("\n=== Phase 3a: Pre-trend event study ===\n")
pretrends_drought <- run_event_study(panel, cohorts_drought, 2012,
                                     outcomes_2x2, "Drought_2012",
                                     leads = 1, lags = 3)
pretrends_hdd     <- run_event_study(panel, cohorts_hdd,     2013,
                                     outcomes_2x2, "HDD_2013",
                                     leads = 2, lags = 3)
pretrends_all     <- bind_rows(pretrends_drought, pretrends_hdd)
write_csv(pretrends_all, "Analysis/did/did_pretrends_event_study.csv")

# ===========================================================================
# Phase 3b: Manual Callaway-Sant'Anna ATT(g,t) with never-treated controls
# ===========================================================================
#
# For each cohort g and post-treatment time t >= g, estimate
#   ATT(g, t) = E[Y(1) - Y(0) | G = g, t]
# using the sub-panel of cohort g + never-treated.
# We use the canonical 2x2 estimator with the pre-period taken as g-1 and
# post-period taken as t, both restricted to cohort g + never-treated.
# This is the "long" version of CS without doubly-robust correction —
# acceptable given the never-treated controls and panel size.

estimate_att_gt <- function(panel, cohort_df, g, t, outcome,
                            cluster_var = "State") {
  if (t < g) return(NULL)  # only post-treatment ATT
  treated_fips <- cohort_df %>% filter(cohort == g) %>% pull(fips_code)
  control_fips <- cohort_df %>% filter(cohort == 0L) %>% pull(fips_code)
  if (length(treated_fips) < 5) return(NULL)

  d <- panel %>%
    filter(fips_code %in% c(treated_fips, control_fips),
           Year %in% c(g - 1L, t)) %>%
    mutate(Treated = as.integer(fips_code %in% treated_fips),
           Post = as.integer(Year == t),
           Treated_x_Post = Treated * Post) %>%
    filter(!is.na(.data[[outcome]]))
  if (n_distinct(d$fips_code[d$Treated == 1]) < 5 ||
      n_distinct(d$fips_code[d$Treated == 0]) < 5) return(NULL)

  f <- as.formula(paste(outcome, "~ Treated_x_Post | fips_code + Year"))
  m <- tryCatch(feols(f, data = d, cluster = cluster_var),
                error = function(e) NULL)
  if (is.null(m)) return(NULL)
  ct <- as.data.frame(coeftable(m))
  data.frame(
    Outcome = outcome,
    Cohort_g = g,
    Time_t = t,
    Event_Time = t - g,
    ATT = ct[1, 1],
    Std_Error = ct[1, 2],
    p_value = ct[1, 4],
    N = nobs(m),
    N_Treated = length(treated_fips),
    stringsAsFactors = FALSE
  )
}

run_cs_did <- function(panel, cohort_df, shock_label, outcomes,
                       max_year = 2023L, min_cohort_size = 30L) {
  valid_cohorts <- cohort_df %>%
    filter(cohort > 0L) %>%
    count(cohort, name = "n") %>%
    filter(n >= min_cohort_size) %>%
    pull(cohort)
  cat(sprintf("\n[%s] cohorts with N>=%d: %s\n",
              shock_label, min_cohort_size,
              paste(valid_cohorts, collapse = ", ")))

  rows <- list()
  for (g in valid_cohorts) {
    for (t in g:max_year) {
      for (y in outcomes) {
        att <- estimate_att_gt(panel, cohort_df, g, t, y)
        if (!is.null(att)) {
          att$Shock <- shock_label
          rows[[paste(shock_label, g, t, y, sep = "_")]] <- att
        }
      }
    }
  }
  do.call(rbind, rows)
}

cat("\n=== Phase 3b: Callaway-Sant'Anna ATT(g,t) ===\n")
cs_drought <- run_cs_did(panel, cohorts_drought, "Drought", outcomes_2x2)
cs_hdd     <- run_cs_did(panel, cohorts_hdd,     "HDD",     outcomes_2x2)
cs_cdd     <- run_cs_did(panel, cohorts_cdd,     "CDD",     outcomes_2x2)

cs_all <- bind_rows(cs_drought, cs_hdd, cs_cdd)
write_csv(cs_all, "Analysis/did/did_cs_att_gt.csv")
cat(sprintf("\nWrote %d ATT(g,t) estimates.\n", nrow(cs_all)))

# ===========================================================================
# Aggregate cohort-level ATTs to event-time response curves
# ===========================================================================
# Simple weighted aggregation: ATT(e) = sum_g w(g) * ATT(g, g+e)
# with weights = cohort size, normalized within each (shock, outcome, e).

event_time_summary <- cs_all %>%
  mutate(weight = N_Treated) %>%
  group_by(Shock, Outcome, Event_Time) %>%
  summarise(ATT_avg = sum(ATT * weight) / sum(weight),
            ATT_se_avg = sqrt(sum((Std_Error * weight)^2) / sum(weight)^2),
            N_Cohorts = n(),
            Total_Treated = sum(N_Treated),
            .groups = "drop") %>%
  arrange(Shock, Outcome, Event_Time)

event_time_summary <- event_time_summary %>%
  mutate(t_stat = ATT_avg / ATT_se_avg,
         p_value = 2 * pnorm(-abs(t_stat)))

write_csv(event_time_summary, "Analysis/did/did_cs_event_time.csv")

# ===========================================================================
# Plots
# ===========================================================================

# Plot 1: pre-trend event studies (one per shock x outcome with data)
plot_event_study <- function(es, label) {
  for (y in unique(es$Outcome)) {
    d <- es %>% filter(Outcome == y)
    if (nrow(d) == 0) next
    p <- ggplot(d, aes(x = Event_Time, y = Estimate)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
      geom_pointrange(aes(ymin = Estimate - 1.96 * Std_Error,
                          ymax = Estimate + 1.96 * Std_Error),
                      color = "#B2182B") +
      labs(title = paste0("Event Study (DiD): ", label, " -> ", y),
           subtitle = paste0("Reference: t = -1; cluster = State"),
           x = "Event time (years from onset)", y = "Coefficient") +
      theme_minimal(base_size = 11)
    fname <- paste0("Analysis/plots/did/eventstudy_", label, "_", y, ".png")
    ggsave(fname, p, width = 7, height = 4, dpi = 120)
  }
}
plot_event_study(pretrends_drought, "Drought_2012")
plot_event_study(pretrends_hdd,     "HDD_2013")

# Plot 2: CS-DiD event-time aggregations
for (s in unique(event_time_summary$Shock)) {
  for (y in unique(event_time_summary$Outcome)) {
    d <- event_time_summary %>% filter(Shock == s, Outcome == y)
    if (nrow(d) < 2) next
    p <- ggplot(d, aes(x = Event_Time, y = ATT_avg)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      geom_line(color = "#2166AC") +
      geom_pointrange(aes(ymin = ATT_avg - 1.96 * ATT_se_avg,
                          ymax = ATT_avg + 1.96 * ATT_se_avg),
                      color = "#2166AC") +
      labs(title = paste0("CS-DiD event-time profile: ", s, " -> ", y),
           subtitle = paste0("Cohort-weighted ATT(e); ", sum(d$N_Cohorts), " cohort-time cells"),
           x = "Event time (years from cohort onset)", y = "ATT(e)") +
      theme_minimal(base_size = 11)
    fname <- paste0("Analysis/plots/did/csdid_", s, "_", y, ".png")
    ggsave(fname, p, width = 7, height = 4, dpi = 120)
  }
}

cat("\n=== Done ===\n")
cat("Outputs:\n  Analysis/did/did_2x2_drought_2012.csv\n  Analysis/did/did_2x2_hdd_2013.csv\n",
    "  Analysis/did/did_pretrends_event_study.csv\n  Analysis/did/did_cs_att_gt.csv\n",
    "  Analysis/did/did_cs_event_time.csv\n  Analysis/plots/did/*.png\n", sep = "")
