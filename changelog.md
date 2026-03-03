# Changelog

---

## 2026-03-03 (Session 4)

### `Code/run_event_study.R`

**Added combined shock diff-in-diff models**
- Constructed `Any_Shock` (OR of individual shocks), `Shock_Count`, `Compound_Shock` (count >= 2) indicators.
- `Any_Shock` runs through existing DL and LP loops automatically.
- New compound LP section: additive decomposition (`Any_Shock + Compound_Shock`) and dose-response (`Shock_Count`).
- Compound shock support is thin (~2.2%) — flagged as exploratory with diagnostics.

**Econometric remediation (E1–E8)**
- E1: Renamed from "event study" to "dynamic panel impulse-response to recurring shocks" in script header.
- E2: Added `LP_ShockHistory` robustness variant with lagged shock controls (t-1, t-2). 192 new coefficient rows + 8 comparison plots.
- E4: Fixed "additive + interaction" comment mislabel → "additive decomposition."
- E5: Added RA-clustered SE variants for compound premium LP specs.
- E6: Added compound-shock support diagnostics table and caveat framing.
- E7: Documented placebo-horizon timing choice in LP section comments.
- E8: Fixed test naming drift (`_Lag1/_Lag2` → `_Lag1_es/_Lag2_es` in Test 4).

**Added AQI shock indicator (High_AQI_Max)**
- `High_AQI_Max = 1 if Max_AQI > 100` (EPA "Unhealthy for Sensitive Groups" threshold).
- 10,949 events (~9.2% prevalence). Runs through DL, LP, LP_ShockHistory, and RA clustering.
- Combined indicators (`Any_Shock`, `Shock_Count`) now include 4 shocks.
- Median AQI > 100 rejected (only 6 obs).

**Dose-response plots redesigned**
- Replaced single-coefficient horizon plot with multi-dose visual showing predicted effects at Shock_Count = 1, 2, 3.

### `Code/synthesize_event_study.R` (new)

- Reads `event_study_coefs.csv` (1,020 rows) and produces:
  - `Analysis/event_study_synthesis.md`: narrative summary with 6 key findings.
  - `Analysis/event_study_tables.csv` and `event_study_full_results.csv`.
  - 3 synthesis plots: significance heatmap, dynamic profile panel, cross-method robustness panel.
- Covers: contemporaneous effects, dynamic profiles, pre-trend checks, DL/LP consistency, shock-history robustness, compound decomposition, population weighting sensitivity.

### `Code/create_county_master.R`

- Added `Median_AQI` and `Max_AQI` to AQI join (previously only `AQI_Shock` columns were pulled through).
- Used `any_of()` for backward-compatible column selection.

### `Code/tests/test_run_event_study.R`

- Updated Tests 6–7 for 4-shock framework (added `High_AQI_Max`).
- Test 7 now expects `Shock_Count = 4` when all shocks active.

### `Plans/event_study_econometric_issues.md`

- All 8 issues (E1–E8) marked Done or N/A.

### Key findings from synthesis

- **High_HDD → Benchmark_Silver_Real**: +$42 (p<0.01 DL, p=0.01 LP) — strongest contemporaneous effect.
- **Building effects**: `High_HDD → Medical_Debt_Share` and `Hosp_BadDebt_PerCapita` grow from h=0 to h=3.
- **Compound premium amplification**: `Compound_Shock → Benchmark_Silver_Real` +$33.6 (p=0.018).
- **Pre-trend warning**: `Is_Extreme_Drought → Benchmark_Silver_Real` fails pre-trend at h=-2.
- Shock-history robustness generally stable (same sign >75%); some instability for `High_HDD` on secondary outcomes.

---

## 2026-03-03 (Session 3, continued)

### `Code/run_analysis.R`

**Fixed broken VIF diagnostics (state-level)**
- Previous `calculate_vif()` used `model.matrix(model)[,-1]` which incorrectly stripped the first predictor (not an intercept) from the `feols` within-transformed matrix — all VIFs silently returned NA.
- Fixed to use `model.matrix()` directly without column removal, consistent with the county VIF approach.
- Removed the redundant `f_vif`/`lm` pooled path; VIF now computed on the `feols` within-transformed matrix.
- Also flagged: `is_extreme_drought_peak` (pdsi_min-based) added this session may be highly correlated with `is_extreme_drought` (pdsi_mean-based) — actual VIF values will confirm severity once state pipeline is re-run.

---

## 2026-03-03 (Session 3)

### `Code/run_county_analysis.R`

**Added rating-area clustered SE variants for premium outcomes**
- Methodological decision: counties within the same rating area share identical premiums by construction, creating mechanical within-rating-area residual correlation. State-level clustering (used for all other outcomes) nests rating areas but is imprecise for this.
- For `Benchmark_Silver_Real` and `Lowest_Bronze_Real` only, `run_models()` now also fits all four specs clustered at `rating_area_id` level. Results are stored as `*_RA_Cluster` list entries and printed in the output file.
- The existing RA-aggregation robustness block is unchanged.
- Data context: median rating area = 4 counties; 33.5% of RA × year cells are 1-to-1; max is 177.

**Debt reporting-rule exclusion corrected**
- Previous code (from prior session) excluded all years for CO, MN, NY. Verified via web research: CO HB23-1126 effective Aug 7 2023 affects only the 2023 August snapshot; NY effective Dec 2023 (postdates snapshot); MN effective Oct 2024 (outside panel). Corrected to CO 2023 only via `debt_reporting_policy` data frame. Recovers ~2,600 valid county-year observations for MN and NY.

**Drought multicollinearity resolved**
- Primary specs now use `drought_vars_primary` (pdsi_val + Lag1/Lag2 only). The previous 9-variable PDSI/PHDI/PMDI block caused severe VIF inflation. Full block retained as `drought_vars_robust_full` for optional robustness specs.

**Sample diagnostics added**
- `build_sample_diag()` computes N, counties, states, year range per outcome-spec combination. Written to `Analysis/county_sample_diagnostics.csv`. Supports outcome-neutral master merge verification (Next 2).

---

### `Code/run_descriptive_stats.R`

**Debt reporting exclusion corrected**
- Migrated from blanket state exclusion to `debt_reporting_policy` table (CO 2023 only), consistent with `run_county_analysis.R`.

---

### `Code/process_aqi_data.R`

**Strict population weighting; `Pop_Wt=1` fallback removed**
- Counties missing population data are now excluded from `AQI_Median_Wtd` rather than assigned weight=1. Equal-weight `AQI_Median_EW` series added as robustness. Diagnostics (N_Counties_AQI, N_Dropped_Missing_Pop, Drop_Share, Wtd vs EW difference) written to `Analysis/state_aqi_weight_diagnostics.csv`.

---

### `Code/process_state_climate.R`

**Added annual minimum PDSI (`pdsi_min`)**
- Aggregates minimum monthly PDSI value per state-year in addition to existing `pdsi_mean`. Captures worst within-year drought peak that the mean smooths over.

---

### `Code/analysis_pre_processing.R`

**Added `is_extreme_drought_peak` and `pdsi_min_level`**
- `pdsi_min_level`: annual minimum PDSI level derived from `pdsi_min`.
- `is_extreme_drought_peak`: binary indicator (pdsi_min < −4), capturing transient within-year drought peaks.
- Both added to distributed lag generation (lag1, lag2).

---

### `Code/run_analysis.R`

**Added `is_extreme_drought_peak` to state regression**
- `is_extreme_drought_peak` + lag1/lag2 added to `climate_vars`, complementing the mean-based `is_extreme_drought`.

---

### `Code/create_county_master.R`

**Outcome-neutral master merge (Next 2)**
- Merge skeleton now built from union of all source key sets (medical debt, premiums, climate, population, AQI, socioeconomic) rather than anchoring to medical debt rows. Counties present in premiums or climate but absent from debt are retained with NA debt values.

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
