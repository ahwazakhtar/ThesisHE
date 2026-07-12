# Track Specification: Audit Response — Claim Architecture, Bounding & Falsification

**Created:** 2026-07-12
**Origin:** `Plans/project_audit_research_questions_20260712.md` (external strategic audit),
fact-checked against the repo the same day (see "Fact-check basis" below).
**Type:** Coordination + targeted-analysis track. It owns the audit's *new* work (evidence
table, abstract reconciliation, null-bounding, falsification, latent-hardship analysis) and
**links to — never duplicates — tasks already owned elsewhere** (see Overlap map). Where a
task overlaps another track, that track's `plan.md` carries a pointer both ways.

## Fact-check basis (what the audit got right, and where it needs correction)

Verified 2026-07-12 before this track was created:

- **−2,011 jobs dies in logs** — confirmed (commit `5c615dd`; flagged as an open conflict in
  `Plans/results_evolution_narrative.md`) yet still headlined in
  `Text/drafts/thesis_paper_abstracts.md`. Audit §4 correct.
- **Premium pass-through incoherent** — confirmed (`thesis_completion_20260704` task 2.1:
  sign flips across county/RA/state; 92–99% of the debt effect survives premium adjustment).
  Audit §3 correct, with one conflation to preserve in the rewrite: the abstract's $18 figure
  is **employer-sponsored** premiums (state panel), a *different object* from the ACA
  benchmark premiums the mediation tested. The rewrite must distinguish them, not delete both.
- **~484 duplicate county-years** — confirmed (`conductor/knowledge/data-pipeline.md`;
  stopgap dedupe in `run_premium_mediation.R`). Audit §9 correct; fix already owned by
  `thesis_completion_20260704` task 2.2.
- **Pooled multi-cohort estimator null/reversed** — confirmed (CS-dr simple ATT income
  **+$350**, SE 585) **but overstated**: the pooled event-time-0 income effect across four
  drought cohorts is **−$1,050 (p=0.002)**, so the *immediate* income hit shows some
  generalization; it is the long-run pooled average that dies. Permitted language must carry
  this nuance.
- **One omission in the project's favor-check:** HonestDiD breakdown M̄<0.5 attaches to the
  *pooled* CS event study only (already null at e=0); it **cannot run on the 2012 cohort**
  (no in-panel pre-period). The 2012 headline's credibility rests on DRDID (−$1,451), WCB/RI
  (p=0.036/0.0075), and the flat 1990–2011 BEA pre-trend — not on HonestDiD. State this
  correctly in the evidence table; do not import the audit's framing uncritically.

## Overlap map (binding — "handled with care" rules)

| Audit item | Existing owner | Handling here |
|---|---|---|
| County-year dedup (audit §9, priority 1) | `thesis_completion_20260704` 2.2 (also closes the `county_analysis_refinement` deferred item) | **Not duplicated.** Task 1.4 (evidence-table refresh) is *blocked on* 2.2; final thesis tables freeze only after both. |
| Abstract rewrite (audit §3–4, priority 2) | `policy_microsim_20260706` Phase 0 had a narrower "reconcile −2,011" task | **Superseded → this track 1.2** (full-scope rewrite). Pointer left in that plan; do not do it there. |
| Burden concentration (audit "high alpha") | `thesis_completion_20260704` 2.3 (T1.3) ≙ `policy_microsim` Phase 1 | **Stays there.** T1.3(a) amended by dated spec note 2026-07-12 (no aggregation of unstable premium coefficients; scenario bands, not a single national total). |
| Hospital winsorization verify (audit §8) | `policy_microsim_20260706` Phase 0 (paused track — item would orphan) | **Absorbed → this track 2.4**, pointer left behind. |
| Full PTC microsimulation (audit "negative alpha") | `policy_microsim_20260706` Phases 2–4, already committee-gated (Gate A) | **No structural change** — Gate A stands; registry annotation records the audit's recommendation. |
| Falsification (LOO state, placebo onsets) | `did_frontier_robustness_20260625` (closed) | **New work here (2.2–2.3)**; a note in the closed track points forward. Does *not* reopen that track. |
| "Future shocks predict past outcomes" (audit) | Already substantively covered by the 1990–2011 BEA pre-trend test (flat, −$69/yr, p=0.44) | **Not re-run** — recorded as a covered falsification in the evidence table. |
| Essay-3 reframing (audit §5, question 5) | `thesis_completion_20260704` T0.4 memo (drafted, **unsent**) | **This track 1.3 updates the memo before the author sends it** — user gate. |
| Mortality (audit "lower alpha") | `thesis_completion_20260704` T2.1 (Tier-2 gated) | **Unchanged.** Audit and plan agree it is a benchmark, not a pillar. |
| Essay drafting order (audit priority 6) | `thesis_completion_20260704` 2.4–2.5 | Notes added there: drafts consume `Plans/master_evidence_table.md` as the claim source of truth. |

## Objectives

- **O1 — Master evidence table** (audit priority 4; the centerpiece). One row per
  abstract-level claim: claim, tier (headline / confirmatory / mechanism-supporting /
  exploratory — audit §10 hierarchy), estimand, population/sample, years, unit, identifying
  variation, inference (analytic + WCB/RI where applicable), robustness status (what
  survives/dies and where), **permitted language** (binding for all subsequent prose),
  source file + commit. Output: `Plans/master_evidence_table.md`.
- **O2 — Abstract reconciliation** (audit priorities 2–3). Rewrite the draft abstracts to the
  verified evidence; `Text/submissions/` items get an errata note + user decision, never a
  silent rewrite.
- **O3 — Essay-3 framing decision** (audit §5 + recommended hierarchy). Present "Unequal
  Weather (inequality)" vs "Institutional & distributional incidence (who records/absorbs/
  fails to price the harm)" as an explicit option in the committee memo **before it is
  sent**. User gate — this is audit clarifying-question 5, and only the author can answer it.
- **O4 — Bound the premium null.** To headline "no coherent pass-through," the null must be
  bounded: MDE (80% power) + TOST equivalence bounds on the primary rating-area×year spec,
  benchmarked against the premium response implied by full pass-through of the Medicare
  morbidity cost ($112–$177/beneficiary). **Contingency (expectation-first):** if the MDE
  exceeds the full-pass-through benchmark, the claim must soften from "institutional null"
  to "bounded within-state response + cross-level sign instability" — either way the
  evidence-table language updates.
- **O5 — Falsification suite** for the 2012 drought 2×2: leave-one-treated-state-out
  (17 treated states, geographically concentrated) and placebo onset years among
  never-exposed controls. Cheap, existing machinery, answers the committee's most likely
  attack first.
- **O6 — Observed vs latent hardship** (audit "high alpha"; the one genuinely new regression
  family). Does the measured shock→debt response *shrink* where institutional access,
  coverage, or credit visibility is weakest (SAHIE uninsurance, rurality, hospital
  density/safety-net presence, income/SVI)? Extends the existing SAHIE interaction
  (`mechanisms_revision_20260704`) from caveat to contribution. **Pre-specified before any
  code runs** (Phase 3.1 dated note in this spec) to respect the frozen specification search.

## Explicitly out of scope (audit "low or negative alpha")

New hazard types; more binary threshold grids; more generic shock×moderator interactions;
treating ACA premium coefficients as stable sufficient statistics; hospital closures before
the hospital-accounting pipeline is cleaned; additional event-study variants without a new
estimand; the full PTC microsimulation (stays behind `policy_microsim` Gate A). The
adaptation-vs-damage horse race and heterogeneous-2012-intensity analyses (audit "moderate
alpha") are **parked in Phase 4**, gated on Tier-1 essay drafts existing.

## Environment

- O4 (`Code/run_passthrough_bounds.R`) and O6 (`Code/run_latent_hardship.R`) on **R 4.2.2**
  (`fixest`, county master + mediation machinery).
- O5 lives in `Code/did_robustness/` → **R 4.5.3** per the project's two-R boundary
  (numbered `07_*`; `06_` is reserved for the de Chaisemartin estimator, T2.2).
- All scripts self-log to `Analysis/**/build_logs/`, provenance headers, `testthat` >80%
  coverage for new code, expectation-first for estimation (workflow principles 3–5).

## Acceptance criteria (track-level)

- **O1** every claim currently appearing in a draft abstract has a row; the four known
  conflicts (−2,011; premium repricing; energy-burden income language; employment
  prominence) are resolved to permitted language; table cross-referenced from
  `thesis_completion` 2.4/2.5.
- **O2** no draft abstract contains a claim whose evidence-table row forbids it; the ESI vs
  ACA premium distinction is explicit; submissions handled via errata note + user decision.
- **O3** memo presents both Essay-3 framings with the evidence for each; author's decision
  recorded here and in `thesis_completion` before the memo is sent.
- **O4** MDE and equivalence bound reported with the Medicare-implied benchmark; verdict
  sentence ("we can rule out pass-through larger than X% of the morbidity cost increase" or
  the honest softer claim) written into the evidence table and technical note.
- **O5** LOO envelope (min/max ATT + significance flips, if any) and placebo-onset
  distribution reported; verdicts folded into technical note §2.5.6 and the evidence table.
- **O6** pre-specification note dated *before* the script's first run; gradient estimates
  with sharpened q-values; write-up converts the debt-measurement caveat into a positive
  finding (or reports the honest null); INDEX row added.

## Open questions for the author (audit questions 2–5; question 1 is answered — memo unsent)

1. Defense deadline, and is Essay 1 the job-market paper? (thesis_completion assumes
   Mar 2027 / yes.)
2. Must the essays be independently publishable, or chapters of one integrated dissertation?
3. Which contribution does the project primarily own: household financial distress,
   climate-health utilization, persistence/scarring, or institutional failure to price and
   measure climate costs? (The audit argues the last; O3 forces the decision.)
4. Willing to demote medical debt and premiums from headline outcomes? (O1–O2 implement the
   demotion the internal documents already made; the author confirms at the 1.3 gate.)
