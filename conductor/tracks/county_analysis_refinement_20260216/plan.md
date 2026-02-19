# Implementation Plan: County-Level Analysis Refinement

## Phase 0: Pipeline Standardization & Critical Fixes

- [ ] **Task: Fix Critical Pipeline Inconsistencies**
    - [x] Align NOAA missing-value thresholds to `<=` -9.9` in `process_county_climate.R`. [d99c564]
    - [ ] Standardize MEPS I/O to `Data/MEPS_Data_IC/` across all scripts.
    - [ ] Archive orphaned `process_medical_debt_county.R` and verify `process_zip_county_map.R` as canonical.
    - [ ] Resolve `Unemployment_Rate` absence in `create_county_master.R` (source BLS data or update controls).
- [ ] **Task: Align State and County Methodologies**
    - [ ] Migrate `run_analysis.R` (State) from `plm` to `fixest`.
    - [ ] Standardize temperature aggregation to annual mean in `process_state_climate.R`.
    - [ ] Align AQI variable construction (z-scores) across both pipelines.
    - [ ] Update NOAA state-code mapping for DC/Hawaii in `process_county_climate.R`.

## Phase 1: Data Integration & Baseline Refinement

- [ ] **Task: Update climate Z-score calculation logic**
    - [ ] Write tests to verify Z-score calculation using a specific baseline period.
    - [ ] Modify `Code/create_county_master.R` to calculate means and SDs using only pre-1996 data.
    - [ ] Apply these parameters to calculate Z-scores for the entire study period.
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
