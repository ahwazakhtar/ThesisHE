# Overall Plan: State-Level Analysis Consolidation

This document tracks the completed steps and current status of building the master state-level dataset (1996–2025) for analyzing the relationship between climate shocks, healthcare expenditures, and economic policy.

## 1. Climate Data Extraction (`Code/process_state_climate.R`)
**Status: COMPLETE**
Extracted and aggregated environmental indicators from NOAA ClimDiv state-level files for the extended period **1996–2025**.
*   **Sources:**
    *   `climdiv-tmpcst-*` (Average Temperature) -> Annual Sum
    *   `climdiv-pcpnst-*` (Precipitation) -> Annual Sum
    *   `climdiv-pdsist-*` (Palmer Drought Severity Index) -> Annual Sum
    *   `climdiv-cddcst-*` (Cooling Degree Days) -> Annual Sum
    *   `climdiv-hddcst-*` (Heating Degree Days) -> Annual Sum
*   **Tasks Completed:**
    *   Parsed fixed-width format (FWF).
    *   Mapped NOAA numeric state codes to standard state names.
    *   Filtered for the target period: 1996–2025.
    *   Generated missing month flags for data integrity.

## 2. MEPS Expenditure Consolidation
**Status: COMPLETE**
Extracted employer-sponsored insurance proxies from AHRQ MEPS-IC using a dual-method approach to cover the full **1996–2024** timeline.
*   **Key Variables:**
    *   `Emp_Contrib_Single`: Average employee contribution for single coverage.
    *   `Avg_Deductible_Single`: Average deductible for single coverage (Available 2002+).
*   **Method 1: HTML Scraping (1996–2020)** (`Code/scrape_meps_html_base.R`)
    *   Used robust regex scraping to extract values from AHRQ's historical HTML tables (`tiic2` and `tiif1`).
    *   Implemented HTML tag stripping to handle formatting inconsistencies in older files.
*   **Method 2: Local Excel Extraction (2021–2024)** (`Code/extract_local_meps.R`)
    *   Processed local state-specific Excel files (`Data/MEPS_Data_IC/Excel/*.xlsx`).
    *   Implemented a "Deep Search" strategy to scan every sheet for "Contribution" and "Deductible" tables, extracting the state "Total" row.

## 3. CMS Health Expenditure Processing (`Code/process_cms_health_exp.R`)
**Status: COMPLETE**
Incorporated broader healthcare spending metrics from the CMS National Health Expenditure (NHE) reports for **1996–2020**.
*   **Source:** `Data/State Residence health expenditures/residence state estimates/`
*   **Key Variables:**
    *   `Total_Per_Capita_Health_Exp`: Total health spending per capita.
    *   `PHI_Per_Enrollee_Health_Exp`: Private health insurance spending per enrollee.
    *   `Medicaid_Per_Enrollee_Health_Exp`: Medicaid spending per enrollee.
    *   `Medicare_Per_Enrollee_Health_Exp`: Medicare spending per enrollee.
*   **Tasks Completed:**
    *   Pivoted "Wide" data (years as columns) to "Long" format (State-Year).
    *   Filtered specifically for "Personal Health Care" items to prevent duplication.

## 4. Medical Debt Consolidation (`Code/process_medical_debt.R`)
**Status: COMPLETE**
Extracted state-level medical debt trends for **2011–2023**.
*   **Source:** `Data/MedicalDebt/changing_med_debt_landscape_state.xlsx`
*   **Key Variables:**
    *   `Medical_Debt_Share`: Share of population with medical debt in collections.
    *   `Medical_Debt_Median`: Median medical debt in collections (in 2023 dollars).
*   **Tasks Completed:**
    *   Extracted data from the newly provided state-level Excel file.
    *   Standardized state names.
    *   Integrated into the master dataset via left-join.

## 5. Macroeconomic Integration
**Status: COMPLETE**
Merged economic controls to account for state-level financial health for **1996–2025**.
*   **Source:** `Data/State_Policy_Data/state_macroeconomics.csv`
*   **Key Variables:** Unemployment Rate, Personal Income Per Capita.
*   **Tasks Completed:**
    *   Aggregated monthly data to annual averages.
    *   Standardized state abbreviations (e.g., "AL") to full names ("Alabama").

## 6. Inflation Adjustment (`Code/create_state_master.R`)
**Status: COMPLETE**
Standardized all monetary values to "Real" dollars to ensure longitudinal comparability.
*   **Source:** US National CPI (CPIAUCNS) downloaded from FRED via `Code/download_state_policy_data.R`.
*   **Target Year:** Latest available year (currently **2025**).
*   **Process:**
    *   Calculated annual adjustment factors: `CPI_2025 / CPI_Year`.
    *   Applied adjustments to MEPS, CMS, and Macroeconomic income variables.
    *   **Special Handling:** Medical Debt (originally in 2023 dollars) was adjusted from its 2023 base to 2025 dollars.
*   **Output:** New columns with `_Real` suffix (e.g., `Emp_Contrib_Single_Real`, `Personal_Income_Per_Capita_Real`).

## 7. Master Dataset Creation (`Code/create_state_master.R`)
**Status: COMPLETE**
Finalized the "Ready-to-Analyze" dataset.
*   **Process:** Left-joined Climate (base), MEPS, CMS, Macro, and Medical Debt data on `State` and `Year`, followed by the inflation adjustment step.
*   **Output:** `Data/state_level_analysis_master.csv`.
*   **Dimensions:** 1530 observations (51 states/DC x 30 years).
*   **Coverage:** 1996–2025.

## 8. Next Steps / Recommendations
*   **Imputation:** Consider imputing the missing CMS data for 2021–2025 if broader health spending analysis is required for recent years.
*   **Validation:** Run outlier detection on the 2021–2024 MEPS data to ensure local Excel extraction remains consistent with historical trends.