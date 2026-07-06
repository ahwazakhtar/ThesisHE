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

**Current status (Jun 2026):**
- **State + county analysis:** Complete, with a deep robustness layer.
- **Completed tracks (analytical phases):** `committee_feedback_april_2026` (Phase 4 humidity now done), `persistence_extensions_20260521` (Phases 0–6), `climate_health_exposure_index` (Phases 1–5), `cross_level_symmetry` (Phases 1–3).
- **Open across all tracks:** only the user-driven Conductor *User Manual Verification* gates.
- Key findings: drought debt **scars** (h=2) and **cold employment compounds** with cumulative exposure; climate harm is **amplified in high-SVI counties** for income/employment/premiums (medical debt is a credit-bureau measurement-fragile outcome); humidity and demographics do **not** confound/mediate the headline findings.

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
| `Analysis/` | Regression outputs, tables, reports — one folder per analysis family |
| `Analysis/INDEX.md` | **Read this first for any results question** — maps every family to its headline finding and read-first file |
| `Analysis/state/regression_results_summary.csv` | Coefficients, SEs, p-values for primary models |
| `Analysis/state/synthesis.md` | State-level regression workflow and findings |
| `Analysis/memos/econometric_review.md` | Expert review of econometric specifications |
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

- **Tracks (all analytical phases complete; Conductor verification gates open):** `committee_feedback_april_2026`, `persistence_extensions_20260521`, `climate_health_exposure_index`, `cross_level_symmetry`. See `conductor/tracks.md` for the registry and each track's `spec.md`/`plan.md`. The earlier `county_analysis_refinement_20260216` track remains in progress for its own optional/verification items.
- **`hospital_supply_side_20260615` — implemented (Phases 1–5); Conductor verification gate open.** Hospital-year panel (NASHP HCT) woven through the three papers with provider heterogeneity.
- **`mechanism_channels_20260625` — implemented (Phases 0–6); verification gate open (Session 8, Jul 2026).** External-reader response bounding the agricultural income channel. Five new county data sources + ag-vs-labor separability estimation + Medicare morbidity channel. Verdict in `Analysis/mechanism/mechanism_verdict.md`: agriculture is one channel, not the channel. See Session-8 lessons below.
- **`did_frontier_robustness_20260625` — Phases 2–3 run; Phase 1 (wild bootstrap), 4 (synthesis), 5 (tests) still open.**
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

- **`Analysis/` layout (reorganized Jul 2026):** one folder per analysis family (`state/`, `county/`, `event_study/`, `delta/`, `cumulative_dose/`, `persistent_exposure/`, `exposure_index/`, `demographic_mediators/`, `hospital/`, `did/`, `mechanism/`, `mediation/`, `descriptive/`, `robustness/`, `threshold_sensitivity/`, `pathways/`, `memos/`). Each family's primary narrative is `synthesis.md`; run logs go in `<family>/build_logs/`; figures stay in `plots/<family>/`. **Never write a new output to the `Analysis/` root** — new scripts write to `Analysis/<family>/` and add a row to `Analysis/INDEX.md`. Refresh `INDEX.md` at session end. Historical docs (`plan.md` files, `changelog.md`) intentionally still cite the old root paths.
- **Hooks must invoke `python`, not `python3`** — on this machine `python3` resolves to the Microsoft Store stub and fails silently (discovered Jul 2026 when both hooks were found dead).
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
- County drought block multicollinearity: `run_county_analysis.R` primary specs use PDSI only (`drought_vars_primary`: pdsi_val + Lag1/Lag2) to avoid VIF inflation from near-collinear PDSI/PHDI/PMDI. Full 9-variable block retained as `drought_vars_robust_full` for optional robustness specs. VIF computed via auxiliary OLS on within-transformed predictor matrix; logged to `Analysis/county/county_vif_diagnostics.txt`. Post-pruning VIFs confirmed acceptable (max ~5.33).
- State AQI aggregation: `process_aqi_data.R` uses strict population weights — counties with missing population are dropped from `AQI_Median_Wtd` (no `Pop_Wt=1` fallback). Equal-weight robustness series `AQI_Median_EW` computed alongside. Diagnostics written to `Analysis/state/state_aqi_weight_diagnostics.csv`.
- Rating area structure in premium models: counties sharing a rating area have identical premiums by construction. Primary models cluster at state level (which nests rating areas). For premium outcomes (`Benchmark_Silver_Real`, `Lowest_Bronze_Real`), `run_county_analysis.R` also produces rating-area-clustered SE variants (`*_RA_Cluster`). The existing rating-area aggregation robustness block (lines 153–243) remains as a separate robustness check. Median rating area has 4 counties; 33.5% are 1-to-1.

### Lessons learned (Session 5, Jun 2026)
- **FIPS zero-padding trap:** `sprintf("%05s", fips)` pads with **spaces**, so 4-digit integer FIPS (single-digit state codes — CA=06, AL=01, …) become `" 1001"` and fail `^[0-9]{5}$` validation, silently dropping ~316 counties. Always use `formatC(as.integer(fips), width = 5, flag = "0")`. The same latent pattern exists in older socioeconomic scripts (their FIPS happen to arrive pre-padded).
- **County master `State` is a 2-letter abbreviation**, NOT a full name — any join to the state pipeline (which uses full names like "Alabama") needs an abbreviation→name map or it zero-matches silently. (`run_exposure_index_state.R` / `run_demographic_mediators_state.R` carry the map.)
- **Spatial work needs only `terra`** (it bundles GDAL/GEOS/PROJ and reads both rasters and vector boundaries) — `sf`/`tigris` are NOT required. Census cartographic boundaries (`Data/Geo/cb_2018_us_{state,county}_20m`) are auto-downloaded. County zonal extraction ≈ 90s/year.
- **PRISM `tdmean` is in °C** (convert ×9/5+32 → °F for project consistency). PRISM serves gridded CONUS data only (no AK/HI, no state/county endpoint) → aggregate locally.
- **Medical debt is the measurement-fragile outcome.** Credit-bureau medical debt requires insurance + billed encounters + a credit file, so poorer/uninsured (high-SVI) areas accrue less *measured* debt. The EJ direction on medical debt is **aggregation-sensitive** (amplifies at state level, reverses at county level), unlike income/employment/premium outcomes which are consistent. Lead EJ claims with the real-economy outcomes.
- **`Code/transition_symmetry.R::lincom()` and `Code/cumulative_dose.R`** are reusable helpers (linear-combination Wald tests, cumulative shock-years) used across the delta, dose, and exposure scripts.
- **New keyless data sources added:** PRISM (`services.nacse.org`), CDC/ATSDR SVI (`svi.cdc.gov`, filename casing varies by vintage — try candidates). New intermediates: `intermediate_humidity{,_county}.rds`, `intermediate_svi.rds`, `intermediate_demographics.rds`.

### Lessons learned (Session 6, Jun 2026)
- **The thesis has a demand/supply structure** (`Text/v2_Akhtar_Proposal.pdf`): Ch.1 consumers (premiums + medical debt), Ch.2 **hospitals** (operating margins, uncompensated care, financing — with provider heterogeneity), Ch.3 structural. The Incidence/Persistence/Inequality reorganization is **demand-heavy**; the hospital/supply side is under-built (only `Hosp_BadDebt_PerCapita`; `Hosp_Charity_Total`/`Hosp_Revenue_Total` unused). Track `hospital_supply_side_20260615` (Option 2) addresses this.
- **NASHP HCT (`Data/Hosp_Data/NASHP 2011-2023 HCT Data 2025 Feb.xlsx`, sheet `Downloadable`) has 114 hospital-year columns** — operating/net margin, uncompensated care, payer mix, ownership, system affiliation, bed size. Far richer than the 3 fields (`Uninsured and Bad Debt Cost`, `Net Charity Care Cost`, `Net Patient Revenue`) currently extracted by `process_zip_county_map.R`.
- **Provider heterogeneity requires a hospital-year unit.** County aggregation (the current county master) destroys hospital-level attributes (ownership, safety-net, system). The supply-side analysis must build a hospital (CCN) × year panel, mapping each hospital's Zip Code → county (modal/highest-share county per zip, not residential split) and attaching that county's climate shocks/SVI; hospital FE + year FE.
- **Beamer hyperlinked appendix:** `\begin{frame}[label=x]` + `\hyperlink{x}{\beamergotobutton{...}}` / `\beamerreturnbutton`, with `\appendix` before the detail slides; needs **two `pdflatex` passes** to resolve. Adding buttons to already-full slides overflows — free space first (drop a caption / shrink a figure).
- **Presentation `.tex`/`.pdf` are gitignored** (the repo tracks only `.md`/`.R`); existing committee decks were never force-added. New decks stay untracked unless the user asks to `git add -f`.

### Lessons learned (Session 7, Jun 2026)
- **Two-R-version setup.** Frontier DiD packages (`DRDID`, `did`, `HonestDiD`, `fwildclusterboot`) are unavailable on CRAN for the project's **R 4.2.2**; they run on **R 4.5.3** (`C:/Program Files/R/R-4.5.3/bin/Rscript.exe`). The `Code/did_robustness/` track is the ONLY thing on 4.5.3 — main pipeline stays on 4.2.2. Keep that boundary explicit in every script header. Install gotchas: the CRAN package is **`DRDID`** (uppercase; lowercase `drdid` silently "not available"); **`fwildclusterboot` is archived on CRAN** → install from r-universe `https://s3alfisc.r-universe.dev`.
- **`boottest` is O(FE-heavy) — never run it on a model with thousands of absorbed FEs.** Partial out the FEs with `fixest::demean` (Frisch-Waugh-Lovell) and bootstrap the 1-regressor residual model; point estimate and cluster structure are preserved. The full 3,155-county-FE model hung; FWL makes it tractable.
- **HonestDiD needs ≥1 testable pre-period.** The **2012 drought cohort has none** (panel starts 2011 = its e=−1), so HonestDiD can only run on the *pooled* multi-cohort CS event-study — which is already null. It cannot vindicate the 2012 natural experiment. Influence-function vcov from a `did::aggte` object must be scaled **1/n²** (`t(inf)%*%inf/n^2`), not 1/n.
- **`DRDID::drdid` requires a numeric `idname`** (`as.integer(factor(fips_code))`); character FIPS errors out.
- **Substantive DiD-robustness finding (2012 drought):** the **income** effect is robust — covariate-conditional DRDID 2×2 confirms it (−$1,451, vs −$1,311 unconditional). The **employment** effect is **fragile** — DR attenuates it ~58% (−2,053 → −871), the pooled CS-dr across all cohorts reverses it to null/positive (+2,609) with positive employment pre-trends. Lead with income; downgrade employment to a caveated secondary result. The 2012 effect is event-specific, NOT the effect of a typical drought cohort.
- **DiD estimand is ITT.** Treatment recurs: the 2012 cohort is in extreme drought only ~13% of its post-2012 county-years, so the ATT is "effect of first drought onset," not "effect of being droughted." The "2012 Midwest drought" label is a misnomer — the extreme-PDSI cohort is GA (45) + Mountain West + Plains, not the Midwest.

### Lessons learned (Session 8, Jul 2026) — Mechanisms track
- **Mechanism verdict (external-reader answer):** agriculture is *one* channel, not *the* channel. Lead the write-up with (1) the **Medicare-measured morbidity/utilization channel** — heat/cold/AQI raise standardized spending & ED visits, entirely non-agricultural, reproduces Deryugina et al. 2019 in-panel — and (2) **broad labor exposure** — cold→employment *survives/strengthens* in the bottom ag tercile; heat→employment loads on `ClimateExposed_NonFarm_Share`. Energy burden is a **distinct** distributional channel (only r=0.11 with SVI). Agriculture is real but **event-specific (2012)** and partly **population selection** (drought→out-migration, p=0.05).
- **New keyless/keyed data sources + exact endpoints** (all verified live, self-documented in each script header): USDA ERS County Typology **2015** CSV (`Farming_2015_Update==1` = 507 broad flag; non-overlapping economic-type==1 = **444** = ERS headline); BEA **CAINC5N LineCode 81** (Farm earnings) / **35** (Earnings by place of work) — `Farm_Earnings_Share`; ACS **C24030** male 003–027 / female 029–053 (climate-exposed non-farm = mining+construction+manufacturing+transport+utilities); IRS SOI `countyinflow<TOK>.csv`/`countyoutflow<TOK>.csv` (97-000 = total-US summary row; non-migrant = origin==dest); CMS Medicare Geographic Variation (resolve current CSV via `data.cms.gov/data.json`; **2014–2023**; filter `BENE_GEO_LVL==County` & `BENE_AGE_LVL==All`); DOE LEAD 2022 per-state ZIPs `data.openei.org/files/6219/{ST}-2022-LEAD-data.zip` (hyphens, not spaces; energy burden is DERIVED household-weighted, single 2022 vintage → time-invariant).
- **CMS Medicare PUF segfaults base `read.csv` when read all-character** (58MB × 246 cols). Read the header, then re-read with `colClasses` set to `"NULL"` for unwanted columns (select-only) — light and crash-free.
- **New intermediates:** `intermediate_ag_dependence.rds`, `intermediate_industry_composition.rds`, `intermediate_migration.rds`, `intermediate_medicare_spending.rds`, `intermediate_energy_burden.rds`. All merge onto the county master at 97–98% (unmatched ~2% = CT 2022 planning regions `091xx`↔old `090xx`, AK renames, CO `089xx`). Moderators are **structural/baseline** (never contemporaneous farm income — bad control).
- **`effect_bottom/effect_overall` ratio is unstable** when the overall effect ≈ 0 — read significance/sign, not the raw ratio.
- **Build-run documentation convention:** R runs are script files (not inline `Rscript -e`); each process/estimation script self-logs via `sink()` to `Analysis/mechanism/build_logs/*.log`.

### Lessons learned (Session 9, Jul 2026) — Writing
- **New writing skill `nber-economist-writing-style`** (`.claude/skills/nber-economist-writing-style/`), reverse-engineered from `Text/w33491.pdf` (Aguilar-Gomez, Graff Zivin & Neidell 2025). The rule the source most enforces: **no antithetical "X, not Y" epigrams** (verified — 0 in 30 pages; "rather than" appears only 3×, always for a substantive mechanism contrast). Also: every number anchored to a baseline, graded hedging, disarm-the-alternative structure, idiom confined to intro/conclusion. `reference/exemplars.md` holds annotated model sentences.
- **Mechanism write-ups (all NBER-styled):** external-reader response (`Text/reviewer_response_mechanisms_nber.md`) + email version (`_email.md`) + self-contained paper section (`Text/mechanisms_section.md`, §6). Findings also woven into `Text/thesis_paper_abstracts.md`. The four mechanism channels: **morbidity/utilization (Medicare), labor exposure, energy burden, provider-finance**; agriculture is the tested hypothesis (one channel among several), migration a caveat. **Outstanding:** two incomplete references (Audi et al. 2024–25; Doremus et al. 2022) and two `[TK]` baseline denominators in the reviewer-response file.
