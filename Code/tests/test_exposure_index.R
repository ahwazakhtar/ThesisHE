# Tests for the Climate–Health Exposure Index track (Phase 1: SVI acquisition).
# Run: Rscript Code/tests/test_exposure_index.R

suppressPackageStartupMessages(library(testthat))
options(svi.test_mode = TRUE)
source("Code/download_svi.R")
source("Code/process_svi.R")

# ---------------------------------------------------------------------------
test_that("SVI URL candidates follow the ATSDR path pattern", {
  u <- svi_url_candidates(2020)
  expect_true(any(grepl("Documents/Data/2020/csv/states_counties/SVI_2020_US_county.csv$", u)))
  expect_true(all(grepl("^https://svi.cdc.gov/", u)))
})

# ---------------------------------------------------------------------------
test_that("nearest_svi_vintage maps panel years to the right vintage", {
  expect_equal(nearest_svi_vintage(2011), 2014)   # before earliest -> floored
  expect_equal(nearest_svi_vintage(2013), 2014)
  expect_equal(nearest_svi_vintage(2014), 2014)
  expect_equal(nearest_svi_vintage(2017), 2016)
  expect_equal(nearest_svi_vintage(2019), 2018)
  expect_equal(nearest_svi_vintage(2021), 2020)
  expect_equal(nearest_svi_vintage(2023), 2022)
  expect_equal(nearest_svi_vintage(c(2012, 2018, 2022)), c(2014, 2018, 2022))
})

# ---------------------------------------------------------------------------
test_that("county FIPS validation rejects state/US aggregates", {
  expect_true(is_valid_county_fips("01001"))
  expect_false(is_valid_county_fips("01000"))   # state aggregate
  expect_false(is_valid_county_fips("00000"))
  expect_false(is_valid_county_fips("1001"))    # not 5 digits
})

# ---------------------------------------------------------------------------
# Integration: raw vintage files present and well-formed.
test_that("downloaded SVI vintages have the key columns", {
  dir <- "Data/SVI_Data"
  skip_if_not(dir.exists(dir), "SVI_Data missing; run download_svi.R first")
  for (yr in c(2014, 2016, 2018, 2020, 2022)) {
    f <- file.path(dir, sprintf("SVI_%d_US_county.csv", yr))
    skip_if_not(file.exists(f), paste("missing vintage", yr))
    h <- read.csv(f, nrows = 3, stringsAsFactors = FALSE)
    expect_true(all(c("FIPS", "RPL_THEMES", "RPL_THEME1", "RPL_THEME2",
                      "RPL_THEME3", "RPL_THEME4") %in% names(h)),
                info = paste("vintage", yr))
  }
})

# ---------------------------------------------------------------------------
# Integration: processed SVI panel is well-formed.
test_that("intermediate_svi.rds is well-formed", {
  path <- "Data/intermediate_svi.rds"
  skip_if_not(file.exists(path), "intermediate_svi.rds missing; run process_svi.R first")
  d <- readRDS(path)
  expect_true(all(c("fips_code", "Year", "SVI_yr", "SVI_static") %in% names(d)))
  expect_equal(anyDuplicated(d[, c("fips_code", "Year")]), 0L)
  expect_setequal(unique(d$Year), 2011:2023)
  # Percentiles in [0,1] where present.
  for (v in c("SVI_yr", "SVI_static", "SVI_T1_yr", "SVI_T4_yr")) {
    ok <- d[[v]][!is.na(d[[v]])]
    expect_true(all(ok >= 0 & ok <= 1), info = v)
  }
  # SVI_static is time-invariant within county.
  spread <- d %>% dplyr::group_by(fips_code) %>%
    dplyr::summarise(u = dplyr::n_distinct(SVI_static), .groups = "drop")
  expect_true(all(spread$u == 1))
})

# ===========================================================================
# Phase 2: exposure components
# ===========================================================================
source("Code/exposure_index.R")

# ---------------------------------------------------------------------------
test_that("person_years_exposure = population x hazard indicator", {
  expect_equal(person_years_exposure(c(1000, 2000, 500), c(1, 0, 1)), c(1000, 0, 500))
  # continuous intensity
  expect_equal(person_years_exposure(c(100, 200), c(0.5, 2)), c(50, 400))
})

test_that("person_years_exposure handles NA per the flag", {
  expect_true(is.na(person_years_exposure(1000, NA)))
  expect_equal(person_years_exposure(1000, NA, na_indicator_zero = TRUE), 0)
})

test_that("person_years_exposure is non-negative for valid inputs", {
  py <- person_years_exposure(c(0, 100, 5000), c(1, 1, 0))
  expect_true(all(py >= 0))
})

# ---------------------------------------------------------------------------
test_that("build_chei rises with both hazard and vulnerability", {
  # increasing in hazard at fixed positive vulnerability
  h <- c(0, 1, 2, 3)
  idx_h <- build_chei(h, svi = rep(0.5, 4))
  expect_true(all(diff(idx_h) > 0))
  # increasing in vulnerability at fixed positive hazard
  v <- c(0, 0.25, 0.5, 1)
  idx_v <- build_chei(hazard_z = rep(2, 4), svi = v)
  expect_true(all(diff(idx_v) > 0))
})

test_that("zero vulnerability gives a zero index", {
  expect_equal(build_chei(c(-2, 0, 3), svi = c(0, 0, 0)), c(0, 0, 0))
})

test_that("build_chei absolute variant scales by population", {
  rel <- build_chei(2, svi = 0.5)
  abs <- build_chei(2, svi = 0.5, pop = 1000)
  expect_equal(abs, rel * 1000)
})

test_that("build_chei standardisation yields mean 0 / sd 1", {
  set.seed(1)
  idx <- build_chei(rnorm(500, 1, 1), svi = runif(500), standardize = TRUE)
  expect_equal(mean(idx), 0, tolerance = 1e-9)
  expect_equal(stats::sd(idx), 1, tolerance = 1e-9)
})

cat("\nAll exposure index (Phase 1+2) tests completed.\n")
