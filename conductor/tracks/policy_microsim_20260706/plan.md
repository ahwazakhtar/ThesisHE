# Implementation Plan: Policy Frontier — Sufficient-Statistics Microsimulation

Track spec: `./spec.md`. Source planning documents: `Plans/frontier_extensions_plan.md`
(tiered roadmap), `Plans/results_evolution_narrative.md` (which claims are calibration-grade
survivors), `Plans/methods_retrospective.md` (discipline rules + open methodological threads).

Sequencing: Phase 0 (hygiene) unblocks everything and is cheap. Phase 1 is the committee
memo's own bounded deliverable and proceeds regardless of the committee's answer. **Gate A**
(committee decision) sits between Phases 1 and 2. Phases 2→3→4 are strictly sequential
(data gate → elasticities → engine). Phase 5 is optional (**Gate B**). Phase 6 closes out.

**Audit note (2026-07-12):** `Plans/project_audit_research_questions_20260712.md` rates the
full microsimulation low/negative alpha *before Tier-1 essay drafts exist* — consistent with
Gate A, which stands unchanged. Phase 1 substantively overlaps `thesis_completion_20260704`
T1.3 **as amended 2026-07-12** (no aggregation of premium coefficients; scenario bands) — if
Phase 1 runs, it runs under that amendment. Two Phase-0 items are superseded/absorbed by
`audit_response_20260712` (marked below); the rest of Phase 0 remains live here.

---

## Phase 0: Hygiene — reconcile documents with the evidence (days)

Items surfaced by the Session-10 retrospectives; all are prerequisites for building on top of
the current results.

- [ ] **Task: Reconcile abstracts with the log re-estimation.** *(SUPERSEDED 2026-07-12 →
      `audit_response_20260712` task 1.2, which widens the scope to all four stale claims —
      −2,011, premium repricing story, energy-burden income language, employment prominence.
      Do not do here; mark `[x]` with a pointer when 1.2 lands.)*
- [ ] **Task: Commit the untracked analysis directories.** `Analysis/did/robustness/` and
      `Analysis/mediation/` hold populated results referenced by synthesis docs but are not in
      git. Stage and commit them (respecting any large-file exclusions).
- [ ] **Task: Fix the stale WCB script header.** `Code/did_robustness/01_wild_cluster_bootstrap.R`
      header still reads "written, not yet run" though results are populated in
      `Analysis/did/robustness/did_robustness_summary.md` (PCPI p=0.036; employment p=0.003).
      Headers are the provenance system — update it.
- [ ] **Task: Verify the winsorization gap.** *(ABSORBED 2026-07-12 →
      `audit_response_20260712` task 2.4 — this track is paused behind Gate A and the item
      would orphan; the audit (§8) independently flags it as a defense vulnerability. Mark
      `[x]` with a pointer when 2.4 lands.)*
- [ ] **Task: Fill the writing TKs.** Two `[TK]` baseline denominators in
      `Text/reviewer_response_mechanisms_nber.md` and two incomplete references
      (Audi et al. 2024–25; Doremus et al. 2022).

## Phase 1: Sufficient-statistics policy section (the committee memo's deliverable, ~2 weeks)

All estimation reuses hardened coefficients — no new identification. Outputs to
`Analysis/microsim/`; write-up NBER-styled.

- [ ] **Task: National burden aggregation.** `Code/microsim/01_burden_aggregation.R` —
      aggregate the survivor coefficients (drought→PCPI −$1,451 ITT; cold cumulative-dose
      employment; Medicare morbidity $/beneficiary; premium levels) to an annual national
      dollar burden with delta-method/bootstrap CIs, every number anchored to a baseline.
      Output: `Analysis/microsim/national_burden.csv` + build log.
- [ ] **Task: RMA benchmark.** `Code/microsim/02_rma_benchmark.R` — compare the implied
      uncompensated health-finance burden to actual RMA drought/total indemnity flows
      (`intermediate_rma_indemnity.rds`), by year and by county exposure decile. The framing
      statistic: federal climate transfers exist, and how small the health-finance side is
      relative to the crop side.
- [ ] **Task: Geographic-targeting concentration statement.** `Code/microsim/03_targeting.R` —
      rank counties by hazard × SVI × population using the existing CHEI machinery
      (`exposure_index.R`); report burden concentration (share borne by top decile/quintile of
      counties; comparison to population share).
- [ ] **Task: §7 policy-section write-up.** `Text/policy_section.md` via the
      `nber-economist-writing-style` skill; fold summary into `Analysis/microsim/` synthesis.
- [ ] **Task: Tests.** `Code/tests/test_microsim_phase1.R` (testthat) — aggregation arithmetic
      on a synthetic coefficient set; CI propagation; concentration-share identities
      (shares ∈ [0,1], sum to 1).

**GATE A — committee decision.** Attach Phase-1 outputs to
`Text/committee_memo_ch3_structure.md`; committee chooses: defend with the policy section
alone (skip to Phase 6) or proceed to the microsimulation (Phases 2–4).

## Phase 2: Microsimulation data gate

New acquisitions are keyless; scripts self-document endpoints per project convention. Raw
downloads are not for git.

- [ ] **Task: CMS Marketplace OEP enrollment PUFs.** `Code/microsim/download_oep_enrollment.R`
      + `process_oep_enrollment.R` → `Data/intermediate_oep_enrollment.rds` — county-level
      plan selections by FPL bin, 2015→latest; map counties → rating areas via existing
      crosswalk; report coverage and FFM-vs-SBM availability honestly (SBM states may lack
      county×FPL detail — document the resulting sample).
- [ ] **Task: Subsidy-rule crosswalk.** `Code/microsim/build_subsidy_rules.R` →
      `Data/intermediate_subsidy_rules.rds` — applicable-percentage schedule by FPL bin ×
      year (statutory pre-2021; ARPA/IRA 2021–2025 cliff removal; scheduled 2026 expiry
      schedule), with source citations in-script.
- [ ] **Task: Second-lowest-cost silver by rating area.** Extend the HIX plan-detail pipeline
      (`Data/HIX_Data/plan details/*.zip`) to derive SLCSP by RA×year; validate against the
      existing `Benchmark_Silver` series (they should match closely — reconcile or document
      divergence).
- [ ] **Task: Issuer competition variable.** `Code/microsim/process_issuer_competition.R` →
      issuer count + HHI by county/RA×year from `Data/HIX_Data/issuer county report/`.
- [ ] **Task: Data-gate validation + tests.** Merge diagnostics (≥95% match vs county master;
      known FIPS boundary cases documented) + `test_microsim_data.R` (schemas, FIPS zero-pad
      idiom via `formatC`, no dup keys, subsidy schedule monotonicity in FPL).

## Phase 3: Elasticity estimation (the four sufficient statistics)

County estimator conventions apply (state clustering; RA clustering for premium outcomes).
Estimand labels stated in every output per the methods-retrospective discipline rules.

- [ ] **Task: β_z — exposure→cost sensitivities.** Assemble from hardened coefficients +
      Medicare standardized-cost sensitivity as the claims fallback (proposal p. 34). No new
      identification; a calibration table with SEs → `Analysis/microsim/beta_z_calibration.csv`.
- [ ] **Task: ρ — premium pass-through at the rating-area level.** `Code/microsim/run_passthrough.R`
      — 2SLS of RA premiums on Medicare-proxied claims instrumented by exposure, HHI-interacted
      (proposal eq. 2). Pre-registered fallback: if unstable (expected per
      `premium_mediation_summary.md`), fix the scenario band ρ ∈ {0, 0.7–1.0 literature,
      estimated} and carry all three through the simulation.
- [ ] **Task: ε_enroll(y) — enrollment elasticity by income bin.** `Code/microsim/run_enrollment_elasticity.R`
      — log-log (or grouped-logit) enrollment response to net-premium variation induced by
      benchmark movements within RA (proposal eq. 3); calibration cross-check against
      literature values (Finkelstein–Hendren–Shepard; Tebaldi) reported side-by-side.
- [ ] **Task: Multiple-testing + robustness posture.** Sharpened q-values across the
      elasticity grid (reuse `run_mechanism_multipletesting.R` machinery); wild-cluster
      bootstrap on the pass-through spec if treated-cluster counts are small (FWL+boottest
      pattern).
- [ ] **Task: Tests.** `test_microsim_elasticities.R` — synthetic-data sign/scale recovery for
      the pass-through and enrollment specs; calibration-table schema.

## Phase 4: PTC engine, counterfactuals, and welfare

- [ ] **Task: Cell construction.** `Code/microsim/build_cells.R` → RA × year × FPL-bin panel
      (2014–2023): enrollment weights (OEP), SLCSP, net premium under observed rules;
      validation against published aggregate enrollment/outlay totals.
- [ ] **Task: PTC engine.** `Code/microsim/ptc_engine.R` — PTC = b(y) + σ·P̂ + g(z);
      enrollment update via constant-elasticity mapping (proposal eq. 7); outputs coverage,
      net-premium-to-income affordability, federal outlays, premium dispersion.
      **Unit-test the identities first (TDD)** — `test_ptc_engine.R` written and failing
      before the engine is implemented.
- [ ] **Task: Counterfactual grid.** σ ∈ {0.3, 0.5, 0.7}; targeted b(y) changes; climate
      kicker g(z) = min{κ·(z−z⁹⁰), ḡ}·1{z>z⁹⁰}; combined packages; **headline: the 2026
      enhanced-PTC expiry** (revert ARPA/IRA schedule) under observed climate. Outputs by
      income × SVI tercile → `Analysis/microsim/counterfactuals/`.
- [ ] **Task: Welfare + uncertainty.** Logit consumer-surplus accounting (ΣΔCS − ΔOutlays)
      with Harberger cross-check; parametric draws of the elasticity vector → simulation
      intervals on every counterfactual; ρ scenario bands reported as separate columns, never
      averaged.
- [ ] **Task: Efficiency–equity frontiers + California calibration.** Frontier plots (net
      social benefit vs concentration of gains in high-SVI populations); the proposal's
      promised worked California calibration as the illustrated case.
- [ ] **Task: Provider-pressure mapping (light).** UC = κ0 + κ_z·z from the hospital panel
      (proposal p. 36) — reported as a bounded side-output, not a full provider module.
- [ ] **Task: Synthesis write-up.** `Analysis/microsim/microsim_synthesis.md` +
      `Text/microsim_section.md` (NBER-styled); estimand and ITT caveats stated in the text.

**GATE B — projection layer.** Proceed to Phase 5 only if timeline permits (job-market
material, not a defense requirement).

## Phase 5: Projection layer (optional — Tier 3a)

- [ ] **Task: Acquire LOCA2 county projections.** `Code/microsim/download_loca2.R` — USGS
      ScienceBase county-averaged CMIP6-LOCA2 time series + extreme-event metrics (27 models ×
      SSP245/370/585); map metrics to the panel's shock definitions (document where the
      mapping is approximate — PDSI has no LOCA2 analogue; use published scPDSI-CMIP6 or
      temperature/precip-implied proxy and label it).
- [ ] **Task: Project the burden.** Hsiang et al. (2017) architecture — response functions ×
      projected exposure → county burden to 2050, with climate-model spread + coefficient
      uncertainty as separate bands; adaptation held fixed (state the Lucas critique
      explicitly).
- [ ] **Task: Re-run subsidy counterfactuals under projected exposure.** The payoff question:
      what does the kicker g(z) cost and reach in 2050 under each SSP?
- [ ] **Task: Tests + write-up.** Projection arithmetic tests; `Text/projection_section.md`.

## Phase 6: Tests, docs, conductor close-out

- [ ] **Task: Full test pass.** All `Code/tests/test_microsim_*.R` green; coverage >80% for
      `Code/microsim/` per project convention.
- [ ] **Task: Documentation.** Update `changelog.md`, `GEMINI.md`, `CLAUDE.md` (directory
      structure, run order, lessons learned); register outputs in the synthesis docs.
- [ ] **Task: Conductor close-out.** tracks.md status, session commit per workflow.
- [ ] **User Manual Verification gate.**
