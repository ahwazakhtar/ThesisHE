# R script to process State-Level Medical Debt Data
library(readxl)
library(dplyr)

input_path  <- "Data/MedicalDebt/changing_med_debt_landscape_state.xlsx"
output_path <- "Data/MedicalDebt/medical_debt_state_consolidated.csv"

# State Code Mapping (Standardizing across the project)
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

cat("Processing Medical Debt data...
")

# Read the data
df <- read_excel(input_path)

# Clean and Standardize
df_clean <- df %>%
  mutate(State = state_abb_to_name[`State Abbreviation`]) %>%
  filter(!is.na(State)) %>%
  select(
    State, 
    Year, 
    Medical_Debt_Share = `Share with medical debt in collections`,
    Medical_Debt_Median = `Median medical debt in collections in $2023`
  ) %>%
  mutate(
    Medical_Debt_Share = as.numeric(Medical_Debt_Share),
    Medical_Debt_Median = as.numeric(Medical_Debt_Median)
  )

# Write to CSV
write.csv(df_clean, output_path, row.names = FALSE)

cat("Success! Consolidated Medical Debt data saved to:", output_path, "
")
print(head(df_clean))
