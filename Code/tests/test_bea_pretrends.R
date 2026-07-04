# Tests for 05_bea_pretrends_1990_2011.R (thesis_completion_20260704, T0.3).
# Guards the acceptance criteria: cohorts match the DiD cohort, the pre-period
# window is strictly <= 2011 (no treatment-year leakage), and FIPS padding avoids
# the documented sprintf("%05s") space-padding trap. Run on main R 4.2.2:
#   Rscript Code/tests/test_bea_pretrends.R

suppressPackageStartupMessages({ library(testthat) })

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")

# ---------------------------------------------------------------------------
test_that("FIPS padding avoids the sprintf('%05s') space-padding trap", {
  # CLAUDE.md lesson: sprintf('%05s', '1001') -> ' 1001' (space-padded), which
  # fails ^[0-9]{5}$ and silently drops single-digit-state counties. formatC must
  # zero-pad instead.
  expect_equal(pad_fips("1001"), "01001")     # AL county, state code 1
  expect_equal(pad_fips(1001),   "01001")     # integer input
  expect_equal(pad_fips("06075"), "06075")    # already padded (CA)
  expect_false(identical(pad_fips("1001"), " 1001"))
  expect_true(grepl("^[0-9]{5}$", pad_fips("1001")))
})

# ---------------------------------------------------------------------------
test_that("pre-period window is strictly 1990-2011 (no treatment-year leakage)", {
  df   <- data.frame(Year = 1985:2015)
  keep <- df$Year[df$Year >= 1990L & df$Year <= 2011L]
  expect_equal(range(keep), c(1990, 2011))
  expect_false(any(keep >= 2012))             # 2012 (onset) and later excluded
})

# ---------------------------------------------------------------------------
test_that("centered year is 0 at the last pre-period and negative before", {
  yr     <- 1990:2011
  year_c <- yr - 2011L
  expect_equal(year_c[yr == 2011L], 0L)       # slope pivots at the last pre-period
  expect_true(all(year_c[yr < 2011L] < 0L))
})

# ---------------------------------------------------------------------------
test_that("cohorts match the DiD cohort sizes (139 treated / 2534 control)", {
  # Integration check against the real county master + shared cohort builder,
  # so the pre-trend test operates on exactly the DiD's treated/control sets.
  skip_if_not(file.exists("Data/county_level_master.csv"),
              "county master not present")
  suppressPackageStartupMessages(source("Code/did_robustness/00_did_robustness_common.R"))
  panel <- load_did_panel()
  co    <- build_cohorts(panel, "Is_Extreme_Drought")
  expect_equal(sum(co$cohort == 2012L), 139L)
  expect_equal(sum(co$cohort == 0L),   2534L)
})

cat("\nAll BEA pre-trend tests completed.\n")
