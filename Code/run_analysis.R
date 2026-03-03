# R script for State-Level Regression Analysis
# Implements Fixed-Effects Models with Distributed Lags and Clustering

# 1. Setup ----------------------------------------------------------------
library(fixest)

input_path  <- "Data/analysis_ready_dataset.csv"
output_path <- "Analysis/regression_results_summary.csv"
vif_output_path <- "Analysis/vif_diagnostics.txt"

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
  "is_high_cdd", "is_high_cdd_lag1", "is_high_cdd_lag2"
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
  
  results_list[[dep]] <- res_mat
}

sink() # Close VIF log

# 5. Export Results -------------------------------------------------------
if (length(results_list) > 0) {
  final_results <- do.call(rbind, results_list)
  rownames(final_results) <- NULL
  
  # Clean column names
  colnames(final_results) <- c("Dependent_Var", "Predictor", "Estimate", "Std_Error", "t_value", "p_value", "N_Obs", "R2_Within")
  
  write.csv(final_results, output_path, row.names = FALSE)
  cat(paste0("\nSuccess! Regression results saved to: ", output_path, "\n"))
  cat(paste0("VIF Diagnostics saved to: ", vif_output_path, "\n"))
} else {
  cat("\nWarning: No models ran successfully.\n")
}