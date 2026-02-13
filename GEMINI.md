# Project Overview

This is a research project (likely a thesis) focused on the aggregation and analysis of United States health, climate, and economic data. The project relies on R for data acquisition and subsequent analysis. The primary goal is constructing a multi-dimensional dataset spanning several years (mostly ~2011-2026) to investigate relationships between environmental factors (Climate, AQI), health costs (HIX premiums, Hospital costs, Medical debt), and policy.

**Status Update (Feb 2026):**
*   **State-Level Analysis:** Completed. Found significant evidence that **Extreme Drought (2-year lag)** and **Cold Shocks (1-year lag)** increase Medical Debt and Insurance Premiums.
*   **County-Level Analysis:** **In Progress.** Data processing scripts for Zip-to-County mapping and population weighting are implemented. Regional (State) drought and local (County) climate shocks (Z-scores) and absolute burdens (HDD/CDD) are being modeled.

# Directory Structure

## `Code/`
Contains R scripts used to automate the downloading and processing of raw data.
- `download_*.R`: Acquisition scripts for climate, HIX, MEPS, and policy data.
- `create_state_master.R`: Consolidates state-level panel.
- `analysis_pre_processing.R`: Feature engineering for state-level analysis.
- `run_analysis.R`: State-level Fixed-Effects models.
- `process_zip_county_map.R`: **New.** Maps Zip-level hospital costs and Urban Institute medical debt to counties using master crosswalks.
- `process_rating_area_map.R`: Maps HIX premiums from Rating Areas to Counties.
- `create_county_master.R`: **New.** Consolidates county-level master dataset, processes SEER population data, and generates local climate shocks (Z-scores) and binned absolute extremes (CDD/HDD).
- `run_county_analysis.R`: **New.** Executes county-level FE models with state-level clustering, including unweighted and population-weighted specifications.

## `Data/`
The core storage for raw and processed datasets.
- **AQIdata/**: Annual Air Quality Index data by county (EPA).
- **Climate_Data/**:
    - `County level/`: Temp, precipitation, heating/cooling degree days.
    - `State level/`: Similar metrics aggregated at the state level, plus drought indices (PDSI, PHDI, PMDI, ZNDX).
- **County Population/**: **New.** SEER county-level population estimates (1969-2023) used for weighting and per-capita normalization.
- **Zip County Crosswalk/**: **New.** Master crosswalk for Zip-to-County allocation based on residential ratios (2010-2023).
- **HIX_Data/**: Health Insurance Exchange data including:
    - `crosswalk/`: Mapping counties to rating areas.
    - `plan details/`: Detailed plan attributes and rates.
- **Hosp_Data/**: Hospital Cost Tool data (NASHP).
- **MedicalDebt/**: County-level medical debt trends (Urban Institute).
- **MEPS_Data_IC/**: Medical Expenditure Panel Survey Insurance Component data.
- **State Residence health expenditures/**: CMS National Health Expenditure (NHE) data (1991-2020).
- **State_Policy_Data/**: Macroeconomic indicators (Unemployment, Personal Income, CPI).
- **data sources.txt**: A text file listing source URLs for the datasets.
- **state_level_analysis_master.csv**: The consolidated state-level panel.
- **county_level_master.csv**: **New.** The consolidated county-level panel with local shocks and lags.

## `Analysis/`
The core storage for analysis outputs.
- **regression_results_summary.csv**: **Updated.** Coefficients, standard errors, and p-values for the primary models (Premiums, Medical Debt, and Systemic Costs).
- **state_analysis_summary.md**: **New.** Detailed report of the state-level regression workflow and findings.
- **econometric_review.md**: **New.** Expert review of the econometric specifications.

## `Text/`
Contains documentation and research proposals.
- `v2_Akhtar_Proposal.pdf`: Likely the thesis or research proposal document.
- `state_analysis_plan.md`: Detailed plan for the binned climate shock analysis and distributed lag modeling.
- `county_level_analysis_plan.md`: **New.** Detailed plan for the upcoming county-level analysis.
- `abstract_draft.md` / `abstract_draft.html`: The research abstract summarizing methodology and key findings regarding lagged climate impacts.

# Data Sources & References

Based on `Data/data sources.txt` and script inspection:

| Domain | Source | Details / Key Variables |
| :--- | :--- | :--- |
| **Climate** | NOAA (NCEI) | Temp, Precip, CDD, HDD, and Drought Indices (PDSI, PHDI, PMDI, ZNDX). |
| **Air Quality** | EPA | Annual AQI by county. |
| **Inflation** | FRED | US National CPI (CPIAUCNS) for Real Dollar conversion. |
| **HIX Premiums** | HIX Compare | Individual market archives (Premiums, Plan details). |
| **Health Spending** | CMS (NHE) | Per capita and per enrollee spending by state (Total, PHI, Medicare, Medicaid). |
| **Employer Ins.** | AHRQ (MEPS-IC) | Employee contributions and deductibles (State-level). |
| **Hospital Costs** | NASHP | Hospital Cost Tool data. |
| **Medical Debt** | Urban Institute | Medical debt over time. |
| **Macro Policy** | FRED / BEA | State Unemployment and Personal Income. |

# Development & Usage

- **Environment:** The project is set up for an R environment.
- **Data Acquisition:** Run the scripts in `Code/` to fetch the latest data. The scripts typically define a base URL and a list of specific filenames to download into the `Data/` directory.
- **Workflow:**
    1.  **Data Acquisition:** Run `Code/download_*.R` scripts to populate local raw data folders.
    2.  **Consolidation:** Run `Code/create_state_master.R` to merge datasets and adjust for inflation.
    3.  **Feature Engineering:** Run `Code/analysis_pre_processing.R` to generate climate shocks (bins) and lags.
    4.  **Analysis:** Run `Code/run_analysis.R` to execute the Fixed-Effects models.
    5.  **Review:** Examine the statistical results in `Analysis/` and the research abstract in `Text/`.

ANY planning document must go into the `Plans/' folder.