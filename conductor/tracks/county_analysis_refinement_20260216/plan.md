# Implementation Plan: County-Level Analysis Refinement

## Phase 0: Pipeline Standardization & Critical Fixes

- [ ] **Task: Fix Critical Pipeline Inconsistencies**
    - [x] Align NOAA missing-value thresholds to `<=` -9.9` in `process_county_climate.R`. [d99c564]
    - [x] Fix NOAA missing-value threshold in `process_state_climate.R`: still applies blanket `<= -9.9` to all variables (temp, CDD, HDD, drought indices); use variable-specific thresholds matching the county script.
    - [x] Fix `process_rating_area_map.R`: `AREA_Clean` (stripped "Rating Area N" → "N") is computed but never used — `rating_area_id = AREA` retains the raw string, causing silent all-NA premium joins for plan years that use the "Rating Area N" format.
    - [x] Standardize MEPS I/O to `Data/MEPS_Data_IC/` across all scripts.
    - [x] Archive orphaned `process_medical_debt_county.R` and verify `process_zip_county_map.R` as canonical.
    - [x] Resolve `Unemployment_Rate` absence in `create_county_master.R` (source BLS data or update controls).
- [x] **Task: Align State and County Methodologies**
    - [x] Migrate `run_analysis.R` (State) from `plm` to `fixest`.
    - [x] Standardize temperature aggregation to annual mean in `process_state_climate.R`.
    - [x] Align AQI variable construction across both pipelines: replaced binary quintile `is_high_aqi` with continuous measures (population-weighted median, max, pollutant day percentages); state AQI aggregation now depends on county intermediate + population weights.
    - [x] Fix NOAA state-code mapping for DC in `process_county_climate.R`: removed broken duplicate key; added comment that DC is absent from county-level NOAA climate divisional files.

## Phase 1: Data Integration & Baseline Refinement

- [x] **Task: Update climate Z-score calculation logic**
    - [x] Write tests to verify Z-score calculation using a specific baseline period (1990–2000).
    - [x] Modify `Code/process_county_climate.R` to calculate means and SDs using only 1990–2000 data and apply to full period. (Note: Z-score computation lives here, not in `create_county_master.R`; year filter changed from 1996 → 1990.)
- [x] **Task: Integrate socioeconomic outcome variables** [90c7eea]
    - [x] Sources: BEA CAINC1 (per capita income) + Census ACS 5-yr (median HH income, B19013_001E; civilian employed, B23025_004E). BEA CAEMP25N not available via Regional API.
    - [x] 16 passing tests (FIPS validation, CPI adjustment, suppression handling, ACS absence rows).
    - [x] create_county_master.R updated to join intermediate_socioeconomic.rds.
- [x] **Task: Generate descriptive statistics and visualizations**
    - [x] Created `Code/run_descriptive_stats.R` with summary stats for 18 key variables.
    - [x] Generated 3 time-series plots: climate shock prevalence, health outcomes, income trends (in `Analysis/plots/`).
    - [x] Documented trends in `Analysis/descriptive_stats_report.md`.
    - [x] Fixed pipeline: NASHP hospital data re-processed (was silently skipped), `Is_Extreme_Drought` added to `process_county_climate.R`, intermediate and master rebuilt.
    - [x] Re-ran and upgraded descriptive outputs to publication standard: weighted and unweighted tables, tail and winsorized moments, missingness diagnostics, correlation matrix, period-comparison table, and manuscript figures (`fig1-fig3`) on 2026-03-02.
- [x] **Task: Conductor - User Manual Verification 'Data Integration & Baseline Refinement' (Protocol in workflow.md)** [707fa14]

## Phase 1 [checkpoint: 707fa14]

## Phase 2: Event Study & Econometric Modeling

- [x] **Task: Add rating-area clustered SE variants for premium models** [rating area clustering added to run_county_analysis.R; premium outcomes get *_RA_Cluster model variants alongside state-clustered primaries]

- [ ] **Task: Econometric Soundness Remediation (Pre-Event-Study Gate)**
    - [ ] **Deferred for now:** Enforce one-row-per-county-year (`fips_code`, `Year`) in county master by resolving split-county multi-rating-area premium joins.
    - [x] **Next 1:** Fix state drought construction mismatch (`pdsi_sum` thresholding as if level PDSI); switched to level-consistent annual metric (`pdsi_mean`/`pdsi_level`) and regenerated state analysis inputs.
    - [x] **Next 2:** Remove outcome-sample anchoring of county regressions to medical-debt base table; make merge strategy outcome-neutral and document outcome-specific analysis samples. Implemented outcome-neutral key skeleton in `create_county_master.R`; added model/spec/weighting sample diagnostics export in `run_county_analysis.R` (`Analysis/county_sample_diagnostics.csv`) and re-ran county pipeline on 2026-03-03.
    - [x] **Next 3:** Apply medical debt reporting-rule exclusion/policy flags directly in county regression stack (not only descriptive stats) for debt outcomes. Implemented AGENTS.md-consistent policy window (`CO 2023` only) in `run_county_analysis.R`, added debt-policy fields to `Analysis/county_sample_diagnostics.csv`, and aligned descriptive pipeline (`run_descriptive_stats.R`) to the same window on 2026-03-03.
    - [x] **Next 4:** Tighten state AQI aggregation weights by removing `Pop_Wt = 1` fallback; define explicit behavior for missing population and document sample impact. Implemented strict population-weighted AQI aggregation in `process_aqi_data.R` (missing population is dropped; if no weighted counties remain in a state-year, primary AQI is `NA`), added equal-weight robustness series (`AQI_Median_EW`), and exported diagnostics to `Analysis/state_aqi_weight_diagnostics.csv` (918 state-years, 102 with no primary AQI value, concentrated in 2024-2025 where population is unavailable).
    - [x] **Next 5:** Add county-model multicollinearity diagnostics (VIF/condition checks) and a documented pruning strategy for drought-index blocks. Completed diagnostics after PDSI-only pruning in primary county specs: no collinearity warnings, max VIF ~5.33, and condition numbers ~2.55-5.33 across outcomes/specs; `PHDI/PMDI` retained for optional robustness runs.

- [ ] **Task: Implement Event Study models for individual shocks**
    - [ ] Define event windows for heat, drought, and precipitation shocks.
    - [ ] Write tests to verify the construction of lead/lag indicators for the event study.
    - [ ] Execute Fixed-Effects regressions for each shock type and outcome (Premiums, Medical Debt, Hours, Income).
- [ ] **Task: Implement Combined Shock Diff-in-Diff study**
    - [ ] Define "any shock" treatment criteria.
    - [ ] Write tests for the diff-in-diff indicator logic.
    - [ ] Execute regressions and extract coefficients/standard errors.
- [ ] **Task: Document and Visualize Regression Results**
    - [ ] Generate Stargazer/Modelsummary tables for the new models.
    - [ ] Create event study coefficient plots (e.g., using `iplot` from `fixest`).
    - [ ] Update `Analysis/regression_results_summary.csv` and summary reports.
- [ ] **Task: Conductor - User Manual Verification 'Event Study & Econometric Modeling' (Protocol in workflow.md)**

## Optional End-Step Robustness (Defer Until Final Pass)

- [ ] Optional: simplify distributed lag blocks (e.g., cumulative lag sums or reduced lag sets) and report sensitivity versus the current unrestricted lag-by-lag primary specs.
- [ ] Optional: Verify `is_extreme_drought_peak` (pdsi_min-based) VIF against `is_extreme_drought` (pdsi_mean-based) in state model after re-running full state pipeline. If VIF > 10 on the 6-variable drought binary block, replace `is_extreme_drought` with `is_extreme_drought_peak` rather than including both, or test as alternative specs. State VIF diagnostics in `Analysis/vif_diagnostics.txt` (previously broken — fixed 2026-03-03).
