# =============================================================================
# test_control_sensitivity.R
#   Estimand-recovery, same-sample and schema tests for run_control_sensitivity.R
#   (track code_quality_remediation_20260713, task 3.1 / objective O4).
#
# Run (R 4.2.2, from the repo root):
#   & "C:/Program Files/R/R-4.2.2/bin/Rscript.exe" Code/tests/test_control_sensitivity.R
#
# ROBUST EXIT: assertions use bare top-level testthat expectations, which THROW on
# failure — so this file exits NON-ZERO on any failure (no false-green; audit A1).
# A final message + exit 0 prints only if every assertion passed.
# =============================================================================

suppressPackageStartupMessages({
  library(testthat)
  library(fixest)
})

# Source the analysis script. Its guarded main block (if sys.nframe()==0L) does NOT
# run when sourced, but the helpers + compute_control_sensitivity() become available
# (and Code/transition_symmetry.R + Code/cumulative_dose.R are sourced at its top).
source("Code/run_control_sensitivity.R")

section <- function(x) cat("\n== ", x, " ==\n", sep = "")

# One computation drives every assertion below.
RES <- compute_control_sensitivity("Data/county_level_master.csv")
TAB <- RES$table
ANC <- RES$anchors
SS  <- RES$sample_sens

CELLS    <- c("cold_debt", "drought_debt", "drought_asym", "cold_dose")
VARIANTS <- c("no_control", "lagged_control", "contemporaneous_control")

# ---------------------------------------------------------------------------
section("1. Output-table schema (task: output schema)")
req_cols <- c("cell", "variant", "coefficient", "SE", "p", "N", "pct_change_vs_no_control")
expect_true(all(req_cols %in% names(TAB)))
expect_equal(nrow(TAB), 12L)                             # 4 cells x 3 variants
expect_setequal(unique(TAB$cell), CELLS)
expect_setequal(unique(TAB$variant), VARIANTS)
expect_true(all(as.integer(table(TAB$cell)) == 3L))      # every cell has all 3 variants
expect_true(all(is.finite(TAB$coefficient)))
expect_true(all(is.finite(TAB$SE) & TAB$SE > 0))
expect_true(all(is.finite(TAB$p) & TAB$p >= 0 & TAB$p <= 1))
expect_true(all(is.finite(TAB$N) & TAB$N > 0))
cat("schema OK: 12 rows, required columns present, finite estimates.\n")

# ---------------------------------------------------------------------------
section("2. Identical-N across the three variants within each cell (task: identical-N)")
for (cn in CELLS) {
  Ns <- TAB$N[TAB$cell == cn]
  expect_equal(length(Ns), 3L)
  expect_equal(length(unique(Ns)), 1L)                   # same estimation sample
  cat(sprintf("  %-13s N = %d [equal across variants]\n", cn, unique(Ns)))
}

# ---------------------------------------------------------------------------
section("3. No-control baseline row bookkeeping")
base_rows <- TAB[TAB$variant == "no_control", ]
expect_equal(nrow(base_rows), 4L)
expect_true(all(base_rows$pct_change_vs_no_control == 0))          # 0% vs itself
expect_true(all(base_rows$materially_diff_vs_no_control == FALSE)) # not material vs itself

# ---------------------------------------------------------------------------
section("4. Variant-(iii) replication identity vs published production values")
# The three production anchors are reproduced via the exact production code paths
# and must land within their documented tolerances (tolerances documented in-file:
# county Spec-2 is post-dedup EXACT; delta + dose are PRE-DEDUP -> dedup-movement tol).
expect_equal(nrow(ANC), 3L)
expect_true(all(ANC$within_tolerance %in% TRUE))
a1 <- ANC[ANC$anchor == "run_county_analysis_Spec2_High_HDD_Lag1", ]
expect_equal(nrow(a1), 1L)
expect_lt(abs(a1$reproduced - 0.0013), 1e-4)             # post-dedup / current: EXACT
a3 <- ANC[ANC$anchor == "run_delta_asymmetry_h2", ]
expect_lt(abs(a3$reproduced - 0.0182300141210608), 1e-3) # pre-dedup published; dedup movement
a4 <- ANC[ANC$anchor == "run_cumulative_dose_binned_10p_vs_1to3", ]
expect_lt(abs(a4$reproduced - (-5667.549684693552)), 250)# pre-dedup published; dedup movement
cat("replication OK: all three production anchors within documented tolerance.\n")

# ---------------------------------------------------------------------------
section("5. Materiality flag matches the 0.1*SE(no-control) rule; %change arithmetic")
for (cn in CELLS) {
  b  <- TAB[TAB$cell == cn & TAB$variant == "no_control", ]
  for (v in c("lagged_control", "contemporaneous_control")) {
    r <- TAB[TAB$cell == cn & TAB$variant == v, ]
    # materiality definition: |coef - coef_nocontrol| > 0.1 * SE(no-control)
    expect_equal(isTRUE(r$materially_diff_vs_no_control),
                 abs(r$coefficient - b$coefficient) > 0.1 * b$SE)
    # pct_change_vs_no_control arithmetic
    expect_equal(r$pct_change_vs_no_control,
                 (r$coefficient - b$coefficient) / b$coefficient * 100, tolerance = 1e-8)
  }
}
cat("materiality + pct-change arithmetic consistent for all cells.\n")

# ---------------------------------------------------------------------------
section("6. Frozen three-variant design (no extra variants)")
expect_named(CONTROL_SETS, VARIANTS)
expect_equal(CONTROL_SETS$no_control, character(0))
expect_equal(CONTROL_SETS$lagged_control,
             c("Household_Income_2023_Lag1", "Uninsured_Rate_Lag1"))
expect_equal(CONTROL_SETS$contemporaneous_control,
             c("Household_Income_2023", "Uninsured_Rate"))
# the target terms are the frozen headline head-terms
tt <- unique(TAB[, c("cell", "target_term")])
expect_equal(tt$target_term[tt$cell == "cold_debt"],    "High_HDD_Lag1")
expect_equal(tt$target_term[tt$cell == "drought_debt"], "Is_Extreme_Drought_Lag2")

# ---------------------------------------------------------------------------
section("7. add_contemp_control_lags(): true year-matched t-1 lag (no positional bleed)")
df <- data.frame(
  fips_code = c("00001", "00001", "00001", "00002"),
  Year      = c(2011L, 2012L, 2013L, 2012L),
  Household_Income_2023 = c(10, 20, 30, 99),
  Uninsured_Rate        = c(0.1, 0.2, 0.3, 0.9),
  stringsAsFactors = FALSE)
out <- add_contemp_control_lags(df)
# county 1: 2012 carries 2011's value, 2013 carries 2012's; 2011 has no lag (NA)
expect_equal(out$Household_Income_2023_Lag1[out$fips_code == "00001" & out$Year == 2012], 10)
expect_equal(out$Household_Income_2023_Lag1[out$fips_code == "00001" & out$Year == 2013], 20)
expect_true(is.na(out$Household_Income_2023_Lag1[out$fips_code == "00001" & out$Year == 2011]))
# county 2 has no 2011 row -> its 2012 lag is NA (no cross-county / positional bleed)
expect_true(is.na(out$Uninsured_Rate_Lag1[out$fips_code == "00002" & out$Year == 2012]))

# ---------------------------------------------------------------------------
section("8. Sample-sensitivity diagnostic present for every cell")
expect_true(all(CELLS %in% SS$cell))
expect_true(all(is.finite(SS$full_sample_no_control_coef)))
expect_true(all(SS$full_sample_N >= SS$identical_sample_N))   # full >= identical sample

cat("\nAll control-sensitivity tests passed.\n")
