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
| E1-T1 Sample & variable defs | §6 Data | `Analysis/descriptive/descriptive_stats_table_main.{csv,tex}`, `descriptive_stats_summary.csv` | `run_descriptive_stats.R` | 4.2.2 | county master | **y** (re-run 2026-07-13 13:48) | Summary moments over 118,732 rows / 41,863 study rows. Trivial shift from 0.3% row drop. **Generator fix:** `output_dir` default changed `"Analysis"`→`"Analysis/descriptive"` (was scattering CSVs to root, against CLAUDE.md); root debris moved to `Analysis/descriptive/_archive_root_debris_20260713/`. |
| E1-T2 2012 drought balance / cohort | §6 Design | `Analysis/did/did_2x2_drought_2012.csv`; balance in `did_results.md` | `run_did_analysis.R` | 4.2.2 | county master | **y** (certified invariant) | 139 first-onset vs 2,534 never-exposed. Cohort = GA + Mountain West + Plains (NOT "Midwest"). |
| E1-T3 Main DiD estimates | §6 Main result | `Analysis/did/did_2x2_drought_2012.csv` | `run_did_analysis.R` | 4.2.2 | county master | **y** (identical) | PCPI_Real ATT **−$1,311** (robustness-suite frame −1,310.67; 2×2 CSV −1,311.30 — same spec family, both p≈0.027) — dedup-invariant (Δ=0). |
| E1-T4 Inference & robustness | §6 Falsification | `Analysis/did/robustness/did_robustness_summary.md`, `dr_csdid_eventtime.csv`, `falsification_summary.md` | `Code/did_robustness/*.R` | **4.5.3** | county master | **y** | WCB p 0.036; RI 0.0075; DR ATT −$1,451; LOO envelope [−1,687,−914]; placebo 0.009. Frontier pooled **e=0 = −$324 (SE 276): null** — governs (retires manual-CS −$1,050). |
| E1-T5 Cross-cohort / external validity | §6 Ext. validity | `Analysis/did/did_cs_event_time.csv` (descriptive), frontier `dr_csdid_*` (inference) | `run_did_analysis.R` (manual, descriptive-only) + `Code/did_robustness/*` | 4.2.2 / 4.5.3 | county master | **y** | Manual-CS aggregation is **descriptive only** (audit A4; invalid independence SEs). Cite inference from frontier layer. |
| E1-T6 Medicare utilization | §6 Medicare | `Analysis/mechanism/medicare_channel_coefs.csv` | `run_mechanism_medicare.R` | 4.2.2 | county master + CMS Geo Variation (2014–2023) | **y** (re-run 13:16) | Heat→std spending **$111.6** (L1 **$175.6**, L2 $75.3); ED +7.8/L1 +9.5. ~0 SE move vs pre-dedup $112/$177. N=30,641 / 3,124 counties. |
| E1-T7 Financial-ledger comparison | §6 Ledgers | `Analysis/mediation/premium_passthrough.csv`, `premium_mediation_summary.md`; state/county debt in `state/`, `county/` | `run_premium_mediation.R` (+ state/county analysis) | 4.2.2 | county master + `Data/premiums_county.csv` | **y** (rebuilt this track, task 2.1) | RA panel rebuilt from source; drought pass-through β **3.13** (SE 2.60), δ*=7.40 STRONG; 92–99% debt effect survives premium adjustment. |
| E1-F2 Income pretrends | §6 Fig | `Analysis/did/did_pretrends_event_study.csv` | `run_did_analysis.R` | 4.2.2 | county master + BEA 1990–2011 | **y** | 1990–2011 differential trend −$69/yr (p=0.44). |
| E1-F3 Event-time income profile | §6 Fig | `Analysis/did/robustness/dr_csdid_eventtime.csv` | `Code/did_robustness/*` | **4.5.3** | county master | **y** | Frontier event-time; e=0 null. |
| E1-F4 Medicare dynamic responses | §6 Fig | `Analysis/mechanism/plots/fig_medicare_morbidity.png`; coefs `medicare_channel_coefs.csv` | `run_mechanism_medicare.R` | 4.2.2 | county master + CMS | **y** | Re-run 13:16. |
| E1-F1 Treated/never-exposed map · E1-F5 Institutional-ledger figure | §6 Figs | — (no committed output) | TBD at drafting | 4.2.2 | — | pending | Map + summary figure to be generated during Essay-1 drafting. |

## Essay 2 — Persistence (scarring / compounding)

Owns: transition symmetry, cumulative dose, recurring exposure, LP dynamics, cross-estimator.

| Exhibit | Section | Output file(s) | Generating script | R | Key inputs | Post-dedup? | Notes (before→after) |
|---|---|---|---|---|---|---|---|
| E2-T1 Transition frequencies / support | §7 | `Analysis/delta/delta_transition_summary.csv` | `run_delta_analysis.R` | 4.2.2 | county master | **y** (re-run 13:10) | Transition counts on deduped panel. |
| E2-T2 Onset / persistence / exit coefs | §7 | `Analysis/delta/delta_coefs.csv` | `run_delta_analysis.R` | 4.2.2 | county master | **y** (13:10) | Incl. `Delta_Exit_LP` / `Delta_Exit_Interaction` blocks. |
| E2-T3 Symmetry tests | §7 | `Analysis/delta/delta_symmetry_test.csv` | `run_delta_analysis.R` | 4.2.2 | county master | **y** (13:10) | **Drought debt exit asymmetry h=2 (unwtd) = +0.01874 (p=0.00073)** vs pre-dedup ~0.0182 → Δ/SE ≈ **+0.09** (unchanged). |
| E2-T4 Cumulative-dose contrasts | §7 | `Analysis/cumulative_dose/cumulative_dose_marginal.csv`, `_coefs.csv` | `run_cumulative_dose.R` | 4.2.2 | county master | **y** (13:11) | **Cold(HDD) employment binned 10+ vs 1–3 (unwtd) = −5,522 (SE 1,196, p=3.9e-6)** vs pre-dedup −5,668 → Δ/SE ≈ **+0.12**. Smooth quadratic ME_diff flat (est-dependent; disclose per B6). |
| E2-T5 Cross-estimator comparison | §7 | `Analysis/event_study/event_study_full_results.csv`; + dose + CS DiD | `run_event_study.R` / `synthesize_event_study.R` (+ did) | 4.2.2 / 4.5.3 | county master | **y** (13:23) | 1,668 coefs / 278 specs regenerated; synthesis clean (see event-study prose note). |
| E2-F2 Drought transition response | §7 Fig | `Analysis/plots/` (delta LP) | `run_delta_analysis.R` | 4.2.2 | county master | **y** (13:10) | |
| E2-F3 Cold cumulative-dose (binned+smooth) | §7 Fig | `Analysis/plots/lp_Shock_Count_*.png` + dose | `run_cumulative_dose.R` / `synthesize_event_study.R` | 4.2.2 | county master | **y** | Honesty box: binned + long-run support compounding; smooth quadratic flat. |
| E2-F5 Cross-estimator figure | §7 Fig | `Analysis/plots/synthesis_robustness_panel*.png` | `synthesize_event_study.R` | 4.2.2 | county master | **y** (13:23) | |
| (support) Persistent-exposure cohort contrasts | §7 §6 | `Analysis/persistent_exposure/persistent_exposure_contrast.csv`, `_dynamic.csv`, `_cohort_summary.csv` | `run_persistent_exposure.R` | 4.2.2 | county master | **y** (13:16) | Never-exposed set is shock-defined ⇒ dedup-invariant; contrasts regenerated. `never_exposed_inventory.csv` (05-21) is a separate descriptive inventory, **not** an input to this script. |
| E2-F1 Concept diagram · E2-F4 Heat saturation | §7 Figs | — | TBD at drafting | — | — | pending | Conceptual diagram hand-drawn; heat-saturation panel from dose/event-study at drafting. |

## Essay 3 — Distributional and institutional incidence

Owns: SVI heterogeneity, energy/labor moderators, safety-net hospitals, debt visibility, burden concentration.

| Exhibit | Section | Output file(s) | Generating script | R | Key inputs | Post-dedup? | Notes (before→after) |
|---|---|---|---|---|---|---|---|
| E3-T1 Moderator defs & correlations | §8 | `Analysis/mechanism/horserace_modcorr.csv` | `run_mechanism_horserace.R` | 4.2.2 | county master + SVI/energy/ag | **y** (13:19) | EnergyBurden–SVI corr 0.11; EnergyBurden–Ag 0.32. |
| E3-T2 SVI marginal effects | §8 | `Analysis/exposure_index/exposure_interaction_coefs.csv` (county), `exposure_interaction_state_coefs.csv` (state) | `run_exposure_index.R`, `run_exposure_index_state.R` | 4.2.2 | county master + SVI | **y** (13:15) | **Amplifies-in-vulnerable** stable: Drought×SVI→premium interaction +138 (p=0.0012); Heat×SVI→employment −2,110 (p=0.0010); Cold×SVI→PCPI amplifies. |
| E3-T3 Energy / labor horse race | §8 | `Analysis/mechanism/horserace_coefs.csv` | `run_mechanism_horserace.R` | 4.2.2 | county master + energy/labor/ag/SVI | **y** (13:19) | Heat×EnergyBurden→log emp **−0.00647 (p=0.020)**; energy burden dominates SVI (SVI ns) in the joint spec. |
| E3-T4 Safety-net hospital heterogeneity | §8 | `Analysis/hospital/hospital_heterogeneity_coefs.csv` (+ `_winsorized.csv`) | `run_hospital_heterogeneity.R` | 4.2.2 | hospital panel RDS | **y** (13:23; +wins) | **Heat×SafetyNet→uncomp %NPR: winsorized interaction 0.0209, p=0.0132** (was p=0.013) — survives. Dedup-invariant. |
| E3-T5 Debt visibility gradients | §8 | `Analysis/latent_hardship/latent_hardship_gradients.csv` | `run_latent_hardship.R` | 4.2.2 | county master | **y** (certified invariant) | Drought×uninsurance −0.00547 (q=0.012), the only multiplicity-robust cell. |
| E3-T6 Burden concentration | §8 | — (no committed output) | TBD at drafting | 4.2.2 | exposure×population×SVI | pending | Concentration curve = descriptive accounting; build at Essay-3 drafting. |
| (support) CHEI composite / robustness / person-years | §8 exploratory | `Analysis/exposure_index/exposure_chei_coefs.csv`, `exposure_robustness.csv`, `exposure_personyears_trend.csv` | `run_exposure_secondary.R` | 4.2.2 | county master + SVI | **y** (13:15) | CHEI is exploratory (not a causal price). |
| (support) Hospital incidence / persistence | §8 provider | `Analysis/hospital/hospital_incidence_coefs.csv` (+`_winsorized`), `hospital_persistence_coefs.csv` (+`_winsorized`) | `run_hospital_incidence.R`, `run_hospital_persistence.R` | 4.2.2 | hospital panel RDS | **y** (13:22–13:23; +wins) | Drought→uncomp $ cumulative default **−$6.21M** / winsorized **−$3.88M**. Dedup-invariant. |
| E3-F2 Marginal effects by SVI · E3-F4 Safety-net response | §8 Figs | `Analysis/plots/exposure_index/*`, `Analysis/plots/hospital/*` | `run_exposure_index.R`, `run_hospital_heterogeneity.R` | 4.2.2 | see above | **y** | |
| E3-F1 Vulnerability map · F3 energy-vs-SVI · F5 debt-by-coverage · F6 concentration curve | §8 Figs | — | TBD at drafting | — | — | pending | Built during Essay-3 drafting. |

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
