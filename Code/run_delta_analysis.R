# Phase 3: Year-over-Year Weather Swing Analysis
#
# Estimand: the health/economic cost of weather *volatility* — year-to-year
# swings in climate exposure — distinct from the level effects in the event study.
#
# Primary spec (symmetric delta, controlling for lagged level):
#   Outcome_{it} = b1*Delta_X_{it} + b2*X_{it-1} + controls | fips_code + Year
#
# Distributed lag extension: h = 0, +1, +2, +3 forward horizons via Local Projections.
#
# Robustness specs:
#   - Asymmetric: separate Delta_Pos and Delta_Neg coefficients
#   - Binary onset/exit: Drought_Onset / Drought_Exit indicators
#
# Outputs:
#   Analysis/delta_coefs.csv          — tidy coefficient table
#   Analysis/delta_results.txt        — full model summaries
#   Analysis/plots/delta/             — coefficient plots
#   Analysis/plots/delta_robustness/  — asymmetry and onset/exit plots

# 1. Setup -----------------------------------------------------------------
library(dplyr)
library(tidyr)
library(fixest)
library(ggplot2)

source("Code/transition_symmetry.R")  # Phase 1: beta_Onset + beta_Exit = 0 Wald test

input_path     <- "Data/county_level_master.csv"
output_coefs   <- "Analysis/delta_coefs.csv"
output_results <- "Analysis/delta_results.txt"
plot_dir       <- "Analysis/plots/delta"
plot_dir_rob   <- "Analysis/plots/delta_robustness"
plot_dir_exit  <- "Analysis/plots/delta_exit_dynamics"
plot_dir_trans <- "Analysis/plots/delta_transition_compare"  # Phase 1 three-way

dir.create("Analysis",    showWarnings = FALSE)
dir.create(plot_dir,      showWarnings = FALSE, recursive = TRUE)
dir.create(plot_dir_rob,  showWarnings = FALSE, recursive = TRUE)
dir.create(plot_dir_exit, showWarnings = FALSE, recursive = TRUE)
dir.create(plot_dir_trans, showWarnings = FALSE, recursive = TRUE)

cat("Loading data...\n")
df <- read.csv(input_path, stringsAsFactors = FALSE)

# 2. Data Prep -------------------------------------------------------------

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

# Ensure panel is sorted for lead/lag operations
df <- df %>% arrange(fips_code, Year)

# Fill year gaps to avoid stale lags across non-contiguous years
df <- df %>%
  group_by(fips_code) %>%
  complete(Year = min(Year):max(Year)) %>%
  ungroup() %>%
  arrange(fips_code, Year)

# 3. Config ----------------------------------------------------------------

# Delta exposures and their corresponding lagged-level control variables
# Structure: list(delta = "Delta_X", lagged_level = "X_Lag1", label = "readable label")
delta_specs <- list(
  list(delta = "Delta_Z_Temp",     lagged_level = "Z_Temp_Lag1",  label = "Z_Temp"),
  list(delta = "Delta_Z_Precip",   lagged_level = "Z_Precip_Lag1", label = "Z_Precip"),
  list(delta = "Delta_CDD",        lagged_level = "High_CDD_Lag1", label = "CDD"),
  list(delta = "Delta_HDD",        lagged_level = "High_HDD_Lag1", label = "HDD"),
  list(delta = "Delta_PDSI",       lagged_level = "PDSI_Lag1",     label = "PDSI"),
  list(delta = "Delta_Median_AQI", lagged_level = "Median_AQI_Lag1", label = "Median_AQI"),
  list(delta = "Delta_Max_AQI",    lagged_level = "Max_AQI_Lag1",    label = "Max_AQI")
)

# Asymmetric robustness pairs: Pos and Neg columns for each delta
asym_specs <- list(
  list(pos = "Delta_Z_Temp_Pos",     neg = "Delta_Z_Temp_Neg",     lagged_level = "Z_Temp_Lag1",   label = "Z_Temp"),
  list(pos = "Delta_Z_Precip_Pos",   neg = "Delta_Z_Precip_Neg",   lagged_level = "Z_Precip_Lag1", label = "Z_Precip"),
  list(pos = "Delta_CDD_Pos",        neg = "Delta_CDD_Neg",        lagged_level = "High_CDD_Lag1", label = "CDD"),
  list(pos = "Delta_HDD_Pos",        neg = "Delta_HDD_Neg",        lagged_level = "High_HDD_Lag1", label = "HDD"),
  list(pos = "Delta_PDSI_Pos",       neg = "Delta_PDSI_Neg",       lagged_level = "PDSI_Lag1",     label = "PDSI"),
  list(pos = "Delta_Median_AQI_Pos", neg = "Delta_Median_AQI_Neg", lagged_level = "Median_AQI_Lag1", label = "Median_AQI"),
  list(pos = "Delta_Max_AQI_Pos",    neg = "Delta_Max_AQI_Neg",    lagged_level = "Max_AQI_Lag1",    label = "Max_AQI")
)

# Binary onset/exit robustness specs (only for binary-shock-derived indicators)
onset_exit_specs <- list(
  list(onset = "Drought_Onset", exit = "Drought_Exit", persist = "Drought_Persist", label = "Drought"),
  list(onset = "CDD_Onset",     exit = "CDD_Exit",     persist = "CDD_Persist",     label = "CDD"),
  list(onset = "HDD_Onset",     exit = "HDD_Exit",     persist = "HDD_Persist",     label = "HDD")
)

outcomes <- c("Medical_Debt_Share", "Benchmark_Silver_Real",
              "Medical_Debt_Median_2023", "Hosp_BadDebt_PerCapita",
              "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed")
outcomes <- outcomes[outcomes %in% names(df)]

controls <- intersect(c("Household_Income_2023", "Uninsured_Rate"), names(df))

h_max <- 3L  # LP forward horizons 0..h_max

cat("Outcomes:", paste(outcomes, collapse = ", "), "\n")

# Filter delta_specs to variables that are actually present in df
delta_specs    <- Filter(function(s) s$delta %in% names(df), delta_specs)
asym_specs     <- Filter(function(s) s$pos %in% names(df) && s$neg %in% names(df), asym_specs)
onset_exit_specs <- Filter(function(s) s$onset %in% names(df), onset_exit_specs)

cat("Delta exposures available:", paste(sapply(delta_specs, `[[`, "label"), collapse = ", "), "\n")

# 4. Forward-horizon columns for LP ----------------------------------------

cat("Constructing LP forward outcome columns...\n")
for (o in outcomes) {
  df <- df %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      !!paste0(o, "_fwd0") := .data[[o]],
      !!paste0(o, "_fwd1") := dplyr::lead(.data[[o]], 1),
      !!paste0(o, "_fwd2") := dplyr::lead(.data[[o]], 2),
      !!paste0(o, "_fwd3") := dplyr::lead(.data[[o]], 3)
    ) %>%
    ungroup()
}

# 5. Helpers ---------------------------------------------------------------

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

extract_coef <- function(model, term, exposure, outcome, horizon, approach, weighting, N) {
  if (is.null(model)) return(NULL)
  ct <- as.data.frame(coeftable(model))
  ct$Term <- rownames(ct)
  row <- ct[ct$Term == term, , drop = FALSE]
  if (nrow(row) == 0) return(NULL)
  data.frame(
    exposure = exposure, outcome = outcome, horizon = horizon,
    term = term,
    estimate  = row$Estimate,
    std.error = row$`Std. Error`,
    p.value   = row$`Pr(>|t|)`,
    ci_low    = row$Estimate - 1.96 * row$`Std. Error`,
    ci_high   = row$Estimate + 1.96 * row$`Std. Error`,
    N = N, approach = approach, weighting = weighting,
    stringsAsFactors = FALSE
  )
}

# 6. Primary Spec: Contemporaneous FE (h=0) --------------------------------
# Outcome ~ Delta_X + Lagged_Level_X + controls | fips_code + Year
# Separates the change effect (b1) from the lagged level effect (b2).

cat("\n=== Primary Spec: Contemporaneous Delta FE ===\n")
coefs_primary <- list()

sink(output_results)
cat("=== Delta Analysis: Model Summaries ===\n\n")

for (spec in delta_specs) {
  for (o in outcomes) {
    # Build RHS: delta + lagged level + controls (drop missing columns)
    rhs <- c(spec$delta, spec$lagged_level, controls)
    rhs <- rhs[rhs %in% names(df)]
    f <- as.formula(paste(o, "~", paste(rhs, collapse = " + "), "| fips_code + Year"))

    for (wt in c("Unweighted", "Population")) {
      wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
      if (wt == "Population" && is.null(wt_arg)) next

      m <- safe_feols(f, df, "State", wt_arg)
      if (!is.null(m)) {
        label <- paste(spec$label, o, wt, sep = " | ")
        cat(paste0("\n--- ", label, " ---\n"))
        print(summary(m))
        N <- nobs(m)
        coefs_primary[[length(coefs_primary) + 1]] <- extract_coef(
          m, spec$delta, spec$label, o, 0L, "Delta_FE", wt, N)
        # Also capture lagged level coefficient for comparison
        if (spec$lagged_level %in% names(df)) {
          coefs_primary[[length(coefs_primary) + 1]] <- extract_coef(
            m, spec$lagged_level, paste0(spec$label, "_LaggedLevel"), o, 0L, "Delta_FE", wt, N)
        }

        # RA clustering for premium outcomes
        if (o == "Benchmark_Silver_Real" && "rating_area_id" %in% names(df)) {
          m_ra <- safe_feols(f, df, "rating_area_id", wt_arg)
          if (!is.null(m_ra)) {
            N_ra <- nobs(m_ra)
            coefs_primary[[length(coefs_primary) + 1]] <- extract_coef(
              m_ra, spec$delta, spec$label, o, 0L, "Delta_FE_RA_Cluster", wt, N_ra)
          }
        }
      }
    }
  }
}

# 7. LP Distributed Lag on Delta (h = 0..h_max) ----------------------------
# Outcome_{t+h} ~ Delta_X_t + Lagged_Level_X_t + controls | fips_code + Year
# Shows whether swing effects persist or decay over subsequent years.

cat("\n=== LP Distributed Lag on Delta ===\n")
coefs_lp <- list()

for (spec in delta_specs) {
  for (o in outcomes) {
    for (h in 0L:h_max) {
      dep_col <- paste0(o, "_fwd", h)
      if (!dep_col %in% names(df)) next

      rhs <- c(spec$delta, spec$lagged_level, controls)
      rhs <- rhs[rhs %in% names(df)]
      f <- as.formula(paste(dep_col, "~", paste(rhs, collapse = " + "), "| fips_code + Year"))

      for (wt in c("Unweighted", "Population")) {
        wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
        if (wt == "Population" && is.null(wt_arg)) next

        m <- safe_feols(f, df, "State", wt_arg)
        if (!is.null(m)) {
          coefs_lp[[length(coefs_lp) + 1]] <- extract_coef(
            m, spec$delta, spec$label, o, h, "Delta_LP", wt, nobs(m))
        }
      }
    }
  }
}

# 8. Asymmetric Robustness -------------------------------------------------
# Replace symmetric delta with Delta_Pos and Delta_Neg.
# Significant asymmetry (b_pos != |b_neg|) indicates ratchet / hysteresis.

cat("\n=== Asymmetric Robustness Specs ===\n")
coefs_asym <- list()

for (spec in asym_specs) {
  for (o in outcomes) {
    rhs <- c(spec$pos, spec$neg, spec$lagged_level, controls)
    rhs <- rhs[rhs %in% names(df)]
    f <- as.formula(paste(o, "~", paste(rhs, collapse = " + "), "| fips_code + Year"))

    for (wt in c("Unweighted", "Population")) {
      wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
      if (wt == "Population" && is.null(wt_arg)) next

      m <- safe_feols(f, df, "State", wt_arg)
      if (!is.null(m)) {
        N <- nobs(m)
        label <- paste(spec$label, o, wt, sep = " | ")
        cat(paste0("\n--- Asymmetric: ", label, " ---\n"))
        print(summary(m))
        coefs_asym[[length(coefs_asym) + 1]] <- extract_coef(
          m, spec$pos, paste0(spec$label, "_Pos"), o, 0L, "Delta_Asym", wt, N)
        coefs_asym[[length(coefs_asym) + 1]] <- extract_coef(
          m, spec$neg, paste0(spec$label, "_Neg"), o, 0L, "Delta_Asym", wt, N)
      }
    }
  }
}

# 9. Binary Onset/Exit Robustness ------------------------------------------
# Replaces continuous delta with shock entry (0->1), exit (1->0), persist (1->1).
# Tests whether it is the *transition* itself that drives outcomes.

cat("\n=== Binary Onset/Exit Robustness ===\n")
coefs_onset <- list()

for (spec in onset_exit_specs) {
  for (o in outcomes) {
    indicators <- c(spec$onset, spec$exit, spec$persist)
    indicators <- indicators[indicators %in% names(df)]
    if (length(indicators) == 0) next

    rhs <- c(indicators, controls)
    rhs <- rhs[rhs %in% names(df)]
    f <- as.formula(paste(o, "~", paste(rhs, collapse = " + "), "| fips_code + Year"))

    for (wt in c("Unweighted", "Population")) {
      wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
      if (wt == "Population" && is.null(wt_arg)) next

      m <- safe_feols(f, df, "State", wt_arg)
      if (!is.null(m)) {
        N <- nobs(m)
        for (ind in indicators) {
          coefs_onset[[length(coefs_onset) + 1]] <- extract_coef(
            m, ind, paste0(spec$label, "_", sub(".*_", "", ind)), o, 0L, "Delta_OnsetExit", wt, N)
        }
      }
    }
  }
}

sink()
cat("Model summaries saved to:", output_results, "\n")

# 9b. Exit LP horizons (Committee Feedback Phase 2) ------------------------
# Block A: lead(Y, h) ~ Exit_{i,t} + controls | fips_code + Year for h=0..3.
# Direct dynamic response to leaving shock status; complements section 9's h=0 onset/exit table.
# Block B: lead(Y, h) ~ Shock_{i,t-1} * NoShock_{i,t} | fips_code + Year.
# The interaction term isolates counties that were shocked at t-1 AND recovered at t —
# i.e. the scarring/relief population — separately from never-shocked and persistently-shocked.

cat("\n=== Exit LP Horizons (Phase 2) ===\n")

exit_lp_specs <- list(
  list(exit = "Drought_Exit", shock = "Is_Extreme_Drought", label = "Drought"),
  list(exit = "CDD_Exit",     shock = "High_CDD",           label = "CDD"),
  list(exit = "HDD_Exit",     shock = "High_HDD",           label = "HDD")
)
exit_lp_specs <- Filter(function(s) s$exit %in% names(df) && s$shock %in% names(df),
                        exit_lp_specs)

# Lagged-shock and NoShock columns for Block B interaction term
for (spec in exit_lp_specs) {
  lag_col   <- paste0(spec$shock, "_LagShock")
  no_col    <- paste0(spec$shock, "_NoShock")
  df <- df %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      !!lag_col := dplyr::lag(.data[[spec$shock]], 1),
      !!no_col  := 1L - .data[[spec$shock]]
    ) %>%
    ungroup()
}

coefs_exit_lp     <- list()
coefs_exit_interact <- list()

sink(output_results, append = TRUE)
cat("\n\n=== Exit LP Horizons (Phase 2) ===\n\n")

for (spec in exit_lp_specs) {
  lag_col <- paste0(spec$shock, "_LagShock")
  no_col  <- paste0(spec$shock, "_NoShock")

  for (o in outcomes) {
    for (h in 0L:h_max) {
      dep_col <- paste0(o, "_fwd", h)
      if (!dep_col %in% names(df)) next

      # ---- Block A: Exit LP ----
      rhs_A <- c(spec$exit, controls)
      rhs_A <- rhs_A[rhs_A %in% names(df)]
      f_A <- as.formula(paste(dep_col, "~", paste(rhs_A, collapse = " + "),
                              "| fips_code + Year"))

      # ---- Block B: Exit-after-shock interaction ----
      rhs_B <- c(paste0(lag_col, " * ", no_col), controls)
      rhs_B <- c(rhs_B[1], rhs_B[-1][rhs_B[-1] %in% names(df)])
      f_B <- as.formula(paste(dep_col, "~", paste(rhs_B, collapse = " + "),
                              "| fips_code + Year"))

      for (wt in c("Unweighted", "Population")) {
        wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
        if (wt == "Population" && is.null(wt_arg)) next

        # Block A
        m_A <- safe_feols(f_A, df, "State", wt_arg)
        if (!is.null(m_A)) {
          label <- paste("Exit_LP", spec$label, o, paste0("h=", h), wt, sep = " | ")
          cat(paste0("\n--- ", label, " ---\n"))
          print(summary(m_A))
          N_A <- nobs(m_A)
          coefs_exit_lp[[length(coefs_exit_lp) + 1]] <- extract_coef(
            m_A, spec$exit, paste0(spec$label, "_Exit"), o, h, "Delta_Exit_LP", wt, N_A)

          # RA cluster for premium outcomes
          if (o == "Benchmark_Silver_Real" && "rating_area_id" %in% names(df)) {
            m_A_ra <- safe_feols(f_A, df, "rating_area_id", wt_arg)
            if (!is.null(m_A_ra)) {
              coefs_exit_lp[[length(coefs_exit_lp) + 1]] <- extract_coef(
                m_A_ra, spec$exit, paste0(spec$label, "_Exit"), o, h,
                "Delta_Exit_LP_RA_Cluster", wt, nobs(m_A_ra))
            }
          }
        }

        # Block B
        m_B <- safe_feols(f_B, df, "State", wt_arg)
        if (!is.null(m_B)) {
          label <- paste("Exit_Interaction", spec$label, o, paste0("h=", h), wt, sep = " | ")
          cat(paste0("\n--- ", label, " ---\n"))
          print(summary(m_B))
          N_B <- nobs(m_B)
          # Capture all three terms: LagShock main, NoShock main, interaction
          interaction_term <- paste0(lag_col, ":", no_col)
          for (trm in c(lag_col, no_col, interaction_term)) {
            coefs_exit_interact[[length(coefs_exit_interact) + 1]] <- extract_coef(
              m_B, trm, paste0(spec$label, "_", trm), o, h,
              "Delta_Exit_Interaction", wt, N_B)
          }

          # RA cluster for premium outcomes
          if (o == "Benchmark_Silver_Real" && "rating_area_id" %in% names(df)) {
            m_B_ra <- safe_feols(f_B, df, "rating_area_id", wt_arg)
            if (!is.null(m_B_ra)) {
              N_B_ra <- nobs(m_B_ra)
              for (trm in c(lag_col, no_col, interaction_term)) {
                coefs_exit_interact[[length(coefs_exit_interact) + 1]] <- extract_coef(
                  m_B_ra, trm, paste0(spec$label, "_", trm), o, h,
                  "Delta_Exit_Interaction_RA_Cluster", wt, N_B_ra)
              }
            }
          }
        }
      }
    }
  }
}

sink()
cat("Exit LP / Interaction summaries appended to:", output_results, "\n")

# 9c. Transition LP: Onset / Persist / Exit jointly + symmetry test (Phase 1) --
# Persistence Extensions Phase 1. Estimates the full transition trio JOINTLY:
#   lead(Y, h) ~ Onset + Persist + Exit + controls | fips_code + Year   (h=0..3)
# All three are measured against the never-transitioned (0 -> 0) reference, so the
# Onset/Persist/Exit coefficients are directly comparable (three-way comparison)
# and the symmetry test beta_Onset + beta_Exit = 0 reads off the joint clustered
# vcov (see Code/transition_symmetry.R). This complements the separate Exit-LP
# block (9b) retained from Phase 2.

cat("\n=== Transition LP (Onset/Persist/Exit) + Symmetry (Phase 1) ===\n")

# approach tag per transition suffix
approach_for <- c(Onset = "Delta_Onset_LP", Persist = "Delta_Persist_LP",
                  Exit = "Delta_Exit_LP_Joint")

coefs_trans_lp <- list()
symmetry_rows  <- list()

sink(output_results, append = TRUE)
cat("\n\n=== Transition LP (Phase 1) ===\n\n")

for (spec in onset_exit_specs) {
  terms_three <- c(spec$onset, spec$persist, spec$exit)
  terms_three <- terms_three[terms_three %in% names(df)]
  # Need at least onset + exit present for the joint spec and symmetry test.
  if (!all(c(spec$onset, spec$exit) %in% terms_three)) next

  for (o in outcomes) {
    for (h in 0L:h_max) {
      dep_col <- paste0(o, "_fwd", h)
      if (!dep_col %in% names(df)) next

      rhs <- c(terms_three, controls)
      rhs <- rhs[rhs %in% names(df)]
      f <- as.formula(paste(dep_col, "~", paste(rhs, collapse = " + "),
                            "| fips_code + Year"))

      for (wt in c("Unweighted", "Population")) {
        wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
        if (wt == "Population" && is.null(wt_arg)) next

        m <- safe_feols(f, df, "State", wt_arg)
        if (is.null(m)) next
        N <- nobs(m)

        if (h == 0L && wt == "Unweighted") {
          cat(paste0("\n--- Transition LP | ", spec$label, " | ", o, " | h=0 ---\n"))
          print(summary(m))
        }

        # Per-transition coefficient rows
        for (trm in terms_three) {
          suffix <- sub(".*_", "", trm)   # Onset / Persist / Exit
          coefs_trans_lp[[length(coefs_trans_lp) + 1]] <- extract_coef(
            m, trm, paste0(spec$label, "_", suffix), o, h,
            approach_for[[suffix]], wt, N)
        }

        # Symmetry test on the joint (state-clustered) fit
        st <- transition_symmetry_test(m, spec$onset, spec$exit)
        if (!is.null(st)) {
          st$shock <- spec$label; st$outcome <- o; st$horizon <- h
          st$weighting <- wt; st$N <- N
          symmetry_rows[[length(symmetry_rows) + 1]] <- st
        }

        # RA-cluster variant for the premium outcome (consistency with 9b)
        if (o == "Benchmark_Silver_Real" && "rating_area_id" %in% names(df)) {
          m_ra <- safe_feols(f, df, "rating_area_id", wt_arg)
          if (!is.null(m_ra)) {
            for (trm in terms_three) {
              suffix <- sub(".*_", "", trm)
              coefs_trans_lp[[length(coefs_trans_lp) + 1]] <- extract_coef(
                m_ra, trm, paste0(spec$label, "_", suffix), o, h,
                paste0(approach_for[[suffix]], "_RA_Cluster"), wt, nobs(m_ra))
            }
          }
        }
      }
    }
  }
}

sink()
cat("Transition LP summaries appended to:", output_results, "\n")

# Export symmetry test (Phase 1, task 3)
if (length(symmetry_rows) > 0) {
  symmetry_df <- bind_rows(symmetry_rows)
  symmetry_df <- symmetry_df[, c("shock", "outcome", "horizon", "weighting", "N",
                                 "beta_onset", "beta_exit", "asymmetry",
                                 "std.error", "z.value", "p.value", "reject_symmetry")]
  write.csv(symmetry_df, "Analysis/delta_symmetry_test.csv", row.names = FALSE)
  cat("Symmetry test results saved to: Analysis/delta_symmetry_test.csv (",
      nrow(symmetry_df), " rows)\n", sep = "")
}

# 10. VIF Diagnostics ------------------------------------------------------

cat("\n=== VIF Diagnostics (Delta + Lagged Level Block) ===\n")
vif_log <- file("Analysis/delta_vif_diagnostics.txt", "w")

for (spec in delta_specs[1:3]) {  # spot-check first 3 exposures
  for (o in outcomes[1:2]) {
    rhs <- c(spec$delta, spec$lagged_level, controls)
    rhs <- rhs[rhs %in% names(df)]
    if (length(rhs) < 2) next

    # Auxiliary OLS on within-transformed predictors to compute VIF
    tryCatch({
      aux_data <- df %>%
        select(all_of(c("fips_code", "Year", rhs))) %>%
        filter(complete.cases(.)) %>%
        group_by(fips_code) %>%
        mutate(across(all_of(rhs), ~ . - mean(., na.rm = TRUE))) %>%
        ungroup() %>%
        group_by(Year) %>%
        mutate(across(all_of(rhs), ~ . - mean(., na.rm = TRUE))) %>%
        ungroup()

      vif_vals <- sapply(rhs, function(v) {
        others <- setdiff(rhs, v)
        if (length(others) == 0) return(NA_real_)
        f_aux <- as.formula(paste(v, "~", paste(others, collapse = " + ")))
        r2 <- summary(lm(f_aux, data = aux_data))$r.squared
        if (is.na(r2) || r2 >= 1) NA_real_ else 1 / (1 - r2)
      })

      writeLines(paste0("\n[", spec$label, " | ", o, "]"), vif_log)
      writeLines(paste(names(vif_vals), round(vif_vals, 3), sep = ": "), vif_log)
    }, error = function(e) {
      writeLines(paste0("[", spec$label, " | ", o, "] ERROR: ", conditionMessage(e)), vif_log)
    })
  }
}

close(vif_log)
cat("VIF diagnostics saved to Analysis/delta_vif_diagnostics.txt\n")

# 11. Combine & Export Coefficients ----------------------------------------

all_coef_lists <- c(coefs_primary, coefs_lp, coefs_asym, coefs_onset,
                    coefs_exit_lp, coefs_exit_interact, coefs_trans_lp)
all_coef_lists <- Filter(Negate(is.null), all_coef_lists)
coefs_all <- if (length(all_coef_lists) > 0) bind_rows(all_coef_lists) else data.frame()
if (nrow(coefs_all) > 0) {
  write.csv(coefs_all, output_coefs, row.names = FALSE)
  cat("\nCoefficients saved to:", output_coefs, "\n")
  cat("Total rows:", nrow(coefs_all), "\n")
  cat("Breakdown by approach:\n")
  print(table(coefs_all$approach, coefs_all$weighting))
} else {
  cat("WARNING: No coefficients extracted.\n")
}

# 12. Visualization --------------------------------------------------------

cat("\n=== Generating Plots ===\n")

# Helper: standard coefficient plot
make_coef_plot <- function(data, title, filename, dir = plot_dir) {
  if (nrow(data) == 0) return(invisible(NULL))
  p <- ggplot(data, aes(x = horizon, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(ymin = ci_low, ymax = ci_high), size = 0.5) +
    scale_x_continuous(breaks = unique(data$horizon)) +
    labs(title = title, x = "Horizon (years after swing)", y = "Estimate") +
    theme_minimal(base_size = 12) +
    theme(plot.background  = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA))
  ggsave(file.path(dir, filename), p, width = 7, height = 5, dpi = 150, bg = "white")
  invisible(p)
}

# 12a. LP dynamic profiles per exposure x outcome
lp_plot <- coefs_all %>% filter(approach == "Delta_LP", weighting == "Unweighted")

for (exp_label in unique(lp_plot$exposure)) {
  for (o in outcomes) {
    sub <- lp_plot %>% filter(exposure == exp_label, outcome == o)
    if (nrow(sub) == 0) next
    make_coef_plot(sub,
                   paste("Delta LP:", exp_label, "->", o),
                   paste0("lp_delta_", exp_label, "_", o, ".png"))
  }
}

# 12b. Level vs. Delta comparison (contemporaneous h=0, unweighted)
level_cols <- sapply(delta_specs, `[[`, "label")

for (exp_label in level_cols) {
  for (o in outcomes) {
    delta_row <- coefs_all %>%
      filter(approach == "Delta_FE", exposure == exp_label,
             outcome == o, weighting == "Unweighted")
    if (nrow(delta_row) == 0) next

    delta_row$spec <- "Delta"

    combined <- delta_row %>% select(spec, estimate, ci_low, ci_high)

    p <- ggplot(combined, aes(x = spec, y = estimate)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_pointrange(aes(ymin = ci_low, ymax = ci_high), size = 0.6) +
      labs(title = paste("Delta Effect:", exp_label, "->", o),
           x = NULL, y = "Estimate") +
      theme_minimal(base_size = 12) +
      theme(plot.background  = element_rect(fill = "white", color = NA),
            panel.background = element_rect(fill = "white", color = NA))
    ggsave(file.path(plot_dir, paste0("delta_fe_", exp_label, "_", o, ".png")),
           p, width = 5, height = 4, dpi = 150, bg = "white")
  }
}

# 12c. Asymmetry plots: Pos vs Neg per exposure x outcome
asym_plot <- coefs_all %>% filter(approach == "Delta_Asym", weighting == "Unweighted")

for (o in outcomes) {
  sub <- asym_plot %>% filter(outcome == o)
  if (nrow(sub) == 0) next

  # Strip "_Pos"/"_Neg" to get base label; add direction column
  sub <- sub %>%
    mutate(
      direction = ifelse(grepl("_Pos$", exposure), "Escalation (+)", "Relief (-)"),
      base_label = gsub("_Pos$|_Neg$", "", exposure)
    )

  p <- ggplot(sub, aes(x = base_label, y = estimate, color = direction)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                    position = position_dodge(width = 0.4), size = 0.5) +
    scale_color_manual(values = c("Escalation (+)" = "#B2182B", "Relief (-)" = "#2166AC")) +
    labs(title = paste("Asymmetric Delta Effects ->", o),
         subtitle = "Escalation = positive swing; Relief = negative swing",
         x = "Exposure", y = "Estimate", color = NULL) +
    theme_minimal(base_size = 11) +
    theme(axis.text.x = element_text(angle = 30, hjust = 1),
          plot.background  = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA))
  ggsave(file.path(plot_dir_rob, paste0("asym_delta_", o, ".png")),
         p, width = 9, height = 5, dpi = 150, bg = "white")
}

# 12d. Onset/Exit plots per exposure x outcome
onset_plot <- coefs_all %>% filter(approach == "Delta_OnsetExit", weighting == "Unweighted")

for (o in outcomes) {
  sub <- onset_plot %>% filter(outcome == o)
  if (nrow(sub) == 0) next

  sub <- sub %>%
    mutate(transition = gsub(".*_(Onset|Exit|Persist)$", "\\1", exposure),
           base_label = gsub("_(Onset|Exit|Persist)$", "", exposure))

  p <- ggplot(sub, aes(x = base_label, y = estimate, color = transition)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                    position = position_dodge(width = 0.4), size = 0.5) +
    scale_color_manual(values = c("Onset" = "#B2182B", "Exit" = "#2166AC", "Persist" = "#4DAF4A")) +
    labs(title = paste("Onset / Exit / Persist Effects ->", o),
         x = "Shock", y = "Estimate", color = "Transition") +
    theme_minimal(base_size = 11) +
    theme(plot.background  = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA))
  ggsave(file.path(plot_dir_rob, paste0("onset_exit_", o, ".png")),
         p, width = 8, height = 5, dpi = 150, bg = "white")
}

# 12e. Exit LP dynamic profiles (Block A: Phase 2) -------------------------

exit_lp_plot <- coefs_all %>%
  filter(approach == "Delta_Exit_LP", weighting == "Unweighted")

for (exp_label in unique(exit_lp_plot$exposure)) {
  for (o in outcomes) {
    sub <- exit_lp_plot %>% filter(exposure == exp_label, outcome == o)
    if (nrow(sub) == 0) next
    make_coef_plot(sub,
                   paste("Post-Exit LP:", exp_label, "->", o),
                   paste0("exit_lp_", exp_label, "_", o, ".png"),
                   dir = plot_dir_exit)
  }
}

# 12f. Exit interaction dynamic profiles (Block B: Phase 2) ----------------
# Show the interaction term (Shock_{t-1} * NoShock_{t}) in its own panel,
# with the two main effects (LagShock, NoShock) in a separate panel.

exit_interact_plot <- coefs_all %>%
  filter(approach == "Delta_Exit_Interaction", weighting == "Unweighted")

for (shock_label in c("Drought", "CDD", "HDD")) {
  for (o in outcomes) {
    sub <- exit_interact_plot %>%
      filter(grepl(paste0("^", shock_label, "_"), exposure), outcome == o)
    if (nrow(sub) == 0) next

    sub <- sub %>%
      mutate(
        component = case_when(
          grepl(":", term) ~ "Interaction (Shock_{t-1} x NoShock_{t})",
          grepl("_NoShock$", term) ~ "NoShock_{t} (main)",
          grepl("_LagShock$", term) ~ "Shock_{t-1} (main)",
          TRUE ~ term
        ),
        panel = ifelse(grepl("Interaction", component),
                       "Interaction (scarring/relief)",
                       "Main effects")
      )

    p <- ggplot(sub, aes(x = horizon, y = estimate, color = component)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                      position = position_dodge(width = 0.3), size = 0.5) +
      facet_wrap(~ panel, scales = "free_y", ncol = 2) +
      scale_x_continuous(breaks = unique(sub$horizon)) +
      labs(title = paste("Exit Interaction:", shock_label, "->", o),
           subtitle = "Shock_{t-1} * NoShock_{t} isolates the recovery cohort",
           x = "Horizon h (years)", y = "Estimate", color = NULL) +
      theme_minimal(base_size = 11) +
      theme(legend.position = "bottom",
            plot.background  = element_rect(fill = "white", color = NA),
            panel.background = element_rect(fill = "white", color = NA))
    ggsave(file.path(plot_dir_exit,
                     paste0("exit_interact_", shock_label, "_", o, ".png")),
           p, width = 10, height = 5, dpi = 150, bg = "white")
  }
}

# 12g. Three-way transition comparison (Onset/Persist/Exit) — Phase 1 --------
# One PNG per (shock x outcome): Onset, Persist, Exit on the same axis across
# horizons h=0..3, from the joint transition LP. Also writes the long-format
# comparison table delta_transition_summary.csv (Phase 1, task 2).

trans_long <- coefs_all %>%
  filter(approach %in% c("Delta_Onset_LP", "Delta_Persist_LP", "Delta_Exit_LP_Joint"),
         weighting == "Unweighted") %>%
  mutate(
    transition = sub(".*_", "", exposure),                  # Onset/Persist/Exit
    shock      = sub("_(Onset|Persist|Exit)$", "", exposure)
  ) %>%
  arrange(shock, outcome, transition, horizon)

if (nrow(trans_long) > 0) {
  write.csv(
    trans_long %>% select(shock, outcome, horizon, transition,
                          estimate, std.error, p.value, N),
    "Analysis/delta_transition_summary.csv", row.names = FALSE)
  cat("Three-way transition summary saved to: Analysis/delta_transition_summary.csv\n")

  trans_colors <- c("Onset" = "#B2182B", "Persist" = "#4DAF4A", "Exit" = "#2166AC")
  for (sh in unique(trans_long$shock)) {
    for (o in outcomes) {
      sub <- trans_long %>% filter(shock == sh, outcome == o)
      if (nrow(sub) == 0) next
      p <- ggplot(sub, aes(x = horizon, y = estimate, color = transition)) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
        geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                        position = position_dodge(width = 0.3), size = 0.5) +
        scale_x_continuous(breaks = unique(sub$horizon)) +
        scale_color_manual(values = trans_colors) +
        labs(title = paste("Onset / Persist / Exit:", sh, "->", o),
             subtitle = "Joint LP; effect vs never-transitioned (0->0) reference",
             x = "Horizon h (years)", y = "Estimate", color = "Transition") +
        theme_minimal(base_size = 11) +
        theme(plot.background  = element_rect(fill = "white", color = NA),
              panel.background = element_rect(fill = "white", color = NA))
      ggsave(file.path(plot_dir_trans, paste0("transition_", sh, "_", o, ".png")),
             p, width = 7, height = 5, dpi = 150, bg = "white")
    }
  }
}

# 13. Summary Diagnostics --------------------------------------------------

cat("\n=== Sample Diagnostics (h=0, Unweighted) ===\n")
diag <- coefs_all %>%
  filter(horizon == 0, weighting == "Unweighted") %>%
  group_by(exposure, outcome, approach) %>%
  summarize(N = first(N), .groups = "drop")
print(as.data.frame(diag))

cat("\n=== Delta Analysis Complete ===\n")
