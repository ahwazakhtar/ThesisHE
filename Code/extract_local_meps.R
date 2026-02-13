# R script to extract MEPS data from LOCAL Excel files (2021-2024)
# Strategy: Refined Keyword search per sheet to distinguish Contribution vs Deductible.

library(readxl)
library(dplyr)

output_path_meps <- "Data/MEPS_Data_IC/meps_ic_state_consolidated.csv"
excel_dir <- "Data/MEPS_Data_IC/Excel"

# 1. Extraction Helper ----------------------------------------------------
extract_from_excel <- function(file_path, keyword_set) {
  sheets <- excel_sheets(file_path)
  for (sh in sheets) {
    try({
      # Read the header of the sheet
      df_head <- read_excel(file_path, sheet = sh, n_max = 15, col_names = FALSE, .name_repair = "minimal")
      head_txt <- paste(as.matrix(df_head), collapse = " ")
      
      # Match concept AND "single" to ensure we are in the right table
      is_match <- all(sapply(keyword_set$must, function(k) grepl(k, head_txt, ignore.case = TRUE)))
      if (is_match && !is.null(keyword_set$must_not)) {
        if (any(sapply(keyword_set$must_not, function(k) grepl(k, head_txt, ignore.case = TRUE)))) is_match <- FALSE
      }
      
      if (is_match) {
        df <- read_excel(file_path, sheet = sh, col_names = FALSE, .name_repair = "minimal")
        mat <- as.matrix(df)
        
        # Find the "Total" row
        row_idx <- grep("Total|establishments|United States", mat[,1], ignore.case = TRUE)[1]
        
        if (!is.na(row_idx)) {
          val <- as.numeric(gsub("[^0-9.]", "", as.character(mat[row_idx, 2])))
          if (is.na(val)) val <- as.numeric(gsub("[^0-9.]", "", as.character(mat[row_idx, 3])))
          if (!is.na(val)) return(val)
        }
      }
    }, silent = TRUE)
  }
  return(NA)
}

# 2. Process Files (2021-2024) --------------------------------------------
files_21_24 <- list.files(excel_dir, pattern = "202[1-4]\\.xlsx$", full.names = TRUE)
cat("Processing", length(files_21_24), "local Excel files...\n")

new_rows <- list()
for (f in files_21_24) {
  fname <- basename(f)
  # Extract state and year from filename like Alabama2021.xlsx
  year <- as.integer(gsub("[^0-9]", "", fname))
  state_raw <- gsub("[0-9].*", "", fname)
  
  cat(".") # Progress indicator
  
  contrib_keywords <- list(must=c("contribution", "single"), must_not=c("deductible"))
  deduct_keywords  <- list(must=c("deductible", "single"), must_not=c("contribution"))
  
  contrib <- extract_from_excel(f, contrib_keywords)
  deduct  <- extract_from_excel(f, deduct_keywords)
  
  new_rows[[fname]] <- data.frame(
    State = state_raw,
    Year = year,
    Emp_Contrib_Single = contrib,
    Avg_Deductible_Single = deduct,
    stringsAsFactors = FALSE
  )
}
cat("\n")

# 3. Merge with Scraped Data ----------------------------------------------
meps_scraped <- read.csv(output_path_meps, stringsAsFactors = FALSE)
meps_scraped <- meps_scraped %>% filter(Year <= 2020)

df_new <- do.call(rbind, new_rows)

standard_states <- unique(meps_scraped$State)
df_new$State <- sapply(df_new$State, function(s) {
  match <- standard_states[gsub(" ", "", standard_states) == s]
  if (length(match) > 0) return(match[1]) else return(s)
})

meps_final <- bind_rows(meps_scraped, df_new) %>%
  arrange(State, Year)

write.csv(meps_final, output_path_meps, row.names = FALSE)
cat("Success! MEPS updated.\n")
