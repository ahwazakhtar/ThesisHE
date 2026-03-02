# Code Directory

This folder contains all R scripts for data download, processing, dataset assembly, and econometric analysis.

## Unified Runner

Use the unified orchestration entrypoint to run only the phases you want:

```bash
Rscript Code/run_pipeline.R --pipeline all
```

### Common examples

```bash
# Process + merge + analysis only (no downloads), state pipeline
Rscript Code/run_pipeline.R --pipeline state --skip-download --from process --to analysis

# County processing and merge only
Rscript Code/run_pipeline.R --pipeline county --phases process,merge

# Preview what would run without executing scripts
Rscript Code/run_pipeline.R --pipeline all --skip-download --to merge --dry-run

# Print selected steps and exit
Rscript Code/run_pipeline.R --pipeline county --phases process,analysis --list-steps
```

### Supported flags

- `--pipeline state|county|all`
- `--phases download,process,merge,analysis`
- `--skip-download`
- `--from <phase>`
- `--to <phase>`
- `--strict TRUE|FALSE`
- `--list-steps`
- `--dry-run`
- `--help`

## Script Groups

### Download (State)
- `download_climate_data.R`
- `download_state_policy_data.R`
- `scrape_meps_html_base.R`

### Process (State)
- `extract_local_meps.R` (runs only when local Excel files are present)
- `process_state_climate.R`
- `process_aqi_data.R`
- `process_medical_debt.R`
- `process_cms_health_exp.R`

### Merge + Analysis (State)
- `create_state_master.R`
- `analysis_pre_processing.R`
- `run_analysis.R`

### Process (County)
- `process_county_population.R`
- `process_county_climate.R`
- `process_county_aqi.R`
- `process_zip_county_map.R`
- `process_rating_area_map.R`

### Merge + Analysis (County)
- `create_county_master.R`
- `run_county_analysis.R`

## Notes

- The runner uses fail-fast dependency checks by default (`--strict TRUE`).
- Existing scripts are still runnable directly with `Rscript Code/<script>.R`.
- `process_medical_debt_county.R` remains available for standalone use but is not in the default county pipeline because `process_zip_county_map.R` produces the richer county debt + hospital output consumed by `create_county_master.R`.
