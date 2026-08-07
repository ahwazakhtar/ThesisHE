# Download the Census 2023 county adjacency file for the spatial spillover analysis
# (advisor_feedback_20260807, Task 1.1).
#
# PURPOSE -------------------------------------------------------------------
# The SUTVA/spillover caveat (results_interpretation_guide.md §7) has never been
# estimated. Neighbor-shock exposure (share of adjacent counties in shock; neighbor
# mean PDSI) requires the county adjacency graph. This file is the Census Bureau's
# canonical adjacency list for all US counties and county-equivalents.
#
# SOURCE (verified 2026-08-07, keyless) --------------------------------------
#   https://www2.census.gov/geo/docs/reference/county_adjacency/county_adjacency2023.txt
#   Pipe-delimited, header row: County Name|County GEOID|Neighbor Name|Neighbor GEOID.
#   Lists self-pairs and both directions of every adjacency (~1.1 MB).
#
# OUTPUT: Data/Geo/county_adjacency2023.txt
# R 4.5.2.

source("Code/pipeline_utils.R")
close_log <- open_build_log("advisor_robustness", "download_county_adjacency")
on.exit(close_log(), add = TRUE)

url  <- "https://www2.census.gov/geo/docs/reference/county_adjacency/county_adjacency2023.txt"
dest <- "Data/Geo/county_adjacency2023.txt"
dir.create(dirname(dest), showWarnings = FALSE, recursive = TRUE)

if (file.exists(dest) && file.size(dest) > 1e6) {
  cat("[skip] already downloaded:", dest, "(", file.size(dest), "bytes )\n")
} else {
  download.file(url, dest, mode = "wb", quiet = TRUE)
  cat("Downloaded", dest, "(", file.size(dest), "bytes )\n")
}

# Validation: parseable, symmetric, plausible county count.
source("Code/spillover_utils.R")
adj <- parse_county_adjacency(dest)
n_counties <- length(unique(adj$fips))
cat("Directed edges (self-pairs removed):", nrow(adj), "\n")
cat("Unique counties/county-equivalents :", n_counties, "\n")
stopifnot(nrow(adj) > 15000, n_counties > 3100)
cat("OK: adjacency file downloaded and validated.\n")
