# Technology Stack

## Core Language & Environment
- **R:** The primary programming language used for data acquisition, processing, and all econometric analyses.
- **RStudio:** The recommended integrated development environment (IDE) for managing the research project.

## Data Processing & Engineering
- **tidyverse (dplyr, tidyr, readr):** Used for robust data manipulation, cleaning, and preparation of the state and county panels.
- **Master Crosswalks:** Utilizing residential-ratio-based Zip-to-County and Rating-Area-to-County crosswalks for spatial data alignment.

## Econometric Modeling & Analysis
- **fixest:** Primarily used for executing high-dimensional Fixed-Effects (FE) models with clustered standard errors.
- **Feature Engineering:** Scripts for generating climate shocks (Z-scores), distributed lags (up to 2-year lags), and binned degree-day metrics (CDD/HDD).

## Visualization & Reporting
- **ggplot2:** The standard for generating high-quality, publication-ready data visualizations.
- **Stargazer/Modelsummary:** For formatting regression outputs into standardized academic tables.

## Data Storage & Management
- **Local File System:** Structured data hierarchy (`Data/`, `Code/`, `Analysis/`) using CSV and R-specific formats for efficient data persistence and retrieval.
