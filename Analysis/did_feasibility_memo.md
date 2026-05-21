# DiD Feasibility Memo — Phase 0 (Committee Feedback Track)

**Date:** 2026-05-21
**Source script:** `Code/run_never_exposed_inventory.R`
**Inputs read:** `Data/county_level_master.csv` (3,225 counties × 13 years, 2011–2023)
**Outputs:**
- `Analysis/never_exposed_inventory.csv` — one row per (county × shock)
- `Analysis/never_exposed_summary.csv` — per-shock totals
- `Analysis/never_exposed_by_state.csv` — per-shock × state
- `Analysis/never_exposed_event_year.csv` — per-shock × year onset counts

---

## 1. Question

The April 2026 committee asked whether there are *never-exposed counties* that could anchor a clean diff-in-diff design as a complement to the dynamic-panel impulse-response (LP/event-study) work already in Phase 2. This memo summarizes the exposure inventory and recommends which shocks advance to Phase 3a (sharp natural-experiment 2×2) and Phase 3b (Callaway-Sant'Anna with never-treated controls).

## 2. Exposure inventory (2011–2023)

| Shock | Counties total | Ever-exposed | Never-exposed | Share never | Mean events (ever) | Max events |
|-------|----------------|--------------|---------------|-------------|--------------------|------------|
| Is_Extreme_Drought | 3,225 | 603 | **2,534** | **78.6%** | 1.55 | 7 |
| High_HDD           | 3,225 | 834 | **2,303** | **71.4%** | 8.52 | 13 |
| High_CDD           | 3,225 | 1,016 | **2,121** | **65.8%** | 9.74 | 13 |
| High_AQI_Max       | 3,225 | 1,048 | 100   | 3.1%  | 7.35 | 13 |

Notes:
- `Is_Extreme_Drought` is sparse (mean 1.55 events conditional on ever-exposed). Pre-shock means are estimable, making it the cleanest 2×2 candidate.
- `High_HDD` and `High_CDD` are persistent — conditional-on-ever counties are exposed in most years. Useful for CS-DiD with never-treated comparisons, but a single-year sharp event is hard to isolate because exposure is highly recurring.
- `High_AQI_Max` has effectively no never-exposed pool (only 100 counties, mostly in low-pollution mountain/coastal states) — **insufficient for never-treated DiD**.

## 3. Geographic concentration of treatment

Top-10 ever-exposed states per shock (from `Analysis/never_exposed_by_state.csv`):

- **Drought:** TX (188), GA (59), NE (47), CA (41), CO (41), NM (29), OK (21), KS (19), NV (16), LA (15). Treatment runs through the Great Plains, Texas, and the Mountain West; large never-exposed pool in the East and upper Midwest.
- **HDD:** MN (87/87), MI (81/83), IA (76/99), WI (72/72), SD (66/66), MT (56/56), ND (53/53), NE (49/93), NY (44/62), CO (41/64). Treatment clusters in the Upper Midwest and Northern Plains; never-exposed pool dominates the South.
- **CDD:** TX (249/254), GA (143/159), MS (82/82), OK (76/77), FL (67/67), AL (66/67), LA (64/64), AR (63/75), NC (47/100), SC (42/46). Treatment is the South; never-exposed pool is the North and West.
- **AQI:** CA (54), NC (45), TX (44), PA (41), IN, OH, FL, NY, CO, GA. No clean never-exposed control pool.

## 4. Top onset years (candidates for sharp natural-experiment DiD)

| Shock | Year | New-onset counties | Onset rate | Comment |
|-------|------|--------------------|------------|---------|
| Is_Extreme_Drought | **2012** | **139** | 4.4% | Classic Midwest drought; large coverage and clean prior-non-shock cohort. |
| Is_Extreme_Drought | 2022 | 110 | 3.5% | Western megadrought; late panel — fewer post-event years available. |
| Is_Extreme_Drought | 2021 | 101 | 3.2% | — |
| High_HDD | **2013** | **407** | 13.0% | Cold-year onset; largest single-year HDD shock in the panel. |
| High_HDD | 2018 | 176 | 5.6% | — |
| High_CDD | **2018** | **250** | 8.0% | Hot-year onset. |
| High_CDD | 2015 | 182 | 5.8% | — |
| High_AQI_Max | 2023 | 336 | 34.1% | Canadian wildfire smoke; but ~3% never-exposed pool — not usable as DiD treatment year. |
| High_AQI_Max | 2020 | 236 | 23.6% | Western wildfires; same control-pool limitation. |

## 5. Recommendation

### Advance to Phase 3a (sharp 2×2 DiD)
1. **Is_Extreme_Drought, event year 2012** — primary candidate. 139 new-onset counties (treatment), 2,534 never-exposed (control pool). Pre-period 2011 (one year) and post-period 2013–2023 (eleven years) supported by data. Treatment cohort lies disproportionately in the Great Plains and Midwest; control pool is well-distributed nationally.
2. **High_HDD, event year 2013** — secondary candidate. 407 new-onset counties, 2,303 never-exposed. More post-event coverage. Treatment cohort is regional (Upper Midwest / Plains), so parallel-trends test should be reported on a region-restricted comparison too.

### Advance to Phase 3b (Callaway-Sant'Anna with never-treated controls)
3. **Is_Extreme_Drought, High_HDD, High_CDD** — all have ≥65% never-exposed pools and multi-year onset variation suitable for cohort-level ATT estimation.

### Drop from DiD scope
4. **High_AQI_Max** — 3.1% never-exposed is too thin for a defensible never-treated control. Keep the existing LP/event-study coverage from Phase 2; do not add a DiD spec.

### Caveats to flag in the write-up
- The county master is currently not enforced one-row-per-county-year (deferred Phase 2 task). Phase 3 scripts must dedupe before constructing treatment cohorts.
- Treatment-control geographic imbalance (especially for HDD/CDD) means an unrestricted comparison conflates climate-shock effects with latent regional differences. Two-way fixed effects in the canonical 2×2 absorb time-invariant county heterogeneity, but pre-trend diagnostics on a region-restricted sample (e.g., HDD: Upper Midwest treatment vs. NY/PA/CO controls only) should be reported alongside the full-sample result.
- The 2022 megadrought onset is a possible robustness check for drought DiD but provides only 1–2 post-event years.
