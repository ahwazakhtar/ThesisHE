# Repository Guidelines
## Project Structure & Module Organization
- `Code/` contains R scripts that download and consolidate datasets (e.g., `download_climate_data.R`, `download_meps_data.R`).
- `Data/` stores raw and processed datasets, organized by source (e.g., `Climate_Data/`, `AQIdata/`, `HIX_Data/`, `State_Policy_Data/`).
- `Text/` holds narrative documents such as the proposal PDF.
- `GEMINI.md` summarizes sources and the intended workflow.

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
- Commit messages are short, imperative, and lowercase (examples from history: `add aqi`, `clean up download scripts and reorganize climate data`).
- Keep commits scoped to one dataset or script at a time.
- For PRs, include: a brief summary, a list of datasets touched, and any manual steps required to reproduce downloads.

## Data & Security Notes
- Many files are large. Prefer downloading via scripts rather than committing fresh raw files unless they are small or critical for reproducibility.
- When updating source URLs, also update `Data/data sources.txt` and note the access date in the commit or PR description.
