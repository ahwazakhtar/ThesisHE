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

**Coordination note (2026-07-12):** `audit_response_20260712` (from
`Plans/project_audit_research_questions_20260712.md`) now owns the claim-architecture layer:
master evidence table, full-scope abstract rewrite, and the Essay-3 framing memo update. Its
evidence table is the claim source of truth for 2.4/2.5; its task 1.4 (table refresh) is
blocked on 2.2 here; T1.3 component (a) is amended (dated note in `spec.md`).

**Environment reminder:** T0.1–T0.2 and T2.2 run on **R 4.5.3**
(`C:/Program Files/R/R-4.5.3/bin/Rscript.exe`); everything else on **R 4.2.2**. See `spec.md`.

---

## Phase 0: Track setup & scoping

- [x] **0.1 Stand up the track.** Write `spec.md` + `plan.md`; register in
  `conductor/tracks.md`; confirm both R toolchains and the existing script inventory
  (`Code/did_robustness/*` present; `run_demographic_mediators.R` present; mortality/policy/
  pass-through scripts are net-new). Commit the scaffolding. `60f7c85`
- [x] **0.2 Verify the wild-bootstrap script is runnable as-is.** Read
  `Code/did_robustness/01_wild_cluster_bootstrap.R`; confirmed it **already** uses the
  FWL-demeaned residual model (`fixest::demean` on both `y` and `TxP`, then `boottest` /
  `.lm.fit` on the 1-regressor residual model) — NOT `boottest` on the full 3,155-FE model.
  No fix needed; runnable as-is. `60f7c85`

## Phase 1: Tier 0 — inference protection & identification hardening (~2–3 weeks)

- [x] **1.1 Run few-treated-cluster inference (T0.1).** Ran
  `Code/did_robustness/01_wild_cluster_bootstrap.R` on R 4.5.3 (exit 0). **The income headline
  survives:** PCPI_Real ATT −$1,311, p_analytic 0.028, **p_wcb 0.036, p_ri 0.0075**, WCB CI
  [−2,911, −138] (excludes 0). Employment clears the few-cluster bar too (p_wcb 0.003, p_ri
  0.037) but stays caveated on conditioning/generalization; the two null outcomes stay null.
  This *confirmed* rather than weakened the one open econometric exposure. Marked
  `did_frontier_robustness_20260625` Phase 1 `[x]`. `fdc0a25`
- [x] **1.2 Close the DiD frontier track (T0.2).**
    - Ran `04_synthesize_did_robustness.R` → `Analysis/did/robustness/did_robustness_summary.md`
      (collates WCB/RI + DRDID + HonestDiD).
    - Folded the bootstrap p-values into `Text/technical_note/technical_note_empirical_framework.{html,tex}`
      as §2.5.4 (few-treated-cluster note). *Left uncommitted — author has a concurrent edit in
      those files.*
    - Wrote `Code/tests/test_did_robustness.R` (5 tests, all pass on R 4.2.2).
    - Marked `did_frontier_robustness_20260625` Phases 4 & 5 `[x]`; that track is effectively
      closed (only the optional de Chaisemartin estimator remains → T3.2 below). `fdc0a25`
- [x] **1.3 Extend the 2012 DiD pre-period with BEA income (T0.3).** Built
  `Code/did_robustness/05_bea_pretrends_1990_2011.R` (R 4.2.2, no frontier package). Coverage is
  excellent: all 139 treated + 2,483/2,534 control counties have PCPI every year 1990–2011 (21
  pre-periods). **Result — linear differential pre-trend −$69/yr (SE 89, p=0.44): flat** (the
  DiD-relevant threat is absent). Event-study joint Wald rejects (F=6.9, p<0.001) = modest
  business-cycle rural-vs-urban wiggle, not secular drift — the composition DRDID conditions on
  (and which *strengthens* the effect to −$1,451). Figure shows parallel pre-2012 trajectories
  diverging after onset. Outputs: `bea_pretrends_1990_2011.{csv,png}` + build log. Technical-note
  §2.5.5 paragraph added (uncommitted, author's file). Test `Code/tests/test_bea_pretrends.R`
  passes (FIPS-padding trap, strict ≤2011 window, 139/2534 cohort match). `dcec119`
- [x] **1.4 Draft the committee memo on Chapter 3 (T0.4).** Wrote
  `Text/correspondence/committee_memo_ch3_structure.md`: boxed decision question (does the three-essay structure
  replace the structural Ch.3?), the proposal→now evolution, the sufficient-statistics section
  offered as the bounded policy substitute, plus disclosures (hazard demotion; unestimated
  premium→debt mediation). `2a2e826` **RESOLVED 2026-07-13: the committee approved the
  three-essay structure; the structural Ch.3 is not required.** T1.3 (sufficient-statistics
  policy section) proceeds as the policy content per the author's writing plan §9
  (`Plans/dissertation_writing_and_framing_plan_20260712.md`); memo question 2 (Essay-3
  framing) is settled by that plan's §8 hybrid framing — sending the memo is now optional.
- [~] **1.5 Housekeeping (T0.5).**
    - [x] Deleted 25 stray `*.tmp.*` editor swap artifacts across `Code/`, `Text/`, `conductor/`
      (all untracked; verified clean).
    - [~] **`[TK]` baseline denominators — computed, handed to author to insert.** Candidate
      full-sample baselines (2014–2023 Medicare; 2011–2023 county master): Medicare std payment
      **$10,359/beneficiary** (bene-wtd) → $112/$177/$75 = **1.1% / 1.7% / 0.7%**; ED visits
      **629 per 1,000** → 7.8/9.5 = **1.2% / 1.5%**; mean county employment **50,113**; mean PCPI
      **$46,269**. **NOT auto-inserted into `reviewer_response_mechanisms_nber.md`:** the −2,011
      (bottom-ag-tercile) and −1,380 (high-energy-burden) employment effects are estimated in
      *subsamples* of small rural counties, so their correct denominator is the subsample mean,
      not the 50,113 overall mean — the author should confirm the intended base per marker.
    - [ ] Complete the two references (Audi et al. 2024–25 — FEMA hurricane risk × hospital
      financial ratio; Doremus et al. 2022 — energy-burden/affordability adaptation). Need the
      author's exact citations; not guessed.
    - [x] Work through the open Conductor verification gates (human sign-off checklists).
      *(Author ran and confirmed all outstanding gates 2026-07-13; closed in batch —
      checkpoints `dbdcdf2`/`c1afd75`/`1eb23a6` (audit_response Phases 1–3), `14c7bcb`
      (mechanisms_revision Phases 1–3), `001698f` (six completed tracks). Still open by
      design: audit_response final gate (Phase 5 pending), policy_microsim gate (behind
      Gate A).)*
- [ ] **Phase 1 checkpoint** — verification gate + git note.

## Phase 2: Tier 1 — write, and add stakes (~2–3 months)

- [x] **2.1 Premium pass-through / mediation (T1.1).** Built `Code/run_premium_mediation.R`
  (R 4.2.2) with tested helpers `add_shock_lags` / `mediation_decompose`.
    - **(i) Pass-through — TWO corrections applied. Final verdict: NO COHERENT pass-through.**
      (1) rate-filing timing → lagged shocks only (t-2 primary); (2) a **Fable econometric review**
      caught that the county+Year-FE spec is confounded (≈86% of premium variance is state×year;
      rates set at rating-area level, reviewed per state), and that adding State×Year FE
      *over-absorbs* (any legal statewide pass-through lives in the deleted state×year cell) — so
      "collapse ⇒ confound" is an invalid inference. Re-specified as a **two-level decomposition**:
      **PRIMARY rating-area×year** (RA + State^Year FE, pop-wtd, state-clustered) — within-state
      local margin; **SECONDARY state×year** (State+Year FE) — between-state; county specs kept as a
      labeled **transparency trail** (misspecified). Result: **the cold t-2 coefficient flips sign
      across levels** (−$15.5 county → +$12.6 RA → −$16.7 state) and so does heat (+$19.5 → −$10.5 →
      +$93) — sign-instability = no stable price response. Within-state estimates are small (few % of
      $375) and incoherent; between-state heat is large (+$54–93/mo = 14–25%) but ~10× too big for a
      claims channel and cold's sign is backwards vs the project's own Medicare result (cold RAISES
      spending) → temperature-anomaly correlate of premium *levels*, not pricing. Drought null
      everywhere. Grounded in single statewide risk pool + unit-cost-only geographic factor + Part
      153 risk adjustment. The earlier "only heat passes through / cold negative" reading is
      **retracted** as a county-spec artifact.
    - **(ii) Mediation:** **92% (cold, lag1) to 99% (drought, lag2) of the shock→medical-debt
      effect survives premium adjustment** — now framed as the *corollary* of the null/incoherent
      first stage (no premium channel to travel through), sharpening the located unpriced margin.
      Difference-method (not causal); premiums RA-level (lower bound); marketplace-era 2014–2025.
      Added the cross-level asymmetry caveat (State^Year FE is right for the state-set premium, NOT
      for household outcomes — cross-ref `cross_level_symmetry`).
    - Bugs fixed en route (Fable review): **484 duplicate county-year rows** (split counties)
      deduped as a T1.2 stopgap; **≤2023 filter dropped 2024–25 premiums** — extended to 2025; the
      `| p_ra < 0.05` significance cherry-pick removed (state clustering primary). CLAUDE.md master
      dims are stale (now 119,300 rows, 1990–2026) — fix at session end.
    - Outputs: `Analysis/mediation/{premium_passthrough,debt_mediation}.csv` (4 specs) +
      `premium_mediation_summary.md`; rewritten NBER write-up `Text/drafts/premium_mediation_writeup.md`.
      Tests (identity + lag alignment + same-sample + generalized `group` param) pass. `4de9e39`+fix
- [x] **2.2 Data-integrity fix (T1.2).** (`fca5643` — 484 groups/568 rows collapsed; unweighted-mean
  RA rule with committee-defense docs in the script header + `Analysis/county_dedup_integrity.md`;
  2012 DiD identical, debt cells <0.08 SE, pass-through verdict holds; build now asserts
  uniqueness; pre-dedup backup archived. Follow-up flagged: re-point the mediation RA panel at
  `premiums_county.csv`; ~25 raw-reading consumers pick up the dedup on next run.) Enforce one-row-per-county-year in
  `Code/create_county_master.R` upstream (resolve the ~3% multi-rating-area duplicates once,
  with a documented rule); add a build-time assertion (`stopifnot` uniqueness on fips×year).
    - Re-run `run_county_analysis.R` + the DiD/RE scripts; confirm coefficients are materially
      unchanged; log the before/after in `Analysis/county_dedup_integrity.md`.
    - **Test:** `testthat` — master is unique on (fips_code, year); row count within expected
      band.
    - **Also:** mark the `county_analysis_refinement_20260216` deferred one-row task `[x]`.
- [x] **2.2b Wet-shock bin (T1.6, reviewer-demanded; pre-spec frozen `d0a90a7` BEFORE code).**
  **HONEST NULL: 0/12 cells at BKY q<0.10** (best: Med_HH_Income L1 −$220, p=.021, q=.254 —
  directionally consistent with the documented swing effect); expectation held; incidence
  14.9%, year-clustered (2018 42%). Evidence-table Row 29; reviewer paragraph in
  `Analysis/wet_shock/wet_shock_summary.md`. 11/11 tests (verified independently).
- [x] **2.3 Sufficient-statistics policy section (T1.3).** (Code `4cffca7`: 5 scenario bands,
  drought unpriced floor 21–50% / $23–88 per member-yr, cold-band concentration 2.4×, RMA
  ratio 3.7×; 9/9 tests, anchor-locked. Write-up: `Text/drafts/policy_section.md`, 4,315
  words, NBER-styled, permitted-language-bound; moved from Text/ root per house rule.
  Author items: confirm the heat-benchmark framing of the drought bound; Figure P1 (Lorenz)
  still to generate from `concentration_curve.csv`; exhibit labels placeholder.) New
  `Code/run_policy_sufficient_stats.R` (R 4.2.2). *(Amended 2026-07-12 — see spec note: T1.1
  found no coherent pass-through, so premium coefficients are NOT stable sufficient statistics.)*
    - (a) **Unpriced margin (re-based):** Medicare morbidity cost response × exposed
      beneficiaries → the measured cost that fails to appear in premiums, bounded by the
      `audit_response_20260712` 2.1 MDE/equivalence result. Do NOT aggregate premium lag
      coefficients into mispricing dollars.
    - (b) **Aggregate scars — scenario bands, not one national total:** 2012-style-event band,
      typical recurring-shock band, direct-Medicare band; cold-compounding job losses ×
      dose-bin county counts; drought debt scar × exposed population; honest error bands.
      A national causal welfare total is not claimed off an event-specific coefficient.
    - (c) **Targeting:** top-decile counties' share of total harm (SVI + energy-burden weighted).
    - **Outputs:** `Analysis/policy/sufficient_stats.csv`; `Text/policy_section.md` (NBER style).
    - **Test:** `testthat` — aggregation sums reconcile to per-unit estimates; error bands
      propagate the coefficient SEs.
- [~] **2.4 Essay 1 full draft (T1.4).** *(Started 2026-08-13: stood up `Text/final_writing/`
  — drafting workflow (`WORKFLOW.md`), fresh-eyes review protocol (`review_protocol.md`), and
  the full paragraph-level `essay1_outline.md` (claims keyed to master-evidence-table rows,
  exhibits to the registry, advisor-robustness additions placed). Author writes the prose in
  their own words into `essay1_draft.md`; Claude outlines + orchestrates agent reviews only.
  Draft output location amended: `Text/final_writing/essay1_draft.md` (supersedes the
  `Text/essay1_incidence_draft.md` path below). Two pre-drafting author decisions flagged in
  the outline: the untraced $18 ESI figure (drop recommended) and the drought→debt 0.7-pp
  level choice.)* **Gated on `audit_response_20260712` 1.1–1.2** (the
  master evidence table `Plans/master_evidence_table.md` is the claim source of truth; the
  abstracts must already be reconciled). Assemble the job-market paper from existing parts
  (`Text/drafts/thesis_paper_abstracts.md`, `technical_note_empirical_framework`, `mechanisms_section.md`,
  reviewer responses, decks) using the `nber-economist-writing-style` skill. Lead with income,
  caveat employment, frame debt as measurement, lead mechanisms with morbidity + labor exposure.
  **Re-audit guidance (Jul 12):** (i) the abstracts are accurate but dense — in the full draft,
  unpack sentences that carry identification + population + estimate + robustness + caveat all
  at once; (ii) present Medicare morbidity as *parallel direct evidence* of a channel, never as
  mediating the 2012 income result; (iii) keep the ACA null hazard-specific (drought tightly
  bounded at >50–79% of the morbidity benchmark; heat/cold only loosely).
  **Advisor-robustness guidance (Aug 7, `advisor_feedback_20260807`):** the robustness
  appendix has four ready subsections in `Analysis/advisor_robustness/` (spillovers,
  AAIW inference levels, window/horizon, MAD scaling — see its `synthesis.md`); use the
  spillover qualifier "county coefficients capture local exposure; adjacent-county
  exposure adds a same-signed regional component the local coefficient understates";
  the clustering note is the inference-methods paragraph (AAIW-cited).
  **Output:** `Text/essay1_incidence_draft.md` (or `.tex`).
- [ ] **2.5 Essays 2 & 3 full drafts (T1.5).** Reuse Essay 1's data/methods sections. Essay 3's
  framing gate is **lifted (2026-07-13)**: hybrid "distribution + observability" spine per
  `Plans/dissertation_writing_and_framing_plan_20260712.md` §8 (audit_response 1.3).
  **Re-audit guidance (Jul 12) for Essay 2:** the cold-compounding estimator dependence
  (binned contrast + CS DiD vs the flat smooth quadratic) must be central in the headline
  table and conclusion, not only disclosed in the abstract.
  **Advisor-robustness guidance (Aug 7):** Essay 2 persistence claims gain the horizon
  refinements (debt scar transient by h=4; cold employment persists h=3–4, p=.009/.006;
  too-short windows *understate* cold compounding) — `Analysis/advisor_robustness/`.
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
- **ACA premium pass-through: TWO binding design rules (T1.1 lessons).**
  (a) *Rate-filing timing* — plan-year-t rates are filed ~mid-t-1 on experience through ~t-2 and
  locked before the plan year (no mid-year re-rating), so a shock→premium regression must use
  **lagged shocks only** (t-2 primary); a contemporaneous shock is not in the insurer info set.
  (b) *Level of analysis* — ACA premiums are NOT a county object: they are set at the rating-area
  level, reviewed per state, and **≈86% of premium variance is state×year**. A county+Year-FE
  premium regression is confounded (state-year premium dynamics load onto county shocks), and
  adding State×Year FE **over-absorbs** (legal statewide pass-through lives in the deleted cell) —
  so "collapse under State×Year FE ⇒ confound" is an *invalid* inference. Estimate at the levels
  the institutions use: **rating-area×year** (within-state, primary) and **state×year** (between-
  state, secondary); treat county specs as a transparency trail only. Verdict: **no coherent
  pass-through** — coefficients flip sign across levels; between-state heat is too large + cold
  mis-signed vs the Medicare morbidity result. Cluster on **state** (not RA — RA understates SEs
  for state-level shocks). This over-rode the earlier "only heat passes through" reading.
