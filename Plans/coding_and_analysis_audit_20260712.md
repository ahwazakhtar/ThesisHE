# Coding and Analysis Audit

## Climate Shocks and the Financial Health of American Households

**Date:** July 12, 2026  
**Scope:** Read-only audit of the R codebase, executable tests, pipeline structure, output traceability, model specifications, post-dedup consistency, and headline empirical results.  
**Purpose:** Determine whether the reported results are reproducible and internally consistent, identify coding or econometric weaknesses that could change interpretation, and prioritize corrections before manuscript tables are frozen.

---

## 1. Executive verdict

### Overall result

The principal dissertation findings are **internally traceable and mostly well defended**, but the repository is not yet in a state where a single command provides a trustworthy full verification.

The strongest result—the 2012 drought effect on per-capita income—passes the audit. Its point estimate, analytic inference, wild-cluster bootstrap, randomization inference, doubly robust estimate, long pretrend, leave-one-state-out envelope, and placebo result agree across the relevant scripts, outputs, and master evidence table.

The main risks are concentrated in five areas:

1. The aggregate test runner is **false-green**: it reports exit code 0 even when many test files error.
2. Many secondary outputs have not been regenerated after the county-master deduplication.
3. The premium mediation script reconstructs rating-area data from a county master that no longer preserves the full county × rating-area structure.
4. The older hand-rolled “Callaway–Sant’Anna” event-time aggregation uses an invalid independence approximation for standard errors; the later `did::att_gt` frontier results should be authoritative.
5. Several recurring-panel specifications include contemporaneous household income and uninsurance controls that may be outcomes or mediators of climate shocks; headline conclusions require no-control sensitivity.

### Audit rating

| Area | Assessment |
|---|---|
| Headline result traceability | Strong |
| County-master key integrity | Strong after deduplication |
| Targeted unit tests | Strong when run individually |
| Repository-wide test command | Failing / false-green |
| Pipeline completeness | Incomplete |
| Output freshness | Mixed |
| Main 2012 DiD identification | Strong |
| Recurring-treatment and persistence inference | Mixed; estimator-dependent |
| ACA premium analysis | Institutionally thoughtful, but rating-area input must be corrected |
| Documentation consistency | Mixed; several stale narratives remain |
| Defense readiness of codebase | Close, after the high-priority fixes below |

---

## 2. What was executed

### Repository inventory

- 137 R scripts under `Code/`
- 31 test files under `Code/tests/`
- Multiple R environments:
  - R 4.2.2 for the main pipeline
  - R 4.5.3 for frontier DiD packages

### Aggregate test command

Executed:

```powershell
& "C:\Program Files\R\R-4.2.2\bin\Rscript.exe" Code/tests/testthat.R
```

Observed behavior:

- The command ended with exit code 0.
- Numerous test files errored after failing to locate `Code/...` paths.
- The errors began after an earlier `test_file()` invocation changed the working directory.
- The runner continued and returned success despite those failures.

Conclusion: this command cannot currently be used as evidence that the test suite passes.

### Critical suites rerun independently

Each of the following was run in its own R process from the repository root and returned exit code 0:

- `test_county_master_dedup.R`
- `test_did_robustness.R`
- `test_falsification_suite.R`
- `test_premium_mediation.R`
- `test_passthrough_bounds.R`
- `test_hospital_winsorize.R`
- `test_hospital_incidence.R`
- `test_hospital_heterogeneity.R`
- `test_latent_hardship.R`
- `test_cumulative_dose.R`
- `test_delta_variables.R`
- `test_run_event_study.R`

Warnings that packages were built under R 4.2.3 while running R 4.2.2 were observed. These are not substantive failures, but the production environment should eventually be harmonized.

### Pipeline dry run

Executed successfully:

```powershell
& "C:\Program Files\R\R-4.2.2\bin\Rscript.exe" Code/run_pipeline.R `
  --pipeline county --phases analysis --dry-run
```

The runner recognizes only the core county analysis step at the analysis phase. It does not orchestrate the event-study, delta, cumulative-dose, exposure-index, mechanism, hospital, mediation, or frontier DiD families.

---

## 3. Verified headline results

### 3.1 The 2012 drought income result passes

Verified across:

- `Analysis/did/robustness/did_robustness_summary.md`
- `Analysis/did/robustness/falsification_summary.md`
- `Analysis/county_dedup_integrity.md`
- `Plans/master_evidence_table.md`
- `Code/did_robustness/*`

Consistent results:

| Check | Result |
|---|---:|
| 2×2 DiD ATT | −$1,310.67 per capita |
| Analytic p-value | 0.0277 |
| Wild-cluster bootstrap p-value | 0.0362 |
| Randomization-inference p-value | 0.0075 |
| WCB confidence interval | approximately [−$2,911, −$138] |
| Doubly robust ATT | −$1,451.27 |
| DR confidence interval | approximately [−$2,461, −$441] |
| 1990–2011 differential trend | −$69/year, p=0.44 |
| Leave-one-treated-state-out envelope | [−$1,687, −$914] |
| Placebo-onset p-value | 0.009 |
| Change after county deduplication | exactly zero |

Verdict: **verified and suitable as the primary causal result**, with the maintained wording that it is an event-specific ITT rather than a universal drought response function.

### 3.2 The 2012 employment result is numerically verified but substantively fragile

Verified values:

- Baseline ATT approximately −2,043 jobs
- WCB p≈0.003
- RI p≈0.037
- DRDID approximately −871 jobs
- Pooled simple estimator reverses sign
- Leave-one-state-out estimates are geographically stable

Verdict: the code supports the stated interpretation: inference is not the main weakness; conditioning and cross-cohort generalization are. It should remain secondary.

### 3.3 Medicare utilization and spending results are traceable

Verified in `Analysis/mechanism/medicare_channel_coefs.csv`, the mechanism synthesis, and the evidence table:

- Heat → standardized spending approximately +$112 contemporaneously
- Heat lag 1 → approximately +$177
- Heat → ED visits approximately +7.8 per 1,000
- Heat lag 1 → approximately +9.5 per 1,000
- Cold lag 2 → positive spending and ED responses

The generating model uses county and year fixed effects, state clustering, and Medicare controls including MA enrollment, dual-eligibility share, and beneficiary count.

Verdict: **numeric trail verified**. Interpretation must remain limited to Medicare beneficiaries and must not be presented as mediation of the drought-income result.

### 3.4 Drought debt asymmetry is traceable

Verified in the delta synthesis and evidence table:

- Onset + exit asymmetry at horizon 2 ≈ +0.0182
- p≈0.0015

Verdict: the calculation is traceable and the transition-symmetry helper is tested. Interpretation remains limited by debt measurement, migration, and contemporaneous-control concerns discussed below.

### 3.5 ACA premium bounds reproduce post-dedup

Verified in:

- `Analysis/mediation/premium_passthrough.csv`
- `Analysis/mediation/passthrough_bounds.csv`
- `Analysis/mediation/passthrough_bounds_summary.md`
- `Analysis/county_dedup_integrity.md`

Post-dedup primary drought result:

- Estimate ≈ $3.17 per month
- SE ≈ $2.57
- Equivalence bound δ* ≈ $7.40
- Full-morbidity benchmark ≈ $9.33–$14.75 per month

Verdict: the drought bound is arithmetically reproducible. The cross-level sign-instability verdict is supported. The rating-area construction problem in Finding A3 must nevertheless be corrected before final publication tables.

### 3.6 Hospital winsorization conclusions are traceable

Verified:

- Heat × safety-net uncompensated-care interaction survives winsorization.
- Hospital operating-margin cumulative-dose result loses significance.
- Drought dollar incidence falls materially in magnitude.

Verdict: the revised interpretation is correct. Some older prose below the correction banner still describes the superseded raw results and should be regenerated or rewritten.

### 3.7 Latent-hardship result is correctly reported as narrow/null

Verified:

- All primary interactions attenuate in the predicted direction.
- Only drought × uninsurance survives multiplicity correction, q≈0.012.
- Rurality and hospital-access evidence is underpowered.

Verdict: the evidence table’s narrow coverage/credit-visibility language is appropriate.

---

## 4. Findings and required corrections

## A. Critical and high-priority findings

### A1. Repository test runner returns a false success

**Severity:** Critical for reproducibility; does not invalidate estimates already checked.

`Code/tests/testthat.R` loops over `testthat::test_file()`. After the first invocation, later tests execute from a different working directory and cannot source repository-relative files such as `Code/cumulative_dose.R`. Despite multiple errors, the process exits 0.

Risk:

- A session or CI job can claim “tests pass” when most tests did not run.
- Conductor verification records may rely on a false-green command.

Required fix:

1. Normalize and restore the repository working directory before every test file.
2. Collect `test_file()` results and explicitly stop if any failure or error occurs.
3. Prefer `testthat::test_dir()` with a helper that establishes the project root, or invoke every test in a clean R process.
4. Add a deliberately failing fixture test for the runner itself and confirm a nonzero exit.

Until fixed, use separate `Rscript Code/tests/test_*.R` invocations.

### A2. Large portions of the analysis are outside the unified pipeline

**Severity:** High.

`run_pipeline.R` covers the main state/county acquisition, processing, merge, and base analysis steps. It does not register most dissertation-defining analyses:

- DiD frontier
- Event study / local projections
- Delta and transition symmetry
- Cumulative dose
- Persistent exposure
- Exposure index
- Mechanism analyses
- Hospital analyses
- Premium mediation and bounds
- Latent hardship

Risk:

- A clean rebuild cannot reproduce the dissertation with one documented execution graph.
- Outputs can silently reflect different master-data vintages.

Required fix:

- Add a manuscript-oriented analysis registry or a second `run_dissertation_analysis.R` orchestrator.
- Record dependencies, R version, required inputs, outputs, and whether a step is optional/frontier.
- Support `--list-steps`, `--dry-run`, and strict output verification.
- Do not put downloads on the default manuscript rebuild path.

### A3. Rating-area pass-through is currently constructed from the wrong post-dedup object

**Severity:** High for the ACA premium chapter; current qualitative verdict appears stable.

`run_premium_mediation.R` reads `Data/county_level_master.csv` and comments that its rating-area panel is built from “raw split-county RA rows.” After the upstream deduplication, that statement is no longer true. A split county now has:

- An average of its rating-area premiums
- One representative/minimum rating-area identifier

The script therefore aggregates averaged county premiums into one representative rating area instead of reconstructing the full county × rating-area structure.

Risk:

- Rating-area composition and population weights are distorted for split counties.
- The RA-level estimate is coupled to the county collapse rule.
- The analysis is no longer an exact institutional-level panel.

Required fix:

1. Build the RA panel from `Data/premiums_county.csv` or a dedicated county × rating-area × year source panel.
2. Join county shocks and population to that source using a documented allocation rule.
3. Avoid assigning full county population to every rating area. If sub-county population shares are unavailable, report equal-area allocation and alternative rules.
4. Rerun premium mediation and equivalence bounds.
5. Compare the corrected estimate with the current $3.17/SE $2.57 result.

The existing mean-vs-min rule comparison suggests the drought-bound verdict is unlikely to reverse, but that is not a substitute for the correct RA source panel.

### A4. Older manual “Callaway–Sant’Anna” standard errors assume independent cohort estimates

**Severity:** High for any claim sourced from `run_did_analysis.R` event-time p-values.

The manual event-time aggregation in `Code/run_did_analysis.R` computes:

```r
ATT_se_avg = sqrt(sum((Std_Error * weight)^2) / sum(weight)^2)
```

This treats cohort-time estimates as independent. They share never-treated controls and therefore generally have nonzero covariance. The procedure is also a sequence of canonical 2×2 regressions, not the full doubly robust Callaway–Sant’Anna estimator.

Risk:

- Event-time standard errors and p-values can be too small.
- The “CS-DiD confirms” language can overstate estimator sophistication.

Mitigation already present:

- The R 4.5.3 frontier layer uses `did::att_gt(est_method="dr")` and `did::aggte()`, which carry the appropriate influence-function covariance.

Required rule:

- Source pooled and event-time inference only from `Analysis/did/robustness/dr_csdid_*` outputs.
- Relabel the older `run_did_analysis.R` block as a descriptive/manual cohort aggregation.
- Remove its p-values from headline prose or replace them with frontier-layer values.
- Add a provenance column to any table that currently mixes the two CS implementations.

### A5. Contemporaneous income and uninsurance controls may be bad controls

**Severity:** High for recurring-panel, delta, transition, and dose interpretations; not relevant to the primary 2012 DiD, which deliberately uses baseline covariates.

Several scripts use:

```r
controls <- c("Household_Income_2023", "Uninsured_Rate")
```

`Household_Income_2023` is not a fixed 2023 baseline. It is annual household income expressed in 2023 dollars. Both income and insurance coverage may respond to climate shocks and local economic changes.

Affected scripts include:

- `run_county_analysis.R`
- `run_delta_analysis.R`
- `run_cumulative_dose.R`
- Related persistence specifications

Risk:

- Conditioning can block part of the effect being estimated.
- For employment, income is especially likely to be a mediator or jointly determined outcome.
- For debt, uninsurance and income are plausible mechanisms, not clean confounders.
- “Total effect” language becomes inappropriate.

Required fix:

- Make the no-control specification primary for weather shocks under county and year fixed effects.
- Present contemporaneous-control models as mediation/sensitivity specifications.
- Alternatively use pre-study or lagged baseline values when the estimand requires adjustment.
- Produce a same-sample coefficient comparison with no controls, lagged controls, and contemporaneous controls for every headline transition/dose result.

### A6. Post-dedup output freshness is incomplete

**Severity:** High for secondary results and figures; headline rows were checked and preserved.

The master was rebuilt on July 12/13, while many output families predate it:

- Cumulative dose: June 14
- Delta: June/early July
- Event-study figures: March
- Exposure index: June
- Mechanisms: July 1–6
- Persistent exposure: May/June
- Descriptive plots: March

The dedup integrity report found 64 of 180 base county coefficient cells moved by more than 0.1 pre-dedup SE, concentrated in population-weighted specifications, with a maximum movement of 1.28 SE.

Risk:

- Secondary tables and plots may not correspond to the current master.
- A manuscript could combine post-dedup headline estimates with pre-dedup supporting exhibits.

Required fix:

1. Build an exhibit registry.
2. Identify every output intended for a manuscript.
3. Rerun its generating script on the current master.
4. Stamp each output with input-file hash or master build identifier.
5. Do not cite uncatalogued exploratory population-weighted coefficients.

---

## B. Medium-priority findings

### B1. Several synthesis files contain superseded prose below correction banners

Examples:

- Hospital synthesis retains the raw cumulative-dose margin discussion even though the winsorized result fails.
- Latent-hardship synthesis still labels itself “pre-dedup,” although its estimates are certified invariant.
- Historical inconsistency memo still claims state AQI is unweighted, while `process_aqi_data.R` now implements strict population weighting and an equal-weight robustness series.

Risk:

- Search results can surface the obsolete paragraph rather than the correction.
- Authors may copy stale language into manuscripts.

Required fix:

- Regenerate or edit synthesis files so only the current verdict remains in the body.
- Preserve historical findings in `_archive/` or changelog entries, not contradictory live prose.
- Add “superseded by” metadata to historical memos.

### B2. Test coverage is uneven relative to the number of scripts

There are 137 R scripts and 31 test files. Critical helper logic is tested, but many full analysis families depend primarily on output-schema checks or have no direct test file.

Gaps include:

- State primary analysis
- County base analysis model construction
- Exposure secondary/state analysis
- Several mechanism scripts
- Multiplicity implementation
- Conley implementation
- RMA buffer analysis
- Full synthesis generators

Required fix:

- Do not target blanket line coverage for estimation scripts.
- Add small synthetic-data tests for estimand recovery, sample construction, weighting, clustering formula construction, and coefficient extraction.
- Add schema and provenance tests for every manuscript exhibit.

### B3. Self-logging and provenance headers are inconsistent

Some recent mechanism scripts self-log cleanly to `Analysis/<family>/build_logs/`. Older scripts often sink only the model output or do not create a timestamped build log. Purpose/provenance headers are also inconsistent.

Required fix:

- Standardize a shared `open_build_log()` helper.
- Log session info, R version, package versions, input hashes, row counts, unit counts, years, clusters, exclusions, and warnings.
- Make scripts close sinks reliably through `on.exit()`.

### B4. FIPS handling remains inconsistent across scripts

Some scripts use `read.csv()` and later pad FIPS; others rely on parsing behavior. The project has already experienced a serious space-padding failure.

Required fix:

- Centralize `pad_fips()` in `pipeline_utils.R`.
- Read FIPS as character explicitly wherever possible.
- Add a repository test that scans built intermediates for five-character county FIPS.

### B5. Primary and robustness clustering labels need harmonization

The county analysis generates rating-area-clustered variants for premium outcomes, while the institutional premium analysis argues that state clustering is primary because shocks and regulatory review induce within-state dependence.

This is not necessarily contradictory, but manuscript tables could make it look so.

Required framing:

- State clustering is primary for causal/institutional premium interpretation.
- Rating-area clustering is a mechanical shared-price sensitivity check.
- Never select significance using the tighter RA standard errors.

### B6. Cumulative-dose estimates should be described as exposure-history associations

Cumulative shock years are mechanically increasing and correlated with geography, climate regime, adaptation, migration, and survival in the panel. County and year fixed effects do not automatically make high cumulative dose as-good-as-random.

Required framing:

- Treat dose bins as descriptive within-county exposure-history contrasts.
- Do not interpret the tenth-vs-first comparison as the marginal causal effect of ten exogenously assigned shock years.
- Lead with agreement across binned, event-time, and recurring-treatment estimators where it exists; disclose disagreement prominently.

---

## C. Lower-priority hygiene findings

### C1. Package-version mismatch warnings

Several packages were built under R 4.2.3 but are run under R 4.2.2. The tests passed, but exact reproduction should use a lockfile or recorded package library.

### C2. Output tracking is difficult to inventory

Many data and analysis outputs are ignored or untracked, so `rg --files` does not provide a full output inventory. A manifest is needed.

### C3. Some filenames encode outdated concepts

“Event study” persists in filenames for recurring treatments even where the prose now calls the design an impulse response. Renaming is optional, but table labels should use the correct estimand.

### C4. Control-variable naming is misleading

`Household_Income_2023` sounds like a fixed baseline but means income measured annually in constant 2023 dollars. Rename it to something like `Household_Income_Real_2023USD` to prevent future misuse.

---

## 5. Result-by-result confidence assessment

| Finding | Code/result verification | Econometric confidence | Required action |
|---|---|---|---|
| 2012 drought → PCPI | Verified | High for event-specific ITT | Freeze after final exhibit rerun |
| 2012 drought → employment | Verified | Moderate/fragile | Keep secondary |
| Pooled drought e=0 income | Traceable to frontier `did` output | Moderate | Use only `did::att_gt/aggte` inference |
| Cold → state medical-debt share | Traceable | Moderate; FE association and measurement limits | Keep confirmatory |
| Drought debt exit asymmetry | Traceable | Moderate-low until no-control sensitivity | Rerun control variants |
| Heat/cold → Medicare use | Verified | Moderate-to-high association | Keep population limitation |
| Cold employment compounding | Numerically traceable | Moderate-low; estimator and control dependence | Re-estimate post-dedup/no-control; foreground disagreement |
| ACA no coherent pass-through | Qualitatively supported | Moderate | Correct RA input before final table |
| Drought equivalence bound | Arithmetically verified | Provisional pending RA correction | Rerun from source RA panel |
| Heat × safety-net hospital strain | Verified and winsorization-robust | Moderate | Keep location/catchment caveat |
| Debt visibility gradient | Verified narrow result | Low-to-moderate | Claim drought × uninsurance only |
| CHEI composite income result | Traceable | Exploratory | Do not treat as causal price |

---

## 6. Recommended verification sequence

### Phase 1 — Make verification trustworthy

1. Fix `Code/tests/testthat.R` so failures return nonzero.
2. Run all tests in clean processes.
3. Save a machine-readable test report.
4. Add the test-runner regression test.

### Phase 2 — Correct the two analysis-source issues

1. Rebuild the premium RA panel from its source county × rating-area data.
2. Rerun pass-through, mediation, and bounds.
3. Mark the manual CS aggregation as descriptive.
4. Ensure every pooled CS claim uses R 4.5.3 `did::att_gt/aggte` outputs.

### Phase 3 — Re-estimate potentially bad-control specifications

For county, delta, transition, and dose headlines, run identical-sample variants:

1. No controls
2. Lagged or baseline controls
3. Contemporaneous controls

Create one comparison table reporting coefficient, SE, N, and percent change.

### Phase 4 — Refresh manuscript outputs

1. Create exhibit registry.
2. Rerun only scripts needed for the dissertation.
3. Confirm post-dedup input hash.
4. Regenerate syntheses and figures.
5. Archive stale outputs.

### Phase 5 — Final independent reproduction

From a fresh R session:

1. Build the county and state masters without downloads.
2. Run manuscript analysis registry.
3. Run all tests.
4. Compare every headline number against the evidence table.
5. Verify all tables and plots have generating scripts and current timestamps/hashes.

---

## 7. Minimum defense gate

Before calling the empirical package frozen:

- [ ] Aggregate tests fail correctly when a test is intentionally broken.
- [ ] All critical tests pass in clean R processes.
- [ ] Rating-area premium results are rebuilt from source RA data.
- [ ] No headline uses the manual-CS independence standard errors.
- [ ] Transition and dose headlines have no-control/lagged-control sensitivity.
- [ ] All manuscript exhibits are post-dedup.
- [ ] Stale synthesis prose is removed or archived.
- [ ] Input/output manifest records hashes and R/package versions.
- [ ] `Plans/master_evidence_table.md` is refreshed one last time.

---

## 8. Final assessment

The audit did **not** find evidence that the central 2012 drought-income result is a coding artifact. That result is unusually well protected and reproduces across independent layers.

The audit did find that the repository’s verification surface overstates its reliability: the aggregate test runner is false-green, the unified pipeline covers only a fraction of the dissertation, and some secondary outputs remain tied to pre-dedup data. Two econometric implementation issues—the rating-area reconstruction and manual cohort-aggregation covariance—must be corrected or explicitly quarantined.

After those fixes and a focused bad-control sensitivity pass, the analysis package should be strong enough for a defensible economics dissertation. The correct strategy is not to add new models; it is to make the existing results reproducible from clean inputs, ensure each headline uses the strongest available estimator, and remove stale or superseded evidence from the live manuscript path.
