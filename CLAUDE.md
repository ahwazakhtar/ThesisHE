# Claude Code Instructions

## Session Start Protocol

At the start of every conversation, before doing anything else:

1. Read `conductor/tracks.md` to identify the active track(s).
2. For each active track, read its `plan.md` (e.g., `conductor/tracks/county_analysis_refinement_20260216/plan.md`).
3. Identify the next uncompleted task (first `[ ]` item) and state it clearly to the user.
4. Ask the user if they want to continue with that task or switch to something else.

---

## Project Overview

This is an academic econometrics thesis investigating relationships between environmental factors (climate shocks, AQI), health costs (HIX premiums, hospital costs, medical debt), and macroeconomic policy across the United States (~2011–2026). The project is entirely R-based.

**Current status (Feb 2026):**
- **State-level analysis:** Complete. Key finding: Extreme Drought (2-year lag) and Cold Shocks (1-year lag) increase Medical Debt and Insurance Premiums.
- **County-level analysis:** In progress — active track `county_analysis_refinement_20260216`.

---

## Directory Structure

| Path | Purpose |
|------|---------|
| `Code/` | R scripts for data acquisition, processing, and analysis |
| `Code/download_*.R` | Acquisition scripts (climate, HIX, MEPS, policy) |
| `Code/create_state_master.R` | Consolidates state-level panel |
| `Code/analysis_pre_processing.R` | Feature engineering for state-level analysis |
| `Code/run_analysis.R` | State-level Fixed-Effects models (`fixest`) |
| `Code/process_zip_county_map.R` | Maps Zip-level data to counties via crosswalk |
| `Code/process_rating_area_map.R` | Maps HIX premiums from Rating Areas to Counties |
| `Code/create_county_master.R` | Builds county-level master panel, Z-scores, CDD/HDD bins |
| `Code/run_county_analysis.R` | County-level FE models with state-level clustering |
| `Data/` | Raw and processed datasets |
| `Data/AQIdata/` | Annual AQI by county (EPA) |
| `Data/Climate_Data/County level/` | Temp, precip, HDD, CDD at county level |
| `Data/Climate_Data/State level/` | State climate + drought indices (PDSI, PHDI, PMDI, ZNDX) |
| `Data/County Population/` | SEER county population estimates (1969–2023) |
| `Data/Zip County Crosswalk/` | Master Zip-to-County crosswalk (2010–2023) |
| `Data/HIX_Data/` | Health Insurance Exchange premiums and plan details |
| `Data/Hosp_Data/` | Hospital Cost Tool data (NASHP) |
| `Data/MedicalDebt/` | County medical debt trends (Urban Institute) |
| `Data/MEPS_Data_IC/` | MEPS Insurance Component data |
| `Data/State_Policy_Data/` | Unemployment, Personal Income, CPI (FRED/BEA) |
| `Data/state_level_analysis_master.csv` | Consolidated state-level panel |
| `Data/county_level_master.csv` | Consolidated county-level panel |
| `Analysis/` | Regression outputs, tables, reports |
| `Analysis/regression_results_summary.csv` | Coefficients, SEs, p-values for primary models |
| `Analysis/state_analysis_summary.md` | State-level regression workflow and findings |
| `Analysis/econometric_review.md` | Expert review of econometric specifications |
| `Text/` | Documentation, proposals, abstracts |
| `Plans/` | All planning documents must go here |

---

## Data Sources

| Domain | Source | Key Variables |
|--------|--------|--------------|
| Climate | NOAA (NCEI) | Temp, Precip, CDD, HDD, PDSI, PHDI, PMDI, ZNDX |
| Air Quality | EPA | Annual AQI by county |
| Inflation | FRED | CPI (CPIAUCNS) for real dollar conversion |
| HIX Premiums | HIX Compare | Individual market premiums and plan details |
| Health Spending | CMS (NHE) | Per capita spending by state (PHI, Medicare, Medicaid) |
| Employer Insurance | AHRQ (MEPS-IC) | Employee contributions and deductibles |
| Hospital Costs | NASHP | Hospital Cost Tool |
| Medical Debt | Urban Institute | County-level medical debt over time |
| Macro Policy | FRED / BEA | State unemployment and personal income |

---

## Script Run Order

1. `Code/download_*.R` — populate raw data
2. `Code/create_state_master.R` — merge and inflation-adjust
3. `Code/analysis_pre_processing.R` — generate climate shock bins and lags
4. `Code/run_analysis.R` — state-level FE models
5. `Code/create_county_master.R` — build county panel
6. `Code/run_county_analysis.R` — county-level FE models

---

## Conductor System

All work is governed by the conductor workflow. Follow `conductor/workflow.md` strictly for task lifecycle (status markers, commits, git notes, phase checkpoints).

- **Active track:** `conductor/tracks/county_analysis_refinement_20260216/`
  - Spec: `conductor/tracks/county_analysis_refinement_20260216/spec.md`
  - Plan: `conductor/tracks/county_analysis_refinement_20260216/plan.md`
- **Track registry:** `conductor/tracks.md`

### Task Status Conventions

| Marker | Meaning |
|--------|---------|
| `[ ]` | Not started |
| `[~]` | In progress |
| `[x]` | Complete (append 7-char commit SHA) |

`plan.md` is the source of truth. Always update it before and after each task per `workflow.md`.

---

## Session End Protocol

When the user signals the session is ending (e.g., "wrap up", "we're done", "end session"), execute the following steps **in order** before closing:

### 1. Update `changelog.md`

Append a new dated entry (format: `## YYYY-MM-DD`) documenting every file changed this session. For each file, record:
- What was changed and why
- Any bugs found or fixed
- Any data/methodological decisions made

Use the existing entries in `changelog.md` as the style template.

### 2. Update `GEMINI.md`

Review the full session and update `GEMINI.md` if any of the following changed:
- Project status (e.g., a task or phase completed)
- Directory structure (new files/folders created)
- Script run order or pipeline dependencies
- Data sources added or removed

Only update sections that actually changed. Do not rewrite unchanged content.

### 3. Update `CLAUDE.md`

Update this file if any of the following changed:
- Active track or task checklist state
- New project-specific conventions discovered
- Directory structure or key file paths
- Lessons learned that should inform future sessions (add to Project-Specific Notes)

### 4. Commit session logs

Stage and commit `changelog.md`, `GEMINI.md`, and `CLAUDE.md` (only if modified) with the message:
```
conductor(session): Log session changes and update project docs
```

### 5. Clear the session edit log

Delete `.claude/session_edits.log` so the next session starts fresh:
```bash
rm -f .claude/session_edits.log
```

---

## Project-Specific Notes

- R-based project — no frontend, no deployment pipeline, no mobile testing. Disregard those sections of `workflow.md`.
- Tests use `testthat`. Coverage target >80% for new code.
- All planning documents go in `Plans/`.
- MEPS data lives in `Data/MEPS_Data_IC/` — use this path consistently across all scripts.
- Both state and county regressions use `fixest::feols`. Do not use `plm` or `sandwich`.
- `process_aqi_data.R` (state AQI) depends on county AQI intermediate (`intermediate_aqi.rds`) and population intermediate (`intermediate_pop.rds`). Always run `process_county_aqi.R` and `process_county_population.R` first.
- Both state and county climate data load from 1990 to cover the 1990–2000 pre-study baseline for Z-score anchoring. County climate previously filtered at 1996 — corrected to 1990.
- Z_Temp and Z_Precip in `process_county_climate.R` are anchored to per-county means/SDs computed over 1990–2000 only. The baseline stats are joined in before the mutate and dropped from the output RDS.
- `Is_Extreme_Drought` (PDSI ≤ −4) is computed in `process_county_climate.R` with Lag1/Lag2. Do not look for it in `create_county_master.R`.
- County socioeconomic pipeline: `download_county_socioeconomic.R` → `process_county_socioeconomic.R` → `Data/intermediate_socioeconomic.rds`. Outputs: `PCPI_Real` (BEA CAINC1), `Med_HH_Income_Real` (ACS B19013_001E), `Civilian_Employed` (ACS B23025_004E). ACS covers 2011–2023; BEA covers 1990–2023. API keys in `~/.Renviron` (BEA_API_KEY, CENSUS_API_KEY).
- ACS variable names require the `E` suffix (estimate): `B19013_001E`, `B23025_004E`. Plain `B19013_001` returns a 400 error.
- BEA CAEMP25N county employment is NOT available via the Regional API. Use ACS B23025_004E as proxy.
- Hospital bad debt/charity data: sourced from NASHP HCT Excel file via `process_zip_county_map.R`. ~23% missing (counties with no hospital reports). One negative Hosp_Charity_Total value (−$408M) — winsorize before regression.
- County master (`county_level_master.csv`): 53 columns, 41,376 rows, 3,155 counties, 2011–2023.
- AQI variables are continuous measures (Median AQI population-weighted, Max AQI, pollutant day percentages). No z-score or binary quintile transformation — AQI uses hard EPA thresholds. `High_AQI_Max` (Max AQI > 100) is constructed in `run_event_study.R` as a binary shock indicator (10,949 events, ~9.2%). Median AQI > 100 was rejected (only 6 obs).
- Event study design: `run_event_study.R` implements dynamic panel impulse-response models (not canonical staggered-adoption). Treatment is recurring — counties enter/exit shock status. 5 individual shocks (`Is_Extreme_Drought`, `High_CDD`, `High_HDD`, `High_AQI_Max`, `Any_Shock`) + compound specs. `synthesize_event_study.R` produces summary narrative and plots.
- `create_county_master.R` pulls `Median_AQI` and `Max_AQI` from intermediate; uses `any_of()` for backward-compatible `AQI_Shock` columns.
- When inspecting NOAA named-vector key mappings, always check for duplicate keys — R silently returns the first match, making later entries dead code.
- `process_zip_county_map.R` is the sole canonical county debt/cost processor. `process_medical_debt_county.R` is archived.
- Medical debt reporting-rule exclusions: The Urban Institute county panel uses August credit bureau snapshots. CO HB23-1126 effective Aug 7 2023 — CO 2023 only is excluded. NY Fair Medical Debt Reporting Act effective Dec 13 2023 — falls after the Aug 2023 snapshot, NO exclusion needed. MN Debt Fairness Act effective Oct 1 2024 — outside panel window, NO exclusion needed. Both `run_descriptive_stats.R` and `run_county_analysis.R` implement this via a `debt_reporting_policy` table (CO, 2023–2023 only). The 2022–2023 national CRA voluntary changes affect all states equally — no state-specific exclusions warranted.
- `process_state_climate.R` outputs both `pdsi_mean` (annual mean) and `pdsi_min` (annual minimum = worst drought month). `analysis_pre_processing.R` derives `pdsi_level` from `pdsi_mean` and `is_extreme_drought_peak` from `pdsi_min < -4`. Both are lagged and included in `run_analysis.R` regressions. `pdsi_min` captures transient within-year drought peaks that the mean smooths over.
- County drought block multicollinearity: `run_county_analysis.R` primary specs use PDSI only (`drought_vars_primary`: pdsi_val + Lag1/Lag2) to avoid VIF inflation from near-collinear PDSI/PHDI/PMDI. Full 9-variable block retained as `drought_vars_robust_full` for optional robustness specs. VIF computed via auxiliary OLS on within-transformed predictor matrix; logged to `Analysis/county_vif_diagnostics.txt`. Post-pruning VIFs confirmed acceptable (max ~5.33).
- State AQI aggregation: `process_aqi_data.R` uses strict population weights — counties with missing population are dropped from `AQI_Median_Wtd` (no `Pop_Wt=1` fallback). Equal-weight robustness series `AQI_Median_EW` computed alongside. Diagnostics written to `Analysis/state_aqi_weight_diagnostics.csv`.
- Rating area structure in premium models: counties sharing a rating area have identical premiums by construction. Primary models cluster at state level (which nests rating areas). For premium outcomes (`Benchmark_Silver_Real`, `Lowest_Bronze_Real`), `run_county_analysis.R` also produces rating-area-clustered SE variants (`*_RA_Cluster`). The existing rating-area aggregation robustness block (lines 153–243) remains as a separate robustness check. Median rating area has 4 counties; 33.5% are 1-to-1.
