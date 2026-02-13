# R script to process EPA County AQI Data and generate Z-score shocks using FIPS lookup
library(dplyr)
library(tidyr)
library(readr)

# Paths
aqi_dir <- "Data/AQIdata"
lookup_path <- "Data/AQIdata/states_and_counties.csv"
output_rds <- "Data/intermediate_aqi.rds"

cat("Processing County AQI Data with FIPS Lookup...\n")

# 1. Load FIPS Lookup -----------------------------------------------------
if (!file.exists(lookup_path)) stop("FIPS lookup file not found at: ", lookup_path)

df_lookup <- read.csv(lookup_path, colClasses = "character") %>%
  mutate(fips_code = paste0(State.Code, County.Code),
         County_Join = tolower(trimws(County.Name)),
         StateName = State.Name) %>%
  select(fips_code, StateName, StateAbbr = State.Abbreviation, County_Join)

# 2. Process AQI Files ----------------------------------------------------
aqi_files <- list.files(aqi_dir, pattern = "\\.zip$", full.names = TRUE)
all_aqi_list <- list()

for (f in aqi_files) {
  year <- as.integer(gsub("[^0-9]", "", basename(f)))
  csv_name <- paste0("annual_aqi_by_county_", year, ".csv")
  
  con <- unz(f, csv_name)
  df_aqi_raw <- tryCatch(
    read.csv(con, stringsAsFactors = FALSE),
    error = function(e) return(NULL)
  )
  
  if (is.null(df_aqi_raw)) next
  
  # Join with FIPS lookup
  # Note: df_aqi_raw has 'State' (Full name) and 'County'
  df_aqi_mapped <- df_aqi_raw %>%
    mutate(County_Join = tolower(trimws(County)),
           StateName_Join = State) %>%
    left_join(df_lookup, by = c("StateName_Join" = "StateName", "County_Join")) %>%
    filter(!is.na(fips_code)) %>%
    select(fips_code, State = StateAbbr, County, Year, Median.AQI)
  
  all_aqi_list[[as.character(year)]] <- df_aqi_mapped
}

df_all_aqi <- bind_rows(all_aqi_list)

# 3. Feature Engineering (Z-Scores & Lags) --------------------------------
cat("  Generating Shocks and Lags...\n")

df_aqi_feat <- df_all_aqi %>%
  group_by(fips_code) %>%
  arrange(Year) %>%
  mutate(
    # Z-Score relative to county's own history
    AQI_Mean_County = mean(Median.AQI, na.rm = TRUE),
    AQI_SD_County = sd(Median.AQI, na.rm = TRUE),
    AQI_Shock = if_else(!is.na(AQI_SD_County) & AQI_SD_County > 0, (Median.AQI - AQI_Mean_County) / AQI_SD_County, 0),
    
    # Lags
    AQI_Shock_Lag1 = lag(AQI_Shock, 1),
    AQI_Shock_Lag2 = lag(AQI_Shock, 2)
  ) %>%
  ungroup()

saveRDS(df_aqi_feat, output_rds)
cat("Success! Intermediate AQI data saved to:", output_rds, "\n")