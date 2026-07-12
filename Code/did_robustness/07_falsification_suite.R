# =============================================================================
# DiD Frontier-Robustness — 07. Falsification Suite for the 2012 Drought 2x2
# =============================================================================
# PURPOSE
#   Two committee-facing falsification tests for the headline 2012 drought
#   natural-experiment 2x2 DiD (the −$1,311 PCPI result). These answer the two
#   most likely attacks on a few-treated-cluster design:
#     PART A  Leave-one-treated-state-out (LOO): is the ATT carried by a single
#             (Corn-Belt) state, or is it a broad multi-state contrast?
#     PART B  Placebo onset years among never-exposed controls: is an effect of
#             this magnitude routinely produced by chance when a fake cohort is
#             assigned a fake onset year in the never-treated pool?
#
#   This is O5 of the audit_response_20260712 track (spec.md O5; plan tasks
#   2.2 + 2.3). It reuses the *exact* 2x2 machinery of 01_wild_cluster_bootstrap.R
#   — it does not re-derive the design. The number 07 is deliberate: 06_ is
#   reserved for the de Chaisemartin estimator (track task T2.2).
#
# ---------------------------------------------------------------------------
# REQUIRED R VERSION: **R 4.5.3** (project two-R boundary — Code/did_robustness/
#   is the ONLY code that runs on 4.5.3). This particular script needs only
#   dplyr + fixest (both exist on 4.2.2 too), which is why its pure functions
#   are unit-tested on 4.2.2 by Code/tests/test_falsification_suite.R. Run it,
#   however, on 4.5.3 to stay inside the frontier-DiD convention:
#     & "C:/Program Files/R/R-4.5.3/bin/Rscript.exe" Code/did_robustness/07_falsification_suite.R
#   NEVER inline `Rscript -e`. Self-logs via sink() (environment.md convention).
#
# INPUTS
#   Data/county_level_master.csv  (via load_did_panel() in 00_did_robustness_common.R:
#     dedup, CO-2023 medical-debt exclusion, 2011–2023 window).
#   Cohorts, 2x2 frame, treated/never-exposed split: build_cohorts() +
#     did_2x2_frame() from the same common file — replicated EXACTLY, not reinvented.
#
# OUTPUTS (all under Analysis/did/robustness/)
#   falsification_loo_state.csv      one row per LOO scenario (row 0 = no drop),
#                                    wide over both outcomes.
#   falsification_placebo_onsets.csv B=1000 rows: draw, pseudo_onset_year, placebo_att.
#   falsification_summary.md         verdicts (LOO envelope + placebo tail).
#   build_logs/07_falsification_suite.log   full run log (sink).
#
# PROVENANCE / BENCHMARKS (must reproduce)
#   Benchmark 2x2 (Analysis/did/robustness/wild_bootstrap_2x2.csv, commit-tracked):
#     PCPI_Real         ATT = -1310.6654  SE 577.25  p 0.0277  N 34086
#     Civilian_Employed ATT = -2042.6673  SE 475.49  p 8.4e-5  N 34048
#     Wild cluster bootstrap (Webb) 95% CI for PCPI: [-2911.16, -138.61].
#     Treated cohort = first extreme-drought onset in 2012 = 139 counties in 17
#     states; never-exposed control pool = 2534 counties. The 2x2 estimator is
#       feols(y ~ TxP | fips_code + Year, cluster = ~State), on !is.na(y) rows.
#   The LOO "no state dropped" row (row 0) re-runs this identical spec and MUST
#   reproduce the benchmark ATT — that reproduction is itself one of the tests.
#
# =============================================================================
# PRE-REGISTRATION (this header is the pre-specification; written BEFORE any
#                   estimation code, per workflow expectation-first principle)
# =============================================================================
#
# PART A — LEAVE-ONE-TREATED-STATE-OUT (task 2.2)
#   • Identify the 17 states that contain >=1 of the 139 treated (2012-onset)
#     counties (stopifnot == 17).
#   • Row 0 = no-drop baseline (reproduces the benchmark 2x2 ATT).
#   • For each of the 17 treated states in turn: DROP ALL counties in that state
#     (treated AND never-exposed control alike — a full geographic excision),
#     then re-estimate the identical 2x2 ATT
#       feols(y ~ TxP | fips_code + Year, cluster = ~State)
#     on the remaining counties, for PCPI_Real (primary) and Civilian_Employed
#     (secondary). Output per row: state dropped, treated counties/states
#     remaining, and ATT/SE/p/N for BOTH outcomes.
#   • Verdicts reported: ATT envelope (min/max across the 17 drops); the states
#     that move the estimate most; whether ANY single drop pushes the PCPI point
#     estimate outside the wild-bootstrap CI [-2911.16, -138.61] or its analytic
#     p above 0.05 (significance flip).
#   • EXPECTATION (recorded now): no single-state drop moves income outside the
#     WCB CI; treated counties are geographically concentrated (GA 45, CO 21,
#     NE 17, NM 10), so one or two states will dominate MAGNITUDE — reported
#     honestly whichever way it falls.
#
# PART B — PLACEBO ONSET YEARS (task 2.3) — DESIGN FROZEN HERE
#   • Universe: NEVER-EXPOSED counties ONLY (cohort == 0, the 2x2 control pool),
#     restricted to those with >=1 non-missing PCPI_Real observation (the
#     analyzable pool, so each pseudo-treated county actually contributes data,
#     mirroring the real 139-county treated cohort). No treated county ever
#     enters as a pseudo-treated unit.
#   • B = 1000 draws. set.seed(20260712).
#   • Per draw: (i) sample 139 never-exposed counties WITHOUT replacement as the
#     pseudo-treated cohort; (ii) draw ONE shared pseudo-onset year g ~ Uniform
#     {2013,...,2019} (one g per draw, mirroring a single cohort event);
#     (iii) build the identical 2x2 — Post = 1{Year >= g}, treated = the 139
#     pseudo units, control = the remaining never-exposed counties — and
#     estimate the ATT for PCPI_Real with the identical feols(y ~ TxP |
#     fips_code + Year) estimator (SEs not needed for the reference distribution;
#     the point estimate is all the placebo uses).
#   • Report: mean, SD, and the 2.5 / 5 / 95 / 97.5 percentiles of the placebo
#     ATT distribution; placebo p-value = share of draws with |placebo ATT| >=
#     |real ATT| (real = -1310.67, ~1,311).
#   • EXPECTATION (recorded now): the placebo distribution is centered on ~0 with
#     the real 2012 estimate in the tail (complements the existing randomization
#     inference, p_ri = 0.0075).
#   • NOT RE-RUN: the audit's "future shocks predict past outcomes" check is
#     already covered by the flat 1990–2011 BEA pre-trend (-$69/yr, p=0.44,
#     Analysis/did/robustness/bea_pretrends_1990_2011.csv). Recorded in the
#     summary as a covered falsification, not repeated here.
#
# DECISION RATIONALE (why these choices)
#   • Full geographic excision (drop control counties too, not just treated) is
#     the honest LOO: it removes a state's entire contribution to both arms so
#     the remaining contrast is genuinely "the other 16 states."
#   • Placebo restricted to the analyzable never-exposed pool keeps every draw at
#     139 effective treated counties and keeps the estimator identical to the
#     benchmark — a fair null reference, not a degraded one.
#   • Full feols per placebo draw (not an FWL shortcut) uses the SAME estimator
#     the headline uses; at ~24 s for B=1000 the shortcut is unnecessary. (The
#     FWL identity is separately unit-tested for the wild bootstrap in 01_.)
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
})
source("Code/did_robustness/00_did_robustness_common.R")

# ----------------------------- constants -------------------------------------
FALS_SEED         <- 20260712L          # placebo RNG seed (pre-registered)
EVENT_YEAR        <- 2012L
B_PLACEBO         <- 1000L
ONSET_YEARS       <- 2013:2019          # pseudo-onset support (shared g per draw)
PRIMARY_OUTCOME   <- "PCPI_Real"
SECONDARY_OUTCOME <- "Civilian_Employed"
LOO_OUTCOMES      <- c(PRIMARY_OUTCOME, SECONDARY_OUTCOME)

# Benchmark references (Analysis/did/robustness/wild_bootstrap_2x2.csv).
BENCH_PCPI_ATT <- -1310.6654
BENCH_EMP_ATT  <- -2042.6673
WCB_CI_LO      <- -2911.16
WCB_CI_HI      <- -138.61

# short column prefix for each outcome (keeps the wide LOO schema readable)
outcome_prefix <- function(y) {
  switch(y, PCPI_Real = "pcpi", Civilian_Employed = "emp",
         tolower(gsub("[^A-Za-z0-9]", "", y)))
}

# -----------------------------------------------------------------------------
# identify_treated_states(): the states containing >=1 first-onset (2012) county.
# -----------------------------------------------------------------------------
identify_treated_states <- function(cohorts, panel, event_year = EVENT_YEAR) {
  tr_fips <- cohorts$fips_code[cohorts$cohort == event_year]
  st <- unique(panel$State[panel$fips_code %in% tr_fips])
  sort(st[!is.na(st)])
}

never_exposed_fips <- function(cohorts) {
  cohorts$fips_code[cohorts$cohort == 0L]
}

# -----------------------------------------------------------------------------
# loo_att(): the 2x2 ATT for one outcome, optionally dropping ALL counties in
# `drop_state`. Estimator is IDENTICAL to the benchmark 2x2 in 01_.
#   drop_state = NA (or "(none)") -> no drop (row-0 baseline).
# -----------------------------------------------------------------------------
loo_att <- function(frame, drop_state = NA_character_, y) {
  d <- frame
  if (!is.na(drop_state) && drop_state != "(none)") {
    d <- d[d$State != drop_state, , drop = FALSE]
  }
  d <- d[!is.na(d[[y]]), , drop = FALSE]
  d$State <- factor(d$State)
  m <- feols(as.formula(paste(y, "~ TxP | fips_code + Year")),
             data = d, cluster = ~State)
  list(att = unname(coef(m)["TxP"]),
       se  = unname(se(m)["TxP"]),
       p   = unname(pvalue(m)["TxP"]),
       n   = nobs(m))
}

# -----------------------------------------------------------------------------
# run_loo(): wide LOO table. Row 0 = "(none)" baseline, then one row per treated
# state. n_treated_remaining / n_treated_states_remaining are cohort-level
# (outcome-independent); ATT/SE/p/N are per outcome.
# -----------------------------------------------------------------------------
run_loo <- function(frame, treated_states, outcomes = LOO_OUTCOMES) {
  states_seq <- c("(none)", sort(treated_states))
  rows <- vector("list", length(states_seq))
  for (i in seq_along(states_seq)) {
    st   <- states_seq[i]
    drop <- if (st == "(none)") NA_character_ else st
    keep_treated <- frame$Treated == 1 &
      (is.na(drop) | frame$State != drop)
    row <- data.frame(
      state_dropped              = st,
      n_treated_remaining        = length(unique(frame$fips_code[keep_treated])),
      n_treated_states_remaining = length(unique(frame$State[keep_treated])),
      stringsAsFactors = FALSE)
    for (y in outcomes) {
      r  <- loo_att(frame, drop, y)
      px <- outcome_prefix(y)
      row[[paste0(px, "_att")]] <- r$att
      row[[paste0(px, "_se")]]  <- r$se
      row[[paste0(px, "_p")]]   <- r$p
      row[[paste0(px, "_n")]]   <- r$n
    }
    rows[[i]] <- row
  }
  do.call(rbind, rows)
}

# -----------------------------------------------------------------------------
# run_placebo(): PART B. Never-exposed-only pseudo-cohorts with pseudo-onset
# years; frozen design in the header. Returns the per-draw distribution plus
# provenance fields the tests assert on (pool, used_fips).
# -----------------------------------------------------------------------------
run_placebo <- function(panel, cohorts, y = PRIMARY_OUTCOME,
                        n_treated = 139L, B = B_PLACEBO,
                        onset_years = ONSET_YEARS, seed = FALS_SEED) {
  nev_fips <- never_exposed_fips(cohorts)
  d <- panel[panel$fips_code %in% nev_fips & !is.na(panel[[y]]), , drop = FALSE]
  d$State <- factor(d$State)
  pool <- unique(d$fips_code)                       # analyzable never-exposed pool
  stopifnot(length(pool) >= n_treated)
  fml <- as.formula(paste(y, "~ TxP | fips_code + Year"))

  set.seed(seed)
  draw_year <- integer(B)
  draw_att  <- numeric(B)
  seen      <- setNames(logical(length(pool)), pool)   # provenance for tests
  for (b in seq_len(B)) {
    g  <- sample(onset_years, 1L)
    pl <- sample(pool, n_treated)
    d$TxP <- as.integer(d$fips_code %in% pl) * as.integer(d$Year >= g)
    m <- feols(fml, data = d)
    draw_year[b] <- g
    draw_att[b]  <- unname(coef(m)["TxP"])
    seen[pl] <- TRUE
  }
  dist <- data.frame(draw = seq_len(B),
                     pseudo_onset_year = draw_year,
                     placebo_att = draw_att,
                     stringsAsFactors = FALSE)
  list(dist = dist, pool = pool, n_pool = length(pool),
       used_fips = names(seen)[seen], onset_years = onset_years,
       n_treated = n_treated)
}

# -----------------------------------------------------------------------------
# write_summary(): assemble falsification_summary.md from the two result sets.
# -----------------------------------------------------------------------------
write_summary <- function(loo_df, pb, real_att, path) {
  base <- loo_df[loo_df$state_dropped == "(none)", ]
  loo  <- loo_df[loo_df$state_dropped != "(none)", ]

  # PART A verdicts
  pcpi_env <- range(loo$pcpi_att)
  emp_env  <- range(loo$emp_att)
  infl_pcpi <- loo$state_dropped[order(-abs(loo$pcpi_att - base$pcpi_att))][1:3]
  infl_emp  <- loo$state_dropped[order(-abs(loo$emp_att  - base$emp_att))][1:3]
  ci_exit   <- loo$state_dropped[loo$pcpi_att < WCB_CI_LO | loo$pcpi_att > WCB_CI_HI]
  sig_flip  <- loo$state_dropped[loo$pcpi_p > 0.05]
  sig_flip_e<- loo$state_dropped[loo$emp_p  > 0.05]

  # PART B verdicts
  att   <- pb$dist$placebo_att
  qs    <- quantile(att, c(0.025, 0.05, 0.95, 0.975))
  p_two <- mean(abs(att) >= abs(real_att))
  p_lo  <- mean(att <= real_att)   # one-sided (more negative than real)

  L <- c(
    "# Falsification Suite — 2012 Drought 2x2 DiD",
    "",
    sprintf("Generated by `Code/did_robustness/07_falsification_suite.R` (R 4.5.3), seed %d.", FALS_SEED),
    "Estimand: effect of *first* drought onset (ITT). Estimator (identical to the",
    "benchmark 2x2): `feols(y ~ TxP | fips_code + Year, cluster = ~State)`.",
    sprintf("Benchmark references: PCPI ATT %.1f (WCB 95%% CI [%.0f, %.0f]); employment ATT %.1f.",
            BENCH_PCPI_ATT, WCB_CI_LO, WCB_CI_HI, BENCH_EMP_ATT),
    "",
    "## Part A — Leave-one-treated-state-out",
    "",
    sprintf("No-drop baseline (row 0): PCPI ATT **%.1f** (SE %.1f, p %.4f), employment ATT **%.1f** (p %.4g).",
            base$pcpi_att, base$pcpi_se, base$pcpi_p, base$emp_att, base$emp_p),
    sprintf("- Baseline reproduces benchmark PCPI ATT (%.1f) to |Δ| = %.3g. %s",
            BENCH_PCPI_ATT, abs(base$pcpi_att - BENCH_PCPI_ATT),
            if (abs(base$pcpi_att - BENCH_PCPI_ATT) < 1) "PASS." else "**CHECK.**"),
    "",
    sprintf("Dropping each of the 17 treated states in turn (full geographic excision of treated + control counties):"),
    "",
    sprintf("- **PCPI_Real ATT envelope:** [%.1f, %.1f] (baseline %.1f).",
            pcpi_env[1], pcpi_env[2], base$pcpi_att),
    sprintf("- **Civilian_Employed ATT envelope:** [%.1f, %.1f] (baseline %.1f).",
            emp_env[1], emp_env[2], base$emp_att),
    sprintf("- Most influential drops (|ΔATT| vs baseline) — PCPI: %s; employment: %s.",
            paste(infl_pcpi, collapse = ", "), paste(infl_emp, collapse = ", ")),
    sprintf("- PCPI point estimate leaves the wild-bootstrap CI [%.0f, %.0f] on dropping: %s.",
            WCB_CI_LO, WCB_CI_HI,
            if (length(ci_exit) == 0) "**none** (all 17 drops stay inside)" else paste(ci_exit, collapse = ", ")),
    sprintf("- PCPI analytic significance flips (p > 0.05) on dropping: %s.",
            if (length(sig_flip) == 0) "**none** (income stays significant throughout)" else paste(sig_flip, collapse = ", ")),
    sprintf("- Employment analytic significance flips (p > 0.05) on dropping: %s.",
            if (length(sig_flip_e) == 0) "none" else paste(sig_flip_e, collapse = ", ")),
    "",
    "Full per-state table: `falsification_loo_state.csv`.",
    "",
    "## Part B — Placebo onset years (never-exposed pool)",
    "",
    sprintf("B = %d draws; %d-county pseudo-cohorts sampled without replacement from the",
            B_PLACEBO, pb$n_treated),
    sprintf("%d-county analyzable never-exposed pool; shared pseudo-onset g ~ U{%d..%d}; seed %d.",
            pb$n_pool, min(pb$onset_years), max(pb$onset_years), FALS_SEED),
    "",
    sprintf("- Placebo ATT distribution: mean **%.1f**, SD %.1f.", mean(att), sd(att)),
    sprintf("- Percentiles: 2.5%% %.1f | 5%% %.1f | 95%% %.1f | 97.5%% %.1f.",
            qs[1], qs[2], qs[3], qs[4]),
    sprintf("- Range: [%.1f, %.1f]; max |placebo ATT| = %.1f.",
            min(att), max(att), max(abs(att))),
    sprintf("- Real 2012 ATT = **%.1f**. Placebo p (two-sided, |placebo| >= |real|) = **%.3f** (%d/%d draws).",
            real_att, p_two, sum(abs(att) >= abs(real_att)), B_PLACEBO),
    sprintf("- One-sided (placebo <= real, i.e. at least as negative) = %.3f (%d/%d).",
            p_lo, sum(att <= real_att), B_PLACEBO),
    "",
    "Per-draw distribution: `falsification_placebo_onsets.csv`.",
    "",
    "## Covered elsewhere (not re-run)",
    "",
    "The audit's *\"future shocks predict past outcomes\"* placebo is already covered by the",
    "flat 1990–2011 BEA pre-trend (-$69/yr, p = 0.44; `bea_pretrends_1990_2011.csv`) and is",
    "not repeated here. Few-treated-cluster inference (wild cluster bootstrap p = 0.036;",
    "randomization inference p = 0.0075) lives in `wild_bootstrap_2x2.csv`.",
    "")
  writeLines(L, path)
}

# =============================================================================
# main
# =============================================================================
main <- function() {
  dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)
  log_dir <- file.path(OUT_DIR, "build_logs")
  dir.create(log_dir, showWarnings = FALSE, recursive = TRUE)
  log_path <- file.path(log_dir, "07_falsification_suite.log")
  con <- file(log_path, open = "wt")
  sink(con, split = TRUE)
  sink(con, type = "message")
  on.exit({ sink(type = "message"); sink(); close(con) }, add = TRUE)

  cat("=== 07 Falsification Suite (2012 drought 2x2) ===\n")
  cat("run at:", format(Sys.time()), "|", R.version.string, "\n")
  cat("seed  :", FALS_SEED, "| B_placebo:", B_PLACEBO, "\n\n")

  # ---- panel + benchmark 2x2 frame (identical to 01_) ----
  panel   <- load_did_panel()
  cohorts <- build_cohorts(panel, "Is_Extreme_Drought")
  frame   <- did_2x2_frame(panel, cohorts, EVENT_YEAR)
  cat(sprintf("2x2 frame: treated = %d, control (never-exposed) = %d counties\n",
              attr(frame, "n_treated"), attr(frame, "n_control")))

  treated_states <- identify_treated_states(cohorts, panel, EVENT_YEAR)
  cat(sprintf("Treated states (%d): %s\n\n",
              length(treated_states), paste(treated_states, collapse = ", ")))
  stopifnot(length(treated_states) == 17L)

  # ================= PART A: leave-one-treated-state-out =================
  cat("---- PART A: leave-one-treated-state-out ----\n")
  loo_df <- run_loo(frame, treated_states, LOO_OUTCOMES)
  loo_path <- file.path(OUT_DIR, "falsification_loo_state.csv")
  write.csv(loo_df, loo_path, row.names = FALSE)
  print(loo_df, row.names = FALSE, digits = 5)

  base <- loo_df[loo_df$state_dropped == "(none)", ]
  cat(sprintf("\nBaseline PCPI ATT = %.4f (benchmark %.4f, |Δ| = %.3g)\n",
              base$pcpi_att, BENCH_PCPI_ATT, abs(base$pcpi_att - BENCH_PCPI_ATT)))
  cat(sprintf("Baseline EMP  ATT = %.4f (benchmark %.4f, |Δ| = %.3g)\n",
              base$emp_att, BENCH_EMP_ATT, abs(base$emp_att - BENCH_EMP_ATT)))
  if (abs(base$pcpi_att - BENCH_PCPI_ATT) > 1)
    warning("Row-0 baseline did NOT reproduce the benchmark PCPI ATT within $1.")

  loo <- loo_df[loo_df$state_dropped != "(none)", ]
  cat(sprintf("PCPI envelope over 17 drops: [%.1f, %.1f]\n",
              min(loo$pcpi_att), max(loo$pcpi_att)))
  cat(sprintf("EMP  envelope over 17 drops: [%.1f, %.1f]\n",
              min(loo$emp_att), max(loo$emp_att)))
  ci_exit <- loo$state_dropped[loo$pcpi_att < WCB_CI_LO | loo$pcpi_att > WCB_CI_HI]
  cat(sprintf("PCPI leaves WCB CI [%.0f, %.0f] on: %s\n", WCB_CI_LO, WCB_CI_HI,
              if (length(ci_exit)) paste(ci_exit, collapse = ", ") else "none"))
  cat(sprintf("PCPI p>0.05 on: %s\n",
              { s <- loo$state_dropped[loo$pcpi_p > 0.05]
                if (length(s)) paste(s, collapse = ", ") else "none" }))

  # ================= PART B: placebo onset years =================
  cat("\n---- PART B: placebo onset years (never-exposed pool) ----\n")
  pb <- run_placebo(panel, cohorts, PRIMARY_OUTCOME,
                    n_treated = attr(frame, "n_treated"),
                    B = B_PLACEBO, onset_years = ONSET_YEARS, seed = FALS_SEED)
  placebo_path <- file.path(OUT_DIR, "falsification_placebo_onsets.csv")
  write.csv(pb$dist, placebo_path, row.names = FALSE)

  att      <- pb$dist$placebo_att
  real_att <- base$pcpi_att
  cat(sprintf("pool = %d never-exposed counties | draws = %d\n", pb$n_pool, B_PLACEBO))
  cat(sprintf("placebo ATT: mean %.2f, SD %.2f, range [%.1f, %.1f]\n",
              mean(att), sd(att), min(att), max(att)))
  cat("onset-year usage: \n"); print(table(pb$dist$pseudo_onset_year))
  cat(sprintf("real ATT %.2f | placebo p (two-sided) = %.4f (%d/%d)\n",
              real_att, mean(abs(att) >= abs(real_att)),
              sum(abs(att) >= abs(real_att)), B_PLACEBO))

  # ---- summary.md ----
  summ_path <- file.path(OUT_DIR, "falsification_summary.md")
  write_summary(loo_df, pb, real_att, summ_path)

  cat("\nWrote:\n")
  cat("  ", loo_path, "\n")
  cat("  ", placebo_path, "\n")
  cat("  ", summ_path, "\n")
  cat("  ", log_path, "\n")
  cat("\n=== done ===\n")
}

if (sys.nframe() == 0L) {
  main()
}
