# Implementation Plan: DiD Frontier-Methods Robustness

Track spec: `./spec.md`. Parent: `committee_feedback_april_2026` Phase 3.

**Status: Phases 1–5 RUN (Phase 1, 4, 5 completed 2026-07-04 via the
`thesis_completion_20260704` track, T0.1–T0.2).** Phase 1 (wild cluster bootstrap +
randomization inference) is done — **the income headline survives** (see below). Phase 2
(doubly-robust) and Phase 3 (HonestDiD) were complete 2026-06-25. Phase 4 synthesis run +
technical note updated; Phase 5 testthat suite written and passing. Only the optional de
Chaisemartin–D'Haultfœuille recurring-treatment estimator remains open (tracked as T2.2 of
`thesis_completion_20260704`). **This track is effectively closed.**

**Headline robustness verdict (Phases 2–3):** The **income** effect is robust — the
covariate-conditional DRDID 2×2 confirms it (−$1,451, even stronger than the unconditional
−$1,311). The **employment** effect is **fragile** — baseline covariates attenuate it ~58%
(−2,053 → −871, CI barely excludes 0), the pooled multi-cohort CS-dr reverses it to null/
positive (+2,609), and the pooled event-study shows positive employment pre-trends. The
2012-cohort headline does **not** generalize to the average drought cohort.

**Environment:** run everything with `C:/Program Files/R/R-4.5.3/bin/Rscript.exe` (NOT the
project's R 4.2.2). Required packages are already installed in the 4.5.3 library — see
`spec.md` → Environment.

---

## Phase 0: Scoping & environment (COMPLETE)

- [x] **Diagnose the design vs. frontier practice.** Identified 3 gaps: few treated
  clusters (67% of 139 treated in 4 states), recurring/non-absorbing treatment (drought
  "on" only 13.1% of treated post-years → ITT estimand), single pre-period for the 2012
  cohort (parallel trends untestable in isolation).
- [x] **Stand up R 4.5.3 environment.** Installed `DRDID`, `did`, `HonestDiD` (CRAN) and
  `fwildclusterboot` (r-universe `s3alfisc`) plus `fixest`/tidyverse-lite into the 4.5.3
  library. Main pipeline left on 4.2.2.
- [x] **Write shared helper** `Code/did_robustness/00_did_robustness_common.R` (panel load
  with CO-2023 debt exclusion, first-event cohort construction mirroring
  `run_did_analysis.R`, baseline-2011 covariates, state→Census-division map, 2×2 frame
  builder). Self-check runs.
- [x] **Confirm baseline covariate coverage at 2011:** Population 2,662/2,673;
  Med_HH_Income 2,618/2,673; Uninsured_Rate & Disability_Rate all-NA (excluded).

## Phase 1: Few-treated-cluster inference (Objective 1) — DONE 2026-07-04 (fdc0a25)

- [x] **Ran** `Code/did_robustness/01_wild_cluster_bootstrap.R` on R 4.5.3 (the script already
  used the FWL-demeaned residual model, so the previously-cancelled full-FE `boottest` hang did
  not recur). Wild cluster bootstrap-t (Webb, B=9999, null imposed) + Fisher randomization
  inference (N=2000). **Output:** `Analysis/did/robustness/wild_bootstrap_2x2.csv`.

    | Outcome | ATT | p_analytic | p_wcb_webb | p_randinf | WCB 95% CI |
    |---|---|---|---|---|---|
    | **PCPI_Real** | **−1,311** | 0.028 | **0.036** | **0.0075** | [−2,911, −138] |
    | Civilian_Employed | −2,043 | 0.0001 | 0.0029 | 0.0365 | [−3,163, −1,043] |
    | Med_HH_Income_Real | −991 | 0.237 | 0.268 | 0.0040 | [−3,261, 1,508] |
    | Medical_Debt_Share | −0.006 | 0.497 | 0.598 | 0.0835 | [−0.022, 0.023] |

    - **Verdict:** the **income headline survives** the few-treated-cluster correction (both
      WCB and RI clear 0.05; CI excludes 0). Employment also clears the few-cluster bar
      (p_wcb=0.003, p_ri=0.037) — its fragility (Phase 2 DRDID ~58% attenuation; pooled CS
      reversal) is one of *conditioning* and *generalization*, NOT cluster count. The two null
      outcomes stay null under WCB. This closes the one genuinely open econometric exposure
      flagged in the roadmap: it *confirmed* rather than weakened the headline.
    - 17 treated states (49 total); N≈34,000 county-years per outcome.

## Phase 2: Conditional parallel trends / doubly-robust (Objective 2)  — DONE 2026-06-25

- [x] **Ran** `Code/did_robustness/02_doubly_robust_did.R`. Bugs fixed en route: duplicate
  `Division` column collision (dropped from `baseline_covariates`); `DRDID` requires a
  **numeric** `idname` (added `as.integer(factor(fips_code))`).
    - (A) **DRDID improved-DR 2×2, Drought_2012** (post = unit mean 2012–2023; covariates =
      z(log pop 2011) + z(baseline median HH income) + Census division), N≈2,612 units.
      **Output:** `Analysis/did/robustness/dr_2x2_drought_2012.csv`.

      | Outcome | DR ATT | SE | 95% CI | vs. unconditional 2×2 |
      |---|---|---|---|---|
      | PCPI_Real | **−1,451** | 515 | [−2461, −441] | −1,311 → **stronger**, still sig |
      | Civilian_Employed | **−871** | 433 | [−1719, −23] | −2,053 → **attenuated ~58%**, barely sig |
      | Med_HH_Income_Real | −1,186 | 487 | [−2140, −232] | sig |
      | Medical_Debt_Share | −0.0108 | 0.0044 | [−0.0194, −0.0023] | now sig (was null) |

    - (B) **CS doubly-robust** (`did::att_gt`, `est_method="dr"`, nevertreated, state-clustered
      bootstrap, universal base, unbalanced allowed) across **all** drought cohorts.
      **Outputs:** `dr_csdid_drought.csv` (simple), `dr_csdid_eventtime.csv` (dynamic).
      Simple ATTs: PCPI **+350** (SE 585), Civilian_Employed **+2,609** (SE 2,245),
      Med_HH_Income −444 (SE 715), Medical_Debt_Share −0.0054 (SE 0.0050) — **all null**.
      Employment dynamic event-study shows **positive pre-trends** (e=−12…−4 all positive).
    - **Takeaway:** income effect survives conditioning (DRDID); the pooled multi-cohort
      average is null and the **2012 result does not generalize**. Employment is fragile.

## Phase 3: Parallel-trends sensitivity (Objective 3)  — DONE 2026-06-25

- [x] **Ran** `Code/did_robustness/03_honestdid_sensitivity.R`. Fixes en route: influence-
  function vcov scaled by **1/n²** (mean-of-a-mean, per the HonestDiD `did` vignette — the
  first draft used 1/n); event window restricted to **e ∈ [−5, 5]** (4 pre + 6 post) so the
  ARP LPs are tractable and not dominated by ultra-noisy long leads; return value is the
  sensitivity data.frame directly (not `$robust_ci`).
    - `HonestDiD::createSensitivityResults_relativeMagnitudes`, target e=0, M-bar ∈ {0.5,1,1.5,2}.
      **Output:** `Analysis/did/robustness/honestdid_sensitivity.csv`.
    - **Result:** for the pooled CS event-study, the robust CI **includes 0 at every M-bar
      (even 0.5)** for both PCPI and Civilian_Employed → **breakdown M-bar < 0.5**.
    - **CRITICAL LIMITATION (expected):** HonestDiD needs ≥1 testable pre-period, but the
      **2012 cohort has none** (panel starts 2011 = its e=−1). So HonestDiD can only be run on
      the **pooled** multi-cohort CS event-study — whose e=0 effect is already **null/positive**
      (PCPI e0 ≈ −324, employment e0 ≈ +202). It therefore **cannot vindicate the 2012
      headline**; it merely confirms the pooled average is indistinguishable from zero. The
      2012 natural experiment's credibility rests on Phase 2 (DRDID 2×2) and Phase 1
      (cluster-robust inference), NOT on HonestDiD.

## Phase 4: Synthesis & write-up (Objective 4) — DONE 2026-07-04

- [x] **Ran** `Code/did_robustness/04_synthesize_did_robustness.R` →
  `Analysis/did/robustness/did_robustness_summary.md` (collates all three robustness layers:
  wild bootstrap/RI, DRDID 2×2 + CS-dr, HonestDiD sensitivity).
- [x] **Updated** `Text/technical_note_empirical_framework.{html,tex}`: added the §2.5.4
  few-treated-cluster note (WCB + RI p-values, FWL rationale, "income survives / employment is
  a conditioning-not-clustering fragility" verdict) alongside the existing DRDID §2.5.3.
  *(Left uncommitted in the working tree — the author has a concurrent affiliation edit in
  those files; folded in for their review, not swept into a conductor commit.)*
- [ ] **Optional (deferred → T2.2 of `thesis_completion_20260704`):** de Chaisemartin–
  D'Haultfœuille `did_multiplegt_dyn` as a direct recurring-treatment estimator.

## Phase 5: Tests & conductor close-out — DONE 2026-07-04 (fdc0a25)

- [x] **Tests** `Code/tests/test_did_robustness.R` (testthat): first-onset cohort construction;
  FWL-residualized 2×2 estimate == full two-way-FE `feols` ATT (identity licensing the fast
  bootstrap); randomization-inference placebo centers on 0 under a true null; baseline
  covariates strictly 2011. All 5 pass on R 4.2.2 (deliberately boottest-free). `fdc0a25`
- [ ] **Changelog / GEMINI / CLAUDE** updates and conductor commit — at session end per
  `workflow.md` (the `thesis_completion_20260704` track carries this forward).

---

### Notes / lessons (live)

- **boottest is O(FE-heavy).** Never run `boottest` on a model with thousands of absorbed
  FEs directly — partial them out with `fixest::demean` (FWL) and bootstrap the 1-regressor
  residual model. Point estimate and cluster structure are preserved.
- **`drdid` vs `DRDID`.** The CRAN package is **`DRDID`** (uppercase); lowercase `drdid`
  resolves to nothing and silently "not available."
- **`fwildclusterboot` is archived on CRAN** — install from the maintainer's r-universe:
  `install.packages('fwildclusterboot', repos='https://s3alfisc.r-universe.dev')`.
- **Two-R-version workflow.** This track is the only thing on R 4.5.3; everything else stays
  on 4.2.2. Keep that boundary explicit in every script header.
- **Falsification extensions live elsewhere (2026-07-12).** Leave-one-treated-state-out and
  placebo-onset falsification for the 2012 2×2 are owned by `audit_response_20260712`
  Phase 2 (`Code/did_robustness/07_falsification_suite.R`, R 4.5.3). This track stays
  closed; the T2.2 de Chaisemartin deferral is unchanged (`06_` remains reserved for it).
