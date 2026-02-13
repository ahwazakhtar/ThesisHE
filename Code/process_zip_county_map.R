# R script to process and map Zip-level and County-level Health Finance Data
# 1. Urban Institute Medical Debt (County Level)
# 2. NASHP Hospital Cost Data (Zip Level -> County Level)

library(readxl)
library(dplyr)
library(stringr)

# Paths
path_urban_debt <- "Data/MedicalDebt/changing_med_debt_landscape_county.xlsx"
path_nashp <- "Data/Hosp_Data/NASHP 2011-2023 HCT Data 2025 Feb.xlsx"
path_zip_crosswalk <- "Data/Zip County Crosswalk/zip2county_master_xwalk_2010_2023_tot_ratio_one2one.csv"
output_path <- "Data/medical_debt_county.csv"

cat("Processing Health Finance Data...
")

# -------------------------------------------------------------------------
# Part 1: Urban Institute (Direct County Level)
# -------------------------------------------------------------------------
cat("1. Processing Urban Institute Medical Debt...
")
if (file.exists(path_urban_debt)) {
  df_urban <- read_excel(path_urban_debt)
  
  df_urban_clean <- df_urban %>%
    mutate(
      fips_code = sprintf("%05d", as.numeric(`County Fips`)),
      State = `State Abbreviation`
    ) %>%
    select(
      fips_code,
      Year,
      State,
      Medical_Debt_Share = `Share with medical debt in collections`,
      Medical_Debt_Median_2023 = `Median medical debt in collections in $2023`,
      Household_Income_2023 = `Average household income in $2023`,
      Uninsured_Rate = `Share of the population with no health insurance coverage`,
      Disability_Rate = `Share of non-elderly adults with a reported disability`
    ) %>%
    filter(!is.na(fips_code))
  
  cat(paste0("   Rows: ", nrow(df_urban_clean), "
"))
} else {
  warning("Urban Institute file not found.")
  df_urban_clean <- NULL
}

# -------------------------------------------------------------------------
# Part 2: NASHP Hospital Costs (Zip -> County)
# -------------------------------------------------------------------------
cat("2. Processing NASHP Hospital Cost Data...
")

if (file.exists(path_nashp) && file.exists(path_zip_crosswalk)) {
  # Load NASHP
  df_nashp <- read_excel(path_nashp)
  
  # Load Crosswalk (Columns: zip, county, year, tot_ratio)
  df_cw <- read.csv(path_zip_crosswalk) %>%
    mutate(ZIP = sprintf("%05d", as.numeric(zip)),
           fips_code = sprintf("%05d", as.numeric(county)),
           Year = as.integer(year),
           RES_RATIO = as.numeric(tot_ratio)) %>%
    select(ZIP, fips_code, Year, RES_RATIO)
  
  # Clean NASHP
  # Note: Key vars are 'Uninsured and Bad Debt Cost', 'Net Charity Care Cost', 'Net Patient Revenue'
  # We assume column names based on standard HCT files; might need adjustment if schema changes
  df_nashp_clean <- df_nashp %>%
    mutate(
      Zip_Code = sprintf("%05d", as.numeric(`Zip Code`)),
      Year = as.integer(Year), # Match column name in NASHP file
      # Force numeric conversion for cost columns
      BadDebt = as.numeric(`Uninsured and Bad Debt Cost`),
      Charity = as.numeric(`Net Charity Care Cost`),
      Revenue = as.numeric(`Net Patient Revenue`)
    ) %>%
    group_by(Zip_Code, Year) %>%
    summarize(
      Zip_BadDebt = sum(BadDebt, na.rm = TRUE),
      Zip_Charity = sum(Charity, na.rm = TRUE),
      Zip_Revenue = sum(Revenue, na.rm = TRUE),
      .groups = "drop"
    )
  
  # Map to County
  # Logic: Distribute Zip dollars to County based on Res_Ratio
  df_hosp_county <- df_nashp_clean %>%
    left_join(df_cw, by = c("Zip_Code" = "ZIP", "Year" = "Year")) %>%
    filter(!is.na(fips_code)) %>%
    mutate(
      Allocated_BadDebt = Zip_BadDebt * RES_RATIO,
      Allocated_Charity = Zip_Charity * RES_RATIO,
      Allocated_Revenue = Zip_Revenue * RES_RATIO
    ) %>%
    group_by(fips_code, Year) %>%
    summarize(
      Hosp_BadDebt_Total = sum(Allocated_BadDebt, na.rm = TRUE),
      Hosp_Charity_Total = sum(Allocated_Charity, na.rm = TRUE),
      Hosp_Revenue_Total = sum(Allocated_Revenue, na.rm = TRUE),
      .groups = "drop"
    )
  
  # Normalize by Population (Need County Pop? Or just keep totals?)
  # Plan says: Uninsured_Bad_Debt_Per_Capita_Real
  # We will merge population in 'create_county_master.R' or here?
  # Let's keep totals here and normalize in master script where we might have pop data.
  
  cat(paste0("   Processed NASHP rows: ", nrow(df_hosp_county), "
"))
  
} else {
  cat("   Skipping NASHP: File or Crosswalk missing.
")
  if (!file.exists(path_zip_crosswalk)) cat("   (Missing Crosswalk: ", path_zip_crosswalk, ")
")
  df_hosp_county <- NULL
}

# -------------------------------------------------------------------------
# Part 3: Merge and Save
# -------------------------------------------------------------------------

if (!is.null(df_urban_clean)) {
  final_df <- df_urban_clean
  
  if (!is.null(df_hosp_county)) {
    final_df <- final_df %>%
      full_join(df_hosp_county, by = c("fips_code", "Year"))
  }
  
  write.csv(final_df, output_path, row.names = FALSE)
  cat(paste0("Success! Data saved to: ", output_path, "
"))
} else {
  cat("No data processed.
")
}
