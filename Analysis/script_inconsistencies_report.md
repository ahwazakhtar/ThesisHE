# Script Inconsistencies Report

**Generated:** 2026-02-18
**Scope:** All active R scripts in `Code/` (20 scripts analyzed)

---

## Summary

15 coding inconsistencies were identified across the state and county pipeline scripts. They are grouped below by severity.

---

## Critical (May Silently Corrupt Results)

### 1. NOAA Missing-Value Threshold Mismatch

| Script | Threshold |
|---|---|
| `process_state_climate.R:60` | `Value <= -9.9` → NA |
| `process_county_climate.R:77` | `Value <= -99` → NA |

NOAA fixed-width files use `-9.99` or `-99.99` to encode missing months. The state-level script flags everything ≤ -9.9 as missing (correct), while the county-level script only flags values ≤ -99. This means county data retains many legitimate-looking missing values (e.g., `-9.99`, `-50`) as if they were real observations, which will silently bias county-level aggregations.

**Fix:** Align both to `<= -9.9` (or the documented NOAA sentinel value for each variable type).

---

### 2. MEPS Data Directory Split

| Script | Directory used |
|---|---|
| `download_meps_data.R:153` | `Data/MEPS_Data/` |
| `scrape_meps_html_base.R:4` | `Data/MEPS_Data_IC/` |
| `extract_local_meps.R:7-8` | `Data/MEPS_Data_IC/` |
| `create_state_master.R:10` | `Data/MEPS_Data_IC/` |

`download_meps_data.R` writes its consolidated CSV to `Data/MEPS_Data/meps_ic_state_consolidated.csv`, but the downstream master-building script reads from `Data/MEPS_Data_IC/meps_ic_state_consolidated.csv`. Running `download_meps_data.R` alone does **not** populate the path the master uses — the output is silently ignored.

**Fix:** Standardize all MEPS I/O to `Data/MEPS_Data_IC/`.

---

### 3. Duplicate Output File: County Medical Debt

Both scripts write to the same output path:

| Script | Writes to |
|---|---|
| `process_medical_debt_county.R:8` | `Data/medical_debt_county.csv` |
| `process_zip_county_map.R:13` | `Data/medical_debt_county.csv` |

`process_medical_debt_county.R` produces a simpler Urban Institute-only table. `process_zip_county_map.R` supersedes it by also merging NASHP hospital cost data. If both are run in sequence, whichever runs last wins, making the pipeline order-dependent. The simpler script appears to be an orphan that was never removed.

**Fix:** Remove or archive `process_medical_debt_county.R`. Document that `process_zip_county_map.R` is the canonical county debt/cost processor.

---

### 4. Missing `Unemployment_Rate` in County Master

`run_county_analysis.R:33` specifies:
```r
controls <- c("Household_Income_2023", "Uninsured_Rate", "Unemployment_Rate")
```

However, `create_county_master.R` never joins a unemployment series. The county master contains `Household_Income_2023` and `Uninsured_Rate` (from Urban Institute debt data) but no unemployment rate. The script uses `intersect()` to guard against missing columns, so it will not error — it will silently drop `Unemployment_Rate` from all county regressions without any warning.

**Fix:** Either source county-level unemployment (e.g., BLS LAUS series) and add it to `create_county_master.R`, or remove it from the intended controls list and document the omission.

---

## High (Methodological Inconsistency Between State and County Pipelines)

### 5. Different Regression Packages for Equivalent Models

| Script | Package | Estimator |
|---|---|---|
| `run_analysis.R:5-6` | `plm` + `sandwich` | `plm(..., model="within", effect="twoways")` + `vcovHC()` |
| `run_county_analysis.R:9` | `fixest` | `feols(... \| id + Year)` |

Both pipelines estimate two-way fixed-effects models with clustered standard errors, but use entirely different packages. `AGENTS.md` and `conductor/tech-stack.md` both designate `fixest` as the project standard. The state-level script predates this decision and was never updated.

**Fix:** Rewrite `run_analysis.R` to use `feols()` from `fixest`, matching the county script and the project style guide.

---

### 6. AQI Variable Construction Differs Between Levels

| Level | Script | AQI variable |
|---|---|---|
| State | `analysis_pre_processing.R:59-62` | Binary quintile indicator: `is_high_aqi` (1 if ≥ 80th pct within state) |
| County | `process_county_aqi.R:62` | Continuous z-score: `AQI_Shock` (county-demeaned, SD-scaled) |

The two pipelines operationalize air quality shocks differently. The binary quintile (state) discards magnitude; the z-score (county) preserves it. Results are therefore not directly comparable across levels.

**Fix:** Decide on one approach (z-score is preferred for event-study designs) and apply it consistently. At minimum, document the difference in the analysis plan.

---

### 7. Temperature Aggregation Method Differs Between Levels

| Level | Script | Aggregation |
|---|---|---|
| State | `process_state_climate.R:65-66` | **Sum** of 12 monthly averages → `temp_sum` |
| County | `process_county_climate.R:82` | **Mean** of 12 monthly values → `temp_val` |

Annual temperature is aggregated differently. Summing monthly temperatures (state) produces a value 12× larger than taking a mean (county), making the resulting z-scores incomparable in magnitude. The county approach (mean) is more standard for annual temperature.

**Fix:** Standardize to annual mean in both pipelines. Update `process_state_climate.R` to use `mean` for temperature (and note that `hdd_sum` / `cdd_sum` should stay as sums since those are cumulative degree-day counts).

---

### 8. NOAA State-Code Mapping: DC and Hawaii Discrepancy

The NOAA internal state codes differ between the two climate scripts:

| State | `process_state_climate.R` code | `process_county_climate.R` code |
|---|---|---|
| District of Columbia | `"101"` | **not present** |
| Hawaii | `"110"` | `"51"` |
| Alaska | `"050"` | `"50"` |

DC is entirely absent from the county-level NOAA mapping, so any county climate data for DC will be silently dropped. Hawaii uses code `"110"` at the state level but `"51"` at the county level — these reflect different NOAA encoding schemes for the two file types, but the discrepancy is undocumented and could cause confusion if the mappings are ever cross-referenced.

**Fix:** Add a code comment explaining that NOAA uses different internal codes for state- vs county-level files. Add DC (`"11"`) to `process_county_climate.R`'s `noaa_state_codes` if DC county data exists in the county files.

---

### 9. MEPS Year Range: Scraper vs Excel Downloader

| Script | Year range |
|---|---|
| `scrape_meps_html_base.R:5` | 1996–2025 |
| `download_meps_data.R:19` | **2011–2024** |

The Excel downloader only covers 2011–2024, leaving a 15-year gap (1996–2010) if the HTML scraper is not run. The `extract_local_meps.R` further restricts to 2021–2024. The intended sequence is: scraper for 1996–2020, Excel for 2021–2024; but `download_meps_data.R`'s year range overlaps and does not make this clear.

**Fix:** Update the comment in `download_meps_data.R` to explicitly state its role as a supplementary Excel downloader for recent years only, or restrict its `years` vector to `2021:2024`.

---

## Medium (Code Quality / Correctness)

### 10. Duplicate Section Numbers in Script Comments

**`download_state_policy_data.R`:** Section `4` appears twice:
```r
# 4. Medicaid Expansion Data   (line 126)
# 4. Section 1332 Reinsurance Waivers  (line 141)  ← should be 5
# 5. Medical Debt Reporting Bans  (line 152)  ← should be 6
```

**`create_county_master.R`:** Section `5` appears twice:
```r
# 5. Inflation Adjustment (Base 2023)  (line 79)
# 5. Final Output  (line 94)  ← should be 6
```

These are comment-only issues but make scripts harder to navigate.

---

### 11. `Is_Extreme_Drought_Lag2` Created but Not Used in County Analysis

`create_county_master.R:63` creates `Is_Extreme_Drought_Lag2`, but `run_county_analysis.R`'s model specs (`vars_spec1_base`, `vars_spec2_base`) include `Is_Extreme_Drought_Lag1` but **not** `Is_Extreme_Drought_Lag2`. The two-year lag variable is computed but never enters any regression. By contrast, the state pipeline uses lags 0, 1, and 2 for all shock indicators.

**Fix:** Add `Is_Extreme_Drought_Lag2` to `vars_spec2_base` (and `vars_spec1_base`) in `run_county_analysis.R`, consistent with the state analysis.

---

### 12. Repeated State Abbreviation Lookup Tables (DRY Violation)

The `state_abb_to_name` mapping (or its inverse) is defined independently in three scripts:

- `process_medical_debt.R:9–21`
- `create_state_master.R:17–29`
- `create_county_master.R:39–51` (inverted as `state_name_to_abbr`)

Any future correction (e.g., adding a territory) must be applied in all three places. A shared utility file or a single sourced R script would eliminate the duplication.

---

### 13. `process_aqi_data.R` Abandons Population-Weighting Goal

The script's comment at line 1 states the goal is "Population Weighted Aggregation", and lines 67–91 discuss the problem at length. The final implementation at line 101–103 silently falls back to a simple county mean:

```r
state_aqi <- df_all_aqi %>%
  group_by(State, Year) %>%
  summarize(aqi_mean = mean(Median.AQI, na.rm = TRUE), .groups = "drop")
```

The TODO comment (line 98) was never resolved. The output `state_aqi_consolidated.csv` used by `create_state_master.R` is therefore unweighted, despite the header claiming otherwise. `process_county_aqi.R` correctly uses FIPS-level data and achieves the intended granularity.

**Fix:** Either implement population-weighting using the FIPS lookup from `process_county_aqi.R`, or remove the misleading "Population Weighted" claims from the file header.

---

### 14. `process_rating_area_map.R`: Rating Area ID Normalization Is Incomplete

Lines 124–134 attempt to clean the `AREA` column:
```r
df_agg <- df_agg %>%
  mutate(
    AREA_Clean = str_replace(AREA, "Rating Area ", ""),
    rating_area_id = AREA   # Assuming it's already "ST##"
  )
```

`AREA_Clean` is computed but never used — `rating_area_id` is set to the raw `AREA` value. If any year's plan files use the `"Rating Area N"` format instead of `"ST##"`, the join to the crosswalk will silently produce all-NA premiums for that year.

**Fix:** Use `AREA_Clean` (or a properly formatted version) as `rating_area_id` rather than the raw `AREA`.

---

### 15. `scrape_meps_html_base.R` Downloads in Text Mode (`mode = "wt"`)

```r
download.file(url, tmp, quiet = TRUE, mode = "wt")
```

The `mode = "wt"` (write text) option is non-standard for `download.file` on Windows and may cause line-ending conversion issues on that platform. The rest of the download scripts consistently use `mode = "wb"` (write binary). HTML is text, but binary mode is safer for cross-platform reproducibility.

**Fix:** Change `mode = "wt"` to `mode = "wb"` in `scrape_meps_html_base.R:26`.

---

## Appendix: Files Analyzed

| Script | Role |
|---|---|
| `download_climate_data.R` | Downloads NOAA climate files |
| `download_meps_data.R` | Downloads MEPS IC Excel tables |
| `download_state_policy_data.R` | Downloads FRED macro + policy data |
| `process_aqi_data.R` | State-level AQI aggregation |
| `process_state_climate.R` | State-level NOAA climate parsing |
| `process_medical_debt.R` | State-level medical debt |
| `process_cms_health_exp.R` | CMS NHE expenditures |
| `scrape_meps_html_base.R` | MEPS HTML scraper (1996–2020) |
| `extract_local_meps.R` | MEPS Excel extractor (2021–2024) |
| `create_state_master.R` | Merges state components |
| `analysis_pre_processing.R` | State shock/lag engineering |
| `run_analysis.R` | State FE regressions |
| `process_county_aqi.R` | County AQI z-scores |
| `process_county_climate.R` | County NOAA climate parsing |
| `process_county_population.R` | SEER county population |
| `process_medical_debt_county.R` | County medical debt (orphaned) |
| `process_zip_county_map.R` | County debt + NASHP hospital costs |
| `process_rating_area_map.R` | HIX premium rating-area mapping |
| `create_county_master.R` | Merges county components |
| `run_county_analysis.R` | County FE regressions |
