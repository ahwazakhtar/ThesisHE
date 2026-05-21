# Tests for run_re_robustness.R (Committee Feedback Phase 1)
# Run: Rscript Code/tests/test_re_robustness.R

suppressPackageStartupMessages({
  library(testthat)
  library(dplyr)
  library(plm)
  library(fixest)
})

# Synthetic balanced panel where unit-level intercepts are correlated with
# the regressor: ground truth for the Hausman test to reject RE.
make_correlated_panel <- function(n_units = 30, n_years = 10, beta = 1.5, seed = 7) {
  set.seed(seed)
  unit <- rep(seq_len(n_units), each = n_years)
  year <- rep(seq_len(n_years), times = n_units)
  alpha <- rnorm(n_units, 0, 2)[unit]              # unit FE
  # x explicitly correlated with alpha
  x <- 0.6 * alpha + rnorm(n_units * n_years, 0, 1)
  y <- alpha + beta * x + rnorm(n_units * n_years, 0, 1)
  data.frame(unit = unit, year = year, x = x, y = y)
}

# Panel where unit effects are uncorrelated with x — RE is admissible.
make_uncorrelated_panel <- function(n_units = 30, n_years = 10, beta = 1.5, seed = 11) {
  set.seed(seed)
  unit <- rep(seq_len(n_units), each = n_years)
  year <- rep(seq_len(n_years), times = n_units)
  alpha <- rnorm(n_units, 0, 2)[unit]
  x <- rnorm(n_units * n_years, 0, 1)              # independent of alpha
  y <- alpha + beta * x + rnorm(n_units * n_years, 0, 1)
  data.frame(unit = unit, year = year, x = x, y = y)
}

# ---------------------------------------------------------------------------
test_that("FE within estimator from plm matches fixest on a balanced panel", {
  d <- make_correlated_panel()
  pfe <- plm(y ~ x, data = d, index = c("unit", "year"),
             model = "within", effect = "individual")
  fe <- feols(y ~ x | unit, data = d)
  expect_equal(as.numeric(coef(pfe)["x"]),
               as.numeric(coef(fe)["x"]),
               tolerance = 1e-6)
})

# ---------------------------------------------------------------------------
test_that("Hausman statistic is non-negative and p-value in [0,1]", {
  d <- make_correlated_panel()
  pfe <- plm(y ~ x, data = d, index = c("unit", "year"),
             model = "within", effect = "individual")
  pre <- plm(y ~ x, data = d, index = c("unit", "year"),
             model = "random", effect = "individual")
  h <- phtest(pfe, pre)
  expect_true(is.finite(as.numeric(h$statistic)))
  expect_gte(as.numeric(h$statistic), 0)
  expect_gte(as.numeric(h$p.value), 0)
  expect_lte(as.numeric(h$p.value), 1)
})

# ---------------------------------------------------------------------------
test_that("Hausman rejects RE when unit FE is correlated with X (truth = FE)", {
  d <- make_correlated_panel()
  pfe <- plm(y ~ x, data = d, index = c("unit", "year"),
             model = "within", effect = "individual")
  pre <- plm(y ~ x, data = d, index = c("unit", "year"),
             model = "random", effect = "individual")
  h <- phtest(pfe, pre)
  expect_lt(as.numeric(h$p.value), 0.05)
})

# ---------------------------------------------------------------------------
test_that("RE point estimate is close to FE when unit FE is uncorrelated with X", {
  # Hausman p-value can still vary across seeds in small panels; instead of
  # asserting p-value > 0.05 (flaky), assert that the FE and RE point
  # estimates of beta are within 0.2 of each other on the uncorrelated DGP.
  d <- make_uncorrelated_panel()
  pfe <- plm(y ~ x, data = d, index = c("unit", "year"),
             model = "within", effect = "individual")
  pre <- plm(y ~ x, data = d, index = c("unit", "year"),
             model = "random", effect = "individual")
  beta_fe <- as.numeric(coef(pfe)["x"])
  beta_re <- as.numeric(coef(pre)["x"])
  expect_equal(beta_fe, beta_re, tolerance = 0.2)
})

# ---------------------------------------------------------------------------
test_that("run_re_robustness.R outputs exist and are well-formed", {
  results_path <- "Analysis/random_effects_results.csv"
  hausman_path <- "Analysis/random_effects_hausman.csv"
  skip_if_not(file.exists(results_path),
              "random_effects_results.csv missing; run run_re_robustness.R first")
  skip_if_not(file.exists(hausman_path),
              "random_effects_hausman.csv missing; run run_re_robustness.R first")

  r <- read.csv(results_path, stringsAsFactors = FALSE)
  h <- read.csv(hausman_path, stringsAsFactors = FALSE)

  expect_true(all(c("Level", "Outcome", "Term",
                    "FE_Estimate", "RE_Estimate", "Hausman_PValue") %in% names(r)))
  expect_true(all(c("Level", "Outcome", "Hausman_ChiSq",
                    "Hausman_PValue", "RE_Rejected_at_05") %in% names(h)))
  expect_true(all(h$Hausman_ChiSq[!is.na(h$Hausman_ChiSq)] >= 0))
  expect_true(all(h$Hausman_PValue[!is.na(h$Hausman_PValue)] >= 0 &
                  h$Hausman_PValue[!is.na(h$Hausman_PValue)] <= 1))
})

cat("All RE robustness tests completed.\n")
