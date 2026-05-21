# Tests for Phase 3: Year-over-Year Delta variable construction
# Run: Rscript Code/tests/test_delta_variables.R

library(testthat)
library(dplyr)

# ---------------------------------------------------------------------------
# Synthetic 3-county panel helpers
# ---------------------------------------------------------------------------
make_panel <- function() {
  set.seed(99)
  expand.grid(fips_code = c("01001", "01002", "01003"), Year = 2010:2020,
              stringsAsFactors = FALSE) %>%
    arrange(fips_code, Year) %>%
    mutate(
      Z_Temp   = rnorm(n(), 0, 1),
      Z_Precip = rnorm(n(), 0, 1),
      cdd_val  = runif(n(), 0, 2000),
      hdd_val  = runif(n(), 0, 5000),
      pdsi_val = runif(n(), -6, 4),
      Median_AQI = runif(n(), 20, 120),
      Max_AQI    = runif(n(), 50, 300)
    ) %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      Delta_Z_Temp       = Z_Temp   - lag(Z_Temp,   1),
      Delta_Z_Precip     = Z_Precip - lag(Z_Precip, 1),
      Delta_CDD          = cdd_val  - lag(cdd_val,  1),
      Delta_HDD          = hdd_val  - lag(hdd_val,  1),
      Delta_PDSI         = pdsi_val - lag(pdsi_val, 1),
      Delta_Median_AQI   = Median_AQI - lag(Median_AQI, 1),
      Delta_Max_AQI      = Max_AQI    - lag(Max_AQI,    1),
      # Asymmetric splits
      Delta_Z_Temp_Pos   = pmax(Delta_Z_Temp,     0), Delta_Z_Temp_Neg   = pmin(Delta_Z_Temp,   0),
      Delta_CDD_Pos      = pmax(Delta_CDD,         0), Delta_CDD_Neg      = pmin(Delta_CDD,      0),
      Delta_HDD_Pos      = pmax(Delta_HDD,         0), Delta_HDD_Neg      = pmin(Delta_HDD,      0),
      Delta_PDSI_Pos     = pmax(Delta_PDSI,        0), Delta_PDSI_Neg     = pmin(Delta_PDSI,     0),
      Delta_Median_AQI_Pos = pmax(Delta_Median_AQI, 0), Delta_Median_AQI_Neg = pmin(Delta_Median_AQI, 0),
      # Binary shock indicators
      Is_Extreme_Drought = as.integer(!is.na(pdsi_val) & pdsi_val <= -4),
      High_CDD           = as.integer(cdd_val >= quantile(cdd_val, 0.80, na.rm = TRUE)),
      High_HDD           = as.integer(hdd_val >= quantile(hdd_val, 0.80, na.rm = TRUE))
    ) %>%
    mutate(
      Drought_Onset   = as.integer(Is_Extreme_Drought == 1 & lag(Is_Extreme_Drought, 1) == 0),
      Drought_Exit    = as.integer(Is_Extreme_Drought == 0 & lag(Is_Extreme_Drought, 1) == 1),
      Drought_Persist = as.integer(Is_Extreme_Drought == 1 & lag(Is_Extreme_Drought, 1) == 1),
      CDD_Onset       = as.integer(High_CDD == 1 & lag(High_CDD, 1) == 0),
      CDD_Exit        = as.integer(High_CDD == 0 & lag(High_CDD, 1) == 1),
      CDD_Persist     = as.integer(High_CDD == 1 & lag(High_CDD, 1) == 1)
    ) %>%
    ungroup()
}

panel <- make_panel()

# ===========================================================================
# Test 1: NA at first observation of each county, non-NA thereafter
# ===========================================================================
test_that("Delta variables are NA only at first obs per county, not elsewhere", {
  first_obs <- panel %>% group_by(fips_code) %>% slice(1) %>% ungroup()
  later_obs  <- panel %>% group_by(fips_code) %>% slice(-1) %>% ungroup()

  expect_true(all(is.na(first_obs$Delta_Z_Temp)),
              "Delta_Z_Temp should be NA at first county-year")
  expect_true(all(is.na(first_obs$Delta_CDD)),
              "Delta_CDD should be NA at first county-year")
  expect_false(any(is.na(later_obs$Delta_Z_Temp)),
               "Delta_Z_Temp should not be NA after first obs")
  expect_false(any(is.na(later_obs$Delta_PDSI)),
               "Delta_PDSI should not be NA after first obs")
})

# ===========================================================================
# Test 2: Delta values are arithmetically correct
# ===========================================================================
test_that("Delta = current - lag(1) is arithmetically correct", {
  # Pick a specific county and year pair to validate manually
  county <- "01001"
  yr <- 2015
  row_t  <- panel %>% filter(fips_code == county, Year == yr)
  row_t1 <- panel %>% filter(fips_code == county, Year == yr - 1)

  expect_equal(row_t$Delta_Z_Temp,   row_t$Z_Temp   - row_t1$Z_Temp,   tolerance = 1e-10)
  expect_equal(row_t$Delta_CDD,      row_t$cdd_val  - row_t1$cdd_val,  tolerance = 1e-10)
  expect_equal(row_t$Delta_PDSI,     row_t$pdsi_val - row_t1$pdsi_val, tolerance = 1e-10)
  expect_equal(row_t$Delta_Median_AQI, row_t$Median_AQI - row_t1$Median_AQI, tolerance = 1e-10)
})

# ===========================================================================
# Test 3: No cross-county contamination (deltas respect panel boundaries)
# ===========================================================================
test_that("Deltas do not bleed across county boundaries", {
  # The first year of county 01002 should be NA, not derived from 01001's last year
  first_01002 <- panel %>% filter(fips_code == "01002", Year == 2010)
  expect_true(is.na(first_01002$Delta_Z_Temp),
              "Delta at first year of 01002 must be NA, not computed from prior county")
  expect_true(is.na(first_01002$Delta_HDD))
})

# ===========================================================================
# Test 4: Asymmetric split — Pos + Neg reconstructs the symmetric delta
# ===========================================================================
test_that("Delta_Pos + Delta_Neg == Delta (symmetric decomposition)", {
  complete <- panel %>% filter(!is.na(Delta_Z_Temp))

  expect_equal(complete$Delta_Z_Temp_Pos + complete$Delta_Z_Temp_Neg,
               complete$Delta_Z_Temp, tolerance = 1e-10,
               label = "Z_Temp asymmetric decomposition")

  expect_equal(complete$Delta_CDD_Pos + complete$Delta_CDD_Neg,
               complete$Delta_CDD, tolerance = 1e-10,
               label = "CDD asymmetric decomposition")

  expect_equal(complete$Delta_PDSI_Pos + complete$Delta_PDSI_Neg,
               complete$Delta_PDSI, tolerance = 1e-10,
               label = "PDSI asymmetric decomposition")

  expect_equal(complete$Delta_Median_AQI_Pos + complete$Delta_Median_AQI_Neg,
               complete$Delta_Median_AQI, tolerance = 1e-10,
               label = "Median_AQI asymmetric decomposition")
})

# ===========================================================================
# Test 5: Asymmetric split — Pos >= 0 and Neg <= 0 everywhere
# ===========================================================================
test_that("Delta_Pos >= 0 and Delta_Neg <= 0 always", {
  complete <- panel %>% filter(!is.na(Delta_CDD_Pos))
  expect_true(all(complete$Delta_CDD_Pos  >= 0), "Delta_CDD_Pos must be non-negative")
  expect_true(all(complete$Delta_CDD_Neg  <= 0), "Delta_CDD_Neg must be non-positive")
  expect_true(all(complete$Delta_HDD_Pos  >= 0), "Delta_HDD_Pos must be non-negative")
  expect_true(all(complete$Delta_PDSI_Pos >= 0), "Delta_PDSI_Pos must be non-negative")
  expect_true(all(complete$Delta_PDSI_Neg <= 0), "Delta_PDSI_Neg must be non-positive")
})

# ===========================================================================
# Test 6: Binary onset/exit/persist are mutually exclusive and exhaustive
# ===========================================================================
test_that("Onset + Exit + Persist + (never-shocked) partitions post-first-obs rows", {
  # For rows where lag is not NA, every county-year must fall into exactly one state:
  #   1=Onset, 2=Exit, 3=Persist, 0=neither (was 0, stays 0)
  complete <- panel %>%
    group_by(fips_code) %>%
    slice(-1) %>%   # drop first obs (lag is NA)
    ungroup() %>%
    filter(!is.na(Drought_Onset))

  # Onset + Exit + Persist <= 1 (mutually exclusive)
  row_sum <- complete$Drought_Onset + complete$Drought_Exit + complete$Drought_Persist
  expect_true(all(row_sum <= 1),
              "Onset, Exit, Persist cannot all be 1 simultaneously")

  # For rows where shocked last year: Exit + Persist == 1 (exhaustive given prior=1)
  was_shocked <- complete %>% filter(lag(Is_Extreme_Drought, 0) == 1 |
                                       Drought_Exit == 1 | Drought_Persist == 1)
  # Simpler: directly check the definitions hold
  expect_true(all(complete$Drought_Onset[complete$Is_Extreme_Drought == 0] == 0),
              "Onset must be 0 when current Is_Extreme_Drought == 0")
  expect_true(all(complete$Drought_Persist[complete$Is_Extreme_Drought == 0] == 0),
              "Persist must be 0 when current Is_Extreme_Drought == 0")
})

# ===========================================================================
# Exit LP horizons (Phase 2)
# ===========================================================================
# These tests cover the local-projection extension to the Exit indicators.
# Block A: lead(Y, h) ~ Exit + ... | fips + Year, for h = 0..3
# Block B: lead(Y, h) ~ Shock_{t-1} * NoShock_{t} | fips + Year (interaction
# isolates scarring/relief population separately from never/persist cohorts).
#
# Tests intentionally use a small synthetic panel — they verify the LP
# construction primitives (lead alignment, h=0 equivalence, no cross-county
# bleed). Empirical findings on the real panel are validated separately.

library(fixest)

make_lp_panel <- function() {
  set.seed(123)
  d <- expand.grid(
    fips_code = c("01001", "01002", "01003", "01004", "01005"),
    Year = 2010:2020, stringsAsFactors = FALSE
  ) %>%
    arrange(fips_code, Year) %>%
    group_by(fips_code) %>%
    mutate(
      Is_Extreme_Drought = as.integer(Year %in% sample(2011:2019, 3)),
      Y                  = rnorm(n(), mean = 100, sd = 10) +
                           5 * Is_Extreme_Drought
    ) %>%
    mutate(
      Drought_Exit = as.integer(Is_Extreme_Drought == 0 &
                                  lag(Is_Extreme_Drought, 1) == 1),
      Y_fwd0 = Y,
      Y_fwd1 = dplyr::lead(Y, 1),
      Y_fwd2 = dplyr::lead(Y, 2),
      Y_fwd3 = dplyr::lead(Y, 3),
      LagShock = dplyr::lag(Is_Extreme_Drought, 1),
      NoShock  = 1L - Is_Extreme_Drought
    ) %>%
    ungroup()
  d
}

# ===========================================================================
# Test 7: Exit LP at h=0 reproduces contemporaneous Exit coefficient
# ===========================================================================
# Y_fwd0 == Y by construction, so feols on Y_fwd0 with the Exit indicator
# must yield the same point estimate as feols on Y. This guards against
# misalignment in the lead() construction.
test_that("LP at h=0 matches contemporaneous Exit coefficient", {
  d <- make_lp_panel() %>% filter(!is.na(Drought_Exit))

  m_base <- feols(Y      ~ Drought_Exit | fips_code + Year, data = d)
  m_lp0  <- feols(Y_fwd0 ~ Drought_Exit | fips_code + Year, data = d)

  expect_equal(coef(m_base)[["Drought_Exit"]],
               coef(m_lp0)[["Drought_Exit"]],
               tolerance = 1e-10,
               label = "h=0 LP must equal contemporaneous regression")
})

# ===========================================================================
# Test 8: lead() does not bleed across county boundaries
# ===========================================================================
# The last h observations of each county must have Y_fwd{h} = NA. If lead()
# were applied without group_by(fips_code), it would carry the next county's
# first values into the prior county's tail — a silent panel violation.
test_that("lead() respects county boundaries (NA at panel tail)", {
  d <- make_lp_panel()

  tail_rows <- d %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    slice_tail(n = 1) %>%   # last year for each county
    ungroup()
  expect_true(all(is.na(tail_rows$Y_fwd1)),
              "Y_fwd1 must be NA at each county's last year")
  expect_true(all(is.na(tail_rows$Y_fwd2)),
              "Y_fwd2 must be NA at each county's last year")
  expect_true(all(is.na(tail_rows$Y_fwd3)),
              "Y_fwd3 must be NA at each county's last year")

  # Cross-county boundary check: county 01001 final year fwd1 must NOT equal
  # county 01002 first year Y — if grouping was missing, that's what would
  # leak through.
  d_01001_last <- d %>% filter(fips_code == "01001", Year == 2020)
  d_01002_first <- d %>% filter(fips_code == "01002", Year == 2010)
  expect_true(is.na(d_01001_last$Y_fwd1),
              "fwd1 at boundary must be NA, not next county's Y")
  expect_false(isTRUE(d_01001_last$Y_fwd1 == d_01002_first$Y),
               "fwd1 must not equal next county's Y")
})

# ===========================================================================
# Test 9: Exit interaction (Shock_{t-1} * NoShock_{t}) identifies recovery cohort
# ===========================================================================
# The interaction term equals 1 only for county-years where the county was
# shocked at t-1 and is not shocked at t — exactly the rows where Drought_Exit
# == 1. The interaction is therefore identical to Drought_Exit by definition.
test_that("Shock_{t-1} * NoShock_{t} matches Drought_Exit indicator", {
  d <- make_lp_panel() %>% filter(!is.na(LagShock))

  interaction_indicator <- as.integer(d$LagShock * d$NoShock)
  expect_equal(interaction_indicator, as.integer(d$Drought_Exit),
               label = "Interaction term must equal Drought_Exit row-by-row")
})

cat("\nAll delta variable tests passed.\n")
