# Implementation Plan: Hospital Supply-Side Integration

Track spec: `./spec.md`. Weaves hospital finances (NASHP HCT) through the Incidence / Persistence / Inequality papers at the **hospital-year** level, preserving provider heterogeneity. Reuses `Code/transition_symmetry.R`, `Code/cumulative_dose.R`, and the zip-county crosswalk.

Sequencing: Phase 1 (panel) is the data gate. Phases 2–4 (the three lenses) build on it and are independent of each other. Phase 5 integrates and verifies.

---

## Phase 1: Hospital-year panel

- [x] **Task: Build the hospital-year financial panel** 51d0ce3
    - [x] New `Code/process_hospital_panel.R`: read NASHP HCT (`readxl`); keep `CCN#`, Year, Zip Code, State + the scoped financials and attributes (spec §Variable scope). Derive `Hosp_UncompCare` (= Uninsured/Bad Debt + Net Charity), `Hosp_UncompCare_PctNPR`, inflation-adjust dollar fields to \$2023. 51d0ce3
    - [x] Map hospital Zip Code → `fips_code` via `Data/Zip County Crosswalk/` (hospital location, not residential allocation). Report county-match rate (98.4%). 51d0ce3
    - [x] Derive moderators: `SafetyNet` (top-quartile Medicaid + uncompensated payer mix), `Ownership`, `SystemAffiliated`, `BedSize`; placeholder for `MarketConcentration` (Phase 4). Output `Data/intermediate_hospital_panel.rds`. 51d0ce3
    - [x] Tests `Code/tests/test_hospital_panel.R`: schema, no duplicate (CCN, Year), margin/ratio plausible ranges, uncompensated-care = baddebt+charity identity, county-match coverage. 51d0ce3
- [x] **Task: Medicaid expansion table** 51d0ce3
    - [x] Small hardcoded state-year `MedicaidExpansion` indicator (KFF adoption dates); join to the panel. Document source in header (`Code/medicaid_expansion.R`). 51d0ce3

## Phase 2: Incidence — climate → hospital finances (Paper 1, supply side)

- [x] **Task: Hospital incidence regressions** 9aaf454
    - [x] New `Code/run_hospital_incidence.R`: `Y ~ Shock(+lags) + controls | CCN + Year`, cluster State, for outcomes {`Hosp_UncompCare_PctNPR`, `Hosp_OperatingMargin`, `Hosp_UncompCare`, `Hosp_NetMargin`}; shocks = Is_Extreme_Drought, High_CDD, High_HDD (county shocks attached by hospital county), High_AQI_Max. 9aaf454
    - [x] Export `Analysis/hospital_incidence_coefs.csv`; plots in `Analysis/plots/hospital/`. Headline: do climate shocks raise uncompensated care / compress operating margins? 9aaf454

## Phase 3: Persistence — hospital-finance dynamics (Paper 2, supply side)

- [x] **Task: Hospital persistence** 736e4c7
    - [x] New `Code/run_hospital_persistence.R`: onset/persist/exit symmetry (reuse `transition_symmetry.R`) and cumulative-dose (reuse `cumulative_dose.R`) on `Hosp_UncompCare_PctNPR` and `Hosp_OperatingMargin`. Hospital + year FE. 736e4c7
    - [x] Export `Analysis/hospital_persistence_coefs.csv`; note whether margin compression scars/compounds (drought scars both outcomes; CDD/HDD symmetric). 736e4c7

## Phase 4: Provider heterogeneity (Paper 3, supply side) — PRIMARY for this track

- [x] **Task: Construct market-concentration measure** 6b7f69d
    - [x] County-year hospital HHI from `Net Patient Revenue` shares by Health System within county; add `MarketConcentration` (+ `HighConcentration` ≥0.25 flag). 6b7f69d
- [x] **Task: Heterogeneity interactions** 6b7f69d
    - [x] New `Code/run_hospital_heterogeneity.R`: `Y ~ Shock + Shock × M + controls | CCN + Year` for M ∈ {`SafetyNet`, `Ownership`, `MedicaidExpansion`, `MarketConcentration`}, outcomes {uncompensated care %, operating margin}. 6b7f69d
    - [x] Marginal shock effect by moderator level; outcome-aware verdict (does strain concentrate in safety-net / high-Medicaid / non-expansion / concentrated-market hospitals?). Export `Analysis/hospital_heterogeneity_coefs.csv` + plots. 6b7f69d
    - [x] Tests for the interaction/heterogeneity machinery on a synthetic panel. 6b7f69d

## Phase 5: Synthesis, integration, verification

- [x] **Task: Synthesis + integrate into the three papers** 214b5b7
    - [x] New `Analysis/hospital_supply_side_synthesis.md`. 214b5b7
    - [x] Add a supply-side subsection to each: `state_analysis_summary.md` / `event_study_synthesis.md` / `delta_analysis_synthesis.md` as appropriate; note the demand↔supply pairing per paper. 214b5b7
    - [x] Make a copy of `Text/committee_presentation_20260615.tex` and add hospital slides to the copy (incidence, persistence, provider heterogeneity). 214b5b7
- [ ] **Task: Conductor — User Manual Verification 'Hospital Supply-Side Integration' (Protocol in workflow.md)**
