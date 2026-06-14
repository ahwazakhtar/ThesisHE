# Implementation Plan: Cross-Level Symmetry

Track spec: `./spec.md`. Mirrors three single-level analyses to the other level for state↔county consistency checks. Phases are independent and can run in any order.

---

## Phase 1: Humidity at county level

- [ ] **Task: Build county tdmean panel**
    - [ ] New `Code/process_county_humidity.R`: area-weighted zonal mean of the PRISM tdmean grids over Census 2018 county boundaries → `Data/intermediate_humidity_county.rds` (fips_code, Year, tdmean_C, tdmean_F). 2009–2023.
    - [ ] Tests: schema, deg-F range, no duplicate (fips, Year), AK/HI NA.
- [ ] **Task: County humidity sensitivity**
    - [ ] New `Code/run_county_humidity_sensitivity.R`: join county tdmean; for the headline county outcomes, fit base vs +`tdmean_F` (+lags) on the identical humidity-available sample (mirror of the state humidity block). Export `Analysis/county_humidity_sensitivity.csv`; note whether county findings survive.

## Phase 2: Exposure Index (SVI) at state level

- [ ] **Task: State SVI + EJ interactions**
    - [ ] New `Code/run_exposure_index_state.R`: population-weight county `SVI_static` → state vulnerability; estimate `Y ~ Shock + Shock×SVI_state + controls | State + Year` for the state headline shocks (is_extreme_drought incl. lag2, is_cold_shock, is_high_cdd/hdd) × state outcomes. Export `Analysis/exposure_interaction_state_coefs.csv` with the outcome-aware EJ verdict.
    - [ ] Compare to the county EJ result; brief note in `Analysis/exposure_index_synthesis.md`.

## Phase 3: Demographic mediators at state level

- [ ] **Task: State demographic mediators**
    - [ ] New `Code/run_demographic_mediators_state.R`: population-weight ACS county demographics → state; first stage (state shocks → demographics) + mediator decomposition (state headline outcomes base vs +demographics, constant sample). Export `Analysis/demographic_response_state_coefs.csv` and `Analysis/demographic_mediator_state_decomposition.csv`.
    - [ ] Brief state↔county comparison note in `Analysis/state_analysis_summary.md` §7.

## Phase 4: Conductor verification

- [ ] **Task: Conductor — User Manual Verification 'Cross-Level Symmetry' (Protocol in workflow.md)**
