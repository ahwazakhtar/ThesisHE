# Track Specification: DiD Frontier-Methods Robustness

**Created:** 2026-06-25
**Status:** Documented; execution deferred (scaffolding written, not yet run).
**Parent work:** Extends `committee_feedback_april_2026` Phase 3 (the natural-experiment
DiD in `Code/run_did_analysis.R` / `Analysis/did/did_results.md`).

## Motivation

The existing 2012-drought natural-experiment DiD (sharp 2×2 + manual Callaway–Sant'Anna)
is "2021-aware" — it uses never-treated controls and avoids the Goodman-Bacon
negative-weighting trap — but three gaps separate it from current frontier practice. A
diagnostic on the treated cohort sharpened all three:

- **Treated counties are concentrated in few states.** The 139 first-onset-2012 counties
  are 67% in 4 states (GA 45, CO 21, NE 17, NM 10; 17 states total). Analytic
  state-clustered SEs over-reject when treatment variation lives in few clusters.
- **Treatment is recurring, not absorbing.** Extreme drought switches on/off; the 2012
  cohort is actually in extreme drought only **13.1%** of post-2012 county-years (mean
  1.58 drought-years of 12; 29% have >1 spell). The 2×2 ATT is therefore an
  intent-to-treat / "effect of first onset" estimand, not "the effect of being in drought."
- **Parallel trends is the binding assumption,** and the 2012 cohort has a single
  pre-period (2011), so it is untestable in isolation. Treated counties skew rural
  Plains/Mountain/GA agricultural; never-exposed skew urban/coastal/eastern — plausibly
  diverging secular trends.

The `did` / `DRDID` / `HonestDiD` / `fwildclusterboot` packages are unavailable on CRAN
for the project's R 4.2.2; this track therefore runs on a **separate R 4.5.3** install,
leaving the main pipeline untouched.

## Objectives

1. **Few-treated-cluster inference.** Wild cluster bootstrap-t (Webb weights, null imposed)
   and Fisher randomization inference on the 2×2 ATTs. Report whether the headline
   PCPI / employment p-values survive.
2. **Conditional parallel trends.** Sant'Anna–Zhao doubly-robust DiD (`DRDID`) and
   covariate-conditional Callaway–Sant'Anna (`did::att_gt`, `est_method="dr"`) using
   **pre-treatment baseline (2011)** covariates only — log population, baseline median HH
   income, Census division. Explicitly NO contemporaneous mediators (income, unemployment,
   premiums are bad controls).
3. **Parallel-trends sensitivity.** Rambachan–Roth `HonestDiD` relative-magnitudes bounds
   on the pooled CS event-study (leaning on the 2021/2022 cohorts that have many
   pre-periods). Report the breakdown M-bar.
4. **Estimand & label hygiene.** Document the ITT framing and flag that the "2012 Midwest
   drought" name is a misnomer (cohort is GA + Mountain West + Plains).

## Scope

New, self-contained, and isolated from the main pipeline:

- `Code/did_robustness/00_did_robustness_common.R` — shared data/cohort/covariate helpers.
- `Code/did_robustness/01_wild_cluster_bootstrap.R` — Objective 1.
- `Code/did_robustness/02_doubly_robust_did.R` — Objective 2.
- `Code/did_robustness/03_honestdid_sensitivity.R` — Objective 3.
- `Code/did_robustness/04_synthesize_did_robustness.R` — collation to markdown.
- Outputs under `Analysis/did/robustness/` (CSVs + summary md; gitignored like other Analysis CSVs).
- Update to `Text/technical_note/technical_note_empirical_framework.html` §2.5–2.6 once results exist.

Out of scope (noted as candidates, not committed): de Chaisemartin–D'Haultfœuille
`did_multiplegt_dyn` for genuinely recurring (on/off) treatment; Borusyak–Jaravel–Spiess
imputation event-study. These would address the recurring-treatment estimand directly
rather than via the first-onset recast.

## Environment

- **R 4.5.3** (`C:/Program Files/R/R-4.5.3/bin/Rscript.exe`). Installed there:
  `dplyr, tidyr, readr, ggplot2, fixest, DRDID, did, HonestDiD, fwildclusterboot`
  (`fwildclusterboot` from r-universe `https://s3alfisc.r-universe.dev`; all others CRAN).
- Main pipeline remains on R 4.2.2, unchanged.

## Acceptance Criteria

- Wild-bootstrap and randomization p-values reported alongside the analytic p for each
  headline outcome; conclusion stated on whether the income/employment effects survive.
- DR 2×2 and CS-dr simple ATTs reported with baseline covariates; compared to the
  unconditional estimates.
- HonestDiD breakdown M-bar reported for PCPI and employment.
- Technical note updated, or a clear note that results are pending.
- Scripts validated to run end-to-end on R 4.5.3.
