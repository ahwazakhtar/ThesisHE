# ---------------------------------------------------------------------------
# run_persistent_exposure.R  (Persistence Extensions — Phase 2)
#
# Characterizes counties by CHRONIC shock exposure (how many of the 13 panel
# years 2011-2023 they spent shock-positive) and contrasts the continuously
# (Always) exposed cohort against the never-exposed cohort.
#
# This complements the prior track's ONSET-cohort CS-DiD (Analysis/did/): there
# the treatment is the year a county first enters shock; here the treatment is
# persistent membership. Hypothesis: continuously-exposed counties show the
# largest, most persistent gap vs never-exposed counties.
#
# Cohorts (see Code/exposure_cohorts.R):
#   Always >= 10/13 ; Frequently 5-9/13 ; Rarely 1-4/13 ; Never 0/13.
#
# Outputs:
#   Analysis/persistent_exposure/persistent_exposure_inventory.csv        (county x shock + cohort)
#   Analysis/persistent_exposure/persistent_exposure_cohort_summary.csv   (cohort sizes, geography, means)
#   Analysis/persistent_exposure/persistent_exposure_contrast.csv         (static cohort-vs-Never gaps)
#   Analysis/persistent_exposure/persistent_exposure_dynamic.csv          (Always-vs-Never by year)
#   Analysis/plots/persistent_exposure/*.png
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(readr); library(fixest); library(ggplot2)
})
source("Code/exposure_cohorts.R")

master_path <- "Data/county_level_master.csv"
plot_dir    <- "Analysis/plots/persistent_exposure"
dir.create("Analysis", showWarnings = FALSE)
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

df <- read_csv(master_path, show_col_types = FALSE, progress = FALSE)
df <- df %>% mutate(High_AQI_Max = as.integer(Max_AQI > 100))
if (all(c("Hosp_BadDebt_Total_Real", "Population") %in% names(df))) {
  df$Hosp_BadDebt_PerCapita <- df$Hosp_BadDebt_Total_Real / df$Population
}
df <- df %>% filter(Year >= 2011, Year <= 2023)

shock_indicators <- c("Is_Extreme_Drought", "High_CDD", "High_HDD", "High_AQI_Max")
outcomes <- c("Medical_Debt_Share", "PCPI_Real", "Hosp_BadDebt_PerCapita",
              "Med_HH_Income_Real", "Civilian_Employed", "Benchmark_Silver_Real")
outcomes <- outcomes[outcomes %in% names(df)]

cat(sprintf("Panel: %d counties x %d years (%d-%d)\n",
            length(unique(df$fips_code)), length(unique(df$Year)),
            min(df$Year), max(df$Year)))

# 1. Cohort inventory -------------------------------------------------------
inventory <- df %>%
  pivot_longer(all_of(shock_indicators), names_to = "shock", values_to = "is_event") %>%
  group_by(fips_code, State, shock) %>%
  summarise(n_years_obs = sum(!is.na(is_event)),
            n_events    = sum(is_event == 1, na.rm = TRUE),
            .groups = "drop") %>%
  mutate(exposure_rate = ifelse(n_years_obs > 0, n_events / n_years_obs, NA_real_),
         cohort = as.character(assign_exposure_cohort(n_events)))

write_csv(inventory, "Analysis/persistent_exposure/persistent_exposure_inventory.csv")

# County-level mean outcomes over the panel (for cohort descriptives)
county_means <- df %>%
  group_by(fips_code) %>%
  summarise(across(all_of(outcomes), ~ mean(.x, na.rm = TRUE)), .groups = "drop")

cohort_summary <- inventory %>%
  left_join(county_means, by = "fips_code") %>%
  group_by(shock, cohort) %>%
  summarise(
    n_counties = n(),
    n_states   = n_distinct(State),
    top_states = paste(head(names(sort(table(State), decreasing = TRUE)), 3),
                       collapse = "; "),
    across(all_of(outcomes), ~ round(mean(.x, na.rm = TRUE), 4)),
    .groups = "drop") %>%
  mutate(cohort = factor(cohort, levels = c("Never", "Rarely", "Frequently", "Always"))) %>%
  arrange(shock, cohort)

write_csv(cohort_summary, "Analysis/persistent_exposure/persistent_exposure_cohort_summary.csv")

cat("\n=== Cohort sizes per shock ===\n")
print(as.data.frame(cohort_summary %>% select(shock, cohort, n_counties)))

# 2. Always-vs-Never contrast ----------------------------------------------
# (a) Static dose-response: Outcome ~ cohort | Year, cluster State, on all four
#     cohorts (Never = reference). Tests the monotone Always > Freq > Rarely gap.
# (b) Dynamic Always-vs-Never: Outcome ~ i(Year, Always_Exposed, ref) | fips + Year
#     on the Always U Never subsample — the persistent treated-vs-never trajectory.

contrast_rows <- list()
dyn_rows      <- list()

for (sh in shock_indicators) {
  coh   <- inventory %>% filter(shock == sh) %>% select(fips_code, cohort)
  panel <- df %>% left_join(coh, by = "fips_code") %>%
    mutate(cohort = factor(cohort, levels = c("Never", "Rarely", "Frequently", "Always")))

  for (o in outcomes) {
    # (a) Static cohort gaps vs Never
    sub_all <- panel %>% filter(!is.na(.data[[o]]), !is.na(cohort))
    if (nrow(sub_all) > 50 && nlevels(droplevels(sub_all$cohort)) > 1) {
      m_static <- tryCatch(
        feols(as.formula(paste(o, "~ cohort | Year")), data = sub_all, cluster = ~State),
        error = function(e) NULL)
      if (!is.null(m_static)) {
        ct <- as.data.frame(coeftable(m_static)); ct$Term <- rownames(ct)
        for (i in seq_len(nrow(ct))) {
          contrast_rows[[length(contrast_rows) + 1]] <- data.frame(
            shock = sh, outcome = o, spec = "Static_Cohort_vs_Never",
            term = sub("^cohort", "", ct$Term[i]),
            estimate = ct$Estimate[i], std.error = ct$`Std. Error`[i],
            p.value = ct$`Pr(>|t|)`[i], N = nobs(m_static), stringsAsFactors = FALSE)
        }
      }
    }

    # (b) Dynamic Always-vs-Never trajectory
    sub_an <- panel %>%
      filter(cohort %in% c("Always", "Never"), !is.na(.data[[o]])) %>%
      mutate(Always_Exposed = as.integer(cohort == "Always"))
    n_always <- sum(sub_an$Always_Exposed == 1)
    if (nrow(sub_an) > 50 && n_always > 0 &&
        length(unique(sub_an$fips_code)) > 10 &&
        length(unique(sub_an$Year)) > 2) {
      ref_year <- min(sub_an$Year, na.rm = TRUE)
      m_dyn <- tryCatch(
        feols(as.formula(paste0(o, " ~ i(Year, Always_Exposed, ref = ", ref_year,
                                ") | fips_code + Year")),
              data = sub_an, cluster = ~State),
        error = function(e) NULL)
      if (!is.null(m_dyn)) {
        ct <- as.data.frame(coeftable(m_dyn)); ct$Term <- rownames(ct)
        ct$year <- suppressWarnings(as.integer(sub(".*Year::(\\d+).*", "\\1", ct$Term)))
        ct <- ct[!is.na(ct$year), ]
        for (i in seq_len(nrow(ct))) {
          dyn_rows[[length(dyn_rows) + 1]] <- data.frame(
            shock = sh, outcome = o, year = ct$year[i], ref_year = ref_year,
            estimate = ct$Estimate[i], std.error = ct$`Std. Error`[i],
            p.value = ct$`Pr(>|t|)`[i],
            ci_low = ct$Estimate[i] - 1.96 * ct$`Std. Error`[i],
            ci_high = ct$Estimate[i] + 1.96 * ct$`Std. Error`[i],
            n_always_counties = length(unique(sub_an$fips_code[sub_an$Always_Exposed == 1])),
            n_never_counties  = length(unique(sub_an$fips_code[sub_an$Always_Exposed == 0])),
            N = nobs(m_dyn), stringsAsFactors = FALSE)
        }
      }
    }
  }
}

contrast_df <- if (length(contrast_rows) > 0) bind_rows(contrast_rows) else data.frame()
dyn_df      <- if (length(dyn_rows) > 0) bind_rows(dyn_rows) else data.frame()

if (nrow(contrast_df) > 0) {
  write_csv(contrast_df, "Analysis/persistent_exposure/persistent_exposure_contrast.csv")
  cat("\nStatic cohort contrasts saved (", nrow(contrast_df), " rows)\n", sep = "")
}
if (nrow(dyn_df) > 0) {
  write_csv(dyn_df, "Analysis/persistent_exposure/persistent_exposure_dynamic.csv")
  cat("Dynamic Always-vs-Never trajectories saved (", nrow(dyn_df), " rows)\n", sep = "")
}

cat("\n=== Always-vs-Never static gap: Medical_Debt_Share ===\n")
if (nrow(contrast_df) > 0) {
  hl <- contrast_df %>%
    filter(outcome == "Medical_Debt_Share", term == "Always") %>%
    mutate(across(c(estimate, std.error, p.value), ~ round(.x, 5)))
  print(as.data.frame(hl %>% select(shock, term, estimate, std.error, p.value, N)))
}

# 3. Plots ------------------------------------------------------------------
# 3a. Dynamic Always-vs-Never trajectories per (shock x outcome)
if (nrow(dyn_df) > 0) {
  for (sh in unique(dyn_df$shock)) {
    for (o in unique(dyn_df$outcome)) {
      sub <- dyn_df %>% filter(shock == sh, outcome == o)
      if (nrow(sub) == 0) next
      p <- ggplot(sub, aes(x = year, y = estimate)) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
        geom_ribbon(aes(ymin = ci_low, ymax = ci_high), alpha = 0.15, fill = "#B2182B") +
        geom_line(color = "#B2182B") + geom_point(color = "#B2182B") +
        scale_x_continuous(breaks = unique(sub$year)) +
        labs(title = paste("Always vs Never:", sh, "->", o),
             subtitle = paste0("Two-way FE; gap relative to ", sub$ref_year[1],
                               " (Always n=", sub$n_always_counties[1],
                               ", Never n=", sub$n_never_counties[1], ")"),
             x = "Year", y = "Always - Never gap") +
        theme_minimal(base_size = 11) +
        theme(plot.background = element_rect(fill = "white", color = NA),
              panel.background = element_rect(fill = "white", color = NA))
      ggsave(file.path(plot_dir, paste0("dynamic_", sh, "_", o, ".png")),
             p, width = 7, height = 5, dpi = 150, bg = "white")
    }
  }
}

# 3b. Static dose-response: cohort gaps vs Never per (shock x outcome)
if (nrow(contrast_df) > 0) {
  cd <- contrast_df %>%
    mutate(term = factor(term, levels = c("Rarely", "Frequently", "Always")))
  for (sh in unique(cd$shock)) {
    for (o in unique(cd$outcome)) {
      sub <- cd %>% filter(shock == sh, outcome == o, !is.na(term))
      if (nrow(sub) == 0) next
      sub$ci_low  <- sub$estimate - 1.96 * sub$std.error
      sub$ci_high <- sub$estimate + 1.96 * sub$std.error
      p <- ggplot(sub, aes(x = term, y = estimate)) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
        geom_pointrange(aes(ymin = ci_low, ymax = ci_high), color = "#2166AC") +
        labs(title = paste("Dose-response vs Never:", sh, "->", o),
             subtitle = "Cohort gap vs never-exposed (Year FE, state-clustered)",
             x = "Exposure cohort", y = "Gap vs Never") +
        theme_minimal(base_size = 11) +
        theme(plot.background = element_rect(fill = "white", color = NA),
              panel.background = element_rect(fill = "white", color = NA))
      ggsave(file.path(plot_dir, paste0("doseresponse_", sh, "_", o, ".png")),
             p, width = 6, height = 5, dpi = 150, bg = "white")
    }
  }
}

cat("\n=== Persistent Exposure Analysis Complete ===\n")
cat("Plots in:", plot_dir, "\n")
