# R script to process SEER County Population Data efficiently
library(dplyr)
library(readr)

path_pop_raw <- "Data/County Population/us.1969_2023.20ages.adjusted.txt"
output_rds <- "Data/intermediate_pop.rds"

cat("Processing SEER Population Data (Efficiently)...
")

if (!file.exists(path_pop_raw)) {
  stop("SEER Population file not found.")
}

# Column positions for 19-age group format:
# Year: 1-4, ST: 5-6, ST_FIPS: 7-8, CTY_FIPS: 9-11, Registry: 12-13, Race: 14, Origin: 15, Sex: 16, Age: 17-18, Pop: 19-26
# Using readr::read_fwf for speed
df_pop <- read_fwf(path_pop_raw, 
                   fwf_positions(
                     start = c(1, 5, 7, 9, 12, 14, 15, 16, 17, 19),
                     end   = c(4, 6, 8, 11, 13, 14, 15, 16, 18, 26),
                     col_names = c("Year", "ST_Abbr", "ST_FIPS", "CTY_FIPS", "Registry", "Race", "Origin", "Sex", "AgeGroup", "Pop")
                   ),
                   col_types = "icccicciid")

cat("  Aggregating to County-Year...
")

df_pop_agg <- df_pop %>%
  filter(Year >= 1996) %>%
  mutate(fips_code = paste0(ST_FIPS, CTY_FIPS)) %>%
  group_by(fips_code, Year) %>%
  summarize(Population = sum(Pop), .groups = "drop")

saveRDS(df_pop_agg, output_rds)
cat(paste0("Success! Population data saved to: ", output_rds, "
"))
