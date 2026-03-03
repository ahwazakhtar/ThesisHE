# Dynamic Panel Impulse-Response Models for County-Level Climate Shocks
# These are responses to recurring binary shock indicators, not canonical
# staggered-adoption event studies. Treatment is not absorbing — counties
# can enter and exit shock status across years.
#
# Approach A: Dynamic Distributed Lag (single regression with leads/lags)
# Approach B: Local Projections (Jordà 2005, separate regression per horizon)
# Horizon window: h = {-2, -1, 0, +1, +2, +3}, reference h=-1 for Approach A

# 1. Setup ----------------------------------------------------------------
library(dplyr)
library(tidyr)
library(fixest)
library(ggplot2)

input_path      <- "Data/county_level_master.csv"
output_coefs    <- "Analysis/event_study_coefs.csv"
output_results  <- "Analysis/event_study_results.txt"
plot_dir        <- "Analysis/plots"

dir.create("Analysis", showWarnings = FALSE)
dir.create(plot_dir, showWarnings = FALSE)

cat("Loading Data...\n")
df <- read.csv(input_path, stringsAsFactors = FALSE)

# 2. Data Prep ------------------------------------------------------------

# Hosp_BadDebt_PerCapita
if ("Population" %in% names(df) && !all(is.na(df$Population))) {
  df$Hosp_BadDebt_PerCapita <- df$Hosp_BadDebt_Total_Real / df$Population
}

# Debt reporting exclusion: CO 2023 only
debt_outcomes <- c("Medical_Debt_Share", "Medical_Debt_Median_2023")
debt_reporting_policy <- data.frame(State = "CO", Start_Year = 2023L, End_Year = 2023L,
                                    stringsAsFactors = FALSE)

if (length(intersect(debt_outcomes, names(df))) > 0 && "State" %in% names(df)) {
  state_upper <- toupper(trimws(as.character(df$State)))
  year_int    <- as.integer(df$Year)
  for (i in seq_len(nrow(debt_reporting_policy))) {
    mask <- state_upper == debt_reporting_policy$State[i] &
      year_int >= debt_reporting_policy$Start_Year[i] &
      year_int <= debt_reporting_policy$End_Year[i]
    for (v in intersect(debt_outcomes, names(df))) {
      df[[v]] <- ifelse(mask, NA_real_, as.numeric(df[[v]]))
    }
  }
  cat("Applied debt exclusion: CO 2023\n")
}

df$State <- as.factor(df$State)

# Config
shocks   <- c("Is_Extreme_Drought", "High_CDD", "High_HDD")
outcomes <- c("Medical_Debt_Share", "Benchmark_Silver_Real",
              "Medical_Debt_Median_2023", "Hosp_BadDebt_PerCapita")
primary_outcomes <- c("Medical_Debt_Share", "Benchmark_Silver_Real")
controls <- intersect(c("Household_Income_2023", "Uninsured_Rate"), names(df))
h_min <- -2L
h_max <- 3L

# Verify shocks exist
shocks <- shocks[shocks %in% names(df)]
outcomes <- outcomes[outcomes %in% names(df)]
cat("Shocks:", paste(shocks, collapse = ", "), "\n")
cat("Outcomes:", paste(outcomes, collapse = ", "), "\n")

# 3. Panel Contiguity & Lead/Lag Construction -----------------------------

cat("Checking panel contiguity...\n")
df <- df %>% arrange(fips_code, Year)

# Fill year gaps with tidyr::complete
df <- df %>%
  group_by(fips_code) %>%
  complete(Year = min(Year):max(Year)) %>%
  ungroup() %>%
  arrange(fips_code, Year)

cat("Constructing leads/lags for shocks and outcomes...\n")

# Shock leads and lags
for (s in shocks) {
  df <- df %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      !!paste0(s, "_Lead1") := dplyr::lead(.data[[s]], 1),
      !!paste0(s, "_Lead2") := dplyr::lead(.data[[s]], 2),
      !!paste0(s, "_Lag1_es")  := dplyr::lag(.data[[s]], 1),
      !!paste0(s, "_Lag2_es")  := dplyr::lag(.data[[s]], 2),
      !!paste0(s, "_Lag3")  := dplyr::lag(.data[[s]], 3)
    ) %>%
    ungroup()
}

# Outcome forward/backward shifts for LP
for (o in outcomes) {
  df <- df %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      !!paste0(o, "_fwd0") := .data[[o]],
      !!paste0(o, "_fwd1") := dplyr::lead(.data[[o]], 1),
      !!paste0(o, "_fwd2") := dplyr::lead(.data[[o]], 2),
      !!paste0(o, "_fwd3") := dplyr::lead(.data[[o]], 3),
      !!paste0(o, "_bwd1") := dplyr::lag(.data[[o]], 1),
      !!paste0(o, "_bwd2") := dplyr::lag(.data[[o]], 2)
    ) %>%
    ungroup()
}

# 3b. Combined Shock Indicators --------------------------------------------

cat("\nConstructing combined shock indicators...\n")
df$Any_Shock      <- as.integer(df$Is_Extreme_Drought == 1 | df$High_CDD == 1 | df$High_HDD == 1)
df$Shock_Count    <- as.integer(df$Is_Extreme_Drought) + as.integer(df$High_CDD) + as.integer(df$High_HDD)
df$Compound_Shock <- as.integer(df$Shock_Count >= 2)

cat("\n--- Shock Co-occurrence Table ---\n")
print(table(df$Shock_Count, useNA = "ifany"))

# Leads/lags for Any_Shock (used in both DL and LP)
for (s in c("Any_Shock", "Compound_Shock", "Shock_Count")) {
  df <- df %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      !!paste0(s, "_Lead1") := dplyr::lead(.data[[s]], 1),
      !!paste0(s, "_Lead2") := dplyr::lead(.data[[s]], 2),
      !!paste0(s, "_Lag1_es")  := dplyr::lag(.data[[s]], 1),
      !!paste0(s, "_Lag2_es")  := dplyr::lag(.data[[s]], 2),
      !!paste0(s, "_Lag3")  := dplyr::lag(.data[[s]], 3)
    ) %>%
    ungroup()
}

# Add Any_Shock to the shocks vector for DL and LP loops
shocks <- c(shocks, "Any_Shock")

# Diagnostic: non-NA counts for constructed columns
cat("\n--- Lead/Lag Non-NA Counts ---\n")
new_cols <- grep("_(Lead|Lag[0-9]_es|Lag3|fwd|bwd)", names(df), value = TRUE)
for (col in new_cols) {
  cat(sprintf("  %s: %d non-NA\n", col, sum(!is.na(df[[col]]))))
}

# 4. Helper ---------------------------------------------------------------

safe_feols <- function(f, data, cluster_var, weights = NULL) {
  tryCatch({
    clust <- as.formula(paste0("~", cluster_var))
    if (!is.null(weights)) {
      feols(f, data = data, cluster = clust, weights = data[[weights]])
    } else {
      feols(f, data = data, cluster = clust)
    }
  }, error = function(e) {
    cat("    Error:", conditionMessage(e), "\n")
    return(NULL)
  })
}

extract_coef <- function(model, term, shock, outcome, horizon, approach, weighting, N) {
  if (is.null(model)) return(NULL)
  ct <- as.data.frame(coeftable(model))
  ct$Term <- rownames(ct)
  row <- ct[ct$Term == term, , drop = FALSE]
  if (nrow(row) == 0) return(NULL)
  data.frame(
    shock = shock, outcome = outcome, horizon = horizon,
    estimate = row$Estimate, std.error = row$`Std. Error`,
    p.value = row$`Pr(>|t|)`,
    ci_low = row$Estimate - 1.96 * row$`Std. Error`,
    ci_high = row$Estimate + 1.96 * row$`Std. Error`,
    N = N, approach = approach, weighting = weighting,
    stringsAsFactors = FALSE
  )
}

# 5. Approach A — Dynamic Distributed Lag ---------------------------------

cat("\n=== Approach A: Dynamic Distributed Lag ===\n")
coefs_dl <- list()
dl_models <- list()

sink(output_results)
cat("=== Event Study: Dynamic Distributed Lag Model Summaries ===\n\n")

for (s in shocks) {
  for (o in outcomes) {
    # Use _Lag1_es and _Lag2_es to avoid collision with master's existing _Lag1/_Lag2
    # which may have different construction (e.g., from process_county_climate.R)
    rhs_terms <- c(
      paste0(s, "_Lead2"),      # h = -2
      # Lead1 omitted: reference = h = -1
      s,                        # h = 0
      paste0(s, "_Lag1_es"),    # h = +1
      paste0(s, "_Lag2_es"),    # h = +2
      paste0(s, "_Lag3"),       # h = +3
      controls
    )
    rhs_terms <- rhs_terms[rhs_terms %in% names(df)]

    f <- as.formula(paste(o, "~", paste(rhs_terms, collapse = " + "), "| fips_code + Year"))

    # Horizon-to-term mapping
    horizon_map <- c(
      setNames(paste0(s, "_Lead2"), "-2"),
      setNames(s, "0"),
      setNames(paste0(s, "_Lag1_es"), "1"),
      setNames(paste0(s, "_Lag2_es"), "2"),
      setNames(paste0(s, "_Lag3"), "3")
    )

    for (wt in c("Unweighted", "Population")) {
      wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
      if (wt == "Population" && is.null(wt_arg)) next

      cluster_var <- "State"
      m <- safe_feols(f, df, cluster_var, wt_arg)

      if (!is.null(m)) {
        label <- paste(s, o, wt, sep = " | ")
        cat(paste0("\n--- ", label, " ---\n"))
        print(summary(m, n = 50))
        dl_models[[label]] <- m

        N <- nobs(m)
        for (h_str in names(horizon_map)) {
          coefs_dl[[length(coefs_dl) + 1]] <- extract_coef(
            m, horizon_map[h_str], s, o, as.integer(h_str), "DL", wt, N
          )
        }
        # Reference row h = -1
        coefs_dl[[length(coefs_dl) + 1]] <- data.frame(
          shock = s, outcome = o, horizon = -1L,
          estimate = 0, std.error = 0, p.value = NA_real_,
          ci_low = 0, ci_high = 0, N = N,
          approach = "DL", weighting = wt, stringsAsFactors = FALSE
        )
      }

      # Rating-area clustering for premium outcomes
      if (o == "Benchmark_Silver_Real" && "rating_area_id" %in% names(df)) {
        m_ra <- safe_feols(f, df, "rating_area_id", wt_arg)
        if (!is.null(m_ra)) {
          N_ra <- nobs(m_ra)
          for (h_str in names(horizon_map)) {
            coefs_dl[[length(coefs_dl) + 1]] <- extract_coef(
              m_ra, horizon_map[h_str], s, o, as.integer(h_str),
              "DL_RA_Cluster", wt, N_ra
            )
          }
          coefs_dl[[length(coefs_dl) + 1]] <- data.frame(
            shock = s, outcome = o, horizon = -1L,
            estimate = 0, std.error = 0, p.value = NA_real_,
            ci_low = 0, ci_high = 0, N = N_ra,
            approach = "DL_RA_Cluster", weighting = wt, stringsAsFactors = FALSE
          )
        }
      }
    }
  }
}

sink()
cat("DL model summaries saved to:", output_results, "\n")

# 6. Approach B — Local Projections ---------------------------------------
# Note on negative horizons (h < 0): The dependent variable is y_{t+h}
# (i.e., past outcomes), while controls remain at time t. This is a standard
# LP pre-trend check: significant coefficients at h < 0 suggest the shock
# is predicted by prior outcome movements (failure of strict exogeneity).
# Controls are not time-shifted because the identification question is
# whether *current* shock assignment correlates with *past* outcome levels.

cat("\n=== Approach B: Local Projections ===\n")
coefs_lp <- list()

for (s in shocks) {
  for (o in outcomes) {
    for (h in h_min:h_max) {
      # Dependent variable
      if (h >= 0) {
        dep_col <- paste0(o, "_fwd", h)
      } else {
        dep_col <- paste0(o, "_bwd", abs(h))
      }

      if (!dep_col %in% names(df)) {
        cat("  Skipping", dep_col, "(not found)\n")
        next
      }

      rhs <- c(s, controls)
      rhs <- rhs[rhs %in% names(df)]
      f <- as.formula(paste(dep_col, "~", paste(rhs, collapse = " + "), "| fips_code + Year"))

      # Robustness: LP with shock-history controls (lags of shock at t-1, t-2)
      # Isolates the h-horizon effect of shock_t from persistence of recent shocks
      shock_hist <- c(paste0(s, "_Lag1_es"), paste0(s, "_Lag2_es"))
      shock_hist <- shock_hist[shock_hist %in% names(df)]
      rhs_hist <- c(s, shock_hist, controls)
      rhs_hist <- rhs_hist[rhs_hist %in% names(df)]
      f_hist <- as.formula(paste(dep_col, "~", paste(rhs_hist, collapse = " + "), "| fips_code + Year"))

      for (wt in c("Unweighted", "Population")) {
        wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
        if (wt == "Population" && is.null(wt_arg)) next

        m <- safe_feols(f, df, "State", wt_arg)
        if (!is.null(m)) {
          coefs_lp[[length(coefs_lp) + 1]] <- extract_coef(
            m, s, s, o, h, "LP", wt, nobs(m)
          )
        }

        # LP with shock history controls
        m_hist <- safe_feols(f_hist, df, "State", wt_arg)
        if (!is.null(m_hist)) {
          coefs_lp[[length(coefs_lp) + 1]] <- extract_coef(
            m_hist, s, s, o, h, "LP_ShockHistory", wt, nobs(m_hist)
          )
        }

        # RA clustering for premium
        if (o == "Benchmark_Silver_Real" && "rating_area_id" %in% names(df)) {
          m_ra <- safe_feols(f, df, "rating_area_id", wt_arg)
          if (!is.null(m_ra)) {
            coefs_lp[[length(coefs_lp) + 1]] <- extract_coef(
              m_ra, s, s, o, h, "LP_RA_Cluster", wt, nobs(m_ra)
            )
          }
        }
      }
    }
  }
}

# 6b. Compound Shock LP Models -------------------------------------------

cat("\n=== Compound Shock Local Projections ===\n")
coefs_compound <- list()

for (o in outcomes) {
  for (h in h_min:h_max) {
    if (h >= 0) {
      dep_col <- paste0(o, "_fwd", h)
    } else {
      dep_col <- paste0(o, "_bwd", abs(h))
    }
    if (!dep_col %in% names(df)) next

    # Spec 1: Additive decomposition (Any_Shock baseline + Compound_Shock increment)
    rhs1 <- c("Any_Shock", "Compound_Shock", controls)
    rhs1 <- rhs1[rhs1 %in% names(df)]
    f1 <- as.formula(paste(dep_col, "~", paste(rhs1, collapse = " + "), "| fips_code + Year"))

    # Spec 2: Dose-response (Shock_Count)
    rhs2 <- c("Shock_Count", controls)
    rhs2 <- rhs2[rhs2 %in% names(df)]
    f2 <- as.formula(paste(dep_col, "~", paste(rhs2, collapse = " + "), "| fips_code + Year"))

    for (wt in c("Unweighted", "Population")) {
      wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
      if (wt == "Population" && is.null(wt_arg)) next

      # Spec 1
      m1 <- safe_feols(f1, df, "State", wt_arg)
      if (!is.null(m1)) {
        N1 <- nobs(m1)
        coefs_compound[[length(coefs_compound) + 1]] <- extract_coef(
          m1, "Any_Shock", "Any_Shock", o, h, "LP_Compound_Additive", wt, N1)
        coefs_compound[[length(coefs_compound) + 1]] <- extract_coef(
          m1, "Compound_Shock", "Compound_Shock", o, h, "LP_Compound_Additive", wt, N1)
      }

      # Spec 2
      m2 <- safe_feols(f2, df, "State", wt_arg)
      if (!is.null(m2)) {
        coefs_compound[[length(coefs_compound) + 1]] <- extract_coef(
          m2, "Shock_Count", "Shock_Count", o, h, "LP_Dose_Response", wt, nobs(m2))
      }

      # RA clustering for premium outcomes (compound specs)
      if (o == "Benchmark_Silver_Real" && "rating_area_id" %in% names(df)) {
        m1_ra <- safe_feols(f1, df, "rating_area_id", wt_arg)
        if (!is.null(m1_ra)) {
          N1_ra <- nobs(m1_ra)
          coefs_compound[[length(coefs_compound) + 1]] <- extract_coef(
            m1_ra, "Any_Shock", "Any_Shock", o, h, "LP_Compound_Additive_RA", wt, N1_ra)
          coefs_compound[[length(coefs_compound) + 1]] <- extract_coef(
            m1_ra, "Compound_Shock", "Compound_Shock", o, h, "LP_Compound_Additive_RA", wt, N1_ra)
        }
        m2_ra <- safe_feols(f2, df, "rating_area_id", wt_arg)
        if (!is.null(m2_ra)) {
          coefs_compound[[length(coefs_compound) + 1]] <- extract_coef(
            m2_ra, "Shock_Count", "Shock_Count", o, h, "LP_Dose_Response_RA", wt, nobs(m2_ra))
        }
      }
    }
  }
}

# 7. Combine & Export Coefficients ----------------------------------------

coefs_all <- bind_rows(c(coefs_dl, coefs_lp, coefs_compound))
if (nrow(coefs_all) > 0) {
  write.csv(coefs_all, output_coefs, row.names = FALSE)
  cat("\nCoefficients saved to:", output_coefs, "\n")
  cat("Total rows:", nrow(coefs_all), "\n")
  cat("Breakdown:\n")
  print(table(coefs_all$approach, coefs_all$weighting))
} else {
  cat("WARNING: No coefficients extracted.\n")
}

# 8. Visualization --------------------------------------------------------

cat("\n=== Generating Plots ===\n")

# Filter to state-clustered main results for plotting
plot_data <- coefs_all %>%
  filter(approach %in% c("DL", "LP"), weighting == "Unweighted")

make_es_plot <- function(data, title, filename) {
  if (nrow(data) == 0) return(invisible(NULL))
  p <- ggplot(data, aes(x = horizon, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
    geom_pointrange(aes(ymin = ci_low, ymax = ci_high), size = 0.5) +
    scale_x_continuous(breaks = h_min:h_max) +
    labs(title = title, x = "Horizon (years)", y = "Estimate") +
    theme_minimal(base_size = 12) +
    theme(plot.background = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA))
  ggsave(file.path(plot_dir, filename), p, width = 7, height = 5, dpi = 150, bg = "white")
  invisible(p)
}

# Per-approach plots
for (s in shocks) {
  for (o in outcomes) {
    dl_sub <- plot_data %>% filter(shock == s, outcome == o, approach == "DL")
    lp_sub <- plot_data %>% filter(shock == s, outcome == o, approach == "LP")

    s_short <- gsub("Is_Extreme_", "", gsub("High_", "", s))
    o_short <- gsub("_Real|_2023", "", o)

    make_es_plot(dl_sub,
                 paste("Dynamic DL:", s, "->", o),
                 paste0("es_", s, "_", o, ".png"))
    make_es_plot(lp_sub,
                 paste("Local Projection:", s, "->", o),
                 paste0("lp_", s, "_", o, ".png"))
  }
}

# Comparison overlays for primary outcomes
for (s in shocks) {
  for (o in primary_outcomes) {
    comp <- plot_data %>% filter(shock == s, outcome == o)
    if (nrow(comp) == 0) next

    p <- ggplot(comp, aes(x = horizon, y = estimate, color = approach)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
      geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                      position = position_dodge(width = 0.3), size = 0.5) +
      scale_x_continuous(breaks = h_min:h_max) +
      scale_color_manual(values = c("DL" = "#2166AC", "LP" = "#B2182B"),
                         labels = c("DL" = "Dynamic DL", "LP" = "Local Projection")) +
      labs(title = paste("Comparison:", s, "->", o),
           x = "Horizon (years)", y = "Estimate", color = "Approach") +
      theme_minimal(base_size = 12) +
      theme(plot.background = element_rect(fill = "white", color = NA),
            panel.background = element_rect(fill = "white", color = NA))
    ggsave(file.path(plot_dir, paste0("es_comparison_", s, "_", o, ".png")),
           p, width = 8, height = 5, dpi = 150, bg = "white")
  }
}

# Compound shock LP plots
compound_plot_data <- coefs_all %>%
  filter(approach %in% c("LP_Compound_Additive", "LP_Dose_Response"),
         weighting == "Unweighted")

for (o in outcomes) {
  # Compound_Shock additive effect
  cs_sub <- compound_plot_data %>%
    filter(shock == "Compound_Shock", outcome == o, approach == "LP_Compound_Additive")
  make_es_plot(cs_sub,
               paste("Compound Shock (additive increment) ->", o),
               paste0("lp_Compound_Shock_", o, ".png"))

  # Dose-response: show predicted effect at Shock_Count = 1, 2, 3
  sc_sub <- compound_plot_data %>%
    filter(shock == "Shock_Count", outcome == o, approach == "LP_Dose_Response")
  if (nrow(sc_sub) > 0) {
    dose_data <- bind_rows(
      sc_sub %>% mutate(dose = "1 shock", estimate = estimate * 1,
                        ci_low = ci_low * 1, ci_high = ci_high * 1),
      sc_sub %>% mutate(dose = "2 shocks", estimate = estimate * 2,
                        ci_low = ci_low * 2, ci_high = ci_high * 2),
      sc_sub %>% mutate(dose = "3 shocks", estimate = estimate * 3,
                        ci_low = ci_low * 3, ci_high = ci_high * 3)
    )
    dose_data$dose <- factor(dose_data$dose, levels = c("1 shock", "2 shocks", "3 shocks"))

    p <- ggplot(dose_data, aes(x = horizon, y = estimate, color = dose)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
      geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                      position = position_dodge(width = 0.3), size = 0.5) +
      scale_x_continuous(breaks = h_min:h_max) +
      scale_color_manual(values = c("1 shock" = "#2166AC", "2 shocks" = "#B2182B",
                                    "3 shocks" = "#4DAF4A")) +
      labs(title = paste("Dose-Response: Shock Count ->", o),
           subtitle = "Predicted effect at 1, 2, and 3 simultaneous shocks (linear model)",
           x = "Horizon (years)", y = "Predicted Effect", color = "Dose") +
      theme_minimal(base_size = 12) +
      theme(plot.background = element_rect(fill = "white", color = NA),
            panel.background = element_rect(fill = "white", color = NA))
    ggsave(file.path(plot_dir, paste0("lp_Shock_Count_", o, ".png")),
           p, width = 8, height = 5, dpi = 150, bg = "white")
  }
}

# LP with shock-history robustness comparison plots (primary outcomes only)
for (s in shocks) {
  for (o in primary_outcomes) {
    lp_comp <- coefs_all %>%
      filter(shock == s, outcome == o, approach %in% c("LP", "LP_ShockHistory"),
             weighting == "Unweighted")
    if (nrow(lp_comp) == 0) next
    p <- ggplot(lp_comp, aes(x = horizon, y = estimate, color = approach)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
      geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                      position = position_dodge(width = 0.3), size = 0.5) +
      scale_x_continuous(breaks = h_min:h_max) +
      scale_color_manual(values = c("LP" = "#2166AC", "LP_ShockHistory" = "#B2182B"),
                         labels = c("LP" = "LP (no history)", "LP_ShockHistory" = "LP (with shock lags)")) +
      labs(title = paste("Shock-History Robustness:", s, "->", o),
           x = "Horizon (years)", y = "Estimate", color = "Specification") +
      theme_minimal(base_size = 12) +
      theme(plot.background = element_rect(fill = "white", color = NA),
            panel.background = element_rect(fill = "white", color = NA))
    ggsave(file.path(plot_dir, paste0("lp_history_robustness_", s, "_", o, ".png")),
           p, width = 8, height = 5, dpi = 150, bg = "white")
  }
}

# 9. Summary Diagnostics --------------------------------------------------

cat("\n=== Sample Diagnostics ===\n")
if (nrow(coefs_all) > 0) {
  diag <- coefs_all %>%
    filter(horizon == 0) %>%
    group_by(shock, outcome, approach, weighting) %>%
    summarize(N = first(N), .groups = "drop")
  print(as.data.frame(diag))
}

# Compound shock support diagnostics (E6)
cat("\n=== Compound Shock Support ===\n")
cat("NOTE: Compound results (Shock_Count >= 2) have thin support (~2.2% of obs).\n")
cat("Interpret compound coefficients as exploratory; CIs will be wide.\n\n")
compound_support <- coefs_all %>%
  filter(shock %in% c("Compound_Shock", "Shock_Count"),
         approach %in% c("LP_Compound_Additive", "LP_Dose_Response"),
         weighting == "Unweighted") %>%
  group_by(shock, outcome, approach) %>%
  summarize(
    horizons = n(),
    mean_N = round(mean(N)),
    mean_CI_width = round(mean(ci_high - ci_low, na.rm = TRUE), 4),
    .groups = "drop"
  )
if (nrow(compound_support) > 0) print(as.data.frame(compound_support))

cat("\n=== Dynamic Panel Impulse-Response Script Complete ===\n")
