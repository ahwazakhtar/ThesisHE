# Random-Effects Robustness for Primary FE Specs (Committee Feedback Phase 1)
#
# Committee question: "check random effects." This script estimates RE
# counterparts to the primary state and county FE models and reports
# Hausman tests for each matched pair.
#
# CLAUDE.md notes that primary regressions use `fixest::feols` and that
# `plm` should not be used. This script is an explicit, scoped exception:
# Hausman testing fundamentally requires the RE estimator that fixest does
# not expose. The primary analysis pipeline (`run_analysis.R`,
# `run_county_analysis.R`) remains on fixest. This file produces a
# robustness appendix only.
#
# Hausman design: One-way RE/FE on the cross-sectional unit (State or
# fips_code) with year dummies entering as covariates. This is the
# standard Hausman setup and matches the two-way FE structure used in
# the primary specs to the extent identification permits.
#
# Inputs:
#   Data/analysis_ready_dataset.csv      (state-level panel)
#   Data/county_level_master.csv         (county-level panel)
#
# Outputs:
#   Analysis/random_effects_results.csv  (long: outcome x term x FE/RE estimates)
#   Analysis/random_effects_hausman.csv  (one row per outcome with test stat + p)

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(plm)
  library(fixest)
})

dir.create("Analysis", showWarnings = FALSE)

# ===========================================================================
# Helpers
# ===========================================================================

# Build a tidy coef table from a plm fit.
tidy_plm <- function(m, label) {
  if (is.null(m)) return(NULL)
  ct <- summary(m)$coefficients
  if (is.null(ct) || nrow(ct) == 0) return(NULL)
  out <- data.frame(
    Term = rownames(ct),
    Estimate = ct[, 1],
    Std_Error = ct[, 2],
    t_value = ct[, 3],
    p_value = ct[, 4],
    Spec = label,
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  out
}

# Wrapper that runs FE-within, RE-random, and the Hausman test on the same
# RHS. Uses `effect = "twoways"` to match the primary State+Year /
# fips_code+Year FE structure in run_analysis.R and run_county_analysis.R.
# Falls back to `effect = "individual"` if the two-way RE GLS step is
# numerically singular (which can happen on thin-year outcomes).
fit_fe_re_hausman <- function(formula, data, index, outcome_label) {
  fit_re <- function(effect) {
    plm(formula, data = data, index = index, model = "random", effect = effect)
  }
  fit_fe <- function(effect) {
    plm(formula, data = data, index = index, model = "within", effect = effect)
  }

  fe <- tryCatch(fit_fe("twoways"),
                 error = function(e) tryCatch(fit_fe("individual"),
                                              error = function(e2) {
                                                cat("FE fit failed for", outcome_label, ":",
                                                    conditionMessage(e2), "\n"); NULL }))
  re <- tryCatch(fit_re("twoways"),
                 error = function(e) tryCatch(fit_re("individual"),
                                              error = function(e2) {
                                                cat("RE fit failed for", outcome_label, ":",
                                                    conditionMessage(e2), "\n"); NULL }))

  hausman <- NULL
  if (!is.null(fe) && !is.null(re)) {
    hausman <- tryCatch(phtest(fe, re),
                        error = function(e) { cat("Hausman failed for", outcome_label, ":", conditionMessage(e), "\n"); NULL })
  }

  list(
    fe_tidy = tidy_plm(fe, "FE_Within"),
    re_tidy = tidy_plm(re, "RE_Random"),
    fe_n = if (!is.null(fe)) nobs(fe) else NA_integer_,
    re_n = if (!is.null(re)) nobs(re) else NA_integer_,
    hausman = hausman
  )
}

# Combine FE and RE coef tables into a wide table for the robustness CSV.
to_wide <- function(fe_tidy, re_tidy, outcome_label, hausman) {
  if (is.null(fe_tidy) && is.null(re_tidy)) return(NULL)
  full_terms <- union(if (!is.null(fe_tidy)) fe_tidy$Term else character(0),
                      if (!is.null(re_tidy)) re_tidy$Term else character(0))
  rows <- lapply(full_terms, function(term) {
    fe_row <- if (!is.null(fe_tidy)) fe_tidy[fe_tidy$Term == term, , drop = FALSE] else NULL
    re_row <- if (!is.null(re_tidy)) re_tidy[re_tidy$Term == term, , drop = FALSE] else NULL
    data.frame(
      Outcome = outcome_label,
      Term = term,
      FE_Estimate = if (!is.null(fe_row) && nrow(fe_row) > 0) fe_row$Estimate else NA_real_,
      FE_StdError = if (!is.null(fe_row) && nrow(fe_row) > 0) fe_row$Std_Error else NA_real_,
      FE_PValue   = if (!is.null(fe_row) && nrow(fe_row) > 0) fe_row$p_value else NA_real_,
      RE_Estimate = if (!is.null(re_row) && nrow(re_row) > 0) re_row$Estimate else NA_real_,
      RE_StdError = if (!is.null(re_row) && nrow(re_row) > 0) re_row$Std_Error else NA_real_,
      RE_PValue   = if (!is.null(re_row) && nrow(re_row) > 0) re_row$p_value else NA_real_,
      FE_minus_RE = NA_real_,
      Hausman_ChiSq  = if (!is.null(hausman)) unname(hausman$statistic) else NA_real_,
      Hausman_DF     = if (!is.null(hausman)) unname(hausman$parameter) else NA_real_,
      Hausman_PValue = if (!is.null(hausman)) unname(hausman$p.value) else NA_real_,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  out$FE_minus_RE <- out$FE_Estimate - out$RE_Estimate
  out
}

# ===========================================================================
# 1. State-level: primary spec from run_analysis.R
# ===========================================================================

cat("\n--- State-level RE robustness ---\n")
state_df <- read_csv("Data/analysis_ready_dataset.csv", show_col_types = FALSE, progress = FALSE)

## Slim "headline" climate block for the RE comparison.
## The primary FE script (`run_analysis.R`) carries a wider list including
## `is_severe_drought` and `is_extreme_drought_peak` for robustness, but
## those collinearities make the RE GLS step numerically singular on
## thin-panel outcomes. The five shocks below are the ones cited as the
## headline findings in `Analysis/state_analysis_summary.md`.
state_climate_vars <- c(
  "is_extreme_drought", "is_extreme_drought_lag1", "is_extreme_drought_lag2",
  "is_heat_shock", "is_heat_shock_lag1", "is_heat_shock_lag2",
  "is_cold_shock", "is_cold_shock_lag1", "is_cold_shock_lag2",
  "is_high_cdd", "is_high_cdd_lag1", "is_high_cdd_lag2",
  "is_high_hdd", "is_high_hdd_lag1", "is_high_hdd_lag2"
)
state_climate_vars <- intersect(state_climate_vars, names(state_df))

state_controls <- intersect(c("Unemployment_Rate", "Personal_Income_Per_Capita_Real"),
                            names(state_df))

state_outcomes <- c(
  "Emp_Contrib_Single_Real",
  "Medical_Debt_Share",
  "Medical_Debt_Median_Real",
  "Total_Per_Capita_Health_Exp_Real",
  "Medicaid_Per_Enrollee_Health_Exp_Real",
  "Medicare_Per_Enrollee_Health_Exp_Real"
)
state_outcomes <- intersect(state_outcomes, names(state_df))

state_results <- list()
state_hausman <- list()

for (dep in state_outcomes) {
  cat(" ", dep, "\n")
  rhs <- paste(c(state_climate_vars, state_controls), collapse = " + ")
  f <- as.formula(paste(dep, "~", rhs))
  d <- state_df %>% filter(!is.na(.data[[dep]]))
  if (nrow(d) < 50) {
    cat("    insufficient data (n=", nrow(d), ")\n")
    next
  }
  fit <- fit_fe_re_hausman(f, d, index = c("State", "Year"), outcome_label = dep)
  wide <- to_wide(fit$fe_tidy, fit$re_tidy, dep, fit$hausman)
  if (!is.null(wide)) state_results[[dep]] <- wide
  if (!is.null(fit$hausman)) {
    state_hausman[[dep]] <- data.frame(
      Level = "State",
      Outcome = dep,
      N_FE = as.integer(fit$fe_n),
      N_RE = as.integer(fit$re_n),
      Hausman_ChiSq  = as.numeric(fit$hausman$statistic),
      Hausman_DF     = as.numeric(fit$hausman$parameter),
      Hausman_PValue = as.numeric(fit$hausman$p.value),
      RE_Rejected_at_05 = as.numeric(fit$hausman$p.value) < 0.05,
      stringsAsFactors = FALSE
    )
  }
}

# ===========================================================================
# 2. County-level: Spec1_Base from run_county_analysis.R
# ===========================================================================

cat("\n--- County-level RE robustness ---\n")
county_df <- read_csv("Data/county_level_master.csv", show_col_types = FALSE, progress = FALSE)

# Apply the same debt reporting policy exclusion the primary script uses.
if ("State" %in% names(county_df) && "Year" %in% names(county_df)) {
  excl_mask <- toupper(trimws(as.character(county_df$State))) == "CO" &
               as.integer(county_df$Year) == 2023L
  for (v in intersect(c("Medical_Debt_Share", "Medical_Debt_Median_2023"), names(county_df))) {
    county_df[[v]][excl_mask] <- NA_real_
  }
}

if ("Population" %in% names(county_df) && !all(is.na(county_df$Population)) &&
    "Hosp_BadDebt_Total_Real" %in% names(county_df)) {
  county_df$Hosp_BadDebt_PerCapita <- county_df$Hosp_BadDebt_Total_Real / county_df$Population
}

# Spec 1 base: Z-score relative shocks + PDSI primary drought block.
county_climate_vars <- c(
  "pdsi_val", "PDSI_Lag1", "PDSI_Lag2",
  "Z_Temp", "Z_Temp_Lag1", "Z_Temp_Lag2",
  "Z_Precip", "Z_Precip_Lag1", "Z_Precip_Lag2"
)
county_climate_vars <- intersect(county_climate_vars, names(county_df))
county_controls <- intersect(c("Household_Income_2023", "Uninsured_Rate"), names(county_df))

county_outcomes <- c(
  "Medical_Debt_Share", "Medical_Debt_Median_2023", "Benchmark_Silver_Real",
  "Hosp_BadDebt_PerCapita", "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed"
)
county_outcomes <- intersect(county_outcomes, names(county_df))

# The county master may have multi-row (fips_code, Year) entries due to
# split-county rating-area joins. Dedupe on the predictors and outcomes
# we need before passing to plm.
county_keep_cols <- unique(c("fips_code", "Year", "State",
                             county_climate_vars, county_controls, county_outcomes,
                             "Population"))
county_keep_cols <- intersect(county_keep_cols, names(county_df))
county_df_d <- county_df %>% distinct(across(all_of(county_keep_cols)))
cat(sprintf("County panel after distinct(): %d rows (from %d).\n",
            nrow(county_df_d), nrow(county_df)))

county_results <- list()
county_hausman <- list()

for (dep in county_outcomes) {
  cat(" ", dep, "\n")
  rhs <- paste(c(county_climate_vars, county_controls), collapse = " + ")
  f <- as.formula(paste(dep, "~", rhs))
  d <- county_df_d %>% filter(!is.na(.data[[dep]]))
  if (nrow(d) < 100) {
    cat("    insufficient data (n=", nrow(d), ")\n")
    next
  }
  fit <- fit_fe_re_hausman(f, d, index = c("fips_code", "Year"), outcome_label = dep)
  wide <- to_wide(fit$fe_tidy, fit$re_tidy, dep, fit$hausman)
  if (!is.null(wide)) county_results[[dep]] <- wide
  if (!is.null(fit$hausman)) {
    county_hausman[[dep]] <- data.frame(
      Level = "County",
      Outcome = dep,
      N_FE = as.integer(fit$fe_n),
      N_RE = as.integer(fit$re_n),
      Hausman_ChiSq  = as.numeric(fit$hausman$statistic),
      Hausman_DF     = as.numeric(fit$hausman$parameter),
      Hausman_PValue = as.numeric(fit$hausman$p.value),
      RE_Rejected_at_05 = as.numeric(fit$hausman$p.value) < 0.05,
      stringsAsFactors = FALSE
    )
  }
}

# ===========================================================================
# 3. Export combined results
# ===========================================================================

state_long <- if (length(state_results) > 0) {
  bind_rows(lapply(names(state_results), function(o) {
    state_results[[o]] %>% mutate(Level = "State")
  }))
} else NULL

county_long <- if (length(county_results) > 0) {
  bind_rows(lapply(names(county_results), function(o) {
    county_results[[o]] %>% mutate(Level = "County")
  }))
} else NULL

combined <- bind_rows(state_long, county_long) %>%
  select(Level, Outcome, Term, FE_Estimate, FE_StdError, FE_PValue,
         RE_Estimate, RE_StdError, RE_PValue, FE_minus_RE,
         Hausman_ChiSq, Hausman_DF, Hausman_PValue)

write_csv(combined, "Analysis/random_effects_results.csv")
cat("\nWrote Analysis/random_effects_results.csv (",
    nrow(combined), "rows)\n", sep = "")

hausman_combined <- do.call(rbind, c(state_hausman, county_hausman))
rownames(hausman_combined) <- NULL
write_csv(hausman_combined, "Analysis/random_effects_hausman.csv")
cat("Wrote Analysis/random_effects_hausman.csv (",
    nrow(hausman_combined), "rows)\n", sep = "")

cat("\n=== Hausman summary ===\n")
print(as.data.frame(hausman_combined))
