# Read more of Alabama2023.xlsx Table II (FIXED)
library(readxl)
file_path <- "Data/MEPS_Data_IC/Excel/Alabama2023.xlsx"
df <- read_excel(file_path, sheet = "Table II", n_max = 1000, col_names = FALSE, .name_repair = "minimal")
mat <- as.matrix(df)
titles <- mat[,1]
cat("Titles in Table II sheet:\n")
# Filter for non-NA titles that look like Table names
found_titles <- titles[!is.na(titles) & grepl("^Table II", titles)]
print(found_titles)