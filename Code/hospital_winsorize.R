# ===========================================================================
# hospital_winsorize.R
#   Within-year winsorization of hospital financial OUTCOME variables for the
#   NASHP CCN-panel analyses (run_hospital_incidence / _persistence /
#   _heterogeneity).  Track: audit_response_20260712, task 2.4 (audit Sec.8).
#
# WHY THIS EXISTS
#   process_hospital_panel.R applies NO winsorization, trimming, or outlier
#   filtering to the hospital financial levels or ratios. Raw NASHP Hospital
#   Cost Tool filings carry extreme values and accounting reversals:
#     * one -$461.6M net-charity-care restatement (CCN 050060, CA, 2012;
#       -$408.7M in the county master after zip->county allocation at fips 6019,
#       Fresno, 2012 — the "-$408M" flagged in descriptive reports), and 3,146
#       negative county-year charity totals overall;
#     * Hosp_UncompCare_Real spans -$461M to +$1.37B (p1/p99 = -$4.9M / +$97M);
#     * proportion outcomes reach -496% (operating margin) and +697%
#       (uncompensated care % of NPR).
#   Unwinsorized, Hosp_UncompCare_Real enters the levels regression in
#   run_hospital_incidence.R directly, and the proportion outcomes drive the
#   two published headlines (heat x safety-net uncompensated care; cumulative
#   climate-dose margins). That is the audit Sec.8 defense exposure.
#
# RULE (task 2.4)
#   Winsorize each analysis OUTCOME (LHS only) at the 1st / 99th percentile
#   WITHIN YEAR: each calendar year is trimmed to its own tails so that a
#   shifting NASHP sample/definition over 2011-2023 is not conflated with
#   genuine outliers. Shocks, moderators, dose counts, and market-structure
#   inputs are NOT touched. Applied in the ANALYSIS layer ONLY (never in
#   process_hospital_panel.R) so it cannot ripple into other tracks that read
#   Data/intermediate_hospital_panel.rds (e.g. run_mechanism_provider.R).
#
# ACTIVATION
#   Off by default; a run sets env var HOSP_WINSORIZE=1 to activate. When active,
#   the calling script winsorizes its outcomes and writes "*_winsorized" outputs
#   ALONGSIDE (never over) the raw outputs. Default runs are byte-for-byte
#   unchanged, so existing results and the scripts' unit tests are unaffected.
# ===========================================================================

# Winsorize a numeric vector to its two-sided [p, 1-p] quantiles.
# Degenerate windows (non-finite or crossed bounds) are returned unchanged.
winsorize_vec <- function(x, p = 0.01) {
  if (!is.numeric(x)) return(x)
  q  <- stats::quantile(x, probs = c(p, 1 - p), na.rm = TRUE, names = FALSE, type = 7)
  lo <- q[1]; hi <- q[2]
  if (!is.finite(lo) || !is.finite(hi) || lo > hi) return(x)
  pmin(pmax(x, lo), hi)
}

# Winsorize the named OUTCOME columns of df within each level of year_col.
# NA values are preserved (feols drops NA LHS regardless). Columns absent from
# df are silently skipped so callers can pass a superset of outcome names.
winsorize_within_year <- function(df, cols, p = 0.01, year_col = "Year") {
  cols <- intersect(cols, names(df))
  stopifnot(year_col %in% names(df))
  yr <- df[[year_col]]
  for (v in cols) {
    x <- df[[v]]
    for (y in unique(yr)) {
      idx <- which(yr == y)
      x[idx] <- winsorize_vec(x[idx], p = p)
    }
    df[[v]] <- x
  }
  df
}

# Is the winsorized robustness pass active for this run?
hosp_winsor_active <- function() identical(Sys.getenv("HOSP_WINSORIZE"), "1")

# Filename suffix for winsorized outputs ("" when inactive).
hosp_winsor_suffix <- function() if (hosp_winsor_active()) "_winsorized" else ""
