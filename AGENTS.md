# Repository Guidelines

## Session Start Protocol
At the start of each new session:
1. Read `conductor/tracks.md` to identify active track(s).
2. Read each active track `plan.md` (for example, `conductor/tracks/county_analysis_refinement_20260216/plan.md`).
3. Identify the next uncompleted task (first `[ ]` item) and state it clearly.
4. Confirm whether to continue that task or switch.

## Project Overview
This is a research project (likely a thesis) focused on aggregating and analyzing United States health, climate, and economic data using R. The primary goal is constructing a multi-dimensional dataset spanning several years (mostly ~2011-2026) to investigate relationships between environmental factors (climate, AQI), health costs (HIX premiums, hospital costs, medical debt), and policy.

**Status Update (Mar 2026):**
- State-level analysis completed: evidence that extreme drought (2-year lag) and cold shocks (1-year lag) increase medical debt and insurance premiums.
- County-level analysis phase 1 completed: 1990-2000 z-score anchoring, socioeconomic integration (BEA PCPI + ACS median household income + ACS civilian employed), and descriptive statistics/plots.
- County-level phase 2 (event study and econometric modeling) is next.

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
- `download_county_socioeconomic.R`: Downloads county socioeconomic source files.
- `process_county_socioeconomic.R`: Builds county socioeconomic intermediates.
- `run_descriptive_stats.R`: Generates county descriptive summaries and plots.

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
- `intermediate_socioeconomic.rds`: County socioeconomic intermediate output.

### `Analysis/`
Stores analysis outputs.
- `regression_results_summary.csv`: Coefficients, standard errors, and p-values for primary models.
- `state_analysis_summary.md`: State-level regression workflow and findings.
- `econometric_review.md`: Review of econometric specifications.
- `descriptive_stats_summary.csv`: County descriptive summary statistics.
- `descriptive_stats_report.md`: County descriptive findings write-up.
- `plots/`: County descriptive plots and trend visuals.

### `Text/`
Documentation and research proposals.
- `v2_Akhtar_Proposal.pdf`: Thesis or research proposal.
- `state_analysis_plan.md`: Plan for binned climate shock analysis and distributed lag modeling.
- `county_level_analysis_plan.md`: Plan for county-level analysis.
- `abstract_draft.md` / `abstract_draft.html`: Research abstract summarizing methodology and findings.

### `conductor/`
Conductor workflow state and execution plans.
- `workflow.md`: Required task lifecycle and verification protocol.
- `tracks.md`: Active track registry.
- `tracks/county_analysis_refinement_20260216/`: Current county-analysis track.

### `Plans/`
All planning documents must go here.

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
5. County socioeconomic pipeline: run `Code/download_county_socioeconomic.R` then `Code/process_county_socioeconomic.R` to update `Data/intermediate_socioeconomic.rds`.
6. County descriptive outputs: run `Code/run_descriptive_stats.R` to regenerate descriptive outputs in `Analysis/`.
7. Review: examine outputs in `Analysis/` and the abstract in `Text/`.

Any planning document must go into the `Plans/` folder.

## Build, Test, and Development Commands
This repo is data-first; there is no build step. Run scripts directly with R:
- `Rscript Code/download_climate_data.R`: downloads NOAA climate division files into `Data/Climate_Data/`.
- `Rscript Code/download_meps_data.R`: downloads MEPS IC Excel files and writes outputs to `Data/MEPS_Data_IC/`.
- `Rscript Code/download_state_policy_data.R`: pulls FRED series and policy tables into `Data/State_Policy_Data/`.
- `Code/download_hix_data.R` is currently disabled and documents the manual HIX access process.

## Conductor Workflow
All work follows conductor protocol in `conductor/workflow.md`.
- Active track: `conductor/tracks/county_analysis_refinement_20260216/`
- Source-of-truth checklist: `conductor/tracks/county_analysis_refinement_20260216/plan.md`
- Track registry: `conductor/tracks.md`

Task status markers:
- `[ ]`: Not started
- `[~]`: In progress
- `[x]`: Complete (append 7-char commit SHA)

Always update `plan.md` before and after each task as required by `workflow.md`.

## Coding Style & Naming Conventions
- Language: R. Use 2-space indentation, a space after commas, and `<-` for assignment (as in existing scripts).
- Filenames: `snake_case` with a `download_` prefix for ingestion scripts.
- Data outputs: write to `Data/<Source>_Data/` with descriptive filenames; avoid overwriting raw files unless explicitly intended.

## Testing Guidelines
Use lightweight sanity checks for analysis scripts (for example, `stopifnot(nrow(df) > 0)`) and document them in script headers.
When adding test-covered code, use `testthat` and target >80% coverage for new components.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and lowercase (examples: `add aqi`, `clean up download scripts and reorganize climate data`).
- Keep commits scoped to one dataset or script at a time.
- For PRs, include: a brief summary, a list of datasets touched, and any manual steps required to reproduce downloads.

## Session End Protocol
When ending a session:
1. Update `changelog.md` with a dated entry summarizing all file changes, bug fixes, and data/method decisions.
2. Update `GEMINI.md` for any changes in project status, directory structure, pipeline order/dependencies, or data sources.
3. Update `CLAUDE.md` for any changes in active track/task state, conventions, key paths, or project-specific lessons learned.
4. Commit `changelog.md`, `GEMINI.md`, and `CLAUDE.md` (only if modified) with:
   `conductor(session): Log session changes and update project docs`
5. Clear `.claude/session_edits.log`.

## Data & Security Notes
- Many files are large. Prefer downloading via scripts rather than committing fresh raw files unless they are small or critical for reproducibility.
- When updating source URLs, also update `Data/data sources.txt` and note the access date in the commit or PR description.

## Project-Specific Notes
- This is an R-first research codebase; no frontend/deployment concerns.
- Keep MEPS paths consistent with `Data/MEPS_Data_IC/`.
- Use `fixest::feols` for state and county regressions (not `plm` or `sandwich` for primary FE specs).
- `process_aqi_data.R` depends on county AQI and population intermediates (`intermediate_aqi.rds`, `intermediate_pop.rds`), so run county preprocessors first.
- State and county climate pipelines load from 1990 onward to preserve the 1990-2000 baseline for z-score anchoring.
- In county climate processing, `Z_Temp` and `Z_Precip` are anchored to county-specific 1990-2000 means/sd and applied to the full period.
- `Is_Extreme_Drought` (PDSI <= -4) and lags are computed in `process_county_climate.R`.
- County socioeconomic pipeline:
  `download_county_socioeconomic.R` -> `process_county_socioeconomic.R` -> `Data/intermediate_socioeconomic.rds`
- ACS variable IDs require estimate suffixes (for example, `B19013_001E`, `B23025_004E`).
- BEA county employment series `CAEMP25N` is not available through the Regional API; use ACS `B23025_004E` proxy.
- Hospital bad debt/charity comes through `process_zip_county_map.R`; one negative charity outlier should be winsorized before regression.
- Current county master reference shape: 41,376 rows, 3,155 counties, 2011-2023, 53 columns.
- AQI variables are continuous (median AQI weighted, max AQI, pollutant-day percentages), not z-scored binary quintiles.
- When using NOAA named-vector mappings in R, check for duplicate keys (R silently takes first match).
- `process_zip_county_map.R` is canonical for county debt/cost processing; `process_medical_debt_county.R` is archived.
- Medical debt reporting-rule exclusions (Urban Institute county panel, August snapshots): CO HB23-1126 effective Aug 7 2023 → exclude CO 2023 only. NY Fair Medical Debt Reporting Act effective Dec 13 2023 → no exclusion needed (postdates Aug 2023 snapshot). MN Debt Fairness Act effective Oct 1 2024 → no exclusion needed (outside panel window). Implemented via `debt_reporting_policy` data frame (CO, 2023–2023) in both `run_descriptive_stats.R` and `run_county_analysis.R`. National CRA changes (2022–2023) affect all states equally — no state-specific exclusion warranted.
- State PDSI outputs: `process_state_climate.R` produces both `pdsi_mean` (annual mean) and `pdsi_min` (annual minimum = worst drought month). `analysis_pre_processing.R` derives `is_extreme_drought` from `pdsi_mean < -4` and `is_extreme_drought_peak` from `pdsi_min < -4`. Both get lag1/lag2 and enter `run_analysis.R`.
- County drought multicollinearity: primary specs in `run_county_analysis.R` use `drought_vars_primary` (pdsi_val + Lag1/Lag2 only). Full PDSI/PHDI/PMDI block retained as `drought_vars_robust_full` for robustness. VIF diagnostics not yet added to county script.
- State AQI weighting: `process_aqi_data.R` uses strict pop weights for `AQI_Median_Wtd` — counties missing population are excluded (no `Pop_Wt=1` fallback). Equal-weight `AQI_Median_EW` series computed as robustness. Diagnostics at `Analysis/state_aqi_weight_diagnostics.csv`.
- Rating area structure in premium models: counties in the same rating area share identical premiums by construction. Primary models cluster at state level (nests rating areas). For `Benchmark_Silver_Real` and `Lowest_Bronze_Real`, `run_county_analysis.R` additionally produces rating-area-clustered SE variants (`*_RA_Cluster`). A separate RA-aggregation robustness block also exists. Median rating area = 4 counties; 33.5% are 1-to-1.
