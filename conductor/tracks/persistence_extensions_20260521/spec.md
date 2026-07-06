# Track Specification: Persistence Extensions

## Description
Addresses the gaps identified in `Text/_archive/persistence.txt` after the April 2026 committee feedback work. Six gaps that the committee_feedback_april_2026 track did not close: ex-ante hypothesis framing, symmetric Onset/Persist LP horizons, continuously-exposed sub-population analysis, demographic-change / migration mediators, cumulative shock-years dose analysis, and HDD/CDD threshold sensitivity. CBSA-level robustness is explicitly excluded per user direction.

## Objectives
- **Hypothesis framing:** Make ex-ante predictions explicit in the synthesis docs; identify findings that are surprising vs.\ expected.
- **Symmetry of shock dynamics:** Extend Onset and Persist indicators with LP horizons \(h=0..3\) mirroring the Exit-LP work in Phase 2 of the prior track; report a three-way comparison table and a formal \(\beta_\text{Onset} + \beta_\text{Exit} = 0\) symmetry test.
- **Continuously-exposed sub-population:** Characterize counties with persistent (e.g., \(\geq 10/13\) years) shock exposure separately from onset cohorts; estimate the always-exposed vs.\ never-exposed gap.
- **Cumulative-dose:** Compute cumulative-shock-years per county and test dose-response on headline outcomes; compare year-10-of-HDD vs.\ year-1-of-HDD effects.
- **Demographic-change mediators:** Pull ACS migration (B07001) and age-distribution (B01001) data; test whether shock effects mediate through population change.
- **Threshold sensitivity:** Re-run primary state and county specs with p70 and p90 HDD/CDD cutoffs alongside the existing p80.

## Out of scope
- CBSA / climate-zone-level robustness (user direction).
- PRISM humidity integration (parent track `committee_feedback_april_2026` Phase 4 remains parked).

## Scope of code changes
- Extensions to `Code/run_delta_analysis.R` for Onset-LP and Persist-LP at \(h=0..3\) and the symmetry test.
- New `Code/run_persistent_exposure.R` for the continuously-exposed sub-population analysis.
- New `Code/run_cumulative_dose.R` for cumulative-shock-years analysis.
- Extensions to `Code/download_county_socioeconomic.R` and `Code/process_county_socioeconomic.R` for migration / age variables; new `Code/run_demographic_mediators.R`.
- New `Code/run_threshold_sensitivity.R` for the p70/p80/p90 sweep.
- Hypothesis-framing additions to `Analysis/state/synthesis.md` and `Analysis/event_study/synthesis.md`.

## Acceptance Criteria
- Synthesis docs lead each finding block with an ex-ante prediction and flag surprises.
- Onset-LP and Persist-LP coefficients exported at \(h=0..3\) for Drought, CDD, HDD shocks; three-way comparison plotted; symmetry-test results tabulated.
- Continuously-exposed cohort defined, descriptive table produced, and contrast vs.\ never-exposed estimated.
- Cumulative-shock-year variable constructed and dose-response coefficients reported.
- ACS migration and age variables joined into county master; mediator regressions produced.
- Threshold-sensitivity table reports headline coefficients at p70, p80, p90 alongside.
