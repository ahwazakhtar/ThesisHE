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
- [ ] **Task: Integrate socioeconomic outcome variables**
    - [ ] Identify and download/read county-level data for hours worked and income.
    - [ ] Write tests to ensure successful merge and data integrity (e.g., no unexpected NAs).
    - [ ] Update the county-level master dataset with these new outcomes.
- [ ] **Task: Generate descriptive statistics and visualizations**
    - [ ] Create scripts to calculate summary statistics for all key variables.
    - [ ] Generate time-series plots showing trends in climate shocks and health/economic outcomes.
    - [ ] Document trends in a new analysis report.
- [ ] **Task: Conductor - User Manual Verification 'Data Integration & Baseline Refinement' (Protocol in workflow.md)**

## Phase 2: Event Study & Econometric Modeling

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
