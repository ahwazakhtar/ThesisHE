# R script for State-Level Regression Analysis
# Implements Fixed-Effects Models with Distributed Lags and Clustering

# 1. Setup ----------------------------------------------------------------
library(fixest)

input_path  <- "Data/analysis_ready_dataset.csv"
output_path <- "Analysis/state/regression_results_summary.csv"
vif_output_path <- "Analysis/state/vif_diagnostics.txt"

# Create Analysis directory if not exists
dir.create("Analysis", showWarnings = FALSE)

cat("Loading Analysis Dataset...\n")
df <- read.csv(input_path, stringsAsFactors = FALSE)

# 2. Define Model Specifications ------------------------------------------

# Climate & Environmental Predictors (Distributed Lags 0, 1, 2)
# We use the lags generated in pre-processing
climate_vars <- c(
  "is_extreme_drought", "is_extreme_drought_lag1", "is_extreme_drought_lag2",
  "is_severe_drought", "is_severe_drought_lag1", "is_severe_drought_lag2",
  # Peak drought: binary indicator based on annual minimum PDSI (worst month < -4).
  # Complements the mean-based indicator by capturing transient within-year peaks.
  "is_extreme_drought_peak", "is_extreme_drought_peak_lag1", "is_extreme_drought_peak_lag2",
  "is_heat_shock", "is_heat_shock_lag1", "is_heat_shock_lag2",
  "is_cold_shock", "is_cold_shock_lag1", "is_cold_shock_lag2",
  "is_high_cdd", "is_high_cdd_lag1", "is_high_cdd_lag2",
  "is_high_hdd", "is_high_hdd_lag1", "is_high_hdd_lag2"
)

# Add state AQI variables if present (continuous measures from process_aqi_data.R)
aqi_base <- c("AQI_Median_Wtd", "AQI_Max_State",
              "Pct_PM25_State", "Pct_PM10_State", "Pct_Ozone_State",
              "Pct_CO_State", "Pct_NO2_State", "Pct_Unhealthy_State")
aqi_vars <- unlist(lapply(intersect(aqi_base, names(df)), function(v)
  c(v, paste0(v, "_lag1"), paste0(v, "_lag2"))))
aqi_vars <- aqi_vars[aqi_vars %in% names(df)]
if (length(aqi_vars) > 0) climate_vars <- c(climate_vars, aqi_vars)

# Controls
controls <- c("Unemployment_Rate", "Personal_Income_Per_Capita_Real")

# Construct Formula String
rhs_formula <- paste(c(climate_vars, controls), collapse = " + ")

# Dependent Variables
deps <- c(
  "Emp_Contrib_Single_Real",        # M1: Premiums
  "Medical_Debt_Share",             # M2: Debt Prevalence
  "Medical_Debt_Median_Real",       # M2b: Debt Severity
  "Total_Per_Capita_Health_Exp_Real", # M3: Systemic Cost
  "Medicaid_Per_Enrollee_Health_Exp_Real", # M4: Public Safety Net
  "Medicare_Per_Enrollee_Health_Exp_Real"  # M5: Elderly/Disabled
)

# 3. Helper Functions -----------------------------------------------------

# VIF via auxiliary OLS on within-transformed predictor matrix.
# Note: model.matrix() on a feols object returns the demeaned matrix with NO
# intercept column — do NOT use [,-1] or you drop the first predictor.
calculate_vif <- function(model) {
  if (is.null(model) || any(is.na(coef(model)))) return(NULL)
  tryCatch({
    X <- model.matrix(model)
    if (is.null(X) || ncol(X) < 2) return(NULL)
    vifs <- setNames(numeric(ncol(X)), colnames(X))
    for (i in seq_len(ncol(X))) {
      r2 <- summary(lm(X[, i] ~ X[, -i]))$r.squared
      vifs[i] <- if (r2 < 1) 1 / (1 - r2) else Inf
    }
    vifs
  }, error = function(e) NULL)
}

# 4. Execution Loop -------------------------------------------------------
results_list <- list()

# Open VIF log
sink(vif_output_path)
cat("--- Multicollinearity Diagnostics (VIF) ---\n\n")

for (dep in deps) {
  cat(paste0("Running Model for: ", dep, "...\n"))
  
  # Filter Data (Complete Cases for specific regression)
  # plm handles NAs, but good to be explicit or check sample size
  model_data <- df[!is.na(df[[dep]]), ]
  
  # Check if enough data
  if (nrow(model_data) < 50) {
    cat(paste0("  Skipping ", dep, " (Insufficient Data: n=", nrow(model_data), ")\n"))
    next
  }
  
  f_fe <- as.formula(paste(dep, "~", rhs_formula, "| State + Year"))

  # A. Two-way FE with state-clustered SEs (fixest)
  fem <- feols(f_fe, data = model_data, cluster = ~State)

  # B. VIF on within-transformed predictor matrix from the FE model.
  # Uses feols model.matrix() which is already demeaned — no intercept to strip.
  vifs <- calculate_vif(fem)

  cat(paste0("\nDependent Variable: ", dep, "\n"))
  if (!is.null(vifs)) print(round(vifs, 2)) else cat("VIF: could not compute\n")
  cat("\n---------------------------------------\n")
  
  # D. Extract Results
  res_mat <- as.data.frame(coeftable(fem))
  res_mat$Term <- rownames(res_mat)
  res_mat$Dependent_Variable <- dep
  res_mat$Observations <- nobs(fem)
  res_mat$R2_Within <- r2(fem, "wr2")

  res_mat <- res_mat[, c("Dependent_Variable", "Term", "Estimate", "Std. Error", "t value", "Pr(>|t|)", "Observations", "R2_Within")]
  
  results_list[[dep]] <- list(coef_df = res_mat, model = fem)
}

sink() # Close VIF log

# 5. Export Results -------------------------------------------------------
if (length(results_list) > 0) {
  final_results <- do.call(rbind, lapply(results_list, function(x) x$coef_df))
  rownames(final_results) <- NULL
  
  # Clean column names
  colnames(final_results) <- c("Dependent_Var", "Predictor", "Estimate", "Std_Error", "t_value", "p_value", "N_Obs", "R2_Within")
  
  write.csv(final_results, output_path, row.names = FALSE)
  cat(paste0("\nSuccess! Regression results saved to: ", output_path, "\n"))
  cat(paste0("VIF Diagnostics saved to: ", vif_output_path, "\n"))
} else {
  cat("\nWarning: No models ran successfully.\n")
}

# 6. Markdown Report -------------------------------------------------------
md_output_path <- "Analysis/state/state_regression_results.md"

model_to_md <- function(model, spec_name, outcome, cluster = "State", note = "") {
  if (is.null(model)) return(paste0("*Model not estimated.*\n\n"))
  ct <- as.data.frame(coeftable(model))
  ct$Term <- rownames(ct)
  n_obs   <- tryCatch(nobs(model), error = function(e) NA)
  r2_w    <- tryCatch(round(r2(model, "wr2"), 4), error = function(e) NA)

  lines <- c(
    paste0("#### ", spec_name),
    if (nzchar(note)) paste0("*", note, "*") else NULL,
    paste0("**N =** ", format(n_obs, big.mark = ","),
           " | **Within-R² =** ", r2_w,
           " | **Cluster =** ", cluster),
    "",
    "| Term | Estimate | Std. Error | t value | p value |",
    "|------|----------|------------|---------|---------|"
  )

  for (i in seq_len(nrow(ct))) {
    sig <- dplyr::case_when(
      ct[i, "Pr(>|t|)"] < 0.01  ~ "***",
      ct[i, "Pr(>|t|)"] < 0.05  ~ "**",
      ct[i, "Pr(>|t|)"] < 0.10  ~ "*",
      TRUE                        ~ ""
    )
    lines <- c(lines, sprintf("| %s | %.4f%s | %.4f | %.3f | %.4f |",
      ct[i, "Term"],
      ct[i, "Estimate"], sig,
      ct[i, "Std. Error"],
      ct[i, "t value"],
      ct[i, "Pr(>|t|)"]))
  }
  c(lines, "")
}

md_lines <- c(
  "# State-Level Regression Results",
  paste0("**Generated:** ", Sys.time()),
  paste0("**Input:** ", input_path),
  "**Model:** Two-way FE (State + Year), cluster = State, `fixest::feols`",
  "",
  "Significance: \\*p<0.10, \\*\\*p<0.05, \\*\\*\\*p<0.01",
  ""
)

for (dep in deps) {
  if (!dep %in% names(results_list)) next
  md_lines <- c(md_lines, paste0("---\n\n## Outcome: `", dep, "`\n"))
  md_lines <- c(md_lines, model_to_md(results_list[[dep]]$model, "Primary FE (State + Year)", dep))
}

writeLines(md_lines, md_output_path)
cat(paste0("\nMarkdown report saved to: ", md_output_path, "\n"))

# 7. Humidity Sensitivity (Committee Feedback April 2026, Environmental #1) -
# PRISM `tdmean` (mean dew point, deg F) covers 2009-2025 and CONUS only (no
# AK/HI), so adding it to the PRIMARY spec would change the estimation sample.
# To isolate the effect of CONTROLLING for humidity (as opposed to changing the
# sample), we re-fit on the IDENTICAL humidity-available subsample:
#   (a) a baseline with NO humidity, and
#   (b) a humidity-augmented spec adding tdmean_F + lag1 + lag2.
# We then compare the two headline coefficients the committee cares about:
#   Extreme Drought, 2-year lag  (is_extreme_drought_lag2)
#   Cold Shock, 1-year lag       (is_cold_shock_lag1)
# The full-sample primary models above remain authoritative; this block is the
# robustness check, written to Analysis/state/humidity_sensitivity.csv.
hum_terms      <- c("tdmean_F", "tdmean_F_lag1", "tdmean_F_lag2")
headline_terms <- c("is_extreme_drought_lag2", "is_cold_shock_lag1")

humidity_rows <- list()
if (all(hum_terms %in% names(df))) {
  rhs_hum <- paste(c(climate_vars, controls, hum_terms), collapse = " + ")
  get_cell <- function(ct, term, col) {
    v <- ct[ct$Term == term, col]
    if (length(v) == 0) NA_real_ else as.numeric(v)
  }
  for (dep in deps) {
    md <- df[!is.na(df[[dep]]) & stats::complete.cases(df[, hum_terms]), ]
    if (nrow(md) < 50) {
      cat(paste0("  Humidity block: skipping ", dep, " (n=", nrow(md), ")\n"))
      next
    }
    f_base <- as.formula(paste(dep, "~", rhs_formula, "| State + Year"))
    f_hum  <- as.formula(paste(dep, "~", rhs_hum,     "| State + Year"))
    m_base <- tryCatch(feols(f_base, data = md, cluster = ~State), error = function(e) NULL)
    m_hum  <- tryCatch(feols(f_hum,  data = md, cluster = ~State), error = function(e) NULL)
    if (is.null(m_base) || is.null(m_hum)) next

    ct_b <- as.data.frame(coeftable(m_base)); ct_b$Term <- rownames(ct_b)
    ct_h <- as.data.frame(coeftable(m_hum));  ct_h$Term <- rownames(ct_h)

    for (term in c(headline_terms, hum_terms)) {
      humidity_rows[[paste(dep, term)]] <- data.frame(
        Outcome          = dep,
        Term             = term,
        N                = nobs(m_hum),
        Est_NoHumidity   = get_cell(ct_b, term, "Estimate"),
        SE_NoHumidity    = get_cell(ct_b, term, "Std. Error"),
        p_NoHumidity     = get_cell(ct_b, term, "Pr(>|t|)"),
        Est_WithHumidity = get_cell(ct_h, term, "Estimate"),
        SE_WithHumidity  = get_cell(ct_h, term, "Std. Error"),
        p_WithHumidity   = get_cell(ct_h, term, "Pr(>|t|)"),
        stringsAsFactors = FALSE
      )
    }
  }
}

if (length(humidity_rows) > 0) {
  hum_df <- do.call(rbind, humidity_rows); rownames(hum_df) <- NULL
  write.csv(hum_df, "Analysis/state/humidity_sensitivity.csv", row.names = FALSE)
  cat("Humidity sensitivity saved to: Analysis/state/humidity_sensitivity.csv\n")
} else {
  cat("Humidity sensitivity skipped (tdmean_F lags unavailable).\n")
}