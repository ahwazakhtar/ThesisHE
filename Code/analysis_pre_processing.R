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
# Baseline mean and SD are estimated from 1990-2000 only to avoid look-ahead
# bias and anchor shocks to a stable pre-study climatology. process_state_climate.R
# starts at 1990 to make this window available.
baseline_start_year <- 1990
baseline_end_year   <- 2000

df <- df %>%
  group_by(State) %>%
  mutate(
    temp_hist_mean = mean(temp_mean[Year >= baseline_start_year & Year <= baseline_end_year], na.rm = TRUE),
    temp_hist_sd   = sd(temp_mean[Year >= baseline_start_year & Year <= baseline_end_year],   na.rm = TRUE),
    temp_z = if_else(
      !is.na(temp_hist_sd) & temp_hist_sd > 0,
      (temp_mean - temp_hist_mean) / temp_hist_sd,
      NA_real_
    ),

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

# D. Air Quality — AQI variables from process_aqi_data.R enter regressions
# directly as continuous measures (population-weighted median, max, pollutant
# day percentages). No binary transformation applied here.

# 3. Distributed Lag Generation -------------------------------------------
cat("Generating Distributed Lags (0, 1, 2 years)...\n")

vars_to_lag <- c("is_extreme_drought", "is_severe_drought",
                 "is_heat_shock", "is_cold_shock",
                 "is_high_cdd", "pdsi_sum", "temp_z")

# Add state AQI variables if present (produced by process_aqi_data.R)
aqi_state_vars <- c("AQI_Median_Wtd", "AQI_Max_State",
                    "Pct_PM25_State", "Pct_PM10_State", "Pct_Ozone_State",
                    "Pct_CO_State", "Pct_NO2_State", "Pct_Unhealthy_State")
vars_to_lag <- c(vars_to_lag, intersect(aqi_state_vars, names(df)))

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