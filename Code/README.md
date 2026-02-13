# Code Directory

This folder contains all R scripts for the acquisition, processing, and analysis of environmental and health finance data.

## Directory Structure

```text
Code/
├── shared/ (Data Acquisition)
│   ├── download_climate_data.R      # Fetches NOAA ClimDiv data
│   ├── download_meps_data.R         # Fetches MEPS-IC Excel tables
│   └── download_state_policy_data.R  # Fetches Macro (FRED) and Policy (KFF) data
│
├── state_level/ (State Pipeline)
│   ├── process_aqi_data.R           # Population-weighted AQI aggregation
│   ├── process_state_climate.R      # Consolidates state climate indices
│   ├── process_medical_debt.R       # Processes state medical debt
│   ├── process_cms_health_exp.R     # Processes CMS NHE expenditures
│   ├── scrape_meps_html_base.R      # Robust scraper for MEPS-IC tables
│   ├── extract_local_meps.R         # Extracts local MEPS Excel data
│   ├── create_state_master.R        # Merges all state components
│   ├── analysis_pre_processing.R    # Generates shocks and lags
│   └── run_analysis.R               # Runs state Fixed-Effects models
│
├── county_level/ (County Pipeline)
│   ├── process_county_aqi.R         # AQI shocks via FIPS lookup
│   ├── process_county_climate.R     # NOAA county climate parsing
│   ├── process_county_population.R  # SEER annual population processing
│   ├── process_medical_debt_county.R # Cleans county medical debt
│   ├── process_zip_county_map.R     # Maps hospital costs (NASHP) to counties
│   ├── process_rating_area_map.R    # Maps premiums (Rating Areas) to counties
│   ├── create_county_master.R       # Merges all county components
│   └── run_county_analysis.R        # Runs county Fixed-Effects models
│
└── archive/                         # Superseded and diagnostic scripts
```

## Key Workflows

### State-Level Workflow
1.  **Download:** `download_*.R`
2.  **Process:** `process_state_*.R`, `scrape_meps_html_base.R`, `extract_local_meps.R`, `process_aqi_data.R`
3.  **Merge:** `create_state_master.R`
4.  **Feature Engineering:** `analysis_pre_processing.R`
5.  **Analyze:** `run_analysis.R`

### County-Level Workflow
1.  **Download:** `download_*.R`
2.  **Process:** `process_county_*.R`, `process_zip_county_map.R`, `process_rating_area_map.R`
3.  **Merge:** `create_county_master.R`
4.  **Analyze:** `run_county_analysis.R` (Shocks and Lags are handled within this script)
