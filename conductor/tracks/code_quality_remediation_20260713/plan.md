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

- [ ] **0.1 Stand up the track** (spec, plan, registry, CLAUDE.md snapshot line). Commit.
- [ ] **0.2 A4 prose correction (orchestrator — permitted-language change).** Replace the
  "immediate income hit generalizes (−$1,050, p=0.002)" nuance with the frontier verdict
  (CS_dr_dynamic e=0 = −$324, SE 276, null; 2012 event-specific even at onset) in:
  evidence-table Row 1 (robustness + permitted language), Essay 1 abstract,
  `conference_abstract_ERRATA.md` amendment 2, audit_response spec fact-check (dated
  amendment, not silent rewrite), re-audit addendum (one-line superseded-by note),
  `Analysis/did/did_results.md` §3 (descriptive-only banner). Grep for stray "1,050"
  citations before closing.

## Phase 1: Truthful verification (audit A1)

- [ ] **1.1 Fix the aggregate runner.** `Code/tests/testthat.R`: run every
  `Code/tests/test_*.R` in a **clean R process** from the repo root (`system2` on
  R 4.2.2), capture per-file exit codes, print a summary table, exit nonzero if ANY file
  fails; emit a machine-readable report (`Analysis/test_reports/test_report.csv` +
  timestamp/R-version stamp).
- [ ] **1.2 Runner regression test.** A deliberately failing fixture (gated so it only runs
  when the runner tests itself, e.g. `TESTTHAT_SELFTEST=1`) proving the runner exits
  nonzero on failure; document the invocation in the runner header.
- [ ] **Phase 1 checkpoint** — verification gate + git note.

## Phase 2: Analysis-source corrections (audit A3 + A4 code side)

- [ ] **2.1 Rebuild the RA panel from source (A3).** `run_premium_mediation.R`: build the
  rating-area panel from `Data/premiums_county.csv` (county × Year × rating_area_id), NOT
  from the deduped master's premium columns; join county shocks/population with a
  documented allocation rule (equal-split across a county's RAs as primary — sub-county
  population shares don't exist — plus an alternative rule as sensitivity; never assign
  full county population to every RA). Re-run mediation + `run_passthrough_bounds.R`
  (update its anchors by the dated-note pattern if numbers shift); compare against
  β=3.17/SE=2.57/δ*=7.40 and report whether the drought STRONG verdict and the 92–99%
  mediation corollary hold. **Test:** extend `test_premium_mediation.R` — RA panel row
  count = source panel count; split-county population never double-assigned.
- [ ] **2.2 Quarantine the manual CS aggregation (A4 code side).** `run_did_analysis.R`:
  descriptive-only header note at the aggregation block (invalid independence SEs, pointer
  to the frontier layer); drop or clearly relabel its p-value column in
  `did_cs_event_time.csv` on next regeneration; banner in `Analysis/did/did_results.md`
  (done at 0.2 if not before). **Test:** none (labeling); verified by grep.
- [ ] **Phase 2 checkpoint** — verification gate + git note.

## Phase 3: Bad-control sensitivity (audit A5)

- [ ] **3.1 Same-sample control-variant comparison.** New `Code/run_control_sensitivity.R`
  (R 4.2.2): for each headline transition/dose/county cell — cold→debt L1 (county),
  drought→debt L2 (county), drought debt onset/exit asymmetry h=2, cold cumulative-dose
  employment binned contrast — estimate three variants on the IDENTICAL estimation sample:
  (i) no controls (county+year FE only), (ii) lagged/baseline controls, (iii) current
  contemporaneous controls. Output one comparison table (coefficient, SE, N, %Δ vs
  no-control) → `Analysis/control_sensitivity/` + build log. **Expectation (recorded):**
  FE-purged weather shocks are quasi-random, so no-control coefficients should move
  modestly; a large collapse or amplification flags mediation and changes permitted
  language. **Test:** `testthat` — identical N across variants per cell; spec construction.
- [ ] **3.2 Fold verdicts in (orchestrator).** Evidence-table rows for the affected
  headlines updated (no-control primary for total-effect language; contemporaneous controls
  relabeled mediation/sensitivity); B6 dose-as-exposure-history framing and B5 clustering
  primacy (state primary, RA sensitivity, never select significance on RA SEs) written into
  the table's permitted language.
- [ ] **Phase 3 checkpoint** — verification gate + git note.

## Phase 4: Post-dedup exhibit freshness + hygiene (audit A6, B1, B4)

- [ ] **4.1 Exhibit registry.** `Plans/exhibit_registry.md`: one row per manuscript-bound
  exhibit (output file, generating script, R version, inputs, master-build stamp,
  post-dedup? y/n, essay/section). Seed from the writing plan §10 table/figure lists.
- [ ] **4.2 Re-run manuscript-bound families on the certified master** (delta, cumulative
  dose, exposure index, persistent exposure, mechanisms as needed); stamp outputs; archive
  stale versions; B1 stale-prose cleanup (hospital synthesis body below the banner;
  latent-hardship "pre-dedup" label → certified-invariant; AQI memo superseded-by note).
- [ ] **4.3 FIPS + logging hygiene (B4, B3 scoped).** `pad_fips()` in `pipeline_utils.R`;
  repo test scanning built intermediates for 5-char county FIPS; build-log helper used by
  scripts this track touched.
- [ ] **Phase 4 checkpoint** — verification gate + git note.

## Phase 5: Final clean-room reproduction (audit §6 Phase 5 / §7 gate)

- [ ] **5.1 Fresh-session reproduction:** rebuild both masters without downloads; run the
  exhibit registry's scripts; run the fixed aggregate test runner; compare every headline
  number against `Plans/master_evidence_table.md`; record the run in
  `Analysis/reproduction_certificate.md`.
- [ ] **5.2 Final evidence-table refresh** + minimum-defense-gate checklist ticked in
  `spec.md`; knowledge merge; registry close-out.
- [ ] **Conductor — User Manual Verification 'Code-Quality Remediation' (Protocol in
  workflow.md).**

---

### Notes / lessons (live)

- **The audit's core rule governs:** no new models. Anything that looks like a new
  specification goes to the parking lot, not the code.
- **Deferred by design** (spec Overlap map): full pipeline DAG (A2 maximal), blanket
  coverage (B2), lockfile (C1), `Household_Income_2023` rename (C4 — 15+ consumers;
  naming note in data-pipeline.md instead).
