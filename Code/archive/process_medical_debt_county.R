# R script to process County-Level Medical Debt Data (Urban Institute)

library(readxl)
library(dplyr)
library(stringr)

input_path <- "Data/MedicalDebt/changing_med_debt_landscape_county.xlsx"
output_path <- "Data/medical_debt_county.csv"

cat("Processing Medical Debt Data...
")

# Read Data
df <- read_excel(input_path)

# Clean and Standardize
df_clean <- df %>%
  mutate(
    fips_code = sprintf("%05d", as.numeric(`County Fips`)),
    State = `State Abbreviation`,
    County = `County Name`
  ) %>%
  select(
    fips_code,
    Year,
    State,
    County,
    Medical_Debt_Share = `Share with medical debt in collections`,
    Medical_Debt_Median_2023 = `Median medical debt in collections in $2023`,
    Household_Income_2023 = `Average household income in $2023`,
    Uninsured_Rate = `Share of the population with no health insurance coverage`,
    Disability_Rate = `Share of non-elderly adults with a reported disability`
  ) %>%
  filter(!is.na(fips_code))

# Save
write.csv(df_clean, output_path, row.names = FALSE)

cat(paste0("Success! Medical Debt data saved to: ", output_path, "
"))
cat(paste0("Total Records: ", nrow(df_clean), "
"))
