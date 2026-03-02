library(testthat)
library(dplyr)

# Source the processing script to get is_valid_county_fips and
# run_process_county_socioeconomic. The test_mode option prevents the
# auto-run at the bottom of the script from firing.
options(socioeconomic.test_mode = TRUE)
source(here::here("Code/process_county_socioeconomic.R"), local = TRUE)
options(socioeconomic.test_mode = FALSE)

# ---------------------------------------------------------------------------
# Helper: build minimal mock CSVs in a temp directory
# ---------------------------------------------------------------------------
make_mock_files <- function(tmp_dir) {
  # BEA CAINC1 -- includes county rows + US/state aggregates to test filtering
  pcpi <- data.frame(
    fips_code = c("01001", "01001", "01003", "01003", "00000", "01000"),
    geo_name  = c("Autauga, AL", "Autauga, AL", "Baldwin, AL", "Baldwin, AL",
                  "United States", "Alabama"),
    Year      = c(2015L, 2016L, 2015L, 2016L, 2015L, 2015L),
    value     = c("45,000", "46,500", "50,000", "51,000", "55,000", "48,000"),
    NoteRef   = NA_character_
  )
  write.csv(pcpi, file.path(tmp_dir, "bea_cainc1_pcpi_raw.csv"), row.names = FALSE)

  # ACS -- 2015 only for both counties; Baldwin 2015 suppressed; 2016 absent
  acs <- data.frame(
    fips_code         = c("01001", "01003"),
    Year              = c(2015L,   2015L),
    med_hh_income_acs = c(52000,   -666666666),
    civilian_employed = c(25000,   -666666666),
    NAME              = c("Autauga County, Alabama", "Baldwin County, Alabama")
  )
  write.csv(acs, file.path(tmp_dir, "acs_socioeconomic_raw.csv"), row.names = FALSE)

  # CPI -- covers 2015 and 2016 but NOT 2014 (to test inner join)
  cpi <- data.frame(Year = c(2015L, 2016L, 2023L), CPI_Value = c(237.0, 240.0, 304.7))
  write.csv(cpi, file.path(tmp_dir, "us_cpi_annual.csv"), row.names = FALSE)

  list(
    path_pcpi   = file.path(tmp_dir, "bea_cainc1_pcpi_raw.csv"),
    path_acs    = file.path(tmp_dir, "acs_socioeconomic_raw.csv"),
    path_cpi    = file.path(tmp_dir, "us_cpi_annual.csv"),
    output_path = file.path(tmp_dir, "intermediate_socioeconomic.rds")
  )
}

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

test_that("is_valid_county_fips correctly distinguishes counties from aggregates", {
  expect_true(is_valid_county_fips("01001"))
  expect_true(is_valid_county_fips("06037"))
  expect_false(is_valid_county_fips("00000"))  # US total
  expect_false(is_valid_county_fips("01000"))  # State total
  expect_false(is_valid_county_fips("1001"))   # Too short (4 digits)
})

test_that("Output has correct columns", {
  tmp   <- tempdir()
  paths <- make_mock_files(tmp)
  run_process_county_socioeconomic(paths)
  df <- readRDS(paths$output_path)

  expect_true(all(c("fips_code", "Year", "PCPI_Real",
                     "Med_HH_Income_Real", "Civilian_Employed") %in% names(df)))
})

test_that("Aggregate FIPS (US/state totals) are excluded from output", {
  tmp   <- tempdir()
  paths <- make_mock_files(tmp)
  run_process_county_socioeconomic(paths)
  df <- readRDS(paths$output_path)

  expect_false(any(df$fips_code == "00000"))
  expect_false(any(df$fips_code == "01000"))
})

test_that("PCPI_Real is inflation-adjusted using 2023 CPI base", {
  tmp   <- tempdir()
  paths <- make_mock_files(tmp)
  run_process_county_socioeconomic(paths)
  df <- readRDS(paths$output_path)

  cpi_factor_2015 <- 304.7 / 237.0
  expected <- 45000 * cpi_factor_2015
  actual   <- df$PCPI_Real[df$fips_code == "01001" & df$Year == 2015]
  expect_equal(actual, expected, tolerance = 0.01)
})

test_that("PCPI_Real has zero NAs (inner join on CPI drops uncovered years)", {
  tmp   <- tempdir()
  paths <- make_mock_files(tmp)
  run_process_county_socioeconomic(paths)
  df <- readRDS(paths$output_path)

  expect_equal(sum(is.na(df$PCPI_Real)), 0)
})

test_that("ACS suppressed values (-666666666) become NA", {
  tmp   <- tempdir()
  paths <- make_mock_files(tmp)
  run_process_county_socioeconomic(paths)
  df <- readRDS(paths$output_path)

  # Baldwin county 2015 was suppressed in ACS
  row <- df[df$fips_code == "01003" & df$Year == 2015, ]
  expect_true(is.na(row$Med_HH_Income_Real))
  expect_true(is.na(row$Civilian_Employed))
})

test_that("ACS absence for a year yields NA, not a dropped row", {
  tmp   <- tempdir()
  paths <- make_mock_files(tmp)
  run_process_county_socioeconomic(paths)
  df <- readRDS(paths$output_path)

  # ACS mock has no 2016 data; BEA does → row should exist with NA ACS columns
  row_2016 <- df[df$fips_code == "01001" & df$Year == 2016, ]
  expect_equal(nrow(row_2016), 1)
  expect_true(is.na(row_2016$Med_HH_Income_Real))
  expect_false(is.na(row_2016$PCPI_Real))
})

test_that("Output RDS is saved to the configured path", {
  tmp   <- tempdir()
  paths <- make_mock_files(tmp)
  run_process_county_socioeconomic(paths)
  expect_true(file.exists(paths$output_path))
})
