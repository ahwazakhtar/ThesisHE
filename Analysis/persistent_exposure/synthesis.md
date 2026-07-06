# Continuously-Exposed Sub-Population Analysis (Persistence Extensions — Phase 2)

**Script:** `Code/run_persistent_exposure.R` · **Cohort helper:** `Code/exposure_cohorts.R`
**Outputs:** `Analysis/persistent_exposure/persistent_exposure_inventory.csv`, `…_cohort_summary.csv`, `…_contrast.csv`, `…_dynamic.csv`, `Analysis/plots/persistent_exposure/`

## Question

The prior track's DiD used the *onset* cohort — the year a county first enters shock. This phase asks a different question: what about counties that are **chronically** exposed? We bin each county by how many of the 13 panel years (2011–2023) it was shock-positive:

| Cohort | Definition |
|--------|-----------|
| **Always** | ≥ 10 / 13 shock-years |
| **Frequently** | 5 – 9 / 13 |
| **Rarely** | 1 – 4 / 13 |
| **Never** | 0 / 13 |

Hypothesis (committee): continuously-exposed counties should show the **largest persistent gap** vs never-exposed counties.

## Cohort inventory

| Shock | Never | Rarely | Frequently | Always | Always geography |
|-------|------:|-------:|-----------:|-------:|------------------|
| **High_CDD** (heat) | 2,209 | 203 | 152 | **661** | TX, GA, MS (hot South) |
| **High_HDD** (cold) | 2,391 | 207 | 195 | **432** | MN, MT, ND (cold North) |
| **High_AQI_Max** | 2,177 | 299 | 396 | **353** | CA, OH, PA (urban/industrial) |
| **Is_Extreme_Drought** | 2,622 | 593 | 9 | **1** | CA only |

**First result — extreme drought is transient, not chronic.** Only **one county** is "Always" in extreme drought (PDSI ≤ −4 in ≥10/13 years). Chronic extreme drought essentially does not exist in the panel, so the continuously-exposed design is **not applicable to drought** — the onset-cohort CS-DiD from the prior track remains the correct design there. The chronic-exposure lens is informative for **heat, cold, and AQI**, where the Always cohorts are 350–660 counties.

## Headline — heat shows a clean monotone dose-response on medical debt

For **High_CDD → Medical_Debt_Share**, the cross-sectional cohort means rise monotonically with exposure intensity:

| Cohort | n | Mean Medical_Debt_Share | Mean Hosp_BadDebt p.c. |
|--------|---:|:---:|:---:|
| Never | 2,209 | 0.156 | 61.6 |
| Rarely | 203 | 0.230 | 71.8 |
| Frequently | 152 | 0.248 | 86.6 |
| **Always** | **661** | **0.255** | 86.6 |

The Always-vs-Never gap is **+0.099 (≈ 10 pp), p < 0.0001** (`Outcome ~ cohort | Year`, state-clustered) — the **largest and most ordered persistent gap** of any shock, confirming the hypothesis for heat. This is the chronic-exposure analogue of the prior track's CS-DiD finding that HDD cold-cohorts accumulate a +4.9 pp debt-share gap by event-time 10: both designs locate the largest persistent debt gaps in chronically temperature-stressed counties.

## Caveat — the static gap is geographically confounded; the within-design gap is a stable level, not a widening one

Chronic-exposure cohorts are strongly selected on geography and income:
- **Heat (CDD) Always** = poorer South: PCPI −$6,438 and Med_HH_Income −$10,092 vs never (both p < 0.05).
- **Cold (HDD) Always** = richer North: Medical_Debt_Share −0.106, PCPI +$6,845, but far smaller counties (Civilian_Employed −43,683).
- **AQI Always** = richer urban/industrial: higher income, *lower* debt and hospital bad debt.

So the static cohort gap mixes the exposure effect with the fact that hot counties are poorer and cold/urban counties richer. The **dynamic two-way FE contrast** (`Outcome ~ i(Year, Always_Exposed, ref) | fips_code + Year`, Always ∪ Never) nets out fixed county differences and traces how the gap *moves*:

For **CDD → Medical_Debt_Share** the Always-vs-Never differential relative to 2012 does **not widen** — it drifts negative and is significant by 2022 (−0.039, p = 0.001) and 2023 (−0.066, p < 0.0001). The chronically-hot counties' relative debt position *improved* over 2012–2023 (plausibly Medicaid-expansion and CRA debt-reporting changes reaching the never-exposed comparison group). 

**Reconciliation:** the persistent heat-debt gap is a large **standing level difference** (cross-sectional, partly a hot-South income confound), **not a dynamically worsening trajectory**. This contrasts with the prior onset CS-DiD for cold, where the gap *compounds* over event time — the difference is exactly what the two designs are built to separate: onset DiD identifies a treatment that switches on, while chronic-exposure identifies a standing population difference.

## Comparison with the onset-cohort CS-DiD (prior track)

| Design | Treatment | What it identifies | Headline |
|--------|-----------|--------------------|----------|
| Onset CS-DiD (`Analysis/did/`) | first year entering shock | dynamic ATT after onset, vs never-exposed | Cold (HDD) debt +4.9 pp and employment −4,982 compounding to e=10; Drought 2012 PCPI −$1,050 |
| **Chronic exposure (this phase)** | ≥10/13 shock-years | standing gap of always- vs never-exposed | Heat (CDD) debt +9.9 pp level gap (largest), but not widening within-design; drought not assessable (1 county) |

The two are complementary. Onset DiD is the causal within-design for *transient* shocks (drought, cold spells); chronic-exposure characterizes *standing* sub-populations for *recurring* shocks (heat, AQI). Together they show the medical-debt burden of temperature stress is real both as a recurring within-county dynamic **and** as a large persistent cross-sectional gap concentrated in the chronically-hot South.

## Caveats
1. **Static spec has no county FE** (the treatment is time-invariant), so it is a *descriptive* cross-sectional gap, confounded by income/geography. The dynamic spec is the within-design counterpart.
2. **Drought-Always = 1 county** — no chronic-drought inference is possible; reported for completeness only.
3. **Unweighted.** Counties enter equally regardless of population; population-weighting would shift the heat cohort toward large Sun-Belt metros.
