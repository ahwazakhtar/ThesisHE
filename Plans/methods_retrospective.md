# Methods Retrospective: How the Toolkit Evolved

**Purpose:** The methodological companion to `Plans/results_evolution_narrative.md` — not what was found, but how the estimation, inference, and design choices evolved; what triggered each change; which methods failed and were corrected; and what is worth carrying to future projects.
**Compiled:** 2026-07-06, from `Analysis/econometric_review.md`, `changelog.md` (2026-02-19 → 2026-07-02), the estimation scripts under `Code/` and `Code/did_robustness/`, and the track specs.

---

## 1. Methods timeline

| Stage (date) | Trigger | Method adopted | What it answered that the prior toolkit couldn't | Evidence |
|---|---|---|---|---|
| S1 (2026-02-19) | County drought was a state-level approximation | County PDSI/PHDI/PMDI replace state-broadcast drought; z-scoring dropped for already-standardized indices | Within-state, county-varying drought identification | `changelog.md` 2026-02-19; `process_county_climate.R` |
| S1 (2026-03-02) | `plm`+`sandwich` clumsy for high-dim FE + clustering | **`plm()`+`vcovHC()` → `fixest::feols(y ~ x \| State+Year, cluster=~State)`** | Fast two-way FE absorption; one-call clustered SEs; within-R² | `changelog.md` 2026-03-02; `run_analysis.R:1-60` |
| S2 (2026-03-02) | Look-ahead bias in shock definition | **Z-scores re-anchored to frozen 1990–2000 per-county baseline** (was full-sample) | Shocks become surprises relative to *pre-study* climate | `changelog.md` 2026-03-02; `process_county_climate.R` |
| S2 (2026-03-02) | Unweighted AQI mean; z-score AQI unreliable | EPA-threshold AQI; **strict population weights, no `Pop_Wt=1` fallback**; z-score `AQI_Shock` dropped | Uses the hard health thresholds AQI actually has; no silent imputation | `process_county_aqi.R`, `process_aqi_data.R` |
| S3 (2026-03-03) | Identical-by-construction prices within rating areas (review §1) | **State clustering primary + RA-clustered SE variants for premiums** | Honest inference when the price is coarser than the county | `run_county_analysis.R` `*_RA_Cluster` |
| S3 (2026-03-03) | VIF inflation from PDSI/PHDI/PMDI block (review §2A) | **VIF-based pruning** → `drought_vars_primary`; 9-var block demoted to robustness | Interpretable drought coefficients (max VIF ~4.96) | `Analysis/county_vif_diagnostics.txt` |
| S3 (2026-03-03) | Blanket CO/MN/NY exclusion over-dropped data | **Exclusion redesigned** via `debt_reporting_policy` table → CO-2023 only | Recovers ~2,600 county-years without contaminating the outcome | `run_county_analysis.R:33-90` |
| S3 (2026-03-03) | Annual-mean PDSI smooths transient droughts | **`pdsi_min`** (worst month) → `is_extreme_drought_peak` | Captures within-year drought peaks the mean hides | `process_state_climate.R` |
| S4 | Static distributed-lag TWFE can't trace dynamics | **Dynamic DL + Jordà local projections** h∈{−2..+3}; **renamed** "event study" → "impulse response to recurring shocks" | Onset timing, pre-trends, building effects; honesty about non-absorbing treatment | `run_event_study.R:1-9` |
| S6 (Persistence) | DL can't separate entering vs. leaving a shock | **Onset/Persist/Exit decomposition + symmetry Wald test**; **cumulative dose** + `lincom` | Hysteresis/scarring vs. reversibility; dose-response of accumulated exposure | `transition_symmetry.R`, `cumulative_dose.R` |
| S6 (Exposure) | No distributional/EJ lens | **Exposure index** (hazard × SVI × person-years); Shock×SVI interactions | Who bears the burden | `exposure_index.R` |
| Committee (Phase 1/3) | "Is FE right? Can this survive a sharp design?" | **Hausman RE test**; **2×2 never-exposed DiD** (2012 drought, 139 vs 2,534) | FE consistency confirmed; clean identification off never-treated controls | `state_analysis_summary.md` §6.1–6.2 |
| S7 (2026-06-25) | Few treated clusters, recurring treatment, single pre-period | **DRDID, Callaway–Sant'Anna, HonestDiD, wild cluster bootstrap** on isolated **R 4.5.3** | Conditional parallel trends; few-cluster inference; PT sensitivity | `did_frontier_robustness_20260625/spec.md`; `Code/did_robustness/` |
| S7 | Single pre-period blocks HonestDiD for 2012 | **BEA 1990–2011 pre-trend test** (income only) | Two-decade parallel-trend defense for the result HonestDiD cannot vindicate | `05_bea_pretrends_1990_2011.R` |
| S8 (2026-07-01) | External reader: "how much is *not* agriculture?" | **Structural-moderator subsample design** (baseline ag tercile + Shock×Ag) | Bounds a mechanism without bad-control contamination | `mechanism_channels_20260625/spec.md` |
| S8+ (2026-07-04) | Referee: recurring binary treatment = negative-weight risk | **TwoWayFEWeights diagnostic + `did_multiplegt_dyn`** (de Chaisemartin–D'Haultfœuille) | Quantifies TWFE weight pathology; estimator built *for* reversible treatment | `07_recurring_treatment_check.R`; commit `7c1e8f6` |
| S8+ (2026-07-04) | Referee: ~15 hits mined from hundreds of cells | **Anderson index + sharpened BKY q-values + Romano–Wolf** | Family-wise/FDR control; one test per channel family | `run_mechanism_multipletesting.R`; commit `1b3f50a` |
| S8+ (2026-07-04) | Proposal promised a premium→debt mediation | **Two-level pass-through + difference-method mediation** (RA×year primary) | Prices the ACA margin at the level institutions set it | `run_premium_mediation.R:1-52` |

---

## 2. The retrospective in prose

**Estimator core.** The project began with the standard-but-awkward `plm` + `sandwich` + `coeftest` stack and migrated to `fixest::feols` (2026-03-02). The migration was not cosmetic: `feols` absorbs two-way fixed effects cheaply, exposes clustering as a one-argument API, and supplies within-R² directly. Crucially, it later made the frontier work tractable — the `demean()` FWL routine that rescues `boottest` is a `fixest` primitive. A plain-formula OLS path was retained only because VIF needs a design matrix the `|` FE syntax doesn't expose.

**Shock construction — where the most consequential methodology lives.** Three moves define it. (1) **Frozen-baseline z-scores.** Shocks were originally z-scored against the full-sample mean/SD — look-ahead bias, since 2011–2023 realizations defined what counted as "extreme." The fix anchors each county's mean/SD to 1990–2000 only. This reframes a shock as a draw from a *pre-study* distribution — exactly the framing the external reader later probed ("anticipatable given historical averages?"), answerable only because the anchor is fixed. (2) **The right transform per variable.** Drought indices are already standardized, so z-scoring was *removed*; AQI has hard EPA thresholds, so its z-score shock was dropped as unreliable. The econometric review (§2A) drove the deliberate separation of *relative* shocks (z-scores: "was this year unexpected?") from *absolute* burdens (CDD/HDD quintiles: "was the physical load high?"), run in separate specs to avoid collinearity. (3) **Mean vs. min.** `pdsi_min` was added because the annual mean smooths transient drought peaks. Recurring lesson: **threshold flags are cutoff-fragile** (degree-day flags move with the cutoff; the cold headline survives p90 via the z-based flag), whereas continuous and EPA-threshold measures are stable.

**The design ladder.** The design evolved rung by rung, each answering a question its predecessor couldn't: static distributed-lag TWFE → dynamic DL + local projections (dynamics, pre-trends) → an explicit *rename* admitting treatment recurs (impulse response, not event study) → onset/persist/exit decomposition with a symmetry Wald test (is the shock reversible or does it scar?) → cumulative-dose and cohort designs (does accumulated exposure compound?) → 2×2 never-exposed DiD (a sharp natural experiment) → frontier DiD (CS/DRDID for conditional parallel trends) → recurring-treatment diagnostics (TwoWayFEWeights, `did_multiplegt_dyn`). Every rung was forced either by a limitation of the prior design or by an external critique — none was methodology for its own sake.

**Inference.** State clustering was "non-negotiable" from the review (§4): state-level drought and rating-area premiums both induce cross-county error correlation. Premium outcomes got a bespoke fix — RA-clustered variants — because counties in a rating area share identical prices by construction. When the 2012 DiD concentrated treatment in a few states (67% in 4), analytic clustering over-rejects, triggering the **wild cluster bootstrap (Webb weights, null imposed) plus Fisher randomization inference**. The key engineering move: `boottest` chokes on 3,155 county FEs, so the FEs are partialled out via **FWL `demean`** and the bootstrap runs on the residualized one-regressor model — identical point estimate, preserved cluster structure (`01_wild_cluster_bootstrap.R:14-18`). Multiplicity, raised by a referee, was answered with an **Anderson inverse-covariance index**, **sharpened BKY q-values**, and **Romano–Wolf**. VIF pruning is inference hygiene of the same kind — the collinear drought block was demoted before its coefficients could mislead.

**Sensitivity machinery and its limits.** HonestDiD turns "are pre-trends flat?" into a breakdown bound. Its *limit* proved as instructive as its use: the 2012 cohort has no testable pre-period (the panel starts 2011 = its e=−1), so HonestDiD can only assess the pooled multi-cohort design, which is already null — it cannot vindicate the natural experiment. That gap forced the standalone **BEA 1990–2011 pre-trend test**, income-only because ACS outcomes don't extend back. Other layers: the humidity confounder tested on the identical humidity-available subsample (so "added control" isn't confounded with "changed sample"); threshold-sensitivity placebos; and a difference-method mediation honestly labeled decomposition, not causal mediation.

**Data engineering as methodology.** Several "plumbing" choices are really identification choices: the frozen-baseline anchor; population-share vs. modal crosswalk aggregation (modal for hospital→county to preserve provider attributes; population weights for AQI); strict population weights with no fallback (a `Pop_Wt=1` fallback silently imputes); and the CO-2023-only exclusion rule designed against the actual August credit-bureau snapshot date rather than statute effective dates.

---

## 3. Mistakes-and-corrections ledger

| Error | How caught | Correction | General lesson |
|---|---|---|---|
| Full-sample z-score baseline (look-ahead bias) | Session-2 audit | Frozen 1990–2000 per-county anchor | A "shock" must be defined against information available *ex ante* |
| Calling recurring-treatment models an "event study" | E-series remediation audit | Renamed to impulse response; added TwoWayFEWeights + `did_multiplegt_dyn` | Name the estimand honestly; canonical event-study tools assume *absorbing* treatment |
| `sprintf("%05s", fips)` space-pads → silently drops single-digit-state FIPS (2,827 vs 3,155 counties) | Row-count discrepancy | `formatC(as.integer(fips), width=5, flag="0")` | Never trust a silent join; verify the N of units |
| State-level drought used as county treatment | Design review | County PDSI/PHDI/PMDI | Push treatment to the finest resolution the outcome varies at |
| Broken state VIF (`model.matrix(model)[,-1]` stripped a predictor; all VIF = NA) | Session-3 diagnostics | `model.matrix()` on the within-transformed matrix directly | Diagnostics fail silently too; sanity-check they return numbers |
| Blanket CO/MN/NY debt exclusion | Statute dates checked against Aug snapshot | `debt_reporting_policy` = CO-2023 only | Match exclusion windows to the data's actual measurement date |
| NOAA blanket `<= -9.9` missing threshold flagged real cold/drought values | Session-1 audit | Per-variable sentinels (−99.90 temp, −9999 CDD/HDD, −99.99 PDSI) | Sentinel values are variable-specific |
| Temperature aggregated by *sum* (12× too large); RA join discarded `AREA_Clean`; duplicate DC key (dead code) | Inconsistencies audit | Mean for temp; normalized RA id; documented DC absence | R silently returns the first match on duplicate named-vector keys |
| `Pop_Wt=1` fallback silently imputed missing-pop counties into state AQI | Weighting review | Strict weights + `AQI_Median_EW` robustness series + drop diagnostics | An imputation fallback is a hidden modeling assumption |
| HonestDiD influence-function vcov scaled 1/n | Session-7 debugging | Scale **1/n²** (`t(inf)%*%inf/n^2`) | Verify vcov scaling against the package vignette |
| `DRDID` errored on character `idname` | Runtime error | `as.integer(factor(fips))` | Frontier packages have strict type contracts |
| `effect_bottom/effect_overall` ratio unstable near zero denominator | Mechanism estimation | Report sign/significance, never the raw ratio | Ratios explode near zero — don't headline them |
| Negative `Hosp_Charity_Total` (−$408M accounting reversal) | Descriptive stats | Flagged for winsorization before levels regressions | Screen for accounting reversals before running levels models |
| Levels-only heterogeneity result (−2,011 low-ag cold) | Second-reviewer log re-estimation | Dies in logs; commit `5c615dd` | Always re-run size-sensitive heterogeneity in logs/per-capita |

---

## 4. `Analysis/econometric_review.md`: demanded vs. done

| Review critique | Response | Status |
|---|---|---|
| §1A MAUP: RA→county broadcast creates artificial precision | State clustering (nests RA) + RA-clustered SE variants for premiums | Done — `run_county_analysis.R` `*_RA_Cluster` |
| §1B: run a separate rating-area-level regression | RA-aggregation robustness block (population-weighted shocks) | Done — retained alongside RA clustering |
| §2A: don't mix z-scores and CDD/HDD quintiles in one regression | Separate Spec A (adaptation/z-score) vs Spec B (burden/quintile) | Done |
| §2A: combined regression only if VIF low | VIF computed; drought block pruned; combined demoted to robustness | Done — `drought_vars_primary` |
| §3: adjust all monetary vars to 2023 dollars | `_Real` columns in both masters | Done |
| §4.1: county clustering invalid; use state | State clustering is the maintained default | Done |
| §4.3: run both unweighted (policy) and population-weighted (welfare) | Unweighted primary + pop-weighted variants | Done |

Every actionable critique in the review was ultimately implemented — worth remembering when weighing whether to solicit another external methods review before the defense.

---

## 5. Reusable toolkit (carry to future projects)

- **`lincom(model, weights)`** (`Code/cumulative_dose.R`) — estimate/SE/p for any linear combination from a clustered vcov; no stacking or bootstrap. The workhorse for marginal effects and bin contrasts.
- **`transition_symmetry_test()`** (`Code/transition_symmetry.R`) — Wald test on β_Onset + β_Exit from one joint regression (shared covariance); a clean reversibility/hysteresis test.
- **FWL + `boottest`** — `fixest::demean` to partial out thousands of FEs, then wild-cluster-bootstrap the residualized one-regressor model (`Code/did_robustness/01_wild_cluster_bootstrap.R`). Makes few-cluster inference tractable at scale.
- **Frozen-baseline z-scores** — compute mean/SD on a pre-study window, join in, drop before output. Kills look-ahead bias in any shock definition.
- **Hand-rolled Anderson index** (sign-align, standardize, invert covariance, GLS-weight) + sharpened BKY q-values without Bioconductor (`Code/run_mechanism_multipletesting.R`).
- **Two-R-version isolation** — main pipeline on R 4.2.2; frontier packages quarantined on R 4.5.3 invoked by absolute path; every script header states its R version.
- **Self-logging convention** — every process/estimation script `sink()`s to `Analysis/*/build_logs/*.log`; runs are script files, never inline `Rscript -e`.
- **Structural-moderator subsample pattern** — bound a mechanism by *baseline* (never contemporaneous) attributes + tercile splits, sidestepping bad-control bias.
- **Select-only large-CSV read** — read the header, re-read with `colClasses="NULL"` on unwanted columns (avoids the 58 MB × 246-col base-`read.csv` segfault).
- **`add_cumulative_shock_years()` / `assign_exposure_cohort()`** — dose/cohort constructors with a single ground-truth definition sourced by both analysis and tests.

---

## 6. Open methodological threads (as of 2026-07-06)

1. **Stale script header:** `01_wild_cluster_bootstrap.R` still says "written, not yet run," but `did_robustness_summary.md` reports populated WCB results (PCPI p=0.036; employment p=0.003). Update the header — headers are the project's provenance system and must not lag the runs.
2. **Winsorization gap:** the negative `Hosp_Charity_Total` row is flagged in CLAUDE.md and the descriptive report, but no winsorize call was found in `Code/`. Verify before any hospital-finance levels regression (relevant to frontier Tier 3d).
3. **Meta-lesson for the frontier plan:** every methods upgrade in this project was *reactive* (a bug, a review, a referee). The microsimulation (Tier 2) is the first chance to be *proactive* — build the multiple-testing, uncertainty-propagation, and estimand-labeling discipline in from the start rather than retrofitting it.
