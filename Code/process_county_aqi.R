# R script to process EPA County AQI Data
library(dplyr)
library(readr)

# Paths
aqi_dir     <- "Data/AQIdata"
lookup_path <- "Data/AQIdata/states_and_counties.csv"
output_rds  <- "Data/intermediate_aqi.rds"

cat("Processing County AQI Data...\n")

# 1. Load FIPS Lookup -------------------------------------------------------
if (!file.exists(lookup_path)) stop("FIPS lookup file not found: ", lookup_path)

df_lookup <- read.csv(lookup_path, colClasses = "character") %>%
  mutate(
    fips_code   = paste0(State.Code, County.Code),
    County_Join = tolower(trimws(County.Name)),
    StateName   = State.Name
  ) %>%
  select(fips_code, StateName, StateAbbr = State.Abbreviation, County_Join)

# 2. Read and Map Each Year ------------------------------------------------
aqi_files <- list.files(aqi_dir, pattern = "\\.zip$", full.names = TRUE)
if (length(aqi_files) == 0) stop("No AQI zip files found in: ", aqi_dir)

all_aqi_list <- list()

for (f in aqi_files) {
  year     <- as.integer(gsub("[^0-9]", "", basename(f)))
  csv_name <- paste0("annual_aqi_by_county_", year, ".csv")

  con    <- unz(f, csv_name)
  df_raw <- tryCatch(read.csv(con, stringsAsFactors = FALSE), error = function(e) NULL)
  if (is.null(df_raw)) next

  expected <- c("State", "County", "Year", "Days.with.AQI", "Unhealthy.Days",
                "Very.Unhealthy.Days", "Hazardous.Days", "Max.AQI", "Median.AQI",
                "Days.CO", "Days.NO2", "Days.Ozone", "Days.PM2.5", "Days.PM10")
  if (!all(expected %in% names(df_raw))) {
    warning("Skipping ", basename(f), ": unexpected schema", call. = FALSE)
    next
  }

  df_mapped <- df_raw %>%
    mutate(
      County_Join    = tolower(trimws(County)),
      StateName_Join = State
    ) %>%
    left_join(df_lookup, by = c("StateName_Join" = "StateName", "County_Join")) %>%
    filter(!is.na(fips_code)) %>%
    transmute(
      fips_code,
      State     = StateAbbr,
      StateName = StateName_Join,
      Year,
      Days_AQI      = Days.with.AQI,
      Median_AQI    = Median.AQI,
      Max_AQI       = Max.AQI,
      Days_CO       = Days.CO,
      Days_NO2      = Days.NO2,
      Days_Ozone    = Days.Ozone,
      Days_PM25     = Days.PM2.5,
      Days_PM10     = Days.PM10,
      # Unhealthy = exceedance of EPA "Unhealthy" threshold (AQI > 150)
      Days_Unhealthy = Unhealthy.Days + Very.Unhealthy.Days + Hazardous.Days
    )

  all_aqi_list[[as.character(year)]] <- df_mapped
}

if (length(all_aqi_list) == 0) stop("No AQI records parsed.")

# 3. Percentages and Lags --------------------------------------------------
df_all <- bind_rows(all_aqi_list)

df_feat <- df_all %>%
  mutate(
    Pct_CO        = if_else(Days_AQI > 0, Days_CO        / Days_AQI * 100, 0),
    Pct_NO2       = if_else(Days_AQI > 0, Days_NO2       / Days_AQI * 100, 0),
    Pct_Ozone     = if_else(Days_AQI > 0, Days_Ozone     / Days_AQI * 100, 0),
    Pct_PM25      = if_else(Days_AQI > 0, Days_PM25      / Days_AQI * 100, 0),
    Pct_PM10      = if_else(Days_AQI > 0, Days_PM10      / Days_AQI * 100, 0),
    Pct_Unhealthy = if_else(Days_AQI > 0, Days_Unhealthy / Days_AQI * 100, 0)
  ) %>%
  group_by(fips_code) %>%
  arrange(Year) %>%
  mutate(
    Median_AQI_Lag1    = lag(Median_AQI, 1),    Median_AQI_Lag2    = lag(Median_AQI, 2),
    Max_AQI_Lag1       = lag(Max_AQI, 1),        Max_AQI_Lag2       = lag(Max_AQI, 2),
    Pct_PM25_Lag1      = lag(Pct_PM25, 1),       Pct_PM25_Lag2      = lag(Pct_PM25, 2),
    Pct_PM10_Lag1      = lag(Pct_PM10, 1),       Pct_PM10_Lag2      = lag(Pct_PM10, 2),
    Pct_Ozone_Lag1     = lag(Pct_Ozone, 1),      Pct_Ozone_Lag2     = lag(Pct_Ozone, 2),
    Pct_CO_Lag1        = lag(Pct_CO, 1),         Pct_CO_Lag2        = lag(Pct_CO, 2),
    Pct_NO2_Lag1       = lag(Pct_NO2, 1),        Pct_NO2_Lag2       = lag(Pct_NO2, 2),
    Pct_Unhealthy_Lag1 = lag(Pct_Unhealthy, 1),  Pct_Unhealthy_Lag2 = lag(Pct_Unhealthy, 2)
  ) %>%
  ungroup()

saveRDS(df_feat, output_rds)
cat("Success! County AQI data saved to:", output_rds, "\n")
