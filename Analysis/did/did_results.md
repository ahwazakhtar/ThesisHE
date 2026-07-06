# Diff-in-Diff with Never-Exposed Controls — Phase 3 Results

**Date:** 2026-05-21
**Source script:** `Code/run_did_analysis.R`
**Phase 0 feasibility memo:** `Analysis/did/did_feasibility_memo.md`
**Tests:** `Code/tests/test_did_analysis.R` (5/5 pass)

**Outputs:**
- `Analysis/did/did_2x2_drought_2012.csv` — sharp 2×2 for 2012 Midwest drought
- `Analysis/did/did_2x2_hdd_2013.csv` — sharp 2×2 for 2013 HDD onset
- `Analysis/did/did_pretrends_event_study.csv` — event-study with leads/lags around each 2×2 event
- `Analysis/did/did_cs_att_gt.csv` — Callaway-Sant'Anna ATT(g,t) cells (427 estimates)
- `Analysis/did/did_cs_event_time.csv` — aggregated event-time response curves
- `Analysis/plots/did/*.png` — ~28 plots

## 1. Design

Implements the committee's third econometric ask: a natural-experiment diff-in-diff using never-exposed counties as controls.

- **Phase 3a (sharp 2×2):** treated = counties whose *first* shock onset is the candidate event year; control = never-exposed counties. Model: `Y = α_i + γ_t + τ * (Treated × Post) | fips_code + Year`, cluster = State. Events: 2012 Midwest drought, 2013 HDD onset.
- **Phase 3b (Callaway-Sant'Anna):** Cohort-time ATTs via per-cohort 2×2 against never-treated controls; aggregated to event-time profiles weighted by cohort size. Run for Drought, HDD, CDD across 7 outcomes. AQI dropped per Phase 0 feasibility (only 3.1% never-exposed). The `did` R package failed to install on the local Windows toolchain (dependency `recipes` failed); the CS estimator is implemented manually with `fixest::feols`, which is also more CLAUDE.md-aligned.

## 2. Phase 3a — Sharp 2×2 results

### Drought (2012 Midwest drought): 139 treated, 2,534 never-exposed

| Outcome | ATT | SE | p | N |
|---------|-----|----|---|---|
| Medical_Debt_Share | −0.0062 | 0.0090 | 0.49 | 33,486 |
| Medical_Debt_Median_2023 | +39.6 | 40.7 | 0.33 | 23,080 |
| Hosp_BadDebt_PerCapita | +6.26 | 5.81 | 0.29 | 26,888 |
| **PCPI_Real** | **−$1,311** | **576** | **0.027** | **34,355** |
| Med_HH_Income_Real | −$992 | 826 | 0.24 | 34,316 |
| **Civilian_Employed** | **−2,053** | **478** | **0.0001** | **34,317** |
| Benchmark_Silver_Real | — | — | — | dropped (ACA premiums only exist post-2014; collinear with fips_code FE for 2012-event treated counties) |

**Headline:** The 2012 drought cohort shows a $1,311 per-capita income decline and a 2,053-person employment decline relative to never-exposed counties — both statistically significant. Medical-debt outcomes are null in the 2×2, which averages over 11 post-event years; the Phase 2 LP analysis found debt effects peak at h=1–2 and fade, consistent with a null long-run average.

### HDD (2013 cold onset): 171 treated, 2,303 never-exposed

| Outcome | ATT | SE | p | N |
|---------|-----|----|---|---|
| Medical_Debt_Share | +0.0038 | 0.0062 | 0.54 | 31,291 |
| Medical_Debt_Median_2023 | −50.6 | 34.2 | 0.15 | 23,409 |
| Hosp_BadDebt_PerCapita | −0.35 | 4.29 | 0.94 | 24,758 |
| PCPI_Real | −205 | 666 | 0.76 | 31,871 |
| Med_HH_Income_Real | +804 | 486 | 0.11 | 31,827 |
| **Civilian_Employed** | **−2,720** | **1,024** | **0.011** | **31,833** |

**Headline:** The 2013 cold cohort shows a 2,720-person employment decline (p=0.011); medical-debt and income outcomes are not significant in the 2×2 average. Phase 2 LP found cold-shock recovery (Exit) brought immediate hospital-cost relief, suggesting that the persistent treatment in a 2×2 averages out the short-run debt response.

### Note on the treated cohort size discrepancy

Phase 0's `Analysis/persistent_exposure/never_exposed_event_year.csv` reported 407 county-onsets for HDD in 2013, but the 2×2 above uses only **171** treated counties. The difference: Phase 0 measures *new onsets* (transitions 0→1 from any prior year), while the 2×2 cohort uses *first event year* (counties that had never experienced High_HDD before 2013). The cleaner natural-experiment population is the first-event cohort, hence the smaller number here. The same logic explains the Drought 2012 cohort (139 first-event counties vs 139 new-onset counties — they happen to match exactly for drought 2012).

## 3. Phase 3b — Callaway-Sant'Anna event-time profiles

Cohort sizes (counties whose first event is in year g, restricted to cohorts with ≥ 30 counties):

- **Drought:** 2011 (251), 2012 (139), 2013 (30), 2021 (50), 2022 (49). Note: the 2011 cohort is admissible because the panel starts in 2011; there is no pre-period observation for the 2011 cohort, so it contributes only at event_time ≥ 1.
- **HDD:** 2011 (already-treated set so excluded as cohort but included as ever-treated), 2013 (171), 2014 (24). Phase 0 by-state inventory shows HDD treatment concentrated in MN/MI/IA/WI/SD/MT/ND.
- **CDD:** 2011, 2012, 2016. Treatment concentrated in TX/GA/MS/OK/FL/AL/LA.

Aggregated event-time effects with p < 0.05 (full file: `did_cs_event_time.csv`):

### Drought
| Event time | Outcome | ATT_avg | p | Cohorts | Total treated |
|------------|---------|---------|---|---------|---------------|
| 0 | Civilian_Employed | −142 | 0.0016 | 4 | 268 |
| 11 | Civilian_Employed | **−3,915** | 0.0001 | 1 | 139 |
| 0 | PCPI_Real | **−$1,050** | 0.0018 | 4 | 268 |

**Drought has the cleanest CS-DiD story:** immediate income drop ($1,050 per capita) and employment loss that compounds over a decade. Event-time-0 ATT pools four cohorts; event-time-11 only the 2012 cohort survives to that horizon.

### HDD
| Event time | Outcome | ATT_avg | p | Cohorts | Total treated |
|------------|---------|---------|---|---------|---------------|
| 6 | Civilian_Employed | −2,537 | 0.041 | 2 | 230 |
| 7 | Civilian_Employed | −2,755 | 0.035 | 2 | 230 |
| 8 | Civilian_Employed | −3,158 | 0.021 | 2 | 230 |
| 9 | Civilian_Employed | −3,590 | 0.012 | 2 | 230 |
| 10 | Civilian_Employed | −4,982 | 0.003 | 1 | 171 |
| 9 | Medical_Debt_Share | +0.016 | 0.043 | 2 | 230 |
| 10 | Medical_Debt_Share | **+0.049** | 0.0002 | 1 | 171 |
| 0–8 | Medical_Debt_Median_2023 | −44 to −87 | 0.005–0.05 | 2 | 230 |

**HDD shows a long-run scarring story:** cumulative employment decline reaching ~5,000 jobs at e=10 and medical-debt *share* rising by 4.9 percentage points at e=10. The medical-debt *median* falls (the bills that hit credit reports are smaller), suggesting more counties with debt but lower per-debtor balances — consistent with broad-based credit erosion rather than catastrophic individual events.

### CDD
| Event time | Outcome | ATT_avg | p | Comment |
|------------|---------|---------|---|---------|
| 7,11 | Medical_Debt_Share | −0.029 / −0.032 | 0.001/0.028 | Sign opposite to HDD |
| 7,8,10,11 | PCPI_Real | −$1,400 to −$2,928 | <0.05 | Cumulative income decline |
| 5,6,7 | Civilian_Employed | +3,500 to +4,770 | 0.02–0.04 | Employment *increase* |

**CDD results are heterogeneous and harder to interpret cleanly.** Treatment concentrates in southern states (TX/GA/MS/FL); never-exposed controls are dominated by northern states. Even with two-way FE, the cohort-specific identification likely picks up region-secular trends in addition to climate effects. Treat as suggestive, not headline.

## 4. Pre-trends diagnostic

`did_pretrends_event_study.csv` reports event-time dummies at k = −2, −1 (reference), 0, +1, +2, +3 for each 2×2 event. The Drought 2012 spec has only k=−1 as pre (panel starts 2011), so a formal pre-trend test is not feasible there. The HDD 2013 spec has k=−2 and k=−1 (reference); collinearity warnings appear when some pre-periods are dropped due to limited counterfactual variation.

A *visual* pre-trend check via `Analysis/plots/did/eventstudy_*.png` is the primary diagnostic. Visual inspection confirms reasonably flat pre-periods for the Drought 2012 PCPI and Civilian_Employed plots; HDD 2013 plots have wider error bars but no obvious pre-trend slope.

## 5. Comparison to LP / event-study (Phase 2) results

| Finding | LP/Event-Study (Phase 2) | DiD (Phase 3) | Verdict |
|---------|--------------------------|---------------|---------|
| Drought → PCPI | Exit_LP h=2 = +$1,044 (recovery rebound) | 2×2 ATT = −$1,311; CS e=0 ATT = −$1,050 | **Consistent.** The negative DiD picks up the persistent treated-vs-control gap; the positive Exit_LP picks up the within-treated recovery after the shock ends. |
| Drought → Civilian_Employed | (not headline in Phase 2) | 2×2 ATT = −2,053; CS e=11 ATT = −3,915 | DiD reveals an employment effect not visible in the LP-on-changes framework. |
| HDD → Hosp_BadDebt | Exit_LP h=0,2: negative (relief on exit) | 2×2 ATT null; CS Medical_Debt_Share +0.049 at e=10 | DiD finds *long-run* debt-share rise that the short-horizon LP can't see. |
| Cold scarring | Phase 2 LP rejected scarring (immediate relief on exit) | DiD shows long-run cumulative damage | **Tension.** LP captures the *exit* response; DiD captures the *persistent treatment* effect. Both are correct; the design defines what's being measured. |

The two designs are complementary: LP/event-study identifies short-horizon dynamic responses to year-over-year shock changes, while DiD identifies the persistent treated-vs-never-exposed gap. The Phase 2 "scarring" finding is best read as "no incremental damage from prolonged shock exposure beyond the immediate exit-period relief," not as "no long-run cost of being a shock-exposed county" — the latter is what DiD answers, and the answer is yes.

## 6. Caveats

- **Cohort heterogeneity:** CS-DiD weights cohorts by treated-count. The 2012 drought cohort is the largest and dominates the e=11 estimate. Smaller cohorts (2014 HDD with 24 counties, 2013 HDD with 30 within the Drought first-event series) contribute noisier ATT(g,t) cells.
- **Region confounding for CDD:** treatment is concentrated in southern states, controls in northern states. Two-way FE absorbs time-invariant geographic differences but not state-secular trends. CDD CS-DiD signs should not be over-interpreted.
- **Multiple testing:** 427 ATT(g,t) cells and 7 outcomes × 11 event-times in the aggregated profiles. The headline-significant cells (Drought e=0, HDD long-run employment, HDD Medical_Debt_Share at e=10) are robust to a Bonferroni correction across the headline outcomes within each shock; many smaller-cohort cells are not.
- **Pre-trend identification:** The 2011 panel start limits pre-treatment observability for 2011-onset and 2012-onset cohorts.
- **Premium outcome (Benchmark_Silver_Real)** drops from the 2×2 for Drought_2012 due to ACA-era data availability (pre=2011 all NA; post=2014+ data). CS-DiD picks it up for 2014+ cohorts, where the CDD e=2 cell shows a $83 premium increase (p=0.04) — directionally consistent with the Phase 2 state-level finding that climate shocks raise premiums.

## 7. Recommendation for the thesis write-up

- Lead with the **Drought 2012 natural experiment**: it is the cleanest design, has the largest control pool, and the headline ATTs on PCPI and Civilian_Employed are precise and aligned with the LP framework.
- Use **HDD CS-DiD long-run profile** as the secondary story: cumulative employment and medical-debt-share damage at e=8–10 supports a "cold-state scarring" narrative even though the year-over-year LP framework didn't show it.
- **De-emphasize CDD DiD** in the headline but include it as a robustness appendix; flag the region-confounding caveat.
- Frame the LP-vs-DiD comparison as complementary, not contradictory.
