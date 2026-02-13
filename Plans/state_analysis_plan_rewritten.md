# State-Level Analysis Plan: Climate Shocks and Healthcare Finance (Rewritten After Review - Feb 10, 2026)

This document updates and refines the state-level analysis plan after econometric review. It specifies estimands, identification assumptions, data windows, inference strategy, and robustness checks.

## 1. Objectives and Research Questions

Primary objective: estimate the association between climate shocks and state-level healthcare financial outcomes, with an emphasis on lagged effects.

Primary research questions:
1. Do extreme drought and temperature shocks increase employee premium contributions with lags?
2. Do drought and cold shocks increase medical debt prevalence and severity with lags?
3. Do climate shocks affect per-capita healthcare spending or public program spending?

## 2. Estimands and Interpretation

We target two estimands:
1. Total effect of climate shocks on outcomes (no potentially post-treatment controls).
2. Direct effect conditional on economic controls (income, unemployment) that may be affected by climate.

All causal language should be conditional on the identification assumptions in Section 5.

## 3. Data Sources, Coverage, and Sample Windows

Climate exposures can cover 1996-2025. Outcome availability varies by source. The analysis will be conducted on outcome-specific samples.

### 3.1 Outcome-Specific Sample Windows (to be verified by data audit)

| Outcome | Source | Earliest Year | Latest Year | Notes |
| --- | --- | --- | --- | --- |
| Emp_Contrib_Single_Real | MEPS-IC | Verify | Verify | State-level employee contribution data |
| Medical_Debt_Share | Urban Institute | Verify | Verify | State-level availability differs from county series |
| Medical_Debt_Median_Real | Urban Institute | Verify | Verify | Dollars are in 2023 base |
| Total_Per_Capita_Health_Exp_Real | CMS NHE | Verify | 2020 | NHE series end 2020 |
| Medicaid_Per_Enrollee_Health_Exp_Real | CMS NHE | Verify | 2020 | NHE series end 2020 |
| Medicare_Per_Enrollee_Health_Exp_Real | CMS NHE | Verify | 2020 | NHE series end 2020 |

Action: before final estimation, produce a table of actual years per outcome and confirm unbalanced panel handling.

## 4. Variable Construction

### 4.1 Climate Exposure Definitions

Binned indicators capture extreme shocks rather than linear effects.

| Variable | Raw Metric | Binning | Interpretation |
| --- | --- | --- | --- |
| Drought Intensity | pdsi_sum | < -4: Extreme; -4 to -3: Severe | Systemic water stress |
| Heat Shock | temp_sum | Z-score > 1.5 | Unusually hot vs baseline |
| Cold Shock | temp_sum | Z-score < -1.5 | Unusually cold vs baseline |
| Energy Demand | cdd_sum | Top quintile | High cooling load |

Baseline definition for Z-scores and quintiles:
- Use a fixed baseline period, preferred 1996-2010, to avoid look-ahead bias.
- Alternative sensitivity: expanding window or 1981-2010 normals if available.

### 4.2 Outcomes

All monetary outcomes must be in 2023 dollars. Use CPI_2023 / CPI_t, document CPI series and formula in the script header.

Primary outcomes:
- Emp_Contrib_Single_Real
- Medical_Debt_Share
- Medical_Debt_Median_Real

Secondary outcomes:
- Total_Per_Capita_Health_Exp_Real
- Medicaid_Per_Enrollee_Health_Exp_Real
- Medicare_Per_Enrollee_Health_Exp_Real

### 4.3 Controls

Core controls:
- Personal_Income_Per_Capita_Real
- Unemployment_Rate
- Policy indicators (Medicaid expansion, 1332 waivers)

These may be post-treatment. Models will be reported both with and without these controls.

## 5. Identification Assumptions

1. Conditional on state FE and year FE, climate shocks are exogenous to unobserved determinants of health finance outcomes.
2. Remaining time-varying confounders are limited or captured by trends and robustness checks.

Threats:
- Time-varying state economic structure
- Migration responses to climate shocks
- State policy responses to climate exposure

## 6. Econometric Specification

Baseline FE model with distributed lags:

Y_{s,t} = alpha_s + gamma_t + sum_{l=0}^2 beta_l * ClimateShock_{s,t-l} + X_{s,t}'delta + epsilon_{s,t}

Extensions:
- Extended lags (0-4) or smooth distributed-lag models (Almon or spline)
- State-specific linear trends as robustness checks
- Region-by-year FE as sensitivity

## 7. Inference and Standard Errors

- Primary clustering at the state level.
- Use small-sample robust inference: CR2 or wild cluster bootstrap.
- Report both conventional and corrected SEs where feasible.

## 8. Robustness Checklist

1. Placebo leads of climate shocks (1-2 year leads).
2. Alternative thresholds for shock bins (1.0, 2.0 Z-score cutoffs).
3. Continuous exposure models (pdsi_sum, temp_sum) as sensitivity.
4. Alternative baseline definitions for Z-scores and quintiles.
5. State trends and region-year FE sensitivity.

## 9. Multiple-Testing Guardrails

Pre-specify:
- Primary exposure: Extreme Drought and Cold Shock.
- Primary outcome: Emp_Contrib_Single_Real and Medical_Debt_Share.

Apply FDR adjustments across secondary outcomes and exposures as sensitivity.

## 10. Implementation Roadmap

1. Data audit: confirm year coverage by outcome and create a window table.
2. Feature engineering: update baseline definitions for Z-scores and quintiles.
3. Estimation: run baseline models, then robustness checks.
4. Reporting: include coefficient plots, cumulative lag effects, and placebo lead results.

## 11. Expected Artifacts

- Analysis/regression_results_premiums.csv
- Analysis/state_analysis_summary.md
- Analysis/Figures/lag_effect_plot.png

Notes:
- Avoid claims beyond available sample windows.
- Interpret results as associations unless identification assumptions are strengthened.
