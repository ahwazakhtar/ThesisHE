# Event Study Econometric Issues Backlog

Last updated: 2026-03-03
Scope: `Code/run_event_study.R` and related outputs/tests

## Summary Table

| ID | Severity | Status | Issue |
|---|---|---|---|
| E1 | High | Done | Design is dynamic recurring-shock response, not canonical staggered-adoption event study |
| E2 | High | Done | LP equations omit shock-history controls |
| E3 | High | N/A | Debt-reporting exclusion table is complete (CO 2023 only is correct per policy analysis) |
| E4 | Medium | Done | "Additive + interaction" spec is mislabeled (no interaction term estimated) |
| E5 | Medium | Done | Compound premium LP lacks rating-area clustered SE robustness |
| E6 | Medium | Done | Compound shock support is sparse (~2.24%), reducing precision |
| E7 | Medium | Done | Negative-horizon placebo setup uses contemporaneous controls with lagged outcomes |
| E8 | Low | Done | Tests are structural but not econometric-validating; naming drift in one test |

## Resolution Order

1. E3 (measurement validity for debt outcomes)
2. E2 (core dynamic identification in LP)
3. E1 (correct identification framing + design choice)
4. E7 (placebo interpretation cleanup)
5. E4 (spec labeling or true interaction implementation)
6. E5 (premium clustering robustness)
7. E6 (support diagnostics and reporting)
8. E8 (test suite hardening)

---

## E1: Not a Canonical Event Study Design

- Severity: High
- Why this matters:
  - Current models estimate responses to recurring shocks over time, not treatment timing relative to first adoption.
  - Standard staggered-adoption ATT interpretation does not follow from this setup.
- Evidence:
  - Script header describes event study framing: `Code/run_event_study.R:2`
  - DL specification uses leads/lags of recurring shock indicator in TWFE: `Code/run_event_study.R:203`
  - LP specification regresses shifted outcomes on contemporaneous recurring shock: `Code/run_event_study.R:290`
- Consequence if unchanged:
  - Over-claims in thesis text and potential reviewer criticism on identification.
- Fix options:
  - Option A (minimal): Keep models but rename as "dynamic panel impulse-response to recurring shocks" throughout text/tables.
  - Option B (full): Implement cohort-based relative-time design around first qualifying shock episode with clean treated/control timing logic.
- Acceptance criteria:
  - Chosen identification language is consistent in script headers, output filenames, tables, and thesis text.
  - If Option B is used, include explicit cohort/event-time construction and pre-trend tests tied to treatment timing.

## E2: LP Omits Shock-History Controls

- Severity: High
- Why this matters:
  - With serially correlated shocks, `beta_h` on shock at time `t` can pick up effects of nearby shocks.
  - Horizon profiles can mix persistence with causal dynamic effects.
- Evidence:
  - LP RHS only includes current shock + controls: `Code/run_event_study.R:288`
  - LP formula definition: `Code/run_event_study.R:290`
- Consequence if unchanged:
  - Dynamic coefficients may be biased/misinterpreted.
- Fix options:
  - Include a consistent lag/lead block of shock history in LP (e.g., `shock_{t-2}, shock_{t-1}, shock_t, shock_{t+1}` depending on horizon design).
  - Add robustness with alternative lag depth.
- Acceptance criteria:
  - LP spec explicitly documents included shock-history terms.
  - Main horizon results compared against no-history baseline in one diagnostic table.

## E3: Debt-Reporting Exclusion Incomplete

- Severity: High
- Why this matters:
  - Debt outcomes are vulnerable to reporting-rule changes that create measurement breaks.
  - Excluding only one state-year is likely insufficient.
- Evidence:
  - Hard-coded policy table has only CO 2023: `Code/run_event_study.R:30`, `Code/run_event_study.R:32`
- Consequence if unchanged:
  - Debt regressions may reflect reporting changes rather than economic effects.
- Fix options:
  - Replace hard-coded one-row policy object with full state-specific effective-year exclusions from the policy source used elsewhere in the pipeline.
  - Log excluded state-year counts by outcome.
- Acceptance criteria:
  - Exclusion table has all required states/years.
  - Script prints transparent exclusion diagnostics (rows dropped/NA-set by state-year and outcome).

## E4: "Additive + Interaction" Label Mismatch

- Severity: Medium
- Why this matters:
  - Current model description claims interaction, but equation includes only additive terms.
  - This can mislead interpretation of compound effects.
- Evidence:
  - Comment says "Additive + interaction": `Code/run_event_study.R:331`
  - Formula includes `Any_Shock + Compound_Shock + controls` only: `Code/run_event_study.R:332`, `Code/run_event_study.R:334`
- Consequence if unchanged:
  - Documentation/specification mismatch and interpretability risk.
- Fix options:
  - Rename to additive-only model, or
  - Add explicit interaction term (if econometrically justified and identified).
- Acceptance criteria:
  - Comment label, formula, and interpretation are aligned.

## E5: Missing Rating-Area Cluster Robustness for Compound Premium LP

- Severity: Medium
- Why this matters:
  - Premium outcome uses rating-area pricing structure; clustering only by state may understate uncertainty in some specs.
- Evidence:
  - Compound LP uses state clustering only: `Code/run_event_study.R:346`, `Code/run_event_study.R:356`
  - Main LP has RA-cluster branch for premium: `Code/run_event_study.R:304`
- Consequence if unchanged:
  - Inference inconsistency across premium models.
- Fix options:
  - Mirror RA-cluster estimation branch for compound premium LP specs.
- Acceptance criteria:
  - Compound premium LP exports both state-cluster and RA-cluster variants (or states clearly why not).

## E6: Thin Support for Compound Shock

- Severity: Medium
- Why this matters:
  - Compound events are rare, which inflates uncertainty and sensitivity to specification choices.
- Evidence:
  - Shock co-occurrence table in run log: `Analysis/run_event_study_20260303_134746.stdout.log:12`, `Analysis/run_event_study_20260303_134746.stdout.log:13`
  - Counts imply `Shock_Count >= 2` is 2,510 out of 112,267 non-missing county-years (~2.24%).
- Consequence if unchanged:
  - Compound coefficients may be unstable and over-interpreted.
- Fix options:
  - Keep as robustness/secondary analysis.
  - Add minimum-support diagnostics by horizon/outcome and report confidence interval width.
- Acceptance criteria:
  - Output includes support table for compound analysis and caveat language in write-up.

## E7: Negative-Horizon Placebo Timing Logic

- Severity: Medium
- Why this matters:
  - For `h < 0`, the dependent variable is past outcome (`y_{t-1}`, `y_{t-2}`), while controls are at time `t`.
  - This weakens interpretation of pre-trend/placebo coefficients.
- Evidence:
  - LP dependent variable mapping for negative horizons: `Code/run_event_study.R:277`, `Code/run_event_study.R:280`
  - Same contemporaneous RHS controls for all horizons: `Code/run_event_study.R:288`
- Consequence if unchanged:
  - Placebo failures/successes are harder to interpret causally.
- Fix options:
  - Horizon-specific control timing for placebo side (align controls to outcome time), or
  - Restrict placebo checks to specification where this timing is explicit and documented.
- Acceptance criteria:
  - Pre-trend interpretation section explains timing choice and corresponding equation.

## E8: Test Coverage Gap (Econometric Validity)

- Severity: Low
- Why this matters:
  - Tests mostly verify mechanics, not identification assumptions or robustness behavior.
  - One formula test uses `_Lag1/_Lag2` naming while script uses `_Lag1_es/_Lag2_es`.
- Evidence:
  - Test naming/formula block: `Code/tests/test_run_event_study.R:136`
  - Script DL term names: `Code/run_event_study.R:196`
- Consequence if unchanged:
  - False confidence from passing tests while econometric risks remain.
- Fix options:
  - Add tests for:
    - horizon-specific sample consistency checks,
    - presence of expected model terms in fitted formulas,
    - exclusion-policy application diagnostics.
  - Update lag-name assertions to match script.
- Acceptance criteria:
  - Test suite covers both transformation mechanics and key specification guarantees.

---

## Tracking Template (Use Per Issue)

Copy this block when starting an issue:

```md
### Issue E#
- Owner:
- Start date:
- Files touched:
- Decision:
- Implementation notes:
- Validation checks:
- Status: In progress / Done
```
