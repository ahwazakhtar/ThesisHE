# Track Specification: Climate–Health Exposure Index (CHEI)

## Description
Introduces an **exposure-index** layer to the county analysis, inspired by Susan Anenberg's climate-health indicator work. It combines the project's existing climate **hazard** with **exposure** (population) and structural **vulnerability** (CDC/ATSDR Social Vulnerability Index) under the standard *hazard × exposure × vulnerability* risk framing, and tests the environmental-justice hypothesis that climate→health-cost effects are **amplified in structurally vulnerable counties**.

Mapping to Anenberg's approaches:
- **EJ / vulnerability indices** (CDC SVI) → the vulnerability layer `V_i` (primary).
- **Lancet Countdown** heatwave/heat-exposure → population-weighted *person-years of extreme-temperature exposure* (descriptive).
- **Composite risk index** → a single scalar `CHEI_it`.
- *Out of scope:* satellite NDVI/LST urban-surface indices (weak fit at county resolution) and mobility-based dynamic exposure (no commute-flow data). Documented per user direction.

## Data source (de-risked)
CDC/ATSDR SVI county CSVs, keyless: `https://svi.cdc.gov/Documents/Data/<YYYY>/csv/states_counties/SVI_<YYYY>_US_county.csv` (confirmed HTTP 200 for 2020; 158 cols incl `FIPS`, `RPL_THEMES`, `RPL_THEME1–4`, `E_TOTPOP`). Vintages 2014/2016/2018/2020/2022 cover the 2011–2023 panel. `-999` codes missing.

## Objectives
- **Acquire & process SVI** to a county panel (overall + 4 theme percentiles), with a documented vintage→year mapping.
- **Build exposure components:** (a) Lancet-style population-weighted extreme-temperature person-years; (b) composite `CHEI_it = z(Hazard_it) × V_i` (and a population-scaled absolute-burden variant).
- **EJ amplification (primary):** `Y ~ Shock + Shock × SVI + controls | fips + Year` — do high-vulnerability counties show larger climate→health-cost effects? Reuses the headline shock vocabulary (drought lag-2, cold lag-1, High_CDD/HDD, cumulative dose).
- **Secondary:** composite `CHEI` as a single regressor; vulnerability-stratified (high/low SVI) robustness; Lancet-style descriptive exposure trends.

## Design decisions
- **SVI is treated as time-invariant `V_i`** in the primary interaction spec (a single mid-panel vintage, e.g. 2018, or the panel mean): the main effect is absorbed by county FE while the `Shock × V` interaction is identified, and this avoids SVI responding endogenously to shocks. A time-varying nearest-vintage SVI is a robustness variant.
- Reuses `fixest`/FE machinery, state-level clustering, and the existing outcomes (Medical_Debt_Share, PCPI_Real, Hosp_BadDebt_PerCapita, premiums, employment).

## Scope of code changes
- New `Code/download_svi.R`, `Code/process_svi.R` → `Data/intermediate_svi.rds`.
- New `Code/exposure_index.R` (sourceable helpers: person-years exposure, CHEI construction) + `Code/run_exposure_index.R` (interaction + index + stratified models).
- New `Code/tests/test_exposure_index.R`.
- New synthesis `Analysis/exposure_index/synthesis.md`; cross-references into `Analysis/state/synthesis.md`.

## Acceptance Criteria
- SVI county panel built and joined; vintage→year mapping documented; FIPS-join coverage reported.
- Person-years exposure and composite CHEI constructed with tests (ranges, NA handling, monotonicity in hazard and in vulnerability).
- EJ amplification interaction models estimated for headline shocks × outcomes; the `Shock × SVI` coefficients tabulated with sign/significance and an explicit verdict on whether vulnerability amplifies the climate-cost effect.
- Composite-index and vulnerability-stratified robustness reported; Lancet-style descriptive exposure trend produced.
- Synthesis doc ties the index results to the headline findings.
