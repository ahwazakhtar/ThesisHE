# R script to scrape MEPS IC State Tables (HTML)
# Variables: 
#   - Employee Contributions (Single Coverage): tiic2
#   - Deductibles (Single Coverage): tiif1

# 1. Setup ----------------------------------------------------------------
if (!require("rvest", quietly = TRUE)) {
  install.packages("rvest", repos = "http://cran.us.r-project.org")
  library(rvest)
}
library(dplyr)
library(stringr)

output_path <- "Data/MEPS_Data_IC/meps_ic_state_consolidated.csv"
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

# 2. Scraping Function ----------------------------------------------------
scrape_meps_table <- function(year, table_code) {
  # URL Pattern: https://meps.ahrq.gov/data_stats/summ_tables/insr/state/series_2/2009/tiic2.htm
  url <- paste0("https://meps.ahrq.gov/data_stats/summ_tables/insr/state/series_2/", year, "/", table_code, ".htm")
  
  cat("Scraping:", url, "...
")
  
  tryCatch({
    page <- read_html(url)
    
    # Tables are often nested or have complex headers. We look for the main data table.
    # Usually the one with many rows.
    tables <- html_table(page, fill = TRUE)
    
    # Find the table that contains "Alabama" or "United States"
    target_table <- NULL
    for (tbl in tables) {
      # Convert to text matrix to search
      txt <- as.matrix(tbl)
      if (any(grepl("Alabama", txt)) && nrow(tbl) > 40) {
        target_table <- tbl
        break
      }
    }
    
    if (is.null(target_table)) return(NULL)
    
    # Cleaning the table
    # The table usually has State in Col 1, and "Total" (Average) in Col 2.
    # Sometimes Col 2 is "Total" (All firms), Col 3 is "Less than 10", etc.
    # We want Col 2 (Total Estimate).
    
    df <- target_table
    
    # Identify the row for each state
    results <- list()
    for (st in states) {
      # Find row index matching state name exactly or close to it
      # Note: Sometimes there are hidden characters or footnotes like "Alabama *"
      row_idx <- which(grepl(paste0("^", st), df[[1]]) | grepl(st, df[[1]]))
      
      if (length(row_idx) > 0) {
        # Take the first match
        r <- row_idx[1]
        # Value is usually in column 2. 
        # But we need to be careful of headers. If row 1-3 are headers, r will be > 3.
        val_str <- df[r, 2]
        
        # Clean the value (remove *, commas, $)
        val_clean <- as.numeric(gsub("[^0-9.]", "", val_str))
        
        results[[st]] <- val_clean
      } else {
        results[[st]] <- NA
      }
    }
    
    return(results)
    
  }, error = function(e) {
    cat("  Error scraping", year, table_code, ":", e$message, "
")
    return(NULL)
  })
}

# 3. Execution Loop -------------------------------------------------------
all_data <- list()
idx <- 1

cat("Starting MEPS HTML Scraping (2011-2024)...
")

for (yr in years) {
  # Scrape Premiums (tiic2)
  cat("  Processing Year:", yr, "(Premiums)
")
  premiums <- scrape_meps_table(yr, "tiic2")
  
  # Scrape Deductibles (tiif1)
  cat("  Processing Year:", yr, "(Deductibles)
")
  deductibles <- scrape_meps_table(yr, "tiif1")
  
  # Combine
  if (!is.null(premiums) || !is.null(deductibles)) {
    for (st in states) {
      all_data[[idx]] <- data.frame(
        State = st,
        Year = yr,
        Emp_Contrib_Single = if (!is.null(premiums)) premiums[[st]] else NA,
        Avg_Deductible_Single = if (!is.null(deductibles)) deductibles[[st]] else NA,
        stringsAsFactors = FALSE
      )
      idx <- idx + 1
    }
  }
}

# 4. Save Results ---------------------------------------------------------
if (length(all_data) > 0) {
  final_df <- do.call(rbind, all_data)
  
  # Filter out rows where both are NA (if scrape failed entirely for a year)
  final_df <- final_df[!(is.na(final_df$Emp_Contrib_Single) & is.na(final_df$Avg_Deductible_Single)), ]
  
  write.csv(final_df, output_path, row.names = FALSE)
  cat("
Success! Scraped MEPS data saved to:", output_path, "
")
  print(head(final_df))
  cat("Total Records:", nrow(final_df), "
")
} else {
  cat("
Failed to scrape any data.
")
}
