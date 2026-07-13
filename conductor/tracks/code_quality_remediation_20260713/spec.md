# Track Specification: Code-Quality Remediation — Reproducibility Before Freeze

**Created:** 2026-07-13
**Origin:** `Plans/coding_and_analysis_audit_20260712.md` (read-only coding/analysis audit),
load-bearing claims verified in-session 2026-07-13 (below).
**Type:** Remediation track gating the manuscript freeze. The audit's §7 "minimum defense
gate" is this track's acceptance checklist. The strategy is the audit's own: **no new
models** — make existing results reproducible from clean inputs, ensure each headline uses
the strongest available estimator, and remove superseded evidence from the live manuscript
path.

## Verification basis (checked before this track was created)

- **A1 (false-green runner): CONFIRMED.** `Rscript Code/tests/testthat.R` exits 0 with 36
  error lines (working-directory drift after the first `test_file()`); individual
  `Rscript Code/tests/test_*.R` runs remain the only trustworthy invocation.
- **A4 (manual CS SEs): CONFIRMED AND MATERIAL.** The independence formula sits at
  `run_did_analysis.R:344`. The manual aggregation's drought-income e=0 is −$1,050
  (p=0.002); the authoritative frontier estimator (`did::att_gt`, DR, influence-function
  covariance; `Analysis/did/robustness/dr_csdid_eventtime.csv`) gives e=0 = **−$324
  (SE 276): null**. The "immediate hit generalizes" nuance in the evidence table, Essay 1
  abstract, errata, and audit_response spec was sourced from the invalid output and must be
  corrected — the 2012 income effect is event-specific even at onset under the frontier
  estimator.
- **A3 (RA panel from post-dedup master): CONFIRMED** — pre-flagged by the dedup task
  (`fca5643` git note). Post-dedup, the master carries county-mean premiums + min RA id, so
  `run_premium_mediation.R`'s RA panel no longer reconstructs the true county×RA structure.
  The mean-vs-min invariance check suggests the drought verdict is stable, but the panel
  must be rebuilt from `Data/premiums_county.csv`.
- **A5 (bad controls): CONFIRMED** — 15+ analysis scripts condition on contemporaneous
  `Household_Income_2023` (annual income in 2023 dollars, not a baseline) and
  `Uninsured_Rate`, both plausible shock mediators. The 2012 DiD is immune (baseline
  covariates only).

## Overlap map (binding — link, never duplicate)

| Audit item | Existing owner / interaction | Handling here |
|---|---|---|
| A3 RA rebuild | Flagged follow-up in thesis_completion 2.2 git note; `run_premium_mediation.R` + `run_passthrough_bounds.R` (anchor gate) | Owned here (task 2.1). Bounds anchors updated by the documented dated-note pattern if numbers shift. |
| A4 prose corrections | `Plans/master_evidence_table.md` (audit_response artifact) + abstracts + errata + audit_response spec fact-check | Owned here (task 0.2, orchestrator — permitted-language change). Historical docs get "superseded-by" notes, not rewrites. |
| A6 exhibit registry | Feeds thesis_completion 2.4/2.5 essay exhibits; does NOT block drafting starting | Owned here (Phase 4); registry doubles as the audit's A2 manuscript-orchestrator in minimal form. |
| B1 stale prose (hospital synthesis body, latent-hardship "pre-dedup" label, AQI memo) | hospital_supply_side (closed) — continue the addendum/banner pattern | Owned here (task 4.2). |
| B5/B6 framing (clustering primacy; dose = exposure-history association) | Evidence-table permitted language + writing-plan quality gates | Owned here (folded into 3.2/4.4 table updates). |
| A2 full pipeline orchestrator | — | **Deferred**: only the exhibit-registry form is built; a full DAG orchestrator is post-defense work. |
| B2 blanket test coverage | — | **Deferred** per the audit's own advice; only estimand-recovery tests added where Phase 2–3 code changes. |
| C1 lockfile, C3/C4 renames | `Household_Income_2023` has 15+ consumers | **Deferred** to close-out / post-defense; C4 handled by a naming note in `conductor/knowledge/data-pipeline.md` instead of a mid-stream rename. |

## Objectives

- **O1 — Truthful verification (A1).** `Code/tests/testthat.R` runs every test in a clean
  R process from the repo root, aggregates results, exits nonzero on any failure/error, and
  is itself regression-tested with a deliberately failing fixture.
- **O2 — Strongest-estimator discipline (A4).** The manual CS aggregation is relabeled
  descriptive (script comments + output-doc banners); no headline prose or evidence-table
  row carries its p-values; pooled/event-time inference cites only
  `Analysis/did/robustness/dr_csdid_*` (R 4.5.3 `did::att_gt/aggte`).
- **O3 — Correct RA source panel (A3).** RA-level pass-through/mediation/bounds rebuilt
  from `Data/premiums_county.csv` (documented population-allocation rule; no full county
  population assigned to every RA); corrected estimates compared against the current
  β=3.17/SE=2.57, δ*=7.40 verdict.
- **O4 — Bad-control sensitivity (A5).** For every headline county/transition/dose cell:
  identical-sample no-control / lagged-control / contemporaneous-control variants in one
  comparison table; the no-control spec becomes primary for total-effect language, with
  contemporaneous controls relabeled mediation/sensitivity. Evidence-table language updated
  to whatever the data give.
- **O5 — Post-dedup exhibit freshness (A6 + B1).** Exhibit registry (one row per
  manuscript exhibit: output file, generating script, inputs, master-build stamp); every
  manuscript-bound family re-run on the certified master; stale synthesis prose regenerated
  or moved under superseded banners.
- **O6 — Hygiene that prevents recurrence (B3/B4 scoped).** `pad_fips()` centralized in
  `pipeline_utils.R` + a repo test scanning built intermediates for 5-char FIPS; build-log
  helper adopted by scripts touched in this track (not a 137-script retrofit).

## Acceptance criteria — the audit's §7 minimum defense gate, verbatim

**ALL MET (2026-07-13; evidence in `Analysis/reproduction_certificate.md` + commits):**

1. ✅ Aggregate tests fail correctly when a test is intentionally broken (`96f26e4` — self-test
   proves nonzero exit on the deliberate-failure fixture).
2. ✅ All critical tests pass in clean R processes (32/32, exit 0; certificate table).
3. ✅ Rating-area premium results rebuilt from source RA data (`aeae55b` — verdicts
   invariant 6/6 across dedup + allocation rules).
4. ✅ No headline uses the manual-CS independence SEs (`034e156` — quarantined; frontier
   e=0 −$324 null governs; all citing surfaces corrected).
5. ✅ Transition and dose headlines have control sensitivity (`ff7049e` — control-robust;
   debt cells re-attributed to sample fragility).
6. ✅ All manuscript exhibits post-dedup (`2e22c11` — every family <0.15 SE movement;
   registry stamped 118,732×82/2026-07-13).
7. ✅ Stale synthesis prose removed/archived (`980b1d7`, `2e22c11` — hospital §B,
   latent-hardship label, AQI memo, mechanism verdict, event-study tail, Midwest labels).
8. ✅ Input/output manifest (`Plans/exhibit_registry.md`, ~35 exhibits, master-stamped;
   masters SHA-256 recorded in the certificate).
9. ✅ `Plans/master_evidence_table.md` refreshed one final time (status FROZEN-READY;
   certified magnitudes locked: asymmetry +0.01874, dose −5,522, SVI-income p≈0.06).

## Environment

R 4.2.2 for everything except re-runs under `Code/did_robustness/` (R 4.5.3). House rules
throughout: `fixest::feols` only; `formatC` FIPS idiom; `sink()` build logs + provenance
headers; testthat via plain Rscript; never hand-edit outputs.
