# R script to generate a Missing Data Summary Report
library(dplyr)
library(tidyr)

master_path <- "Data/state_level_analysis_master.csv"
df <- read.csv(master_path, stringsAsFactors = FALSE)

cat("========================================================
")
cat("MISSING DATA SUMMARY REPORT: State-Level Analysis Master
")
cat("========================================================
")
cat("Total Observations:", nrow(df), "
")
cat("Year Range:", min(df$Year), "-", max(df$Year), "

")

# 1. Overall Missingness by Variable
missing_summary <- df %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Count") %>%
  mutate(Percent_Missing = round((Missing_Count / nrow(df)) * 100, 1)) %>%
  arrange(desc(Percent_Missing))

cat("1. TOP MISSING VARIABLES (Overall):
")
print(as.data.frame(missing_summary))

# 2. Missingness by Time Period
cat("
2. MISSINGNESS BY PERIOD (Percent Missing):
")
period_summary <- df %>%
  mutate(Period = case_when(
    Year < 2000 ~ "1996-1999",
    Year < 2010 ~ "2000-2009",
    Year < 2021 ~ "2010-2020",
    TRUE ~ "2021-2025"
  )) %>%
  group_by(Period) %>%
  summarise(across(c(Emp_Contrib_Single, Avg_Deductible_Single, Total_Per_Capita_Health_Exp, Medical_Debt_Share), 
                   ~ round(mean(is.na(.)) * 100, 1)))

print(as.data.frame(period_summary))

# 3. Identfying "Zero-Data" States
cat("
3. STATES WITH SIGNIFICANT MISSING MACRO DATA:
")
state_na <- df %>%
  group_by(State) %>%
  summarise(NA_Macro = sum(is.na(Personal_Income_Per_Capita))) %>%
  filter(NA_Macro > 0)
print(as.data.frame(state_na))
