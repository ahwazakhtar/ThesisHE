# Deep search for variables in 2023 Alabama Excel
library(readxl)
file_path <- "Data/MEPS_Data_IC/Excel/Alabama2023.xlsx"
sheets <- excel_sheets(file_path)

for (sh in sheets) {
  df <- read_excel(file_path, sheet = sh, col_names = FALSE, .name_repair = "minimal")
  txt <- paste(as.matrix(df), collapse = " ")
  
  has_contrib <- grepl("contribution", txt, ignore.case = TRUE)
  has_deduct <- grepl("deductible", txt, ignore.case = TRUE)
  
  if (has_contrib || has_deduct) {
    cat("
--- Found in Sheet:", sh, "---
")
    if (has_contrib) cat("  [Matches 'contribution']
")
    if (has_deduct) cat("  [Matches 'deductible']
")
    
    # Print the first few rows of text to identify the table
    header <- paste(as.matrix(df[1:5, ]), collapse = " ")
    cat("  Header Snippet:", substr(header, 1, 200), "...
")
  }
}
