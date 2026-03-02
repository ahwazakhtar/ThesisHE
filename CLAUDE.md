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
- State climate data starts at 1990 (not 1996) to cover the 1990–2000 pre-study baseline for z-score anchoring.
- AQI variables are continuous measures (Median AQI population-weighted, Max AQI, pollutant day percentages). No z-score or binary quintile transformation — AQI uses hard EPA thresholds.
- When inspecting NOAA named-vector key mappings, always check for duplicate keys — R silently returns the first match, making later entries dead code.
- `process_zip_county_map.R` is the sole canonical county debt/cost processor. `process_medical_debt_county.R` is archived.
