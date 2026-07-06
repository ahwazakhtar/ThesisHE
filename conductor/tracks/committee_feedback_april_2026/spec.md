# Track Specification: Committee Feedback April 2026

## Description
This track implements the five-item feedback set delivered by the thesis committee in April 2026. It is a cross-cutting refinement layer on top of the county- and state-level analyses already in place. Source: `Text/correspondence/Feedback from Committee April 2026.md`.

## Objectives
- **Econometric robustness:** Estimate random-effects counterparts to primary FE specs and report Hausman tests.
- **Post-exit dynamics:** Extend the existing delta/exit framework with local-projection horizons to estimate the effect on spending when a county exits a shock state.
- **Diff-in-Diff with never-exposed controls:** Construct a never-exposed inventory per shock and estimate (a) a sharp natural-experiment 2x2 DiD and (b) a stacked / Callaway-Sant'Anna DiD against never-treated controls.
- **Humidity controls:** Acquire PRISM `tdmean` at state level, integrate into the state pipeline, and test whether headline drought/cold findings survive humidity adjustment.
- **Propagation-pathway evidence:** Document literature and produce descriptive evidence for the claimed mechanisms (heat -> delayed care, cold -> shifted utilization).

## Scope
- New script: `Code/run_did_analysis.R` for natural-experiment and stacked DiD.
- New script: `Code/download_prism_humidity.R` and `Code/process_state_humidity.R`.
- New script: `Code/run_pathway_descriptives.R`.
- Extensions to `Code/run_delta_analysis.R` (post-exit LP horizons).
- New RE robustness output: `Analysis/robustness/synthesis.md` and supporting code in either an extension to `run_analysis.R` / `run_county_analysis.R` or a new `Code/run_re_robustness.R`.
- Updates to `Code/create_state_master.R`, `Code/analysis_pre_processing.R`, and re-run of `Code/run_analysis.R` with humidity included.
- New thesis text: `Text/drafts/propagation_pathways.md`.

## Acceptance Criteria
- Never-exposed inventory exported and a short feasibility memo identifies the candidate shock(s) and event(s) for DiD.
- Random-effects estimates and Hausman tests reported for primary state and county specs.
- Post-exit LP horizons (h=0..3) estimated for Drought_Exit, CDD_Exit, HDD_Exit, with plots and synthesis updates.
- DiD outputs (2x2 and Callaway-Sant'Anna) generated with parallel-trends diagnostics.
- PRISM `tdmean` integrated at state level; state regressions re-run; sensitivity of headline findings documented.
- Propagation-pathway document combines cited literature with descriptive figures from existing data.
