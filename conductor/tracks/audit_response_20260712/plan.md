# Implementation Plan: Audit Response — Claim Architecture, Bounding & Falsification

Track spec: `./spec.md`. Source: `Plans/project_audit_research_questions_20260712.md`
(fact-checked 2026-07-12 — see spec "Fact-check basis").

**Sequencing:** Phase 1 (claim architecture) is the critical path — `thesis_completion_20260704`
2.4/2.5 essay drafts consume its evidence table and must not start before 1.1–1.2 land.
Phase 2 (bounding + falsification) is cheap econometrics on existing machinery; it can run
alongside Phase 1 but must land before essay claims freeze. Phase 3 (latent hardship) is the
only new regression family — pre-specified, after Phases 1–2. Phase 4 is **parked**
(gated on Tier-1 essay drafts). **Overlap rule:** where a task belongs to another track, this
plan links and never duplicates — the binding map is in `spec.md` → "Overlap map".

---

## Phase 0: Standup & overlap reconciliation

- [x] **0.1 Stand up the track.** Write `spec.md` + `plan.md`; register in
  `conductor/tracks.md`; add the track to the CLAUDE.md snapshot Active line. Commit. `dea6b2a`
- [x] **0.2 Cross-track annotations (the "care" in overlap handling).** `dea6b2a`
    - `thesis_completion_20260704/spec.md`: dated 2026-07-12 amendment under T1.3
      (component (a) re-based off Medicare morbidity, scenario bands for (b)).
    - `thesis_completion_20260704/plan.md`: header coordination note; 2.3 amended; 2.4/2.5
      gated on the evidence table.
    - `policy_microsim_20260706/plan.md`: header audit note; Phase-0 abstract-reconcile and
      winsorization tasks marked superseded/absorbed → this track (1.2, 2.4).
    - `did_frontier_robustness_20260625/plan.md`: note that falsification extensions live
      here (track stays closed).
    - `conductor/tracks.md`: `policy_microsim` entry annotated (audit: Phases 2–4 stay
      behind Gate A until Tier-1 drafts exist).

## Phase 1: Claim architecture (audit priorities 2–5)

- [x] **1.1 Master evidence table** (`a25a62b`) → `Plans/master_evidence_table.md`. One row per
  abstract-level claim; columns: claim, tier (headline / confirmatory / mechanism-supporting
  / exploratory), estimand, population/sample, years, unit, identifying variation, inference
  (analytic + WCB/RI where run), robustness status, **permitted language**, source
  file + commit. Primary sources: `Plans/results_evolution_narrative.md`,
  `Plans/methods_retrospective.md`, `Analysis/did/robustness/did_robustness_summary.md`,
  `Analysis/mediation/premium_mediation_summary.md`, `Analysis/mechanism/mechanism_verdict.md`,
  the `Analysis/*/synthesis.md` family. Must encode the spec's fact-check nuances: the
  pooled e=0 income effect (−$1,050, p=0.002) vs null long-run pooled average; HonestDiD
  applies to the pooled event study only; ESI vs ACA premiums are different objects.
  **Test:** none (document), but every row's numbers must be traceable to a tracked
  `Analysis/` file — no hand-recalled figures.
- [x] **1.2 Rewrite the draft abstracts** (`d3d04f2` — all four rebuilt to the table; ERRATA
  note for the submitted conference abstract; dead vintages archived; supersedes the
  `policy_microsim` Phase-0 item).
  Files: `Text/drafts/thesis_paper_abstracts.md`, `thesis_paper_abstracts_structured.md`,
  `abstract_draft.md` (confirm which are live; kill or archive dead variants with user
  approval). Changes bound by 1.1 permitted language: drop the −2,011 headline (`5c615dd`);
  replace the actuarial-repricing premium story with no-coherent-pass-through + the unpriced
  margin; distinguish employer-sponsored vs ACA benchmark premiums; soften energy-burden
  income language (joint horse race not robust); give employment fragility explicit
  prominence next to the robust income result; keep drought income + Medicare morbidity as
  leads. `Text/submissions/conference_abstract.*`: **errata note + user decision only** —
  never silently rewrite a submitted document.
- [~] **1.3 Essay-3 framing decision + memo update (USER GATE).** *(Memo updated `e924861` —
  both framings boxed, audit recommendation labeled, retracted claims reconciled. REMAINING:
  author reviews/sends memo; decision recorded here + thesis_completion. Gate OPEN.)* Update
  `Text/correspondence/committee_memo_ch3_structure.md` (drafted, unsent) to present both
  framings: "Unequal Weather (inequality)" vs "Institutional & distributional incidence."
  Author decides (audit question 5) and sends; record the decision here and in
  `thesis_completion_20260704`. **Blocking for Essay-3 drafting (thesis_completion 2.5),
  not for Essay 1/2.**
- [x] **1.4 Post-dedup evidence-table refresh.** (2.2 landed `fca5643`; refresh done — table
  header → POST-DEDUP with headline rows freezable; Row 8 refreshed from the officially
  re-run mediation + bounds scripts (drought β 3.17/SE 2.57, δ*=$7.40, rules out >50–79% of
  the benchmark; verdicts unchanged); Row 27 integrity caveat resolved; memo bound updated;
  data-pipeline.md integrity bullet rewritten; re-audit items 6/7 phrasing fixes applied to
  the abstracts; items 5/8 lodged as essay-draft guidance in thesis_completion 2.4/2.5.)
- [x] **Phase 1 checkpoint** — verification gate + git note. [checkpoint: dbdcdf2] *(author
  sign-off 2026-07-13; the 1.3 Essay-3 decision remains an external committee dependency.)*

## Phase 2: Bounding & falsification (existing machinery only)

- [x] **2.1 MDE / equivalence bounds on premium pass-through** (R 4.2.2, `d9f5362` — verdict hazard-split: drought STRONG, heat/cold SOFTER; see git note)
  `Code/run_passthrough_bounds.R`, reusing `run_premium_mediation.R` data prep). On the
  PRIMARY rating-area×year spec (RA + State^Year FE, pop-wtd, state-clustered): 80%-power
  MDE from the estimated SEs + TOST equivalence bounds, benchmarked against the premium
  response implied by full pass-through of the Medicare morbidity cost ($112–$177/
  beneficiary mapped to per-member-per-month premium dollars — document the mapping's
  assumptions in-script). **Expectation (recorded before the run):** within-state SEs are
  small (few % of the $375 base), so the MDE is likely below the full-pass-through
  benchmark, licensing "we can rule out pass-through larger than X%"; if not, the softer
  bounded-response language applies (spec O4 contingency). **Test:** `testthat` — MDE
  arithmetic on synthetic SEs; TOST identity; benchmark mapping units.
- [x] **2.2 Leave-one-treated-state-out, 2012 drought** (`3f8bdf8` — no CI exits; CO/NE analytic-p flips noted, handled by WCB layer) (R 4.5.3,
  `Code/did_robustness/07_falsification_suite.R` part A; `06_` reserved for T2.2
  de Chaisemartin). Drop each of the 17 treated states in turn; re-estimate the 2×2 ATT for
  PCPI_Real (primary) and Civilian_Employed (secondary); report the ATT envelope + any
  significance flips. **Expectation:** no single state moves income outside the WCB CI
  [−2,911, −138]; treated counties are geographically concentrated, so one or two large
  states (plausibly the Corn Belt core) will dominate magnitude — report honestly either way.
- [x] **2.3 Placebo onset years** (same script, part B; `3f8bdf8` — placebo p=0.009, distribution centered on 0). Pseudo-onset years among
  never-exposed controls, cohort size matched to the 139-county 2012 cohort; exact design
  pre-specified in the script header *before* running. **Expectation:** placebo ATT
  distribution centered on 0 with the real 2012 estimate in the tail (complements the
  existing randomization inference; the audit's "future shocks predict past outcomes" check
  is already covered by the flat 1990–2011 BEA pre-trend — evidence-table row, not a rerun).
  **Test:** extend `Code/tests/test_did_robustness.R` style — placebo assignment respects
  never-exposed status; LOO reruns reproduce the full-sample ATT when no state is dropped.
- [x] **2.4 Verify hospital winsorization/filtering** (`4576268` — absent, env-gated pass added; heat×safety-net ROBUST p=.013, hospital cumulative-dose margin FAILS p=.080 → demote, drought $ incidence −38% magnitude) (absorbed from `policy_microsim`
  Phase 0; audit §8). Grep the hospital pipeline for winsorize/trim on `Hosp_*` levels (the
  −$408M charity-care reversal is the known offender); if absent, add it where levels
  regressions consume the variables or document the upstream filter; note survivorship and
  discretionary-reporting caveats in the hospital synthesis. **Test:** if code changes,
  `testthat` on the winsorization bounds; if documentation-only, none.
- [x] **2.5 Fold verdicts in.** (`285ad66` — technical note .tex/.html falsification + winsorization
  notes; evidence-table Rows 1/2/8/23 verdicts; Essay-3 abstract staleness; hospital synthesis
  addendum; propagation_pathways drift banner; INDEX rows. Done by orchestrator.)
- [x] **Phase 2 checkpoint** — verification gate + git note. [checkpoint: c1afd75] *(author
  sign-off 2026-07-13.)*

## Phase 3: Observed vs latent hardship (the one new regression family)

- [x] **3.1 Pre-specification (dated spec.md note BEFORE any code).** `07cc834` Question: does the
  measured shock→medical-debt response shrink where hardship is least observable?
  Moderators (primary): SAHIE uninsurance (interaction already exists —
  `mechanisms_revision_20260704`), rurality (RUCC), hospital density / safety-net presence
  (NASHP panel). Secondary: income, SVI. Expected signs (response *shrinks* where
  access/visibility is weakest), sample, FE structure, clustering, and multiplicity handling
  (reuse the sharpened-q machinery from `run_mechanism_multipletesting.R`) all written down
  first — this respects the audit's frozen specification search.
- [x] **3.2 Implement** (`8b20df0` — HONEST NULL: all cells attenuate as predicted, only
  drought×uninsurance robust q=.012; cold 0/3, drought 1/3 vs the ≥2/3 bar; RUCC proxied by
  baseline population, flagged) `Code/run_latent_hardship.R` (R 4.2.2) + `testthat`
  (`Code/tests/test_latent_hardship.R`): moderator construction, interaction alignment,
  no-NA leakage, FIPS `formatC` idiom. Outputs → `Analysis/latent_hardship/` + build log +
  `Analysis/INDEX.md` row.
- [x] **3.3 Write-up.** (`4bda650` — honest null propagated: evidence-table Row 24 narrowed
  to the coverage/credit-visibility gradient; Essay-3 abstract + committee memo Option B
  updated; INDEX row. Summary doc: `Analysis/latent_hardship/latent_hardship_summary.md`.)
- [x] **Phase 3 checkpoint** — verification gate + git note. [checkpoint: 1eb23a6] *(author
  sign-off 2026-07-13.)*

## Phase 4: PARKED — do not start before thesis_completion 2.4–2.5 drafts exist

*(Audit "moderate alpha"; explicitly deferred by its own freeze logic. Committee-gated.)*

- [ ] **4.1 Adaptation vs damage horse race.** Organize the existing z-score anomalies,
  absolute CDD/HDD, and frozen 1990–2000 baseline-climate interactions into one
  pre-specified question: is harm driven by physical severity or by exceedance of local
  adaptation?
- [ ] **4.2 Heterogeneous 2012 treatment intensity.** Tightly pre-specified dose design
  (PDSI intensity, months in extreme drought, agricultural dependence, baseline labor
  exposure) to distinguish dose response from a treated-region contrast.

## Phase 5: Close-out

- [ ] **5.1 Knowledge merge** (`conductor/knowledge/econometrics.md`: MDE/equivalence
  pattern for headline nulls; falsification-suite lessons) + INDEX refresh + changelog.
- [ ] **5.2 Registry update** + final commit.
- [ ] **Conductor — User Manual Verification 'Audit Response' (Protocol in workflow.md).**

---

### Notes / lessons (live)

- **The overlap map in `spec.md` is binding.** Link, never duplicate: dedup = thesis_completion
  2.2; burden aggregation = thesis_completion 2.3 (as amended); microsim = policy_microsim
  behind Gate A; abstract task formerly in policy_microsim Phase 0 is superseded here.
- **The audit's "freeze the specification search" governs this track too.** Phases 2–3 are
  pre-specified, expectation-first; Phase 4 stays parked until drafts exist. Any impulse to
  add "one more interaction" goes to the parking lot, not the code.
- **Nulls need bounds before they can be headlines** (spec O4). If the MDE turns out too
  large, the reframing softens — the evidence table records whichever verdict the data give.
