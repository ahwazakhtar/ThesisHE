# State-Level Analysis Summary Report

## 1. Overview
This document summarizes the execution of the state-level analysis plan, investigating the impact of climate shocks on healthcare financial outcomes (Premiums, Medical Debt, and Systemic Costs) from 1996 to 2025.

## 2. Analysis Workflow

### Phase 1: Data Pre-Processing
*   **Script:** `Code/analysis_pre_processing.R`
*   **Action:** 
    *   Loaded the consolidated master dataset (`Data/state_level_analysis_master.csv`).
    *   **Feature Engineering:**
        *   **Drought:** Binned `pdsi_sum` into `is_extreme_drought` (<-4), `is_severe_drought` (-4 to -3), and `is_extremely_wet` (>3).
        *   **Temperature:** Calculated state-specific Z-scores for `temp_sum` to define `is_heat_shock` (Z > 1.5) and `is_cold_shock` (Z < -1.5).
        *   **Energy Demand:** Identified the top quintile (80th percentile) of Cooling Degree Days (CDD) for each state to flag `is_high_cdd`.
    *   **Lag Generation:** Created 1-year and 2-year lags for all climate shock variables to test delayed effects.
*   **Error Resolution:**
    *   *Issue:* Initial script referenced `tmpc_sum` which did not exist.
    *   *Fix:* Verified column names in master CSV and corrected variable to `temp_sum`.

### Phase 2: Econometric Analysis
*   **Script:** `Code/run_analysis.R`
*   **Methodology:**
    *   **Model:** Fixed-Effects Regression (Within Estimator) with State and Year effects (`twoways`).
    *   **Clustering:** Standard Errors clustered at the State level (`vcovHC`, type "HC1") to account for serial correlation.
    *   **VIF Check:** Ran pooled OLS diagnostics to calculate Variance Inflation Factors (VIF). All VIFs were < 1.3, indicating negligible multicollinearity between the different climate shock bins.
*   **Error Resolution:**
    *   *Issue:* `coeftest` object could not be coerced directly to a data frame.
    *   *Fix:* Modified script to use `as.data.frame(unclass(sum_fem))` for proper extraction of results.

## 3. Key Decisions & Rationales

| Decision | Rationale |
| :--- | :--- |
| **Distributed Lags (0-2 Years)** | Insurance premiums are set based on prior year experience (Lag 1). Medical debt collection cycles typically take 1-2 years to appear in credit data (Lags 1 & 2). |
| **State-Specific Z-Scores** | Measuring heat/cold shocks relative to a state's *own* historical norm accounts for regional adaptation (e.g., a hot day in Maine is different from a hot day in Arizona). |
| **State-Level Clustering** | Essential for valid inference as climate treatments are highly correlated within states over time. |
| **Base Year Consistency** | Medical Debt data was pre-adjusted to 2023 dollars. While not explicitly re-baselined in the final regression script (as `_Real` variables were pre-calculated), the analysis relied on the `_Real` columns generated in the master creation phase. |

## 4. Summary of Findings

*   **Medical Debt:** Strongly responsive to climate shocks with a lag.
    *   **Extreme Drought (Lag 2):** Significant positive effect ($p < 0.01$).
    *   **Cold Shock (Lag 1):** Significant positive effect ($p < 0.001$).
*   **Premiums:** Showed sensitivity to lagged drought and temperature shocks, though significance was more marginal ($p < 0.05$).
*   **Systemic Costs:** Largely driven by economic controls (Income, Unemployment) rather than climate shocks.

## 5. Artifacts
*   **Processed Data:** `Data/analysis_ready_dataset.csv`
*   **Results Table:** `Analysis/regression_results_summary.csv`
*   **Diagnostics:** `Analysis/vif_diagnostics.txt`
