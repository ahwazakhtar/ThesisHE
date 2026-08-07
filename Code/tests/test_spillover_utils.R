# Tests for spillover_utils.R (advisor_feedback_20260807 — Task 1.1 spatial spillovers)
# Run: Rscript Code/tests/test_spillover_utils.R

suppressPackageStartupMessages({
  library(testthat)
})
source("Code/spillover_utils.R")

# --- Fixture: a tiny adjacency file in the Census 2023 pipe-delimited format ---
# Counties: 01001 ~ 01002, 01001 ~ 06037; 01002 and 06037 are NOT adjacent.
# The raw Census file lists self-pairs and both directions of each pair.
write_adjacency_fixture <- function() {
  path <- tempfile(fileext = ".txt")
  lines <- c(
    "County Name|County GEOID|Neighbor Name|Neighbor GEOID",
    "Autauga County, AL|01001|Autauga County, AL|01001",
    "Autauga County, AL|01001|Baldwin County, AL|01002",
    "Autauga County, AL|01001|Los Angeles County, CA|06037",
    "Baldwin County, AL|01002|Baldwin County, AL|01002",
    "Baldwin County, AL|01002|Autauga County, AL|01001",
    "Los Angeles County, CA|06037|Los Angeles County, CA|06037",
    "Los Angeles County, CA|06037|Autauga County, AL|01001"
  )
  writeLines(lines, path)
  path
}

make_panel <- function() {
  # 3 counties x 2 years; shock is binary, pdsi-like var is continuous
  data.frame(
    fips_code = rep(c("01001", "01002", "06037"), each = 2),
    Year      = rep(2011:2012, times = 3),
    shock     = c(1, 0,   0, 1,   1, 1),
    pdsi      = c(-4, 1,  2, -2,  0, 3),
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
test_that("parse_county_adjacency drops self-pairs, keeps both directions, pads to 5 chars", {
  adj <- parse_county_adjacency(write_adjacency_fixture())
  expect_true(all(c("fips", "neighbor_fips") %in% names(adj)))
  expect_true(all(nchar(adj$fips) == 5))
  expect_true(all(nchar(adj$neighbor_fips) == 5))
  expect_false(any(adj$fips == adj$neighbor_fips))
  # symmetry: every A->B has a B->A
  key_fwd <- paste(adj$fips, adj$neighbor_fips)
  key_rev <- paste(adj$neighbor_fips, adj$fips)
  expect_true(all(key_fwd %in% key_rev))
  # 01001 has two neighbors; the others one each
  expect_equal(sum(adj$fips == "01001"), 2)
  expect_equal(sum(adj$fips == "01002"), 1)
  expect_equal(sum(adj$fips == "06037"), 1)
})

# ---------------------------------------------------------------------------
test_that("neighbor exposure is the mean over adjacent counties, own county excluded", {
  adj <- parse_county_adjacency(write_adjacency_fixture())
  d <- build_neighbor_exposure(make_panel(), adj, "shock", out_var = "Nbr_shock")
  # 01001's neighbors are 01002 and 06037: 2011 mean(0,1)=0.5; 2012 mean(1,1)=1
  expect_equal(d$Nbr_shock[d$fips_code == "01001" & d$Year == 2011], 0.5)
  expect_equal(d$Nbr_shock[d$fips_code == "01001" & d$Year == 2012], 1.0)
  # 01002's only neighbor is 01001: exposure = 01001's own value (1 then 0)
  expect_equal(d$Nbr_shock[d$fips_code == "01002" & d$Year == 2011], 1)
  expect_equal(d$Nbr_shock[d$fips_code == "01002" & d$Year == 2012], 0)
  # own value never leaks in: 01002 in 2012 has shock=1 but exposure=0
})

# ---------------------------------------------------------------------------
test_that("binary shock exposure stays in [0,1]; continuous var reproduces known means", {
  adj <- parse_county_adjacency(write_adjacency_fixture())
  d <- build_neighbor_exposure(make_panel(), adj, "shock", out_var = "Nbr_shock")
  expect_true(all(d$Nbr_shock >= 0 & d$Nbr_shock <= 1, na.rm = TRUE))
  d2 <- build_neighbor_exposure(make_panel(), adj, "pdsi", out_var = "Nbr_pdsi")
  # 01001 2011: mean(2, 0) = 1; 2012: mean(-2, 3) = 0.5
  expect_equal(d2$Nbr_pdsi[d2$fips_code == "01001" & d2$Year == 2011], 1)
  expect_equal(d2$Nbr_pdsi[d2$fips_code == "01001" & d2$Year == 2012], 0.5)
})

# ---------------------------------------------------------------------------
test_that("missing neighbor-years average over observed neighbors; zero observed -> NA", {
  adj <- parse_county_adjacency(write_adjacency_fixture())
  p <- make_panel()
  p$shock[p$fips_code == "06037" & p$Year == 2011] <- NA
  d <- build_neighbor_exposure(p, adj, "shock", out_var = "Nbr_shock")
  # 01001 2011: only 01002 observed (0) -> 0, count 1
  expect_equal(d$Nbr_shock[d$fips_code == "01001" & d$Year == 2011], 0)
  expect_equal(d$Nbr_shock_n[d$fips_code == "01001" & d$Year == 2011], 1)
  # drop 01001 entirely from the panel: 01002 has no observed neighbor -> NA, count 0
  p2 <- make_panel()
  p2 <- p2[p2$fips_code != "01001", ]
  d2 <- build_neighbor_exposure(p2, adj, "shock", out_var = "Nbr_shock")
  expect_true(all(is.na(d2$Nbr_shock[d2$fips_code == "01002"])))
  expect_true(all(d2$Nbr_shock_n[d2$fips_code == "01002"] == 0))
})

# ---------------------------------------------------------------------------
test_that("panel shape is preserved: same rows, unique on fips_code x Year", {
  adj <- parse_county_adjacency(write_adjacency_fixture())
  p <- make_panel()
  d <- build_neighbor_exposure(p, adj, "shock", out_var = "Nbr_shock")
  expect_equal(nrow(d), nrow(p))
  expect_equal(anyDuplicated(d[, c("fips_code", "Year")]), 0)
  # original columns untouched
  expect_equal(d$shock, p$shock)
})

# ---------------------------------------------------------------------------
test_that("row order of the input panel does not change per-county results", {
  adj <- parse_county_adjacency(write_adjacency_fixture())
  p <- make_panel()
  set.seed(42)
  p_shuf <- p[sample(nrow(p)), ]
  d1 <- build_neighbor_exposure(p, adj, "shock", out_var = "Nbr_shock")
  d2 <- build_neighbor_exposure(p_shuf, adj, "shock", out_var = "Nbr_shock")
  key1 <- paste(d1$fips_code, d1$Year)
  key2 <- paste(d2$fips_code, d2$Year)
  expect_equal(d2$Nbr_shock[match(key1, key2)], d1$Nbr_shock)
})

# ---------------------------------------------------------------------------
test_that("lag of neighbor exposure equals neighbor exposure of lagged var (static adjacency)", {
  adj <- parse_county_adjacency(write_adjacency_fixture())
  p <- make_panel()
  # within-county lag of pdsi
  p <- p[order(p$fips_code, p$Year), ]
  p$pdsi_lag1 <- ave(p$pdsi, p$fips_code, FUN = function(x) c(NA, head(x, -1)))
  d <- build_neighbor_exposure(p, adj, "pdsi", out_var = "Nbr_pdsi")
  d <- build_neighbor_exposure(d, adj, "pdsi_lag1", out_var = "Nbr_pdsi_lag1")
  d <- d[order(d$fips_code, d$Year), ]
  lag_of_nbr <- ave(d$Nbr_pdsi, d$fips_code, FUN = function(x) c(NA, head(x, -1)))
  expect_equal(d$Nbr_pdsi_lag1, lag_of_nbr)
})

cat("\nAll spillover_utils tests defined; testthat reported above.\n")
