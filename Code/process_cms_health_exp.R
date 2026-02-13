# R script to process CMS National Health Expenditure (NHE) data
# Files: Total, PHI, Medicaid, and Medicare Per Enrollee

# 1. Setup ----------------------------------------------------------------
input_dir <- "Data/State Residence health expenditures/residence state estimates"
output_path <- "Data/State Residence health expenditures/cms_nhe_state_consolidated.csv"

# 2. Processing Function --------------------------------------------------
process_cms_csv <- function(file_path, var_name, item_regex = "Personal Health Care") {
  df <- read.csv(file_path, stringsAsFactors = FALSE)
  
  # Group == "State" is our primary filter.
  df_states <- df[df$Group == "State", ]
  
  # Filter for the relevant Item
  df_states <- df_states[grep(item_regex, df_states$Item, ignore.case = TRUE), ]
  
  # In case there are sub-items, we take the one that is the most aggregate 
  # (usually the first one, or the one that just says "... / Personal Health Care ($)")
  if (nrow(df_states) > 51) {
    df_states <- df_states[1:51, ]
  }
  
  # Reshape from Wide to Long
  year_cols <- grep("^Y[0-9]{4}", names(df_states), value = TRUE)
  
  long_df <- reshape(df_states, 
                     varying = year_cols, 
                     v.names = "Value", 
                     timevar = "Year", 
                     times = as.integer(gsub("Y", "", year_cols)), 
                     direction = "long")
  
  # Standardize State Column Name
  st_col <- names(long_df)[grep("State_Name", names(long_df), ignore.case = TRUE)]
  
  long_df <- long_df[, c(st_col, "Year", "Value")]
  names(long_df) <- c("State", "Year", var_name)
  
  return(long_df)
}

# 3. Execution ------------------------------------------------------------
cat("Processing CMS Health Expenditure data (Total, PHI, Medicaid, Medicare)...\n")

# Total Per Capita Spending
df_total <- process_cms_csv(file.path(input_dir, "US_PER_CAPITA20.CSV"), "Total_Per_Capita_Health_Exp")

# Private Health Insurance (PHI) Per Enrollee
df_phi <- process_cms_csv(file.path(input_dir, "PHI_PER_ENROLLEE20.CSV"), "PHI_Per_Enrollee_Health_Exp")

# Medicaid Per Enrollee
df_medicaid <- process_cms_csv(file.path(input_dir, "MEDICAID_PER_ENROLLEE20.CSV"), "Medicaid_Per_Enrollee_Health_Exp")

# Medicare Per Enrollee
df_medicare <- process_cms_csv(file.path(input_dir, "MEDICARE_PER_ENROLLEE20.CSV"), "Medicare_Per_Enrollee_Health_Exp")

# Merge all
final_cms <- Reduce(function(x, y) merge(x, y, by = c("State", "Year"), all = TRUE), 
                    list(df_total, df_phi, df_medicaid, df_medicare))

# Filter for 1996-2020
final_cms <- final_cms[final_cms$Year >= 1996 & final_cms$Year <= 2020, ]

# Write output
write.csv(final_cms, output_path, row.names = FALSE)

cat("\nSuccess! Expanded CMS data consolidated to:", output_path, "\n")
print(head(final_cms))
cat("Total Records:", nrow(final_cms), "\n")
