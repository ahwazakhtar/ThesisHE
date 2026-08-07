# Analysis Index

One folder per analysis family. Each folder holds the family's outputs; where a narrative
exists it is named **`synthesis.md`** and is the file to read first. Machine outputs
(`*_coefs.csv`, `*_results.txt` sink dumps, inventories) sit beside it; run logs go in
`build_logs/`. Figures live centrally in `plots/<family>/`.

**Convention: never write a new output to the `Analysis/` root.** New scripts write to
`Analysis/<family>/` (create the folder if the family is new) and add a row here.
This index is refreshed at session end.

| Folder | What it answers | Headline | Read first |
|---|---|---|---|
| `state/` | State-level FE models: climate shocks → premiums, debt, macro outcomes | Drought/heat effects on premiums & debt at state level; anchor for cross-level comparison | `synthesis.md` |
| `county/` | County-level FE models (state-clustered), incl. VIF & sample diagnostics | Headline county results; drought block pruned to PDSI-only (VIF) | `synthesis.md` |
| `descriptive/` | Descriptive stats, missingness, period comparisons (+ LaTeX tables) | Panel coverage & summary tables for the write-ups | `synthesis.md` |
| `event_study/` | Dynamic impulse-response event studies, 5 shocks + compounds | **Drought debt scar at h=2**; shock-specific dynamics | `synthesis.md` |
| `delta/` | Transition (entry/exit) symmetry of shock effects | Entry/exit asymmetries by shock and outcome | `synthesis.md` |
| `cumulative_dose/` | Dose–response in cumulative shock-years | **Cold employment effects compound with cumulative exposure** | `cumulative_dose_marginal.csv` |
| `persistent_exposure/` | Persistently-exposed vs never-exposed cohort contrasts | Persistence of harm in repeatedly-shocked counties | `synthesis.md` |
| `exposure_index/` | CHEI exposure index × SVI interactions (EJ layer) | **Climate harm amplified in high-SVI counties** (income/employment/premiums; debt is measurement-fragile) | `synthesis.md` |
| `threshold_sensitivity/` | Sensitivity of shock-threshold definitions | Headline results robust to threshold choice | `threshold_sensitivity_coefs.csv` |
| `demographic_mediators/` | Do demographics confound/mediate the shock effects? | **No** — headline findings survive demographic adjustment | `demographic_mediator_decomposition.csv` |
| `robustness/` | FE vs RE specification (Hausman) | FE required; RE rejected where unit effects correlate with shocks | `synthesis.md` |
| `hospital/` | Hospital-year supply side: incidence, persistence, provider heterogeneity | Provider-finance responses to shocks by ownership/safety-net status | `synthesis.md` |
| `did/` | 2012 drought-cohort DiD + frontier robustness (CS, DRDID, HonestDiD, WCB/RI) | **Income effect robust** (−$1,311, p_wcb 0.036); employment fragile; effect is event-specific ITT | `robustness/did_robustness_summary.md` |
| `did/robustness/` (falsification) | LOO-treated-state + placebo-onset falsification for the 2012 2×2 (audit_response 2.2–2.3) | **Passed**: no single state drives income (envelope [−1,687, −914], no WCB-CI exits); placebo p=0.009 | `robustness/falsification_summary.md` |
| `mechanism/` | Which channel carries the climate→economy effect? | **Agriculture is one channel, not the channel**; lead with Medicare morbidity + broad labor exposure | `mechanism_verdict.md` |
| `mediation/` | Premium pass-through and premium-mediation of debt effects | **No coherent pass-through**; 92–99% of shock→debt effect survives premium adjustment | `premium_mediation_summary.md` |
| `mediation/` (bounds) | MDE/TOST equivalence bounds on the premium null (audit_response 2.1) | **Hazard-split**: drought rules out >43–68% of full morbidity-cost pass-through; heat/cold bounded ≈5–8% of mean premium, not tightly | `passthrough_bounds_summary.md` |
| `hospital/` (winsorization) | Winsorization verification of hospital accounting levels (audit_response 2.4) | Heat×safety-net **robust** (p=.013); cumulative-dose margin **fails** (demoted); drought $ incidence −$3.88M winsorized | `winsorization_verification.md` |
| `latent_hardship/` | Pre-registered observed-vs-latent hardship gradients (audit_response 3.1–3.2) | **Honest null** vs the ≥2/3 bar: all cells attenuate as predicted but only drought×uninsurance robust (q=.012); claim coverage/credit-visibility only | `latent_hardship_summary.md` |
| `county_dedup_integrity.md` | One-row-per-county-year certification + before/after (thesis_completion 2.2) | **Headlines preserved**: 2012 DiD identical, debt cells <0.08 SE; 64 exploratory pop-weighted cells corrected (double-counting bug) | `county_dedup_integrity.md` |
| `control_sensitivity/` | Same-sample no-/lagged/contemporaneous control variants for headline cells (code_quality 3.1) | **Headlines control-robust**; county debt cells are SAMPLE-fragile (measurement caveat, not bad controls) | `control_sensitivity_summary.md` |
| `test_reports/` | Machine-readable output of the truthful aggregate test runner | 32/32 suites pass in clean processes (runner exits nonzero on any failure) | `test_report.md` |
| `reproduction_certificate.md` | Clean-room reproduction (code_quality 5.1) | **Masters rebuild byte-identically; 32/32 tests; 13/13 headline rows match the evidence table** | `reproduction_certificate.md` |
| `wet_shock/` | Pre-registered wet-extreme precipitation bin (reviewer-requested; thesis_completion T1.6) | **Honest null**: 0/12 cells at q<0.10 — no level channel beyond the documented swing/deficit margins; appendix tier | `wet_shock_summary.md` |
| `policy/` | Sufficient-statistics scenario bands, unpriced floor, concentration, RMA benchmark (thesis_completion T1.3) | **2012 event −$7.1B; drought unpriced floor 21–50%; cold band 2.4× top-decile; RMA ratio 3.7×**; bands never summed | `sufficient_stats_summary.md` |
| `advisor_robustness/` | Aug-2026 advisor package: spillovers, AAIW clustering grid, window & horizon robustness, MAD impulse scaling | **All headlines survive or strengthen**: spillovers amplify (not confound); state clustering ≈ Conley 200km; drought income stable to 1990; debt scar = 45% of a typical annual move | `synthesis.md` |
| `pathways/` | Descriptive pathway decompositions (early exploratory) | Motivating descriptives for the mechanism work | `synthesis.md` |
| `memos/` | Cross-cutting reviews & memos (dated Feb–May 2026; some superseded by later tracks) | Econometric review, feasibility memos, interpretation guides | `econometric_review.md` |
| `plots/` | All figures, one subfolder per family | — | — |
| `_archive/` | Debris kept for provenance (editor tmp, LaTeX aux/log) | — | — |

## Notes

- Several `synthesis.md` files are **script-generated** and will be overwritten on re-run:
  `event_study/` (by `synthesize_event_study.R`), `descriptive/` (by `run_descriptive_stats.R`).
  Hand-edits belong in `Text/`, not in generated files.
- `state/synthesis.md` is appended to by `run_re_robustness.R` (RE robustness section).
- Historical documents (`conductor/tracks/*/plan.md`, `changelog.md`) still cite pre-July-2026
  root paths (e.g. `Analysis/regression_results_summary.csv`); those records were left
  untouched deliberately. The mapping is: old root file → `Analysis/<family>/<same name>`,
  with each family's primary narrative renamed to `synthesis.md`.
