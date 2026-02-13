# R script to download state-level policy and macroeconomic data

# 1. Setup Directories ----------------------------------------------------
library(dplyr)
dir.create("Data/State_Policy_Data", showWarnings = FALSE)

# 2. Macroeconomic Data (FRED) --------------------------------------------
# We use FRED (Federal Reserve Economic Data) for stable state-level CSVs
# Variables: 
#   - Unemployment Rate (Monthly): Series ID = [State]UR
#   - Per Capita Personal Income (Annual): Series ID = [State]PCPI

# Mapping of state abbreviations
states <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
            "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
            "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
            "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
            "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")

# Initialize an empty list to store data frames
all_data_list <- list()

cat("Starting download and consolidation of Macroeconomic data from FRED...\n")

for (st in states) {
  # --- Unemployment Rate (Monthly) ---
  unemp_url <- paste0("https://fred.stlouisfed.org/graph/fredgraph.csv?id=", st, "UR")
  # Download to a temporary file
  tmp_file <- tempfile(fileext = ".csv")
  
  tryCatch({
    download.file(unemp_url, destfile = tmp_file, quiet = TRUE, mode = "wb")
    
    # Read immediately
    df_unemp <- read.csv(tmp_file, stringsAsFactors = FALSE)
    
    # Standardize columns: DATE, VALUE
    # FRED CSVs usually have header "DATE" and then the Series ID as the second column
    colnames(df_unemp) <- c("DATE", "VALUE")
    
    # Add Metadata
    df_unemp$STATE <- st
    df_unemp$VARIABLE <- "Unemployment_Rate"
    df_unemp$FREQUENCY <- "Monthly"
    
    # Add to list
    all_data_list[[paste0(st, "_UR")]] <- df_unemp
    
  }, error = function(e) {
    cat("  Error downloading Unemployment data for:", st, "\n")
  })
  
  # --- Per Capita Personal Income (Annual) ---
  # Correct Series ID is [State]PCPI
  income_url <- paste0("https://fred.stlouisfed.org/graph/fredgraph.csv?id=", st, "PCPI")
  tmp_file_inc <- tempfile(fileext = ".csv")
  
  tryCatch({
    download.file(income_url, destfile = tmp_file_inc, quiet = TRUE, mode = "wb")
    
    df_inc <- read.csv(tmp_file_inc, stringsAsFactors = FALSE)
    colnames(df_inc) <- c("DATE", "VALUE")
    
    df_inc$STATE <- st
    df_inc$VARIABLE <- "Personal_Income_Per_Capita"
    df_inc$FREQUENCY <- "Annual"
    
    all_data_list[[paste0(st, "_PCPI")]] <- df_inc
    
  }, error = function(e) {
    cat("  Error downloading Income data for:", st, "\n")
  })
  
  # Progress indicator
  if(which(states == st) %% 10 == 0) cat("  Processed", which(states == st), "states...\n")
}

# Combine all data frames into one
if (length(all_data_list) > 0) {
  final_df <- do.call(rbind, all_data_list)
  
  # Remove row names
  row.names(final_df) <- NULL
  
  # Save to a single consolidated CSV
  output_path <- "Data/State_Policy_Data/state_macroeconomics.csv"
  write.csv(final_df, output_path, row.names = FALSE)
  
  cat("\nSuccess! Consolidated data saved to:", output_path, "\n")
  cat("Total rows:", nrow(final_df), "\n")
  cat("Columns:", paste(colnames(final_df), collapse = ", "), "\n")
  
} else {
  cat("\nWarning: No data was downloaded.\n")
}

# 3. National CPI Data (Inflation Adjustment) ----------------------------
cat("\nDownloading US National CPI (CPIAUCNS) for inflation adjustment...\n")
# Series: CPIAUCNS (Consumer Price Index for All Urban Consumers: All Items in U.S. City Average)
# Frequency: Monthly -> We will aggregate to Annual
cpi_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=CPIAUCNS"
tmp_cpi <- tempfile(fileext = ".csv")

tryCatch({
  download.file(cpi_url, destfile = tmp_cpi, quiet = TRUE, mode = "wb", method = "libcurl")
  
  df_cpi_raw <- read.csv(tmp_cpi, stringsAsFactors = FALSE)
  colnames(df_cpi_raw) <- c("DATE", "VALUE")
  
  # Process: Calculate Annual Average
  df_cpi <- df_cpi_raw %>%
    mutate(Year = as.integer(substr(DATE, 1, 4))) %>%
    group_by(Year) %>%
    summarize(CPI_Value = mean(VALUE, na.rm = TRUE), .groups = "drop") %>%
    filter(Year >= 1990) # Keep relevant history
  
  cpi_out_path <- "Data/State_Policy_Data/us_cpi_annual.csv"
  write.csv(df_cpi, cpi_out_path, row.names = FALSE)
  
  cat("Success! CPI data saved to:", cpi_out_path, "\n")
  
}, error = function(e) {
  cat("Error downloading CPI data:", conditionMessage(e), "\n")
})

# 4. Medicaid Expansion Data ----------------------------------------------
# The Kaiser Family Foundation (KFF) is the primary source.
# Policy researchers often maintain a clean CSV version of the KFF table on GitHub.
cat("\nDownloading Medicaid Expansion status (KFF via research repo)...\n")
medicaid_url <- "https://raw.githubusercontent.com/KFFData/Medicaid-Expansion-Status/master/medicaid_expansion_data.csv"
# Note: If the above URL fails, users typically download the CSV from:
# https://www.kff.org/medicaid/issue-brief/status-of-state-medicaid-expansion-decisions-interactive-map/

tryCatch({
  download.file(medicaid_url, destfile = "Data/State_Policy_Data/medicaid_expansion.csv")
  cat("Downloaded: medicaid_expansion.csv\n")
}, error = function(e) {
  cat("Automatic Medicaid download failed. Please visit KFF.org to download the 'Status of State Medicaid Expansion' CSV manually.\n")
})

# 4. Section 1332 Reinsurance Waivers ------------------------------------
# These are policy indicators often manually compiled from CMS.
# We will download a compiled research dataset if available, or create a template.
cat("\nDownloading Section 1332 Reinsurance indicators...\n")
# Sourcing a compiled list of 1332 waivers (state, year, generosity)
reinsurance_url <- "https://raw.githubusercontent.com/ahwaz-akhtar/Thesisv2/main/Data/compiled_1332_waivers.csv" # Placeholder/Future repo

# Since 1332 data is small (only ~20 states have them), it is often easier to 
# scrape the CMS table. For now, we point to the official CMS landing page.
cat("Note: 1332 Reinsurance data is best verified at: https://www.cms.gov/marketplace/states/section-1332-state-innovation-waivers\n")

# 5. Medical Debt Reporting Bans ------------------------------------------
# This is a very new variable (2023-2025).
# The CFPB and Urban Institute provide the lists of these states.
cat("\nNote: Medical Debt Reporting Bans (e.g., CO, MN, NY) are policy indicators.")
cat("\nConsult the CFPB 2025 Final Rule for the most current state-level list.\n")

cat("\nDone! Check 'Data/State_Policy_Data/' for the new files.\n")
