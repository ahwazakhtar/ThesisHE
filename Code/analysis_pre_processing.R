# R script for Feature Engineering (State-Level Analysis)
# Implements the Binning and Lag Generation strategy defined in state_analysis_plan.md

# 1. Setup ----------------------------------------------------------------
library(dplyr)
library(tidyr)
library(zoo) # For rolling functions if needed, though we use standard lags

input_path  <- "Data/state_level_analysis_master.csv"
output_path <- "Data/analysis_ready_dataset.csv"

cat("Loading Master Dataset...
")
df <- read.csv(input_path, stringsAsFactors = FALSE)

# 2. Climate Shock Generation (Binning) -----------------------------------
cat("Generating Climate Shocks...
")

# A. Drought Intensity (PDSI)
# Thresholds: < -4 (Extreme), -4 to -3 (Severe), > 3 (Wet)
df <- df %>%
  mutate(
    is_extreme_drought = ifelse(!is.na(pdsi_sum) & pdsi_sum < -4, 1, 0),
    is_severe_drought  = ifelse(!is.na(pdsi_sum) & pdsi_sum >= -4 & pdsi_sum < -3, 1, 0),
    is_extremely_wet   = ifelse(!is.na(pdsi_sum) & pdsi_sum > 3, 1, 0)
  )

# B. Temperature Shocks (State-Specific Z-Scores)
# We need to calculate the Mean and SD for each state to establish the "norm"
df <- df %>%
  group_by(State) %>%
  mutate(
    temp_mean = mean(temp_sum, na.rm = TRUE),
    temp_sd   = sd(temp_sum, na.rm = TRUE),
    temp_z    = (temp_sum - temp_mean) / temp_sd,
    
    # Define Shocks: Z > 1.5 (Heat) or Z < -1.5 (Cold)
    is_heat_shock = ifelse(!is.na(temp_z) & temp_z > 1.5, 1, 0),
    is_cold_shock = ifelse(!is.na(temp_z) & temp_z < -1.5, 1, 0)
  ) %>%
  ungroup()

# C. Energy Demand Shocks (CDD Top Quintile)
# We determine the 80th percentile of CDD *within* each state
df <- df %>%
  group_by(State) %>%
  mutate(
    cdd_80th = quantile(cdd_sum, probs = 0.80, na.rm = TRUE),
    is_high_cdd = ifelse(!is.na(cdd_sum) & cdd_sum >= cdd_80th, 1, 0)
  ) %>%
  ungroup()

# D. Air Quality Shocks (AQI Top Quintile)
# We determine the 80th percentile of AQI *within* each state
df <- df %>%
  group_by(State) %>%
  mutate(
    aqi_80th = if("aqi_mean" %in% names(.)) quantile(aqi_mean, probs = 0.80, na.rm = TRUE) else NA,
    is_high_aqi = if("aqi_mean" %in% names(.)) ifelse(!is.na(aqi_mean) & aqi_mean >= aqi_80th, 1, 0) else 0
  ) %>%
  ungroup()

# 3. Distributed Lag Generation -------------------------------------------
cat("Generating Distributed Lags (0, 1, 2 years)...
")

# Helper function to create lags for a list of variables
vars_to_lag <- c("is_extreme_drought", "is_severe_drought", 
                 "is_heat_shock", "is_cold_shock", 
                 "is_high_cdd", "is_high_aqi", "pdsi_sum", "temp_z")

if("aqi_mean" %in% names(df)) vars_to_lag <- c(vars_to_lag, "aqi_mean")

# We must group by State to ensure lags don't bleed across states
df_lags <- df %>%
  arrange(State, Year) %>%
  group_by(State) %>%
  mutate(across(all_of(vars_to_lag), 
                list(lag1 = ~lag(., 1), 
                     lag2 = ~lag(., 2)),
                .names = "{.col}_{.fn}")) %>%
  ungroup()

# 4. Final Cleaning & Export ----------------------------------------------
# Filter out years that might have lost too much data due to lagging (optional, but good practice)
# For now, we keep all rows but note that 1996/1997 will have NAs for Lags.

cat("Saving Analysis-Ready Dataset...
")
write.csv(df_lags, output_path, row.names = FALSE)

cat("
Success! File saved to:", output_path, "
")
cat("Dimensions:", nrow(df_lags), "x", ncol(df_lags), "
")
cat("New Shock Variables Created:
")
print(colnames(df_lags)[grep("is_|lag", colnames(df_lags))])