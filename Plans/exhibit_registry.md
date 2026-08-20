# Dissertation Exhibit Registry

**Created:** 2026-07-13 · **Owner track:** `code_quality_remediation_20260713` (spec O5 /
audit A6 / writing-plan §10). **Status:** live; refresh at Phase 5 clean-room reproduction.

One row per manuscript-bound exhibit. Seeded from the writing plan
(`Plans/dissertation_writing_and_framing_plan_20260712.md` §6 Essay 1, §7 Essay 2, §8 Essay 3,
§9 policy synthesis) and §10's registry spec. Binding companion:
`Plans/master_evidence_table.md` (claim tiers + permitted language).

## Provenance stamps (apply to every "post-dedup=y" county-based row)

- **County master:** `Data/county_level_master.csv` — **118,732 rows × 82 cols, 3,232
  counties**, certified unique on `(fips_code, Year)`, rebuilt 2026-07-13 (`fca5643`).
  Pre-dedup backup: `Data/_archive/county_level_master_prededup_20260713.csv` (119,300 rows).
- **State master:** `Data/state_level_analysis_master.csv` — **not affected** by the county
  dedup (separate build); state-family outputs are current w.r.t. their own master.
- **Hospital panel:** `Data/intermediate_hospital_panel.rds` — rebuilt 2026-07-13 13:20 from
  the certified county master by `Code/process_hospital_panel.R`. **Dedup-invariant** (see the
  join note in §"Hospital join-duplication finding" below).
- **R:** 4.2.2 for the whole main pipeline; **R 4.5.3 only** for `Code/did_robustness/*`
  (frontier `did`/`DRDID`/`HonestDiD`/`fwildclusterboot`).
- **Re-run this refresh (2026-07-13):** delta, cumulative-dose, exposure (index + state +
  secondary), persistent-exposure, event-study (+ synthesis generator), mechanism (medicare,
  multipletesting, horserace), hospital (incidence/heterogeneity/persistence × default +
  `HOSP_WINSORIZE=1`), descriptive. Already-current (dedup-invariant or rebuilt earlier this
  track): did/robustness, mediation, control-sensitivity, latent-hardship, county, state.

---

## Essay 1 — Incidence and institutional recording

Owns: 2012 drought design, Medicare incidence, debt/premium ledgers, fragile employment.

| Exhibit | Section | Output file(s) | Generating script | R | Key inputs | Post-dedup? | Notes (before→after) |
|---|---|---|---|---|---|---|---|
| E1-T0a Data sources & coverage | §3 Data | `Analysis/descriptive/data_sources_table.{csv,tex}` | `create_data_source_tables.R` | 4.5.2 | county + state masters; 6 mechanism intermediates | **y** (built 2026-08-18) | 14 sources: provider, unit/geography, coverage, role in Essay 1. **All counts computed at build time** from the delivered files (year range over non-missing rows, non-missing obs, distinct units) — not typed, so the table cannot drift from the panel. Coverage ≠ estimation sample (stated in the table note). |
| E1-T0b Variable definitions | §3 Data | `Analysis/descriptive/variable_definitions_table.{csv,tex}` | `create_data_source_tables.R` | 4.5.2 | as E1-T0a | **y** (built 2026-08-18) | 20 variables in 4 panels (shocks / outcomes / moderators / auxiliary) with construction, units, source, coverage, and where used. Time-invariant moderators report county counts only, no year range. State dollar base **read** from `us_cpi_annual.csv` (= **2025**) vs county **2023** — the CLAUDE.md base-divergence trap, now printed in the note. CSV carries the exact panel column name; the `.tex` merges coverage fields for width. |
| E1-T1 Sample & variable defs | §6 Data | `Analysis/descriptive/descriptive_stats_table_main.{csv,tex}`, `descriptive_stats_summary.csv` | `run_descriptive_stats.R` | 4.2.2 | county master | **y** (re-run 2026-07-13 13:48) | Summary moments over 118,732 rows / 41,863 study rows. Trivial shift from 0.3% row drop. **Generator fix:** `output_dir` default changed `"Analysis"`→`"Analysis/descriptive"` (was scattering CSVs to root, against CLAUDE.md); root debris moved to `Analysis/descriptive/_archive_root_debris_20260713/`. |
| E1-T2 2012 drought balance / cohort | Appendix A.1 | `Analysis/did/cohort_balance_table.{csv,tex}` (**BUILT 2026-08-18**); ATT in `Analysis/did/did_2x2_drought_2012.csv` | `create_essay1_ledger_exhibits.R` | 4.5.2 | county master | **y** | Pre-treatment (2011) means for the 139 first-onset vs 2,534 never-exposed counties, with Imbens-Rubin normalized differences. Cohort logic mirrors `run_did_analysis.R` and **reproduces 139 / 2,534 exactly** (asserted at build). Confirms the imbalance the DRDID is there to address: employment norm. diff. −0.31, population −0.31, median income −0.25, debt share +0.20. `Uninsured_Rate` drops out (SAHIE starts 2012). Cohort = GA + Mountain West + Plains (NOT "Midwest"). |
| E1-T3 Main DiD estimates | §6 Main result | `Analysis/did/did_2x2_drought_2012.csv` | `run_did_analysis.R` | 4.2.2 | county master | **y** (identical) | PCPI_Real ATT **−$1,311** (robustness-suite frame −1,310.67; 2×2 CSV −1,311.30 — same spec family, both p≈0.027) — dedup-invariant (Δ=0). |
| E1-T4 Inference & robustness | Appendix A.3 | **printed table `Analysis/did/robustness/falsification_table.{csv,tex}` (added 2026-08-18, `Code/create_falsification_table.R`)**; underlying `did_robustness_summary.md`, `dr_csdid_eventtime.csv`, `falsification_summary.md` | `Code/did_robustness/*.R` → `create_falsification_table.R` | **4.5.3** / 4.5.2 | county master | **y** | **2026-08-18:** 7-row printed table (pre-trend, WCB, RI, DRDID, LOO, placebo, pre-window sensitivity) built by reading the committed robustness CSVs — no transcription. It carries the enumerable per-test prose that Appendix A.3 shed when it went from 6 ¶ to 5 (and absorbed A.4). Humidity/ACS-demographics/threshold/Conley checks are deliberately **excluded** — their statistics exist only in narrative docs, so they stay in prose with an Appendix D pointer. Prior notes: WCB p 0.036; RI 0.0075; DR ATT −$1,451; LOO envelope [−1,687,−914]; placebo 0.009. Frontier pooled **e=0 = −$324 (SE 276): null** — governs (retires manual-CS −$1,050). |
| E1-T5 Cross-cohort / external validity | Appendix A.3 | `Analysis/did/did_cs_event_time.csv` (descriptive), frontier `dr_csdid_*` (inference); fig `Analysis/plots/did/csdid_panels_income_employment.png` | `run_did_analysis.R` (manual, descriptive-only) + `Code/did_robustness/*`; fig `Code/create_fig_csdid_panels.R` (2026-08-17 hazard × outcome panels) | 4.2.2 / 4.5.3 / 4.5.2 | county master | **y** | Manual-CS aggregation is **descriptive only** (audit A4; invalid independence SEs) — the panel figure's subtitle says so. Cite inference from frontier layer. |
| E1-T6 Medicare utilization | §4 Medicare | `Analysis/mechanism/medicare_table.{csv,tex}` (**BUILT 2026-08-18**); coefs `Analysis/mechanism/medicare_channel_coefs.csv` | `create_essay1_ledger_exhibits.R` (table) + `run_mechanism_medicare.R` (estimation) | 4.5.2 | county master + CMS Geo Variation (2014–2023) | **y** | 24 rows: spending and ED visits × 4 hazards × 3 lags, each anchored to its own baseline. **Baselines are BENEFICIARY-WEIGHTED** (\$10,359/beneficiary; 629 ED per 1,000) — verified to reproduce the essay's anchors exactly; the unweighted county mean (\$9,951 / 646) is the wrong convention for a per-beneficiary quantity and must not be substituted. |
| E1-T7 Financial-ledger comparison | §5 Ledgers | `Analysis/mediation/ledger_comparison.{csv,tex}` (**BUILT 2026-08-18**); inputs `premium_passthrough.csv`, `passthrough_bounds.csv`, `Analysis/state/regression_results_summary.csv`, `medicare_channel_coefs.csv` | `create_essay1_ledger_exhibits.R` | 4.5.2 | county + state masters | **y** | One row per ledger with its response, its own baseline, and the response as a percent of that baseline — the standardisation that makes a dollar premium, a debt share and an ED rate comparable. **The two COUNTY debt cells are re-estimated at build** because no committed county output contains them (the county pipeline has no binary cold-z shock and reports drought through continuous `pdsi_val`): cold→debt L1 = **−0.27 pp (p=0.46)**, drought→debt L2 = **+0.58 pp (p=0.024)**. These SUPERSEDE the Row 4 "+1.2 pp (p<0.001)" and Row 5 "+0.54 pp (p<0.01)" figures — see the 2026-08-18 verification notes on those rows. |
| E1-F2 Income pretrends | §6 Fig | `Analysis/did/did_pretrends_event_study.csv` | `run_did_analysis.R` | 4.2.2 | county master + BEA 1990–2011 | **y** | 1990–2011 differential trend −$69/yr (p=0.44). |
| E1-F3 Event-time income profile | §6 Fig | `Analysis/did/robustness/dr_csdid_eventtime.csv` | `Code/did_robustness/*` | **4.5.3** | county master | **y** | Frontier event-time; e=0 null. |
| E1-F4 Medicare dynamic responses | §4 Fig (Medicare-led restructure) | `Analysis/mechanism/plots/fig_medicare_morbidity.png`; coefs `medicare_channel_coefs.csv` | `Code/create_fig_medicare_morbidity.R` (reads the coefs CSV; estimation stays in `run_mechanism_medicare.R`) | 4.5.2 | county master + CMS | **y** | **Redesigned 2026-08-17**: hazard × outcome panel grid (free x per outcome — spending and ED differ by 2 orders of magnitude), plain-language labels, heat panel first. Previous one-column base-R version had no committed generating script. |
| E1-F1 Treated/never-exposed map | §6 Fig | `Analysis/did/fig_treated_map.png` | `create_manuscript_exhibits.R` | 4.5.2 | county master | **y** (built 2026-08-13) | 139 first-onset-2012 counties (GA/Mountain West/Plains) vs never-exposed; cohort logic replicates `run_did_analysis.R` exactly (tested). `usmap`/`sf` installed 2026-08-13. |
| E1-F5 Institutional-ledger figure | §5 Fig | `Analysis/mediation/fig_institutional_ledgers.png` (**BUILT 2026-08-18** — was `pending`) | `create_essay1_ledger_exhibits.R` | 4.5.2 | as E1-T7 | **y** | The deferral reason was that cross-ledger standardisation had no agreed units. **Resolved:** each response is plotted as a percent of that ledger's own mean, with 90% intervals, so precision and sign are both visible. Shares its data frame with E1-T7, so the two can never disagree. |
| E1-F6 Farm/nonfarm decomposition | §5 Fig (2026-08-17 reframe) | `Analysis/plots/did/decomposition_Drought_2012_farm_nonfarm.png`; coefs `Analysis/did/did_farm_nonfarm_eventstudy_drought2012.csv` | `Code/diagnostics/farm_nonfarm_decomposition_drought2012.R` | 4.5.2 | county master + BEA CAINC5N raw (`Data/County_Agriculture/`) + CPI | **y** (built 2026-08-17) | Treated farm income/capita spikes to $4,339 in 2011 (vs $1,903–2,438 2007–10); 2008–10 leads ≈85% farm; nonfarm gaps baseline-invariant −$261…−$414. Anchors the §5 reframe (evidence-table Row 1 amendment 2026-08-17). |
| E1-T8 Baseline sensitivity of the 2×2 | §5 Table (2026-08-17 reframe) | `Analysis/did/did_2x2_baseline_sensitivity_drought2012.csv` | `Code/diagnostics/farm_nonfarm_decomposition_drought2012.R` | 4.5.2 | as E1-F6 | **y** (built 2026-08-17) | ATT grid: pre-period (2011/2010/2009/2007/2002) × component (total/farm/nonfarm). Total −$1,311→−$285; farm −$907→−$14; nonfarm sign-stable −$261…−$414 (never significant). |
| E1-F7 Full-window event study (income + employment panels) | Appendix A.2 Fig | `Analysis/plots/did/eventstudy_panels_Drought_2012.png` (combined 2-panel exhibit); single-outcome variants `eventstudy_fullwindow_…` / `eventstudy_leads2_…`; coefs `did_eventstudy_full_window_drought2012_pcpi.csv` + `…_employment.csv` | `Code/diagnostics/eventstudy_full_window_drought2012.R` | 4.5.2 | county master (BEA PCPI 1990–2023; ACS employment 2011–2023) | **y** (built 2026-08-17; panelized same day) | Income: 21 pre-treatment leads + all 12 post years vs 2011 ref (mean of 12 post gaps = pooled ATT −$1,310.7 exactly). Employment: gap builds monotonically; panel label states no pre-2011 data exist. |
| E1-T9 Shock-definition robustness | Appendix B Table | `Analysis/advisor_robustness/baseline_horizon_sensitivity.csv`; companion `horizon_sensitivity.csv` (advisor 1.4) | `Code/diagnostics/baseline_horizon_sensitivity.R`; `Code/run_horizon_sensitivity.R` | 4.5.2 | county master + `intermediate_climate.rds` + `intermediate_medicare_spending.rds` + `analysis_ready_dataset.csv` | **y** (built 2026-08-17) | Baselines 1990–2000/2005/2010: validation replica exact (0/40,781 flag mismatches); Medicare heat + cold employment stable; state cold→debt attenuates 1.35→0.85pp (sig at 5% throughout) — cite as range. |

## Essay 2 — Persistence (scarring / compounding)

Owns: transition symmetry, cumulative dose, recurring exposure, LP dynamics, cross-estimator.

| Exhibit | Section | Output file(s) | Generating script | R | Key inputs | Post-dedup? | Notes (before→after) |
|---|---|---|---|---|---|---|---|
| E2-T1 Transition frequencies / support | Essay 2 §3 | `Analysis/delta/transition_table.{csv,tex}` (**BUILT 2026-08-18**); source `transition_episode_counts.csv` | `create_essay23_exhibits.R` | 4.5.2 | county panel | **y** | Onset / persistence / exit / calm county-year counts by hazard, with counties ever exposed. Shows the support behind each transition and therefore the horizons the dynamic estimates can reach. |
| E2-T2 Onset / persistence / exit coefs | §7 | `Analysis/delta/delta_coefs.csv` | `run_delta_analysis.R` | 4.2.2 | county master | **y** (13:10) | Incl. `Delta_Exit_LP` / `Delta_Exit_Interaction` blocks. |
| E2-T3 Symmetry tests | Essay 2 §5 | `Analysis/delta/symmetry_table.{csv,tex}` (**BUILT 2026-08-18**); source `delta_symmetry_test.csv` | `create_essay23_exhibits.R` | 4.5.2 | county panel | **y** | h=2 cells for debt, income and employment across both weightings; onset, exit, their sum, and the symmetry verdict. The full 168-row grid across horizons stays in the analysis output. |
| E2-T4 Cumulative-dose contrasts | §7 | `Analysis/cumulative_dose/cumulative_dose_marginal.csv`, `_coefs.csv` | `run_cumulative_dose.R` | 4.2.2 | county master | **y** (13:11) | **Cold(HDD) employment binned 10+ vs 1–3 (unwtd) = −5,522 (SE 1,196, p=3.9e-6)** vs pre-dedup −5,668 → Δ/SE ≈ **+0.12**. Smooth quadratic ME_diff flat (est-dependent; disclose per B6). |
| E2-T5 Cross-estimator comparison | §7 | `Analysis/event_study/event_study_full_results.csv`; + dose + CS DiD | `run_event_study.R` / `synthesize_event_study.R` (+ did) | 4.2.2 / 4.5.3 | county master | **y** (13:23) | 1,668 coefs / 278 specs regenerated; synthesis clean (see event-study prose note). |
| E2-F2 Drought transition response | §7 Fig | `Analysis/plots/` (delta LP) | `run_delta_analysis.R` | 4.2.2 | county master | **y** (13:10) | |
| E2-F3 Cold cumulative-dose (binned+smooth) | §7 Fig | `Analysis/plots/lp_Shock_Count_*.png` + dose | `run_cumulative_dose.R` / `synthesize_event_study.R` | 4.2.2 | county master | **y** | Honesty box: binned + long-run support compounding; smooth quadratic flat. |
| E2-F5 Cross-estimator figure | §7 Fig | `Analysis/plots/synthesis_robustness_panel*.png` | `synthesize_event_study.R` | 4.2.2 | county master | **y** (13:23) | |
| (support) Persistent-exposure cohort contrasts | §7 §6 | `Analysis/persistent_exposure/persistent_exposure_contrast.csv`, `_dynamic.csv`, `_cohort_summary.csv` | `run_persistent_exposure.R` | 4.2.2 | county master | **y** (13:16) | Never-exposed set is shock-defined ⇒ dedup-invariant; contrasts regenerated. `never_exposed_inventory.csv` (05-21) is a separate descriptive inventory, **not** an input to this script. |
| E2-F1 Concept diagram | §7 Fig | `Analysis/plots/essay_diagrams/fig_adjustment_regimes.png` | `create_manuscript_exhibits.R` | 4.5.2 | (schematic, no data) | **y** (built 2026-08-13) | Four stylized regime paths: reversal / scarring / saturation / compounding. |
| E2-F4 Heat saturation | §7 Fig | `Analysis/persistent_exposure/fig_heat_saturation.png` | `create_manuscript_exhibits.R` | 4.5.2 | `cumulative_dose_marginal.csv` | **y** (built 2026-08-13) | **Spec = HDD-vs-CDD cumulative-dose contrast** (cold binned −5,522 p=3.9e-6; heat +4,460 p=0.06, no negative gradient; subtitle computed from data). The county chronic-heat debt-gap dynamic series was REJECTED as the exhibit basis — it is negative and widening (region-confounded CDD pattern, `did_results.md` §3); see `Text/final_writing/TK_resolutions.md`. |

## Essay 3 — Distributional and institutional incidence

Owns: SVI heterogeneity, energy/labor moderators, safety-net hospitals, debt visibility, burden concentration.

| Exhibit | Section | Output file(s) | Generating script | R | Key inputs | Post-dedup? | Notes (before→after) |
|---|---|---|---|---|---|---|---|
| E3-T1 Moderator defs & correlations | Essay 3 §2 | `Analysis/mechanism/moderator_correlations.{csv,tex}` (**BUILT 2026-08-18**) | `create_essay23_exhibits.R` | 4.5.2 | county panel | **y** | 5x5 correlation matrix, columns numbered (1)-(5) and keyed to the row labels (full names cannot wrap in numeric columns). Carries the energy-burden vs SVI independence point. |
| E3-T2 SVI marginal effects | Essay 3 §4 | `Analysis/exposure_index/svi_marginal_effects.{csv,tex}` (**BUILT 2026-08-18**) | `create_essay23_exhibits.R` | 4.5.2 | county panel | **y** | Marginal effect of each hazard at the 25th and 75th vulnerability percentiles, with the interaction p-value. **Medical debt is included but reverses** — cite it only as the measurement critique (Row 24), never as amplification. |
| E3-T3 Energy / labor horse race | Essay 3 §5 | `Analysis/mechanism/horserace_table.{csv,tex}` (**BUILT 2026-08-18**) | `create_essay23_exhibits.R` | 4.5.2 | county panel | **y** | log-employment interactions across three nested specifications. Energy burden survives the joint race (−0.0065, p=0.020); the labor share is marginal there (p=0.058) — see Row 11b/12. |
| E3-T4 Safety-net hospital heterogeneity | Essay 3 §6 | `Analysis/hospital/safetynet_table.{csv,tex}` (**BUILT 2026-08-18**) | `create_essay23_exhibits.R` | 4.5.2 | NASHP hospital-year | **y** | Safety-net vs other hospitals by hazard and outcome, with interaction p-values. Note in the caption that exposure is at the provider's location, not the patient catchment. |
| E3-T5 Debt visibility gradients | Essay 3 §7 | `Analysis/latent_hardship/visibility_gradients.{csv,tex}` (**BUILT 2026-08-18**) | `create_essay23_exhibits.R` | 4.5.2 | county panel | **y** | Primary-family cells only. Attenuation in the predicted direction is necessary, not sufficient — the pre-registered rule cleared only drought x uninsurance (Row 24). |
| E3-T6/F6 Burden concentration | §8 | `Analysis/policy/concentration_topshares.csv` + `fig_concentration_lorenz.png` (from `concentration_curve.csv`) | `create_manuscript_exhibits.R` (source data: `run_policy_sufficient_stats.R`) | 4.5.2 | policy concentration bands | **y** (built 2026-08-13) | Top-10% most-vulnerable population bears **19%** of recurring-cold employment burden, **15%** heat exposure, **14%/11%** cold/heat Medicare. **Uniform-per-capita bands (2012 income event, drought debt scar) are diagonal BY CONSTRUCTION** — flagged in the CSV, omitted from the figure; do not cite them as "no concentration". Doubles as policy Fig P1. |
| (support) CHEI composite / robustness / person-years | §8 exploratory | `Analysis/exposure_index/exposure_chei_coefs.csv`, `exposure_robustness.csv`, `exposure_personyears_trend.csv` | `run_exposure_secondary.R` | 4.2.2 | county master + SVI | **y** (13:15) | CHEI is exploratory (not a causal price). |
| (support) Hospital incidence / persistence | §8 provider | `Analysis/hospital/hospital_incidence_coefs.csv` (+`_winsorized`), `hospital_persistence_coefs.csv` (+`_winsorized`) | `run_hospital_incidence.R`, `run_hospital_persistence.R` | 4.2.2 | hospital panel RDS | **y** (13:22–13:23; +wins) | Drought→uncomp $ cumulative default **−$6.21M** / winsorized **−$3.88M**. Dedup-invariant. |
| E3-F2 Marginal effects by SVI | Essay 3 §4 Fig | `Analysis/plots/essay3/fig_svi_marginal_effects.png` (**REBUILT 2026-08-19**) | `Code/create_essay3_figures.R` | 4.5.2 | `exposure_interaction_coefs.csv` | **y** | Supersedes the diagnostic `Analysis/plots/exposure_index/interaction_Civilian_Employed.png`, whose axes printed panel column names (`Civilian_Employed`, `Heat_CDD`, `Drought_Lag2`, `Cold_CumYears`). Dumbbell across all five outcomes: the arrow runs from the marginal effect at the 25th vulnerability percentile to the 75th, with the interaction p printed per row. Colour encodes whether the two ends are distinguishable, NOT which direction is worse -- that differs across outcomes. Reads the same CSV as E3-T2, so figure and table cannot disagree. |
| E3-F4 Safety-net hospital response | Essay 3 §6 Fig | `Analysis/plots/essay3/fig_safetynet_uncompensated_care.png` (**REBUILT 2026-08-19**) | `Code/create_essay3_figures.R` | 4.5.2 | `hospital_heterogeneity_coefs.csv` | **y** | Supersedes `Analysis/plots/hospital/heterogeneity_SafetyNet_Hosp_UncompCare_PctNPR.png`, whose x-axis was an unlabelled 0/1 and whose legend read `High_CDD` / `Is_Extreme_Drought`. Uncompensated-care and operating-margin panels, safety-net vs other hospitals, 95% intervals, one interaction p per hazard. Reads the same CSV as E3-T4. |
| E3-F1 Vulnerability map · F3 energy-vs-SVI · F5 debt-by-coverage · F6 concentration curve | §8 Figs | — | TBD at drafting | — | — | pending | Built during Essay-3 drafting. |
| E3-T6 Burden concentration | Essay 3 §8 | `Analysis/policy/concentration_table.{csv,tex}` (**BUILT 2026-08-18**); source `concentration_topshares.csv` | `create_essay23_exhibits.R` | 4.5.2 | county panel + policy layer | **y** | Share of measured burden borne by the most vulnerable 10/20/50 percent of population, by burden band. Two bands are constructed with a **uniform per-capita** burden and are flagged as such in the table -- they are a reference line, not a finding. |
| E3-F6 Concentration curve | Essay 3 §8 Fig | `Analysis/policy/fig_concentration_lorenz.png` | (existing policy layer) | -- | as E3-T6 | **y** | **Was listed as not built; it already existed** and only needed wiring into the renderer (2026-08-18). Shares its data with E3-T6. |

## Cross-cutting / methods & policy (Intro, Ch5)

| Exhibit | Section | Output file(s) | Generating script | R | Post-dedup? | Notes |
|---|---|---|---|---|---|---|
| Descriptive figures | Intro / Essay 1 | `Analysis/plots/descriptive/fig{1,2,3}_*.png`, `ts_*.png` | `run_descriptive_stats.R` | 4.2.2 | **y** (13:48) | Re-run to `Analysis/plots/descriptive/`. |
| Control-sensitivity (bad-control) table | Methods appendix | `Analysis/control_sensitivity/control_sensitivity_table.csv` | `run_control_sensitivity.R` | 4.2.2 | **y** (this track, task 3.1) | No-control primary for total-effect language. |
| Premium equivalence bounds | Essay 1 appendix / Ch5 | `Analysis/mediation/passthrough_bounds.csv`, `passthrough_bounds_summary.md` | `run_passthrough_bounds.R` | 4.2.2 | **y** (12:07) | Drought STRONG; heat/cold loosely bounded. |
| Policy scenario table | Ch5 | reuses 2012-DiD ATT, Medicare coefs, dose/event-study, exposure×pop | (no new family — cites above) | — | **y** | Label each scenario as event / recurring / accounting / causal per §9. |

---

## Hospital join-duplication finding (brief deliverable)

**No hospital-year rows were ever duplicated by split counties, in either master vintage.**
`Code/process_hospital_panel.R` attaches county climate shocks to the CCN×Year panel at
lines 221–233. Before the `left_join(by = c("fips_code","Year"))` it applies
`distinct(fips_code, Year, .keep_all = TRUE)` to the county-shock frame (line 223). The
shock columns are county-level objects that are **constant within any `(fips_code,Year)`
duplicate group** (the dedup constancy proof: only the 5 premium/rating-area columns vary), so
the first-row pick is lossless. Consequently:

- The split-county fan-out that inflated the pre-dedup county master (568 extra rows) **never
  reached the hospital panel** — the `distinct()` guard neutralized it pre- and post-dedup.
- Hospital incidence / heterogeneity / persistence are therefore **exactly dedup-invariant**
  (matches the audit-verified winsorized numbers: heat×safety-net p=0.0132; drought $ incidence
  −$3.88M winsorized / −$6.21M default; N=56,874 hospital-years, 4,859 hospitals for `Uncomp_Real`).
- The RDS was nonetheless rebuilt (2026-07-13 13:20) from the certified 118,732-row master, and
  all six hospital runs (3 scripts × default + `HOSP_WINSORIZE=1`) read the fresh RDS (13:22–13:23).

## Stale-prose fixes applied (2026-07-13)

- **`Analysis/mechanism/mechanism_verdict.md`** (hand-authored — no `Code/` generator): §2 bullet 1
  cold-employment low-ag figures (−721 / −2,011) struck through + SUPERSEDED banner → Row 11a
  (levels/county-size artifact, dies in logs, commits `5c615dd`/`ddfc448`). Headline verdict and
  the "ratio question" point 2 reworded to rest on heat×labor / heat×energy-burden gradients.
- **`Analysis/event_study/synthesis.md`** (script-generated by `synthesize_event_study.R`): the
  manual-CS drought e=0 −$1,050 and "2012 Midwest drought" label lived in a **hand-appended**
  "Key Finding 7/8/9" tail. On regeneration (13:23) the generated file is clean (Key Findings
  1–6 only); the hand tail was archived to
  `Analysis/event_study/_archive/synthesis_prededup_handnarrative_20260713.md`, to which a
  SUPERSEDED banner was added (frontier e=0 −$324 SE 276 null; cohort = GA/Mountain West/Plains,
  not Midwest). Live path carries neither stale claim.

## Residual provenance notes (for the descriptive owner / Phase 5)

- `run_descriptive_stats.R` writes its narrative as `descriptive_stats_report.md` (fresh 13:48),
  but `Analysis/INDEX.md` points the family's read-first at `synthesis.md` (still 2026-03-04 —
  a manual rename during the July reorg, **not** script-generated under that name). Reconcile at
  Phase 5 (regenerate/rename), not touched here.
- All movements above are **< 0.15 SE**; none triggered the "investigate before accepting" gate.
