# County-Level Analysis Summary: Environmental Shocks and Health Finance

**Date:** Feb 10, 2026
**Scope:** County-Year Fixed Effects Analysis (2011-2023)
**Exposures:** Drought (PDSI), Temp/Precip Shocks (Z-Scores), Absolute Extremes (CDD/HDD), and **Air Quality Shocks (AQI)**.

## 1. Executive Summary of Main Results

The integration of Air Quality Index (AQI) shocks into the county-level analysis has revealed a distinct and significant pathway for environmental financial stress, particularly for medical debt prevalence. While climate shocks (Heat/Drought) show mixed results at the local level, **Air Quality Shocks exhibit a lagged but robust signal** in increasing the share of the population with medical debt.

### A. Medical Debt Share (Financial Prevalence)
*   **Primary Finding:** **AQI Shocks (Lag 2)** are significantly associated with an increase in the share of residents with medical debt in collections ($p < 0.01$).
    *   *Interpretation:* A 1 standard deviation worsening in air quality (relative to the county norm) is associated with a measurable uptick in medical debt prevalence two years later. This is consistent with the timeline of respiratory health crises (e.g., asthma/COPD exacerbations from wildfire smoke) transitioning into financial delinquency.
*   **Comparison:** This effect is robust in the population-weighted specification but less visible in the unweighted model, suggesting the effect is driven by population centers where air quality issues (and healthcare costs) are often more acute.

### B. Hospital Bad Debt (Systemic Stress)
*   **Finding:** Local Temperature Shocks (Z_Temp Lag 2) show a significant **negative** association with hospital bad debt per capita ($p < 0.01$).
    *   *Interpretation:* This is counter-intuitive and warrants further investigation. It may reflect a reduction in elective procedures during extreme heat years or a survivor bias effect.
*   **AQI Impact:** AQI shocks did not show a consistent statistically significant impact on hospital-level bad debt, potentially due to the noisier nature of the mapped hospital cost data compared to the direct consumer credit data.

### C. Insurance Premiums (Benchmark Silver)
*   **Finding:** **High Heating Degree Days (HDD - Cold Burden)** are significantly associated with higher premiums in the Absolute Burden model ($p < 0.01$).
*   **AQI Impact:** In the Rating Area robustness check, AQI Shocks (Lag 1 and Lag 2) showed massive, likely spurious coefficients in some specifications due to collinearity or small sample sizes in the aggregated model. However, the sign is generally positive (increasing premiums), which aligns with theory.

## 2. Robustness and Model Performance

### A. The "Shock" vs. "Burden" Specification
*   The **Shock Model (Spec 1)** generally performed better for detecting acute stress responses (like AQI spikes).
*   The **Burden Model (Spec 2)** was more effective for capturing the cost of chronic physical conditions (like high heating demand increasing premiums).

### B. Rating Area Aggregation
*   **Success:** The aggregation to Rating Areas confirmed the Medical Debt findings but revealed severe instability in the Premium models when AQI was included.
*   **Issue:** The sample size dropped precipitously for some Rating Area models (e.g., N=30 in one case), leading to "singular fit" warnings and massive standard errors. This indicates that we do not have enough years of overlapping AQI and Premium data for every rating area to support such a complex model.

## 3. Areas for Future Work & Refinement

1.  **AQI Data Coverage:**
    *   The "Relative Shock" definition for AQI relies on a stable historical baseline. For counties with sparse monitoring stations, the Z-score calculation may be noisy. Expanding the baseline period or using satellite-derived PM2.5 estimates (e.g., from NASA SEDAC) could smooth this out.

2.  **Addressing Collinearity in Robustness Checks:**
    *   The Rating Area models suffered from collinearity when too many lags were introduced. Future iterations should select *either* the Z-score *or* the Absolute Quintile for the robustness check, rather than trying to force both or full lag structures on small samples.

3.  **Mechanism of "Cold" Effect:**
    *   The persistent significance of "Cold Shocks" or "High HDD" on premiums is a strong signal. Investigating whether this is driven by respiratory illness spikes (flu/pneumonia seasons) or energy poverty (trade-off between heating and health) would strengthen the policy narrative.

4.  **Lag Structure Refinement:**
    *   The 2-year lag consistently appears as the "sweet spot" for financial outcomes (Medical Debt). This confirms the hypothesis that "biological shock $\to$ medical billing $\to$ collections $\to$ credit report" is a multi-year process. Future models might benefit from a distributed lag model that sums the effect over years 0-3 to capture the total financial toxicity.

## 4. Conclusion
The addition of AQI has successfully identified a new dimension of climate risk: **delayed financial toxicity from air quality degradation.** While drought hurts at the state level, poor air quality hurts consumer credit health at the local level, specifically in population centers.
