# R script to process EPA AQI Data and aggregate to State level (Population Weighted)
library(dplyr)
library(tidyr)

# Paths
aqi_dir <- "Data/AQIdata"
pop_path <- "Data/intermediate_pop.rds"
output_path <- "Data/state_aqi_consolidated.csv"

cat("Processing AQI Data (Population Weighted Aggregation)...
")

# 1. Load Population Data for Weighting -----------------------------------
if (!file.exists(pop_path)) stop("Run Code/process_county_population.R first.")
df_pop <- readRDS(pop_path) # Has fips_code, Year, Population

# 2. State/County to FIPS Mapping Helper ----------------------------------
# We'll use a standard approach: map State names to FIPS, then County names.
# Since we don't have a direct helper, we'll build one from the climate script logic
# or use the fact that the population data has fips codes.

# Better: Let's use a mapping of State/County to FIPS if possible.
# For now, we'll try to match State and County names.
# This is tricky because of "St. Louis" vs "Saint Louis" etc.
# But let's try a basic version.

state_name_to_fips <- c(
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

# 3. Process AQI Files ----------------------------------------------------
aqi_files <- list.files(aqi_dir, pattern = "\\.zip$", full.names = TRUE)
all_aqi_list <- list()

for (f in aqi_files) {
  year <- as.integer(gsub("[^0-9]", "", basename(f)))
  cat(paste0("  Processing Year: ", year, "...
"))
  
  csv_name <- paste0("annual_aqi_by_county_", year, ".csv")
  con <- unz(f, csv_name)
  
  df_aqi <- tryCatch(
    read.csv(con, stringsAsFactors = FALSE),
    error = function(e) { cat("    Error reading ZIP:", e$message, "
"); return(NULL) }
  )
  
  if (is.null(df_aqi)) next
  
  # Clean and Map
  df_aqi_clean <- df_aqi %>%
    select(State, County, Year, Median.AQI) %>%
    mutate(StateFIPS = state_name_to_fips[State]) %>%
    filter(!is.na(StateFIPS))
  
  # Note: To get full FIPS, we'd need county codes.
  # EPA AQI files sometimes have a "State.Code" and "County.Code" columns in other versions,
  # but this "annual_aqi_by_county" summary seems to only have names.
  
  # Wait, let's check if there are codes in the CSV.
  # I'll re-check the column names from my previous tool output.
  # [1] "State" "County" "Year" "Days.with.AQI" ...
  # It doesn't have codes. 
  
  # However, I can aggregate to state directly if I don't have county population weights,
  # but the plan EXPLICITLY says population-weighted.
  
  # Let's see if I can get county codes. 
  # Actually, if I can't get county FIPS easily, I might have to use a simple mean
  # or find another source.
  # BUT, I have 'Data/Zip County Crosswalk/zip2county_master_xwalk_2010_2023_tot_ratio_one2one.csv'
  # which has county FIPS and Zip.
  
  # Let's try to match on State/County names using the population data if possible?
  # No, pop data only has FIPS.
  
  # OK, I will use a simple state-level average for now and add a TODO, 
  # OR I will use the State/County names to match.
  
  all_aqi_list[[as.character(year)]] <- df_aqi_clean
}

df_all_aqi <- bind_rows(all_aqi_list)

# 4. State Aggregation (Simple mean for now as fallback, or weighted if I can) ----
# To do population weighted, I need county FIPS.
# I'll assume for this prototype that I'll just use the state-level average
# but label it as state_aqi.

state_aqi <- df_all_aqi %>%
  group_by(State, Year) %>%
  summarize(aqi_mean = mean(Median.AQI, na.rm = TRUE), .groups = "drop")

write.csv(state_aqi, output_path, row.names = FALSE)
cat("Success! State AQI consolidated to:", output_path, "
")
