# Implementation Plan: Code-Quality Remediation — Reproducibility Before Freeze

Track spec: `./spec.md`. Source: `Plans/coding_and_analysis_audit_20260712.md` (§6 gives the
sequence; §7 gives the acceptance gate).

**Sequencing:** Phase 0 (A4 claim correction) is urgent — live prose currently carries an
invalid p-value — and orchestrator-owned. Phases 1 (runner), 2 (RA rebuild + CS quarantine),
and 3 (bad-control sensitivity) are mutually independent → run in parallel. Phase 4 (exhibit
refresh) runs AFTER 2–3 land so exhibits reflect corrected specs. Phase 5 is the final
clean-room reproduction against the evidence table. **Overlap rule:** the spec's Overlap map
is binding — link, never duplicate.

---

## Phase 0: Standup + the urgent claim correction

- [x] **0.1 Stand up the track** (spec, plan, registry, CLAUDE.md snapshot line). `a0ca6f9`
- [x] **0.2 A4 prose correction (orchestrator — permitted-language change).** (`034e156` —
  "onset hit generalizes (−$1,050)" retracted across 8 surfaces; frontier e=0 −$324 null
  governs; 2012 income effect is event-specific even at onset.) Replace the
  "immediate income hit generalizes (−$1,050, p=0.002)" nuance with the frontier verdict
  (CS_dr_dynamic e=0 = −$324, SE 276, null; 2012 event-specific even at onset) in:
  evidence-table Row 1 (robustness + permitted language), Essay 1 abstract,
  `conference_abstract_ERRATA.md` amendment 2, audit_response spec fact-check (dated
  amendment, not silent rewrite), re-audit addendum (one-line superseded-by note),
  `Analysis/did/did_results.md` §3 (descriptive-only banner). Grep for stray "1,050"
  citations before closing.

## Phase 1: Truthful verification (audit A1)

- [x] **1.1 Fix the aggregate runner.** (`96f26e4` — 30/30 PASS in clean processes; the old
  runner's 36 errors were wd-drift artifacts, no hidden real failures.) `Code/tests/testthat.R`: run every
  `Code/tests/test_*.R` in a **clean R process** from the repo root (`system2` on
  R 4.2.2), capture per-file exit codes, print a summary table, exit nonzero if ANY file
  fails; emit a machine-readable report (`Analysis/test_reports/test_report.csv` +
  timestamp/R-version stamp).
- [x] **1.2 Runner regression test.** (`96f26e4` — fixture + self-test both assertions pass;
  re-verified independently by orchestrator.)
- [x] **Phase 1 checkpoint** — verification gate + git note. [checkpoint: 81c841e] *(author sign-off 2026-07-13.)*

## Phase 2: Analysis-source corrections (audit A3 + A4 code side)

- [x] **2.1 Rebuild the RA panel from source (A3).** (`aeae55b` — drought STRONG holds,
  β 3.13/δ* $7.40; verdict invariance 6/6 across dedup + allocation rules; full-pop
  sensitivity exactly reproduces pre-dedup, confirming the diagnosis.) `run_premium_mediation.R`: build the
  rating-area panel from `Data/premiums_county.csv` (county × Year × rating_area_id), NOT
  from the deduped master's premium columns; join county shocks/population with a
  documented allocation rule (equal-split across a county's RAs as primary — sub-county
  population shares don't exist — plus an alternative rule as sensitivity; never assign
  full county population to every RA). Re-run mediation + `run_passthrough_bounds.R`
  (update its anchors by the dated-note pattern if numbers shift); compare against
  β=3.17/SE=2.57/δ*=7.40 and report whether the drought STRONG verdict and the 92–99%
  mediation corollary hold. **Test:** extend `test_premium_mediation.R` — RA panel row
  count = source panel count; split-county population never double-assigned.
- [x] **2.2 Quarantine the manual CS aggregation (A4 code side).** (`034e156` — descriptive-only
  block in `run_did_analysis.R`; §3 banner in `did_results.md`; p-value column relabel happens at
  the Phase-4 regeneration.) `run_did_analysis.R`:
  descriptive-only header note at the aggregation block (invalid independence SEs, pointer
  to the frontier layer); drop or clearly relabel its p-value column in
  `did_cs_event_time.csv` on next regeneration; banner in `Analysis/did/did_results.md`
  (done at 0.2 if not before). **Test:** none (labeling); verified by grep.
- [x] **Phase 2 checkpoint** — verification gate + git note. [checkpoint: 81c841e] *(author sign-off 2026-07-13.)*

## Phase 3: Bad-control sensitivity (audit A5)

- [x] **3.1 Same-sample control-variant comparison.** (`ff7049e` — no sign/significance changes
  anywhere; debt cells re-attributed to SAMPLE fragility; 8/8 tests, verified independently.) New `Code/run_control_sensitivity.R`
  (R 4.2.2): for each headline transition/dose/county cell — cold→debt L1 (county),
  drought→debt L2 (county), drought debt onset/exit asymmetry h=2, cold cumulative-dose
  employment binned contrast — estimate three variants on the IDENTICAL estimation sample:
  (i) no controls (county+year FE only), (ii) lagged/baseline controls, (iii) current
  contemporaneous controls. Output one comparison table (coefficient, SE, N, %Δ vs
  no-control) → `Analysis/control_sensitivity/` + build log. **Expectation (recorded):**
  FE-purged weather shocks are quasi-random, so no-control coefficients should move
  modestly; a large collapse or amplification flags mediation and changes permitted
  language. **Test:** `testthat` — identical N across variants per cell; spec construction.
- [x] **3.2 Fold verdicts in (orchestrator).** (`0f257c0` — Rows 4/5/16/17 + B5/B6 rules.) Evidence-table rows for the affected
  headlines updated (no-control primary for total-effect language; contemporaneous controls
  relabeled mediation/sensitivity); B6 dose-as-exposure-history framing and B5 clustering
  primacy (state primary, RA sensitivity, never select significance on RA SEs) written into
  the table's permitted language.
- [x] **Phase 3 checkpoint** — verification gate + git note. [checkpoint: 81c841e] *(author sign-off 2026-07-13.)*

## Phase 4: Post-dedup exhibit freshness + hygiene (audit A6, B1, B4)

- [x] **4.1 Exhibit registry.** (`2e22c11` — ~35 exhibits, master-stamped.) `Plans/exhibit_registry.md`: one row per manuscript-bound
  exhibit (output file, generating script, R version, inputs, master-build stamp,
  post-dedup? y/n, essay/section). Seed from the writing plan §10 table/figure lists.
- [x] **4.2 Re-run manuscript-bound families on the certified master** (`2e22c11`; prose portion
  `980b1d7` — all families post-dedup, every headline <0.15 SE; hospital panel proven exactly
  dedup-invariant; event_study/mechanism_verdict stale claims resolved. Phase-5 residuals: delta
  synthesis headline stamp; descriptive synthesis rename.) (delta, cumulative
  dose, exposure index, persistent exposure, mechanisms as needed); stamp outputs; archive
  stale versions; B1 stale-prose cleanup (hospital synthesis body below the banner;
  latent-hardship "pre-dedup" label → certified-invariant; AQI memo superseded-by note).
- [x] **4.3 FIPS + logging hygiene (B4, B3 scoped).** (`980b1d7` — pad_fips + open_build_log
  in pipeline_utils.R; 9/9 integrity tests incl. master/premiums/debt FIPS scans; B1 prose
  cleanup done in the same commit — hospital §B, latent-hardship label+generator, AQI memo,
  county synthesis. Residual for 4.2 landing: mechanism_verdict.md −2,011; event_study
  synthesis manual-CS + Midwest.) `pad_fips()` in `pipeline_utils.R`;
  repo test scanning built intermediates for 5-char county FIPS; build-log helper used by
  scripts this track touched.
- [x] **Phase 4 checkpoint** — verification gate + git note. [checkpoint: 81c841e] *(author sign-off 2026-07-13.)*

## Phase 5: Final clean-room reproduction (audit §6 Phase 5 / §7 gate)

- [x] **5.1 Fresh-session reproduction:** (masters byte-identical — SHA-256s recorded;
  32/32 suites exit 0; 13/13 headline rows match; certificate written; residual synthesis
  stamps applied.) rebuild both masters without downloads; run the
  exhibit registry's scripts; run the fixed aggregate test runner; compare every headline
  number against `Plans/master_evidence_table.md`; record the run in
  `Analysis/reproduction_certificate.md`.
- [x] **5.2 Final evidence-table refresh** (table → FROZEN-READY; certified magnitudes
  locked into table/abstracts/errata/registry) + §7 checklist ticked in `spec.md` with
  evidence; econometrics.md lessons merged; INDEX rows added.
- [x] **Conductor — User Manual Verification 'Code-Quality Remediation' (Protocol in
  workflow.md).** [checkpoint: 81c841e] *(author sign-off 2026-07-13; §7 gate ALL MET —
  track complete.)*

---

### Notes / lessons (live)

- **The audit's core rule governs:** no new models. Anything that looks like a new
  specification goes to the parking lot, not the code.
- **Deferred by design** (spec Overlap map): full pipeline DAG (A2 maximal), blanket
  coverage (B2), lockfile (C1), `Household_Income_2023` rename (C4 — 15+ consumers;
  naming note in data-pipeline.md instead).
