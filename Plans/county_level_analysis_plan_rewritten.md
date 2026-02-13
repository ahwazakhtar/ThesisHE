# County-Level Analysis Plan: Climate, Health Costs, and Financial Outcomes (Rewritten After Review - Feb 10, 2026)

This document updates the county-level analysis plan after econometric review, with explicit identification assumptions, inference strategy, and robustness checks.

## 1. Objective

Estimate the association between environmental stressors (state-level drought and local climate shocks) and county-level healthcare financial outcomes from the earliest feasible year through 2025, with outcome-specific samples.

## 2. Unit of Analysis

County-Year. All variables are mapped to county FIPS annually.

## 3. Data Sources, Coverage, and Sample Windows

Outcome availability varies by source. All analysis is outcome-specific.

### 3.1 Outcome-Specific Sample Windows (to be verified by data audit)

| Outcome | Source | Earliest Year | Latest Year | Notes |
| --- | --- | --- | --- | --- |
| Premium_Benchmark_Real | HIX Compare | Verify | Verify | HIX premiums begin in 2014 for most states |
| Uninsured_Bad_Debt_Per_Capita_Real | NASHP HCT | Verify | 2023 | Hospital data ends 2023 |
| Medical_Debt_Share | Urban Institute | Verify | Verify | In 2023 dollars |
| Medical_Debt_Median_2023 | Urban Institute | Verify | Verify | In 2023 dollars |

Action: confirm actual years and document unbalanced panel strategy.

## 4. Variable Construction

### 4.1 Premium Mapping (Rating Area to County)

- Aggregate plan details to rating area.
- Benchmark: Second Lowest Cost Silver Plan (SLCSP) for a fixed reference age.
- Broadcast rating-area premiums to counties via crosswalk.
- Document rating-area changes over time.

### 4.2 Hospital Costs (ZIP to County)

- Aggregate hospital data by ZIP and year.
- Map ZIPs to counties using year-appropriate crosswalk and residential ratios.
- Allocate and sum to county level.

### 4.3 Medical Debt

- Use Urban Institute county series; already in 2023 dollars.

### 4.4 Climate Exposure

State-level drought:
- pdsi_sum with bins (< -4 extreme; -4 to -3 severe), plus lags 1-2.

County-level climate shocks:
- Z-scores for temperature and precipitation.
- CDD/HDD quintiles for absolute burden.

Baseline definition:
- Use fixed baseline (preferred 1996-2010) or NOAA normals if available.
- Report sensitivity to alternative baseline definitions.

## 5. Identification Assumptions

1. Conditional on county FE and year FE, local climate shocks are exogenous to unobserved county-level drivers of outcomes.
2. State-level drought variation is exogenous to time-varying state-level confounders after FE and robustness checks.

Threats:
- Time-varying local economic shifts
- Policy responses correlated with drought
- Migration and compositional changes

## 6. Econometric Specification

Two separate FE models to avoid collinearity.

Shock model:
Y_{c,s,t} = alpha_c + gamma_t + sum_{l=0}^2 beta_{1,l} Drought_{s,t-l} + sum_{l=0}^2 beta_{2,l} ZShock_{c,t-l} + X_{c,t}'delta + epsilon_{c,s,t}

Burden model:
Y_{c,s,t} = alpha_c + gamma_t + sum_{l=0}^2 beta_{1,l} Drought_{s,t-l} + sum_{l=0}^2 beta_{3,l} AbsExtreme_{c,t-l} + X_{c,t}'delta + epsilon_{c,s,t}

Extensions:
- Extended lags (0-4) or smooth distributed lags.
- County-specific linear trends as sensitivity.

## 7. Inference and Standard Errors

- Primary clustering at the state level (non-negotiable due to drought and rating-area premiums).
- Small-sample corrections: CR2 or wild cluster bootstrap.
- For premium outcomes, consider two-way clustering by state and rating area if feasible.
- Spatial correlation: Conley or spatial HAC as robustness if tractable.

## 8. Robustness Checklist

1. Placebo leads (1-2 years) for climate exposures.
2. Alternative Z-score thresholds and continuous exposure models.
3. Alternative baseline definitions for shocks and quintiles.
4. Rating-area level aggregation and re-estimation.
5. Bounded outcome checks for Medical_Debt_Share (fractional model or logit link as sensitivity).

## 9. Multiple-Testing Guardrails

Pre-specify:
- Primary exposure: Extreme Drought and local temperature shock.
- Primary outcome: Premium_Benchmark_Real and Medical_Debt_Share.

Apply FDR adjustments across secondary outcomes and exposures as sensitivity.

## 10. Implementation Roadmap

1. Data audit: confirm year coverage by outcome and create window table.
2. Process ZIP-to-county and rating-area-to-county mappings.
3. Construct climate shocks using fixed baseline definitions.
4. Estimate baseline FE models, then robustness checks.
5. Output results and diagnostics.

## 11. Expected Artifacts

- Analysis/county_analysis_results.txt
- Analysis/Figures/county_lag_effects.png
- Analysis/county_analysis_summary.md

Notes:
- Avoid claims beyond actual data coverage.
- Interpret results as associations unless identification assumptions are strengthened.
