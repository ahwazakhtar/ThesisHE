# Scan all years for Alabama to see available tables (FIXED REGEX)
library(readxl)

alabama_files <- list.files("Data/MEPS_Data_IC/Excel", pattern = "^Alabama.*\\.xls[x]?$", full.names = TRUE)

cat("Year | Available Sheets\n")
cat("-----|-----------------\n")

for (f in alabama_files) {
  fname <- basename(f)
  year <- gsub("[^0-9]", "", fname)
  sheets <- excel_sheets(f)
  
  # Check if our target concepts exist in any sheet name
  has_contrib <- any(grepl("contribution", sheets, ignore.case = TRUE))
  has_deduct <- any(grepl("deductible", sheets, ignore.case = TRUE))
  
  status <- ""
  if (has_contrib) status <- paste0(status, "[CONTAINS CONTRIB] ")
  if (has_deduct) status <- paste0(status, "[CONTAINS DEDUCT] ")
  
  cat(year, "|", paste(sheets, collapse = ", "), status, "\n")
}