# Interpretation of State-Level Regression Results
**Date:** February 9, 2026
**Model:** Fixed-Effects Regression (State + Year) with Distributed Lags (0-2 Years)
**Standard Errors:** Clustered at the State Level

This document provides a detailed interpretation of the regression results found in `regression_results_summary.csv`. The analysis investigates the impact of climate shocks (Drought, Heat, Cold, Energy Demand) on healthcare financial outcomes.

## 1. Executive Summary

The analysis reveals that **Medical Debt (Prevalence)** and **Medicaid Spending** are the most sensitive to climate shocks, specifically **Drought** and **Cold Events**, typically with a **1-2 year lag**.

*   **Medical Debt Share** significantly increases 2 years after an Extreme Drought and 1 year after a Cold Shock.
*   **Medicaid Per Enrollee Costs** surge significantly 2 years after a Severe Drought.
*   **Commercial Premiums** show a reaction to Extreme Drought (1-year lag), suggesting insurers adjust pricing retrospectively.
*   **Systemic Costs (Total Per Capita)** are largely insulated from specific climate shocks, likely due to the diversity of payers and smoothing effects.

---

## 2. Detailed Findings by Outcome

### A. Employee Premiums (`Emp_Contrib_Single_Real`)
*   **Extreme Drought (Lag 1):** **+ $20.70** ($p < 0.05$).
    *   *Interpretation:* Insurers appear to raise premiums in the year following an extreme drought event. This is consistent with a retrospective pricing model where losses (or anticipated risks) from the shock year are priced into the subsequent renewal cycle.
*   **Cold Shock (Lag 1):** **- $41.58** ($p < 0.05$).
    *   *Interpretation:* Counter-intuitively, premiums decreased following cold shocks. This requires further investigation—it could be related to decreased utilization during extreme cold (cancelled elective procedures) leading to lower claims and subsequently lower premiums.
*   **Unemployment Rate:** **+ $14.02** per percentage point.
    *   *Interpretation:* Weaker labor markets correlate with higher employee contributions, possibly because employers shift more cost burden to employees when labor supply is high.

### B. Medical Debt Prevalence (`Medical_Debt_Share`)
*   **Extreme Drought (Lag 2):** **+ 0.54 percentage points** ($p < 0.01$).
    *   *Interpretation:* This is a highly significant finding. It suggests a delayed financial cascade: a drought hits, economic or health stress builds up over a year, and by year 2, individuals face collections.
*   **Cold Shock (Lag 1):** **+ 1.2 percentage points** ($p < 0.001$).
    *   *Interpretation:* A very strong immediate-to-short-lag effect. Cold shocks (e.g., Polar Vortex) may lead to immediate expensive emergency care (respiratory, cardiovascular) that quickly translates into debt.
*   **High Cooling Demand (CDD Lag 2):** **+ 0.47 percentage points** ($p < 0.05$).
    *   *Interpretation:* Sustained heat/energy stress also correlates with higher debt burdens with a 2-year lag.

### C. Medical Debt Severity (`Medical_Debt_Median_Real`)
*   *Observation:* Unlike the *share* of the population with debt, the *median amount* of debt did not show statistically significant responses to climate shocks at the $p < 0.05$ level.
*   *Interpretation:* Climate shocks appear to push *more people* into debt (extensive margin) rather than significantly increasing the debt burden of those already in debt (intensive margin).

### D. Medicaid Spending (`Medicaid_Per_Enrollee_Health_Exp_Real`)
*   **Severe Drought (Lag 2):** **+ $511.42** ($p < 0.05$).
    *   *Interpretation:* A massive increase in per-enrollee spending. This could suggest that severe droughts lead to deteriorating health conditions for vulnerable (low-income) populations that manifest as expensive treatments (hospitalizations) two years later.
*   **Unemployment:** Not statistically significant in this specification, likely because Medicaid enrollment fluctuates with unemployment (denominator effect), smoothing the per-enrollee cost.

### E. Medicare Spending (`Medicare_Per_Enrollee_Health_Exp_Real`)
*   **High Cooling Demand (CDD Lag 2):** **- $101.75** ($p < 0.01$).
    *   *Interpretation:* Unexpected negative correlation. High cooling demand years might be associated with higher mortality among the frail elderly (harvesting effect), potentially reducing average per-capita spending in the surviving cohort, or it may be a statistical anomaly requiring robustness checks.
*   **Unemployment:** **+ $91.38** ($p < 0.001$).

---

## 3. Conclusions for Policy

1.  **Lagged Response is Key:** Policy interventions targeting climate-related financial stress should not just focus on the event year. The financial "pain" (Medical Debt, Medicaid costs) often peaks **12-24 months after the shock**.
2.  **Vulnerability:** The Medicaid and Medical Debt results highlight that low-income populations bear the brunt of the financial impact.
3.  **Insurer Pricing:** The premium response suggests the commercial market is reacting to these risks, passing costs to employees with a 1-year lag.
