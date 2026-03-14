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
# Thresholds use annual mean PDSI levels:
#   < -4 (Extreme), -4 to -3 (Severe), > 3 (Extremely Wet).
# Preferred input is `pdsi_mean`. For legacy files with only `pdsi_sum`,
# convert to an annual level by dividing by observed months.
if (!"pdsi_mean" %in% names(df) && !"pdsi_sum" %in% names(df)) {
  stop("Missing both `pdsi_mean` and legacy `pdsi_sum` in state master.")
}

df$pdsi_mean_input <- if ("pdsi_mean" %in% names(df)) as.numeric(df$pdsi_mean) else NA_real_
df$pdsi_sum_input  <- if ("pdsi_sum"  %in% names(df)) as.numeric(df$pdsi_sum)  else NA_real_

df <- df %>%
  mutate(
    pdsi_obs_months = ifelse(
      "pdsi_missing_months" %in% names(.),
      pmax(12 - as.numeric(pdsi_missing_months), 1),
      12
    ),
    pdsi_level = coalesce(pdsi_mean_input, pdsi_sum_input / pdsi_obs_months),
    is_extreme_drought = ifelse(!is.na(pdsi_level) & pdsi_level < -4, 1, 0),
    is_severe_drought  = ifelse(!is.na(pdsi_level) & pdsi_level >= -4 & pdsi_level < -3, 1, 0),
    is_extremely_wet   = ifelse(!is.na(pdsi_level) & pdsi_level > 3, 1, 0),
    # Annual minimum PDSI: worst drought month reached within the year.
    # Captures transient drought peaks that the annual mean smooths over.
    # Threshold mirrors PDSI extreme drought classification (< -4).
    pdsi_min_level = if ("pdsi_min" %in% names(.)) as.numeric(pdsi_min) else NA_real_,
    is_extreme_drought_peak = ifelse(!is.na(pdsi_min_level) & pdsi_min_level < -4, 1, 0)
  ) %>%
  select(-pdsi_obs_months, -pdsi_mean_input, -pdsi_sum_input)

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

# C. Energy Demand Shocks (CDD/HDD National 80th-Percentile Threshold)
# Thresholds are computed from the 1990-2000 baseline period across all states,
# matching the county-level pipeline design. Using a fixed national threshold
# (rather than within-state quintiles) ensures High_CDD/High_HDD capture
# objectively extreme years, not merely above-average years for a state that
# is already hot/cold. Anchoring to 1990-2000 prevents look-ahead bias.
baseline_cdd_hdd <- df %>% filter(Year >= 1990 & Year <= 2000)
cdd_p80_national <- quantile(baseline_cdd_hdd$cdd_sum, 0.80, na.rm = TRUE)
hdd_p80_national <- quantile(baseline_cdd_hdd$hdd_sum, 0.80, na.rm = TRUE)
cat(sprintf("  CDD national p80 (1990-2000): %.1f | HDD national p80: %.1f\n",
            cdd_p80_national, hdd_p80_national))

df <- df %>%
  mutate(
    is_high_cdd = ifelse(!is.na(cdd_sum) & cdd_sum >= cdd_p80_national, 1, 0),
    is_high_hdd = ifelse(!is.na(hdd_sum) & hdd_sum >= hdd_p80_national, 1, 0)
  )

# D. Air Quality — AQI variables from process_aqi_data.R enter regressions
# directly as continuous measures (population-weighted median, max, pollutant
# day percentages). No binary transformation applied here.

# 3. Distributed Lag Generation -------------------------------------------
cat("Generating Distributed Lags (0, 1, 2 years)...\n")

vars_to_lag <- c("is_extreme_drought", "is_severe_drought",
                 "is_heat_shock", "is_cold_shock",
                 "is_high_cdd", "is_high_hdd", "pdsi_level", "temp_z",
                 "pdsi_min_level", "is_extreme_drought_peak")

# Add state AQI variables if present (produced by process_aqi_data.R)
aqi_state_vars <- c("AQI_Median_Wtd", "AQI_Median_EW", "AQI_Max_State",
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
