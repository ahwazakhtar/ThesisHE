# Implementation Plan: Climate–Health Exposure Index (CHEI)

Track spec: `./spec.md`. Inspired by Anenberg's climate-health indicator work; primary framing is **Shock × vulnerability (CDC SVI) interactions** (EJ amplification), with Lancet-style person-years exposure and a composite CHEI scalar as complements.

Sequencing: Phase 1 (SVI acquisition) is the data gate. Phase 2 builds the exposure components on top of it. Phase 3 (EJ amplification) is the primary analysis and unlocks Phase 4 (secondary/robustness). Phase 5 is synthesis + the conductor gate.

---

## Phase 1: Acquire & process CDC SVI

- [x] **Task: Download SVI county data** [9f68392]
    - [x] New `Code/download_svi.R`: keyless pull of `SVI_<YYYY>_US_county.csv` for 2014/2016/2018/2020/2022 from `svi.cdc.gov`, trying candidate filename casings (ATSDR varies them), skip-if-exists, `-999` documented. All 5 vintages fetched. Raw in `Data/SVI_Data/`.
    - [x] Tests in `Code/tests/test_exposure_index.R` (URL-candidate pattern; raw vintages have FIPS/RPL_THEMES/RPL_THEME1–4).

- [x] **Task: Process SVI to a county panel** [9f68392]
    - [x] New `Code/process_svi.R`: keeps overall `RPL_THEMES` + 4 theme percentiles; `-999`→NA; validated 5-digit FIPS. Documented `nearest_svi_vintage()` map (largest vintage ≤ year, floored at 2014). Output `Data/intermediate_svi.rds`: **time-invariant `SVI_static`** (2018 vintage, cross-vintage-mean fallback) for the primary interaction + **time-varying `SVI_yr`** (+ themes) for robustness. 41,015 rows, 3,155 counties, 2011–2023, ~0% NA.
    - [x] **Bug fixed:** `sprintf("%05s")` pads with spaces (dropped CA/AL/etc. 4-digit-int FIPS → 2,827 counties); switched to `formatC(width=5, flag="0")` → 3,155 counties (matches master).
    - [x] Tests: nearest-vintage mapping, FIPS validation, percentiles in [0,1], no duplicate (fips, Year), time-invariance of `SVI_static`, year coverage. 5/5 pass.

## Phase 2: Construct exposure components

- [ ] **Task: Lancet-style person-years exposure**
    - [ ] In `Code/exposure_index.R` (sourceable): `person_years_exposure(pop, hazard_indicator)` = Population × extreme-temperature indicator (High_CDD / High_HDD). County-year series + state/national aggregates for a Lancet-style trend.
    - [ ] Tests: arithmetic correctness, NA handling, non-negativity.

- [ ] **Task: Composite CHEI scalar**
    - [ ] In `Code/exposure_index.R`: `build_chei(hazard_z, svi, pop=NULL)` = z(Hazard) × SVI (relative risk) and a population-scaled absolute-burden variant; standardized output. Hazard input parameterized (continuous CDD/HDD z, PDSI severity, or shock-count).
    - [ ] Tests: monotonic increasing in both hazard and vulnerability; zero-vulnerability ⇒ zero index; standardization sanity.

## Phase 3: EJ amplification — Shock × vulnerability interactions (PRIMARY)

- [ ] **Task: Interaction regressions**
    - [ ] New `Code/run_exposure_index.R`. For each headline shock (Is_Extreme_Drought incl. lag2, High_CDD, High_HDD incl. lags, cumulative-dose) × headline outcome (Medical_Debt_Share, PCPI_Real, Hosp_BadDebt_PerCapita, premiums, employment): estimate `Y ~ Shock + Shock:SVI_2018 + controls | fips_code + Year`, cluster State (+ RA-cluster for premiums).
    - [ ] Export `Analysis/exposure_interaction_coefs.csv` with the `Shock` and `Shock × SVI` terms; a verdict column on whether vulnerability amplifies (sign & significance of the interaction).
    - [ ] Plots: interaction marginal effects (effect of shock at low vs high SVI) per (shock × outcome) in `Analysis/plots/exposure_index/`.

## Phase 4: Composite index & robustness (SECONDARY)

- [ ] **Task: Composite-index regressions**
    - [ ] `Y ~ CHEI + controls | fips_code + Year` for the headline outcomes; export `Analysis/exposure_chei_coefs.csv`.
- [ ] **Task: Vulnerability-stratified + time-varying-SVI robustness**
    - [ ] Re-estimate the headline shock models on high- vs low-SVI subsamples (median split) and compare; re-run the primary interactions with time-varying `SVI_yr`. Export `Analysis/exposure_robustness.csv`.
- [ ] **Task: Lancet-style descriptive exposure**
    - [ ] National/state person-years-of-extreme-temperature-exposure trend (2011–2023) + plot; brief narrative.

## Phase 5: Synthesis & conductor verification

- [ ] **Task: Synthesis write-up**
    - [ ] New `Analysis/exposure_index_synthesis.md`: EJ-amplification verdict, composite-index result, stratified robustness, Lancet trend; cross-reference into `Analysis/state_analysis_summary.md`.
- [ ] **Task: Conductor — User Manual Verification 'Climate–Health Exposure Index' (Protocol in workflow.md)**
