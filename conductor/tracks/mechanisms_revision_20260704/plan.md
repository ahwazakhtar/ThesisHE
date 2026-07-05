# Implementation Plan: Mechanisms Section — Second-Reviewer Revision

Track spec: `./spec.md`. Source: `Plans/mechanisms_revision_plan_20260704.md`. Feedback:
`Text/second_reviewer_feedback_mechanisms.md`. Parent: `mechanism_channels_20260625`.

**Status: Phase 1 COMPLETE (2026-07-05; 1.1–1.3 done, checkpoint pending). Phase 2 next.** Phases map
to the ~3-week sequence. **The organizing trick:
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
- [x] **0.2 Confirm the rerun surface.** Read the four `run_mechanism_*.R`. Map below. `6861d90`
    - **A2 (log employment) — two scripts:** `run_mechanism_agriculture.R` (`outcomes` L70,
      `Civilian_Employed` a level; carries the −2,011-vs-−721 bottom-ag subsample AND the CDD×Labor_z
      ≈ −689 interaction) and `run_mechanism_secondary.R` (`en_outcomes` L65; carries the
      CDD×EnergyBurden_z ≈ −1,380 interaction). Income/debt outcomes are already scale-free.
    - **B2 (division×year FE on heat) — all four, priority heat headlines:** heat→Medicare
      (`run_mechanism_medicare.R`, outcomes `Mdcr_Std_Payment_PC`/`ER_Visits_per1000` — the key
      survival test), heat→employment interactions (ag CDD×Labor_z; secondary CDD×EnergyBurden_z),
      heat×safety-net→uncompensated care (`run_mechanism_provider.R`, outcomes `Hosp_UncompCare_*`).
    - **B1 two headline pairs:** cold→log-employment (agriculture) + heat→Medicare (medicare).
    - **A3 horse-race locus:** `run_mechanism_secondary.R` (energy burden) — add `poverty_z` +
      baseline-own-climate_z alongside the existing `EnergyBurden_z`/`Ag_z`/`Labor_z`/`SVI_static`
      (need to source poverty + baseline-CDD normals — check master/intermediates in 2.1).
    - **C4 channel families:** morbidity=medicare, labor=agriculture(employment), energy=secondary,
      provider=provider.
    - **Convention note:** mechanism scripts lag as `_Lag1`/`_Lag2` (NOT `_L1`/`_L2`); these already
      exist in the master. **F1 LEADS do not exist** — construct `*_Lead1` in the 1.1 rerun. Specs
      per script: overall / interaction(shock×moderator_z) / bottom-tercile subsample; all
      `feols(... | fips_code + Year, cluster="State")`.
- [x] **0.3 R 4.5.3 packages.** `wildrwolf`, `DIDmultiplegtDYN`, `TwoWayFEWeights` all install and
  **LOAD** (`fwildclusterboot` was already present; `wildrwolf` also needed `fabricatr` from CRAN).
  **`mutoss` does NOT load** — it depends on Bioconductor's `multtest` (not CRAN). Not worth the
  Bioconductor install: use base-R `p.adjust(., "BY")` (Benjamini–Yekutieli) + a hand-rolled BKY
  two-stage for Anderson's sharpened q-values in C4. `6861d90`
- [x] **0.4 Pulled the two quick-win datasets** (keyless/keyed; self-documenting; log to build_logs):
    - `download_census_sahie.R` → `Data/intermediate_sahie.rds`: county×year 18–64 uninsured
      (`Uninsured_18_64` all-income + `Uninsured_18_64_le138FPL` low-income proxy), Census SAHIE API
      (AGECAT=1, PCTUI_PT), CENSUS_API_KEY. **40,855 county-years, full 2011–2023 (incl. 2023),
      match 97.6%** of master county-years (gap = CT planning-region/AK FIPS churn). Mean 18–64
      uninsured 15.5%.
    - `download_rma_cause_of_loss.R` → `Data/intermediate_rma_indemnity.rds`: county×year
      `Drought_Indemnity` / `Total_Indemnity` / `Drought_Indemnity_Share` / `Drought_Liability` from
      RMA COL ZIPs (col map verified via loss-ratio identity — indemnity = col29). **35,523
      county-years, 2011–2023, drought indemnity in 25,429; match 83.9%** of master (expected <100 —
      only crop-loss county-years have rows; non-loss = NA→0 on join).
    - Both `.rds` are gitignored (regenerate from the scripts). `6861d90`

## Phase 1: Rescaling gate + free text fixes (Week 1 — critical path)

- [x] **1.1 [MUST] A2 rescaling campaign — the one grid.** Built
  `Code/run_mechanism_employment_rescaled.R` (log/asinh/per-1000 employment + F1 leads + division×year
  FE), tested helper `add_shock_leads` + transforms. Output `employment_rescaled_coefs.csv` (450 rows).
  **FALLBACK TRIGGERED — the reviewer was right:**
    - **A2:** cold→employment "strengthening" **dies in logs** — neither overall nor bottom-ag-tercile
      is significant (all |est|<0.5 log-pts, p>0.15). The level −2,011-vs−721 was a county-size
      artifact. → §6.3 rewritten to REST ON THE INTERACTION, not the cold subsample.
    - **The labor channel survives via interactions (robust):** heat→emp loads on exposed-industry
      share (CDD×Labor_z **−0.0052, p=0.006**) and energy burden (CDD×EnergyBurden_z **−0.0084,
      p=0.005**), **both survive division×year FE** (−0.0042/−0.0078, p=0.015/0.002 — clears B2 for
      these results). Energy-burden interaction surviving div×yr FE is a point in its favor ahead of
      the A3 horse-race.
    - **B1 leads:** cold null (pass); heat marginal (p=0.09, mild trend); **drought lead FAILS
      (p=0.005)** — drought persistence, escalates the Phase-2 recurring-treatment work (2.4).
    - **Cascade:** cold→employment is no longer a significant *overall* cell in logs → drop it from
      the A1 accounting table (3.1) significant-cells set; it is also a C4 casualty to pre-concede
      (2.2). §6.3 done; the **energy-burden paragraph (§6.5) rewrite waits on A3 (2.1)**. `ddfc448`
- [x] **1.2 [MUST] Free text batch.** All five edits made across `mechanisms_section.md` +
  `reviewer_response_mechanisms_nber.md`: A1 softened ("operates substantially outside agriculture",
  reframed as a *bound* not a share; removed the antithetical "is not" epigram) in §6 opener, §6.6,
  and the NBER answer + bottom line; C1 Medicare **sentinel** reframe + lag-structure-by-channel
  calendar (cold→debt t+1 via Aug credit snapshot; Medicare t+2 sequelae) in §6.2; C2 provider stories
  trimmed 5→2 evidenced (federal buffers — crop-insurance leg testable; revenue-positive utilization),
  rest set aside as untested; C3 IRS non-filer caveat (out-migration a lower bound → selection share
  understated → strengthens the anti-scarring caveat); C4 migration p=0.05 → "suggestive." `885fbea`
- [x] **1.3 [MUST] B1 event-study figure.** `Code/plot_did_eventstudy.R` →
  `Analysis/mechanism/plots/did_eventstudy_pooled.png`: pooled CS-dr dynamic event-study (income +
  employment, e∈[−6,6], 95% CI) from the existing `dr_csdid_eventtime.csv`. Caption states the 2012
  cohort has no testable pre-period (leads come from 2013/2021/2022 cohorts). Figure shows both
  real-economy outcomes rising *post*-onset in the pooled average (the disclosed "2012 doesn't
  generalize" result) with the mild positive employment pre-trend visible. `187f84b`
- [ ] **Phase 1 checkpoint** — verification gate + git note. *(All three Phase-1 tasks complete;
  awaiting user sign-off. Then Phase 2.)*

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
  q-values (base-R `p.adjust(.,"BY")` + hand-rolled BKY two-stage — `mutoss` needs Bioconductor, see
  0.3). Expected survivors: heat→ED, AQI→ED, safety-net; expected
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
