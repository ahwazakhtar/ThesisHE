# Implementation Plan: Committee Feedback April 2026

Source: `Text/Feedback from Committee April 2026.md`. Track spec: `./spec.md`.

Sequencing: Phase 0 is the gate. Phases 1 and 4 can run in parallel with Phase 2 after Phase 0. Phase 3 depends on Phase 0. Phase 5 runs anytime after Phase 0.

---

## Phase 0: Scoping & exposure inventory

- [x] **Task: Inventory never-exposed counties and identify DiD candidates** [bc165f1]
    - [x] For each shock indicator (`Is_Extreme_Drought`, `High_CDD`, `High_HDD`, `High_AQI_Max`), compute per-county event counts across 2011-2023. (`Code/run_never_exposed_inventory.R`)
    - [x] Export `Analysis/never_exposed_inventory.csv` (county, shock, n_events, ever_exposed flag, never_exposed flag) plus per-shock summary, by-state, and event-year onset tables. (CSVs gitignored.)
    - [x] Identify candidate sharp events for natural-experiment DiD. Primary: **2012 Midwest drought** (139 onset counties, 2,534 never-exposed). Secondary: **2013 HDD** (407 onset, 2,303 never-exposed). Documented in `Analysis/did_feasibility_memo.md`.
    - [x] Memo determines which shock(s) advance to Phase 3a. **Drought + HDD advance to 3a; Drought + HDD + CDD advance to 3b; AQI dropped from DiD scope (3.1% never-exposed too thin).**

## Phase 1: Random-effects robustness (Econometric #1)

- [x] **Task: Random-effects counterparts for primary specs** [4c57c86]
    - [x] Identified primary FE specs in `run_analysis.R` (State+Year, cluster=State, 6 outcomes) and `run_county_analysis.R` (fips_code+Year, cluster=State, 7 outcomes / Spec1_Base).
    - [x] Implemented in new `Code/run_re_robustness.R` using `plm::plm(model = "within" | "random", effect = "twoways")` with `phtest`. Scoped exception to the fixest-only rule documented in the script header.
    - [x] Hausman test per matched pair exported to `Analysis/random_effects_hausman.csv`; full coefficient comparison in `Analysis/random_effects_results.csv`.
    - [x] Memo at `Analysis/random_effects_robustness.md` reports FE vs RE side-by-side. **RE rejected for all 11 estimable outcomes at p < 1e-9** (2 state outcomes failed to fit RE due to thin panels; FE remains authoritative there). Headline state findings (Extreme Drought 2-yr lag, Cold Shock 1-yr lag) survive — RE estimates same sign; rejection driven by precision/efficiency, not coefficient reversals.
    - [x] Tests in `Code/tests/test_re_robustness.R` (5 tests, all pass): plm-fixest FE equality; Hausman stat/p-value sanity; correlated DGP rejects RE; uncorrelated DGP yields close FE/RE; output schema check.

## Phase 2: Post-exit dynamics (Econometric #2)

- [x] **Task: Extend Exit indicators with LP dynamic horizons** [b241f83]
    - [x] Extended `Code/run_delta_analysis.R` Section 9 with Block A (Exit_LP h=0..3) and Block B (Exit_Interaction: `Shock_{t-1} * NoShock_t`).
    - [x] `Analysis/delta_coefs.csv`: 896 -> 1664 rows (+768 across primary + RA-cluster variants).
    - [x] 3 new testthat blocks in `Code/tests/test_delta_variables.R` (LP-at-h=0 equivalence, lead() boundary safety, interaction identity). 9/9 pass.
    - [x] 42 new plots in `Analysis/plots/delta_exit_dynamics/`.
    - [x] `Analysis/delta_analysis_synthesis.md` extended with "Post-Exit Dynamics" section. Headline: Drought_Exit -> PCPI_Real peaks at h=2 (+$1044 pc, p=0.0002, partial scarring); HDD_Exit -> Hosp_BadDebt_PerCapita immediate relief (no cold-shock scarring); CDD-exit shows persistent employment benefits.

## Phase 3: Diff-in-Diff with never-exposed controls (Econometric #3)

- [x] **Task: 3a. Natural-experiment 2x2 DiD** [0e297b1]
    - [x] Selected events from Phase 0 memo: 2012 Midwest drought (139 treated, 2,534 controls); 2013 HDD onset (171 treated, 2,303 controls — first-event semantics rather than new-onset).
    - [x] Built treated/never-exposed cohorts and 2x2 DiD in `Code/run_did_analysis.R` for 7 outcomes (Medical_Debt, premiums, hospital, income, employment).
    - [x] Pre-trends event-study (k=-2..+3) for both events in `Analysis/did/did_pretrends_event_study.csv`.
    - [x] Headline: Drought 2012 treated counties have PCPI ATT=-$1,311 (p=0.027) and Civilian_Employed ATT=-2,053 (p=0.0001). HDD 2013 has Civilian_Employed ATT=-2,720 (p=0.011). Premium outcome drops via ACA-era collinearity (handled in CS-DiD).
    - [x] Synthesis in `Analysis/did/did_results.md`.

- [x] **Task: 3b. Stacked / Callaway-Sant'Anna DiD** [0e297b1]
    - [x] Manual CS implementation in `Code/run_did_analysis.R` via fixest (the `did` R package failed to install on the local Windows R 4.2.2 toolchain because dep `recipes` failed to build). 427 ATT(g,t) estimates across Drought/HDD/CDD.
    - [x] Cohort-size-weighted event-time aggregation in `Analysis/did/did_cs_event_time.csv`; 28 plots in `Analysis/plots/did/`.
    - [x] Headline CS findings: Drought e=0 PCPI=-$1,050 (p=0.002); HDD long-run Civilian_Employed loss compounds to -4,982 at e=10 (p=0.003); HDD Medical_Debt_Share rises +4.9pp at e=10 (p=0.0002) — long-run cold-state scarring identified.
    - [x] LP vs DiD comparison in `Analysis/did/did_results.md`: complementary designs (LP=within-county dynamics; DiD=persistent treated-vs-never-exposed gap).

- [x] **Task: 3c. Tests for DiD construction** [0e297b1]
    - [x] `Code/tests/test_did_analysis.R`: 5 testthat tests covering 2x2 tau recovery on synthetic data, partition cleanliness, cohort first-event construction, CS-DiD vs canonical 2x2 equivalence, and output schema. 5/5 pass.

## Phase 4: Humidity integration (Environmental #1)

- [x] **Task: Acquire PRISM humidity (tdmean) at state level**
    - [x] New `Code/download_prism_humidity.R`: pulls annual 4km CONUS `tdmean` grids (BIL) from `services.nacse.org` (no API key) for 2009–2025; skips already-unzipped years (PRISM 24h re-download block). Raw outputs in `Data/Climate_Data/State level/PRISM_tdmean/`.
    - [x] Script header documents the open (keyless) access pattern, download limits, and a manual-download fallback.
    - [x] Tests in `Code/tests/test_humidity_download.R` (skip-existing logic offline; file shape + year coverage integration). 3/3 pass.

- [x] **Task: Process humidity to state-year panel**
    - [x] New `Code/process_state_humidity.R`: area-weighted zonal mean of each grid over Census 2018 state polygons via `terra` (only `terra` needed — bundles GDAL/GEOS/PROJ; `sf`/`tigris` NOT required). Output `Data/intermediate_humidity.rds` (State, Year, tdmean_C, tdmean_F). CONUS-only → AK/HI NA.
    - [x] Tests in `Code/tests/test_state_humidity.R` (synthetic area-weighted extraction, C→F conversion, no-duplicate state-year, deg-F range, AK/HI missingness). 4/4 pass.

- [x] **Task: Integrate humidity into state pipeline and re-run primary state regressions**
    - [x] Joined `intermediate_humidity.rds` in `Code/create_state_master.R`; `tdmean_F` lagged in `Code/analysis_pre_processing.R`.
    - [x] Humidity-sensitivity block in `Code/run_analysis.R` compares headline coefficients on the *identical humidity-available subsample* with vs. without `tdmean_F` + lags (avoids conflating added control with changed sample). Output `Analysis/humidity_sensitivity.csv`.
    - [x] Re-ran state pipeline; full-sample primary `regression_results_summary.csv` unchanged (humidity kept out of it by design); `Analysis/state_analysis_summary.md` §6.4 rewritten with results.
    - [x] Headline **Cold Shock (1-yr lag) → Medical Debt Share survives** (0.01363, p=0.011 → 0.01368, p=0.017). Humidity itself raises medical debt (Share +0.0025/°F p=0.009; Median +$16.0/°F p=0.004) and marginally lowers premiums (−$13.7/°F p=0.052).

## Phase 5: Propagation-pathway evidence (General #1)

- [x] **Task: Literature review of mechanisms** [0e297b1]
    - [x] `Text/propagation_pathways.md` covers heat -> delayed care, cold -> shifted utilization, drought -> income -> debt, AQI -> respiratory/cardiac. 18 references total (2-4 per pathway). Pathway-to-empirics mapping table links each pathway to the specific identification channel(s) in our work.

- [x] **Task: Descriptive evidence from existing data** [0e297b1]
    - [x] `Code/run_pathway_descriptives.R` produces 4 figures in `Analysis/plots/pathways/`: (1) shock prevalence by Census region, (2) pooled correlation matrix, (3) delta onset/exit mean comparison, (4) Medical_Debt_Share by income quartile x shock status.
    - [x] Summary doc `Analysis/pathway_descriptives_summary.md` references figures by pathway.
    - [x] Annual panel limits us to cross-county and year-over-year evidence (no within-year seasonal patterns possible).

## Phase 6: Conductor verification & write-up

- [ ] **Task: Conductor - User Manual Verification 'Committee Feedback April 2026' (Protocol in workflow.md)**
- [x] **Task: Update upstream synthesis documents**
    - [x] `Analysis/state_analysis_summary.md`: added §6 ("Committee Feedback April 2026 — Robustness Layer") covering RE robustness, DiD cross-reference, propagation evidence, humidity caveat (Phase 4 parked), and a summary table of what changed.
    - [x] `Analysis/event_study_synthesis.md`: added Key Finding 7 (Post-Exit Dynamics) and Key Finding 8 (DiD with Never-Exposed) plus the LP-vs-DiD reconciliation table and a Cross-Reference Index.
    - [x] `Analysis/delta_analysis_synthesis.md`: already updated in Phase 2 with the post-exit LP results.
