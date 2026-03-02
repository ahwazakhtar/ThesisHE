# Changelog

---

## 2026-03-02 (Session 2)

### `Code/process_county_climate.R`

**Z-score baseline anchored to 1990–2000 (was full-sample mean/SD)**
- Year filter changed from `>= 1996` to `>= 1990` to load the baseline window.
- Per-county baseline means/SDs computed via a separate `summarize()` on `Year 1990–2000`, joined in, then dropped from the output RDS.
- `Is_Extreme_Drought`, `Is_Extreme_Drought_Lag1`, `Is_Extreme_Drought_Lag2` added (PDSI ≤ −4 threshold). These were present in an older intermediate but absent from the current script; now restored.
- Climate intermediate regenerated: 53 columns including pdsi_val, phdi_val, pmdi_val and all lags.

---

### `Code/tests/test_process_county_climate.R`

**3 new Z-score baseline tests added**
- Verifies baseline years use 1990–2000 mean/SD (not full-sample).
- Verifies post-baseline Z-scores differ from full-sample normalization when temps diverge.
- Verifies each county gets its own independent baseline.
- All 8 tests pass.

---

### `Code/download_county_socioeconomic.R` (new)

**Downloads county-level income and employment data**
- BEA CAINC1 (LineCode 3): per capita personal income, all counties, all years via BEA Regional API.
- Census ACS 5-year: median HH income (B19013_001E) + civilian employed count (B23025_004E), 2011–2023.
- Note: BEA CAEMP25N county employment not available via Regional API; ACS B23025_004E used as proxy.
- API keys stored in `~/.Renviron` (BEA_API_KEY, CENSUS_API_KEY) — not committed.

---

### `Code/process_county_socioeconomic.R` (new)

**Processes BEA + ACS downloads into `Data/intermediate_socioeconomic.rds`**
- Filters BEA to CPI-covered years via inner join (drops pre-1990 and post-2023 rows; eliminates ~37% NA rate).
- Drops US/state aggregate FIPS (00000, *000).
- ACS suppressed values (−666666666) set to NA.
- Left-joins ACS on BEA spine so pre-2009 BEA rows are retained with NA ACS columns.
- Output columns: `fips_code`, `Year`, `PCPI_Real`, `Med_HH_Income_Real`, `Civilian_Employed` (all 2023 dollars).
- Guard option (`socioeconomic.test_mode`) prevents auto-run when sourced by tests.

---

### `Code/tests/test_process_county_socioeconomic.R` (new)

**16 passing tests covering the full processing pipeline**
- FIPS validation (rejects US/state aggregates, malformed codes).
- CPI inflation adjustment correctness.
- Zero PCPI_Real NAs after inner CPI join.
- ACS suppression (−666666666) → NA.
- ACS-absent years retain BEA row with NA ACS columns (left join verified).
- Output RDS path correctness.

---

### `Code/create_county_master.R`

**Joined socioeconomic intermediate + fixed hospital data path**
- Added `path_socio_rds` and load of `intermediate_socioeconomic.rds`.
- Added join section for `PCPI_Real`, `Med_HH_Income_Real`, `Civilian_Employed`.
- Rebuilt master now has 53 columns (up from 41) and 41,376 rows.
- Hospital bad debt/charity/revenue now included (NASHP was silently skipped on prior runs due to stale `medical_debt_county.csv`).

---

### `Code/process_zip_county_map.R`

**Re-run to populate hospital columns (no code change)**
- Previous output was missing Hosp_BadDebt_Total, Hosp_Charity_Total, Hosp_Revenue_Total because the script had been run before NASHP crosswalk was in place.
- Re-running produced 31,437 hospital county-year rows (23.1% NA in master — counties with no hospital reports).
- Discovered negative Hosp_Charity_Total min (−$408M): one county-year has a correction/reversal; noted in descriptive report for winsorization before regression.

---

### `Code/run_descriptive_stats.R` (new)

**Summary statistics and time-series visualizations**
- Summary stats CSV (`Analysis/descriptive_stats_summary.csv`): N, mean, SD, min, P25, median, P75, max, NA% for 18 key variables.
- Three ggplot2 time-series plots saved to `Analysis/plots/`:
  - `ts_climate_shocks.png`: % counties with extreme heat, cold, drought per year.
  - `ts_outcomes.png`: Medical debt share, uninsured rate, silver premium trends.
  - `ts_income.png`: BEA per capita income and ACS median HH income trends.
- Key finding: temperature Z-score mean of +0.89 vs 1990–2000 baseline confirms systematic county-level warming during 2011–2023.

---

### `Analysis/descriptive_stats_report.md` (new)

**Written summary of descriptive findings**
- Panel overview, per-variable stats, trend narratives for climate, health, and income sections.
- Data quality notes flagging AQI sparse coverage, hospital missing data, and the negative charity care outlier.

---

### `conductor/tracks/county_analysis_refinement_20260216/plan.md`

**Phase 1 complete — all three substantive tasks marked `[x]`**
- Z-score baseline task: corrected script reference (was `create_county_master.R`, is `process_county_climate.R`).
- Socioeconomic task: noted BEA CAEMP25N unavailability via API; ACS employed count substituted.
- Descriptive stats task: noted pipeline fixes discovered during this task.

---

## 2026-03-02 (Session 1)

### `Analysis/script_inconsistencies_report.md` (pre-existing, read-only)

**Audited — all 15 inconsistencies verified against live scripts**
- Confirmed which issues were already fixed, which were newly discovered (state NOAA threshold, broken DC key, rating area join), and which remained open.
- Three items added to `plan.md` that were absent: state NOAA blanket threshold, `AREA_Clean` unused in rating area join, broken DC duplicate key.

---

### `Code/process_state_climate.R`

**Fixed NOAA missing-value threshold (was blanket `<= -9.9` for all variables)**
- Temperature now uses `<= -99.90`, CDD/HDD use `<= -9999`, PDSI uses `<= -99.99`, precip stays at `<= -9.99`.
- Blanket threshold was silently flagging legitimate cold temperatures (e.g. Alaska/Montana January means) and extreme drought PDSI values as missing.

**Temperature aggregation changed from sum to mean**
- Annual temperature was being summed across 12 months, producing values ~12× larger than the county pipeline's annual mean. Output column renamed from `temp_sum` to `temp_mean`.
- CDD, HDD, precip, and PDSI remain as sums — those are cumulative quantities.

**Year filter extended from 1996 to 1990**
- Required to cover the 1990–2000 pre-study baseline window used for temperature z-score anchoring in `analysis_pre_processing.R`.

---

### `Code/process_rating_area_map.R`

**Fixed silent all-NA premium join for older plan file formats**
- `AREA_Clean` (which stripped the "Rating Area N" prefix) was being computed but discarded; `rating_area_id` was set to the raw `AREA` string.
- Fix: detect `"^Rating Area "` format and build `"ST##"` from `ST` column + zero-padded number; otherwise keep the existing `"ST##"` value. Join now uses the normalised `rating_area_id` on both sides.
- Stale comment block removed.

---

### `Code/archive/download_meps_data.R`

**Paths updated to `Data/MEPS_Data_IC/`**
- Script was the source of the MEPS directory split (wrote to `Data/MEPS_Data/`). It has been archived; paths corrected so it can be safely revived without re-introducing the split.

---

### `Code/process_medical_debt_county.R`

**Archived — moved to `Code/archive/`**
- Was an orphaned script producing a simpler Urban Institute-only table at the same output path as `process_zip_county_map.R`. Whichever ran last would silently overwrite the other's output.
- `process_zip_county_map.R` is now the sole canonical county debt/cost processor.

---

### `Code/run_county_analysis.R`

**`Unemployment_Rate` removed from controls**
- No county-level unemployment series has been sourced. Leaving it in `controls` caused `intersect()` to silently drop it from every regression with no warning.
- Comment added documenting the omission and pointing to BLS LAUS integration planned in Phase 1.

---

### `Code/process_county_aqi.R`

**Full rewrite — expanded AQI measures, dropped z-score shock**
- Now outputs per FIPS-year: `Median_AQI`, `Max_AQI`, `Days_AQI` (denominator), `Days_CO/NO2/Ozone/PM25/PM10`, `Days_Unhealthy` (Unhealthy + Very Unhealthy + Hazardous), and percentage equivalents (`Pct_*`).
- Distributed lags (Lag1, Lag2) generated for all key measures at processing time.
- `AQI_Shock` (county-demeaned z-score) dropped: AQI has hard EPA thresholds; history coverage is incomplete, making z-scoring unreliable.
- `StateName` (full state name) retained in intermediate so state aggregation can group correctly.

---

### `Code/process_aqi_data.R`

**Full rewrite — now aggregates from county intermediate with population weights**
- Previously read raw zip files and computed an unweighted county mean. Now depends on `intermediate_aqi.rds` (from `process_county_aqi.R`) and `intermediate_pop.rds` (from `process_county_population.R`).
- State-level measures: population-weighted mean of `Median_AQI` (`AQI_Median_Wtd`), state-max of `Max_AQI` (`AQI_Max_State`), and summed pollutant day totals with state-level percentage equivalents.
- Pipeline dependency: `process_county_aqi.R` must run before `process_aqi_data.R`.

---

### `Code/analysis_pre_processing.R`

**Temperature z-score anchored to 1990–2000 pre-study baseline**
- Previously computed z-scores against the full sample mean (look-ahead bias). Now uses only `Year >= 1990 & Year <= 2000` for `temp_hist_mean` and `temp_hist_sd`.
- Intermediate variable names changed from `temp_mean`/`temp_sd` to `temp_hist_mean`/`temp_hist_sd` to avoid a naming collision with the incoming `temp_mean` column from `process_state_climate.R`.

**`is_high_aqi` binary quintile removed; replaced with continuous AQI state variables**
- `is_high_aqi`, `aqi_80th`, and all references to `aqi_mean` removed.
- `vars_to_lag` updated to include the new state AQI measures (`AQI_Median_Wtd`, `AQI_Max_State`, `Pct_PM25_State`, etc.) if present.

---

### `Code/run_analysis.R`

**Migrated from `plm` + `sandwich` to `fixest`**
- `plm()` + `vcovHC()` + `coeftest()` replaced with `feols(dep ~ vars | State + Year, cluster = ~State)`.
- Result extraction updated: `coeftable(fem)` for coefficients, `r2(fem, "wr2")` for within-R².
- Separate plain formula retained for the VIF pooled-OLS check (which cannot use the `|` FE syntax).
- AQI predictor block updated to use new continuous state AQI variables with their lags.

---

### `Code/process_county_climate.R`

**Removed broken DC duplicate key from `noaa_state_codes`**
- A previous fix appended `"11" = "District of Columbia"` after `"11" = "Illinois"`. In R, named-vector lookup returns the first match, so the DC entry was dead code.
- Replaced with a comment explaining DC is absent from NOAA county-level climate divisional files.

---

### `conductor/tracks/county_analysis_refinement_20260216/plan.md`

**Phase 0 fully complete**
- All six "Fix Critical Pipeline Inconsistencies" subtasks marked `[x]`.
- All four "Align State and County Methodologies" subtasks marked `[x]`.
- Three new subtasks added and resolved: state NOAA threshold, rating area join, broken DC key.

---

## 2026-02-25

### `CLAUDE.md`

**Created — session start/end protocol and full project context**
- New file providing Claude Code with automatic session orientation: reads active track's `plan.md` at session start and identifies the next uncompleted task.
- Includes full directory structure table, data sources table, script run order, and conductor system conventions — merged from `GEMINI.md` so Claude has all context in one load.
- Session End Protocol added: triggers on "wrap up" / "we're done" and instructs Claude to update `changelog.md`, `GEMINI.md`, and `CLAUDE.md` before committing, then clear the session edit log.
- Project-specific notes: R-only project, `testthat` for testing, all planning docs go in `Plans/`, MEPS data path is `Data/MEPS_Data_IC/`.

---

### `.claude/settings.json`

**Created — project-level Claude Code hooks configuration**
- `PostToolUse` hook on `Edit|Write`: fires `.claude/hooks/track_edits.py` after every file edit to silently log changed paths to `.claude/session_edits.log`.
- `UserPromptSubmit` hook: fires `.claude/hooks/detect_wrapup.py` on every prompt to detect session-end keywords and automatically inject the edit log + `git diff --stat` into Claude's context.

---

### `.claude/hooks/track_edits.py`

**Created — automatic file change logger**
- Reads `PostToolUse` JSON payload from stdin, extracts `file_path`, appends `HH:MM:SS  <path>` to `.claude/session_edits.log`.

---

### `.claude/hooks/detect_wrapup.py`

**Created — session-end keyword detector**
- Reads `UserPromptSubmit` payload, checks for wrap-up keywords (wrap up, end session, we're done, finish up, done for today, etc.).
- On match: reads `.claude/session_edits.log` and runs `git diff HEAD --stat`, prints both to stdout so they are injected into Claude's context before the Session End Protocol runs.

---

### `.gitignore`

**Added `.claude/session_edits.log` exclusion**
- Temp session log is ephemeral and should not be committed.

---

## 2026-02-19

### `Code/process_county_climate.R`

**Added DC to NOAA state code mapping**
- Added `"11" = "District of Columbia"` to `noaa_state_codes`. DC was previously absent, causing all DC county climate records to be silently dropped at the `filter(!is.na(StateFIPS))` step.

**Added PDSI/PHDI/PMDI county-level drought index support**
- Added `pdsi`, `phdi`, `pmdi` to the file list (county-level NOAA drought index files).
- Missing-value threshold for these variables set to `<= -99.99` (correct NOAA sentinel for drought indices).
- Annual aggregation uses `mean()` for all three indices, consistent with their nature as indices rather than cumulative counts.
- Removed `Z_PDSI` z-score computation. PDSI, PHDI, and PMDI are already standardized indices (roughly −4 to +4) and do not require further normalization.
- Added distributed lags (1 and 2 years) for all three indices, computed directly from their `_val` columns:
  - `PDSI_Lag1`, `PDSI_Lag2` from `pdsi_val`
  - `PHDI_Lag1`, `PHDI_Lag2` from `phdi_val`
  - `PMDI_Lag1`, `PMDI_Lag2` from `pmdi_val`

---

### `Code/run_county_analysis.R`

**Replaced state-level drought variables with county-level drought indices in model specs**
- `vars_spec1_base` and `vars_spec2_base` previously included state-level approximations (`pdsi_sum`, `Drought_Lag1`, `Drought_Lag2`, `Is_Extreme_Drought`, `Is_Extreme_Drought_Lag1`). These are now replaced with county-level `pdsi_val`, `phdi_val`, `pmdi_val` and their precomputed lags (`PDSI_Lag1/2`, `PHDI_Lag1/2`, `PMDI_Lag1/2`).

**Updated rating area robustness aggregation block**
- Added `pdsi_val`, `phdi_val`, `pmdi_val` to `cols_to_agg` so they are population-weighted when counties are collapsed to rating areas.
- Removed the stale "State-level vars are constant within RA-Year" block, which carried forward the now-removed state-level drought variables (`pdsi_sum`, `Drought_Lag1/2`, `Is_Extreme_Drought`, `Is_Extreme_Drought_Lag1`).
- Added drought lag recalculation in the post-aggregation `mutate` block: `PDSI_Lag1/2`, `PHDI_Lag1/2`, `PMDI_Lag1/2`.

---

### `Code/create_county_master.R`

**Removed state-level climate data pipeline**

The county master previously loaded `state_climate_consolidated.csv` to derive state-level drought controls. With county-level PDSI/PHDI/PMDI now available from `intermediate_climate.rds`, this is redundant. Removed:

- `path_state_climate` path definition
- `df_state_climate <- read.csv(path_state_climate, ...)` load call
- `state_name_to_abbr` lookup table (51-entry named vector mapping state full names to abbreviations, used only for the state climate join)
- State drought processing block: `Drought_Lag1`, `Drought_Lag2`, `Is_Extreme_Drought`, `Is_Extreme_Drought_Lag1`, `Is_Extreme_Drought_Lag2`
- `left_join(df_state_climate, by = c("State", "Year"))` from the master join chain

The master join chain is now: `df_med_debt` → `df_premiums` → `df_climate` → `df_pop` → `df_aqi`.
