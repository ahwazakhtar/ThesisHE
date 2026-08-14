# Knowledge: Data & Pipeline

Read this before touching any download/process/create script or debugging a merge.
Cross-cutting silent-corruption traps (FIPS padding, state-name joins) are in CLAUDE.md.

## Data sources

| Domain | Source | Key Variables |
|--------|--------|--------------|
| Climate | NOAA (NCEI) | Temp, Precip, CDD, HDD, PDSI, PHDI, PMDI, ZNDX |
| Air Quality | EPA | Annual AQI by county |
| Humidity | PRISM (Oregon State/NACSE, keyless) | Annual 4km CONUS `tdmean` → state/county via `terra` |
| Social Vulnerability | CDC/ATSDR SVI (keyless) | County overall + 4-theme percentiles, 2014–2022 |
| Demographics | Census ACS 5-yr | Mobility (B07001), age (B01001), tenure (B25003) |
| Inflation | FRED | CPI (CPIAUCNS) for real-dollar conversion. **Base-year divergence trap (found 2026-08-13):** the county master hardcodes **Base 2023** (`create_county_master.R:173`), but the state master targets the **latest** year in `us_cpi_annual.csv` ("Target Year: Latest Available") — and that file has carried 2025 rows since Feb 2026, so state `*_Real` series rebuilt after that date are plausibly in 2025 dollars. Verify the base before citing any cross-panel dollar comparison; essay dollar levels are county-based (2023). |
| HIX Premiums | HIX Compare | Individual market premiums and plan details |
| Health Spending | CMS (NHE) | Per capita spending by state (PHI, Medicare, Medicaid) |
| Employer Insurance | AHRQ (MEPS-IC) | Employee contributions and deductibles |
| Hospital Costs | NASHP | Hospital Cost Tool (hospital-year) |
| Medical Debt | Urban Institute | County medical debt over time (Aug credit-bureau snapshots) |
| Macro Policy | FRED / BEA | State unemployment and personal income |
| Ag dependence | USDA ERS + BEA CAINC5N | County Typology 2015; Farm_Earnings_Share |
| Industry composition | Census ACS C24030 | Climate-exposed non-farm share |
| Migration | IRS SOI county flows | In/out-migration, non-migrants |
| Medicare | CMS Geographic Variation PUF | Standardized spending, ED visits (2014–2023) |
| Energy burden | DOE LEAD 2022 | Household-weighted energy burden (time-invariant) |

Mechanism-track endpoint details (exact URLs, line codes, filter rules) are self-documented
in each `download_county_*.R` / `process_county_*.R` script header — trust those first.
Highlights: ERS `Farming_2015_Update==1` = 507 broad flag vs non-overlapping economic-type
= 444 (ERS headline); BEA CAINC5N LineCode 81 (farm earnings) / 35 (earnings by place of
work); ACS C24030 male 003–027 / female 029–053; IRS SOI `97-000` = total-US summary row,
non-migrant = origin==dest; CMS: resolve current CSV via `data.cms.gov/data.json`, filter
`BENE_GEO_LVL=="County" & BENE_AGE_LVL=="All"`; DOE LEAD per-state ZIPs
`data.openei.org/files/6219/{ST}-2022-LEAD-data.zip` (hyphens, not spaces).

## Master panels

- `Data/county_level_master.csv`: **82 columns, 118,732 rows, 3,232 counties, 1990–2026**
  (verified 2026-07-13 post-dedup; rows before 2011 exist for baseline anchoring/pre-trends —
  the outcome analysis window is 2011–2023, premiums extend to 2025/26). If dims matter,
  re-verify with `nrow()` — the durable fix is a build-time manifest emitted by
  `create_county_master.R` (not yet implemented; the build DOES now assert uniqueness and a
  row-count band).
- Integrity: **county master certified unique on (fips_code, Year)** as of 2026-07-13
  (`fca5643`): the multi-rating-area premium join is collapsed in `create_county_master.R`
  (unweighted mean across a county's rating areas for the 4 premium columns; `first()` for
  the constancy-asserted rest) and the build hard-stops on any duplicate or constancy
  violation. Pre-dedup backup: `Data/_archive/county_level_master_prededup_20260713.csv`;
  defense documentation: `Analysis/county_dedup_integrity.md`. The old downstream dedupe
  stopgaps (`run_premium_mediation.R`, `run_latent_hardship.R`) are now no-ops, left as
  redundancy. ~25 raw-reading consumers pick up the dedup on their next run — regenerate
  before citing pop-weighted county distributed-lag coefficients from stale outputs.
- `Data/state_level_analysis_master.csv`: consolidated state panel.

## Pipeline dependency rules

- `process_aqi_data.R` (state AQI) needs `intermediate_aqi.rds` + `intermediate_pop.rds` —
  run `process_county_aqi.R` and `process_county_population.R` first.
- Both state and county climate load **from 1990** to cover the 1990–2000 pre-study baseline
  for Z-score anchoring (county previously filtered at 1996 — corrected).
- `Z_Temp`/`Z_Precip` in `process_county_climate.R` are anchored to per-county means/SDs
  computed over **1990–2000 only**; baseline stats joined pre-mutate, dropped from output RDS.
- `Is_Extreme_Drought` (PDSI ≤ −4) is computed in `process_county_climate.R` with Lag1/Lag2 —
  not in `create_county_master.R`.
- `process_state_climate.R` outputs `pdsi_mean` (annual mean) and `pdsi_min` (worst month).
  `analysis_pre_processing.R` derives `pdsi_level` (from mean) and `is_extreme_drought_peak`
  (`pdsi_min < -4`); both lagged into `run_analysis.R`. `pdsi_min` catches transient
  within-year peaks the mean smooths over.
- State AQI aggregation (`process_aqi_data.R`): strict population weights — counties with
  missing population are dropped from `AQI_Median_Wtd` (no fallback). Equal-weight series
  `AQI_Median_EW` computed alongside; diagnostics in `Analysis/state/state_aqi_weight_diagnostics.csv`.
- AQI variables are continuous (Median AQI pop-weighted, Max AQI, pollutant-day %) — no
  z-scores or quintiles; AQI uses hard EPA thresholds. `High_AQI_Max` (Max AQI > 100) is
  built in `run_event_study.R` (10,949 events, ~9.2%). Median AQI > 100 was rejected (6 obs).
- `create_county_master.R` pulls `Median_AQI`/`Max_AQI` from the intermediate; uses
  `any_of()` for backward-compatible `AQI_Shock` columns.
- County socioeconomic: `download_county_socioeconomic.R` → `process_county_socioeconomic.R`
  → `Data/intermediate_socioeconomic.rds`. `PCPI_Real` (BEA CAINC1), `Med_HH_Income_Real`
  (ACS B19013_001E), `Civilian_Employed` (ACS B23025_004E). ACS 2011–2023; BEA 1990–2023.
  API keys in `~/.Renviron` (`BEA_API_KEY`, `CENSUS_API_KEY`).
- `process_zip_county_map.R` is the **sole canonical** county debt/cost processor
  (`process_medical_debt_county.R` is archived).

## API and format gotchas

- **ACS variable names need the `E` suffix** (`B19013_001E`); plain `B19013_001` → 400 error.
- **BEA CAEMP25N county employment is NOT on the Regional API** — use ACS B23025_004E.
- **CMS Medicare PUF segfaults base `read.csv`** when read all-character (58MB × 246 cols).
  Read the header, then re-read with `colClasses="NULL"` for unwanted columns.
- **PRISM `tdmean` is °C** (convert ×9/5+32 → °F). PRISM is gridded CONUS only (no AK/HI,
  no state/county endpoint) → aggregate locally.
- **SVI filename casing varies by vintage** — try candidate casings.
- **NOAA named-vector key maps: check for duplicate keys** — R silently returns the first
  match, making later entries dead code.

## Intermediates registry

`intermediate_aqi.rds`, `intermediate_pop.rds`, `intermediate_socioeconomic.rds`,
`intermediate_humidity.rds`, `intermediate_humidity_county.rds`, `intermediate_svi.rds`,
`intermediate_demographics.rds`, `intermediate_ag_dependence.rds`,
`intermediate_industry_composition.rds`, `intermediate_migration.rds`,
`intermediate_medicare_spending.rds`, `intermediate_energy_burden.rds`.

Mechanism intermediates merge onto the county master at 97–98%; the unmatched ~2% are CT
2022 planning regions (`091xx` vs old `090xx`), AK renames, and CO `089xx`.

## Domain-specific data notes

- **Hospital (NASHP HCT)**: `Data/Hosp_Data/NASHP 2011-2023 HCT Data 2025 Feb.xlsx`, sheet
  `Downloadable`, has **114 hospital-year columns** (margins, uncompensated care, payer mix,
  ownership, system, beds). County aggregation destroys hospital attributes — provider
  heterogeneity uses the hospital (CCN) × year panel (`process_hospital_panel.R`), zip →
  modal county (not residential split). Bad debt/charity: ~23% of counties missing (no
  hospital reports); one negative `Hosp_Charity_Total` (−$408M) — winsorize before regression.
- **Medical debt reporting-rule exclusions** (Urban Institute Aug snapshots): CO HB23-1126
  (eff. Aug 7 2023) → **exclude CO 2023 only**. NY (eff. Dec 13 2023) → after the Aug
  snapshot, no exclusion. MN (eff. Oct 1 2024) → outside window, no exclusion. Implemented
  via the `debt_reporting_policy` table in `run_descriptive_stats.R` and
  `run_county_analysis.R`. The 2022–23 national CRA voluntary changes hit all states equally.
- **MEPS lives in `Data/MEPS_Data_IC/`** — use this path consistently.
