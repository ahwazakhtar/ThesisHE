# State-Level Analysis Plan: Environmental Shocks and Healthcare Finance

This document outlines the analytical framework for investigating how environmental variations (climate and air quality) impact health insurance premiums, medical debt, and overall healthcare expenditures across the United States (1996–2025).

## 1. Research Questions
1.  Do extreme climate events (drought, heatwaves) lead to measurable increases in employee health insurance contributions with a lag?
2.  Is there a threshold effect where "Extreme" drought (PDSI) significantly increases the share of the population with medical debt?
3.  How do climate-driven energy demands (CDD/HDD) and **temperature shocks (Heat/Cold)** correlate with per capita healthcare spending?
4.  Does chronic or acute exposure to poor air quality (AQI shocks) exacerbate healthcare financial burdens and systemic costs?

## 2. Variables of Interest

### A. Exposure Variables (Environmental) - "Binned" Interpretation
Rather than linear effects, we will use binned variables to capture "shocks" and "extremes."

| Variable | Raw Metric | Binning Strategy | Interpretation |
| :--- | :--- | :--- | :--- |
| **Drought Intensity** | `pdsi_sum` | < -4: Extreme Drought; -4 to -3: Severe; > 3: Extremely Wet | Captures agricultural and water-stress shocks. |
| **Heat Shocks** | `temp_sum` | State-specific Z-score > 1.5 | Captures "Unusually Hot" years relative to state norms. |
| **Cold Shocks** | `temp_sum` | State-specific Z-score < -1.5 | Captures "Unusually Cold" years (e.g., polar vortex events). |
| **Energy Demand** | `cdd_sum` | Top Quintile (20%) within State | High-cooling years (heatwaves) that drive systemic stress. |
| **Air Quality Shocks**| `aqi_mean`* | Top Quintile (20%) within State | Captures "Unusually Polluted" years (e.g., wildfire smoke). |

*\*Note: State-level AQI is calculated as a **population-weighted average** of county-level annual means to represent the exposure of the average resident.*

### B. Dependent Variables (Financial Outcomes)
All monetary variables must use the `_Real` (inflation-adjusted) versions.

*   **Primary Outcome:** `Emp_Contrib_Single_Real` (Employee Premium Burden)
*   **Secondary Outcome:** `Medical_Debt_Share` (Financial Fragility - Prevalence)
*   **Secondary Outcome:** `Medical_Debt_Median_Real` (Financial Fragility - Severity)
*   **Systemic Outcome:** `Total_Per_Capita_Health_Exp_Real` (NHE spending)
*   **Systemic Outcome:** `Medicaid_Per_Enrollee_Health_Exp_Real` (Public Safety Net)
*   **Systemic Outcome:** `Medicare_Per_Enrollee_Health_Exp_Real` (Elderly/Disabled)

### C. Controls (Economic State)
*   `Personal_Income_Per_Capita_Real`
*   `Unemployment_Rate`
*   State Policy Indicators (Medicaid Expansion, 1332 Waivers)

## 3. Modeling Strategy: Distributed Lag Fixed-Effects

We will employ a Fixed-Effects (FE) regression model to control for time-invariant state characteristics (e.g., geography) and national trends (e.g., federal policy changes).

### The Model
$$Y_{s,t} = \alpha_s + \gamma_t + \sum_{l=0}^{2} \beta_l \cdot EnvShock_{s,t-l} + \mathbf{X}_{s,t}'\delta + \epsilon_{s,t}$$

*   **$\alpha_s$**: State Fixed Effects (controls for "baseline" state health).
*   **$\gamma_t$**: Year Fixed Effects (controls for national inflation/policy).
*   **$l \in \{0, 1, 2\}$**: Lags of 0, 1, and 2 years. 
    *   *Rationale:* Health insurance premiums are often set 6–12 months in advance based on the previous year's claims. Medical debt may take 1–2 years to move into "collections."

## 4. Proposed Analysis Workflow

### Step 1: Feature Engineering (`Code/analysis_pre_processing.R`)
*   **Aggregation:** Map county-level AQI to states using population weights (SEER data) to generate the state-level `aqi_mean`.
*   **Baselines:** Calculate state-specific historical means for `temp_sum`, `precip_sum`, and `aqi_mean`.
*   **Binning:** Create dummy variables for bins (e.g., `is_extreme_drought`, `is_heat_shock`, `is_high_aqi`).
*   **Lags:** Generate lagged variables for all environmental dummies (1-year and 2-year lags).

### Step 2: Exploratory Data Analysis (EDA)
*   **Event Studies:** Plot `Medical_Debt_Share` for states that experienced a "Severe Drought" (PDSI < -3) vs. those that did not.
*   **Heatmaps:** Correlation between lagged CDD shocks and current `Emp_Contrib_Single_Real`.

### Step 3: Formal Regression Analysis
*   Run the FE models using the `plm` or `fixest` packages in R.
*   Test for "Parallel Trends" in a Difference-in-Differences (DiD) framework if looking at specific policy shocks (e.g., Medicaid Expansion * Climate interaction).

## 5. Expected Artifacts
*   `Analysis/regression_results_premiums.csv`: Coefficients and p-values.
*   `Analysis/Figures/lag_effect_plot.png`: Visualizing the impact of a climate shock over a 3-year horizon.

## 6. Analysis Status & Findings (Feb 2026)

### Execution Status
*   **Data Processing:** Completed via `Code/analysis_pre_processing.R`. Climate shocks (Drought, Heat, Cold, CDD) and 0-2 year lags were generated for all 50 states.
*   **Modeling:** Completed via `Code/run_analysis.R`. Fixed-Effects models with State-Level clustering were estimated for Premiums, Medical Debt, and Systemic Costs.
*   **Diagnostics:** VIF analysis confirmed no significant multicollinearity between climate bin indicators.

### Key Findings
1.  **Medical Debt:** Highly sensitive to climate shocks with a delay.
    *   **Extreme Drought (Lag 2):** Significant positive impact ($p < 0.01$).
    *   **Cold Shock (Lag 1):** Significant positive impact ($p < 0.001$).
2.  **Premiums:** showed a significant response to **Extreme Drought (Lag 1)** ($p < 0.05$) and **Cold Shocks**, suggesting insurers price in these risks retrospectively.
3.  **Systemic Costs (NHE):** Did not show consistent sensitivity to climate shocks, likely due to the smoothing effect of federal subsidies and long-term contracts.
