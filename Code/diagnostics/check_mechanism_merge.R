# Diagnostic: verify the mechanism-track intermediates merge cleanly onto the county
# master by fips_code, and report county-match rates. Track: mechanism_channels_20260625
# (Phase 1 data-gate validation). Run output logged to build_logs/.
#
# Checks each intermediate's fips_code format and coverage against the county master's
# unique counties, so Phase 2 (interaction + subsample estimation) can trust the joins.
# Energy-burden is included only if already built (its download may still be running).

log_con <- file("Analysis/mechanism/build_logs/check_mechanism_merge.log", open = "wt")
sink(log_con, split = TRUE); sink(log_con, type = "message")
on.exit({ sink(type = "message"); sink(); close(log_con) }, add = TRUE)
cat("=== check_mechanism_merge.R run ===\n")

library(dplyr)

master <- read.csv("Data/county_level_master.csv", colClasses = c(fips_code = "character"))
master$fips_code <- formatC(as.integer(master$fips_code), width = 5, flag = "0")
mfips <- unique(master$fips_code)
cat("County master:", nrow(master), "rows,", length(mfips), "unique counties,",
    paste(range(master$Year), collapse = "-"), "\n\n")

report <- function(name, path, keycol = "fips_code", is_panel = FALSE) {
  if (!file.exists(path)) { cat(sprintf("%-26s  [not built yet]\n", name)); return(invisible()) }
  d <- readRDS(path)
  d[[keycol]] <- formatC(as.integer(d[[keycol]]), width = 5, flag = "0")
  ifips <- unique(d[[keycol]])
  matched <- sum(mfips %in% ifips)
  cat(sprintf("%-26s  rows=%-6d counties=%-5d  master-counties matched=%d/%d (%.1f%%)\n",
              name, nrow(d), length(ifips), matched, length(mfips),
              100 * matched / length(mfips)))
  # a couple of master counties that failed to match (if any)
  miss <- setdiff(mfips, ifips)
  if (length(miss) > 0) cat("     unmatched master fips (first 5):", paste(head(miss, 5), collapse = ", "), "\n")
  invisible()
}

cat("Coverage of the master's counties by each intermediate:\n")
report("ag_dependence",        "Data/intermediate_ag_dependence.rds")
report("industry_composition", "Data/intermediate_industry_composition.rds", is_panel = TRUE)
report("migration",            "Data/intermediate_migration.rds",            is_panel = TRUE)
report("medicare_spending",    "Data/intermediate_medicare_spending.rds",    is_panel = TRUE)
report("energy_burden",        "Data/intermediate_energy_burden.rds")

cat("\nDone.\n")
