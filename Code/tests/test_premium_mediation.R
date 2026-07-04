# Tests for run_premium_mediation.R (thesis_completion_20260704, T1.1).
# The script exposes two pure helpers (guarded main via sys.nframe()==0), so this
# sources it and exercises them on synthetic data. Run on main R 4.2.2:
#   Rscript Code/tests/test_premium_mediation.R
#
# Covers the two acceptance properties the plan names:
#   - decomposition identity: est_base == est_with + mediated ; fraction = with/base
#   - lag alignment: a shock at year t lands in _L1 at t+1 and _L2 at t+2, per county.

suppressPackageStartupMessages({
  library(testthat)
  library(fixest)
})
source("Code/run_premium_mediation.R")

# ---------------------------------------------------------------------------
test_that("add_shock_lags aligns L1/L2 by county with no cross-county bleed", {
  d <- data.frame(
    fips_code = rep(c("01001", "06075"), each = 5),
    Year      = rep(2011:2015, times = 2),
    shk       = c(1, 0, 0, 0, 0,      # county A: shock in 2011 only
                  0, 0, 1, 0, 0),     # county B: shock in 2013 only
    stringsAsFactors = FALSE)
  out <- add_shock_lags(d, "shk", max_lag = 2)
  a <- out[out$fips_code == "01001", ]
  b <- out[out$fips_code == "06075", ]
  # County A: 2011 shock -> L1 at 2012, L2 at 2013.
  expect_equal(a$shk_L1, c(NA, 1, 0, 0, 0))
  expect_equal(a$shk_L2, c(NA, NA, 1, 0, 0))
  # County B: 2013 shock -> L1 at 2014, L2 at 2015; and A's tail does NOT bleed in.
  expect_equal(b$shk_L1, c(NA, 0, 0, 1, 0))
  expect_equal(b$shk_L2, c(NA, NA, 0, 0, 1))
})

# ---------------------------------------------------------------------------
test_that("add_shock_lags honors a non-default group (RA/state level panels)", {
  # The aggregated pass-through panels lag within rating_area_id / State, not fips.
  d <- data.frame(
    rating_area_id = rep(c("CA01", "NY02"), each = 4),
    Year = rep(2014:2017, times = 2),
    fips_code = "X",                         # present but must be IGNORED as grouper
    sh = c(0.1, 0.2, 0.3, 0.4,  0.5, 0.6, 0.7, 0.8),
    stringsAsFactors = FALSE)
  out <- add_shock_lags(d, "sh", max_lag = 1L, group = "rating_area_id")
  ca <- out[out$rating_area_id == "CA01", ]
  ny <- out[out$rating_area_id == "NY02", ]
  expect_equal(ca$sh_L1, c(NA, 0.1, 0.2, 0.3))
  expect_equal(ny$sh_L1, c(NA, 0.5, 0.6, 0.7))   # no bleed from CA's 0.4 into NY
})

# ---------------------------------------------------------------------------
test_that("mediation_decompose satisfies the additive identity and fraction", {
  set.seed(101)
  n_c <- 60; yrs <- 2008:2019
  g <- expand.grid(fips_code = sprintf("%05d", 1:n_c), Year = yrs,
                   stringsAsFactors = FALSE)
  g$State <- substr(g$fips_code, 1, 2)
  g$shk <- rbinom(nrow(g), 1, 0.25)
  fe_c <- rnorm(n_c); names(fe_c) <- sprintf("%05d", 1:n_c)
  # DGP: shock raises the mediator, which raises the outcome; shock also has a
  # direct effect. So controlling for M should shrink (but not zero) the shock coef.
  g$M <- 3 * g$shk + fe_c[g$fips_code] + rnorm(nrow(g), 0, 1)
  g$Y <- 2 * g$shk + 1.5 * g$M + fe_c[g$fips_code] * 0.5 + rnorm(nrow(g), 0, 1)

  dec <- mediation_decompose(g, outcome = "Y", shock_terms = "shk",
                             mediator_terms = "M", cluster = ~State)
  r <- dec[dec$term == "shk", ]
  # Additive identity is definitional but must be computed consistently.
  expect_equal(r$est_base, r$est_with + r$mediated, tolerance = 1e-9)
  expect_equal(r$fraction_surviving, r$est_with / r$est_base, tolerance = 1e-9)
  # Economically: controlling for the mediator shrinks the effect toward the
  # direct component (2), and some is mediated (>0), so 0 < fraction < 1.
  expect_gt(r$mediated, 0)
  expect_true(r$fraction_surviving > 0 && r$fraction_surviving < 1)
})

# ---------------------------------------------------------------------------
test_that("an unrelated mediator leaves the effect essentially intact (fraction ~ 1)", {
  set.seed(202)
  n_c <- 60; yrs <- 2008:2019
  g <- expand.grid(fips_code = sprintf("%05d", 1:n_c), Year = yrs,
                   stringsAsFactors = FALSE)
  g$State <- substr(g$fips_code, 1, 2)
  g$shk <- rbinom(nrow(g), 1, 0.25)
  g$M   <- rnorm(nrow(g))                       # pure noise, unrelated to shock
  g$Y   <- 2 * g$shk + rnorm(nrow(g), 0, 1)
  dec <- mediation_decompose(g, outcome = "Y", shock_terms = "shk",
                             mediator_terms = "M", cluster = ~State)
  r <- dec[dec$term == "shk", ]
  expect_equal(r$fraction_surviving, 1, tolerance = 0.05)  # nothing mediated
})

# ---------------------------------------------------------------------------
test_that("mediation_decompose fits base and with-mediator on the SAME sample", {
  # Rows missing the mediator must be dropped from BOTH fits, else the
  # decomposition compares different samples and the identity is meaningless.
  set.seed(303)
  n_c <- 40; yrs <- 2010:2019
  g <- expand.grid(fips_code = sprintf("%05d", 1:n_c), Year = yrs,
                   stringsAsFactors = FALSE)
  g$State <- substr(g$fips_code, 1, 2)
  g$shk <- rbinom(nrow(g), 1, 0.3)
  g$M   <- 2 * g$shk + rnorm(nrow(g))
  g$Y   <- g$shk + g$M + rnorm(nrow(g))
  g$M[sample(nrow(g), 50)] <- NA                # punch holes in the mediator
  dec <- mediation_decompose(g, outcome = "Y", shock_terms = "shk",
                             mediator_terms = "M", cluster = ~State)
  r <- dec[dec$term == "shk", ]
  expect_equal(r$N, sum(!is.na(g$M) & !is.na(g$Y) & !is.na(g$shk)))
  expect_false(is.na(r$est_base))
})

cat("\nAll premium-mediation tests completed.\n")
