# Tests for process_hospital_panel.R  (Hospital Supply-Side Integration — Phase 1)
# Run: Rscript Code/tests/test_hospital_panel.R
#
# Two layers:
#   (1) Pure-helper unit tests on synthetic input (always run).
#   (2) Integration checks on the built panel Data/intermediate_hospital_panel.rds
#       (run only if the artifact exists; the build must be run first).

suppressPackageStartupMessages({
  library(testthat)
})
# Sourcing must NOT trigger the heavy build (guarded by sys.nframe()).
source("Code/process_hospital_panel.R")
source("Code/medicaid_expansion.R")

# ---------------------------------------------------------------------------
# (1) Pure helpers
# ---------------------------------------------------------------------------
test_that("pad_fips zero-pads integers to 5 chars (no space-padding bug)", {
  expect_equal(pad_fips(1001), "01001")     # single-digit state code
  expect_equal(pad_fips("6037"), "06037")   # CA county
  expect_equal(pad_fips(36103), "36103")
  expect_true(is.na(pad_fips(NA)))
  expect_false(grepl(" ", pad_fips(1001)))  # never pads with spaces
})

test_that("classify_ownership collapses to 3 levels with Non-Profit reference", {
  f <- classify_ownership(c("For-Profit", "Governmental", "Non-Profit", "Non-Profit"))
  expect_equal(levels(f), c("Non-Profit", "For-Profit", "Government"))
  expect_equal(as.character(f), c("For-Profit", "Government", "Non-Profit", "Non-Profit"))
})

test_that("derive_uncomp sums components but is NA only when both are missing", {
  bd <- c(10,  5, NA, NA)
  ch <- c(20, NA,  7, NA)
  expect_equal(derive_uncomp(bd, ch), c(30, 5, 7, NA))
})

test_that("uncompensated-care identity holds where both components observed", {
  bd <- c(10, 5, 0); ch <- c(20, 15, 3)
  expect_equal(derive_uncomp(bd, ch), bd + ch)
})

test_that("derive_safetynet flags the top quartile and preserves NA", {
  mix  <- c(0.05, 0.10, 0.20, 0.40, NA)
  unc  <- c(0.01, 0.02, 0.05, 0.10, 0.5)
  res  <- derive_safetynet(mix, unc, q = 0.75)
  # scores: .06,.12,.25,.50,NA -> 75th pct ~ .3125 -> only the .50 obs flagged
  expect_equal(res$flag, c(0L, 0L, 0L, 1L, NA_integer_))
  expect_true(is.na(res$flag[5]))
})

test_that("medicaid_expanded respects adoption-year thresholds", {
  expect_equal(medicaid_expanded("CA", 2013), 0L)  # CA expanded 2014
  expect_equal(medicaid_expanded("CA", 2014), 1L)
  expect_equal(medicaid_expanded("TX", 2023), 0L)  # never expanded
  expect_equal(medicaid_expanded("LA", 2015), 0L)  # LA expanded 2016
  expect_equal(medicaid_expanded("LA", 2016), 1L)
  expect_equal(medicaid_expanded(c("MO","MO"), c(2020, 2021)), c(0L, 1L))
})

# ---------------------------------------------------------------------------
# (2) Integration checks on the built panel
# ---------------------------------------------------------------------------
rds <- "Data/intermediate_hospital_panel.rds"
test_that("built panel exists (run process_hospital_panel.R first)", {
  expect_true(file.exists(rds))
})

if (file.exists(rds)) {
  panel <- readRDS(rds)

  test_that("schema has the required keys, outcomes and moderators", {
    needed <- c("CCN", "Year", "Zip_Code", "State", "fips_code",
                "Hosp_OperatingMargin", "Hosp_NetMargin", "Hosp_UncompCare",
                "Hosp_UncompCare_PctNPR", "Hosp_NetPatientRevenue_Real",
                "SafetyNet", "Ownership", "SystemAffiliated", "Hosp_BedSize",
                "MedicaidExpansion", "Is_Extreme_Drought", "High_CDD", "High_HDD",
                "High_AQI_Max")
    expect_true(all(needed %in% names(panel)))
  })

  test_that("(CCN, Year) is a unique key", {
    expect_equal(anyDuplicated(panel[, c("CCN", "Year")]), 0L)
  })

  test_that("operating margin lies in a plausible proportion range", {
    om <- panel$Hosp_OperatingMargin[is.finite(panel$Hosp_OperatingMargin)]
    expect_gt(length(om), 1000)
    expect_true(all(om >= -6 & om <= 1.5))     # proportions, not percents
    expect_lt(abs(median(om) - 0.13), 0.10)    # ~13% median (sanity)
  })

  test_that("uncompensated-care-% is a proportion, not a percentage", {
    pc <- panel$Hosp_UncompCare_PctNPR[is.finite(panel$Hosp_UncompCare_PctNPR)]
    expect_lt(median(pc, na.rm = TRUE), 0.5)
  })

  test_that("real uncompensated care = real bad-debt + real charity where observed", {
    ok <- is.finite(panel$Hosp_BadDebt_Real) & is.finite(panel$Hosp_Charity_Real) &
          is.finite(panel$Hosp_UncompCare_Real)
    expect_equal(panel$Hosp_UncompCare_Real[ok],
                 panel$Hosp_BadDebt_Real[ok] + panel$Hosp_Charity_Real[ok],
                 tolerance = 1e-6)
  })

  test_that("county-match and shock-attach coverage are high", {
    expect_gt(mean(!is.na(panel$fips_code)), 0.90)
    expect_gt(mean(!is.na(panel$Is_Extreme_Drought)), 0.80)
  })

  test_that("SafetyNet is a ~25% top-quartile flag", {
    sn <- panel$SafetyNet[!is.na(panel$SafetyNet)]
    expect_true(mean(sn) > 0.18 && mean(sn) < 0.32)
  })

  test_that("panel covers the 2011-2023 NASHP window with many hospitals", {
    expect_equal(range(panel$Year, na.rm = TRUE), c(2011L, 2023L))
    expect_gt(length(unique(panel$CCN)), 3000)
  })
}

cat("\nAll hospital panel tests completed.\n")
