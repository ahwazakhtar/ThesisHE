# Download IRS SOI county-to-county migration flat files for the mechanism track
# (mechanism_channels_20260625, Phase 1).
#
# PURPOSE -------------------------------------------------------------------
# The migration / sectoral-reallocation channel is an ADJUSTMENT MARGIN and an
# identification caveat: how much of the county-level income/employment "scarring"
# (h=2) reflects who LEAVES a shocked county vs. who stays and earns less? County
# net-migration flows let us bound population selection as an alternative to a
# same-population income effect.
#
# SOURCE (verified 2026-07-01, keyless plain HTTPS) -------------------------
#   https://www.irs.gov/pub/irs-soi/countyinflow<TOK>.csv
#   https://www.irs.gov/pub/irs-soi/countyoutflow<TOK>.csv
#   <TOK> = last two digits of year1 + last two digits of year2. Tokens 1112..2021
#   cover tax-year pairs 2011-2012 .. 2020-2021. The current CSV convention with the
#   consistent (primary+secondary+dependent TIN matching) methodology begins at 1112,
#   which is our clean panel start.
#
# CSV SCHEMA (identical fields, mirrored order for in/out) -------------------
#   inflow:  y2_statefips,y2_countyfips (fixed = destination), y1_statefips,y1_countyfips
#            (varying = origin), y1_state,y1_countyname, n1,n2,agi
#   outflow: y1_* fixed = origin, y2_* varying = destination, y2_state,y2_countyname, n1,n2,agi
#   n1 = returns (~households), n2 = individuals (exemptions), agi = AGI in $THOUSANDS.
#   Suppressed cells = -1. Per-county summary rows use special state FIPS:
#     96-000 = Total migration (US + foreign); 97-000 = Total migration (US);
#     97-001 = same-state; 97-003 = different-state; 98-000 = foreign.
#   Non-migrants = the row where origin county == destination county.
#   (2018-19+ dropped whole-STATE rows and raised the suppression threshold to 20, but
#    the per-county 96/97/98 summary rows remain -- so total-US in/out is available all years.)
#
# OUTPUT: raw CSVs saved verbatim under Data/County_Migration/; parsed downstream by
#         process_county_migration.R.

library(httr)

dir.create("Data/County_Migration", showWarnings = FALSE, recursive = TRUE)

# Tokens for tax-year pairs 2011-2012 .. 2020-2021
tokens <- c("1112","1213","1314","1415","1516","1617","1718","1819","1920","2021")

base_url <- "https://www.irs.gov/pub/irs-soi/"

fetch_one <- function(direction, tok) {
  fname <- paste0("county", direction, tok, ".csv")
  dest  <- file.path("Data/County_Migration", fname)
  url   <- paste0(base_url, fname)
  resp  <- GET(url, write_disk(dest, overwrite = TRUE), config(followlocation = TRUE))
  if (http_error(resp)) {
    warning("IRS migration download failed: ", fname, " HTTP ", status_code(resp))
    return(FALSE)
  }
  cat("  Saved:", fname, "(", file.info(dest)$size, "bytes )\n")
  TRUE
}

cat("Downloading IRS SOI county-to-county migration files (2011-12 .. 2020-21)...\n")
for (tok in tokens) {
  fetch_one("inflow",  tok)
  fetch_one("outflow", tok)
}
cat("\nDone. Raw migration CSVs in Data/County_Migration/\n")
