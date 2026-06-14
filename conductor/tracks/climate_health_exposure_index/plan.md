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

- [x] **Task: Lancet-style person-years exposure** [8b5b79d]
    - [x] `Code/exposure_index.R::person_years_exposure(pop, hazard_indicator, na_indicator_zero)` = Population × extreme-temperature indicator. (County-year series + state/national Lancet trend are materialized in Phase 4's descriptive script where the master join lives — avoids a redundant intermediate.)
    - [x] Tests: arithmetic (binary + continuous), NA handling per flag, non-negativity.

- [x] **Task: Composite CHEI scalar** [8b5b79d]
    - [x] `Code/exposure_index.R::build_chei(hazard_z, svi, pop=NULL, standardize=)` = hazard_z × SVI (relative) and × Population (absolute); optional z-standardisation. Hazard input parameterized.
    - [x] Tests: monotonic increasing in both hazard and vulnerability; zero-vulnerability ⇒ zero index; population scaling; standardisation mean 0 / sd 1. 12/12 exposure tests pass.

## Phase 3: EJ amplification — Shock × vulnerability interactions (PRIMARY)

- [x] **Task: Interaction regressions** [ceb8531]
    - [x] New `Code/run_exposure_index.R`: `Y ~ Shock + Shock:SVI_static + controls | fips_code + Year`, cluster State, for shocks {Drought, Drought_Lag2, Heat_CDD, Cold_HDD, Cold_CumYears} × 6 headline outcomes (30 models). Marginal shock effects at low (p25) and high (p75) SVI via `lincom`.
    - [x] Export `Analysis/exposure_interaction_coefs.csv` with `beta_shock`, `beta_interaction`, marginal effects, and an **outcome-aware `ej_verdict`** (adverse direction differs by outcome: debt/premiums up = harm, income/employment down = harm).
    - [x] 6 marginal-effect plots (shock effect at low vs high SVI) in `Analysis/plots/exposure_index/`.
    - [x] **Result:** 4 interactions show **EJ amplification** (climate harm worse in vulnerable counties): Heat→Employment (+878→−184), Cold→PCPI (−$56→−$472, ~8×), Drought(+lag2)→premiums. 3 are reversed — the *credit-bureau medical-debt* response concentrates in *less*-vulnerable counties (measurement artifact: poorer/uninsured counties accrue less measured debt). Honest caveat documented.

## Phase 4: Composite index & robustness (SECONDARY)

- [x] **Task: Composite-index regressions** [d842fbc]
    - [x] `Code/run_exposure_secondary.R` §4a: `Y ~ CHEI_heat / CHEI_cold + controls | fips + Year` for the 6 outcomes → `Analysis/exposure_chei_coefs.csv`. Headline: `CHEI_heat → Med_HH_Income` −$435/SD (p=0.0002).
- [x] **Task: Vulnerability-stratified + time-varying-SVI robustness** [d842fbc]
    - [x] §4b: median-SVI-split headline shock models (high/low) + time-varying-`SVI_yr` interactions → `Analysis/exposure_robustness.csv` (54 rows). Stratified corroborates the interaction direction (High_HDD→PCPI −$317 high-SVI vs −$85 low-SVI); time-varying-SVI leaves conclusions unchanged.
- [x] **Task: Lancet-style descriptive exposure** [d842fbc]
    - [x] §4c: person-years of extreme-temperature exposure (Population × High_CDD/HDD) → `Analysis/exposure_personyears_trend.csv` + `personyears_trend.png`. U.S. heat ~70–105M person-years/yr, 3–5× cold.

## Phase 5: Synthesis & conductor verification

- [x] **Task: Synthesis write-up** [d842fbc]
    - [x] New `Analysis/exposure_index_synthesis.md` (EJ-amplification verdict + medical-debt caveat, composite CHEI, robustness, Lancet trend); cross-referenced as §9 in `Analysis/state_analysis_summary.md`.
- [ ] **Task: Conductor — User Manual Verification 'Climate–Health Exposure Index' (Protocol in workflow.md)**
