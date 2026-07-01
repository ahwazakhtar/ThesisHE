# Download DOE LEAD (Low-Income Energy Affordability Data) 2022 county files for the
# mechanism track (mechanism_channels_20260625, Phase 1).
#
# PURPOSE -------------------------------------------------------------------
# The energy-burden / household-distress channel (Doremus et al. 2022; the Barreca
# et al. 2016 AC-adaptation micro-foundation) is distributional: extreme temperatures
# raise heating/cooling costs and low-income households cut necessities to pay energy
# bills. County average energy burden (energy cost as % of income) -- overall and for
# low-income households -- gives the structural measure of that channel, and maps
# directly to the thesis's high-SVI amplification.
#
# SOURCE (verified 2026-07-01, keyless) -------------------------------------
#   OEDI/NREL LEAD 2022 update, per-state ZIPs:
#     https://data.openei.org/files/6219/{ST}-2022-LEAD-data.zip   ({ST}=USPS code, hyphens)
#   Each ZIP bundles tract- and county-level CSVs for 4 income metrics (AMI/FPL/SMI/LLSI).
#   We keep ONLY the county-level AMI file per state (small ~0.7MB) and discard the ZIP
#   (~18-150MB) to save disk. County file has FIP (5-digit), UNITS (household weight),
#   and the weighted sums HINCP*UNITS / ELEP*UNITS / GASP*UNITS / FULP*UNITS plus their
#   "... UNITS" denominators; energy burden is DERIVED downstream (not a shipped column).
#
# CAVEAT: LEAD is a single cross-sectional 2022 vintage (modeled from ACS 5-year PUMS +
# EIA calibration), NOT a time series. It is a TIME-INVARIANT structural moderator, like
# ag-dependence -- attach it as a fixed county attribute, do not treat as annual.
#
# OUTPUT: Data/County_Energy/raw/{ST}_AMI_Counties_2022.csv  (one per state)

log_con <- file("Analysis/mechanism/build_logs/download_county_energy.log", open = "wt")
sink(log_con, split = TRUE); sink(log_con, type = "message")
on.exit({ sink(type = "message"); sink(); close(log_con) }, add = TRUE)
cat("=== download_county_energy.R run ===\n")

library(httr)

rawdir <- "Data/County_Energy/raw"
dir.create(rawdir, showWarnings = FALSE, recursive = TRUE)

# scratch dir for the big ZIPs (session tmp, cleaned up with the job)
scratch <- Sys.getenv("CLAUDE_JOB_DIR"); if (nchar(scratch) == 0) scratch <- tempdir()
zipdir  <- file.path(scratch, "tmp", "lead_zips")
dir.create(zipdir, showWarnings = FALSE, recursive = TRUE)

states <- c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL",
            "IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE",
            "NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD",
            "TN","TX","UT","VT","VA","WA","WV","WI","WY")

base_url <- "https://data.openei.org/files/6219/"

fetch_state <- function(st) {
  dest_csv <- file.path(rawdir, paste0(st, "_AMI_Counties_2022.csv"))
  if (file.exists(dest_csv)) { cat("  [skip]", st, "(already have county file)\n"); return(TRUE) }
  zip_url  <- paste0(base_url, st, "-2022-LEAD-data.zip")
  zip_dest <- file.path(zipdir, paste0(st, "-2022-LEAD-data.zip"))
  resp <- tryCatch(GET(zip_url, write_disk(zip_dest, overwrite = TRUE),
                       config(followlocation = TRUE), timeout(600)),
                   error = function(e) { cat("  [ERR]", st, conditionMessage(e), "\n"); NULL })
  if (is.null(resp) || http_error(resp)) { cat("  [FAIL]", st, "\n"); return(FALSE) }
  members <- tryCatch(unzip(zip_dest, list = TRUE), error = function(e) NULL)
  if (is.null(members)) { cat("  [BADZIP]", st, "\n"); file.remove(zip_dest); return(FALSE) }
  county_ami <- members$Name[grepl("Count", members$Name, ignore.case = TRUE) &
                             grepl("AMI",   members$Name, ignore.case = TRUE)]
  if (length(county_ami) == 0) { cat("  [NOFILE]", st, "\n"); file.remove(zip_dest); return(FALSE) }
  unzip(zip_dest, files = county_ami[1], exdir = zipdir, junkpaths = TRUE)
  extracted <- file.path(zipdir, basename(county_ami[1]))
  file.copy(extracted, dest_csv, overwrite = TRUE)
  file.remove(zip_dest); if (file.exists(extracted)) file.remove(extracted)
  cat("  [ok]  ", st, "->", basename(dest_csv),
      "(", round(file.info(dest_csv)$size/1e3, 0), "KB )\n")
  TRUE
}

cat("Downloading LEAD 2022 per-state ZIPs, extracting county AMI files...\n")
ok <- vapply(states, fetch_state, logical(1))
cat("\nDone.", sum(ok), "of", length(states), "states saved to", rawdir, "\n")
