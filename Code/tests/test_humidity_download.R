# Tests for download_prism_humidity.R (Committee Feedback Phase 4)
# Run: Rscript Code/tests/test_humidity_download.R

suppressPackageStartupMessages(library(testthat))

source("Code/download_prism_humidity.R")

# ---------------------------------------------------------------------------
# Skip-existing logic must work WITHOUT touching the network: a year whose grid
# package is already unzipped (a .bil present) is reported as skipped.
test_that("existing unzipped grids are skipped (no network access)", {
  tmp <- file.path(tempdir(), paste0("prism_test_", as.integer(Sys.time())))
  dir.create(file.path(tmp, "2099"), recursive = TRUE, showWarnings = FALSE)
  # Stub an unzipped grid for year 2099.
  writeLines("stub", file.path(tmp, "2099", "prism_tdmean_us_25m_2099.bil"))

  res <- run_download_prism_humidity(list(
    years = 2099, out_dir = tmp, sleep_secs = 0
  ))

  expect_equal(length(res$downloaded), 0)
  expect_equal(length(res$skipped), 1)
  expect_equal(length(res$failed), 0)
  unlink(tmp, recursive = TRUE)
})

# ---------------------------------------------------------------------------
# The function returns a well-formed manifest (the download "contract").
test_that("download function returns the expected manifest fields", {
  tmp <- file.path(tempdir(), paste0("prism_test2_", as.integer(Sys.time())))
  dir.create(file.path(tmp, "2098"), recursive = TRUE, showWarnings = FALSE)
  writeLines("stub", file.path(tmp, "2098", "prism_tdmean_us_25m_2098.bil"))

  res <- run_download_prism_humidity(list(years = 2098, out_dir = tmp, sleep_secs = 0))
  expect_true(all(c("out_dir", "years", "downloaded", "skipped", "failed") %in% names(res)))
  expect_equal(res$out_dir, tmp)
  unlink(tmp, recursive = TRUE)
})

# ---------------------------------------------------------------------------
# Integration: real downloaded grids have the expected file shape and year
# coverage. Skips cleanly if the acquisition step has not been run.
test_that("downloaded PRISM grids have correct file shape and year coverage", {
  prism_dir <- "Data/Climate_Data/State level/PRISM_tdmean"
  skip_if_not(dir.exists(prism_dir),
              "PRISM_tdmean dir missing; run download_prism_humidity.R first")

  year_dirs <- list.dirs(prism_dir, recursive = FALSE)
  years <- suppressWarnings(as.integer(basename(year_dirs)))
  year_dirs <- year_dirs[!is.na(years)]; years <- years[!is.na(years)]
  skip_if(length(years) == 0, "No year directories present yet")

  # Year coverage: contiguous and within the documented PRISM annual range.
  expect_true(all(years >= 1895))
  expect_equal(sort(years), seq(min(years), max(years)))

  # File shape: each year package has exactly one .bil raster plus a .hdr header.
  for (d in year_dirs) {
    bil <- list.files(d, pattern = "\\.bil$", ignore.case = TRUE)
    hdr <- list.files(d, pattern = "\\.hdr$", ignore.case = TRUE)
    expect_equal(length(bil), 1, info = paste("one .bil expected in", d))
    expect_gte(length(hdr), 1)
  }
})

cat("All PRISM humidity download tests completed.\n")
