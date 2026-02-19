# Changelog

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
