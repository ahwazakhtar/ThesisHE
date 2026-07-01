# Diagnostic: inspect the DOE LEAD 2022 county-file schema (single small state = DC)
# so the full aggregator (process_county_energy.R) uses the exact column names.
# Track: mechanism_channels_20260625 (Phase 1). Run output logged to build_logs/.
#
# Downloads the DC 2022 LEAD ZIP to the session tmp dir, lists its members, and prints
# the header + a couple rows of the county-level AMI file. Does NOT write any intermediate.

log_con <- file("Analysis/mechanism/build_logs/inspect_lead_dc.log", open = "wt")
sink(log_con, split = TRUE); sink(log_con, type = "message")
on.exit({ sink(type = "message"); sink(); close(log_con) }, add = TRUE)
cat("=== inspect_lead_dc.R run ===\n")

library(httr)

tmp <- Sys.getenv("CLAUDE_JOB_DIR"); if (nchar(tmp) == 0) tmp <- tempdir()
tmpdir <- file.path(tmp, "tmp", "lead_inspect")
dir.create(tmpdir, showWarnings = FALSE, recursive = TRUE)

zip_url  <- "https://data.openei.org/files/6219/DC-2022-LEAD-data.zip"
zip_dest <- file.path(tmpdir, "DC-2022-LEAD-data.zip")

cat("Downloading DC LEAD ZIP...\n")
resp <- GET(zip_url, write_disk(zip_dest, overwrite = TRUE), config(followlocation = TRUE), timeout(300))
cat("  HTTP", status_code(resp), "size", round(file.info(zip_dest)$size/1e6, 1), "MB\n")

members <- unzip(zip_dest, list = TRUE)
cat("\nZIP members:\n"); print(members[, c("Name","Length")])

# find the county-level AMI file
county_ami <- members$Name[grepl("Count", members$Name, ignore.case = TRUE) &
                            grepl("AMI",   members$Name, ignore.case = TRUE)]
cat("\nCounty AMI file:", county_ami, "\n")

unzip(zip_dest, files = county_ami, exdir = tmpdir)
df <- read.csv(file.path(tmpdir, county_ami), check.names = FALSE, nrows = 5)
cat("\nColumn names (verbatim):\n")
print(names(df))
cat("\nFirst 2 rows (transposed for readability):\n")
print(t(head(df, 2)))
