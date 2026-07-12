# Implementation Plan: Cross-Level Symmetry

Track spec: `./spec.md`. Mirrors three single-level analyses to the other level for state↔county consistency checks. Phases are independent and can run in any order.

---

## Phase 1: Humidity at county level

- [x] **Task: Build county tdmean panel** [93e9c2e]
    - [x] New `Code/process_county_humidity.R`: area-weighted zonal mean of the PRISM tdmean grids over Census 2018 county boundaries → `Data/intermediate_humidity_county.rds` (fips_code, Year, tdmean_C, tdmean_F). 48,300 rows, 3,220 counties, 2009–2023, °F range 13.7–70.8; AK/HI/PR NA.
    - [x] Integration test added to `Code/tests/test_state_humidity.R` (schema, deg-F range, no duplicate (fips, Year), AK/HI NA). 5/5 pass.
- [x] **Task: County humidity sensitivity** [93e9c2e]
    - [x] New `Code/run_county_humidity_sensitivity.R`: county Spec-2 climate coefficients base vs +`tdmean_F`(+lags) on the identical humidity-available sample → `Analysis/county_humidity_sensitivity.csv`. **County cold findings survive humidity** (High_HDD→Hosp_BadDebt 4.93→4.71 p=0.04; →premium 28.1→23.2 p=0.01; High_CDD→Med_HH_Income −297→−295 p=0.007) — mirrors the state result.

## Phase 2: Exposure Index (SVI) at state level

- [x] **Task: State SVI + EJ interactions** [93e9c2e]
    - [x] New `Code/run_exposure_index_state.R`: population-weighted state SVI; `Y ~ Shock + Shock×SVI_state + controls | State + Year` for state shocks × outcomes → `Analysis/exposure_interaction_state_coefs.csv` (25 rows, outcome-aware EJ verdict).
    - [x] EJ signal persists (cold→Total_Per_Capita_Health_Exp +$1,720 p=0.0002 amplifies). **State↔county divergence on medical debt** (state: amplifies in vulnerable; county: concentrated in less-vulnerable credit-bureau artifact) noted in `Analysis/exposure_index_synthesis.md`.

## Phase 3: Demographic mediators at state level

- [x] **Task: State demographic mediators** [93e9c2e]
    - [x] New `Code/run_demographic_mediators_state.R`: population-weighted state demographics; first stage (2/12 shock→demographic links significant) + decomposition → `Analysis/demographic_response_state_coefs.csv`, `Analysis/demographic_mediator_state_decomposition.csv`. **No mediation** (fraction surviving ≈ 0.92–1.04 for debt/health-spending) — mirrors county. Noted in `Analysis/state_analysis_summary.md` §10.

## Phase 4: Conductor verification

- [x] **Task: Conductor — User Manual Verification 'Cross-Level Symmetry' (Protocol in workflow.md)** [checkpoint: 001698f] *(author sign-off 2026-07-13; track complete.)*
