# Implementation Plan: Climate–Health Exposure Index (CHEI)

Track spec: `./spec.md`. Inspired by Anenberg's climate-health indicator work; primary framing is **Shock × vulnerability (CDC SVI) interactions** (EJ amplification), with Lancet-style person-years exposure and a composite CHEI scalar as complements.

Sequencing: Phase 1 (SVI acquisition) is the data gate. Phase 2 builds the exposure components on top of it. Phase 3 (EJ amplification) is the primary analysis and unlocks Phase 4 (secondary/robustness). Phase 5 is synthesis + the conductor gate.

---

## Phase 1: Acquire & process CDC SVI

- [ ] **Task: Download SVI county data**
    - [ ] New `Code/download_svi.R`: pull `SVI_<YYYY>_US_county.csv` for 2014, 2016, 2018, 2020, 2022 from `svi.cdc.gov` (keyless). Store raw CSVs in `Data/SVI_Data/`. Skip-if-exists; document the URL pattern and `-999` missing code in the header.
    - [ ] Tests in `Code/tests/test_exposure_index.R` (file present, expected key columns: `FIPS`, `RPL_THEMES`, `RPL_THEME1–4`).

- [ ] **Task: Process SVI to a county panel**
    - [ ] New `Code/process_svi.R`: keep `FIPS`, overall `RPL_THEMES`, and the four theme percentiles; recode `-999`→NA; validate 5-digit county FIPS. Build a vintage→year mapping covering 2011–2023 (nearest available vintage; document) → `Data/intermediate_svi.rds` with both a **time-invariant** `SVI_2018` (primary) and a **time-varying** `SVI_yr` (robustness) column.
    - [ ] Tests: percentiles in [0,1], no duplicate (fips, Year), AK/HI/territory coverage noted, vintage-mapping correctness.

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
