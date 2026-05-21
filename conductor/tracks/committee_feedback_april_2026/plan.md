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

- [ ] **Task: Random-effects counterparts for primary specs**
    - [ ] Identify the primary FE specs in `run_analysis.R` (state) and `run_county_analysis.R` (county). Limit RE scope to these primary specs only.
    - [ ] Estimate RE counterparts using `plm::plm(..., model = "random")` (or equivalent in `fixest` if available without losing the RE structure).
    - [ ] Hausman test per matched pair; export coefficients/SEs/p-values to `Analysis/random_effects_results.csv`.
    - [ ] Write `Analysis/random_effects_robustness.md` with FE vs. RE side-by-side coefficient table, Hausman test results, and a short interpretation.
    - [ ] Add tests in `Code/tests/test_re_robustness.R` for at least one model (verify RE estimate reproduces from raw inputs).

## Phase 2: Post-exit dynamics (Econometric #2)

- [ ] **Task: Extend Exit indicators with LP dynamic horizons**
    - [ ] Extend `Code/run_delta_analysis.R` so that `*_Exit` (Drought, CDD, HDD) are estimated with LP horizons h=0..3 (currently only h=0).
    - [ ] Add a complementary "exit-after-shock" spec: `Y_{i,t+h} ~ Shock_{i,t-1} * NoShock_{i,t}` (interaction isolates counties that were shocked at t-1 and recovered at t).
    - [ ] Export coefficients to `Analysis/delta_coefs.csv` (extend existing file with horizon != 0 rows for Exit).
    - [ ] Add tests in `Code/tests/test_delta_variables.R` for the new exit LP horizons (boundary cases, sign).
    - [ ] Plots in `Analysis/plots/delta_exit_dynamics/` (per shock x outcome).
    - [ ] Update `Analysis/delta_analysis_synthesis.md` with a new section on post-exit dynamics.

## Phase 3: Diff-in-Diff with never-exposed controls (Econometric #3)

- [ ] **Task: 3a. Natural-experiment 2x2 DiD**
    - [ ] Based on Phase 0 memo, select 1-2 events (likely 2012 Midwest drought; possibly 2014 polar vortex for HDD).
    - [ ] Construct treated cohort (counties exposed in event year) and control cohort (never-exposed counties) per Phase 0 inventory.
    - [ ] Estimate canonical 2x2 DiD in new `Code/run_did_analysis.R` for headline outcomes (Medical_Debt, Benchmark_Silver_Real, hospital cost metrics).
    - [ ] Pre-trends diagnostic: event-study with leads/lags around event year, restricted to treated + never-exposed.
    - [ ] Export results to `Analysis/did/2x2/` and tabulate in `Analysis/did/did_results.md`.

- [ ] **Task: 3b. Stacked / Callaway-Sant'Anna DiD**
    - [ ] In `Code/run_did_analysis.R`, use `did::att_gt` with `control_group = "nevertreated"` for each shock type that has sufficient never-exposed counties.
    - [ ] Aggregate cohort-level ATTs to event-time response curves; report group-time ATTs and dynamic effects.
    - [ ] Export to `Analysis/did/cs/` with plots in `Analysis/plots/did/`.
    - [ ] Compare CS-DiD dynamic profile against existing LP profile and note any divergence in `Analysis/did/did_results.md`.

- [ ] **Task: 3c. Tests for DiD construction**
    - [ ] `Code/tests/test_did_analysis.R`: never-treated identification matches Phase 0 inventory; treated/control cohort sizes correct; group-time ATT signs reasonable on a synthetic test fixture.

## Phase 4: Humidity integration (Environmental #1)

- [ ] **Task: Acquire PRISM humidity (tdmean) at state level**
    - [ ] New `Code/download_prism_humidity.R`: pull `tdmean` from PRISM web service (https://prism.oregonstate.edu/documents/PRISM_downloads_web_service.pdf). Store raw outputs in `Data/Climate_Data/State level/PRISM_tdmean/`.
    - [ ] Document API key / access pattern in script header. If no API key, document the manual download fallback.
    - [ ] Tests in `Code/tests/test_humidity_download.R` (file shape, column names, year coverage).

- [ ] **Task: Process humidity to state-year panel**
    - [ ] New `Code/process_state_humidity.R`: aggregate raw PRISM `tdmean` to state-year. Output `Data/intermediate_humidity.rds`.
    - [ ] Tests: missingness summary, sensible value range for dew point (deg F), no duplicate state-year rows.

- [ ] **Task: Integrate humidity into state pipeline and re-run primary state regressions**
    - [ ] Join `intermediate_humidity.rds` in `Code/create_state_master.R`.
    - [ ] Add `tdmean` (and a lagged variant if motivated) to controls in `Code/analysis_pre_processing.R` and `Code/run_analysis.R`.
    - [ ] Re-run `run_analysis.R`; update `Analysis/regression_results_summary.csv` and `Analysis/state_analysis_summary.md`.
    - [ ] Add a humidity-sensitivity sub-section: do the headline Extreme Drought (2-yr lag) and Cold Shock (1-yr lag) results survive?

## Phase 5: Propagation-pathway evidence (General #1)

- [ ] **Task: Literature review of mechanisms**
    - [ ] New `Text/propagation_pathways.md`: cited literature on (a) heat -> delayed care, (b) cold -> shifted/increased care utilization, (c) drought -> chronic health and income effects, (d) AQI -> respiratory and cardiac utilization.
    - [ ] Aim: 2-4 cited references per pathway; include effect direction and time-scale claims.

- [ ] **Task: Descriptive evidence from existing data**
    - [ ] New `Code/run_pathway_descriptives.R`: produce seasonal patterns in MEPS/hospital data, correlation of shock indicators with care-adjacent variables already in the panel, climate-region splits.
    - [ ] Figures in `Analysis/plots/pathways/`; reference them inline in `Text/propagation_pathways.md`.

## Phase 6: Conductor verification & write-up

- [ ] **Task: Conductor - User Manual Verification 'Committee Feedback April 2026' (Protocol in workflow.md)**
- [ ] **Task: Update upstream synthesis documents**
    - [ ] `Analysis/state_analysis_summary.md`: humidity-robust findings, RE robustness note.
    - [ ] `Analysis/event_study_synthesis.md`: post-exit dynamics and DiD comparison.
    - [ ] `Analysis/delta_analysis_synthesis.md`: post-exit LP results (already touched in Phase 2).
