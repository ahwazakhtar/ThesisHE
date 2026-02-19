# R script to create the Master County-Level Analysis Dataset (Optimized)
library(dplyr)
library(tidyr)
library(readr)

# Paths
path_med_debt <- "Data/medical_debt_county.csv"
path_premiums <- "Data/premiums_county.csv"
path_cpi <- "Data/State_Policy_Data/us_cpi_annual.csv"
path_pop_rds <- "Data/intermediate_pop.rds"
path_climate_rds <- "Data/intermediate_climate.rds"
path_aqi_rds <- "Data/intermediate_aqi.rds"
output_path <- "Data/county_level_master.csv"

cat("Consolidating County-Level Master Dataset...\n")

# 1. Load Pre-processed Data -----------------------------------------------
if (!file.exists(path_pop_rds)) stop("Run Code/process_county_population.R first.")
if (!file.exists(path_climate_rds)) stop("Run Code/process_county_climate.R first.")
if (!file.exists(path_aqi_rds)) stop("Run Code/process_county_aqi.R first.")

df_pop <- readRDS(path_pop_rds)
df_climate <- readRDS(path_climate_rds)
df_aqi <- readRDS(path_aqi_rds)

# 2. Load Other Datasets --------------------------------------------------
cat("Loading Outcomes & Policy Data...\n")
df_med_debt <- read.csv(path_med_debt, colClasses = c("fips_code"="character"))
df_premiums <- read.csv(path_premiums, colClasses = c("fips_code"="character"))
df_cpi <- read.csv(path_cpi, stringsAsFactors = FALSE)

# 3. Merge ----------------------------------------------------------------
cat("Merging...\n")

# Master Join
master <- df_med_debt %>%
  left_join(df_premiums, by = c("fips_code", "Year", "State")) %>%
  left_join(df_climate, by = c("fips_code", "Year")) %>%
  left_join(df_pop, by = c("fips_code", "Year"))

# 4. AQI Join (FIPS-based) ------------------------------------------------
# Join using fips_code and Year
master <- master %>%
  left_join(df_aqi %>% select(fips_code, Year, AQI_Shock, AQI_Shock_Lag1, AQI_Shock_Lag2), 
            by = c("fips_code", "Year"))

# 5. Inflation Adjustment (Base 2023) -------------------------------------
cat("Adjusting Inflation (Base 2023)...\n")
cpi_2023 <- df_cpi$CPI_Value[df_cpi$Year == 2023]

master <- master %>%
  left_join(df_cpi, by = "Year") %>%
  mutate(
    CPI_Factor = cpi_2023 / CPI_Value,
    Benchmark_Silver_Real = Benchmark_Silver * CPI_Factor,
    Lowest_Bronze_Real = Lowest_Bronze * CPI_Factor,
    Hosp_BadDebt_Total_Real = if("Hosp_BadDebt_Total" %in% names(.)) Hosp_BadDebt_Total * CPI_Factor else NA,
    Hosp_Charity_Total_Real = if("Hosp_Charity_Total" %in% names(.)) Hosp_Charity_Total * CPI_Factor else NA
  ) %>%
  select(-CPI_Value, -CPI_Factor)

# 5. Final Output ---------------------------------------------------------
write.csv(master, output_path, row.names = FALSE)
cat(paste0("Success! Master Dataset saved to: ", output_path, "\n"))
cat(paste0("Rows: ", nrow(master), "\n"))