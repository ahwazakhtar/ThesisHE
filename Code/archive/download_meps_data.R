# R script to download MEPS Insurance Component (IC) State Tables (Excel)
# Focused on "Out-of-Pocket" proxy measures: Employee Contributions and Deductibles.

# 1. Setup Directories ----------------------------------------------------
dir.create("Data/MEPS_Data", showWarnings = FALSE)
dir.create("Data/MEPS_Data/Excel", showWarnings = FALSE)

# Load required packages
if (!require("readxl", quietly = TRUE)) {
  warning("The 'readxl' package is not installed. Data consolidation will be skipped.")
  do_consolidation <- FALSE
} else {
  library(readxl)
  do_consolidation <- TRUE
}

# 2. Define Parameters ----------------------------------------------------
# Years: 2011-2024
years <- 2011:2024

states <- c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", 
            "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", 
            "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", 
            "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", 
            "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", 
            "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", 
            "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", 
            "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", 
            "Washington", "West Virginia", "Wisconsin", "Wyoming", "United States")

base_url <- "https://meps.ahrq.gov/mepsweb/data_stats/summ_tables/insr/excel/"

# 3. Download Loop --------------------------------------------------------
cat("Starting download of MEPS IC State Tables (Excel)...
")

for (yr in years) {
  cat("Processing Year:", yr, " ...\n")
  
  # Determine extension based on year
  ext <- if (yr < 2021) ".xls" else ".xlsx"
  
  for (st in states) {
    st_nospace <- gsub(" ", "", st)
    fname <- paste0(st_nospace, yr, ext)
    url <- paste0(base_url, yr, "/", fname)
    dest_file <- paste0("Data/MEPS_Data/Excel/", fname)
    
    # Skip if exists
    if (file.exists(dest_file)) {
      next
    }
    
    tryCatch({
      download.file(url, destfile = dest_file, quiet = TRUE, mode = "wb")
      
      # Check for error files (small size)
      if (file.info(dest_file)$size < 2000) {
        file.remove(dest_file)
      } else {
        cat("  Downloaded:", fname, "\n")
      }
      
    }, error = function(e) {
      # cat("  Error downloading", fname, ":", e$message, "\n")
    })
  }
}

# 4. Consolidate Data -----------------------------------------------------

if (do_consolidation) {
  cat("\nConsolidating data from downloaded Excel files...\n")
  
  # List both .xls and .xlsx
  # Note: Escaping backslashes for R string inside this script
  excel_files <- list.files("Data/MEPS_Data/Excel", pattern = "\\.xls[x]?$", full.names = TRUE)
  all_data_list <- list()
  
  for (f in excel_files) {
    tryCatch({
      fname <- basename(f)
      name_core <- sub("\\.xls[x]?$", "", fname)
      yr_str <- substr(name_core, nchar(name_core)-3, nchar(name_core))
      st_str <- substr(name_core, 1, nchar(name_core)-4)
      
      sheets <- excel_sheets(f)
      
      # Helper to find relevant sheet and value
      find_value_in_sheets <- function(regex_sheet_name) {
        # 1. Try finding sheet by name
        target_sheet <- sheets[grep(regex_sheet_name, sheets, ignore.case = TRUE)][1]
        
        # 2. If not found, search content of likely sheets (expensive but needed)
        search_sheets <- if (!is.na(target_sheet)) c(target_sheet) else sheets
        
        for (sh in search_sheets) {
          # Read chunk
          df <- read_excel(f, sheet = sh, col_names = FALSE, .name_repair = "minimal", n_max = 50)
          mat <- as.matrix(df)
          
          # Check title for "Employee contribution" AND "single"
          title_rows <- paste(mat[1:10, ], collapse = " ")
          
          is_contrib <- grepl("contribution", title_rows, ignore.case=TRUE)
          is_single <- grepl("single", title_rows, ignore.case=TRUE)
          is_deduct <- grepl("deductible", title_rows, ignore.case=TRUE)
          
          # Logic: Match the requested concept
          # If regex_sheet_name asked for Contrib/Single...
          match <- FALSE
          if (grepl("contribution", regex_sheet_name, ignore.case=TRUE)) {
             if (is_contrib && is_single) match <- TRUE
          } else if (grepl("deductible", regex_sheet_name, ignore.case=TRUE)) {
             if (is_deduct && is_single) match <- TRUE
          }
          
          if (match) {
             # Find Total row
             row_idx <- grep("Total|All establishments|United States", mat[,1], ignore.case = TRUE)[1]
             if (!is.na(row_idx)) {
               # Val is usually col 2 (Estimate)
               val <- as.numeric(mat[row_idx, 2])
               if (is.na(val)) val <- as.numeric(mat[row_idx, 3])
               return(val)
             }
          }
        }
        return(NA)
      }
      
      # Extract using concept search if sheet name search fails
      # We pass a concept string to our helper
      val_c2 <- find_value_in_sheets("contribution.*single") 
      val_f2 <- find_value_in_sheets("deductible.*single")
      
      # Store what we found
      all_data_list[[fname]] <- data.frame(
        STATE = st_str,
        YEAR = as.integer(yr_str),
        Emp_Contrib_Single = val_c2,
        Avg_Deductible_Single = val_f2,
        stringsAsFactors = FALSE
      )
      
    }, error = function(e) {
      cat("  Error parsing", basename(f), ":", e$message, "\n")
    })
  }
  
  if (length(all_data_list) > 0) {
    final_df <- do.call(rbind, all_data_list)
    write.csv(final_df, "Data/MEPS_Data/meps_ic_state_consolidated.csv", row.names = FALSE)
    cat("Success! Consolidated data saved to: Data/MEPS_Data/meps_ic_state_consolidated.csv\n")
    print(head(final_df))
  } else {
    cat("No data extracted.\n")
  }
}