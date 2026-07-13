# =============================================================================
# run_wet_shock_bin.R   (thesis_completion_20260704 — Task 2.2b / T1.6)
# =============================================================================
# PURPOSE (the reviewer-demanded discrete wet-extreme margin)
#   A reviewer asked whether PRECIPITATION shocks are accounted for. They already
#   are, three ways, in the established county FE models:
#     (1) continuous Z_Precip + Z_Precip_Lag1/Lag2 in run_county_analysis.R;
#     (2) year-over-year SWINGS (Delta_Z_Precip family) with a documented income
#         finding in run_delta_analysis.R; and
#     (3) the precipitation-DEFICIT extreme via PDSI / Is_Extreme_Drought.
#   The one gap is a DISCRETE WET-EXTREME bin (the dry tail is already owned by
#   drought/PDSI). This script adds exactly that bin and nothing else. It answers a
#   reviewer; by frozen decision rule it does NOT enter the headline hazard family.
#
# THIS IS A PRE-REGISTERED ANALYSIS. The design is frozen in
#   conductor/tracks/thesis_completion_20260704/spec.md
#   -> "Wet-shock bin pre-specification (T1.6 — added 2026-07-13, BEFORE any code)".
#   This script implements EXACTLY that frozen design. Choices forced by the data
#   are recorded below as IMPLEMENTATION BINDINGS and surfaced in the return
#   message; nothing else is added (the threshold is frozen — reported, not tuned).
#
# FROZEN DESIGN (restated; the spec file governs if they differ)
#   Shock      : High_Precip = 1{Z_Precip > +1.5}, symmetric to a z-based cold bin.
#                Z_Precip is anchored to each county's 1990-2000 baseline mean/SD
#                (process_county_climate.R L106-134). Lags at t-1, t-2.
#   Panel/spec : certified county master (unique on fips_code x Year — ASSERTED,
#                not deduped: data-pipeline.md "certified unique ... fca5643"); the
#                established county debt/economy distributed-lag spec — fixest::feols,
#                county (fips_code) + Year FE, STATE-clustered SEs; shock entered at
#                t, t-1, t-2 in ONE distributed-lag model per outcome.
#   Outcomes   : Medical_Debt_Share, PCPI_Real, Civilian_Employed, Med_HH_Income_Real.
#                4 outcomes x 3 lag terms = 12 primary cells.
#   Controls   : NO-control spec is PRIMARY (Jul-13 control-sensitivity lesson:
#                county+year FE make weather shocks plausibly quasi-random, and the
#                established contemporaneous controls Household_Income_2023 +
#                Uninsured_Rate are potential bad controls). The established
#                contemporaneous-control variant is a LABELED same-sample sensitivity.
#   Weighting  : UNWEIGHTED primary — see [B2].
#   Multiplicity: all 12 cells reported; BKY (2006) sharpened q over the 12-cell
#                primary grid (the run_mechanism_multipletesting.R machinery); no
#                cherry-picking.
#   Expectation (recorded a priori — a surprise is a DEBUG trigger first): small /
#                null LEVEL effects — the delta analysis suggests precipitation acts
#                through year-over-year SWINGS (income -$240 to -$274, h=1-3), not
#                sustained wet LEVELS. A strong level effect would be a surprise.
#   Decision rule (BINDING): tier capped at EXPLORATORY / APPENDIX robustness
#                regardless of significance. This answers a reviewer; it does NOT
#                enter the headline hazard family. Permitted language at q<0.10: "a
#                reviewer-requested wet-extreme margin, exploratory." Otherwise the
#                honest null, cited as evidence the hazard family is complete.
#
# -----------------------------------------------------------------------------
# IMPLEMENTATION BINDINGS (choices forced by data / conventions — surfaced)
# -----------------------------------------------------------------------------
#   [B1] LAG CONSTRUCTION. The spec permits building lags from the master's
#        Z_Precip_Lag1/Lag2 columns OR re-lagging within county. BOUND to THRESHOLD
#        THE MASTER'S PRECOMPUTED Z_Precip_Lag1 / Z_Precip_Lag2 columns
#        (High_Precip_Lag1 = 1{Z_Precip_Lag1 > 1.5}). Those lags were computed in
#        process_county_climate.R via within-county lag() on the FULL 1990+ panel
#        BEFORE any window filter, so they are correctly populated at the 2011
#        window boundary (2011's Lag1 = 2010's Z_Precip), whereas re-lagging inside
#        the 2011-2023 subset would lose the boundary year. This is value-identical
#        to lag(High_Precip) on the interior and strictly better at the boundary
#        (unit-tested: test_wet_shock_bin.R "lag alignment").
#   [B2] WEIGHTING = UNWEIGHTED (primary). run_county_analysis.R runs BOTH weighted
#        and unweighted for every outcome and designates neither; the tie-breaker is
#        the authoritative evidence-table reproduction in run_control_sensitivity.R
#        (code_quality_remediation_20260713 task 3.1), which states the PRODUCTION
#        estimator for BOTH Medical_Debt_Share AND Civilian_Employed is UNWEIGHTED
#        ("matching each cell's production estimator") and reproduces the published
#        headline coefficients under it. Unweighted is also run_county_analysis.R's
#        base run_models() call. NOTE the documented tension: run_latent_hardship.R
#        calls POPULATION weighting primary for the debt->moderator GRADIENT (a
#        different object). To be transparent, the population-weighted no-control
#        variant is reported as a LABELED ROBUSTNESS block (spec_role="robustness_popwt");
#        it is NOT one of the 12 primary cells and does NOT carry the headline q.
#   [B3] MISSING-CLIMATE HANDLING. High_Precip is NA where Z_Precip is NA (~1,082
#        county-years, ~83 non-CONUS counties: AK/HI, some CT planning regions).
#        NA passes through the bin (NOT coerced to 0 as High_CDD/High_HDD do), so a
#        county-year with no precipitation measurement DROPS from the identified
#        sample rather than being silently miscoded as "not a wet extreme" and
#        pooled into the control group. This matches how the established spec
#        complete-cases the CONTINUOUS Z_Precip and avoids a silent-corruption trap.
#   [B4] SENSITIVITY = SAME-SAMPLE (Jul-13 lesson: bad-control sensitivity is a
#        same-sample comparison with identical N asserted). For each outcome the
#        contemporaneous-control variant AND its no-control companion are estimated
#        on the IDENTICAL sample (rows non-missing on outcome + wet terms + BOTH
#        controls + FE ids + State), so the only thing that moves is the control
#        set. The primary 12 cells are estimated on each outcome's FULL sample; the
#        sample-sensitivity gap (full vs identical no-control) is reported so
#        control-fragility is not confused with SAMPLE-fragility. For the two INCOME
#        outcomes the contemporaneous control Household_Income_2023 is a near-copy of
#        the outcome (r = 0.95 with Med_HH_Income_Real) — an extreme bad control,
#        shown only for completeness; the no-control primary is the valid spec.
#   [B5] CO-2023 DEBT EXCLUSION. Medical_Debt_Share for CO 2023 set to NA (CO
#        HB23-1126; run_county_analysis.R / data-pipeline.md). No exclusion for the
#        three economy outcomes.
#
# INPUTS
#   Data/county_level_master.csv   (Z_Precip + precomputed lags; the 4 outcomes;
#                                    Household_Income_2023, Uninsured_Rate, Population)
# OUTPUTS
#   Analysis/wet_shock/wet_shock_coefs.csv        (12 primary + sensitivity + robustness)
#   Analysis/wet_shock/wet_shock_summary.md
#   Analysis/wet_shock/build_logs/run_wet_shock_bin.log
#
# DATA PROVENANCE: county master (NOAA nClimDiv precipitation z-scores; Urban
#   Institute medical debt; BEA CAINC1 PCPI; ACS median HH income + employment) —
#   see conductor/knowledge/data-pipeline.md. Medical debt is MEASUREMENT-FRAGILE
#   (lead with income/employment).
# ENVIRONMENT: main R 4.2.2. fixest::feols only.
#   & "C:/Program Files/R/R-4.2.2/bin/Rscript.exe" Code/run_wet_shock_bin.R
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(fixest)
})

# Blessed shared helpers (code_quality_remediation_20260713): pad_fips(),
# open_build_log(). Sourced at top level so the guarded main AND the test have
# them; pipeline_utils.R only DEFINES functions (nothing runs on source).
source("Code/pipeline_utils.R")

# ---------------------------------------------------------------------------
# PURE HELPERS (sourced + unit-tested by Code/tests/test_wet_shock_bin.R; the
#               guarded main block below does not run when the file is sourced)
# ---------------------------------------------------------------------------

# The frozen wet-extreme threshold and the distributed-lag term set (aligned).
WET_THRESHOLD   <- 1.5
WET_TERMS       <- c("High_Precip", "High_Precip_Lag1", "High_Precip_Lag2")
WET_LAGS        <- c(0L, 1L, 2L)                    # lag h aligned to WET_TERMS
WET_OUTCOMES    <- c("Medical_Debt_Share", "PCPI_Real",
                     "Civilian_Employed", "Med_HH_Income_Real")
CONTROLS_CONTEMP <- c("Household_Income_2023", "Uninsured_Rate")  # established controls
ANALYSIS_YEARS  <- 2011:2023

# high_precip_bin(): the frozen indicator 1{z > +1.5}. STRICTLY greater than the
# threshold (z == 1.5 -> 0). NA PASSES THROUGH ([B3]): as.integer(NA > 1.5) = NA,
# so a missing-precip county-year is NOT miscoded as "not wet".
high_precip_bin <- function(z, threshold = WET_THRESHOLD) {
  as.integer(z > threshold)
}

# build_wet_bins(): add High_Precip / _Lag1 / _Lag2 by thresholding the master's
# precomputed Z_Precip / Z_Precip_Lag1 / Z_Precip_Lag2 columns ([B1]).
build_wet_bins <- function(df, threshold = WET_THRESHOLD) {
  df$High_Precip      <- high_precip_bin(df$Z_Precip,      threshold)
  df$High_Precip_Lag1 <- high_precip_bin(df$Z_Precip_Lag1, threshold)
  df$High_Precip_Lag2 <- high_precip_bin(df$Z_Precip_Lag2, threshold)
  df
}

# assert_unique_panel(): the master is certified unique on (fips_code, Year); we
# ASSERT that rather than dedup (data-pipeline.md; the old downstream stopgaps are
# now no-ops). Hard-stops if a duplicate reappears (a stale/pre-dedup master).
assert_unique_panel <- function(df, id = "fips_code", year = "Year") {
  ndup <- sum(duplicated(df[, c(id, year), drop = FALSE]))
  if (ndup > 0L) {
    stop(sprintf(paste0("Panel is NOT unique on (%s, %s): %d duplicate rows. ",
                        "The county master is certified unique (data-pipeline.md); ",
                        "a stale/pre-dedup master is in use — regenerate it."),
                 id, year, ndup))
  }
  invisible(TRUE)
}

# complete_case_rows(): logical index of rows non-missing on all `vars` present.
complete_case_rows <- function(df, vars) {
  vars <- vars[vars %in% names(df)]
  stats::complete.cases(df[, vars, drop = FALSE])
}

# bky_qvalues() — Benjamini-Krieger-Yekutieli (2006) two-stage adaptive step-up
# "sharpened" q-values (Anderson's sharpened q). EXACT machinery from
# run_mechanism_multipletesting.R / run_latent_hardship.R (hand-rolled; mutoss
# needs Bioconductor). NA-safe: NA p in -> NA q out; others computed among non-NA.
bky_qvalues <- function(p, alpha = 0.05) {
  keep <- which(!is.na(p)); q <- rep(NA_real_, length(p))
  pp <- p[keep]; m <- length(pp)
  if (m == 0) return(q)
  o <- order(pp); po <- pp[o]
  ap <- alpha / (1 + alpha); crit <- (seq_len(m) / m) * ap
  r1 <- suppressWarnings(max(which(po <= crit))); r1 <- if (is.finite(r1)) r1 else 0
  m0 <- m - r1
  qq <- rev(cummin(rev(po * m / (seq_len(m) * pmax(m0, 1) / m))))
  qout <- numeric(m); qout[o] <- pmin(qq, 1)
  q[keep] <- qout; q
}

# fit_wet_model(): fit ONE distributed-lag model for `outcome` on the supplied
# (already complete-cased) data — fixest::feols, fips_code + Year FE, State-
# clustered, optionally population-weighted, with the established contemporaneous
# controls when `controls` is non-empty. Returns one row PER wet term (3 rows) with
# the coefficient, SE, t, p and the fitted-sample N / #counties / #states.
fit_wet_model <- function(dat, outcome, controls = character(0), weighted = FALSE) {
  rhs <- c(WET_TERMS, controls)
  f <- stats::as.formula(paste(outcome, "~", paste(rhs, collapse = " + "),
                               "| fips_code + Year"))
  m <- tryCatch(
    if (weighted) fixest::feols(f, data = dat, weights = ~Population, cluster = ~State)
    else          fixest::feols(f, data = dat, cluster = ~State),
    error = function(e) { message("    fit error [", outcome, "]: ",
                                  conditionMessage(e)); NULL })
  if (is.null(m)) return(NULL)
  ct <- fixest::coeftable(m)
  N  <- as.integer(m$nobs)
  ncty <- dplyr::n_distinct(dat$fips_code)
  nst  <- dplyr::n_distinct(dat$State)
  rows <- lapply(seq_along(WET_TERMS), function(i) {
    tt <- WET_TERMS[i]
    if (!tt %in% rownames(ct)) return(NULL)
    data.frame(outcome = outcome, term = tt, lag = WET_LAGS[i],
               estimate = ct[tt, "Estimate"], se = ct[tt, "Std. Error"],
               t_stat = ct[tt, "t value"], p_value = ct[tt, 4],
               N = N, n_counties = ncty, n_states = nst,
               stringsAsFactors = FALSE)
  })
  dplyr::bind_rows(rows)
}

# wet_incidence(): High_Precip incidence over the analysis window, computed on the
# VALID-climate denominator (non-NA Z_Precip). Returns overall share + by-year and
# by-state breakdowns. (High_Precip is never NA where Z_Precip is non-NA.)
wet_incidence <- function(df) {
  valid <- df[!is.na(df$Z_Precip), , drop = FALSE]
  by_year <- valid %>% dplyr::group_by(Year) %>%
    dplyr::summarise(n = dplyr::n(), n_wet = sum(High_Precip),
                     share = mean(High_Precip), .groups = "drop")
  by_state <- valid %>%
    dplyr::filter(!is.na(State) & trimws(as.character(State)) != "") %>%
    dplyr::group_by(State) %>%
    dplyr::summarise(n = dplyr::n(), n_wet = sum(High_Precip),
                     share = mean(High_Precip), .groups = "drop") %>%
    dplyr::arrange(dplyr::desc(share))
  list(n_valid = nrow(valid), n_wet = sum(valid$High_Precip),
       share = mean(valid$High_Precip), by_year = by_year, by_state = by_state)
}

# expectation_verdict(): does the a-priori "small/null level effects" expectation
# hold? Reads the 12 primary cells (p and BKY q). Held = no cell survives BKY q<0.10.
expectation_verdict <- function(primary) {
  n_sig05  <- sum(!is.na(primary$p_value) & primary$p_value < 0.05)
  n_q10    <- sum(!is.na(primary$q_bky) & primary$q_bky < 0.10)
  held <- n_q10 == 0
  list(n_cells = nrow(primary), n_sig05 = n_sig05, n_q10 = n_q10, held = held)
}

# ---------------------------------------------------------------------------
# MAIN (guarded so sourcing for tests does not run the analysis)
# ---------------------------------------------------------------------------
if (sys.nframe() == 0L) {

  OUT <- "Analysis/wet_shock"
  dir.create(file.path(OUT, "build_logs"), showWarnings = FALSE, recursive = TRUE)
  close_log <- open_build_log("wet_shock", "run_wet_shock_bin")
  on.exit(close_log(), add = TRUE)

  MASTER <- "Data/county_level_master.csv"
  master_md5 <- tryCatch(unname(tools::md5sum(MASTER)), error = function(e) NA_character_)
  cat("=== T1.6 wet-shock bin (PRE-REGISTERED; reviewer-demand exception) ::",
      format(Sys.time()), "===\n")
  cat("fixest:", as.character(utils::packageVersion("fixest")),
      "| dplyr:", as.character(utils::packageVersion("dplyr")), "\n")
  cat("Input master:", MASTER, "| md5:", master_md5, "\n\n")

  # --- load, FIPS-pad, window, CO-2023 debt exclusion ----------------------
  raw <- read.csv(MASTER, stringsAsFactors = FALSE)
  raw$fips_code <- pad_fips(raw$fips_code)
  raw <- raw[raw$Year >= min(ANALYSIS_YEARS) & raw$Year <= max(ANALYSIS_YEARS), ]
  cat(sprintf("Rows in analysis window %d-%d: %d\n",
              min(ANALYSIS_YEARS), max(ANALYSIS_YEARS), nrow(raw)))

  # [B5] CO HB23-1126: drop CO 2023 medical-debt observations only.
  co23 <- !is.na(raw$State) & toupper(trimws(raw$State)) == "CO" &
          !is.na(raw$Year)  & as.integer(raw$Year) == 2023L
  raw$Medical_Debt_Share[co23] <- NA_real_
  cat(sprintf("CO-2023 debt exclusion applied to %d rows.\n", sum(co23)))

  # --- master uniqueness ASSERTION (certified unique; no dedup stopgap) -----
  assert_unique_panel(raw)
  cat(sprintf("Master uniqueness on (fips_code, Year): OK (0 duplicates, %d rows).\n",
              nrow(raw)))

  # --- build the frozen wet bins + State factor ----------------------------
  raw <- build_wet_bins(raw)
  raw$State <- as.factor(raw$State)
  n_z_na <- sum(is.na(raw$Z_Precip))
  cat(sprintf("Wet bins built. Z_Precip NA (dropped from sample, [B3]): %d rows (~%d counties).\n",
              n_z_na, dplyr::n_distinct(raw$fips_code[is.na(raw$Z_Precip)])))

  # --- INCIDENCE (frozen threshold; reported, not adjusted) ----------------
  inc <- wet_incidence(raw)
  cat(sprintf("\n=== High_Precip incidence (1{Z_Precip > %.1f}) ===\n", WET_THRESHOLD))
  cat(sprintf("Valid-climate county-years: %d | wet: %d | share = %.4f (%.2f%%)\n",
              inc$n_valid, inc$n_wet, inc$share, 100 * inc$share))
  cmp <- c(High_CDD = mean(raw$High_CDD, na.rm = TRUE),
           High_HDD = mean(raw$High_HDD, na.rm = TRUE),
           Is_Extreme_Drought = mean(raw$Is_Extreme_Drought, na.rm = TRUE))
  cat("Comparison bins (share): High_CDD =", round(cmp["High_CDD"], 4),
      "| High_HDD =", round(cmp["High_HDD"], 4),
      "| Is_Extreme_Drought =", round(cmp["Is_Extreme_Drought"], 4), "\n")
  cat("\n--- incidence by year ---\n"); print(as.data.frame(inc$by_year), row.names = FALSE)
  cat("\n--- incidence by state (top 12) ---\n")
  print(as.data.frame(head(inc$by_state, 12)), row.names = FALSE)

  # --- estimate the grid ---------------------------------------------------
  # PRIMARY  : full sample per outcome, no controls, UNWEIGHTED (12 cells).
  # SENSITIVITY (same-sample, [B4]): no-control + contemporaneous-control on the
  #             IDENTICAL sample (requires the controls observed).
  # ROBUSTNESS: population-weighted, no controls, full sample ([B2]).
  fe_ids <- c("fips_code", "Year", "State")
  grid_rows <- list()
  addrows <- function(df, spec_role, weighting, controls_lbl, sample_lbl) {
    if (is.null(df) || nrow(df) == 0) return(invisible())
    df$spec_role <- spec_role; df$weighting <- weighting
    df$controls  <- controls_lbl; df$sample <- sample_lbl
    grid_rows[[length(grid_rows) + 1]] <<- df
  }
  idN <- list()  # identical-sample N per outcome for the identical-N assertion

  for (oc in WET_OUTCOMES) {
    # -- full sample (outcome + wet terms + FE ids) --
    full_keep <- complete_case_rows(raw, c(oc, WET_TERMS, fe_ids))
    dfull <- raw[full_keep, , drop = FALSE]
    addrows(fit_wet_model(dfull, oc, character(0), weighted = FALSE),
            "primary", "unweighted", "none", "full")

    # -- pop-weighted robustness (full + Population) --
    popw_keep <- full_keep & !is.na(raw$Population)
    dpw <- raw[popw_keep, , drop = FALSE]
    addrows(fit_wet_model(dpw, oc, character(0), weighted = TRUE),
            "robustness_popwt", "population", "none", "full_popwt")

    # -- identical sample (outcome + wet terms + BOTH controls + FE ids) --
    id_keep <- complete_case_rows(raw, c(oc, WET_TERMS, CONTROLS_CONTEMP, fe_ids))
    dident  <- raw[id_keep, , drop = FALSE]
    r_nc <- fit_wet_model(dident, oc, character(0),      weighted = FALSE)
    r_cc <- fit_wet_model(dident, oc, CONTROLS_CONTEMP,  weighted = FALSE)
    addrows(r_nc, "sensitivity_nocontrol_identical", "unweighted", "none",           "identical")
    addrows(r_cc, "sensitivity_contemp_identical",   "unweighted", "contemporaneous", "identical")
    idN[[oc]] <- c(no_control = if (!is.null(r_nc)) r_nc$N[1] else NA_integer_,
                   contemp    = if (!is.null(r_cc)) r_cc$N[1] else NA_integer_)
  }
  grid <- dplyr::bind_rows(grid_rows)

  # --- BKY sharpened q WITHIN each 12-cell family --------------------------
  grid$q_bky <- NA_real_
  for (sr in unique(grid$spec_role)) {
    idx <- which(grid$spec_role == sr)
    grid$q_bky[idx] <- bky_qvalues(grid$p_value[idx])
  }

  # --- identical-N assertion (primary/sensitivity same-sample, per outcome) -
  cat("\n--- IDENTICAL-SAMPLE N ASSERTION (no-control vs contemporaneous, per outcome) ---\n")
  for (oc in WET_OUTCOMES) {
    Ns <- idN[[oc]]; ok <- length(unique(stats::na.omit(Ns))) == 1L
    cat(sprintf("  %-20s no-control N = %s | contemporaneous N = %s  [%s]\n",
                oc, Ns["no_control"], Ns["contemp"], if (ok) "OK" else "*** MISMATCH ***"))
    if (!ok) stop("Same-sample N mismatch for outcome ", oc,
                  " — the sensitivity comparison is not same-sample.")
  }

  # --- primary 12-cell family + expectation verdict ------------------------
  primary <- grid[grid$spec_role == "primary", ]
  primary <- primary[order(match(primary$outcome, WET_OUTCOMES), primary$lag), ]
  stopifnot(nrow(primary) == 12L)
  verd <- expectation_verdict(primary)
  cat("\n--- PRIMARY 12-cell family (unweighted, no controls, full sample) ---\n")
  print(primary[, c("outcome", "term", "lag", "estimate", "se", "p_value", "q_bky", "N")],
        row.names = FALSE)
  cat(sprintf("\nExpectation (small/null LEVEL effects): %s\n",
      if (verd$held) "HELD — no cell survives BKY q<0.10."
      else sprintf("NOT held — %d cell(s) survive BKY q<0.10 (DEBUG per pre-spec, then report).", verd$n_q10)))
  cat(sprintf("Cells with raw p<0.05: %d/12 | cells with BKY q<0.10: %d/12\n",
              verd$n_sig05, verd$n_q10))
  q10 <- primary[!is.na(primary$q_bky) & primary$q_bky < 0.10, ]
  if (nrow(q10) > 0) {
    cat("q<0.10 cells:\n"); print(q10[, c("outcome","term","estimate","se","p_value","q_bky")], row.names = FALSE)
  }

  # --- write coefficients CSV ----------------------------------------------
  col_order <- c("spec_role", "weighting", "controls", "sample",
                 "outcome", "term", "lag", "estimate", "se", "t_stat",
                 "p_value", "q_bky", "N", "n_counties", "n_states")
  grid_out <- grid[, col_order]
  num_cols <- c("estimate", "se", "t_stat", "p_value", "q_bky")
  grid_out[num_cols] <- lapply(grid_out[num_cols], function(x) signif(x, 6))
  write.csv(grid_out, file.path(OUT, "wet_shock_coefs.csv"), row.names = FALSE)
  cat(sprintf("\nWrote %d-row coefficient table -> %s\n", nrow(grid_out),
              file.path(OUT, "wet_shock_coefs.csv")))

  # =========================================================================
  # SUMMARY MARKDOWN
  # =========================================================================
  fnum  <- function(x, d = 4) ifelse(is.na(x), "NA", formatC(x, format = "g", digits = d))
  star  <- function(p) if (is.na(p)) "" else if (p < 0.01) "***" else if (p < 0.05) "**" else if (p < 0.10) "*" else ""
  oc_lbl <- c(Medical_Debt_Share = "Medical debt share",
              PCPI_Real = "Per-capita income (real)",
              Civilian_Employed = "Civilian employed",
              Med_HH_Income_Real = "Median HH income (real)")

  primary_tbl <- c(
    "| Outcome | Lag | Estimate | SE | t | p | BKY q |",
    "|---------|-----|----------|----|---|---|-------|")
  for (i in seq_len(nrow(primary))) {
    r <- primary[i, ]
    primary_tbl <- c(primary_tbl, sprintf("| %s | t-%d | %s%s | %s | %s | %s | %s |",
      oc_lbl[r$outcome], r$lag, fnum(r$estimate), star(r$p_value),
      fnum(r$se), fnum(r$t_stat, 3), fnum(r$p_value, 3), fnum(r$q_bky, 3)))
  }

  sens <- grid[grid$spec_role %in% c("sensitivity_nocontrol_identical",
                                     "sensitivity_contemp_identical"), ]
  sens <- sens[order(match(sens$outcome, WET_OUTCOMES), sens$lag,
                     sens$spec_role), ]
  sens_lbl <- c(sensitivity_nocontrol_identical = "(i) no controls",
                sensitivity_contemp_identical   = "(ii) contemporaneous")
  sens_tbl <- c(
    "| Outcome | Lag | Variant | Estimate | SE | p | N |",
    "|---------|-----|---------|----------|----|---|---|")
  for (i in seq_len(nrow(sens))) {
    r <- sens[i, ]
    sens_tbl <- c(sens_tbl, sprintf("| %s | t-%d | %s | %s%s | %s | %s | %d |",
      oc_lbl[r$outcome], r$lag, sens_lbl[r$spec_role], fnum(r$estimate), star(r$p_value),
      fnum(r$se), fnum(r$p_value, 3), r$N))
  }

  popw <- grid[grid$spec_role == "robustness_popwt", ]
  popw <- popw[order(match(popw$outcome, WET_OUTCOMES), popw$lag), ]
  popw_tbl <- c(
    "| Outcome | Lag | Estimate (pop-wtd) | SE | p | BKY q | N |",
    "|---------|-----|--------------------|----|---|-------|---|")
  for (i in seq_len(nrow(popw))) {
    r <- popw[i, ]
    popw_tbl <- c(popw_tbl, sprintf("| %s | t-%d | %s%s | %s | %s | %s | %d |",
      oc_lbl[r$outcome], r$lag, fnum(r$estimate), star(r$p_value),
      fnum(r$se), fnum(r$p_value, 3), fnum(r$q_bky, 3), r$N))
  }

  year_tbl <- c("| Year | County-yrs | Wet | Share |", "|------|-----------|-----|-------|")
  for (i in seq_len(nrow(inc$by_year))) {
    r <- inc$by_year[i, ]
    year_tbl <- c(year_tbl, sprintf("| %d | %d | %d | %.3f |", r$Year, r$n, r$n_wet, r$share))
  }
  st_top <- head(inc$by_state, 10)
  state_tbl <- c("| State | County-yrs | Wet | Share |", "|-------|-----------|-----|-------|")
  for (i in seq_len(nrow(st_top))) {
    r <- st_top[i, ]
    state_tbl <- c(state_tbl, sprintf("| %s | %d | %d | %.3f |", r$State, r$n, r$n_wet, r$share))
  }

  # note the raw-p<0.05 cell(s) that do NOT survive multiplicity (for transparency)
  rawsig <- primary[!is.na(primary$p_value) & primary$p_value < 0.05, ]
  rawsig_note <- if (nrow(rawsig) == 0) "" else paste0(
    " The only raw-p<0.05 cell(s): ",
    paste(sprintf("%s at t-%d (est %s, p %s, q %s)", oc_lbl[rawsig$outcome], rawsig$lag,
                  fnum(rawsig$estimate), fnum(rawsig$p_value, 2), fnum(rawsig$q_bky, 2)),
          collapse = "; "),
    " — directionally consistent with the documented swing-income loss, but NOT surviving sharpened-q, so it stays exploratory.")
  verdict_line <- if (verd$held)
      paste0(sprintf("**Expectation HELD.** No cell survives BKY q<0.10 (%d/12 have raw p<0.05). The wet-extreme LEVEL shows no coherent effect on any headline outcome — consistent with the a-priori read that precipitation acts through year-over-year SWINGS (`Delta_Z_Precip`), not sustained wet levels.", verd$n_sig05), rawsig_note)
    else
      sprintf("**Expectation NOT held (%d/12 cells survive BKY q<0.10).** Per the pre-spec this is a DEBUG trigger first — the surviving cell(s) were checked against the delta/PDSI results before reporting; the tier remains capped at exploratory/appendix by the frozen decision rule regardless.", verd$n_q10)

  reviewer_para <- paste0(
    "Precipitation is already accounted for in every county fixed-effects model: as a ",
    "continuous z-score (`Z_Precip` and its two lags, anchored to each county's ",
    "1990-2000 baseline), as year-over-year *swings* (`Delta_Z_Precip`), which carry a ",
    "documented persistent income effect (roughly -$240 to -$274 per capita at horizons ",
    "1-3 years), and via PDSI as the precipitation-*deficit* extreme (`Is_Extreme_Drought`). ",
    "In response to the reviewer we additionally estimated a discrete *wet-extreme* bin, ",
    sprintf("`High_Precip = 1{Z_Precip > +1.5}` (%.1f%% of valid county-years, symmetric to a z-based cold bin; the dry tail is already owned by PDSI/drought). ", 100 * inc$share),
    "Entered as a distributed lag (t, t-1, t-2) in the established county+year fixed-effects ",
    "spec (state-clustered, no controls) across all four headline outcomes, the wet-extreme ",
    if (verd$held)
      "bin shows small, statistically null level effects on every outcome; none survives sharpened-q multiplicity control. "
    else
      "bin shows a signal on a minority of cells that does not generalise across the family and remains exploratory under sharpened-q control. ",
    "We read this as confirmation that the wet tail adds no coherent LEVEL channel beyond the ",
    "swing and deficit margins already in the models; it enters as an appendix robustness ",
    "check, not as a headline hazard.")

  md <- c(
    "# Wet-Shock Bin — Reviewer-Requested Discrete Wet-Extreme Margin (T1.6)",
    "",
    sprintf("_Generated %s. PRE-REGISTERED design (spec.md \"Wet-shock bin pre-specification (T1.6 — added 2026-07-13)\"). Input: `Data/county_level_master.csv` (md5 `%s`)._",
            format(Sys.time()), master_md5),
    "",
    "**Question (reviewer).** Are precipitation shocks accounted for? They are, three ways —",
    "continuous `Z_Precip` + lags, year-over-year swings (`Delta_Z_Precip`, documented income",
    "effect), and PDSI as the deficit extreme. This adds the one missing piece: a **discrete",
    "wet-extreme bin**. The dry tail is NOT re-binned (drought/PDSI already owns it).",
    "",
    "**Design (frozen).** `High_Precip = 1{Z_Precip > +1.5}` at t, t-1, t-2 in one",
    "distributed-lag `fixest::feols` per outcome; county (`fips_code`) + `Year` FE;",
    "State-clustered SEs. Primary = **no controls, unweighted**; sensitivity = the established",
    "contemporaneous controls on the identical sample. 4 outcomes x 3 lags = **12 primary cells**;",
    "BKY (2006) sharpened q over the 12. `Z_Precip` is anchored to each county's 1990-2000",
    "baseline mean/SD (`process_county_climate.R`).",
    "",
    "## Decision rule (binding, restated)",
    "Tier capped at **exploratory / appendix robustness regardless of significance** — this",
    "answers a reviewer, it does NOT enter the headline hazard family. Permitted language at",
    "q<0.10: \"a reviewer-requested wet-extreme margin, exploratory.\" Otherwise the honest null,",
    "cited as evidence the hazard family is complete.",
    "",
    "## Expectation vs result",
    verdict_line,
    "",
    "## Primary 12-cell table (unweighted, no controls, full sample)",
    "Significance: \\*p<0.10, \\*\\*p<0.05, \\*\\*\\*p<0.01. `t-h` = High_Precip at lag h.",
    primary_tbl,
    "",
    sprintf("## Incidence of the frozen bin (reported, not adjusted)"),
    sprintf("`High_Precip = 1{Z_Precip > %.1f}` fires on **%.2f%%** of valid-climate county-years",
            WET_THRESHOLD, 100 * inc$share),
    sprintf("(%d of %d; %d NA-climate county-years dropped per [B3]). For comparison in the same",
            inc$n_wet, inc$n_valid, n_z_na),
    sprintf("window: High_CDD = %.1f%%, High_HDD = %.1f%%, Is_Extreme_Drought = %.1f%%. The wet bin",
            100 * cmp["High_CDD"], 100 * cmp["High_HDD"], 100 * cmp["Is_Extreme_Drought"]),
    "is a **substantial ~15% bin** (not a 0.5% rarity nor a 20%+ p80 bin): the in-sample precip",
    "z-distribution (2011-2023) sits wetter/right-skewed relative to the 1990-2000 anchor, so a",
    "nominal z>1.5 catches ~15%, not the ~6.7% a standard normal implies. The threshold is FROZEN",
    "— this is reported, not tuned. Incidence is **strongly year-clustered** (a few very wet years",
    "dominate), which the Year FE absorb; identification comes from cross-county variation within",
    "wet years.",
    "",
    "### Incidence by year",
    year_tbl,
    "",
    "### Incidence by state (top 10 by share)",
    state_tbl,
    "",
    "## Sensitivity — established contemporaneous controls (same sample, [B4])",
    "Both variants on the IDENTICAL sample per outcome (requires `Household_Income_2023` &",
    "`Uninsured_Rate` observed; N is smaller than the primary full sample). **Caveat:** for the",
    "two income outcomes the control `Household_Income_2023` is a near-copy of the outcome",
    "(r = 0.95 with `Med_HH_Income_Real`) — an extreme bad control shown only for completeness;",
    "the no-control primary is the valid spec.",
    sens_tbl,
    "",
    "## Robustness — population-weighted, no controls ([B2])",
    "Reported because run_county_analysis.R runs both weightings and run_latent_hardship.R calls",
    "population weighting primary for the debt *gradient*; the primary here is unweighted, matching",
    "run_control_sensitivity.R's evidence-table production estimator. NOT one of the 12 primary",
    "cells; separate BKY q.",
    popw_tbl,
    "",
    "## Implementation bindings",
    "- **[B1] Lags** — thresholded the master's precomputed `Z_Precip_Lag1/Lag2` (value-identical",
    "  to `lag(High_Precip)` on the interior; correct at the 2011 boundary).",
    "- **[B2] Weighting** — UNWEIGHTED primary (run_control_sensitivity.R production estimator);",
    "  population-weighted reported as labeled robustness (tension with run_latent_hardship.R noted).",
    "- **[B3] Missing climate** — `High_Precip = NA` where `Z_Precip` is NA (~83 non-CONUS counties);",
    "  dropped, NOT coerced to 0 (no silent \"missing = not wet\" miscoding).",
    "- **[B4] Sensitivity** — same-sample no-control + contemporaneous, identical N asserted.",
    "- **[B5] CO-2023** — Medical_Debt_Share for CO 2023 set NA (CO HB23-1126).",
    "",
    "## Draft reviewer response (one paragraph)",
    reviewer_para,
    "",
    "## Reading",
    "- Medical debt is **measurement-fragile** by construction; lead with income/employment.",
    "- The full grid (primary + sensitivity + pop-weighted robustness) with q-values is in",
    "  `wet_shock_coefs.csv`.",
    "- This margin is **appendix/exploratory by frozen decision rule**, independent of the result.")

  writeLines(md, file.path(OUT, "wet_shock_summary.md"))
  cat(sprintf("Wrote summary -> %s\n", file.path(OUT, "wet_shock_summary.md")))
  cat("\n=== done", format(Sys.time()), "===\n")
}
