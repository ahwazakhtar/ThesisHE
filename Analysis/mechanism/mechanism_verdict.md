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
several cases, **concentrate on non-farm labor exposure** (heat×labor and heat×energy-burden
gradients, §2; the earlier "cold-employment strengthens in the least-agricultural counties"
claim is **superseded** — see the §2 note). The single strongest
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
| Heat (`High_CDD`) | Std spending / benef. | **+$112** (Lag1 **+$176**, Lag2 +$75) | 0.013 / 0.002 / 0.003 |
| Heat (`High_CDD`) | ED visits / 1,000 | **+7.8** (Lag1 **+9.4**) | 0.006 / 0.0002 |
| Cold (`High_HDD`) Lag2 | Std spending; ED visits | **+$87**; **+9.0** | 0.008 / 0.002 |
| **Air quality** (`High_AQI_Max`) | ED visits / 1,000 | **+5.0** (Lag1 +3.6, Lag2 +2.8) | 0.0002 / 0.001 / 0.023 |

This is the in-panel reproduction of the Deryugina-et-al. pollution-morbidity result and the
temperature-utilization result — a health-cost channel that **cannot be agricultural** and that
would survive in any county with a hospital.

## 2. Labor exposure, not cropland
*(Tasks 2a/2b; `ag_channel_coefs.csv`; Figs `fig_labor_vs_ag.png`, `fig_moderator_interactions.png`)*

- ~~**Cold → employment survives in low-ag counties.** `High_HDD` Lag2 → **−721 jobs** overall
  (p=0.029) and **−2,011** in the *bottom* ag-dependence tercile (p=0.048). A cold-employment
  effect that is *stronger* where there is least farming is not the agricultural channel.~~
  **[SUPERSEDED 2026-07-13 (coding audit B1; `Plans/master_evidence_table.md` Row 11a).** The
  struck-through cold→employment low-ag figures (−721 overall / −2,011 bottom-ag tercile) are a
  levels/county-size artifact that **dies in logs** (overall and bottom-ag both ns, |est|<0.5
  log-pts; commits `5c615dd`/`ddfc448`) — **do not cite**, and do not claim cold→employment
  survives in low-ag counties. The non-agricultural labor claim now rests on the heat×labor and
  heat×energy-burden interaction gradients (bullets 2–3 below), which are unaffected.]
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

## 5. The provider / hospital-finance channel — a genuine gap, and our null is the expected result
*(`hospital_supply_side_20260615` track; supply-side literature reviewed 2026-07-02)*

The demand-side reviewer question has a supply-side twin: do climate shocks strain *hospitals*? The
`hospital_supply_side` incidence models find **drought → lower uncompensated care** (−$6.2M cumulative,
p<1e-11) and **null operating margins** — counterintuitive at first glance. The literature review
resolves this: it is the **expected** result, not an anomaly.

- **The one comparable study finds the same paradox.** Audi, Hamadi et al. (2024–25) regress FEMA
  hurricane-risk on a hospital financial ratio for ~1,030 hospitals and find higher risk → *better*
  cost-to-charge ratio ("requires further investigation"). Same sign as ours.
- **A null/negative is theoretically sound.** Federal buffers (Section 1135 Medicaid waivers, crop
  insurance / USDA disaster payments, DSH) sever the farm-income→uninsurance→uncompensated-care chain;
  climate demand surges are *revenue-positive* (billable ED visits); deferred care + out-migration
  lower *measured* uncompensated care mechanically; and hospital distress is driven by capital
  structure/occupancy/ownership, not local income (a national Altman-Z study found income/uninsured
  insignificant). Uncompensated care is also a discretionary accounting category — as
  measurement-fragile as credit-bureau medical debt.
- **The gap is confirmed.** The rural-hospital-closure prediction literature omits climate/agricultural
  variables entirely; the "climate strains hospitals" evidence base is all *acute* destructive events
  (hurricanes/wildfires) with no drought analog. So the thesis's supply-side work **fills a real gap**
  rather than contradicting an established finding.
- **Reverse-causality caveat:** the closure→local-economy DiD literature (Vogler; Alexander & Richards)
  runs the opposite direction — guard any drought→closure claim accordingly.
- **Separability/heterogeneity test — now run** (`Code/run_mechanism_provider.R` →
  `provider_channel_coefs.csv`, hospital-year panel, CCN+Year FE, state-clustered):
  - **The drought → uncompensated-care effect is NOT agricultural.** `Drought × Ag_z` is null
    (p=0.24–0.41) and the effect *survives essentially unchanged in the bottom ag-dependence tercile*
    (−0.0043, p=0.01, vs −0.0051 overall) — a general accounting/utilization response, not a farm channel.
  - **Where provider strain appears, it concentrates in safety-net hospitals, as theory predicts.**
    `Heat(CDD) × SafetyNet` on uncompensated-care %NPR is strongly positive: **+0.023 at Lag1 (p<0.001),
    +0.020 at Lag2 (p<0.0001)** — safety-net providers (margins >6× lower) absorb the demand-side
    morbidity surge (Channel 1). This is the supply-side face of the morbidity channel, landing on the
    providers least able to buffer it. (Drought × SafetyNet is positive but insignificant.)

---

## Answering the reviewer's ratio question directly

*"How much cannot be explained by agriculture?"* — Three concrete, defensible statements:

1. **The health-cost/utilization channel is entirely non-agricultural** and is the most cleanly
   identified result here (heat/cold/AQI → Medicare spending & ED visits, all measured in health
   data). Agriculture explains **none** of it.
2. **The non-agricultural labor channel is carried by heat, not by low-ag cold employment.**
   Heat-employment damage loads on climate-exposed **non-farm** labor (heat×labor interaction
   −689, p=0.009) and on energy burden. *(The earlier "cold-employment survives/strengthens in
   the bottom ag tercile (−2,011/−721)" statement is **superseded** — a levels/county-size
   artifact that dies in logs; see the §2 superseded note and `master_evidence_table.md` Row 11a.)*
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

> **Post-dedup refresh, 2026-08-20.** The Medicare table above previously carried the
> 2026-07-01 pre-dedup run. The 2026-07-13 county dedup (568 double-counted county-years,
> all inside the 2014-2023 Medicare window) regenerated
> `Analysis/mechanism/medicare_channel_coefs.csv`, but this hand-authored file was not
> updated with it, and the stale figures propagated through the evidence table into the
> essay drafts. Values above are now read from that CSV (spec `overall`). No sign or
> verdict changed. See `Plans/draft_review_20260819.md` section 3.0.
