# Implementation Plan: Mechanisms Section — Second-Reviewer Revision

Track spec: `./spec.md`. Source: `Plans/mechanisms_revision_plan_20260704.md`. Feedback:
`Text/second_reviewer_feedback_mechanisms.md`. Parent: `mechanism_channels_20260625`.

**Status: Phase 0 (setup) not started.** Phases map to the ~3-week sequence. **The organizing trick:
Phase 1's rescaling campaign discharges A2 + B1(leads) + B2(division×year FE) in ONE grid rerun**;
every downstream quantitative task (A1 table, A3 horse-race, C4 corrections) consumes that grid — so
Phase 1 is the critical path and must land before Phase 2/3 numbers.

**Environment:** mechanism reruns + Conley SEs on **R 4.2.2**; the C4 multiple-testing layer
(`wildrwolf`) and the B1 recurring-treatment estimators (`DIDmultiplegtDYN`, `TwoWayFEWeights`) on
**R 4.5.3**. See `spec.md` → Environment.

**Priority tags:** `[MUST]` before recirculation · `[STR]` strengthens · `[DEF]` deferred/declined.

---

## Phase 0: Setup, environment & data acquisition

- [x] **0.1 Stand up the track.** Write `spec.md` + `plan.md`; register in `conductor/tracks.md`.
  Commit. `3683ee4`
- [ ] **0.2 Confirm the rerun surface.** Read `Code/run_mechanism_{agriculture,secondary,medicare,
  provider}.R`; identify every employment spec (level `Civilian_Employed`) that needs rescaling and
  every heat coefficient that needs the division×year-FE column. List them.
- [ ] **0.3 R 4.5.3 packages.** Install `wildrwolf` + `fwildclusterboot` (r-universe `s3alfisc`),
  `DIDmultiplegtDYN`, `TwoWayFEWeights` (CRAN), `mutoss`. Confirm each loads. (Mirror the
  `did_frontier_robustness` install pattern.)
- [ ] **0.4 Pull the two quick-win datasets** (self-documenting scripts, headers cite endpoints):
    - `download_census_sahie.R` → county×year 18–64 uninsured rate + income bands, 2011–2023
      (census.gov/programs-surveys/sahie or Census API) → `Data/intermediate_sahie.rds`.
    - `download_rma_cause_of_loss.R` → county×year drought-cause indemnities from RMA Summary of
      Business (`colsom_2011.zip … colsom_2023.zip` at
      `pubfs-rma.fpac.usda.gov/pub/Web_Data_Files/Summary_of_Business/cause_of_loss/`) →
      `Data/intermediate_rma_indemnity.rds`. Report county-year match rate onto the master.

## Phase 1: Rescaling gate + free text fixes (Week 1 — critical path)

- [ ] **1.1 [MUST] A2 rescaling campaign — the one grid.** Re-run every employment spec with
  **log(Civilian_Employed)** (asinh sensitivity) + **per-1,000-workers**, and in the SAME rerun add
  **F1 lead terms** (B1 placebos) and a **division×year-FE column** (B2 heat-trend). Outputs feed A1,
  A3, C4. Rewrite §6.3 + the energy-burden paragraph in log points. **Fallback pre-commit:** if
  "strengthens" dies in logs, downgrade to "survives" (separability only needs a nonzero low-ag
  effect) and lean on the interaction reading (loads on non-farm exposed share). Test the outcome
  transform + lead alignment.
- [ ] **1.2 [MUST] Free text batch** (no dependencies): A1 soften "runs primarily through" →
  "operates substantially outside agriculture" (§6.6, §6 opener, NBER-response bottom line); C3 IRS
  non-filer caveat (measured out-migration is a *lower bound* → selection share could be larger →
  cuts against scarring); C2 trim the five provider-finance stories to the two evidenced; C1 reframe
  Medicare as a **sentinel population** + the lag-structure-by-channel calendar (winter-t cold →
  Aug-t+1 credit snapshot via 90–180-day collections; reuse the f35bf5f calendar-forensics move); C4
  downgrade every p≈0.05 claim to "suggestive."
- [ ] **1.3 [MUST] B1 event-study figure.** From the existing `Analysis/did/robustness/
  dr_csdid_eventtime.csv` (+ `fixest::i(event_time, treat_cohort, ref=-1)` / LP-DiD for the 2012 2×2).
  State explicitly the 2012 cohort has no testable pre-period (panel starts at its e=−1) — show the
  2012 dynamic post-path + the pooled CS event-study with its disclosed employment pre-trends.
- [ ] **Phase 1 checkpoint** — verification gate + git note.

## Phase 2: New evidence (Week 2 — three parallel lanes)

- [ ] **2.1 [MUST/STR] A3 interaction horse-race** (on the rescaled grid). shock × {Ag_z, Labor_z,
  EnergyBurden_z, SVI_z, **poverty_z, baseline-own-climate_z**} entered jointly, all standardized, +
  a moderator-correlation matrix (appendix). Minimal MUST version: shock×EnergyBurden controlling for
  shock×baseline-CDD + shock×poverty. Read **sign/significance survival, not magnitudes.** **Decide
  energy burden's fate** — if it attenuates, demote to "affordability marker inseparable from
  damage-function curvature" in one paragraph.
- [ ] **2.2 [STR] C4 multiple-testing** (R 4.5.3, on the rescaled grid). Define families **per channel,
  pre-specified**. `wildrwolf::rwolf` (one call/channel; share a `param` via multi-LHS or a regressor
  alias; FWL/`demean` trick if slow) + one hand-rolled **Anderson (2008) index per channel** + sharpened
  q-values (`mutoss::multiple.down`). Expected survivors: heat→ED, AQI→ED, safety-net; expected
  casualties: bottom-tercile cold-emp, migration, cold→debt×Labor. Test the Anderson-index construction.
- [ ] **2.3 [STR] C2 RMA provider-finance test.** drought→indemnity spike (mechanical first stage),
  then **drought × baseline-indemnity-intensity** on uncompensated care (federal-buffer prediction:
  the uncompensated-care rise concentrates in *low*-insurance-participation ag counties). Test the
  merge + the interaction.
- [ ] **2.4 [STR] B1 recurring-treatment robustness** (R 4.5.3). `TwoWayFEWeights::twowayfeweights`
  negative-weight share on the main specs; `DIDmultiplegtDYN::did_multiplegt_dyn` on the **two
  headline pairs only** (cold→log-employment, heat→Medicare). Write one paragraph dispositioning
  Goodman-Bacon / Borusyak–Jaravel–Spiess as staggered-only.
- [ ] **Phase 2 checkpoint** — verification gate + git note.

## Phase 3: Assembly (Week 3)

- [ ] **3.1 [STR] A1 accounting table** (needs A2 + C4 outputs). Columns: overall effect,
  bottom-ag-tercile effect, share reproduced outside agriculture — rescaled units, significant cells
  only, footnote = **upper bound under channel-homogeneity, not a decomposition**. Plus the hedged
  order-of-magnitude compatibility paragraph (NOT the literal $177→1.1pp calibration).
- [ ] **3.2 [STR] B2 harder-FE + Conley columns.** State×year FE where feasible (note premiums die
  mechanically — rating areas are within-state); **Conley SEs** (`fixest::vcov_conley`, county
  centroids in `Data/Geo/`, 200 km triangular primary + 2–3-cutoff robustness) alongside state
  clustering on the heat headlines.
- [ ] **3.3 [STR] C1 SAHIE working-age bridge.** shocks × county 18–64 uninsured share (SAHIE) as the
  working-age moderator, full 2011–2023; CDC PLACES (2018–2023) as a secondary cross-check if cheap.
- [ ] **3.4 [MUST] Rewrite §6 end-to-end** with the new numbers; draft the second-reviewer response
  document; update `Text/reviewer_response_mechanisms_nber.md` and `mechanism_verdict.md`.
- [ ] **Phase 3 checkpoint** — verification gate + git note.

---

### Notes / lessons (live)

- **This track revises `mechanism_channels_20260625` §6** — keep `mechanism_verdict.md` (already
  correctly hedged) as the template for the softened §6.6 language.
- **Concede, don't fight:** energy burden (A3), "runs primarily through" (A1), migration p=0.047 (C3).
- **The A1 back-of-envelope is a trap** — Medicare 65+ dollars → working-age credit-bureau debt needs
  three order-of-magnitude-uncertain free parameters; hedged compatibility paragraph or decline.
- **Recurring binary treatment ≠ staggered adoption:** most modern DiD-robustness tools (Goodman-Bacon,
  Borusyak–Jaravel–Spiess, `sunab`) are staggered-only; use the de Chaisemartin–D'Haultfœuille family
  (`twowayfeweights`, `did_multiplegt_dyn`) — say so explicitly rather than omitting them.
- **B2 is heat-only:** cold/drought are anti-fragile (warming → rarer cold → attenuation). Frame the
  concession as targeted, not general.
- Reference appendix (packages, citations, data endpoints) lives in
  `Plans/mechanisms_revision_plan_20260704.md`.
