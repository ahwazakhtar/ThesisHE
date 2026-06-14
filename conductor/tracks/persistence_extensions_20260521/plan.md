# Implementation Plan: Persistence Extensions

Source notes: `Text/persistence.txt`. Track spec: `./spec.md`.

Sequencing: Phase 0 is the framing gate. Phase 1 builds on the existing Exit-LP work in `Code/run_delta_analysis.R` and unlocks Phases 2 and 3. Phase 4 (demographics) has an independent data-acquisition step. Phase 5 is a standalone robustness sweep.

---

## Phase 0: Ex-ante hypothesis framing

- [x] **Task: Make hypotheses explicit in synthesis docs** [8949e8b]
    - [x] Drafted "Ex-Ante Hypotheses and Predictions" subsection (§3a) in `Analysis/state_analysis_summary.md` — predicted direction + time-scale per shock × outcome, each sourced to a named pathway/citation in `Text/propagation_pathways.md`.
    - [x] Same block added near the top of `Analysis/event_study_synthesis.md`.
    - [x] Tagged each headline (state §4.6 surprise audit; event-study Surprise Audit section): drought-lag-2 & cold-lag-1 debt = **As expected**; HDD long-run scarring = **Stronger than expected**; High_CDD income split = **Direction opposite/mixed**; humidity→debt, systemic cost, AQI = **No clear prior**.

## Phase 1: Symmetric Onset-LP and Persist-LP

- [x] **Task: Extend Onset and Persist indicators with LP horizons** [2c497be]
    - [x] `run_delta_analysis.R` §9c estimates `*_Onset`/`*_Persist`/`*_Exit` JOINTLY at h=0..3 (one LP per shock×outcome×horizon×weighting), against the never-transitioned (0→0) reference. Approaches `Delta_Onset_LP`, `Delta_Persist_LP`, `Delta_Exit_LP_Joint` (+`_RA_Cluster` for premiums).
    - [x] Joint estimation chosen so the symmetry test reads off the model's own covariance; `delta_coefs.csv` 1664→2240 rows.
    - [x] 21 PNGs (3 shocks × 7 outcomes) in `Analysis/plots/delta_transition_compare/` showing Onset/Persist/Exit on one axis across h=0..3.

- [x] **Task: Three-way comparison synthesis** [2c497be]
    - [x] Long-format `Analysis/delta_transition_summary.csv` (252 rows) indexed by (shock, outcome, horizon, transition) with estimate, SE, p, N.
    - [x] "Three-Way Transition Decomposition" section added to `Analysis/delta_analysis_synthesis.md`. Headline: Drought→Medical_Debt_Share h=2 is scarring (asymmetry +0.0182, p=0.0015); income shows symmetric overshoot; HDD→Hosp_BadDebt h=3 over-relief.

- [x] **Task: Formal symmetry test** [2c497be]
    - [x] `Code/transition_symmetry.R`: Wald test H0: β_Onset + β_Exit = 0 from the joint clustered vcov. Exported to `Analysis/delta_symmetry_test.csv` (168 tests; 28 reject at p<0.05, with beta_onset/beta_exit/asymmetry/p/reject_symmetry).
    - [x] 4 new `test_that` blocks in `Code/tests/test_delta_variables.R` (Tests 10–13): joint LP h=0 equivalence; symmetry rejects under known asymmetric DGP; does not reject under symmetric DGP; NULL guard. 13/13 pass.

## Phase 2: Continuously-exposed sub-population analysis

- [x] **Task: Define and characterize the always-exposed cohort** [443e895]
    - [x] New `Code/run_persistent_exposure.R` + `Code/exposure_cohorts.R` define Always (≥10/13), Frequently (5–9), Rarely (1–4), Never (0) per shock. 6 tests in `Code/tests/test_persistent_exposure.R` (band boundaries, partition, custom cuts, inventory schema). 6/6 pass.
    - [x] Descriptive table `Analysis/persistent_exposure_cohort_summary.csv`: cohort size, n_states, top-3 states, headline outcome means. Always cohorts: CDD 661 (TX/GA/MS), HDD 432 (MN/MT/ND), AQI 353 (CA/OH/PA), Drought **1** (chronic extreme drought ≈ nonexistent → onset-DiD remains the drought design).
    - [x] Exported `Analysis/persistent_exposure_inventory.csv` (county × shock + cohort).

- [x] **Task: Always-vs-Never DiD-style contrast** [443e895]
    - [x] Static dose-response (`Outcome ~ cohort | Year`) and dynamic two-way FE trajectory (`i(Year, Always_Exposed, ref) | fips_code + Year`) on Always ∪ Never. Outputs `Analysis/persistent_exposure_contrast.csv` (72 rows) + `…_dynamic.csv` (275 rows).
    - [x] Hypothesis confirmed for heat: **CDD Always shows the largest, monotone persistent debt gap** (+9.9 pp, p<0.0001; Never 0.156→Always 0.255). But within-design the gap is a stable level, not widening — contrasted against the onset CS-DiD (which compounds) in `Analysis/persistent_exposure_synthesis.md`.
    - [x] 48 plots in `Analysis/plots/persistent_exposure/` (dynamic trajectories + dose-response).

## Phase 3: Cumulative-dose analysis

- [x] **Task: Construct cumulative-shock-years variable** [8e573cc]
    - [x] Successor-script approach (avoids full county-pipeline rebuild): `Code/cumulative_dose.R::add_cumulative_shock_years()` derives `Cum_Drought_Years`, `Cum_CDD_Years`, `Cum_HDD_Years` from the master's shock indicators — running per-county count, **monotonic non-decreasing** (no reset on exit/re-entry), NA→0 carry-forward. Documented in the helper header.
    - [x] 7 tests in `Code/tests/test_cumulative_dose.R` (running-sum correctness, monotonicity, no cross-county bleed/reset, NA handling, order-invariance, plus `lincom` recovery). 7/7 pass.

- [x] **Task: Dose-response regressions** [8e573cc]
    - [x] New `Code/run_cumulative_dose.R`: `Y ~ f(CumYears) + controls | fips_code + Year` for 3 shocks × 6 outcomes × 2 weightings, with **linear / quadratic / binned (1–3,4–6,7–9,10+ vs 0)** forms.
    - [x] Year-10-vs-year-1 answered via quadratic ME(10)−ME(1) and binned 10+−1–3 (`lincom` Wald). **HDD employment compounds**: monotone −1,269/−3,267/−5,353/−6,936; 10+ vs 1–3 = −5,668 (p<0.0001), converging with CS-DiD. **Heat does NOT compound** (CDD debt ME negative by year 10). **Drought 10+ = 1 county**, flagged not interpretable.
    - [x] Exported `Analysis/cumulative_dose_coefs.csv` (252) + `…_marginal.csv` (180); plots in `Analysis/plots/cumulative_dose/`.
    - [x] "Cumulative-Dose Response" narrative section added to `Analysis/delta_analysis_synthesis.md`.

## Phase 4: Demographic-change mediators

- [x] **Task: Acquire ACS migration and age-distribution variables** [53a92d2]
    - [x] Extended `Code/download_county_socioeconomic.R` to pull ACS B25003 (tenure), B01001 (age 65+ cells), B07001 (geographic mobility) for 2011–2023. (B07401 not needed — B07001 supplies the in-migration cells.)
    - [x] New `Code/process_county_demographics.R` derives `In_Migration_Rate`, `Pct_Age_65plus`, `Pct_Owner_Occupied` → `Data/intermediate_demographics.rds` (41,869 rows, 3,234 counties). **DEVIATION:** named `In_Migration_Rate` not `Net_Migration_Rate` — ACS mobility tables observe in-migration only (out-migration unobserved), so a true net rate is not recoverable; documented in script header. Joined at analysis time (no county-master rebuild).
    - [x] Tests `Code/tests/test_demographic_mediators.R` (feature arithmetic, all 12 age cells, NA-denominator guards, [0,1] ranges, intermediate schema). 5/5 pass. ACS 5-year smoothing documented.

- [x] **Task: Population-change responses to shocks** [53a92d2]
    - [x] `Code/run_demographic_mediators.R` first stage: each demographic ~ contemporaneous + lag1 + lag2 shocks | fips + Year. Export `Analysis/demographic_response_coefs.csv` (27 rows).
    - [x] **Result: shocks barely move demographics** — only 2/27 links significant, both tiny (High_CDD lag-2 → Pct_Age_65plus +0.0017; High_CDD → Pct_Owner_Occupied −0.0020). ACS smoothing limits annual response (power caveat).

- [x] **Task: Mediator decomposition** [53a92d2]
    - [x] Re-ran Medical_Debt_Share / PCPI_Real / Hosp_BadDebt_PerCapita on shocks with vs. without demographic controls on the identical sample. Output `Analysis/demographic_mediator_decomposition.csv` + plot.
    - [x] **Clean null: demographics do NOT mediate** — fraction of shock effect surviving 0.94–1.04 for debt/hospital outcomes. Headline mechanisms are not population-turnover/aging artifacts. Narrative §7 added to `Analysis/state_analysis_summary.md`.

## Phase 5: HDD/CDD threshold sensitivity

- [ ] **Task: Sensitivity sweep for top-quintile cutoffs**
    - [ ] New `Code/run_threshold_sensitivity.R`. Recompute `High_CDD` and `High_HDD` at the p70, p80 (existing primary), and p90 national 1990--2000 baselines.
    - [ ] Re-estimate the primary state spec and primary county Spec 2 for each cutoff.
    - [ ] Export the side-by-side coefficient table: `Analysis/threshold_sensitivity_coefs.csv`.
    - [ ] Brief narrative in `Analysis/state_analysis_summary.md`: does the headline cold-lag-1 effect survive a stricter cutoff (p90)? If yes, robustness is supported.

## Phase 6: Conductor verification & write-up

- [ ] **Task: Conductor --- User Manual Verification 'Persistence Extensions' (Protocol in workflow.md)**
- [ ] **Task: Propagate findings into upstream synthesis**
    - [ ] `Analysis/state_analysis_summary.md`: humidity caveat untouched; add threshold-sensitivity verdict; add demographic-mediator decomposition; reference Onset/Persist/Exit symmetry results.
    - [ ] `Analysis/event_study_synthesis.md`: add the three-way transition decomposition and cumulative-dose results.
    - [ ] `Analysis/delta_analysis_synthesis.md`: already extended in Phases 1 and 3; final pass for cross-references.
