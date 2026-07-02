# Diagnostic: print hospital-panel schema so run_mechanism_provider.R uses the exact
# county-key and outcome columns. Track: mechanism_channels_20260625 (provider channel).
log_con <- file("Analysis/mechanism/build_logs/inspect_hospital_panel.log", open = "wt")
sink(log_con, split = TRUE); on.exit({ sink(); close(log_con) }, add = TRUE)
d <- readRDS("Data/intermediate_hospital_panel.rds")
cat("rows", nrow(d), "cols", ncol(d), "years", paste(range(d$Year, na.rm = TRUE), collapse = "-"), "\n")
cat("candidate county keys:\n"); print(grep("fip|county", names(d), value = TRUE, ignore.case = TRUE))
cat("shock cols:\n"); print(grep("Drought|CDD|HDD|AQI", names(d), value = TRUE))
cat("finance outcomes + moderators:\n")
print(grep("Uncomp|Margin|SafetyNet|Ownership|System|MarketConc|Medicaid|CCN|State", names(d), value = TRUE, ignore.case = TRUE))
