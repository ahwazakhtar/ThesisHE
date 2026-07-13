# Tests for Code/run_policy_sufficient_stats.R
# (thesis_completion_20260704 task 2.3, T1.3 as amended). Main R 4.2.2.
# Run:  Rscript Code/tests/test_policy_sufficient_stats.R
#
# Covers the properties the sufficient-statistics synthesis relies on:
#   (1) aggregation identity: aggregate == per-unit coefficient x count
#       (synthetic fixture + a real band read back from the written CSV);
#   (2) delta-method band propagation against a hand-computed reference;
#   (3) concentration shares in [0,1], monotone non-decreasing, final == 1
#       (synthetic fixture + the real written curve);
#   (4) the unpriced-floor arithmetic (hand-computed reference);
#   (5) INPUT-ANCHOR LOCK: every input coefficient equals the certified
#       evidence-table value it cites -- hard-coded here independently of the
#       script's own constants, checked against both the source files (via the
#       script's locators) and the coefficients written into sufficient_stats.csv.
#       A mismatch fails the suite (the frozen table may have moved).

suppressPackageStartupMessages({
  library(testthat)
})

# Sourcing defines all functions; the sys.nframe() guard means main() does NOT
# auto-run here. We invoke main() once to (re)generate the outputs, then read
# them back for the identity/curve checks.
source("Code/run_policy_sufficient_stats.R")

OUT <- "Analysis/policy"
invisible(main())                        # regenerate outputs (also exercises the pipeline)
stats <- read.csv(file.path(OUT, "sufficient_stats.csv"), stringsAsFactors = FALSE)
curve <- read.csv(file.path(OUT, "concentration_curve.csv"), stringsAsFactors = FALSE)

bandrow <- function(b) stats[stats$band == b, ][1, ]

# ---------------------------------------------------------------------------
test_that("aggregation identity holds on a synthetic fixture", {
  expect_equal(aggregate_band(-1311, 5410588), -1311 * 5410588)
  expect_equal(aggregate_band(0.01874, 68907329), 0.01874 * 68907329)
  expect_equal(aggregate_band(0, 12345), 0)
  # vectorized
  expect_equal(aggregate_band(c(2, 3), c(10, 100)), c(20, 300))
})

# ---------------------------------------------------------------------------
test_that("aggregation identity holds on real written bands", {
  for (b in c("cold_cumulative_employment", "drought_debt_scar",
              "heat_medicare_annual_t0", "event_2012_income")) {
    r <- bandrow(b)
    expect_equal(r$aggregate_point, r$per_unit_coef * r$count, tolerance = 1e-6,
                 info = paste("band", b))
    # the CI endpoints are also count * per-unit endpoints (identity preserved)
    expect_equal(r$aggregate_ci_lo, r$per_unit_ci_lo * r$count, tolerance = 1e-6, info = b)
    expect_equal(r$aggregate_ci_hi, r$per_unit_ci_hi * r$count, tolerance = 1e-6, info = b)
  }
})

# ---------------------------------------------------------------------------
test_that("delta-method band matches a hand-computed reference", {
  # point=100, se=10, count=5, z=1.959964 (qnorm .975).
  z <- qnorm(0.975)
  d <- delta_band(100, 10, 5, z = z)
  expect_equal(d$per_unit_lo, 100 - z * 10)
  expect_equal(d$per_unit_hi, 100 + z * 10)
  expect_equal(d$agg_point, 500)
  expect_equal(d$agg_lo, 5 * (100 - z * 10))
  expect_equal(d$agg_hi, 5 * (100 + z * 10))
  expect_equal(d$agg_se, 5 * 10)                      # SE_agg = |count| * SE_beta
  # explicit hand numbers (z ~= 1.959964): lo per-unit 80.40036, agg 402.0018
  expect_equal(round(d$per_unit_lo, 5), 80.40036)
  expect_equal(round(d$agg_lo, 4), 402.0018)
  # negative point (income loss) keeps the ordering
  d2 <- delta_band(-1311, 515, 100, z = z)
  expect_lt(d2$agg_lo, d2$agg_hi)
  expect_equal(d2$agg_point, -131100)
})

# ---------------------------------------------------------------------------
test_that("concentration_curve is monotone, in [0,1], and sums to 1 (synthetic)", {
  cc <- concentration_curve(fips = c("A", "B", "C", "D"),
                            vuln = c(4, 3, 2, 1),          # A most vulnerable
                            weight = c(40, 30, 20, 10),
                            pop = c(1, 1, 1, 1))
  # sorted most-vulnerable-first => weights accumulate 0.4, 0.7, 0.9, 1.0
  expect_equal(cc$cum_burden_share, c(0.4, 0.7, 0.9, 1.0))
  expect_equal(cc$cum_pop_share, c(0.25, 0.5, 0.75, 1.0))
  expect_true(all(cc$cum_burden_share >= 0 & cc$cum_burden_share <= 1))
  expect_true(all(diff(cc$cum_burden_share) >= 0))       # monotone non-decreasing
  expect_equal(cc$cum_burden_share[nrow(cc)], 1)
  expect_equal(cc$cum_pop_share[nrow(cc)], 1)
  # top 25% (k=1) => most vulnerable county
  ts <- top_share(cc, 0.25)
  expect_equal(unname(ts["burden"]), 0.4)
  expect_equal(unname(ts["pop"]), 0.25)
})

# ---------------------------------------------------------------------------
test_that("real written concentration curves are valid Lorenz-style curves", {
  expect_gt(nrow(curve), 0)
  for (b in unique(curve$band)) {
    cb <- curve[curve$band == b, ]
    cb <- cb[order(cb$rank), ]
    expect_true(all(cb$cum_pop_share >= -1e-9 & cb$cum_pop_share <= 1 + 1e-9), info = b)
    expect_true(all(cb$cum_burden_share >= -1e-9 & cb$cum_burden_share <= 1 + 1e-9), info = b)
    expect_true(all(diff(cb$cum_pop_share) >= -1e-9), info = b)     # monotone
    expect_true(all(diff(cb$cum_burden_share) >= -1e-9), info = b)  # monotone
    expect_equal(cb$cum_pop_share[nrow(cb)], 1, tolerance = 1e-8, info = b)
    expect_equal(cb$cum_burden_share[nrow(cb)], 1, tolerance = 1e-8, info = b)
  }
})

# ---------------------------------------------------------------------------
test_that("unpriced-floor arithmetic matches a hand-computed reference", {
  # delta* = 7.4048658, benchmark 9.3333333 - 14.75 (PMPM).
  pt <- locate_passthrough()
  excl_lo <- pt$delta_star / pt$bench_lo
  excl_hi <- pt$delta_star / pt$bench_hi
  floor_lo <- 1 - excl_lo
  floor_hi <- 1 - excl_hi
  expect_equal(round(excl_lo, 4), 0.7934)     # ruled out > ~79% vs low benchmark
  expect_equal(round(excl_hi, 4), 0.5020)     # ruled out > ~50% vs high benchmark
  expect_equal(round(floor_lo, 4), 0.2066)    # >= ~21% unpriced floor
  expect_equal(round(floor_hi, 4), 0.4980)    # >= ~50% unpriced floor
  # dollar floor = benchmark - delta*
  expect_equal(round(pt$bench_lo - pt$delta_star, 4), 1.9285)
  expect_equal(round(pt$bench_hi - pt$delta_star, 4), 7.3451)
  # and the written row reproduces the shares
  fr <- bandrow("unpriced_margin_drought")
  expect_equal(fr$aggregate_ci_lo, floor_lo, tolerance = 1e-6)
  expect_equal(fr$aggregate_ci_hi, floor_hi, tolerance = 1e-6)
  # the floor is strictly between 0 and 1 and lo < hi
  expect_true(fr$aggregate_ci_lo > 0 && fr$aggregate_ci_hi < 1)
  expect_lt(fr$aggregate_ci_lo, fr$aggregate_ci_hi)
})

# ---------------------------------------------------------------------------
test_that("INPUT ANCHOR LOCK: every cited coefficient matches the frozen evidence table", {
  # (a) The script's own anchor check must pass end-to-end.
  anch <- verify_anchors()
  expect_true(all(anch$ok),
              info = paste("drifted anchors:",
                           paste(anch$anchor[!anch$ok], collapse = ", ")))

  # (b) INDEPENDENT hard-coded certified values (Plans/master_evidence_table.md),
  #     re-verified here so a change to the SCRIPT's constants alone cannot mask a
  #     table move. Checked against the live source-file locators.
  expect_equal(locate_medicare(shock = "CDD", term = "High_CDD")$estimate,      111.620936, tolerance = 1e-4)  # Row 10 heat t0
  expect_equal(locate_medicare(shock = "CDD", term = "High_CDD_Lag1")$estimate, 175.576630, tolerance = 1e-4)  # Row 10 heat L1
  expect_equal(locate_medicare(shock = "HDD", term = "High_HDD_Lag2")$estimate, 86.787960,  tolerance = 1e-4)  # Row 10 cold L2
  expect_equal(locate_passthrough()$delta_star, 7.404866, tolerance = 1e-4)                                    # Row 8 drought delta*
  expect_equal(locate_colddose()$estimate,      -5522.02202, tolerance = 1e-3)                                 # Row 17 cold dose
  expect_equal(locate_debtscar()$estimate,      0.0187376850, tolerance = 1e-7)                                # Row 16 debt scar
  expect_equal(locate_did2012()$att,            -1310.665380, tolerance = 1e-3)                                # Row 1 ITT
  expect_equal(locate_did2012()$wcb_lo,         -2911.159539, tolerance = 1e-2)                                # Row 1 WCB CI lo
  expect_equal(locate_did2012()$wcb_hi,         -138.613702,  tolerance = 1e-2)                                # Row 1 WCB CI hi
  expect_equal(locate_drdid()$att,              -1451.268144, tolerance = 1e-3)                                # Row 1 DRDID
  expect_equal(locate_pooled_e0()$att,          -324.397359,  tolerance = 1e-3)                                # Row 1 pooled e=0

  # (c) The coefficients WRITTEN into sufficient_stats.csv equal those certified values.
  expect_equal(bandrow("event_2012_income")$per_unit_coef,        -1310.665380, tolerance = 1e-3)
  expect_equal(bandrow("cold_cumulative_employment")$per_unit_coef, -5522.02202, tolerance = 1e-3)
  expect_equal(bandrow("drought_debt_scar")$per_unit_coef,          0.0187376850, tolerance = 1e-7)
  expect_equal(bandrow("heat_medicare_annual_t0")$per_unit_coef,    111.620936, tolerance = 1e-4)
  expect_equal(bandrow("typical_recurring_income")$per_unit_coef,   -324.397359, tolerance = 1e-3)
})

# ---------------------------------------------------------------------------
test_that("scenario bands are never summed and carry honest estimand labels", {
  # each band is a distinct row with its own estimand label (no total row exists)
  expect_false(any(grepl("total|national_total|sum_of_bands", stats$band, ignore.case = TRUE)))
  # the 2012 band is labeled event-specific / not annualizable
  expect_true(grepl("event-specific", bandrow("event_2012_income")$estimand_label))
  expect_true(grepl("not annualiz", bandrow("event_2012_income")$estimand_label, ignore.case = TRUE))
  # typical-recurring is a bounded null (CI spans zero)
  tr <- bandrow("typical_recurring_income")
  expect_lt(tr$aggregate_ci_lo, 0)
  expect_gt(tr$aggregate_ci_hi, 0)
  expect_true(grepl("BOUNDED NULL", tr$estimand_label))
  # cold band labeled exposure-history contrast (B6), not marginal causal
  expect_true(grepl("exposure-history", bandrow("cold_cumulative_employment")$estimand_label))
  # debt scar labeled measurement-fragile lower bound
  expect_true(grepl("MEASUREMENT-FRAGILE", bandrow("drought_debt_scar")$estimand_label))
  # no premium coefficient is multiplied by enrollment: the unpriced-floor row has NA count
  expect_true(is.na(bandrow("unpriced_margin_drought")$count))
})

# ---------------------------------------------------------------------------
test_that("RMA framing ratio equals |income loss| / RMA drought indemnity", {
  rr <- bandrow("rma_income_vs_drought_indemnity")
  a1 <- bandrow("event_2012_income")
  # count column holds the RMA drought indemnity denominator; ratio = |loss| / denom
  expect_equal(rr$aggregate_point, abs(a1$aggregate_point) / rr$count, tolerance = 1e-6)
  expect_gt(rr$aggregate_point, 0)
})

cat("\nAll policy sufficient-stats tests completed.\n")
