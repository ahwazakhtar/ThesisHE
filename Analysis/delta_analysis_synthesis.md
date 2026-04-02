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
| `Analysis/delta_coefs.csv` | 896-row tidy coefficient table |
| `Analysis/delta_results.txt` | Full model summaries |
| `Analysis/delta_vif_diagnostics.txt` | VIF for delta + lagged-level blocks |
| `Analysis/plots/delta/` | LP dynamic profile plots, contemporaneous FE plots |
| `Analysis/plots/delta_robustness/` | Asymmetry plots, onset/exit plots |
