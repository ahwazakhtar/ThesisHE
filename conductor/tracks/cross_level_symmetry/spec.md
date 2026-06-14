# Track Specification: Cross-Level Symmetry

## Description
Several analyses built in earlier tracks were estimated at only one geographic level because they extended a pipeline that lived at that level (the year-over-year delta/transition framework is county-only; humidity plugged into the state pipeline; SVI and ACS demographics are county data). This track **mirrors three of them to the other level** so the headline conclusions can be checked for state↔county consistency. Per user direction.

## Mirrors
1. **Humidity → county.** Aggregate PRISM `tdmean` to county-year by area-weighted zonal mean (mirror of `process_state_humidity.R`), then run a county humidity-sensitivity (does the county Spec-2 / delta finding survive humidity adjustment?).
2. **Exposure Index (SVI) → state.** Population-weight county SVI to a state vulnerability index and run the `Shock × SVI` EJ-amplification interactions in the state pipeline. *Caveat:* vulnerability is inherently local, so state SVI is coarser; reported as a robustness mirror, not a replacement for the county result.
3. **Demographic mediators → state.** Population-weight ACS migration/age/tenure to state and re-run the mediator decomposition on the state headline outcomes.

## Scope of code changes
- New `Code/process_county_humidity.R` (+ county humidity sensitivity in a small runner or `run_county_analysis.R` block).
- New `Code/run_exposure_index_state.R` (state SVI aggregation + interactions).
- New `Code/run_demographic_mediators_state.R` (state demographic aggregation + decomposition).
- Tests extended; synthesis cross-references into the existing synthesis docs.

## Acceptance Criteria
- County `tdmean` panel built; county humidity-sensitivity reports whether headline county findings survive humidity.
- State SVI built (population-weighted); `Shock × SVI` state interactions estimated and compared to the county EJ verdict.
- State demographic mediators built; decomposition reports the fraction of state shock effects surviving demographic adjustment.
- Each mirror notes state↔county agreement/disagreement in a brief synthesis addition.
