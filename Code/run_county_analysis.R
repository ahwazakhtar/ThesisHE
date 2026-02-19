# R script to run County-Level Fixed Effects Analysis
# Models:
# 1. Spec A (Adaptation): Z-Scores (Temp/Precip)
# 2. Spec B (Burden): Absolute Extremes (CDD/HDD Quintiles)
# Both specs include County-Level Drought (PDSI/PHDI/PMDI)
# All models run both WITH and WITHOUT AQI shocks.

library(dplyr)
library(fixest) # Primary package for FE with clustering

# 1. Setup ----------------------------------------------------------------
input_path <- "Data/county_level_master.csv"
output_file <- "Analysis/county_analysis_results.txt"
output_csv <- "Analysis/county_regression_coefs.csv"

cat("Loading Data...\n")
df <- read.csv(input_path)

# 2. Pre-Analysis Prep ----------------------------------------------------
# Create Per Capita Hospital Debt if Population exists
if ("Population" %in% names(df) && !all(is.na(df$Population))) {
  df$Hosp_BadDebt_PerCapita <- df$Hosp_BadDebt_Total_Real / df$Population
} else {
  df$Hosp_BadDebt_PerCapita <- NA # Placeholder
}

# Ensure State Factor for Clustering
df$State <- as.factor(df$State)

# 3. Model Specifications -------------------------------------------------

# Common Controls
controls <- c("Household_Income_2023", "Uninsured_Rate", "Unemployment_Rate") 
available_controls <- intersect(controls, names(df))

# Spec 1: Relative Shocks (Climate only)
vars_spec1_base <- c(
  "pdsi_val", "PDSI_Lag1", "PDSI_Lag2",
  "phdi_val", "PHDI_Lag1", "PHDI_Lag2",
  "pmdi_val", "PMDI_Lag1", "PMDI_Lag2",
  "Z_Temp", "Z_Temp_Lag1", "Z_Temp_Lag2",
  "Z_Precip", "Z_Precip_Lag1", "Z_Precip_Lag2"
)

# Spec 1b: Relative Shocks (Climate + AQI)
vars_spec1_aqi <- c(vars_spec1_base, "AQI_Shock", "AQI_Shock_Lag1", "AQI_Shock_Lag2")

# Spec 2: Absolute Burden (High CDD/HDD)
vars_spec2_base <- c(
  "pdsi_val", "PDSI_Lag1", "PDSI_Lag2",
  "phdi_val", "PHDI_Lag1", "PHDI_Lag2",
  "pmdi_val", "PMDI_Lag1", "PMDI_Lag2",
  "High_CDD", "High_CDD_Lag1", "High_CDD_Lag2",
  "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2"
)

# Spec 2b: Absolute Burden (+ AQI)
vars_spec2_aqi <- c(vars_spec2_base, "AQI_Shock", "AQI_Shock_Lag1", "AQI_Shock_Lag2")

# 4. Helper Functions -----------------------------------------------------

# Helper to run feols safely
safe_feols <- function(f, data, cluster, weights = NULL) {
  tryCatch({
    if (!is.null(weights)) {
      if(is.character(weights)) {
        feols(f, data = data, cluster = cluster, weights = data[[weights]])
      } else {
        feols(f, data = data, cluster = cluster, weights = weights)
      }
    } else {
      feols(f, data = data, cluster = cluster)
    }
  }, error = function(e) {
    cat("    Error in model fit:", conditionMessage(e), "\n")
    return(NULL)
  })
}

# 5. Run Analysis Function ------------------------------------------------

run_models <- function(outcome_var, weight_var = NULL) {
  if (!outcome_var %in% names(df)) return(NULL)
  
  cat(paste0("  Running Models for: ", outcome_var, 
             if(!is.null(weight_var)) " (Weighted)" else " (Unweighted)", "...\n"))
  
  # Filter NA for outcome
  df_mod <- df %>% filter(!is.na(!!sym(outcome_var)))
  
  # Prepare formulas
  f1_base <- as.formula(paste(outcome_var, "~", paste(c(vars_spec1_base, available_controls), collapse = "+"), "| fips_code + Year"))
  f1_aqi  <- as.formula(paste(outcome_var, "~", paste(c(vars_spec1_aqi, available_controls), collapse = "+"), "| fips_code + Year"))
  f2_base <- as.formula(paste(outcome_var, "~", paste(c(vars_spec2_base, available_controls), collapse = "+"), "| fips_code + Year"))
  f2_aqi  <- as.formula(paste(outcome_var, "~", paste(c(vars_spec2_aqi, available_controls), collapse = "+"), "| fips_code + Year"))
  
  m1_base <- safe_feols(f1_base, df_mod, "State", weight_var)
  m1_aqi  <- if("AQI_Shock" %in% names(df_mod)) safe_feols(f1_aqi, df_mod, "State", weight_var) else NULL
  m2_base <- safe_feols(f2_base, df_mod, "State", weight_var)
  m2_aqi  <- if("AQI_Shock" %in% names(df_mod)) safe_feols(f2_aqi, df_mod, "State", weight_var) else NULL
  
  return(list(Spec1_Base = m1_base, Spec1_AQI = m1_aqi, Spec2_Base = m2_base, Spec2_AQI = m2_aqi))
}

# 6. Execution Loop -------------------------------------------------------
outcomes <- c("Medical_Debt_Share", "Medical_Debt_Median_2023", "Benchmark_Silver_Real", "Hosp_BadDebt_PerCapita")
results_list <- list()

sink(output_file)
cat("=================================================\n")
cat("COUNTY LEVEL ENVIRONMENTAL IMPACT ANALYSIS RESULTS\n")
cat("=================================================\n")

for (y in outcomes) {
  # Unweighted
  res <- run_models(y)
  if (!is.null(res)) {
    cat(paste0("\nOUTCOME: ", y, " (Unweighted)\n"))
    cat("--- Spec 1 (Climate Shocks) ---\n")
    if(!is.null(res$Spec1_Base)) print(summary(res$Spec1_Base, n = 100))
    cat("\n--- Spec 1b (Climate + AQI Shocks) ---\n")
    if(!is.null(res$Spec1_AQI)) print(summary(res$Spec1_AQI, n = 100))
    cat("\n--- Spec 2 (Absolute Burden) ---\n")
    if(!is.null(res$Spec2_Base)) print(summary(res$Spec2_Base, n = 100))
    cat("\n--- Spec 2b (Absolute Burden + AQI Shocks) ---\n")
    if(!is.null(res$Spec2_AQI)) print(summary(res$Spec2_AQI, n = 100))
    results_list[[paste0(y, "_Unweighted")]] <- res
  }
  
  # Weighted (Only if Population exists)
  if ("Population" %in% names(df) && !all(is.na(df$Population))) {
    res_w <- run_models(y, "Population")
    if (!is.null(res_w)) {
      cat(paste0("\nOUTCOME: ", y, " (Pop-Weighted)\n"))
      cat("--- Spec 1 (Climate Shocks) ---\n")
      if(!is.null(res_w$Spec1_Base)) print(summary(res_w$Spec1_Base, n = 100))
      cat("\n--- Spec 1b (Climate + AQI Shocks) ---\n")
      if(!is.null(res_w$Spec1_AQI)) print(summary(res_w$Spec1_AQI, n = 100))
      cat("\n--- Spec 2 (Absolute Burden) ---\n")
      if(!is.null(res_w$Spec2_Base)) print(summary(res_w$Spec2_Base, n = 100))
      cat("\n--- Spec 2b (Absolute Burden + AQI Shocks) ---\n")
      if(!is.null(res_w$Spec2_AQI)) print(summary(res_w$Spec2_AQI, n = 100))
      results_list[[paste0(y, "_Weighted")]] <- res_w
    }
  }
}

# -------------------------------------------------------------------------
# 7. Robustness: Rating Area Aggregation
# -------------------------------------------------------------------------
cat("\n=================================================\n")
cat("ROBUSTNESS CHECK: RATING AREA LEVEL AGGREGATION\n")
cat("=================================================\n")

if ("rating_area_id" %in% names(df) && "Population" %in% names(df) && !all(is.na(df$Population))) {
  
  cat("Aggregating to Rating Area Level (Population Weighted)...\n")
  
  # Aggregate numeric cols by Rating Area + Year
  cols_to_agg <- c(outcomes, available_controls,
                   "Z_Temp", "Z_Precip", "High_CDD", "High_HDD",
                   "pdsi_val", "phdi_val", "pmdi_val")
  if("AQI_Shock" %in% names(df)) cols_to_agg <- c(cols_to_agg, "AQI_Shock")

  df_ra <- df %>%
    filter(!is.na(rating_area_id), !is.na(Population)) %>%
    group_by(rating_area_id, Year, State) %>%
    summarize(
      # Weight these by Population
      across(all_of(cols_to_agg),
             ~ weighted.mean(., w = Population, na.rm = TRUE)),

      # Sum Population
      Population = sum(Population, na.rm = TRUE),

      .groups = "drop"
    ) %>%
    # Re-calculate Lags
    group_by(rating_area_id) %>%
    arrange(Year) %>%
    mutate(
      Z_Temp_Lag1 = lag(Z_Temp, 1), Z_Temp_Lag2 = lag(Z_Temp, 2),
      Z_Precip_Lag1 = lag(Z_Precip, 1), Z_Precip_Lag2 = lag(Z_Precip, 2),
      High_CDD_Lag1 = lag(High_CDD, 1), High_CDD_Lag2 = lag(High_CDD, 2),
      High_HDD_Lag1 = lag(High_HDD, 1), High_HDD_Lag2 = lag(High_HDD, 2),
      PDSI_Lag1 = lag(pdsi_val, 1), PDSI_Lag2 = lag(pdsi_val, 2),
      PHDI_Lag1 = lag(phdi_val, 1), PHDI_Lag2 = lag(phdi_val, 2),
      PMDI_Lag1 = lag(pmdi_val, 1), PMDI_Lag2 = lag(pmdi_val, 2)
    )
  
  if("AQI_Shock" %in% names(df_ra)) {
    df_ra <- df_ra %>%
      group_by(rating_area_id) %>%
      mutate(AQI_Shock_Lag1 = lag(AQI_Shock, 1), AQI_Shock_Lag2 = lag(AQI_Shock, 2)) %>%
      ungroup()
  } else {
    df_ra <- df_ra %>% ungroup()
  }

  # Run Models on RA Data
  run_models_ra <- function(outcome_var) {
    if (!outcome_var %in% names(df_ra)) return(NULL)
    
    cat(paste0("  Running RA Models for: ", outcome_var, "...\n"))
    df_mod <- df_ra %>% filter(!is.na(!!sym(outcome_var)))
    
    if (nrow(df_mod) == 0) {
      cat("    Skipping: No observations after NA filtering.\n")
      return(NULL)
    }

    f1_base <- as.formula(paste(outcome_var, "~", paste(c(vars_spec1_base, available_controls), collapse = "+"), "| rating_area_id + Year"))
    f1_aqi  <- as.formula(paste(outcome_var, "~", paste(c(vars_spec1_aqi, available_controls), collapse = "+"), "| rating_area_id + Year"))
    f2_base <- as.formula(paste(outcome_var, "~", paste(c(vars_spec2_base, available_controls), collapse = "+"), "| rating_area_id + Year"))
    f2_aqi  <- as.formula(paste(outcome_var, "~", paste(c(vars_spec2_aqi, available_controls), collapse = "+"), "| rating_area_id + Year"))
    
    m1_base <- safe_feols(f1_base, df_mod, "State", "Population")
    m1_aqi  <- if("AQI_Shock" %in% names(df_mod)) safe_feols(f1_aqi, df_mod, "State", "Population") else NULL
    m2_base <- safe_feols(f2_base, df_mod, "State", "Population")
    m2_aqi  <- if("AQI_Shock" %in% names(df_mod)) safe_feols(f2_aqi, df_mod, "State", "Population") else NULL
    
    return(list(Spec1_Base = m1_base, Spec1_AQI = m1_aqi, Spec2_Base = m2_base, Spec2_AQI = m2_aqi))
  }

  for (y in outcomes) {
    res_ra <- run_models_ra(y)
    if (!is.null(res_ra)) {
      cat(paste0("\nOUTCOME: ", y, " (Rating Area Level)\n"))
      if(!is.null(res_ra$Spec1_Base)) print(summary(res_ra$Spec1_Base, n = 100))
      if(!is.null(res_ra$Spec1_AQI)) print(summary(res_ra$Spec1_AQI, n = 100))
      if(!is.null(res_ra$Spec2_Base)) print(summary(res_ra$Spec2_Base, n = 100))
      if(!is.null(res_ra$Spec2_AQI)) print(summary(res_ra$Spec2_AQI, n = 100))
      results_list[[paste0(y, "_RA_Robustness")]] <- res_ra
    }
  }

} else {
  cat("Skipping Robustness: Missing 'rating_area_id' or 'Population' column.\n")
}

sink()

# 8. Export Coefficients Table --------------------------------------------
# Using etable to export to CSV
if (length(results_list) > 0) {
  # Collect all valid models
  all_models <- list()
  for (res in results_list) {
    if (!is.null(res$Spec1_Base)) all_models[[length(all_models)+1]] <- res$Spec1_Base
    if (!is.null(res$Spec1_AQI))  all_models[[length(all_models)+1]] <- res$Spec1_AQI
    if (!is.null(res$Spec2_Base)) all_models[[length(all_models)+1]] <- res$Spec2_Base
    if (!is.null(res$Spec2_AQI))  all_models[[length(all_models)+1]] <- res$Spec2_AQI
  }
  
  if (length(all_models) > 0) {
    etable(all_models, file = output_csv, replace = TRUE)
    cat(paste0("\nResults exported to: ", output_file, " and ", output_csv, "\n"))
  } else {
    cat("\nNo valid models were estimated.\n")
  }
} else {
  cat("No models converged or variables missing.\n")
}