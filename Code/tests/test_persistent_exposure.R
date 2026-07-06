# Tests for exposure_cohorts.R / run_persistent_exposure.R (Persistence Phase 2)
# Run: Rscript Code/tests/test_persistent_exposure.R

suppressPackageStartupMessages(library(testthat))
source("Code/exposure_cohorts.R")

# ---------------------------------------------------------------------------
# Cohort cut-points: the four bands partition event counts exactly as specified.
test_that("assign_exposure_cohort maps event counts to the right bands", {
  got <- as.character(assign_exposure_cohort(c(0, 1, 4, 5, 9, 10, 13)))
  expect_equal(got, c("Never", "Rarely", "Rarely",
                      "Frequently", "Frequently", "Always", "Always"))
})

# ---------------------------------------------------------------------------
# Boundary cases: 4/5 (Rarely/Frequently) and 9/10 (Frequently/Always).
test_that("band boundaries fall on the documented thresholds", {
  expect_equal(as.character(assign_exposure_cohort(4)),  "Rarely")
  expect_equal(as.character(assign_exposure_cohort(5)),  "Frequently")
  expect_equal(as.character(assign_exposure_cohort(9)),  "Frequently")
  expect_equal(as.character(assign_exposure_cohort(10)), "Always")
})

# ---------------------------------------------------------------------------
# Result is an ordered-able factor with a fixed, stable level set.
test_that("cohort factor has the expected levels in order", {
  f <- assign_exposure_cohort(c(0, 5, 12))
  expect_equal(levels(f), c("Never", "Rarely", "Frequently", "Always"))
})

# ---------------------------------------------------------------------------
# Every nonnegative count <= 13 lands in exactly one cohort (no NA gaps).
test_that("the four cohorts partition all valid event counts", {
  all_counts <- 0:13
  f <- assign_exposure_cohort(all_counts)
  expect_false(any(is.na(f)))
  expect_setequal(unique(as.character(f)),
                  c("Never", "Rarely", "Frequently", "Always"))
})

# ---------------------------------------------------------------------------
# Custom cut-points are honoured.
test_that("custom thresholds reclassify counts", {
  # With always_min = 12, a count of 10 is no longer Always.
  got <- as.character(assign_exposure_cohort(10, always_min = 12,
                                             frequently_min = 5, rarely_min = 1))
  expect_equal(got, "Frequently")
})

# ---------------------------------------------------------------------------
# Integration: the inventory output, once produced, is well-formed.
test_that("persistent_exposure_inventory.csv is well-formed", {
  path <- "Analysis/persistent_exposure/persistent_exposure_inventory.csv"
  skip_if_not(file.exists(path),
              "inventory missing; run run_persistent_exposure.R first")
  inv <- read.csv(path, stringsAsFactors = FALSE)

  expect_true(all(c("fips_code", "shock", "n_events", "n_years_obs",
                    "cohort") %in% names(inv)))
  # Cohorts are exactly the four labels.
  expect_setequal(unique(inv$cohort),
                  c("Never", "Rarely", "Frequently", "Always"))
  # One row per county x shock (no duplicates).
  expect_equal(anyDuplicated(inv[, c("fips_code", "shock")]), 0L)
  # n_events never exceeds observed years.
  expect_true(all(inv$n_events <= inv$n_years_obs))
  # Cohort label is consistent with the event count.
  expect_equal(as.character(assign_exposure_cohort(inv$n_events)), inv$cohort)
})

cat("\nAll persistent exposure tests completed.\n")
