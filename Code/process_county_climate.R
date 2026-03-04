# R script to process NOAA County Climate Data efficiently
library(dplyr)
library(tidyr)
library(readr)

if (!exists("%||%")) {
  `%||%` <- function(x, y) {
    if (is.null(x)) return(y)
    if (length(x) == 1 && is.atomic(x) && is.na(x)) return(y)
    x
  }
}

# This function encapsulates the data processing logic, making it testable.
process_noaa_data <- function(file_list, output_path) {
  
  # Constants & Mappings
  noaa_state_codes <- c(
    "01" = "Alabama", "02" = "Arizona", "03" = "Arkansas", "04" = "California",
    "05" = "Colorado", "06" = "Connecticut", "07" = "Delaware", "08" = "Florida",
    "09" = "Georgia", "10" = "Idaho", "11" = "Illinois", "12" = "Indiana",
    "13" = "Iowa", "14" = "Kansas", "15" = "Kentucky", "16" = "Louisiana",
    "17" = "Maine", "18" = "Maryland", "19" = "Massachusetts", "20" = "Michigan",
    "21" = "Minnesota", "22" = "Mississippi", "23" = "Missouri", "24" = "Montana",
    "25" = "Nebraska", "26" = "Nevada", "27" = "New Hampshire", "28" = "New Jersey",
    "29" = "New Mexico", "30" = "New York", "31" = "North Carolina", "32" = "North Dakota",
    "33" = "Ohio", "34" = "Oklahoma", "35" = "Oregon", "36" = "Pennsylvania",
    "37" = "Rhode Island", "38" = "South Carolina", "39" = "South Dakota", "40" = "Tennessee",
    "41" = "Texas", "42" = "Utah", "43" = "Vermont", "44" = "Virginia",
    "45" = "Washington", "46" = "West Virginia", "47" = "Wisconsin", "48" = "Wyoming",
    "50" = "Alaska", "51" = "Hawaii"
    # DC (FIPS 11) does not appear in NOAA county-level climate divisional files.
    # Code "11" in these files is Illinois. DC county climate data is absent.
  )
  
  state_fips_map <- c(
    "Alabama" = "01", "Alaska" = "02", "Arizona" = "04", "Arkansas" = "05", "California" = "06",
    "Colorado" = "08", "Connecticut" = "09", "Delaware" = "10", "District of Columbia" = "11",
    "Florida" = "12", "Georgia" = "13", "Hawaii" = "15", "Idaho" = "16", "Illinois" = "17",
    "Indiana" = "18", "Iowa" = "19", "Kansas" = "20", "Kentucky" = "21", "Louisiana" = "22",
    "Maine" = "23", "Maryland" = "24", "Massachusetts" = "25", "Michigan" = "26", "Minnesota" = "27",
    "Mississippi" = "28", "Missouri" = "29", "Montana" = "30", "Nebraska" = "31", "Nevada" = "32",
    "New Hampshire" = "33", "New Jersey" = "34", "New Mexico" = "35", "New York" = "36",
    "North Carolina" = "37", "North Dakota" = "38", "Ohio" = "39", "Oklahoma" = "40", "Oregon" = "41",
    "Pennsylvania" = "42", "Rhode Island" = "44", "South Carolina" = "45", "South Dakota" = "46",
    "Tennessee" = "47", "Texas" = "48", "Utah" = "49", "Vermont" = "50", "Virginia" = "51",
    "Washington" = "53", "West Virginia" = "54", "Wisconsin" = "55", "Wyoming" = "56"
  )
  
  cat("Processing County Climate Data...
")
  
  processed_list <- list()
  
  for (var in names(file_list)) {
    fpath <- file_list[[var]]
    cat(paste0("  Reading ", var, " (", basename(fpath), ")...
"))
    
    df_raw <- read_fwf(fpath, 
                       fwf_widths(c(2, 3, 2, 4, rep(7, 12)), 
                                  col_names = c("NOAA_State", "NOAA_Cnty", "Elem", "Year", month.abb)),
                       col_types = "ccciidddddddddddd",
                       show_col_types = FALSE)
    
    # Load from 1990 to include the 1990-2000 pre-study baseline for Z-score anchoring.
    df_raw <- df_raw %>% filter(Year >= 1990)
    
    df_raw$StateName <- noaa_state_codes[df_raw$NOAA_State]
    df_raw$StateFIPS <- state_fips_map[df_raw$StateName]
    df_raw <- df_raw %>% filter(!is.na(StateFIPS))
    df_raw$fips_code <- paste0(df_raw$StateFIPS, sprintf("%03d", as.integer(df_raw$NOAA_Cnty)))
    
    long_df <- df_raw %>%
      select(fips_code, Year, all_of(month.abb)) %>%
      pivot_longer(cols = all_of(month.abb), names_to = "Month", values_to = "Value")
    
    if (var == "precip") {
      long_df$Value[long_df$Value <= -9.99] <- NA
    } else if (var == "temp") {
      long_df$Value[long_df$Value <= -99.90] <- NA
    } else if (var %in% c("cdd", "hdd")) {
      long_df$Value[long_df$Value <= -9999] <- NA
    } else if (var %in% c("pdsi", "phdi", "pmdi")) {
      long_df$Value[long_df$Value <= -99.99] <- NA
    }
    
    agg <- long_df %>%
      group_by(fips_code, Year) %>%
      summarize(
        !!paste0(var, "_val") := if(var %in% c("temp", "pdsi", "phdi", "pmdi")) mean(Value, na.rm=TRUE) else sum(Value, na.rm=TRUE), 
        .groups = "drop"
      )
    
    processed_list[[var]] <- agg
  }
  
  cat("  Merging and Feature Engineering...
")
  
  full_climate <- Reduce(function(x, y) full_join(x, y, by = c("fips_code", "Year")), processed_list)
  
  # Compute per-county baseline means/SDs using the 1990-2000 reference period.
  # Applying a fixed pre-study baseline prevents the Z-score distribution from shifting
  # as the study period extends, and aligns with the state-level pipeline methodology.
  baseline_stats <- full_climate %>%
    filter(Year >= 1990, Year <= 2000) %>%
    group_by(fips_code) %>%
    summarize(
      temp_base_mean   = mean(temp_val,   na.rm = TRUE),
      temp_base_sd     = sd(temp_val,     na.rm = TRUE),
      precip_base_mean = mean(precip_val, na.rm = TRUE),
      precip_base_sd   = sd(precip_val,   na.rm = TRUE),
      .groups = "drop"
    )

  # Compute national CDD/HDD 80th-percentile cutoffs from 1990-2000 county-year obs.
  # Using a fixed national threshold (rather than within-county quintiles) ensures
  # High_CDD/High_HDD capture objectively extreme years, not merely above-average
  # years for a county that is already hot/cold. Anchored to the same pre-study
  # reference period as the Z-score baseline for consistency.
  baseline_cdd_hdd <- full_climate %>% filter(Year >= 1990, Year <= 2000)
  cdd_p80 <- quantile(baseline_cdd_hdd$cdd_val, 0.80, na.rm = TRUE)
  hdd_p80 <- quantile(baseline_cdd_hdd$hdd_val, 0.80, na.rm = TRUE)
  cat(sprintf("  CDD national p80 (1990-2000): %.1f | HDD national p80: %.1f\n", cdd_p80, hdd_p80))

  full_climate_feat <- full_climate %>%
    left_join(baseline_stats, by = "fips_code") %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      # Z-Scores anchored to 1990-2000 baseline (not full-sample mean/SD)
      Z_Temp   = (temp_val   - temp_base_mean)   / temp_base_sd,
      Z_Precip = (precip_val - precip_base_mean) / precip_base_sd,

      # CDD/HDD shock indicators: national 80th-percentile cutoff from 1990-2000.
      # A county-year is "High" only if it exceeds the national reference threshold,
      # not merely if it ranks high within its own county-specific history.
      High_CDD = as.integer(!is.na(cdd_val) & cdd_val >= cdd_p80),
      High_HDD = as.integer(!is.na(hdd_val) & hdd_val >= hdd_p80),

      # Distributed Lags (0-2)
      Z_Temp_Lag1 = lag(Z_Temp, 1), Z_Temp_Lag2 = lag(Z_Temp, 2),
      Z_Precip_Lag1 = lag(Z_Precip, 1), Z_Precip_Lag2 = lag(Z_Precip, 2),
      High_CDD_Lag1 = lag(High_CDD, 1), High_CDD_Lag2 = lag(High_CDD, 2),
      High_HDD_Lag1 = lag(High_HDD, 1), High_HDD_Lag2 = lag(High_HDD, 2),
      # PDSI/PHDI/PMDI are already standardized indices; lag directly
      PDSI_Lag1 = lag(pdsi_val, 1), PDSI_Lag2 = lag(pdsi_val, 2),
      PHDI_Lag1 = lag(phdi_val, 1), PHDI_Lag2 = lag(phdi_val, 2),
      PMDI_Lag1 = lag(pmdi_val, 1), PMDI_Lag2 = lag(pmdi_val, 2),
      # Extreme drought indicator: PDSI <= -4 (NOAA/Palmer threshold for extreme drought)
      Is_Extreme_Drought      = as.integer(!is.na(pdsi_val) & pdsi_val <= -4),
      Is_Extreme_Drought_Lag1 = lag(Is_Extreme_Drought, 1),
      Is_Extreme_Drought_Lag2 = lag(Is_Extreme_Drought, 2)
    ) %>%
    select(-temp_base_mean, -temp_base_sd, -precip_base_mean, -precip_base_sd) %>%
    ungroup()
  
  saveRDS(full_climate_feat, output_path)
  cat(paste0("Success! Climate data saved to: ", output_path, "
"))

  invisible(list(outputs = c(output_path), rows = nrow(full_climate_feat)))
}

run_process_county_climate <- function(config = list()) {
  files <- config$files %||% list(
    cdd = "Data/Climate_Data/County level/climdiv-cddccy-v1.0.0-20260107",
    hdd = "Data/Climate_Data/County level/climdiv-hddccy-v1.0.0-20260107",
    precip = "Data/Climate_Data/County level/climdiv-pcpncy-v1.0.0-20260107",
    temp = "Data/Climate_Data/County level/climdiv-tmpccy-v1.0.0-20260107",
    pdsi = "Data/Climate_Data/County level/climdiv-pdsicy-v1.0.0-20260205",
    phdi = "Data/Climate_Data/County level/climdiv-phdicy-v1.0.0-20260205",
    pmdi = "Data/Climate_Data/County level/climdiv-pmdicy-v1.0.0-20260205"
  )
  output_rds <- config$output_rds %||% "Data/intermediate_climate.rds"

  process_noaa_data(files, output_rds)
}

if (sys.nframe() == 0) {
  run_process_county_climate()
}
