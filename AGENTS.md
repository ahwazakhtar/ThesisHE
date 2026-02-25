# Repository Guidelines

## Project Overview
This is a research project (likely a thesis) focused on aggregating and analyzing United States health, climate, and economic data using R. The primary goal is constructing a multi-dimensional dataset spanning several years (mostly ~2011-2026) to investigate relationships between environmental factors (climate, AQI), health costs (HIX premiums, hospital costs, medical debt), and policy.

**Status Update (Feb 2026):**
- State-level analysis completed: evidence that extreme drought (2-year lag) and cold shocks (1-year lag) increase medical debt and insurance premiums.
- County-level analysis in progress: scripts for zip-to-county mapping and population weighting are implemented; regional drought and local climate shocks and absolute burdens (HDD/CDD) are being modeled.

## Directory Structure

### `Code/`
Contains R scripts used to automate downloading and processing of raw data.
- `download_*.R`: Acquisition scripts for climate, HIX, MEPS, and policy data.
- `create_state_master.R`: Consolidates state-level panel.
- `analysis_pre_processing.R`: Feature engineering for state-level analysis.
- `run_analysis.R`: State-level fixed-effects models.
- `process_zip_county_map.R`: Maps zip-level hospital costs and Urban Institute medical debt to counties using crosswalks.
- `process_rating_area_map.R`: Maps HIX premiums from rating areas to counties.
- `create_county_master.R`: Consolidates county-level master dataset, processes SEER population data, and generates local climate shocks (z-scores) and binned absolute extremes (CDD/HDD).
- `run_county_analysis.R`: Executes county-level fixed-effects models with state-level clustering, including unweighted and population-weighted specifications.

### `Data/`
Core storage for raw and processed datasets.
- `AQIdata/`: Annual Air Quality Index data by county (EPA).
- `Climate_Data/`:
  - `County level/`: Temperature, precipitation, heating/cooling degree days.
  - `State level/`: Similar metrics aggregated by state, plus drought indices (PDSI, PHDI, PMDI, ZNDX).
- `County Population/`: SEER county-level population estimates (1969-2023) used for weighting and per-capita normalization.
- `Zip County Crosswalk/`: Master crosswalk for zip-to-county allocation based on residential ratios (2010-2023).
- `HIX_Data/`: Health Insurance Exchange data including:
  - `crosswalk/`: Mapping counties to rating areas.
  - `plan details/`: Detailed plan attributes and rates.
- `Hosp_Data/`: Hospital Cost Tool data (NASHP).
- `MedicalDebt/`: County-level medical debt trends (Urban Institute).
- `MEPS_Data_IC/`: Medical Expenditure Panel Survey Insurance Component data.
- `State Residence health expenditures/`: CMS National Health Expenditure (1991-2020).
- `State_Policy_Data/`: Macroeconomic indicators (unemployment, personal income, CPI).
- `data sources.txt`: Source URLs for datasets.
- `state_level_analysis_master.csv`: Consolidated state-level panel.
- `county_level_master.csv`: Consolidated county-level panel with local shocks and lags.

### `Analysis/`
Stores analysis outputs.
- `regression_results_summary.csv`: Coefficients, standard errors, and p-values for primary models.
- `state_analysis_summary.md`: State-level regression workflow and findings.
- `econometric_review.md`: Review of econometric specifications.

### `Text/`
Documentation and research proposals.
- `v2_Akhtar_Proposal.pdf`: Thesis or research proposal.
- `state_analysis_plan.md`: Plan for binned climate shock analysis and distributed lag modeling.
- `county_level_analysis_plan.md`: Plan for county-level analysis.
- `abstract_draft.md` / `abstract_draft.html`: Research abstract summarizing methodology and findings.

## Data Sources & References

| Domain | Source | Details / Key Variables |
| :--- | :--- | :--- |
| Climate | NOAA (NCEI) | Temperature, precipitation, CDD, HDD, drought indices (PDSI, PHDI, PMDI, ZNDX). |
| Air Quality | EPA | Annual AQI by county. |
| Inflation | FRED | CPIAUCNS for real-dollar conversion. |
| HIX Premiums | HIX Compare | Individual market archives (premiums, plan details). |
| Health Spending | CMS (NHE) | Per capita and per enrollee spending by state. |
| Employer Ins. | AHRQ (MEPS-IC) | Employee contributions and deductibles (state-level). |
| Hospital Costs | NASHP | Hospital Cost Tool data. |
| Medical Debt | Urban Institute | Medical debt over time. |
| Macro Policy | FRED / BEA | State unemployment and personal income. |

## Development & Usage Workflow
1. Data acquisition: run `Code/download_*.R` scripts to populate raw data folders.
2. Consolidation: run `Code/create_state_master.R` to merge datasets and adjust for inflation.
3. Feature engineering: run `Code/analysis_pre_processing.R` to generate climate shocks (bins) and lags.
4. Analysis: run `Code/run_analysis.R` to execute fixed-effects models.
5. Review: examine outputs in `Analysis/` and the abstract in `Text/`.

Any planning document must go into the `Plans/` folder.

## Build, Test, and Development Commands
This repo is data-first; there is no build step. Run scripts directly with R:
- `Rscript Code/download_climate_data.R`: downloads NOAA climate division files into `Data/Climate_Data/`.
- `Rscript Code/download_meps_data.R`: downloads MEPS IC Excel files and writes `Data/MEPS_Data/meps_ic_state_consolidated.csv`.
- `Rscript Code/download_state_policy_data.R`: pulls FRED series and policy tables into `Data/State_Policy_Data/`.
- `Code/download_hix_data.R` is currently disabled and documents the manual HIX access process.

## Coding Style & Naming Conventions
- Language: R. Use 2-space indentation, a space after commas, and `<-` for assignment (as in existing scripts).
- Filenames: `snake_case` with a `download_` prefix for ingestion scripts.
- Data outputs: write to `Data/<Source>_Data/` with descriptive filenames; avoid overwriting raw files unless explicitly intended.

## Testing Guidelines
There are no automated tests or test framework configured. If you add analysis code, include a small, runnable sanity check (e.g., `stopifnot(nrow(df) > 0)` or a lightweight summary) and document it in the script header.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and lowercase (examples: `add aqi`, `clean up download scripts and reorganize climate data`).
- Keep commits scoped to one dataset or script at a time.
- For PRs, include: a brief summary, a list of datasets touched, and any manual steps required to reproduce downloads.

## Data & Security Notes
- Many files are large. Prefer downloading via scripts rather than committing fresh raw files unless they are small or critical for reproducibility.
- When updating source URLs, also update `Data/data sources.txt` and note the access date in the commit or PR description.

## CLAUDE.md
`CLAUDE.md` is currently empty, so no additional guidance was pulled from it.
