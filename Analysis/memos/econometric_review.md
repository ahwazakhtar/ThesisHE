# Econometric Review of County-Level Analysis Plan

## 1. Specification Review: Multi-Level Data Aggregation

### A. The "Modifiable Areal Unit Problem" (MAUP) Risk
*   **Context:** You are mapping data from three different spatial resolutions:
    1.  **Zip Code** (Hospital Debt) $\to$ County
    2.  **Rating Area** (Premiums) $\to$ County
    3.  **State** (Drought) $\to$ County
*   **Assessment:**
    *   **Zip $\to$ County:** The proposed population-weighted mapping using `RES_RATIO` is the standard "best practice" (HUD Crosswalk method). **Verdict: Safe.**
    *   **Rating Area $\to$ County:** This is a 1-to-Many broadcast (since Rating Areas $>$ Counties).
        *   *Risk:* This creates "artificial precision." You have $N$ counties but only $M$ unique premium values ($N > M$). Standard errors calculated at the county level will be artificially small because the "treatment" (premium variation) is coarser than the unit of analysis.
        *   *Mitigation:* Your plan to **cluster standard errors at the State level** is CRITICAL here. It accounts for the fact that errors are correlated not just within a county over time, but across all counties in the same state (and thus same Rating Area).

### B. Rating Area Robustness Check
*   **Plan:** Run a separate regression at the Rating Area level.
*   **Assessment:** This is an excellent robustness check.
    *   *Method:* Aggregating county climate shocks to Rating Areas using population weights is econometrically sound. It tests if the "county-level" results are just artifacts of the broadcasting.

## 2. Variable Construction Review

### A. Absolute vs. Relative Climate Shocks
*   **New Plan:** Including *both* Relative Shocks (Z-scores > 1.5) and Absolute Burdens (Quintiles of CDD/HDD).
*   **Econometric Implication:**
    *   **Interpretation:** This disentangles *adaptation* from *physics*.
        *   Z-score tells us: "Was this year unexpected?" (Shock).
        *   CDD Quintile tells us: "Was the cooling load physically high?" (Burden).
    *   **Collinearity Risk:** High. A year with a high Z-score (Heatwave) will almost certainly be in the Top Quintile for CDD.
    *   *Mitigation:* Do not include them in the same regression simultaneously unless VIF is low. Run separate specifications: one for "Shocks" (Z-score) and one for "Burden" (Quintiles), or test their correlation first.

### B. Drought (State-Level)
*   **Constraint:** Drought is measured at the State level.
*   **Implication:** You cannot estimate the effect of drought on any outcome that doesn't vary within a state-year unless you have a control group.
    *   Since you *do* have county-level variation in outcomes (Medical Debt), this is fine. The model compares "High Drought State-Years" to "Low Drought State-Years," controlling for the average national trend.

## 3. Base Year & Inflation Consistency
*   **Critical Flag:** Your Medical Debt data is pre-adjusted to **2023 Dollars**.
*   **Requirement:** All other monetary variables (Premiums, Income, Uncompensated Care) **MUST** be adjusted to 2023 dollars.
    *   *Common Error:* Adjusting everything to "2020" or "Current Year."
    *   *Action:* In `create_county_master.R`, ensure the CPI adjustment factor is calculated as $CPI_{2023} / CPI_{t}$.

## 4. Final Recommendations for `county_level_analysis_plan.md`
1.  **Clustering is Non-Negotiable:** Because of the State-level Drought variable and Rating Area premiums, clustering at the **County** level would be scientifically invalid. State-level clustering is the correct approach.
2.  **Separate Climate Models:** Plan to run separate regressions for "Relative Shocks" vs. "Absolute Burdens" to avoid multicollinearity, then a combined one if stable.
3.  **Weights:** For the county-level regressions, consider running both **Unweighted** (policy focus) and **Population-Weighted** (welfare focus) specifications. A drought in Los Angeles County matters more for aggregate "systemic risk" than a drought in Alpine County.
