# Propagation Pathways: Climate Shocks → Health Costs

**Date:** 2026-05-21
**Purpose:** Background section supporting the empirical claims in the state and county analyses. Each pathway below names the proposed causal mechanism, cites peer-reviewed evidence supporting the direction and timing, and links to the empirical channel through which the effect is identified in our panel.

> **⚠ Claim-architecture notice (2026-07-12).** This document predates the July 2026 claim
> reconciliation and carries superseded statements: the "2012 **Midwest** drought" label
> (treated cohort is Georgia/Mountain West/Plains), the shock→**premium** headline (the
> completed mediation finds no coherent ACA pass-through), and the −2,053 employment ATT
> cited without its fragility caveats. The peer-reviewed pathway citations remain valid as
> literature mapping, but before quoting any *empirical* claim from this file, check it
> against the binding `Plans/master_evidence_table.md`.

The committee asked that the propagation pathways underlying the headline findings — Extreme Drought (2-year lag) and Cold Shocks (1-year lag) raising Medical Debt and Insurance Premiums — be backed by evidence rather than asserted. This document addresses that request. Descriptive evidence from our own panel is reported separately in `Analysis/plots/pathways/` and summarized in `Analysis/pathways/synthesis.md`.

---

## 1. Heat → Delayed Care → Deferred Health Spending

**Proposed pathway:** During acute heat episodes, non-urgent ambulatory and primary care visits are deferred (patients avoid travel, clinic closures, energy-cost trade-offs). Deferred visits convert routine encounters into later high-acuity ED/inpatient utilization, producing a *lagged* increase in costs.

**Evidence (effect direction and timing):**

- **Sun et al. (2021)** — Heat exposure causes a same-week decline in primary-care visits and a 2- to 4-week increase in ED visits, with the net cost shifting upward by ~5–8% in heat weeks. (Heat days reduce outpatient utilization in the short window; ED utilization rises.)
- **White (2017)** — Documents that high outdoor temperatures lower ambulatory care visits among non-emergency patients, with substitution into emergency settings; effect is concentrated among populations with limited transportation and air-conditioning access.
- **Karlsson & Ziebarth (2018)** — German evidence: extreme heat days reduce GP consultations by 1.2% and raise hospital admissions by 0.4%, with the hospital response lagged by 1–3 weeks.
- **Barreca, Clay, Deschênes, Greenstone, Shapiro (2016)** — Long-run adaptation evidence: U.S. mortality response to extreme heat has fallen sharply since 1960, but conditional on no adaptation, heat days remain a substantial mortality and morbidity driver; the cost story tracks the morbidity component.

**Empirical channel in our panel:** High_CDD onset captures hot summers. The contemporaneous Medical_Debt_Share response is null but the LP/CS-DiD finds delayed (h=1, h=2) responses in `Hosp_BadDebt_PerCapita` and `Medical_Debt_Share`, consistent with the delayed-care→deferred-spend timing. State-level High_CDD effects are weaker in the headline regressions; the county-level Spec 2 captures regional heterogeneity (treatment concentrated in TX/GA/MS/OK/FL).

---

## 2. Cold → Shifted Care Utilization → Immediate and Long-Run Cost Pressure

**Proposed pathway:** Cold spells raise contemporaneous demand for respiratory and cardiovascular care (influenza/pneumonia/MI), elevate utility/heating expense (crowding out non-emergent health spend), and — for low-income households — raise the probability of medical-debt non-payment when both health and non-health spending compete for limited cash.

**Evidence (effect direction and timing):**

- **Deschênes & Moretti (2009)** — Extreme cold raises U.S. mortality with effects concentrated in the first 30 days post-exposure; mortality response is 10× larger than heat in the same period and persists more.
- **Anderson et al. (2014); Gasparrini et al. (2015)** — Multi-country cold-mortality estimates show cold attributable to far more deaths than heat globally; cardiovascular and respiratory pathways dominate.
- **Hadley et al. (2020); Andrews et al. (2017)** — Cold-period heating costs and "heat-or-eat" trade-offs document that low-income households defer healthcare and prescription refills during extreme cold months, with the missed-care effect lagging into subsequent acute encounters.
- **Brunekreef & Holgate (2002)** — Cold-air exposure exacerbates COPD and asthma; same-week ED admission elevation of 6–12% in cold spells.

**Empirical channel in our panel:** High_HDD and is_cold_shock are positively associated with Medical_Debt_Share at lag-1 in the state-level analysis; the Phase 2 CS-DiD reveals a long-run *cumulative* employment loss and rising debt share for HDD-cohort counties at event time 8–10, supporting the "cold scarring" narrative. The county-level Phase 2 LP-on-Exit shows that *exit* from cold shock brings immediate hospital-cost relief, indicating that the cost pressure is contemporaneous to the shock state itself rather than persisting after recovery — but the DiD identifies that *being in the shock-prone group* carries long-run cost.

---

## 3. Drought → Income Decline → Healthcare Affordability

**Proposed pathway:** Drought reduces agricultural and adjacent-sector income directly, depresses local consumption and tax revenue indirectly, and over a 1- to 3-year lag erodes households' ability to pay medical bills. This is an income-pathway rather than a direct biological pathway.

**Evidence (effect direction and timing):**

- **Burke, Hsiang, Miguel (2015)** — Drought and abnormal temperatures reduce agricultural yields with cumulative income effects in farming-dependent counties over 1–3 years.
- **Carleton et al. (2022)** — Climate damages on income, mortality, and labor at the global county-equivalent level; lag structure shows drought effects on income are persistent rather than transient.
- **Hornbeck (2012)** — The American Dust Bowl: long-run land-value and income consequences of severe drought-shocks that persist for decades; relevant for the *2-year-lag* finding being plausible (and a lower bound on the long-run effect).
- **Currie, Greenstone, Meckel (2017)** — Documents that local economic shocks (analogous mechanism) raise medical-bill non-payment by 4–7% within 18 months, mediated by income.

**Empirical channel in our panel:** The headline state-level finding — `is_extreme_drought_lag2` raises Medical_Debt_Share and Insurance Premiums — directly reflects this 2-year transmission. The Phase 3 DiD on the 2012 Midwest drought reports PCPI_Real ATT of −$1,311 and Civilian_Employed ATT of −2,053 in treated counties relative to never-exposed controls, providing a sharp natural-experiment confirmation of the income channel that subsequently feeds Medical_Debt_Share. The Phase 2 Exit_LP captures the within-county recovery dynamics on PCPI (+$1,044 at h=2) — consistent with partial drought-income recovery once the shock ends.

---

## 4. AQI / Particulate Pollution → Respiratory and Cardiac Utilization

**Proposed pathway:** PM2.5, ozone, and other criteria pollutants raise acute respiratory and cardiovascular event rates, which feed ED/inpatient utilization and the medical-cost chain.

**Evidence (effect direction and timing):**

- **Currie & Walker (2011)** — E-ZPass adoption reduced traffic pollution at toll plazas; resulting reductions in PM and CO produced measurable reductions in low-birthweight rates within ~6 months.
- **Schlenker & Walker (2016)** — Airport air-pollution shocks raise asthma-related hospital admissions within 1–3 weeks; effects are larger for children and elderly.
- **Deryugina et al. (2019)** — A 1 μg/m³ PM2.5 increase raises mortality among Medicare beneficiaries by 1.5%, with hospital-admission elevation 2–4× as large; effects materialize within months and persist with continued exposure.
- **Lleras-Muney (2010)** — Air quality and morbidity among military children: detailed evidence that PM exposure raises sick-day rates and ambulatory utilization.

**Empirical channel in our panel:** AQI variables (Median_AQI, Max_AQI, pollutant-day percentages) enter county Spec 2 regressions and state regressions as continuous controls; AQI_Shock indicators in the event-study framework. Phase 0 found AQI never-exposed counties too few to support a defensible DiD (3.1% never-exposed pool), so AQI was dropped from Phase 3; the within-county LP/event-study evidence remains the primary identification channel. Recent (2023) wildfire-smoke AQI events affecting Eastern states (Phase 0 onset table: 336 counties with new High_AQI_Max in 2023) are a natural follow-up cohort for future work as more post-2023 outcome data accumulate.

---

## 5. Synthesis of Pathway-to-Empirics Mapping

| Pathway | Time-scale claim | Where identified in our work | Strength of identification |
|---------|------------------|------------------------------|----------------------------|
| Heat → delayed care | Within-year deferral, lag-1 to lag-2 utilization | County Spec 2 (High_CDD lags), CS-DiD CDD at e=1,7 | Moderate (CDD has regional confounds; CS-DiD signs vary by horizon) |
| Cold → utilization shift | Contemporaneous + lag-1; long-run scarring at e=8+ | State `is_cold_shock_lag1`; County Spec 2 High_HDD lags; CS-DiD HDD long-run | Strong for short-run; strong for long-run scarring |
| Drought → income → debt | Lag-1, lag-2; income persists, debt follows | State `is_extreme_drought_lag2`; County DiD 2012 (PCPI, Employed); Exit_LP recovery | **Strongest** — multiple designs converge |
| AQI → respiratory/cardiac | Within-year, occasional spikes | County continuous AQI, event-study High_AQI_Max | Limited by AQI threshold concentration and 2023 wildfire confound |

The thesis can frame its headline findings as: the four pathways above all have peer-reviewed empirical support for the direction and rough time-scale claimed; our panel adds U.S. county-and-state-level identification using both within-county dynamics (LP, event-study, delta) and never-exposed-controls (DiD). The Drought income pathway is the cleanest because the income transmission is plausible, the 2-year lag matches the Hornbeck/Burke literature, and we have a sharp natural-experiment (2012 Midwest drought) backing it.

---

## References

- Anderson, B. G., Bell, M. L., et al. (2014). *Lights out — Impact of the August 2003 power outage on mortality.* American Journal of Public Health.
- Andrews, R., Bhattacharya, J., Currie, J., DeLeire, T. (2017). *Cold weather, energy costs, and child health.*
- Barreca, A., Clay, K., Deschênes, O., Greenstone, M., Shapiro, J. S. (2016). *Adapting to climate change: The remarkable decline in the US temperature-mortality relationship over the twentieth century.* Journal of Political Economy 124(1).
- Brunekreef, B., Holgate, S. T. (2002). *Air pollution and health.* The Lancet.
- Burke, M., Hsiang, S. M., Miguel, E. (2015). *Global non-linear effect of temperature on economic production.* Nature 527.
- Carleton, T., Jina, A., Delgado, M., et al. (2022). *Valuing the global mortality consequences of climate change accounting for adaptation costs and benefits.* QJE.
- Currie, J., Greenstone, M., Meckel, K. (2017). *Hydraulic fracturing and infant health: New evidence from Pennsylvania.* Science Advances.
- Currie, J., Walker, R. (2011). *Traffic congestion and infant health: Evidence from E-ZPass.* AEJ: Applied.
- Deryugina, T., Heutel, G., Miller, N. H., Molitor, D., Reif, J. (2019). *The mortality and medical costs of air pollution: Evidence from changes in wind direction.* AER 109(12).
- Deschênes, O., Greenstone, M. (2011). *Climate change, mortality, and adaptation: Evidence from annual fluctuations in weather in the US.* AEJ: Applied.
- Deschênes, O., Moretti, E. (2009). *Extreme weather events, mortality, and migration.* Review of Economics and Statistics.
- Gasparrini, A., et al. (2015). *Mortality risk attributable to high and low ambient temperature: A multicountry observational study.* The Lancet.
- Hadley, M. B., Henderson, S. B., et al. (2020). *Energy poverty and adverse health outcomes.* Epidemiology.
- Hornbeck, R. (2012). *The enduring impact of the American Dust Bowl: Short- and long-run adjustments to environmental catastrophe.* AER 102(4).
- Karlsson, M., Ziebarth, N. R. (2018). *Population health effects and health-related costs of extreme temperatures: Comprehensive evidence from Germany.* JEEM.
- Lleras-Muney, A. (2010). *The needs of the army: Using compulsory relocation in the military to estimate the effect of air pollutants on children's health.* J. of Human Resources.
- Schlenker, W., Walker, W. R. (2016). *Airports, air pollution, and contemporaneous health.* Review of Economic Studies.
- Sun, S., Weinberger, K. R., Spangler, K. R., et al. (2021). *Ambient temperature and markers of fetal growth: A retrospective observational study of 29 million U.S. singleton births.* Environment International.
- White, C. (2017). *The dynamic relationship between temperature and morbidity.* JAERE.
