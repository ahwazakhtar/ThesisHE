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

---

## 6. Committee Feedback April 2026 — Robustness Layer

Track: [`committee_feedback_april_2026`](../conductor/tracks/committee_feedback_april_2026/). The committee's April 2026 feedback added a robustness layer on top of the analysis above. This section summarizes how the headline findings (Extreme Drought 2-year lag and Cold Shock 1-year lag raising Medical Debt and Insurance Premiums) hold up under the additional designs.

### 6.1 Random-effects robustness (Hausman) — Phase 1

Source: `Code/run_re_robustness.R` · Memo: `Analysis/random_effects_robustness.md`

- The Hausman test rejects RE in favor of FE for **every estimable outcome** at p < 1e-9 (4 state outcomes converged; 2 — Emp_Contrib_Single_Real and Medical_Debt_Median_Real — failed to fit RE due to thin MEPS-IC year coverage).
- **Headline-coefficient verdict:** RE estimates on `is_extreme_drought_lag2` and `is_cold_shock_lag1` have the same sign as FE; the rejection of RE is driven by precision on lagged terms rather than coefficient reversals. The single outcome with material FE-RE divergence is Medicaid_Per_Enrollee_Health_Exp_Real (RE ≈ 2× FE on cold-shock terms) — reported in the memo for transparency.
- **Implication for the write-up:** FE remains the maintained specification. The state findings would survive even if RE were the right spec on point estimates; we use FE on consistency grounds (Hausman) rather than as a magnitude argument.

### 6.2 Natural-experiment DiD with never-exposed controls — Phase 3

Source: `Code/run_did_analysis.R` · Memo: `Analysis/did/did_results.md`. Pre-feasibility memo: `Analysis/did_feasibility_memo.md`.

The committee asked whether the LP/FE results could be replicated using a sharp natural experiment with never-exposed counties as controls. The Phase 0 inventory found large never-exposed pools for Drought (78.6%), HDD (71.4%), and CDD (65.8%); AQI was dropped from the DiD scope (3.1% never-exposed too thin).

- **2012 Midwest drought 2×2 DiD** (139 treated counties, 2,534 never-exposed):
    - **PCPI_Real ATT = −$1,311 (p=0.027)**
    - **Civilian_Employed ATT = −2,053 (p=0.0001)**
    - These are *county-level* outcomes; their state-level analogues in this summary's headline (Medical Debt) work through the income channel documented in `Text/propagation_pathways.md` §3.
- **HDD Callaway-Sant'Anna long-run profile:** Civilian_Employed loss compounds to −4,982 by event-time 10 (p=0.003); Medical_Debt_Share rises +4.9 percentage points at e=10 (p=0.0002). This *long-run cold-state scarring* is consistent with the state-level `is_cold_shock_lag1` finding and extends it across multi-year horizons.
- **Implication for the write-up:** The headline state-level effects survive being recast as a never-exposed-controlled DiD design at the county level. The 2012 drought is now the cleanest single piece of identification in the thesis.

### 6.3 Propagation pathways now evidence-backed — Phase 5

Source: `Text/propagation_pathways.md` · Descriptives: `Analysis/pathway_descriptives_summary.md`

The four pathways underlying the headline findings (heat → delayed care, cold → shifted utilization, drought → income → debt, AQI → respiratory/cardiac) are now anchored to 18 cited references with effect-direction and time-scale claims. The drought→income→debt pathway has the strongest convergence: Hornbeck (2012), Burke-Hsiang-Miguel (2015), Carleton et al. (2022), and our own 2012 DiD all point the same direction at consistent 1- to 3-year horizons.

### 6.4 Humidity NOT yet controlled — Phase 4 parked

Phase 4 (acquire PRISM `tdmean` at state level and add as control) is **parked** because the required `terra`, `sf`, and `tigris` R packages are not installed in the local environment. See `memory/project_humidity_phase4.md` for the working PRISM endpoint and resumption notes.

**Outstanding caveat for the thesis text:** the headline drought and cold findings have not been stress-tested against humidity confounding. A discussant asking "could the drought lag actually be picking up low-humidity confounding?" cannot be definitively answered with the current pipeline. This is the highest-priority residual gap from the committee's feedback.

### 6.5 Summary table — what changed after committee feedback

| Concern | Status | Where addressed |
|---------|--------|-----------------|
| Random effects check | Done — RE rejected, headlines survive | §6.1, `Analysis/random_effects_robustness.md` |
| Post-exit dynamics | Done — see `Analysis/delta_analysis_synthesis.md` | County-level (delta + LP) |
| Natural-experiment DiD with never-exposed | Done — Drought 2012 is cleanest | §6.2, `Analysis/did/did_results.md` |
| Propagation evidence | Done — 18 references + descriptive plots | §6.3, `Text/propagation_pathways.md` |
| Humidity (PRISM tdmean) | **Parked** — packages not installed | §6.4 — flag in thesis text |
