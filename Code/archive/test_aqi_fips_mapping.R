# Test script for AQI FIPS mapping using states_and_counties.csv
library(dplyr)

# Paths
aqi_zip <- "Data/AQIdata/annual_aqi_by_county_2023.zip"
lookup_path <- "Data/AQIdata/states_and_counties.csv"

# 1. Load Lookup ----------------------------------------------------------
df_lookup <- read.csv(lookup_path, colClasses = "character") %>%
  mutate(fips_code = paste0(State.Code, County.Code),
         County_Join = tolower(trimws(County.Name)),
         StateName = State.Name) %>%
  select(fips_code, StateName, State.Abbreviation, County_Join)

# 2. Load Sample AQI Data (2023) ------------------------------------------
csv_name <- "annual_aqi_by_county_2023.csv"
con <- unz(aqi_zip, csv_name)
df_aqi <- read.csv(con, stringsAsFactors = FALSE) %>%
  mutate(County_Join = tolower(trimws(County)),
         StateName = State)

# 3. Join and Evaluate ----------------------------------------------------
df_mapped <- df_aqi %>%
  left_join(df_lookup, by = c("StateName", "County_Join"))

total_rows <- nrow(df_aqi)
mapped_rows <- sum(!is.na(df_mapped$fips_code))
missing_counties <- df_mapped %>% filter(is.na(fips_code)) %>% select(State, County) %>% distinct()

cat("Total AQI Rows (2023):", total_rows, "
")
cat("Mapped Rows:", mapped_rows, "(", round(mapped_rows/total_rows*100, 2), "%)
")

if (nrow(missing_counties) > 0) {
  cat("
First 10 missing counties:
")
  print(head(missing_counties, 10))
} else {
  cat("
All counties mapped successfully!
")
}
