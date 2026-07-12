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

- [ ] **1.1 Master evidence table** → `Plans/master_evidence_table.md`. One row per
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
- [ ] **1.2 Rewrite the draft abstracts** (supersedes `policy_microsim` Phase-0 item).
  Files: `Text/drafts/thesis_paper_abstracts.md`, `thesis_paper_abstracts_structured.md`,
  `abstract_draft.md` (confirm which are live; kill or archive dead variants with user
  approval). Changes bound by 1.1 permitted language: drop the −2,011 headline (`5c615dd`);
  replace the actuarial-repricing premium story with no-coherent-pass-through + the unpriced
  margin; distinguish employer-sponsored vs ACA benchmark premiums; soften energy-burden
  income language (joint horse race not robust); give employment fragility explicit
  prominence next to the robust income result; keep drought income + Medicare morbidity as
  leads. `Text/submissions/conference_abstract.*`: **errata note + user decision only** —
  never silently rewrite a submitted document.
- [ ] **1.3 Essay-3 framing decision + memo update (USER GATE).** Update
  `Text/correspondence/committee_memo_ch3_structure.md` (drafted, unsent) to present both
  framings: "Unequal Weather (inequality)" vs "Institutional & distributional incidence."
  Author decides (audit question 5) and sends; record the decision here and in
  `thesis_completion_20260704`. **Blocking for Essay-3 drafting (thesis_completion 2.5),
  not for Essay 1/2.**
- [ ] **1.4 Post-dedup evidence-table refresh.** **Blocked on `thesis_completion_20260704`
  2.2** (upstream one-row-per-county-year). When `Analysis/county_dedup_integrity.md`
  exists, refresh every table row whose estimate reran; only then may final thesis tables
  freeze. Do not close this track's Phase 1 checkpoint gate for the table's *final* status
  before 2.2 lands (interim status "pre-dedup" is acceptable for drafting).
- [ ] **Phase 1 checkpoint** — verification gate + git note.

## Phase 2: Bounding & falsification (existing machinery only)

- [ ] **2.1 MDE / equivalence bounds on premium pass-through** (R 4.2.2,
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
- [ ] **2.2 Leave-one-treated-state-out, 2012 drought** (R 4.5.3,
  `Code/did_robustness/07_falsification_suite.R` part A; `06_` reserved for T2.2
  de Chaisemartin). Drop each of the 17 treated states in turn; re-estimate the 2×2 ATT for
  PCPI_Real (primary) and Civilian_Employed (secondary); report the ATT envelope + any
  significance flips. **Expectation:** no single state moves income outside the WCB CI
  [−2,911, −138]; treated counties are geographically concentrated, so one or two large
  states (plausibly the Corn Belt core) will dominate magnitude — report honestly either way.
- [ ] **2.3 Placebo onset years** (same script, part B). Pseudo-onset years among
  never-exposed controls, cohort size matched to the 139-county 2012 cohort; exact design
  pre-specified in the script header *before* running. **Expectation:** placebo ATT
  distribution centered on 0 with the real 2012 estimate in the tail (complements the
  existing randomization inference; the audit's "future shocks predict past outcomes" check
  is already covered by the flat 1990–2011 BEA pre-trend — evidence-table row, not a rerun).
  **Test:** extend `Code/tests/test_did_robustness.R` style — placebo assignment respects
  never-exposed status; LOO reruns reproduce the full-sample ATT when no state is dropped.
- [ ] **2.4 Verify hospital winsorization/filtering** (absorbed from `policy_microsim`
  Phase 0; audit §8). Grep the hospital pipeline for winsorize/trim on `Hosp_*` levels (the
  −$408M charity-care reversal is the known offender); if absent, add it where levels
  regressions consume the variables or document the upstream filter; note survivorship and
  discretionary-reporting caveats in the hospital synthesis. **Test:** if code changes,
  `testthat` on the winsorization bounds; if documentation-only, none.
- [ ] **2.5 Fold verdicts in.** Technical note §2.5.6 (falsification suite) + evidence-table
  rows updated with the LOO/placebo/MDE verdicts and their permitted language.
- [ ] **Phase 2 checkpoint** — verification gate + git note.

## Phase 3: Observed vs latent hardship (the one new regression family)

- [ ] **3.1 Pre-specification (dated spec.md note BEFORE any code).** Question: does the
  measured shock→medical-debt response shrink where hardship is least observable?
  Moderators (primary): SAHIE uninsurance (interaction already exists —
  `mechanisms_revision_20260704`), rurality (RUCC), hospital density / safety-net presence
  (NASHP panel). Secondary: income, SVI. Expected signs (response *shrinks* where
  access/visibility is weakest), sample, FE structure, clustering, and multiplicity handling
  (reuse the sharpened-q machinery from `run_mechanism_multipletesting.R`) all written down
  first — this respects the audit's frozen specification search.
- [ ] **3.2 Implement** `Code/run_latent_hardship.R` (R 4.2.2) + `testthat`
  (`Code/tests/test_latent_hardship.R`): moderator construction, interaction alignment,
  no-NA leakage, FIPS `formatC` idiom. Outputs → `Analysis/latent_hardship/` + build log +
  `Analysis/INDEX.md` row.
- [ ] **3.3 Write-up.** Converts "debt is measurement-fragile" from caveat into a positive
  finding about where financial records fail to observe hardship (or reports the honest
  null); evidence-table rows added at the tier the results warrant (mechanism-supporting or
  exploratory — NOT headline without the full robustness battery).
- [ ] **Phase 3 checkpoint** — verification gate + git note.

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
