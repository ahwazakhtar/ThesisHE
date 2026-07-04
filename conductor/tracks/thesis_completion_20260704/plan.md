# Implementation Plan: Thesis Completion — Roadmap Execution

Track spec: `./spec.md`. Source: `Plans/roadmap_recommendations_20260704.md`.

**Status: Phase 0 in progress (track stood up 2026-07-04).** This is the master-execution
track for the final thesis push. Overlapping items drive existing tracks to closure rather
than duplicating them: **T0.1–T0.2** close `did_frontier_robustness_20260625` (Phases 1, 4,
5); **T1.2** closes the `county_analysis_refinement_20260216` deferred one-row-per-county-year
item. Update *both* `plan.md` files when those complete.

**Sequencing rule:** Tier 0 before Tier 1 before Tier 2. Within Tier 1, T1.1 (mediation) and
T1.2 (data integrity) land *before/inside* essay writing (T1.4); T1.3 (policy section) can run
in parallel with essay drafting. Tier 2 is gated on Tier-1 drafts existing.

**Environment reminder:** T0.1–T0.2 and T2.2 run on **R 4.5.3**
(`C:/Program Files/R/R-4.5.3/bin/Rscript.exe`); everything else on **R 4.2.2**. See `spec.md`.

---

## Phase 0: Track setup & scoping

- [ ] **0.1 Stand up the track.** Write `spec.md` + `plan.md`; register in
  `conductor/tracks.md`; confirm both R toolchains and the existing script inventory
  (`Code/did_robustness/*` present; `run_demographic_mediators.R` present; mortality/policy/
  pass-through scripts are net-new). Commit the scaffolding.
- [ ] **0.2 Verify the wild-bootstrap script is runnable as-is.** Read
  `Code/did_robustness/01_wild_cluster_bootstrap.R`; confirm it uses the FWL-demeaned residual
  model (NOT `boottest` on the full 3,155-FE model, which hung and caused the cancelled run).
  If it still has the naive full-FE call, apply the `fixest::demean` (FWL) fix before running.

## Phase 1: Tier 0 — inference protection & identification hardening (~2–3 weeks)

- [ ] **1.1 Run few-treated-cluster inference (T0.1).** Execute
  `Code/did_robustness/01_wild_cluster_bootstrap.R` on R 4.5.3.
    - Wild cluster bootstrap-t (Webb, B=9999, null imposed) via `fwildclusterboot::boottest`
      on the FWL-residualized 2×2; Fisher randomization inference (N=2000 placebo re-draws of
      the 139 treated labels). Outcomes: PCPI_Real, Civilian_Employed, Med_HH_Income_Real,
      Medical_Debt_Share.
    - **Output:** `Analysis/did/robustness/wild_bootstrap_2x2.csv`.
    - **Acceptance:** report `p_analytic` vs `p_wcb_webb` vs `p_randinf`; state whether income
      (and employment) still clear 0.05 under the corrections.
    - **Also:** mark `did_frontier_robustness_20260625` Phase 1 `[x]`.
- [ ] **1.2 Close the DiD frontier track (T0.2).**
    - Run `Code/did_robustness/04_synthesize_did_robustness.R` →
      `Analysis/did/robustness/did_robustness_summary.md`.
    - Fold the bootstrap p-values into `Text/technical_note_empirical_framework.{html,tex}`
      §2.5 (the DRDID subsection is already there; add the wild-bootstrap line and decide on a
      short HonestDiD limitation line).
    - Write `Code/tests/test_did_robustness.R` (testthat): cohort construction matches
      `run_did_analysis.R`; FWL-residualized point estimate equals the full-FE `feols` ATT;
      randomization placebo distribution centers on 0; baseline covariates strictly 2011.
    - **Also:** mark `did_frontier_robustness_20260625` Phases 4 & 5 `[x]`; close that track.
- [ ] **1.3 Extend the 2012 DiD pre-period with BEA income (T0.3).**
    - New `Code/did_robustness/05_bea_pretrends_1990_2011.R` (R 4.5.3, or 4.2.2 if it needs no
      frontier package): pull county PCPI 1990–2011 from the socioeconomic intermediate; label
      treated (first-onset-2012 cohort, mirroring `00_did_robustness_common.R`) vs never-exposed;
      plot mean PCPI trajectories and estimate a pre-trend slope difference (event-study on
      pre-periods, or treated×year interactions 1990–2011).
    - **Outputs:** `Analysis/did/robustness/bea_pretrends_1990_2011.csv` + a figure under
      `Analysis/did/robustness/`.
    - **Acceptance:** figure + parallel-pre-trend test (slope difference, SE, p); one paragraph
      in the technical note stating whether the two-decade pre-trends are parallel.
    - **Test:** `testthat` — treated/never-exposed cohort sizes match the DiD cohort; pre-period
      window is strictly ≤2011.
- [ ] **1.4 Draft the committee memo on Chapter 3 (T0.4).** Write
  `Text/committee_memo_ch3_structure.md`: state the Incidence/Persistence/Inequality structure,
  ask for explicit sign-off that it replaces the structural model, and offer the
  sufficient-statistics section (T1.3) as the scaled-down policy component. **Hand to the
  author to send — user-decision gate; do not proceed to assume the answer.**
- [ ] **1.5 Housekeeping (T0.5).**
    - Fix the two incomplete references (Audi et al. 2024–25; Doremus et al. 2022) and the two
      `[TK]` baseline denominators in the reviewer-response file.
    - Delete stray `*.tmp.*` artifacts in `Code/`, `Text/`, `conductor/`.
    - Work through the open Conductor verification gates (checklists, not analysis — batch them).
- [ ] **Phase 1 checkpoint** — verification gate + git note.

## Phase 2: Tier 1 — write, and add stakes (~2–3 months)

- [ ] **2.1 Premium pass-through / mediation (T1.1).** New
  `Code/run_premium_mediation.R` (R 4.2.2): (i) shock → benchmark premium pass-through ρ
  (lagged claims-relevant shocks → `Benchmark_Silver_Real`, county+year FE, state-clustered,
  rating-area-clustered variant); (ii) medical-debt share with/without premium controls →
  fraction-of-effect-surviving decomposition (reuse `run_demographic_mediators.R` helpers).
    - **Outputs:** `Analysis/mediation/premium_passthrough.csv`, `debt_mediation.csv`; a
      write-up paragraph.
    - **Test:** `testthat` — decomposition identity (total = mediated + direct) holds; lag
      alignment correct.
- [ ] **2.2 Data-integrity fix (T1.2).** Enforce one-row-per-county-year in
  `Code/create_county_master.R` upstream (resolve the ~3% multi-rating-area duplicates once,
  with a documented rule); add a build-time assertion (`stopifnot` uniqueness on fips×year).
    - Re-run `run_county_analysis.R` + the DiD/RE scripts; confirm coefficients are materially
      unchanged; log the before/after in `Analysis/county_dedup_integrity.md`.
    - **Test:** `testthat` — master is unique on (fips_code, year); row count within expected
      band.
    - **Also:** mark the `county_analysis_refinement_20260216` deferred one-row task `[x]`.
- [ ] **2.3 Sufficient-statistics policy section (T1.3).** New
  `Code/run_policy_sufficient_stats.R` (R 4.2.2):
    - (a) **Unpriced margin:** premium lag responses × exposed enrollment → aggregate mispricing $.
    - (b) **Aggregate scars:** cold-compounding job losses × dose-bin county counts; drought
      debt scar × exposed population → national annual burden with honest error bands.
    - (c) **Targeting:** top-decile counties' share of total harm (SVI + energy-burden weighted).
    - **Outputs:** `Analysis/policy/sufficient_stats.csv`; `Text/policy_section.md` (NBER style).
    - **Test:** `testthat` — aggregation sums reconcile to per-unit estimates; error bands
      propagate the coefficient SEs.
- [ ] **2.4 Essay 1 full draft (T1.4).** Assemble the job-market paper from existing parts
  (`Text/thesis_paper_abstracts.md`, `technical_note_empirical_framework`, `mechanisms_section.md`,
  reviewer responses, decks) using the `nber-economist-writing-style` skill. Lead with income,
  caveat employment, frame debt as measurement, lead mechanisms with morbidity + labor exposure.
  **Output:** `Text/essay1_incidence_draft.md` (or `.tex`).
- [ ] **2.5 Essays 2 & 3 full drafts (T1.5).** Reuse Essay 1's data/methods sections.
  **Outputs:** `Text/essay2_persistence_draft.md`, `Text/essay3_inequality_draft.md`.
- [ ] **Phase 2 checkpoint** — verification gate + git note.

## Phase 3: Tier 2 — optional depth (only after Tier-1 drafts exist; committee-demand-gated)

- [ ] **3.1 County mortality from CDC WONDER (T2.1).** New pipeline
  `download_county_mortality.R` → `process_county_mortality.R` → intermediate; add all-cause +
  cardiovascular/respiratory mortality as an outcome family in a mortality analysis script vs
  the four shocks. Reproduce the Barreca/Deryugina benchmark in-panel. Tests + write-up.
- [ ] **3.2 Recurring-treatment frontier estimator (T2.2).** New
  `Code/did_robustness/06_recurring_treatment.R` (R 4.5.3): de Chaisemartin–D'Haultfœuille
  `did_multiplegt_dyn` (or Borusyak–Jaravel–Spiess), income outcome only, to address the
  on/off estimand directly. Compare to the first-onset 2×2. Tests + write-up.
- [ ] **3.3 Hospital closures hazard model (T2.3).** New
  `Code/run_hospital_closures.R` (R 4.2.2): derive closure events from CCN exit in the NASHP
  hospital-year panel; shock → closure-hazard model. Guard reverse causality (closures → local
  economy). Tests + write-up.
- [ ] **Phase 3 checkpoint** — verification gate + git note.

---

### Notes / lessons (live)

- **This track coordinates; it does not re-own.** T0.1–T0.2 execute the *existing*
  `Code/did_robustness/` scripts and close `did_frontier_robustness_20260625`. T1.2 closes the
  `county_analysis_refinement` deferred item. Keep both plan.mds in sync.
- **Two-R-version boundary.** T0.1–T0.2 and T2.2 on R 4.5.3; all else on R 4.2.2. Every
  frontier script header states which R it needs.
- **Writing is the binding constraint.** Do not let Tier 2 econometrics onto the critical path
  before the Tier-1 essay drafts exist.
- **Author-decision gates:** T0.4 (Ch. 3 structure) is not something this track can answer —
  it drafts the memo and waits. T1.3 is the hedge if the committee still wants policy content.
