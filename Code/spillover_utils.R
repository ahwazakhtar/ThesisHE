# spillover_utils.R — shared helpers for the spatial spillover analysis
# (advisor_feedback_20260807, Task 1.1).
#
# parse_county_adjacency(): read the Census 2023 county adjacency file
#   (pipe-delimited: County Name|County GEOID|Neighbor Name|Neighbor GEOID)
#   into a directed edge list with self-pairs removed.
# build_neighbor_exposure(): for each county-year, the mean of a variable over
#   the county's adjacent counties (own county excluded) — for a binary shock
#   this is the share of neighbors in shock; for PDSI it is neighbor mean PDSI.
#
# Base R + pad_fips() from pipeline_utils.R. Tested by
# Code/tests/test_spillover_utils.R. R 4.5.2.

source("Code/pipeline_utils.R")

parse_county_adjacency <- function(path) {
  if (!file.exists(path)) stop("parse_county_adjacency(): file not found: ", path)
  raw <- read.delim(path, sep = "|", header = TRUE, colClasses = "character",
                    check.names = FALSE, quote = "", fileEncoding = "UTF-8")
  if (ncol(raw) != 4) {
    stop("parse_county_adjacency(): expected 4 pipe-delimited columns, got ", ncol(raw))
  }
  adj <- data.frame(
    fips          = pad_fips(raw[[2]]),
    neighbor_fips = pad_fips(raw[[4]]),
    stringsAsFactors = FALSE
  )
  adj <- adj[!is.na(adj$fips) & !is.na(adj$neighbor_fips), ]
  adj <- adj[adj$fips != adj$neighbor_fips, ]          # drop self-pairs
  adj <- unique(adj)

  # The Census file lists both directions of every pair; assert that survives parsing.
  fwd <- paste(adj$fips, adj$neighbor_fips)
  rev <- paste(adj$neighbor_fips, adj$fips)
  if (!all(fwd %in% rev)) {
    stop("parse_county_adjacency(): adjacency is not symmetric after parsing — ",
         sum(!(fwd %in% rev)), " one-directional pair(s)")
  }
  adj
}

build_neighbor_exposure <- function(panel, adjacency, var,
                                    out_var = paste0("Nbr_", var),
                                    id_col = "fips_code", year_col = "Year") {
  stopifnot(all(c("fips", "neighbor_fips") %in% names(adjacency)))
  for (cn in c(id_col, year_col, var)) {
    if (!cn %in% names(panel)) stop("build_neighbor_exposure(): missing column: ", cn)
  }

  pid <- pad_fips(panel[[id_col]])
  yr  <- panel[[year_col]]
  if (anyDuplicated(paste(pid, yr)) > 0) {
    stop("build_neighbor_exposure(): panel is not unique on ", id_col, " x ", year_col)
  }

  # One row per (edge, year the neighbor is observed in the panel), carrying the
  # neighbor's value of `var`; then average within (own county, year).
  nb_vals <- data.frame(
    neighbor_fips = pid,
    .yr           = yr,
    .val          = panel[[var]],
    stringsAsFactors = FALSE
  )
  edges <- merge(adjacency, nb_vals, by = "neighbor_fips")

  grp <- paste(edges$fips, edges$.yr)
  mean_by  <- tapply(edges$.val, grp, function(v) {
    m <- mean(v, na.rm = TRUE)
    if (is.nan(m)) NA_real_ else m
  })
  count_by <- tapply(edges$.val, grp, function(v) sum(!is.na(v)))

  key <- paste(pid, yr)
  panel[[out_var]] <- as.numeric(mean_by[key])
  n <- as.integer(count_by[key])
  n[is.na(n)] <- 0L                                    # county-years with no observed neighbor
  panel[[paste0(out_var, "_n")]] <- n
  panel
}
