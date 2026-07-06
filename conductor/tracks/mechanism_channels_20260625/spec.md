# Track Specification: Mechanisms — Agricultural Channel & Beyond

**Created:** 2026-06-25
**Origin:** External-reader feedback (`Text/correspondence/external_reader_feedback.md`).

## Description
An external reviewer's central critique: the thesis presents credible **reduced-form**
climate→health-cost relationships but does not yet **point readers to the mechanisms** that
generate them. His leading hypothesis is the **agricultural income channel** — cold/drought
shocks devastate agriculture, which depresses local income, which in turn drives the
premium / debt / employment results we report. His framing question:

> "How much of what you're finding **cannot** be explained by that channel? And what other
> channels might be in play?"

He explicitly asks not for *perfect* mechanism identification but for **suggestive evidence
that bounds the agricultural channel and gestures at the others.** This track delivers that.

## What the reviewer raised, and how this track responds

| Reviewer point | Disposition |
|----------------|-------------|
| **Mechanisms / agricultural income channel** (his "biggest question") | **Primary objective.** Build a structural agricultural-dependence moderator; quantify how much of each headline effect is vs. is **not** the agricultural channel. |
| **Other channels in play** | **Secondary.** The hospital-finance channel is already its own track (`hospital_supply_side_20260615`) and the air-quality/health channel is already in the panel. This track adds bounded proxies/discussion for energy-burden and labor-reallocation, and ties the channels together in one narrative. |
| **Shocks as a draw from a distribution / anticipatable vs. not** | **Documentation only** (reviewer said "set aside"). Already operationalized: shocks are z-score deviations anchored to a 1990–2000 baseline. Write this up explicitly in the technical note. |
| **Handling multiple shocks** | **Documentation only.** Already operationalized via `cumulative_dose.R` and the compound/`Any_Shock` specs. Write it up. |

## Core design (key decisions)
- **Moderator is structural, not contemporaneous.** Agricultural dependence is measured as a
  **time-invariant / baseline** county attribute (USDA ERS typology + pre-period farm-earnings
  share). Interacting shocks with *contemporaneous* farm income would be a **bad control** on
  the causal path — explicitly avoided (consistent with the DiD track's no-contemporaneous-
  mediators rule).
- **"How much cannot be explained by agriculture" = the effect that survives in low-ag
  counties.** Two complementary readings: (A) a Shock × Ag-dependence interaction (does the
  effect *load* on agricultural counties?), and (B) the shock effect estimated **within the
  bottom tercile of agricultural dependence** (urban/service counties) — the residual there is,
  by construction, not the agricultural channel. Report the ratio effect_low-ag / effect_overall.
- **Outcomes/shocks reuse the existing headline set** — no new estimator. Outcomes:
  `PCPI_Real`, `Med_HH_Income_Real`, `Civilian_Employed`, `Benchmark_Silver_Real`,
  `Lowest_Bronze_Real`, medical-debt share. Shocks: `Is_Extreme_Drought`, `High_HDD`,
  `High_CDD` (agriculture-relevant ones lead). County + year FE, state-clustered, per
  `run_county_analysis.R`.

## Data (all reachable; no new credentials)
- **USDA ERS County Typology Codes (2015)** — `Farming-dependent` county flag. Keyless CSV
  download from ERS.
- **BEA CAINC5N / CAINC4** — farm earnings (and total earnings) by county, to compute a
  **farm-earnings share**. Same `BEA_API_KEY` already used for CAINC1.
- **ACS 5-year** — agriculture/forestry/fishing/mining employment share (`C24030` or `DP03`).
  Same `CENSUS_API_KEY`.
- Existing county master (`Data/county_level_master.csv`) for outcomes, shocks, SVI, controls.

## Variable scope (new)
| Variable | Source | Note |
|----------|--------|------|
| `Ag_Dependent` | USDA ERS typology 2015 | binary structural flag |
| `Farm_Earnings_Share` | BEA farm / total earnings, baseline-averaged | continuous moderator |
| `Ag_Emp_Share` | ACS ag-sector employment / civilian employed, baseline-averaged | continuous cross-check |
| `Ag_Dependence_Tercile` | tercile of the composite | for subsample (A/B) reading |

## Objectives
1. Build `Data/intermediate_ag_dependence.rds` (county-level structural ag-dependence) with
   coverage reported and tested.
2. **Agricultural-channel bound:** for each headline (outcome, shock) pair, estimate the
   Shock × Ag-dependence interaction **and** the within-low-ag-tercile effect; report the
   share of the effect attributable to vs. independent of the agricultural channel.
3. **Other channels:** document the hospital channel (cross-ref the supply-side track), the
   AQI/health channel, and add feasible proxies/discussion for energy-burden and labor
   reallocation — flagged honestly as suggestive, not identified.
4. **Definitional write-up:** add a technical-note subsection explaining shocks-as-
   distributional-draws (z-score baseline anchoring) and multiple-shock handling (cumulative
   dose / compound specs).
5. Fold a "Mechanisms" subsection into the synthesis docs / technical note with an explicit
   verdict.

## Out of scope
- Perfect / causal mechanism identification (reviewer concedes this is not the goal).
- A full county-year agricultural-production (yield) panel (USDA NASS Census of Agriculture is
  quinquennial; annual QuickStats yields are spotty) — the structural moderator is sufficient
  for bounding the channel.
- The hospital-finance channel's *estimation* (owned by `hospital_supply_side_20260615`; this
  track only cross-references it).
- Re-opening shock **definition** (z-score thresholds) — only documenting it.

## Acceptance Criteria
- Ag-dependence intermediate built, merged, coverage + match-rate reported and tested.
- For every headline (outcome, shock) pair: interaction estimate + low-ag-tercile estimate
  tabulated, with the effect-share-not-explained-by-agriculture stated numerically.
- A documented verdict on which headline findings are **mostly agricultural** (e.g. expect
  drought→income) vs. which **persist in non-agricultural counties** (the part needing other
  channels).
- Other-channel section written with honest "suggestive" labeling and a cross-ref to the
  hospital track + AQI channel.
- Technical note gains the shocks-as-distribution and multiple-shock subsections.
- Synthesis docs gain a Mechanisms subsection.
