# Tests for process_county_demographics.R (Persistence Extensions — Phase 4)
# Run: Rscript Code/tests/test_demographic_mediators.R

suppressPackageStartupMessages(library(testthat))
options(demographics.test_mode = TRUE)
source("Code/process_county_demographics.R")

# Build a synthetic raw ACS row with hand-computable totals.
make_raw <- function() {
  r <- data.frame(fips_code = "01001", Year = 2021, stringsAsFactors = FALSE)
  # Tenure: 700 owners / 1000 occupied = 0.70
  r$B25003_001E <- 1000; r$B25003_002E <- 700
  # Age: total 2000; 65+ = 12 cells of 10 each = 120 -> 0.06
  r$B01001_001E <- 2000
  for (v in AGE_65PLUS_CELLS) r[[v]] <- 10
  # Mobility: total 5000; in-movers 100 + 50 + 25 = 175 -> 0.035
  r$B07001_001E <- 5000
  r$B07001_049E <- 100; r$B07001_065E <- 50; r$B07001_081E <- 25
  r
}

# ---------------------------------------------------------------------------
test_that("demographic features are computed correctly", {
  f <- compute_demographic_features(make_raw())
  expect_equal(f$Pct_Owner_Occupied, 0.70, tolerance = 1e-9)
  expect_equal(f$Pct_Age_65plus,     0.06, tolerance = 1e-9)
  expect_equal(f$In_Migration_Rate,  0.035, tolerance = 1e-9)
  expect_equal(f$fips_code, "01001")
  expect_equal(f$Year, 2021L)
})

# ---------------------------------------------------------------------------
test_that("all 12 age-65+ cells are summed (drop one -> lower share)", {
  raw <- make_raw()
  raw[[AGE_65PLUS_CELLS[1]]] <- 0      # remove 10 of the 120
  f <- compute_demographic_features(raw)
  expect_equal(f$Pct_Age_65plus, 110 / 2000, tolerance = 1e-9)
})

# ---------------------------------------------------------------------------
test_that("zero or missing denominators yield NA, not Inf", {
  raw <- make_raw()
  raw$B25003_001E <- 0          # zero occupied units
  raw$B07001_001E <- NA         # missing mobility base
  f <- compute_demographic_features(raw)
  expect_true(is.na(f$Pct_Owner_Occupied))
  expect_true(is.na(f$In_Migration_Rate))
  expect_false(is.na(f$Pct_Age_65plus))   # age base intact
})

# ---------------------------------------------------------------------------
test_that("shares are bounded in [0, 1] on the synthetic row", {
  f <- compute_demographic_features(make_raw())
  for (v in c("Pct_Owner_Occupied", "Pct_Age_65plus", "In_Migration_Rate")) {
    expect_gte(f[[v]], 0); expect_lte(f[[v]], 1)
  }
})

# ---------------------------------------------------------------------------
# Integration: the built intermediate, once produced, is well-formed.
test_that("intermediate_demographics.rds is well-formed", {
  path <- "Data/intermediate_demographics.rds"
  skip_if_not(file.exists(path),
              "intermediate missing; run download + process_county_demographics first")
  d <- readRDS(path)
  expect_true(all(c("fips_code", "Year", "In_Migration_Rate",
                    "Pct_Age_65plus", "Pct_Owner_Occupied") %in% names(d)))
  expect_equal(anyDuplicated(d[, c("fips_code", "Year")]), 0L)
  # Plausible ranges on observed values.
  ok <- d$Pct_Age_65plus[!is.na(d$Pct_Age_65plus)]
  expect_true(all(ok >= 0 & ok < 0.8))
  own <- d$Pct_Owner_Occupied[!is.na(d$Pct_Owner_Occupied)]
  expect_true(all(own >= 0 & own <= 1))
})

cat("\nAll demographic mediator tests completed.\n")
