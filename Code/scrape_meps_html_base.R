# R script to scrape MEPS IC State Tables using Refined Base R (Regex)
# Strategy: Strip all HTML tags, collapse whitespace, then search for state + value.

output_path <- "Data/MEPS_Data_IC/meps_ic_state_consolidated.csv"
years <- 1996:2025
states <- c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", 
            "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", 
            "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", 
            "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", 
            "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", 
            "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", 
            "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", 
            "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", 
            "Washington", "West Virginia", "Wisconsin", "Wyoming", "United States")

# 1. Scraping Function ----------------------------------------------------
scrape_meps_robust <- function(year, table_code) {
  # 2007: No survey was conducted
  if (year == 2007) return(NULL)
  
  url <- paste0("https://meps.ahrq.gov/data_stats/summ_tables/insr/state/series_2/", year, "/", table_code, ".htm")
  cat("  Scraping:", url, "...\n")
  
  tmp <- tempfile()
  tryCatch({
    download.file(url, tmp, quiet = TRUE, mode = "wt")
    html <- readLines(tmp, warn = FALSE)
    html_str <- paste(html, collapse = " ")
    
    # 1. Clean HTML tags
    clean_text <- gsub("<.*?>", " ", html_str)
    # 2. Collapse whitespace
    clean_text <- gsub("\\s+", " ", clean_text)
    
    results <- list()
    for (st in states) {
      # Handle District of Columbia variants
      st_pattern <- st
      if (st == "District of Columbia") st_pattern <- "District of Columbia|Dist. of Columbia"
      
      # Search for state name followed by the first numeric sequence
      # This skips any footnotes like * that might be in between
      # Pattern: StateName [Anything but digits] [The Number]
      pattern <- paste0("(", st_pattern, ")", "[^0-9.]*?([0-9,.]+)")
      match <- regmatches(clean_text, regexec(pattern, clean_text, ignore.case = TRUE))[[1]]
      
      if (length(match) >= 3) {
        val_str <- match[3]
        # Clean the value (remove commas)
        val_clean <- as.numeric(gsub("[^0-9.]", "", val_str))
        results[[st]] <- val_clean
      } else {
        results[[st]] <- NA
      }
    }
    return(results)
  }, error = function(e) {
    return(NULL)
  }, finally = {
    if (file.exists(tmp)) file.remove(tmp)
  })
}

# 2. Execution Loop -------------------------------------------------------
all_data <- list()
idx <- 1

cat("Starting Robust MEPS Scraping (1996-2025)...\n")

for (yr in years) {
  cat("Processing Year:", yr, "\n")
  
  premiums <- scrape_meps_robust(yr, "tiic2")
  deductibles <- scrape_meps_robust(yr, "tiif1")
  
  # Only add if we got something for this year
  if (!is.null(premiums) || !is.null(deductibles)) {
    for (st in states) {
      p_val <- if (!is.null(premiums)) premiums[[st]] else NA
      d_val <- if (!is.null(deductibles)) deductibles[[st]] else NA
      
      if (!is.na(p_val) || !is.na(d_val)) {
        all_data[[idx]] <- data.frame(
          State = st,
          Year = yr,
          Emp_Contrib_Single = p_val,
          Avg_Deductible_Single = d_val,
          stringsAsFactors = FALSE
        )
        idx <- idx + 1
      }
    }
  }
}

# 3. Save Results ---------------------------------------------------------
if (length(all_data) > 0) {
  final_df <- do.call(rbind, all_data)
  write.csv(final_df, output_path, row.names = FALSE)
  cat("\nSuccess! Scraped MEPS data saved to:", output_path, "\n")
  print(head(final_df))
  cat("Total Records:", nrow(final_df), "\n")
} else {
  cat("\nFailed to scrape data.\n")
}