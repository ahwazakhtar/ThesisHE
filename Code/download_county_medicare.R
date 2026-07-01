# Download the CMS Medicare Geographic Variation county Public Use File for the
# mechanism track (mechanism_channels_20260625, Phase 1).
#
# PURPOSE -------------------------------------------------------------------
# The morbidity / healthcare-utilization channel (Deryugina et al. 2019; Barreca
# et al. 2016; IJPH 2025) links climate/pollution shocks to health-cost outcomes
# measured DIRECTLY in administrative data, with no farm-income intermediary. County
# Medicare per-capita spending and utilization (ED visits, inpatient stays,
# readmissions) give us that outcome to test whether shocks raise realized medical
# costs -- a channel that survives in low-agriculture counties.
#
# SOURCE (verified 2026-07-01, keyless) -------------------------------------
#   Dataset: "Medicare Geographic Variation - by National, State & County" (CMS DKAN).
#   Single multi-year CSV covering 2014-2024 (National/State/County rows stacked).
#   Coverage caveat: this PUF STARTS AT 2014 -- 2011-2013 are NOT available in a
#   schema-compatible form, so the Medicare channel is tested on 2014-2023 only.
#
# ROBUST URL RESOLUTION -----------------------------------------------------
#   The direct file path embeds a dated folder (e.g. /sites/default/files/2026-04/...)
#   that changes on every annual refresh. We therefore resolve the CURRENT downloadURL
#   from the authoritative CMS catalog https://data.cms.gov/data.json (parse the
#   dataset whose title matches, take the CSV distribution). A hardcoded fallback URL
#   (verified live 2026-07-01) is used only if catalog resolution fails.
#
# OUTPUT: Data/County_Health_Spending/medicare_geo_variation_2014_2024.csv

library(jsonlite)
library(httr)

dir.create("Data/County_Health_Spending", showWarnings = FALSE, recursive = TRUE)

DATASET_TITLE <- "Medicare Geographic Variation - by National, State & County"
FALLBACK_URL  <- paste0(
  "https://data.cms.gov/sites/default/files/2026-04/",
  "cc600d1e-d475-4b0e-80dc-1f64c01ca68c/",
  "2014-2024%20Original%20Medicare%20Geographic%20Variation%20Public%20Use%20File.csv"
)

resolve_csv_url <- function() {
  cat("Resolving current CSV URL from CMS data.json catalog...\n")
  cat_url <- "https://data.cms.gov/data.json"
  res <- tryCatch({
    dj <- fromJSON(cat_url, simplifyVector = FALSE)
    ds <- Filter(function(d) isTRUE(d$title == DATASET_TITLE), dj$dataset)
    if (length(ds) == 0) stop("dataset title not found in catalog")
    dists <- ds[[1]]$distribution
    # pick the CSV distribution with a downloadURL ending in .csv
    urls <- vapply(dists, function(x) {
      u <- x$downloadURL
      if (is.null(u)) return(NA_character_)
      fmt <- tolower(paste0(x$format, x$mediaType))
      if (grepl("csv", fmt) || grepl("\\.csv", tolower(u))) u else NA_character_
    }, character(1))
    urls <- urls[!is.na(urls)]
    if (length(urls) == 0) stop("no CSV distribution found")
    urls[[1]]
  }, error = function(e) { cat("  catalog resolution failed:", conditionMessage(e), "\n"); NA_character_ })
  if (is.na(res)) { cat("  falling back to hardcoded verified URL.\n"); return(FALLBACK_URL) }
  cat("  resolved:", res, "\n"); res
}

csv_url <- resolve_csv_url()
dest    <- "Data/County_Health_Spending/medicare_geo_variation_2014_2024.csv"

cat("Downloading CMS Medicare Geographic Variation PUF (large file)...\n")
resp <- GET(csv_url, write_disk(dest, overwrite = TRUE), config(followlocation = TRUE),
            timeout(600))
if (http_error(resp)) stop("CMS download failed: HTTP ", status_code(resp))
cat("  Saved:", dest, "(", round(file.info(dest)$size / 1e6, 1), "MB )\n")
cat("\nDone. Raw Medicare PUF in Data/County_Health_Spending/\n")
