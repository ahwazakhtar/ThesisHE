# Mechanism Verdict: How Much of the Climate → Health-Cost Result Is *Not* Agriculture

**Track:** `mechanism_channels_20260625`, Phase 2 (Task 2f).
**Inputs:** the four Phase-2 coefficient tables in `Analysis/mechanism/` — `ag_channel_coefs.csv`
(2a/2b), `medicare_channel_coefs.csv` (2c), `energy_channel_coefs.csv` (2d),
`migration_selection_coefs.csv` (2e). Figures in `Analysis/mechanism/plots/`.
All estimates: `fixest::feols`, County + Year FE, state-clustered, county panel 2011–2023
(Medicare 2014–2023). This document is the reviewer-facing answer to *"how much of what you're
finding cannot be explained by the agricultural income channel, and what else is in play?"*

---

## Headline verdict

**Agriculture is one channel, not the channel.** The reduced-form climate → health-cost
relationships are reproduced by mechanisms that operate *independent of farm income* and, in
several cases, **strengthen in the counties with the least agriculture**. The single strongest
piece of evidence is a **morbidity/health-cost channel measured directly in Medicare
administrative data**: heat, cold, and air pollution each raise per-beneficiary spending and ED
visits, with no farm-income intermediary. Two further non-agricultural channels are visible in
the panel — **broad labor exposure** (effects load on climate-exposed *non-farm* employment
share) and **energy burden** (heat damage concentrates in high-energy-burden counties). A genuine
**agricultural** signature survives mainly as event-specific drought dynamics, and part of the
drought "scar" is **population selection** (out-migration), not pure same-population loss.

---

## 1. The morbidity / healthcare-utilization channel — the cleanest non-agricultural result
*(Task 2c; `medicare_channel_coefs.csv`; Fig. `fig_medicare_morbidity.png`)*

Climate and pollution shocks raise **directly-measured** Medicare cost and utilization among the
65+/disabled population — the temperature/pollution-sensitive group the canonical literature
studies (Deryugina et al. 2019; Barreca et al. 2016). None of this passes through farm income.

| Shock | Outcome | Estimate | p |
|---|---|---|---|
| Heat (`High_CDD`) | Std spending / benef. | **+$112** (Lag1 **+$177**, Lag2 +$75) | 0.013 / 0.001 / 0.003 |
| Heat (`High_CDD`) | ED visits / 1,000 | **+7.8** (Lag1 **+9.5**) | 0.006 / 0.0002 |
| Cold (`High_HDD`) Lag2 | Std spending; ED visits | **+$85**; **+9.0** | 0.009 / 0.002 |
| **Air quality** (`High_AQI_Max`) | ED visits / 1,000 | **+4.8** (Lag1 +3.3, Lag2 +2.8) | 0.0003 / 0.002 / 0.019 |

This is the in-panel reproduction of the Deryugina-et-al. pollution-morbidity result and the
temperature-utilization result — a health-cost channel that **cannot be agricultural** and that
would survive in any county with a hospital.

## 2. Labor exposure, not cropland
*(Tasks 2a/2b; `ag_channel_coefs.csv`; Figs `fig_labor_vs_ag.png`, `fig_moderator_interactions.png`)*

- **Cold → employment survives in low-ag counties.** `High_HDD` Lag2 → **−721 jobs** overall
  (p=0.029) and **−2,011** in the *bottom* ag-dependence tercile (p=0.048). A cold-employment
  effect that is *stronger* where there is least farming is not the agricultural channel.
- **Heat → employment loads on the labor moderator.** The `High_CDD × ClimateExposed_NonFarm_Share`
  interaction is **−689** (p=0.009; Lag1 −705, Lag2 −511): heat employment damage concentrates
  where the climate-exposed *non-farm* employment share is high (construction, manufacturing,
  transport, utilities) — the Graff Zivin–Neidell / Somanathan labor-productivity signature.
- **Cold → medical debt loads on labor exposure too** (`High_HDD × Labor_z` +0.0021, p=0.033;
  Lag1 +0.0024, p=0.015) — again a non-agricultural gradient.

## 3. Energy burden — a distinct distributional channel
*(Task 2d; `energy_channel_coefs.csv`)*

- **Heat damage concentrates in high-energy-burden counties.** `High_CDD × EnergyBurden_z` =
  **−1,380 jobs** (p<0.001; Lag1 −1,430; Lag2 −956) and **−$370 median income** (p<0.001). This is
  the Doremus-et-al. affordability mechanism: where energy is a big share of income, a hot year
  bites harder.
- **Honest caveat — energy burden ≠ SVI.** `corr(Energy_Burden_Pct, SVI_static) = 0.11` at the
  county level. Energy burden is a **partly distinct** vulnerability axis, not a restatement of the
  social-vulnerability result — so it adds an independent distributional dimension rather than
  merely echoing the existing high-SVI finding. (Low-income households nonetheless bear ~2.6× the
  burden: 8.9% of income vs 3.4% overall.)

## 4. The agricultural channel itself — real but event-specific and selection-tinged
*(Tasks 2a, 2e)*

- The clean farm-income interactions are **noisy** in the recurring-treatment panel: e.g.
  `Is_Extreme_Drought` → income is ~null overall and, if anything, *positive* inside the bottom ag
  tercile — consistent with the DiD-robustness track's finding that the drought-income effect is
  **event-specific (2012 cohort)** and does not generalize to the average drought cohort under an
  ITT/recurring-treatment design.
- **Selection is part of the drought scar.** `Is_Extreme_Drought` Lag1 → **net migration −0.0021**
  (p=0.047): drought-hit counties lose population the following year. So some of the persistent
  drought income/employment effect reflects *who leaves*, not only same-population loss — a caveat
  the reviewer's "other channels" question specifically anticipated. (Heat shows *in*-migration,
  but that is confounded by Sun Belt growth and is not interpreted as a shock response.)

---

## Answering the reviewer's ratio question directly

*"How much cannot be explained by agriculture?"* — Three concrete, defensible statements:

1. **The health-cost/utilization channel is entirely non-agricultural** and is the most cleanly
   identified result here (heat/cold/AQI → Medicare spending & ED visits, all measured in health
   data). Agriculture explains **none** of it.
2. **The cold-employment effect is non-agricultural**: it *survives and strengthens* in the bottom
   ag-dependence tercile, and heat-employment damage loads on climate-exposed **non-farm** labor.
3. **Where an agricultural signature is real (drought), it is event-specific and partly a
   population-selection artifact**, not a general "droughted-county" income law.

**Bottom line for the write-up:** lead the mechanism story with the **morbidity/utilization** and
**labor-exposure** channels (both robust, both non-agricultural, both in your own panel), present
**energy burden** as an independent distributional channel, and concede the **agricultural**
channel as a real but narrower, event-specific, partly-selection contributor. That is exactly the
"bound the agricultural channel and gesture at the others" the reviewer asked for.

### Caveats carried forward
- **Medical debt** remains the measurement-fragile, aggregation-sensitive outcome (near-null
  throughout) — do not lead with it.
- The **`effect_bottom/effect_overall` ratio** in `ag_channel_coefs.csv` is unstable when the
  overall effect ≈ 0 (division by ~0); read the significance/sign patterns, not the raw ratio.
- Medicare covers **65+/disabled** and **2014–2023** only.
- Migration selection is **bounded, not point-identified**; treat as a caveat on the scar, not a
  decomposition.
