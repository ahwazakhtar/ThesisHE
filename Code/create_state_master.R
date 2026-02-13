# R script to create the Master State-Level Analysis Dataset
# Merges Climate, MEPS, CMS Health Expenditures, and Macroeconomic data

# 1. Setup ----------------------------------------------------------------
library(dplyr)

# Paths
path_climate <- "Data/Climate_Data/state_climate_consolidated.csv"
path_aqi     <- "Data/state_aqi_consolidated.csv"
path_meps    <- "Data/MEPS_Data_IC/meps_ic_state_consolidated.csv"
path_cms     <- "Data/State Residence health expenditures/cms_nhe_state_consolidated.csv"
path_macro   <- "Data/State_Policy_Data/state_macroeconomics.csv"
path_meddebt <- "Data/MedicalDebt/medical_debt_state_consolidated.csv"
output_path  <- "Data/state_level_analysis_master.csv"

# State Code Mapping for Macro data (AL -> Alabama)
state_abb_to_name <- c(
  "AL" = "Alabama", "AK" = "Alaska", "AZ" = "Arizona", "AR" = "Arkansas", "CA" = "California",
  "CO" = "Colorado", "CT" = "Connecticut", "DE" = "Delaware", "DC" = "District of Columbia",
  "FL" = "Florida", "GA" = "Georgia", "HI" = "Hawaii", "ID" = "Idaho", "IL" = "Illinois",
  "IN" = "Indiana", "IA" = "Iowa", "KS" = "Kansas", "KY" = "Kentucky", "LA" = "Louisiana",
  "ME" = "Maine", "MD" = "Maryland", "MA" = "Massachusetts", "MI" = "Michigan", "MN" = "Minnesota",
  "MS" = "Mississippi", "MO" = "Missouri", "MT" = "Montana", "NE" = "Nebraska", "NV" = "Nevada",
  "NH" = "New Hampshire", "NJ" = "New Jersey", "NM" = "New Mexico", "NY" = "New York",
  "NC" = "North Carolina", "ND" = "North Dakota", "OH" = "Ohio", "OK" = "Oklahoma", "OR" = "Oregon",
  "PA" = "Pennsylvania", "RI" = "Rhode Island", "SC" = "South Carolina", "SD" = "South Dakota",
  "TN" = "Tennessee", "TX" = "Texas", "UT" = "Utah", "VT" = "Vermont", "VA" = "Virginia",
  "WA" = "Washington", "WV" = "West Virginia", "WI" = "Wisconsin", "WY" = "Wyoming"
)

# 2. Load and Prepare Components ------------------------------------------
cat("Loading datasets...
")

# Climate
df_climate <- read.csv(path_climate, stringsAsFactors = FALSE)

# AQI
df_aqi <- if(file.exists(path_aqi)) read.csv(path_aqi, stringsAsFactors = FALSE) else NULL

# MEPS
df_meps <- read.csv(path_meps, stringsAsFactors = FALSE)

# CMS
df_cms <- read.csv(path_cms, stringsAsFactors = FALSE)

# Medical Debt
df_meddebt <- read.csv(path_meddebt, stringsAsFactors = FALSE)

# Macroeconomics (requires more cleaning)
df_macro_raw <- read.csv(path_macro, stringsAsFactors = FALSE)

# Convert Macro Date to Year and filter
df_macro_raw$Year <- as.integer(substr(df_macro_raw$DATE, 1, 4))
df_macro_raw$State <- state_abb_to_name[df_macro_raw$STATE]

# Aggregate Macro to Annual (Mean for Rate, Mean/Sum for others)
# Since they are monthly, we take the annual average
df_macro <- df_macro_raw %>%
  filter(!is.na(State) & Year >= 1996 & Year <= 2025) %>%
  group_by(State, Year, VARIABLE) %>%
  summarize(Value = mean(as.numeric(VALUE), na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = VARIABLE, values_from = Value)

# 3. Merge ----------------------------------------------------------------
cat("Merging datasets...
")

# Use df_climate as the base because it has the most years
master <- df_climate %>%
  left_join(df_meps, by = c("State", "Year")) %>%
  left_join(df_cms, by = c("State", "Year")) %>%
  left_join(df_macro, by = c("State", "Year")) %>%
  left_join(df_meddebt, by = c("State", "Year"))

if (!is.null(df_aqi)) {
  master <- master %>% left_join(df_aqi, by = c("State", "Year"))
}

# 4. Inflation Adjustment -------------------------------------------------
cat("Adjusting for Inflation (Target Year: Latest Available)...\n")
cpi_path <- "Data/State_Policy_Data/us_cpi_annual.csv"

if (file.exists(cpi_path)) {
  df_cpi <- read.csv(cpi_path, stringsAsFactors = FALSE)
  
  # Determine Target Year (Max Year in CPI)
  target_year <- max(df_cpi$Year)
  cpi_target <- df_cpi$CPI_Value[df_cpi$Year == target_year]
  
  cat("  Target Year for Real Dollars:", target_year, "(CPI:", round(cpi_target, 2), ")\n")
  
  # Create Adjustment Factor Table
  df_adj <- df_cpi %>%
    mutate(Adj_Factor = cpi_target / CPI_Value) %>%
    select(Year, Adj_Factor)
  
  # Join Adjustment Factor to Master
  master <- master %>%
    left_join(df_adj, by = "Year")
  
  # Define Columns to Adjust (Nominal -> Real)
  cols_to_adjust <- c(
    "Emp_Contrib_Single", 
    "Avg_Deductible_Single",
    "Total_Per_Capita_Health_Exp",
    "PHI_Per_Enrollee_Health_Exp",
    "Medicaid_Per_Enrollee_Health_Exp",
    "Medicare_Per_Enrollee_Health_Exp",
    "Personal_Income_Per_Capita"
  )
  
  # Apply Adjustment to Standard Nominal Columns
  for (col in cols_to_adjust) {
    if (col %in% names(master)) {
      new_col <- paste0(col, "_Real")
      master[[new_col]] <- master[[col]] * master$Adj_Factor
    }
  }
  
  # Special Handling: Medical Debt (Already in 2023 Dollars)
  # We need to adjust from 2023 Dollars -> Target Year Dollars
  if ("Medical_Debt_Median" %in% names(master)) {
    cpi_2023 <- df_cpi$CPI_Value[df_cpi$Year == 2023]
    if (length(cpi_2023) > 0) {
      adj_factor_med_debt <- cpi_target / cpi_2023
      master$Medical_Debt_Median_Real <- master$Medical_Debt_Median * adj_factor_med_debt
    } else {
      warning("CPI for 2023 not found. Medical Debt not adjusted.")
      master$Medical_Debt_Median_Real <- master$Medical_Debt_Median
    }
  }
  
  # Clean up
  master$Adj_Factor <- NULL
  
} else {
  warning("CPI data not found at ", cpi_path, ". skipping inflation adjustment.")
}

# 5. Final Cleaning -------------------------------------------------------
# Remove "United States" if it exists as a state entry in any dataset
master <- master %>% filter(State != "United States" & !is.na(State))

# Sort
master <- master %>% arrange(State, Year)

# Write output
write.csv(master, output_path, row.names = FALSE)

cat("
Success! Master State-Level Analysis Dataset created.
")
cat("Path:", output_path, "
")
cat("Dimensions:", nrow(master), "rows x", ncol(master), "columns
")
cat("Year Range:", min(master$Year), "-", max(master$Year), "
")
print(head(master))
