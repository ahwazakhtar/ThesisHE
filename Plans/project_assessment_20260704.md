# Project Assessment — Climate Shocks and the Financial Health of American Households
**Date:** July 4, 2026
**Purpose:** A comprehensive stock-take of the dissertation: where the research questions started, how the data and methods now answer them, what is robust, what is fragile, and what gaps remain. A companion document, `Plans/roadmap_recommendations_20260704.md`, translates this into a prioritized, time-triaged plan.

---

## Part I — Where the project started

### The original proposal (October 28, 2025)

`Text/v2_Akhtar_Proposal.pdf`, "The Financial Impacts of Climate Shocks on Healthcare," framed the dissertation around a demand / supply / structural triad:

> "This dissertation investigates how climate shocks propagate through U.S. healthcare financing on both the **demand (households/insurers) and supply (hospitals) sides**, and then embeds those empirical relationships in a **structural policy model**."

| Chapter | Question as proposed | Design as proposed |
|---|---|---|
| **Ch. 1 — Patients (demand)** | Whether — and how quickly — local climate shocks feed through to higher benchmark premiums and medical debt | ACA SLCSP premiums + credit-bureau medical debt; stacked event study + triple-difference off the 2022–23 credit-reporting reforms; a **premium→debt mediation test** |
| **Ch. 2 — Providers (supply)** | How extreme heat and wildfire smoke affect uncompensated care and hospital operating performance | Hospital-year HCRIS/S-10 panel; FE event studies; heterogeneity by safety-net status, rurality, Medicaid expansion |
| **Ch. 3 — Structural policy model** | How premium subsidies should be calibrated to the evolving distribution of climate risk and measured pass-through | Semi-structural microsimulation (rating-area × year × income bin) with sufficient statistics (claims sensitivity β_z, pass-through ρ, enrollment elasticity); counterfactual PTC subsidy schedules; welfare (ΔCS), efficiency–equity frontiers |

Headline hazards as proposed: **extreme heat, wildfire smoke/PM2.5, FEMA disaster events.**

An even earlier kernel (`Text/abstract_draft.md`, the EUHEA proposal) was a single state-level paper, "The Lagged Financial Burden of Climate Shocks (1996–2025)": drought and temperature anomalies → premiums, medical debt, and systemic spending at 0/1/2-year lags. That distributed-lag reduced form remained the empirical spine of everything that followed.

### How the framing evolved (five stages)

1. **Oct 2025 — Proposal:** demand / supply / structural; heat + wildfire smoke + disasters.
2. **Mar 2026 — Outcome layers:** committee decks reorganize around shock × outcome layers; the panel shifts from state 1996–2025 to **county 2011–2023** as the primary unit.
3. **Apr 2026 — Committee feedback absorbed:** the April committee asked for (i) random-effects/Hausman checks, (ii) exit dynamics ("if a county leaves a shock, what happens?"), (iii) smaller natural experiments with never-exposed controls, (iv) evidence-backed propagation pathways, (v) humidity. Every ask was implemented and each generated a design that is now load-bearing (the 2012-drought DiD, the onset/exit symmetry framework, PRISM humidity).
4. **May–Jun 2026 — The Incidence / Persistence / Inequality reorganization:** three essays answering *how much / how long / who bears it*, with the hospital results woven into each essay as a "second ledger" rather than standing as their own chapter. Headline hazards became **cold and drought** (heat secondary, wildfire smoke collapsed into a minor AQI role).
5. **Jun–Jul 2026 — Mechanisms response:** an external reader asked how much of the findings could be the agricultural income channel. The response added five county data sources and concluded **agriculture is one channel, not the channel** — the cleanest evidence being a directly-measured Medicare morbidity/utilization channel, plus broad (non-farm) labor exposure and a distinct energy-burden margin.

**Net drift to be aware of:** the dissertation delivered *more* than proposed on persistence and mechanisms, and *less* than proposed on the structural side. The structural Chapter 3 was replaced by a reduced-form Inequality essay; the proposed premium→debt mediation test was never estimated; wildfire smoke and FEMA disasters were demoted. None of this is fatal — the replacement structure is arguably stronger empirically — but Part V flags what still needs an explicit committee sign-off.

---

## Part II — The dissertation as it stands (the three essays)

Current abstracts: `Text/thesis_paper_abstracts.md`. Umbrella title: *"Climate Shocks and the Financial Health of American Households: Incidence, Persistence, and Inequality."*

| Essay | Question | Core designs | Headline results |
|---|---|---|---|
| **1 — Incidence** ("Deferred Costs") | How much do climate shocks cost households, and at what lag? | State + county distributed-lag TWFE; 2012-drought never-exposed DiD (+ DRDID); local projections; Medicare morbidity channel; ag-channel bounding | Cold → medical-debt share +1.1 pp (lag 1); drought → +0.7 pp (lag 2) and premiums +$18; 2012 drought → income −$1,311, employment −2,053; heat → Medicare spending +$112–177/beneficiary, ED visits +8–10/1,000 |
| **2 — Persistence** ("Scarring and Compounding") | Does the damage reverse, scar, or compound? | Onset/persist/exit LP with Wald symmetry tests; cumulative-dose (shock-years); chronic-exposure cohorts; CS-DiD long-run event studies; migration selection | Drought debt **scars** (h=2 asymmetry +1.8 pp, does not unwind); cold **compounds** (10th cold-year ≈ −5,700 more jobs than the 1st; CS-DiD −4,982 jobs and +4.9 pp debt at e=10); heat **saturates**; part of the drought scar is out-migration |
| **3 — Inequality** ("Unequal Weather") | Who bears the cost? | Shock × SVI interactions (county + state mirror); composite CHEI; Lancet-style person-years; energy-burden interactions; hospital safety-net heterogeneity | Cold income harm ~8× larger at high SVI; heat flips employment gain to loss at high SVI; heat damage concentrates in high-energy-burden counties (r = 0.11 with SVI — a distinct margin); heat × safety-net raises uncompensated care where margins are thinnest |

The **hospital supply side** (59,896 hospital-years, 5,119 hospitals from NASHP HCT) runs through all three: cold raises uncompensated care ~$1.55M/hospital cumulatively; margins are null on average (absorbed on the uncompensated-care line); drought *lowers* measured uncompensated care — the literature-consistent "expected paradox," itself a measurement-fragility story parallel to medical debt.

---

## Part III — Data and methods: how the questions are answered

### Data assets (all built, validated, and merged)

- **Panels:** state (1996–2025 spine, study 2011+), county (3,155 counties × 2011–2023, 41k rows), hospital-year (CCN × 2011–2023), rating-area (premium robustness).
- **Hazards:** NOAA temp/precip/CDD/HDD/PDSI (z-scored to a fixed 1990–2000 baseline — no look-ahead), EPA AQI, PRISM humidity (CONUS).
- **Outcomes:** HIX benchmark premiums, Urban Institute medical debt, NASHP hospital finance, MEPS-IC employer premiums, CMS NHE spending, BEA income, ACS employment/income, CMS Medicare Geographic Variation (2014–2023).
- **Moderators (structural, pre-treatment):** CDC SVI, USDA ERS ag typology + BEA farm-earnings share, ACS industry composition (climate-exposed non-farm share), DOE LEAD energy burden, IRS migration flows, Medicaid expansion.

### Methods inventory (15 distinct designs, all `fixest::feols`-based except the R 4.5.3 frontier layer)

Distributed-lag TWFE (state + county) · dynamic event study / local projections with pre-trend tests · 2×2 never-exposed DiD + hand-rolled Callaway–Sant'Anna · frontier robustness on R 4.5.3 (DRDID doubly-robust, HonestDiD, wild cluster bootstrap **[unfinished]**) · weather-swing deltas with Pos/Neg asymmetry · onset/persist/exit transition symmetry (Wald) · chronic-exposure cohorts · cumulative-dose response · Shock × SVI exposure index + CHEI composite · demographic-mediator decomposition · mechanism separability (ag terciles, labor exposure, Medicare, energy burden, migration) · hospital incidence/persistence/heterogeneity · RE/Hausman · threshold sensitivity.

### Identification, honestly stated

The causal core is within-unit weather variation under two-way FE, anchored to a fixed pre-study climatology — a standard and defensible climate-economics design. The 2012 drought DiD sharpens it with never-exposed controls. The design's two known vulnerabilities are exactly the ones the (unfinished) frontier track targets: **few treated clusters** (67% of the 2012 cohort sits in 4 states → wild bootstrap / randomization inference, *not yet run*) and **parallel trends** (DRDID run — supportive for income; HonestDiD run — cannot vindicate the 2012 cohort because the panel starts in 2011, leaving it no testable pre-period). Everything interaction-based (SVI, ag, energy burden) is heterogeneity/amplification, not causal moderation — the write-ups already frame it that way.

---

## Part IV — Robustness scorecard

### Solid (lead with these)

| Finding | Why it holds |
|---|---|
| **Drought → income (2012 DiD)** | DRDID doubly-robust *strengthens* it (−$1,451 vs −$1,311 unconditional); Med_HH_Income confirms (−$1,186) |
| **Cold → medical-debt share (state, lag 1)** | Survives humidity (stable to 3 significant figures), demographics (fraction surviving ~0.94–1.04), stricter p90 thresholds, RE/Hausman |
| **Cold employment compounding** | Cumulative dose monotone (−1,269 → −6,936 across dose bins, 10+ vs 1–3 = −5,668, p<0.0001); CS-DiD confirms widening gap to e=10 |
| **Drought debt scar (h=2 asymmetry)** | Onset/exit Wald test; consistent with state lag-2 headline; migration caveat *quantified*, not hand-waved |
| **SVI amplification on real-economy outcomes** | Replicates at both county and state level (the cross-level symmetry track's core deliverable) |
| **Medicare morbidity channel** | Directly measured in administrative data; reproduces Deryugina et al. (2019) in-panel; cannot be agricultural |
| **Heat × safety-net uncompensated care** | Theory-consistent, strongly significant at lags 1–2 |

### Fragile (already correctly caveated — keep it that way)

| Finding | Fragility |
|---|---|
| **Drought → employment** | DRDID attenuates ~58% (−2,053 → −871, CI barely excludes 0); pooled CS reverses to null/positive with *positive* pre-trends. Event-specific to 2012; must stay a caveated secondary result |
| **Credit-bureau medical debt** | Measurement-fragile: EJ direction flips between county and state aggregation; null on the intensive margin; requires insurance + billed care + a credit file, so it under-measures harm where harm is greatest. The thesis's own framing (debt as a *mismeasured* welfare metric) is the right defensive move |
| **HDD/CDD binary flags** | Cutoff-fragile (only ~11% of estimates significant across p70/80/90); the z-based `is_cold_shock` carries the cold story |
| **AQI** | Weakest identification: dropped from DiD (too few never-exposed), null in levels; signal only via deltas (bad-debt ratchet) and Medicare ED visits |
| **2012 cohort external validity** | The pooled multi-cohort CS estimate is null for everything — the 2012 event is one clean natural experiment, not a general law of droughted counties. The ITT/recurring-treatment estimand caveat is documented |

### The one genuinely open econometric exposure

**Few-treated-cluster inference on the 2012 DiD has not been run** (DiD frontier track, Phase 1 — started once, cancelled). With 67% of treated counties in 4 states, state-clustered analytic p-values are exactly what a referee or committee member will attack first. The script (`Code/did_robustness/01_wild_cluster_bootstrap.R`) exists, the FWL-demeaning workaround for the FE-heavy model is documented, and the run is hours, not weeks. Until it runs, the headline income result carries an unquantified inference risk.

---

## Part V — Gap analysis

### A. Proposal-vs-delivery gaps (need a committee conversation, not necessarily work)

1. **Chapter 3 structural model — never built.** The microsimulation, subsidy counterfactuals, welfare accounting, and California calibration have no trace in the repo. The Inequality essay occupies its slot. **Decision needed:** has the committee formally accepted the Incidence/Persistence/Inequality structure as replacing it? If not, the cheapest honest bridge is a *sufficient-statistics policy section* (see roadmap), not the full model.
2. **Premium pass-through / mediation (premiums → debt) — never estimated.** It was Ch. 1's stated novel contribution ("first joint elasticities") and Ch. 3's key input (ρ). A tractable version exists with data in hand.
3. **Hazard demotion:** wildfire smoke/PM2.5 and FEMA disasters quietly dropped. Defensible (AQI identification is thin), but should be acknowledged once, explicitly, rather than left for a committee member to notice.

### B. Open analytical work (small, well-defined)

4. **DiD frontier Phase 1** — wild cluster bootstrap + Fisher randomization inference (see Part IV).
5. **DiD frontier Phase 4/5** — the synthesis write-up (`did_robustness_summary.md`) is unwritten (results exist only as CSVs), technical-note updates pend Phase 1, and the `testthat` suite for the robustness layer is unwritten.
6. **County master data-integrity task (deferred)** — one-row-per-county-year is violated by ~3% multi-rating-area duplicate rows (currently deduped ad hoc in the DiD/RE scripts). Low risk but a defense-question magnet.
7. **Two optional county robustness items** (distributed-lag simplification; `is_extreme_drought_peak` VIF check) — deferred "until final pass."

### C. The writing gap (the binding constraint)

8. **No full essay manuscripts exist.** The repo holds abstracts, a technical note, a mechanisms section, reviewer responses, and presentation decks — but no complete Essay 1/2/3 drafts. For a time-bound thesis, prose is now the critical path, not econometrics. The NBER writing skill and exemplar are already in place.
9. **Loose ends in existing text:** two incomplete references (Audi et al. 2024–25; Doremus et al. 2022) and two `[TK]` baseline denominators in the reviewer-response file.

### D. Process debt

10. **8 open Conductor verification gates** across 7 tracks — human sign-off checklists, not analysis. They are why nearly every track still reads `[~]`.
11. Repo hygiene: stray `*.tmp.*` editor artifacts in `Code/`, `Text/`, and `conductor/`.

### E. Positioning gaps for a health-economics audience

12. **Direct health outcomes are thin.** The dissertation measures *financial* health; its physical-health content is the Medicare spending/ED channel. A health-econ committee may ask "where is mortality?" CDC WONDER county mortality is keyless, public, and would slot into the existing county pipeline as one more outcome — the standard Deryugina/Barreca-style complement. Optional but high defensive value.
13. **Welfare quantification absent.** The abstracts claim an "unpriced margin" for insurers and policymakers, but no number ever prices it. Even a back-of-envelope aggregate (scar costs × exposed population; premium mispricing implied by the lag structure) would raise the stakes of all three essays and partially honor the structural promise.

---

## Part VI — Open questions for the author

These were posed during the session and remain unanswered; the roadmap makes assumptions that should be corrected if wrong.

1. **Timeline:** What is the defense date / hard deadline? (Roadmap assumes ~6–12 months.)
2. **Job market paper:** Which essay? (Roadmap assumes Essay 1 — it has the natural experiment, the mechanism story, and the frontier robustness.)
3. **Chapter 3 status:** Has the committee formally accepted the Incidence/Persistence/Inequality reorganization as replacing the structural model, or is a policy/welfare component still owed?
4. **Scope appetite:** New identification and welfare quantification vs. writing-and-packaging only?

---

## Appendix — Conductor track ledger (as of 2026-07-04)

| Track | Substance | Open items |
|---|---|---|
| county_analysis_refinement_20260216 | Complete | 2 verification gates; deferred one-row-per-county-year task; 2 optional robustness items |
| committee_feedback_april_2026 | Complete (Phases 0–5) | 1 verification gate |
| persistence_extensions_20260521 | Complete (Phases 0–6) | 1 verification gate |
| climate_health_exposure_index | Complete (Phases 1–5) | 1 verification gate |
| cross_level_symmetry | Complete (Phases 1–3) | 1 verification gate |
| hospital_supply_side_20260615 | Complete (Phases 1–5) | 1 verification gate |
| mechanism_channels_20260625 | Complete (Phases 0–6) | 1 verification gate; optional deck slide |
| did_frontier_robustness_20260625 | Phases 2–3 run | **Phase 1 (wild bootstrap/RI) not run; Phase 4 synthesis unwritten; Phase 5 tests unwritten** |

Work cadence: one foundational track Feb–Apr 2026, then seven tightly-scoped extension tracks from late May onward, with the last substantive commits July 1–2. Momentum is high; the parked item is the frontier-DiD inference layer.
