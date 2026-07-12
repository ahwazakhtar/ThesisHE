# Tests for run_passthrough_bounds.R (audit_response_20260712, task 2.1 / spec O4).
# The script exposes pure bound helpers (guarded main via sys.nframe()==0), so this
# sources it and exercises them on synthetic inputs. Run on main R 4.2.2:
#   & "C:/Program Files/R/R-4.2.2/bin/Rscript.exe" Code/tests/test_passthrough_bounds.R
#
# Covers the four properties the task names:
#   1. MDE arithmetic: MDE == 2.80 * SE (80% power, alpha=.05 two-sided identity).
#   2. TOST: delta* == |beta| + 1.645*SE; equivalence rejected iff the 90% CI is a
#      strict subset of (-delta, delta) iff delta > delta*.
#   3. Unit mapping: annual $/beneficiary -> PMPM is division by 12 (112->9.333,
#      177->14.75).
#   4. Output schema: compute_bounds_row() returns one row with every required
#      column, correctly derived.

suppressPackageStartupMessages({
  library(testthat)
})
source("Code/run_passthrough_bounds.R")

# ---------------------------------------------------------------------------
test_that("MDE is exactly 2.80 x SE on synthetic SEs (80% power, alpha=.05)", {
  ses <- c(0, 1, 2.334, 5.748, 8.613, 100)
  expect_equal(mde(ses), 2.80 * ses)
  # default constant is the intended 2.80 (within rounding of qnorm(.975)+qnorm(.80))
  expect_equal(Z_MDE, 2.80)
  expect_lt(abs(Z_MDE - (qnorm(.975) + qnorm(.80))), 0.002)
  # scalar identity
  expect_equal(mde(2.334), 2.80 * 2.334)
})

# ---------------------------------------------------------------------------
test_that("TOST bound identity: delta* = |beta| + 1.645*SE", {
  expect_equal(tost_bound(2.479, 2.334), 2.479 + 1.645 * 2.334)
  expect_equal(tost_bound(-10.475, 8.613), 10.475 + 1.645 * 8.613)  # |beta|
  expect_equal(tost_bound(0, 4), 1.645 * 4)
  expect_equal(Z_TOST, 1.645)
})

# ---------------------------------------------------------------------------
test_that("TOST rejection equals: 90% CI strict subset of (-delta, delta) iff delta > delta*", {
  beta <- -8.334; se <- 5.059
  ds <- tost_bound(beta, se)                 # = 16.66...
  ci <- ci90(beta, se)
  # at delta just ABOVE delta*: CI must be strictly inside -> reject equivalence-to-null
  expect_true(tost_reject(beta, se, ds + 1e-6))
  # at delta just BELOW delta*: not rejected
  expect_false(tost_reject(beta, se, ds - 1e-6))
  # the CI-subset definition matches the algebraic bound across a grid
  for (d in seq(1, 40, by = 0.5)) {
    subset_ok <- (ci["lo"] > -d) && (ci["hi"] < d)
    expect_equal(tost_reject(beta, se, d), unname(subset_ok))
    expect_equal(tost_reject(beta, se, d), d > ds)
  }
  # a positive-beta case too
  expect_true(tost_reject(12.566, 5.748, tost_bound(12.566, 5.748) + 1e-6))
})

# ---------------------------------------------------------------------------
test_that("annual-to-PMPM mapping is division by 12 (benchmark band)", {
  expect_equal(annual_to_pmpm(112), 112 / 12)
  expect_equal(annual_to_pmpm(177), 177 / 12)
  expect_equal(annual_to_pmpm(MORBIDITY_ANNUAL_LO), 9.333333, tolerance = 1e-5)
  expect_equal(annual_to_pmpm(MORBIDITY_ANNUAL_HI), 14.75,    tolerance = 1e-9)
  expect_equal(annual_to_pmpm(c(120, 240)), c(10, 20))
})

# ---------------------------------------------------------------------------
test_that("verdict_label splits on the benchmark band correctly", {
  blo <- annual_to_pmpm(112); bhi <- annual_to_pmpm(177)
  expect_equal(verdict_label(6.3, blo, bhi), "STRONG")   # below whole band
  expect_equal(verdict_label(24.6, blo, bhi), "SOFTER")  # above whole band
  expect_equal(verdict_label(12.0, blo, bhi), "MIXED")   # between 9.33 and 14.75
  expect_equal(verdict_label(bhi, blo, bhi), "SOFTER")   # >= high end -> softer
})

# ---------------------------------------------------------------------------
test_that("compute_bounds_row returns the full schema with correct derivations", {
  required_cols <- c(
    "spec", "premium", "outcome_role", "hazard", "lag", "lag_role",
    "beta", "se", "p_state", "N", "ci90_lo", "ci90_hi",
    "mde", "delta_star", "mean_premium", "mde_pct_mean", "delta_pct_mean",
    "bench_lo", "bench_hi", "mde_mult_bench_lo", "mde_mult_bench_hi",
    "delta_mult_bench_lo", "delta_mult_bench_hi", "verdict")
  r <- compute_bounds_row(
    spec = "RAxYr: RA+State^Year", premium = "Benchmark_Silver_Real",
    outcome_role = "primary", hazard = "Cold", lag = "L2", lag_role = "primary",
    beta = 12.566, se = 5.748, p_state = 0.0337, N = 3883, mean_premium = 375)
  expect_equal(nrow(r), 1L)
  expect_true(all(required_cols %in% names(r)))
  # derivations
  expect_equal(r$mde, 2.80 * 5.748)
  expect_equal(r$delta_star, 12.566 + 1.645 * 5.748)
  expect_equal(r$ci90_lo, 12.566 - 1.645 * 5.748)
  expect_equal(r$ci90_hi, 12.566 + 1.645 * 5.748)
  expect_equal(r$bench_lo, 112 / 12)
  expect_equal(r$bench_hi, 177 / 12)
  expect_equal(r$mde_pct_mean, 100 * r$mde / 375)
  expect_equal(r$delta_pct_mean, 100 * r$delta_star / 375)
  expect_equal(r$delta_mult_bench_lo, r$delta_star / (112 / 12))
  expect_equal(r$delta_mult_bench_hi, r$delta_star / (177 / 12))
  # cold L2 delta* ($22.0) exceeds the band -> SOFTER
  expect_equal(r$verdict, "SOFTER")
})

# ---------------------------------------------------------------------------
test_that("a tiny-SE cell yields the STRONG verdict (delta* below the band)", {
  # drought-like: small beta, small SE -> delta* < $9.33
  r <- compute_bounds_row(
    spec = "RAxYr: RA+State^Year", premium = "Benchmark_Silver_Real",
    outcome_role = "primary", hazard = "Drought", lag = "L2", lag_role = "primary",
    beta = 2.479, se = 2.334, p_state = 0.294, N = 3883, mean_premium = 375)
  expect_lt(r$delta_star, annual_to_pmpm(112))  # below the low end
  expect_equal(r$verdict, "STRONG")
  # and the strong claim quantifies as a fraction < 1 of the band
  expect_lt(r$delta_mult_bench_lo, 1)
})

cat("\nAll passthrough-bounds tests completed.\n")
