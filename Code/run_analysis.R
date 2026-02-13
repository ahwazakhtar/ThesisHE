# R script for State-Level Regression Analysis
# Implements Fixed-Effects Models with Distributed Lags and Clustering

# 1. Setup ----------------------------------------------------------------
library(plm)
library(lmtest)
library(sandwich)

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
  "is_heat_shock", "is_heat_shock_lag1", "is_heat_shock_lag2",
  "is_cold_shock", "is_cold_shock_lag1", "is_cold_shock_lag2",
  "is_high_cdd", "is_high_cdd_lag1", "is_high_cdd_lag2"
)

# Add AQI if present
if ("is_high_aqi" %in% names(df)) {
  climate_vars <- c(climate_vars, "is_high_aqi", "is_high_aqi_lag1", "is_high_aqi_lag2")
}

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

# Custom VIF function (since 'car' package might not be available)
calculate_vif <- function(model) {
  if(any(is.na(coef(model)))) return(NA) # Handle singular fits
  v <- tryCatch({
    # Approximation using R-squared of aux regressions
    X <- model.matrix(model)[,-1] # Remove Intercept
    if(ncol(X) < 2) return(NA)
    vifs <- numeric(ncol(X))
    names(vifs) <- colnames(X)
    for(i in 1:ncol(X)) {
      y_aux <- X[,i]
      x_aux <- X[,-i]
      r2 <- summary(lm(y_aux ~ x_aux))$r.squared
      vifs[i] <- 1 / (1 - r2)
    }
    return(vifs)
  }, error = function(e) { return(NA) })
  return(v)
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
  
  # Formula
  f <- as.formula(paste(dep, "~", rhs_formula))
  
  # A. Run Fixed Effects Model (Two-Ways: State + Year)
  # Note: index arg sets the panel structure
  fem <- plm(f, data = model_data, index = c("State", "Year"), 
             model = "within", effect = "twoways")
  
  # B. Cluster Standard Errors (State Level)
  # vcovHC type="HC1" is standard for panel robust SEs
  # cluster="group" clusters by State (the first index)
  cl_se <- vcovHC(fem, type = "HC1", cluster = "group")
  sum_fem <- coeftest(fem, vcov = cl_se)
  
  # C. VIF Check (using Pooled OLS approximation)
  # VIF is a property of X, so model type matters less, but FE transforms X.
  # We run a dummy pooled OLS to check raw collinearity first.
  vif_model <- lm(f, data = model_data)
  vifs <- calculate_vif(vif_model)
  
  cat(paste0("\nDependent Variable: ", dep, "\n"))
  print(vifs)
  cat("\n---------------------------------------\n")
  
  # D. Extract Results
  # coeftest returns a matrix-like object
  res_mat <- as.data.frame(unclass(sum_fem))
  res_mat$Term <- rownames(res_mat)
  res_mat$Dependent_Variable <- dep
  res_mat$Observations <- nobs(fem)
  res_mat$R2_Within <- summary(fem)$r.squared["rsq"]
  
  # Reorder columns
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