# County-Level Analysis Plan: Climate, Health Costs, and Financial Outcomes

## 1. Objective
To estimate the causal impact of environmental stressors (specifically state-level drought, local climate shocks, and air quality) on county-level healthcare financial outcomes (insurance premiums, medical debt) from ~2011 to 2025.

## 2. Unit of Analysis
**County-Year**.
All variables must be aggregated or mapped to the FIPS (County) level annually.

## 3. Data Sources & Variable Construction

### A. Dependent Variables (Outcomes)

#### 1. Health Insurance Premiums (Rating Area $\to$ County)
*   **Source:** HIX Compare (CMS) / `HIX_Data/plan details/` & `HIX_Data/crosswalk/`
*   **Native Level:** Rating Area (Geographic region defined by state).
*   **Files:**
    *   Crosswalk: `Data/HIX_Data/crosswalk/individual_county_rating_area_crosswalk_*.csv`
        *   Columns: `fips_code`, `rating_area_id`
    *   Premiums: `Data/HIX_Data/plan details/*.zip` (Rate files)
*   **Mapping Strategy:**
    *   **Step 1:** Aggregate Plan Data to Rating Area. Calculate the `Benchmark_Silver_Premium` (Second Lowest Cost Silver Plan) and `Lowest_Bronze_Premium` for each `RatingAreaId`.
    *   **Step 2:** Join with Crosswalk.
        *   `Left Join` Crosswalk (`fips_code`) with Premium Data (`rating_area_id`).
    *   **Handling Multi-County Areas:** Since Rating Areas are aggregates of counties, this is a 1-to-Many broadcast. Each county in Rating Area X gets the price for Rating Area X.
*   **Target Variable:** `Premium_Benchmark_Real` (Inflation adjusted to **2023 Dollars** to match Medical Debt data).

#### 2. Hospital "Bad Debt" & Costs (Hospital/Zip $\to$ County)
*   **Source:** NASHP Hospital Cost Tool / `Data/Hosp_Data/NASHP 2011-2023 HCT Data 2025 Feb.xlsx`
*   **Native Level:** Facility (Hospital) with **Zip Code**.
*   **Mapping Strategy (Zip $\to$ County):**
    *   **Crosswalk:** `Data/Zip County Crosswalk/zip2county_master_xwalk_2010_2023_tot_ratio_one2one.csv`
    *   **Logic:**
        1.  Sum variables by `Zip Code` and `Year`.
        2.  Join with Crosswalk on `ZIP` and `Year`.
        3.  **Allocation:** Distribute Zip-level dollars to counties based on `tot_ratio` (Residential Ratio).
        4.  Sum allocated amounts by `fips_code`.
*   **Target Variable:** `Uninsured_Bad_Debt_Per_Capita_Real` (Normalized by county population, adjusted to **2023 Dollars**).

#### 3. Consumer Medical Debt (County Level)
*   **Source:** Urban Institute / `Data/MedicalDebt/changing_med_debt_landscape_county.xlsx`
*   **Target Variables:** `Medical_Debt_Share`, `Medical_Debt_Median_2023`.

#### 4. County Population (Weighting & Normalization)
*   **Source:** SEER (NCI) / `Data/County Population/us.1969_2023.20ages.adjusted.txt`
*   **Implementation:** Sum age-sex-race specific counts to obtain total annual population for each FIPS code.
*   **Usage:** Used for population-weighting in regressions and calculating per-capita outcomes.

### B. Independent Variables (Climate & Environment)

#### 1. State-Level Environmental Stressors (Regional Shocks)
*   **Rationale:** Large-scale phenomena like drought are best measured at regional/state levels to capture systemic agricultural and macroeconomic stress.
*   **Source:** `Data/Climate_Data/state_climate_consolidated.csv`
*   **Primary Variable:** `pdsi_sum` (Palmer Drought Severity Index).
*   **Binned Interpretation:** 
    *   Extreme Drought: PDSI < -4.
    *   Severe Drought: -4 < PDSI < -3.
*   **Lags:** 1 and 2-year lags for both continuous and binned indicators.

#### 2. County-Level Climate Exposure (Local Shocks & Absolute Measures)
*   **Source:** NOAA County Climate Division files (`Data/Climate_Data/County level/`).
*   **Local Climate Shocks (Z-Scores):**
    *   **Temperature & Precipitation:** Calculated using county-specific historical means and standard deviations (1996-2025).
*   **Absolute Measures of Heat/Cold (Energy Demand):**
    *   **CDD/HDD Quintiles:** Created based on each county's own historical distribution to measure absolute physical intensity.
*   **Lags:** 1 and 2-year lags for all Z-scores and Absolute Extreme indicators.

#### 3. County-Level Air Quality Shocks
*   **Source:** EPA Annual AQI by County (`Data/AQIdata/`).
*   **Variable:** `AQI_Median` (Annual median of daily AQI values).
*   **Shock Definition:**
    *   **AQI Shocks (Z-Scores):** Calculated using county-specific historical means (2008-2025) to identify years with "Unusually Poor" air quality (e.g., wildfire smoke impacts).
*   **Lags:** 1 and 2-year lags.

## 4. Methodological Specification

### A. The Model (Fixed Effects) - Split Specifications
To avoid multicollinearity between "Relatively Hot" (Z-Score) and "Physically Hot" (CDD), we estimate two separate specifications using the `fixest::feols` package.

**Specification 1: The "Shock" Model (Adaptation Focus)**
$$ Y_{c,s,t} = \alpha_c + \gamma_t + \sum_{l=0}^{2} \beta_{1,l} \cdot \text{Drought}_{s,t-l} + \sum_{l=0}^{2} \beta_{2,l} \cdot \text{Z\_Shock}_{c,t-l} + \sum_{l=0}^{2} \beta_{3,l} \cdot \text{AQI\_Shock}_{c,t-l} + \delta \cdot \mathbf{X}_{c,t} + \epsilon_{c,s,t} $$

**Specification 2: The "Burden" Model (Physics/Energy Focus)**
$$ Y_{c,s,t} = \alpha_c + \gamma_t + \sum_{l=0}^{2} \beta_{1,l} \cdot \text{Drought}_{s,t-l} + \sum_{l=0}^{2} \beta_{3,l} \cdot \text{Absolute\_Extremes}_{c,t-l} + \delta \cdot \mathbf{X}_{c,t} + \epsilon_{c,s,t} $$

*   $\alpha_c$: County FE, $\gamma_t$: Year FE.
*   **Clustering:** Standard errors clustered at the **State Level** for all models.

### B. Robustness & Weighting
*   **Weighting:** Every outcome is run both **Unweighted** (average county response) and **Population-Weighted** (aggregate welfare impact).
*   **Rating Area Robustness:** Data is aggregated to the Rating Area level (population-weighted) and re-estimated to ensure results are not driven by the broadcasting of premiums.

## 5. Implementation Roadmap

1.  **Script 1: `process_zip_county_map.R`**
    *   Cleans Urban Institute data.
    *   Maps NASHP Zip-level costs to Counties using `zip2county_master_xwalk`.
2.  **Script 2: `process_rating_area_map.R`**
    *   Aggregates HIX plan details to Rating Area and joins with FIPS crosswalk.
3.  **Script 3: `create_county_master.R`**
    *   **Modular Sub-scripts:**
        *   `process_county_population.R`: Extracts total population from fixed-width SEER files using high-speed reading.
        *   `process_county_climate.R`: Generates Z-scores, Quintiles, and 0-2 year lags for climate variables.
        *   `process_county_aqi.R`: Extracts annual Median AQI and generates Z-score shocks and lags at the FIPS level.
    *   **Master Join:** Merges intermediate results and enforces **2023 Real Dollar** adjustment ($CPI_{2023} / CPI_{t}$).
4.  **Script 4: `run_county_analysis.R`**
    *   Executes primary County-Year FE models (Unweighted and Weighted).
    *   Performs Rating Area level aggregation and re-estimation for robustness.
    *   Exports results to `Analysis/county_analysis_results.txt`.
