# Implementation Plan: Advisor Feedback August 2026

Track spec: `./spec.md`. Origin: advisor meeting, early Aug 2026 (spillovers; AAIW
clustering justification; window/horizon robustness; MAD impulse scaling).

**Sequencing:** All four items are independent of each other and of the essay drafts;
they feed the robustness appendices, so they should land before essay claims freeze
(`thesis_completion_20260704` 2.4/2.5 final passes). 1.2 (clustering note) is
cheapest — mostly writing on existing runs. 1.1 (spillovers) is the only task needing a
new data input (Census county adjacency file). Any contingency that fires propagates to
`Plans/master_evidence_table.md` via `audit_response_20260712` conventions.

---

## Phase 0: Standup

- [x] **0.1 Stand up the track.** Write `spec.md` + `plan.md`; register in
  `conductor/tracks.md`; add to the CLAUDE.md snapshot Active line. Commit. `6f5bb0f`

## Phase 1: The four advisor items

- [x] **1.1 Spatial spillover test (O1).** `40a79ce` *(Verdict: spillovers amplify, not
  confound — own+nbr total exceeds own-only baseline for income/employment, joint
  p≈0.006; own/nbr split unidentified at r≈0.95; dated deviation note in spec.)* Download the Census county adjacency file
  (`Code/download_county_adjacency.R`); build neighbor-shock exposure (share of adjacent
  counties in shock, own excluded) in a pre-processing step; add the term to the headline
  county FE specs (drought→income, drought→debt, cold→employment) in
  `Code/run_spillover_analysis.R`. Tests: adjacency symmetry, own-county exclusion,
  exposure ∈ [0,1], panel uniqueness. Expectation recorded in spec O1.
  Output: `Analysis/advisor_robustness/spillover_results.csv` + synthesis note.
- [x] **1.2 AAIW clustering justification + sensitivity grid (O2).** `550ea2c` *(County
  clustering severely anticonservative as predicted; Conley 200km ≈ state; headlines
  survive all defensible levels — drought income p=.008 even at Conley 300km.)* Methods note applying
  Abadie–Athey–Imbens–Wooldridge (QJE 2023) to this design (state = assignment-correlation
  level, nests rating areas); sensitivity grid county vs state on headline specs,
  cross-referencing the existing Conley and RA-cluster runs. No new primary inference
  level. Output: `Analysis/advisor_robustness/clustering_sensitivity.csv` +
  `clustering_justification.md`.
- [x] **1.3 Backward window extension, BEA outcomes (O3a).** `92c2e3a` *(Stable: PDSI_Lag1
  −99 to −132 across 1990/2000/2011 starts, precision improves with length; forward
  2011–2024 bonus window included; 2011–2023 stays the primary estimand population.)* Re-estimate drought→income
  on the longest feasible pre-2011 BEA window; document regime-boundary caveats; ACS
  outcomes explicitly out of scope. Output:
  `Analysis/advisor_robustness/window_extension_results.csv` + note.
- [x] **1.4 Horizon-choice sensitivity (O3b).** `e066d58` *(No sign flips; h=0–2 moves
  <1 SE under extension; only shortening to K=2 matters (understates cold employment);
  debt scar transient by h=4; cold employment persists h=3–4 (p=.009/.006).)* Parameterize `h_max` in the event-study
  machinery (`Code/run_horizon_sensitivity.R` wrapping/extending `run_event_study.R`);
  run h_max ∈ {2,3,4,5}; table + plot of headline h=0…2 coefficients across h_max, with
  per-run estimation-sample sizes. Output:
  `Analysis/advisor_robustness/horizon_sensitivity.csv` + plot.
- [ ] **1.5 MAD impulse scaling (O4).** Within-county mean absolute deviation of each
  headline outcome (raw year-to-year; residualized variant as secondary); impulse
  coefficients re-expressed as shares of MAD. Output:
  `Analysis/advisor_robustness/mad_scaling_table.csv` + short note; flag for advisor
  confirmation if raw vs residualized diverge.

## Phase 2: Synthesis & propagation

- [ ] **2.1 Synthesis memo.** `Analysis/advisor_robustness/synthesis.md` — one verdict per
  advisor item; explicit statement of whether any headline claim needs qualification.
  Update `Analysis/INDEX.md`.
- [ ] **2.2 Propagation (conditional).** If any contingency fired: dated spec note here,
  evidence-table row updates per `audit_response_20260712` conventions, pointer notes in
  `thesis_completion_20260704` 2.4/2.5. If nothing fired: record "no propagation needed."
- [ ] **Phase 2 checkpoint** — verification gate + git note.
