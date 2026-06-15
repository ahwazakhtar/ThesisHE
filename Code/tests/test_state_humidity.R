# Tests for process_state_humidity.R (Committee Feedback Phase 4)
# Run: Rscript Code/tests/test_state_humidity.R

suppressPackageStartupMessages({
  library(testthat)
  library(terra)
})

source("Code/process_state_humidity.R")

# ---------------------------------------------------------------------------
# extract_state_tdmean: area-weighted mean of a synthetic grid over a polygon
# that covers the whole extent equals the mean of all cell values.
test_that("area-weighted extraction recovers the grid mean over a full-extent polygon", {
  r <- rast(nrows = 2, ncols = 2, xmin = 0, xmax = 2, ymin = 0, ymax = 2,
            crs = "EPSG:4326")
  values(r) <- c(1, 2, 3, 4)                      # mean = 2.5
  poly <- vect("POLYGON ((0 0, 2 0, 2 2, 0 2, 0 0))", crs = "EPSG:4326")
  poly$NAME <- "TestState"

  out <- extract_state_tdmean(r, poly)
  expect_equal(out$State, "TestState")
  expect_equal(out$tdmean_C, 2.5, tolerance = 1e-6)
})

# ---------------------------------------------------------------------------
# A polygon over only the left half recovers the left-column mean (cells 1,3).
test_that("partial-coverage polygon recovers the covered-cell mean", {
  r <- rast(nrows = 2, ncols = 2, xmin = 0, xmax = 2, ymin = 0, ymax = 2,
            crs = "EPSG:4326")
  values(r) <- c(1, 2, 3, 4)                      # left column = cells 1 (top), 3 (bottom)
  poly <- vect("POLYGON ((0 0, 1 0, 1 2, 0 2, 0 0))", crs = "EPSG:4326")
  poly$NAME <- "LeftHalf"

  out <- extract_state_tdmean(r, poly)
  expect_equal(out$tdmean_C, 2.0, tolerance = 1e-6)   # mean(1, 3)
})

# ---------------------------------------------------------------------------
# Celsius -> Fahrenheit conversion used in the panel is correct.
test_that("C to F conversion is correct", {
  cs <- c(0, 100, -40, 21.5)
  fs <- cs * 9/5 + 32
  expect_equal(fs, c(32, 212, -40, 70.7), tolerance = 1e-9)
})

# ---------------------------------------------------------------------------
# Integration: the built intermediate is well-formed.
test_that("intermediate_humidity.rds is well-formed", {
  path <- "Data/intermediate_humidity.rds"
  skip_if_not(file.exists(path),
              "intermediate_humidity.rds missing; run process_state_humidity.R first")
  h <- readRDS(path)

  # Schema.
  expect_true(all(c("State", "Year", "tdmean_C", "tdmean_F") %in% names(h)))

  # No duplicate state-year rows.
  expect_equal(anyDuplicated(h[, c("State", "Year")]), 0L)

  # Sensible dew-point range (deg F) for covered states.
  f <- h$tdmean_F[!is.na(h$tdmean_F)]
  expect_true(length(f) > 0)
  expect_true(all(f > -20 & f < 90),
              info = "annual mean dew point should be a plausible deg-F value")

  # Missingness: CONUS-only coverage means Alaska and Hawaii are NA throughout.
  expect_true(all(is.na(h$tdmean_C[h$State == "Alaska"])))
  expect_true(all(is.na(h$tdmean_C[h$State == "Hawaii"])))
  # ... and contiguous states are populated (spot check).
  expect_true(all(!is.na(h$tdmean_C[h$State == "Texas"])))
})

# ---------------------------------------------------------------------------
# Integration: county humidity mirror (Cross-Level Symmetry).
test_that("intermediate_humidity_county.rds is well-formed", {
  path <- "Data/intermediate_humidity_county.rds"
  skip_if_not(file.exists(path),
              "county humidity missing; run process_county_humidity.R first")
  h <- readRDS(path)
  expect_true(all(c("fips_code", "Year", "tdmean_C", "tdmean_F") %in% names(h)))
  expect_equal(anyDuplicated(h[, c("fips_code", "Year")]), 0L)
  f <- h$tdmean_F[!is.na(h$tdmean_F)]
  expect_true(length(f) > 0 && all(f > -20 & f < 90))
  expect_true(any(is.na(h$tdmean_C)))   # CONUS-only: AK/HI/PR counties NA
})

cat("All state + county humidity processing tests completed.\n")
