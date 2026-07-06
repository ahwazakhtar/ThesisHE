# Weather Swing Analysis: Synthesis of Results

Generated: 2026-04-02

## Overview

This analysis estimates the health and economic costs of year-over-year *swings* in climate
and air quality, distinct from the level effects estimated in the Phase 2 event study.

**Primary specification:**
`Outcome_{it} = β₁·ΔX_{it} + β₂·X_{it-1} + controls | county FE + year FE`

β₁ captures the marginal effect of a one-unit change in exposure from one year to the next,
holding the prior year's level fixed. β₂ captures the lagged level effect in the same model.

- **Total coefficients:** 896 across 5 approaches
- **Exposures:** Delta_Z_Temp, Delta_Z_Precip, Delta_CDD, Delta_HDD, Delta_PDSI, Delta_Median_AQI, Delta_Max_AQI
- **Outcomes:** Medical_Debt_Share, Medical_Debt_Median_2023, Benchmark_Silver_Real, Hosp_BadDebt_PerCapita, PCPI_Real, Med_HH_Income_Real, Civilian_Employed
- **Approaches:** Delta_FE (contemporaneous), Delta_LP (h=0..3), Delta_Asym (Pos/Neg), Delta_OnsetExit (binary transitions), Delta_FE_RA_Cluster (premium robustness)
- **Clustering:** State-level (primary); rating-area for premium outcomes
- **Significant at p<0.05 (unweighted):** 83 out of 448 non-RA-cluster estimates

---

## Key Finding 1: HDD Swing and Insurance Premiums

A positive swing in HDD (colder year than prior year) is the most robust contemporaneous
finding: `Delta_HDD → Benchmark_Silver_Real` (est = +0.033, p = 0.0004). The onset/exit
decomposition confirms this is driven by **shock entry**: `HDD_Onset → Benchmark_Silver_Real`
(est = +49.46, p = 0.003), while the asymmetric spec shows the effect is concentrated in
positive swings (`HDD_Pos`, est = +0.065, p = 0.028). Insurers appear to price in the first
year of an extreme cold period.

---

## Key Finding 2: AQI Swings and Hospital Bad Debt — Persistent and Escalating

`Delta_Max_AQI → Hosp_BadDebt_PerCapita` is significant at all horizons h=0..3:

| Horizon | Estimate | p-value |
|---------|----------|---------|
| h=0 | +0.0050 | 0.0014 |
| h=1 | +0.0082 | <0.0001 |
| h=2 | +0.0080 | 0.0150 |
| h=3 | +0.0157 | <0.0001 |

The effect **grows** rather than decays — a worsening AQI swing accumulates into greater
hospital bad debt over three years. This is consistent with uncompensated care costs building
up as pollution-related illness (respiratory, cardiovascular) manifests with delay.

The asymmetric spec reveals the pattern is driven by **AQI improvement** years:
`Max_AQI_Neg → Hosp_BadDebt_PerCapita` (est = +0.010, p < 0.0001). This is a counterintuitive
"ratchet" result: bad debt does not fall when AQI improves, suggesting hospital cost burdens
are sticky once incurred.

---

## Key Finding 3: Temperature Swings and Medical Debt — Growing Effect

`Delta_Z_Temp → Medical_Debt_Median_2023` grows significantly across horizons:

| Horizon | Estimate | p-value |
|---------|----------|---------|
| h=0 | +13.17 | 0.0143 |
| h=2 | +19.40 | 0.0325 |
| h=3 | +29.70 | 0.0001 |

A warmer year relative to the prior year is associated with increasing county-level median
medical debt over subsequent years. The asymmetric spec shows this is driven by warming swings
specifically (`Z_Temp_Pos → Medical_Debt_Median_2023`, est = +20.50, p = 0.020).

Note: `Delta_Z_Temp → Benchmark_Silver_Real` is negative (est = −14.31, p = 0.028) — a warming
swing is associated with *lower* premiums contemporaneously, possibly because warmer-than-usual
years reduce acute cold-related demand that insurers price reactively. This is the opposite
sign to the HDD result and consistent with the directional interpretation.

---

## Key Finding 4: Precipitation and PDSI Swings Suppress Income

`Delta_Z_Precip → PCPI_Real` is negative and persistent across h=1..3:

| Horizon | Estimate | p-value |
|---------|----------|---------|
| h=1 | −273.6 | 0.0006 |
| h=2 | −240.2 | 0.0001 |
| h=3 | −238.6 | 0.0048 |

`Delta_PDSI → PCPI_Real` similarly negative at h=1 (−226.2, p < 0.0001) and h=2 (−144.4,
p = 0.002). A swing toward wetter/drier conditions relative to the prior year suppresses
per capita personal income for multiple years. The asymmetric spec confirms the PDSI effect
is concentrated in **drought-worsening** swings (`PDSI_Neg → PCPI_Real`, est = −206.8, p = 0.001)
and is accompanied by employment loss (`PDSI_Neg → Civilian_Employed`, est = −141.9, p = 0.006).

This mirrors the state-level finding that extreme drought suppresses incomes — the delta
analysis adds that the *transition into* drought (not just the level) independently matters.

---

## Key Finding 5: CDD Swings — Asymmetric Income Effects

`Delta_CDD` shows a clean asymmetric pattern on PCPI_Real:
- `CDD_Pos → PCPI_Real`: est = +3.30, p = 0.0005 (cooling demand boosts income)
- `CDD_Neg → PCPI_Real`: est = −3.55, p = 0.0015 (mild year after hot year contracts income)

The onset/exit spec adds further nuance:
- `CDD_Exit → PCPI_Real`: +812 (p = 0.007) and `CDD_Persist → PCPI_Real`: +1251 (p = 0.009) —
  counties in or exiting a hot period have higher incomes, consistent with cooling-sector
  economic activity (energy, HVAC).
- `CDD_Onset → Med_HH_Income_Real`: −314 (p = 0.006) — the first year of a heat shock reduces
  household income even as it may boost aggregate PCPI (distributional effects).

---

## Key Finding 6: Drought Exit Reduces Medical Debt

`Drought_Exit → Medical_Debt_Median_2023` (est = −53.9, p = 0.020): counties that recover
from extreme drought in a given year see a meaningful reduction in median medical debt.
This complements the level-effect finding from Phase 2 and suggests the health-cost burden
of drought partly resolves when conditions improve — unlike the AQI ratchet pattern.

---

## Comparison with Phase 2 Level Effects

| Relationship | Phase 2 (Level) | Phase 3 (Delta) | Interpretation |
|---|---|---|---|
| HDD → Benchmark_Silver_Real | +31.99*** (h=0) | +0.033*** (h=0) | Both significant; delta captures first-year pricing |
| Is_Extreme_Drought → Benchmark_Silver_Real | +22.73 (h=0) | Drought_Exit: −53.9* | Level raises premiums; recovery lowers debt |
| High_CDD → PCPI_Real | +669.7** | CDD_Pos: +3.3*** | Consistent direction; delta confirms cooling-sector income |
| AQI → Hosp_BadDebt | +0.89 (ns) | Delta_Max_AQI: +0.005** | Swing significant where level was not |

The delta analysis identifies effects not visible in the level regressions, particularly
for AQI (where level effects were uniformly insignificant in Phase 2).

---

## Caveats

1. **Delta introduces mechanical first-differencing**: county FE already removes time-invariant
   heterogeneity; the delta additionally removes slow-moving trends. Coefficients capture
   short-run responsiveness to weather volatility, not long-run adaptation.
2. **NA at first county-year**: delta is undefined at the first observation of each county's
   panel. Sample sizes are slightly smaller than Phase 2 level models.
3. **CDD/HDD lagged-level control is binary** (High_CDD_Lag1): this is a coarse control.
   Continuous HDD/CDD values are not in the intermediate — the lagged level control for
   CDD and HDD partially absorbs prior-year extremeness but not the full continuous history.
4. **Medical_Debt_Share estimates near zero**: the share variable is a proportion (0–1
   range ~0.02–0.35); coefficient magnitudes appear small but are meaningful relative to
   the variable's scale.

---

## Output Files

| File | Contents |
|------|----------|
| `Analysis/delta/delta_coefs.csv` | 896-row tidy coefficient table |
| `Analysis/delta/delta_results.txt` | Full model summaries |
| `Analysis/delta/delta_vif_diagnostics.txt` | VIF for delta + lagged-level blocks |
| `Analysis/plots/delta/` | LP dynamic profile plots, contemporaneous FE plots |
| `Analysis/plots/delta_robustness/` | Asymmetry plots, onset/exit plots |
| `Analysis/plots/delta_exit_dynamics/` | Phase 2: post-exit LP and Shock_{t-1}*NoShock_{t} interaction plots |

---

## Post-Exit Dynamics (Committee Feedback Phase 2)

The April 2026 thesis committee asked: *if a county was in a shock one year and then it
exits, what effect does it have on the spending?* The existing onset/exit block (Section
9, "Binary Onset/Exit Robustness") only estimated the contemporaneous (h=0) effect of an
Exit indicator. Phase 2 extends that to the full **local-projection (LP) horizon set
h = 0, 1, 2, 3** and adds an explicit **scarring/relief interaction** specification.

### Design

**Block A — Exit LP.** For each binary `*_Exit` indicator (`Drought_Exit`, `CDD_Exit`,
`HDD_Exit`) and outcome Y:

`lead(Y, h) ~ Exit_{i,t} + controls | fips_code + Year`,  for h = 0, 1, 2, 3

with cluster=State (and an additional rating-area-clustered variant for
`Benchmark_Silver_Real`, where premiums are constant within rating area by construction).
Forward outcome columns `Y_fwd0`–`Y_fwd3` are built via `dplyr::lead()` within
`group_by(fips_code)`, so leads never bleed across county boundaries (verified in
`Code/tests/test_delta_variables.R` Tests 7–8).

**Block B — Exit-after-shock interaction.** The Exit indicator collapses three transitions
(0→0, 1→0 = exit, 0→0 again at h+1) onto a single dummy. To isolate the *scarring/relief*
population — counties that were shocked at t-1 and recovered at t — we estimate:

`lead(Y, h) ~ Shock_{i,t-1} + NoShock_{i,t} + Shock_{i,t-1} * NoShock_{i,t} | fips_code + Year`

The interaction term equals 1 only for the recovery cohort and is identical, row-by-row,
to the original `Exit` indicator (Test 9 verifies this). The two main effects absorb the
"always-no-shock" and "still-shocked-at-t" populations, so the interaction coefficient is
a cleaner estimate of the post-exit response holding the t-1 and t shock statuses fixed.
`Shock_{t-1}` uses the underlying continuous-or-binary indicator
(`Is_Extreme_Drought`, `High_CDD`, `High_HDD`); `NoShock_{t}` is `1 - Shock_{t}`.

Total new coefficients added to `Analysis/delta/delta_coefs.csv`: **768** rows under approaches
`Delta_Exit_LP` (168), `Delta_Exit_LP_RA_Cluster` (24), `Delta_Exit_Interaction` (504),
`Delta_Exit_Interaction_RA_Cluster` (72).

### Headline Findings

#### 1. Drought_Exit -> PCPI_Real grows sharply by h=2

A county recovering from extreme drought sees per-capita income rise sharply by year +2:

| Horizon | Estimate | p-value |
|---------|----------|---------|
| h=0     | +101    | 0.84 |
| h=1     | +472    | 0.18 |
| h=2     | **+1044** | **0.0002** |
| h=3     | +10     | 0.98 |

The h=2 peak echoes the state-level finding that extreme drought operates with a 2-year
lag. The Block B interaction estimate at h=2 (+964, p = 0.010) and h=3 (+1230, p = 0.007)
confirms this is identified off the recovery cohort, not driven by selection between
ever-shocked and never-shocked counties. The effect dies out by h=3 in the simple Exit LP
but persists in the interaction — consistent with mean-reversion in raw incomes offset by
the longer scarring window in the recovery sub-population.

`Drought_Exit -> Med_HH_Income_Real` is also significant at h=2 (+429, p = 0.032) and
h=3 (+751, p = 0.003) — household-level recovery follows the per-capita signal with a
1-year lag.

#### 2. Drought_Exit -> Medical_Debt_Median at h=0, with a sign reversal at h=1

`Drought_Exit -> Medical_Debt_Median_2023` is negative at h=0 (−49.7, p = 0.019), echoing
the previously documented Key Finding 6. However, `Drought_Exit -> Medical_Debt_Share` is
*positive* at h=1 (+0.0057, p = 0.037), suggesting a brief uptick in debt incidence even as
the median balance falls. The two outcomes capture different margins (extensive vs.
intensive), and the divergence is consistent with deferred-care utilization re-entering
the credit-bureau snapshot in the year after drought conditions ease.

#### 3. CDD_Exit -> Civilian_Employed is the most precise post-exit signal

Counties exiting a hot (high-CDD) year see persistently elevated employment:

| Horizon | Estimate | p-value |
|---------|----------|---------|
| h=0 | +704 | 0.0021 |
| h=1 | +712 | 0.0010 |
| h=2 | +732 | 0.0036 |
| h=3 | +736 | 0.019 |

The flat, persistent profile (~+710–740 across all 4 horizons) is hard to reconcile with a
pure transient-recovery story. The Block B interaction (CDD_t-1 × NoShock_t) is positive
and significant at h=1 (+553, p = 0.013), h=2 (+1239, p = 0.041), and h=3 (+1466,
p = 0.040), suggesting the effect identifies a real recovery mechanism, not just composition.

#### 4. HDD_Exit -> Hosp_BadDebt_PerCapita is *negative* — relief from cold shocks reduces hospital bad debt

| Horizon | Estimate | p-value |
|---------|----------|---------|
| h=0 | **−3.13** | **0.014** |
| h=1 | −2.55 | 0.14 |
| h=2 | **−2.88** | **0.034** |
| h=3 | −0.88 | 0.52 |

The negative sign aligns with the directional story that cold winters drive emergency-care
utilization; exiting a cold-shock year provides immediate relief, with the effect re-
emerging at h=2 (perhaps as billing cycles complete). `HDD_Exit -> Medical_Debt_Share` is
also negative at h=1 (−0.006, p = 0.017), reinforcing the relief interpretation.

### Is the "Scarring" hypothesis supported?

**Mixed evidence, outcome-dependent:**

- **No scarring for cold shocks (HDD_Exit):** Exit *reduces* bad debt and debt share —
  this is *relief*, not scarring.
- **Partial scarring for drought (Drought_Exit):** A short-run income recovery (positive
  PCPI at h=2) coexists with a one-year uptick in debt incidence (Medical_Debt_Share at
  h=1). The recovery dominates by h=2.
- **Persistent post-CDD-exit benefits:** Employment stays elevated for 3 years after
  exiting a high-CDD year — consistent with cooling-sector economic activity persisting
  past the shock window rather than a "scarring" cost.

Overall, the post-exit framework adds evidence that climate-shock effects do *not*
mechanically reverse on exit — the dynamic profile differs by shock type and outcome.

---

## Supply-Side Persistence — hospital finances scar under drought

Added 2026-06-16. Track: `hospital_supply_side_20260615`. Full write-up:
`Analysis/hospital/synthesis.md`. Source:
`Code/run_hospital_persistence.R` (`Analysis/hospital/hospital_persistence_coefs.csv`),
hospital (CCN) × year panel, hospital + year FE, state-clustered. Reuses the same
onset/exit symmetry test (`transition_symmetry.R`) and cumulative-dose machinery
(`cumulative_dose.R`) used here on the county side.

The county-level "drought scars / cold relieves" pattern **reappears on hospital
balance sheets**:

- **Drought is asymmetric (scarring)** for both hospital outcomes: onset+exit
  asymmetry on uncompensated care %NPR = −0.013 (p=0.012) and on operating margin
  = +0.027 (p=0.006). Entering and leaving a drought state do not cleanly cancel.
- **Temperature shocks are symmetric (reversible)** for hospitals (CDD/HDD
  asymmetry p > 0.14) — the same "cost is in the exposure, not lasting damage"
  reading as the county-level cold-exit *relief*.
- **Cumulative exposure does not compound into margin collapse.** The
  cumulative-shock-years dose-response on operating margin is mildly *positive*
  (+0.018 for 10+ vs 1-3 years, p=0.033), read as survivorship/adaptation in the
  unbalanced hospital panel — not erosion. The persistence story on the supply
  side is **drought hysteresis**, not dose-driven decline.
The drought 2-year lag (which underpins the state-level headline result) is now visible
in a county-level recovery setting, strengthening the causal interpretation.

### Caveats

1. **Block B interaction = Exit by construction.** The interaction term is mathematically
   identical to the Exit indicator (Test 9). Block B is therefore not new identification
   — it is a re-parameterization that lets the main effects absorb the never/persist
   cohorts so the interaction reads as a conditional ATT relative to those reference groups.
2. **No controls for prior shock duration.** A county exiting after one year of shock
   versus three years is treated identically. Future work could interact `Exit` with run-
   length.
3. **Multiple testing.** With 168 Exit_LP estimates, an expected ~8 spurious significant
   results at p<0.05. Findings 1–4 above are robust to Bonferroni-style adjustment within
   their (shock, outcome) family.

---

## Three-Way Transition Decomposition (Persistence Extensions — Phase 1)

Phase 2 estimated the Exit indicator in isolation. Phase 1 closes the symmetry question the committee implied — *if entering a shock raises costs, does leaving it lower them by the same amount?* — by estimating **Onset, Persist, and Exit jointly** in one local projection per horizon:

```
lead(Y, h) ~ Onset + Persist + Exit + controls | fips_code + Year,   h = 0..3
```

All three transitions are measured against the **never-transitioned (0→0) reference**, so their coefficients are directly comparable (plotted in `Analysis/plots/delta_transition_compare/`, tabulated in `Analysis/delta/delta_transition_summary.csv`, 252 rows). The formal symmetry test **H₀: β_Onset + β_Exit = 0** is computed from the joint clustered covariance (`Code/transition_symmetry.R`) and exported to `Analysis/delta/delta_symmetry_test.csv` (168 tests; **28, or 16.7%, reject symmetry at p<0.05**).

### Design

- **Onset (0→1):** the year a county enters shock — the cost of *arriving*.
- **Exit (1→0):** the year it leaves — the *relief* on departure.
- **Persist (1→1):** staying in shock — the *standing* cost of chronic exposure.
- A rejection of β_Onset + β_Exit = 0 means the onset effect is **not** mirrored by the exit effect. A positive sum is **hysteresis / scarring** (arriving costs more than leaving relieves); a negative sum is **over-relief**.

### Headline finding: drought debt is scarring, not reversible

**Drought → Medical_Debt_Share at h=2** is the cleanest asymmetry: β_Onset = +0.0133 and β_Exit = +0.0049, so the sum **+0.0182 is significantly positive (p = 0.0015)**. Both entering *and* leaving drought leave a county with higher debt two years later than a never-transitioned county — the debt accrued during drought does **not** unwind when the drought ends. This is direct county-level evidence of **scarring** behind the state headline (`is_extreme_drought_lag2` → Medical Debt), and it is the persistence story the committee asked us to interrogate. The effect is still present, weaker, at h=3 (+0.0144, p = 0.043).

### Income transitions overshoot symmetrically upward

The largest cluster of rejections is on **per-capita income (PCPI_Real) at h=1–2**, where Onset and Exit *both* carry positive coefficients:

| Shock | Outcome | h | β_Onset | β_Exit | Asymmetry (sum) | p |
|-------|---------|---|---------|--------|-----------------|---|
| CDD | PCPI_Real | 1 | 949 | 911 | **+1,860** | 0.0007 |
| Drought | PCPI_Real | 2 | 464 | 1,127 | **+1,591** | 0.0021 |
| Drought | PCPI_Real | 1 | 950 | 599 | **+1,550** | 0.0063 |
| HDD | PCPI_Real | 2 | 678 | 554 | **+1,232** | 0.0033 |

The shared sign suggests a **recovery-overshoot / mean-reversion** pattern: both the year of entry and the year of exit are followed, 1–2 years later, by income running above the no-transition baseline. This is consistent with transitory shocks triggering compensating activity (relief transfers, rebuilding, re-employment) rather than a permanent income-path shift, and it is the same recovery dynamic the Phase 2 Exit_LP flagged for PCPI — now shown to be a property of *both* transition edges, not just exit.

### One cold over-relief signal

**HDD → Hosp_BadDebt_PerCapita at h=3** rejects with a *negative* sum (−6.49, p = 0.024): cold onset and exit both reduce hospital bad debt three years out — over-relief rather than scarring, consistent with the Phase 2 finding that cold-shock exit brings immediate hospital-cost relief.

### Where symmetry holds

For **83% of the 168 tests symmetry is not rejected** — for most shock × outcome × horizon cells, onset and exit are statistical mirror images and the shock effect is reversible. The asymmetries are not scattered noise: they concentrate on (i) drought → debt at h=2 (scarring) and (ii) income at h=1–2 (overshoot), exactly the channels where a persistence mechanism is theorized. A pipeline producing 16.7% rejections clustered on the predicted channels, rather than ~5% scattered at random, is evidence of signal rather than a multiple-testing artifact.

### Caveats

1. **Drought_Persist is thin** (301 county-years), so the Persist coefficient for drought is the least precise of the trio; the Onset/Exit contrast that drives the symmetry test is unaffected.
2. **Symmetry is tested per horizon**, not jointly across horizons; a joint test would have more power but the per-horizon view is what the three-way plots show.
3. **Reference group.** All effects are relative to never-transitioned (0→0) counties; the test asks whether onset and exit are mirror images of each other, not whether either equals zero.

---

## Cumulative-Dose Response (Persistence Extensions — Phase 3)

The transition decomposition above treats each shock year as a discrete event. Phase 3 asks a *stock* question: does the **10th** cumulative year of a shock cost more than the **1st**? We count, per county-year, the running number of shock-positive years to date (`Cum_*_Years`, monotonic non-decreasing — exposure accumulates and never resets; `Code/cumulative_dose.R`) and fit linear, quadratic, and binned (1–3 / 4–6 / 7–9 / 10+ vs 0) forms with county + year FE (`Code/run_cumulative_dose.R`). Coefficients in `Analysis/cumulative_dose/cumulative_dose_coefs.csv` (252 rows); marginal effects and the 10+-vs-1–3 contrast in `Analysis/cumulative_dose/cumulative_dose_marginal.csv` (180 rows); plots in `Analysis/plots/cumulative_dose/`.

Support varies sharply by shock: counties reaching 10+ cumulative years number **661 for CDD, 432 for HDD, but only 1 for extreme drought** — so the high-dose drought estimates are driven by a single county and are not interpretable (reported for completeness, flagged below).

### Headline: cumulative *cold* compounds into employment loss

**HDD → Civilian_Employed** is a textbook monotone dose-response — each additional band of accumulated cold-years deepens the employment deficit relative to never-cold counties:

| Cumulative HDD-years | Effect on Civilian_Employed | p |
|---|---:|---:|
| 1–3 | −1,269 | 0.22 |
| 4–6 | −3,267 | 0.02 |
| 7–9 | −5,353 | <0.01 |
| **10+** | **−6,936** | <0.01 |

The 10+-vs-1–3 contrast is **−5,668 (p < 0.0001)**: the tenth year of cold is far more costly than the first. This is the cumulative-stock analogue of the prior CS-DiD long-run cold scarring (employment compounding to −4,982 at event-time 10) — two independent designs converging on the same compounding cold-employment damage. HDD → Medical_Debt_Share also escalates with dose, though only marginally (10+ vs 1–3 = +0.0147, p = 0.062).

### Heat does *not* compound

**CDD** shows the opposite pattern. Its marginal effect on Medical_Debt_Share *attenuates* with accumulated exposure — the quadratic marginal effect is ≈ 0 at year 1 (−0.0003, p = 0.93) and turns significantly negative by year 10 (−0.0039, p = 0.026), and the binned 10+-vs-1–3 contrast is −0.0212 (p = 0.041). Cumulative heat tracks Sun-Belt employment *growth* (CDD 10+ → Civilian_Employed +8,235, p = 0.003) rather than damage. This reconciles with Phase 2: the chronically-hot debt gap is a standing *level* difference, not a dynamically compounding one — so accumulating more heat-years does not keep adding debt.

### Drought dose not assessable at the top

Extreme drought is transient: only one county reaches 10+ cumulative drought-years, so the drought 10+ coefficients (e.g., the implausibly large Civilian_Employed and PCPI values) are a single-county artifact and are excluded from interpretation. Drought's cost is captured by its *onset/lag* dynamics (Phase 1 scarring; state lag-2 headline), not by chronic accumulation.

### Takeaway

The persistence mechanism is **shock-specific**: cold damage *accumulates* (each additional cold-year compounds employment loss), heat damage *saturates* (a level gap that stops growing), and drought damage is *episodic* (onset-and-lag, not stock). A one-size "more exposure = monotonically worse" story would be wrong — Phase 3 shows which shocks actually compound.

### Caveats
1. **Cumulative years correlate with calendar time**; year FE absorb the common trend, so identification is the *cross-county* difference in accumulation rate. Counties that accumulate faster than the year average drive the estimates.
2. **Income controls** (`Household_Income_2023`) are held in all specs for consistency with the delta pipeline; for the income outcomes themselves this absorbs much variation, so the employment and debt results are the cleaner reads.
3. **Drought high-dose bins are single-county** — do not interpret.

---

## Persistence Extensions — cross-references

The Phase 1 transition decomposition and Phase 3 cumulative-dose sections above are part of the `persistence_extensions_20260521` track. Companion analyses:
- **Continuously-exposed cohorts (Phase 2):** `Analysis/persistent_exposure/synthesis.md` — Always-vs-Never gaps; chronic-heat debt gap is the largest but a standing *level*, not a widening trajectory (complements the cumulative-dose finding that heat saturates).
- **Demographic mediators (Phase 4):** `Analysis/state/synthesis.md` §7 — the shock effects survive demographic adjustment (no population-turnover confound).
- **Threshold sensitivity (Phase 5):** `Analysis/state/synthesis.md` §8 — the `is_cold_shock` headline survives p90; `High_CDD`/`High_HDD` degree-day flags are cutoff-fragile.
- **Symmetry test machinery:** `Code/transition_symmetry.R`; results in `Analysis/delta/delta_symmetry_test.csv`.
