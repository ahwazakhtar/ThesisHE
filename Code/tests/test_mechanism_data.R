# Tests for the mechanism-track Phase 1 data builds.
# Track: mechanism_channels_20260625.  Run: Rscript Code/tests/test_mechanism_data.R
#
# Integration checks on the five built intermediates (skipped individually if the
# artifact does not yet exist, so partial builds still test what's present):
#   Data/intermediate_ag_dependence.rds
#   Data/intermediate_industry_composition.rds
#   Data/intermediate_migration.rds
#   Data/intermediate_medicare_spending.rds
#   Data/intermediate_energy_burden.rds
# Plus a pure test of the FIPS zero-pad idiom used across all processors (guards the
# Session-5 sprintf("%05s") space-pad trap).

suppressPackageStartupMessages(library(testthat))

FIVE <- 5L
pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
all_5digit <- function(f) all(grepl("^[0-9]{5}$", f))

# ---------------------------------------------------------------------------
# (0) Pure: FIPS zero-pad must pad with ZEROS, never spaces
# ---------------------------------------------------------------------------
test_that("pad_fips zero-pads single-digit-state FIPS without spaces", {
  expect_equal(pad_fips(1001), "01001")
  expect_equal(pad_fips("6037"), "06037")
  expect_false(any(grepl(" ", pad_fips(c(1001, 6037, 36103)))))
})

skip_if_absent <- function(path) if (!file.exists(path)) skip(paste("not built:", path))

# ---------------------------------------------------------------------------
# (1) Ag-dependence
# ---------------------------------------------------------------------------
test_that("ag_dependence: schema, FIPS, flags, share range, terciles", {
  skip_if_absent("Data/intermediate_ag_dependence.rds")
  d <- readRDS("Data/intermediate_ag_dependence.rds")
  expect_true(all(c("fips_code","Ag_Dependent","Ag_Dependent_Flag",
                    "Farm_Earnings_Share","Ag_Dependence_Tercile") %in% names(d)))
  expect_true(all_5digit(d$fips_code))
  expect_false(any(duplicated(d$fips_code)))
  # counties in BEA but absent from the USDA typology are legitimately NA (unknown class)
  expect_true(all(d$Ag_Dependent %in% c(0L, 1L, NA)))
  # USDA non-overlapping "Farming" count is ERS's published 444
  expect_equal(sum(d$Ag_Dependent == 1, na.rm = TRUE), 444)
  # broader standalone flag is a superset
  expect_gte(sum(d$Ag_Dependent_Flag == 1, na.rm = TRUE),
             sum(d$Ag_Dependent == 1, na.rm = TRUE))
  # farm-earnings share is a plausible fraction (allow small negatives: bad farm years)
  fs <- d$Farm_Earnings_Share[!is.na(d$Farm_Earnings_Share)]
  expect_true(all(fs > -0.2 & fs < 1))
  expect_true(all(d$Ag_Dependence_Tercile %in% c(1L, 2L, 3L, NA)))
})

# ---------------------------------------------------------------------------
# (2) Industry composition
# ---------------------------------------------------------------------------
test_that("industry_composition: shares in [0,1], key moderator present, terciles", {
  skip_if_absent("Data/intermediate_industry_composition.rds")
  d <- readRDS("Data/intermediate_industry_composition.rds")
  expect_true(all(c("fips_code","Year","Ag_Emp_Share","ClimateExposed_NonFarm_Share",
                    "ClimateExposed_NonFarm_Share_baseline","ClimateExposed_Tercile") %in% names(d)))
  expect_true(all_5digit(unique(d$fips_code)))
  for (v in c("Ag_Emp_Share","ClimateExposed_NonFarm_Share")) {
    x <- d[[v]][!is.na(d[[v]])]
    expect_true(all(x >= 0 & x <= 1), info = v)
  }
  expect_true(all(range(d$Year) == c(2011, 2023)))
  expect_true(all(d$ClimateExposed_Tercile %in% c(1L, 2L, 3L, NA)))
})

# ---------------------------------------------------------------------------
# (3) Migration
# ---------------------------------------------------------------------------
test_that("migration: schema, years, rate finite and signed", {
  skip_if_absent("Data/intermediate_migration.rds")
  d <- readRDS("Data/intermediate_migration.rds")
  expect_true(all(c("fips_code","Year","net_migration_rate",
                    "in_migration_rate","out_migration_rate","net_agi_flow") %in% names(d)))
  expect_true(all_5digit(unique(d$fips_code)))
  expect_true(min(d$Year) >= 2012 && max(d$Year) <= 2021)
  # rates are a ratio; the vast majority sit in a sane band even if tiny counties are extreme
  r <- d$net_migration_rate[!is.na(d$net_migration_rate)]
  expect_gt(mean(abs(r) < 0.5), 0.98)
})

# ---------------------------------------------------------------------------
# (4) Medicare spending / utilization
# ---------------------------------------------------------------------------
test_that("medicare: years 2014-2023, positive spending, utilization present", {
  skip_if_absent("Data/intermediate_medicare_spending.rds")
  d <- readRDS("Data/intermediate_medicare_spending.rds")
  expect_true(all(c("fips_code","Year","Mdcr_Std_Payment_PC","ER_Visits_per1000",
                    "IP_Stays_per1000","Readmission_Rate") %in% names(d)))
  expect_true(all_5digit(unique(d$fips_code)))
  expect_true(min(d$Year) >= 2014 && max(d$Year) <= 2023)
  sp <- d$Mdcr_Std_Payment_PC[!is.na(d$Mdcr_Std_Payment_PC)]
  expect_true(all(sp > 0))
  # readmission rate is a proportion
  rr <- d$Readmission_Rate[!is.na(d$Readmission_Rate)]
  expect_true(all(rr >= 0 & rr <= 1))
})

# ---------------------------------------------------------------------------
# (5) Energy burden
# ---------------------------------------------------------------------------
test_that("energy: burden positive, low-income burden exceeds overall, terciles", {
  skip_if_absent("Data/intermediate_energy_burden.rds")
  d <- readRDS("Data/intermediate_energy_burden.rds")
  expect_true(all(c("fips_code","Energy_Burden_Pct","Energy_Burden_Pct_LowInc",
                    "Energy_Burden_Tercile") %in% names(d)))
  expect_true(all_5digit(unique(d$fips_code)))
  expect_false(any(duplicated(d$fips_code)))
  b <- d$Energy_Burden_Pct[!is.na(d$Energy_Burden_Pct)]
  expect_true(all(b > 0 & b < 60))          # % of income; sane upper bound
  # distributional signature: low-income households bear a HIGHER burden on average
  expect_gt(mean(d$Energy_Burden_Pct_LowInc, na.rm = TRUE),
            mean(d$Energy_Burden_Pct, na.rm = TRUE))
  expect_true(all(d$Energy_Burden_Tercile %in% c(1L, 2L, 3L, NA)))
})

cat("mechanism data tests defined.\n")
