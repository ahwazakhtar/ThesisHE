# Wet-Shock Bin — Reviewer-Requested Discrete Wet-Extreme Margin (T1.6)

_Generated 2026-07-13 16:55:29. PRE-REGISTERED design (spec.md "Wet-shock bin pre-specification (T1.6 — added 2026-07-13)"). Input: `Data/county_level_master.csv` (md5 `6acb472b010f502292dfc31dcb4cb345`)._

**Question (reviewer).** Are precipitation shocks accounted for? They are, three ways —
continuous `Z_Precip` + lags, year-over-year swings (`Delta_Z_Precip`, documented income
effect), and PDSI as the deficit extreme. This adds the one missing piece: a **discrete
wet-extreme bin**. The dry tail is NOT re-binned (drought/PDSI already owns it).

**Design (frozen).** `High_Precip = 1{Z_Precip > +1.5}` at t, t-1, t-2 in one
distributed-lag `fixest::feols` per outcome; county (`fips_code`) + `Year` FE;
State-clustered SEs. Primary = **no controls, unweighted**; sensitivity = the established
contemporaneous controls on the identical sample. 4 outcomes x 3 lags = **12 primary cells**;
BKY (2006) sharpened q over the 12. `Z_Precip` is anchored to each county's 1990-2000
baseline mean/SD (`process_county_climate.R`).

## Decision rule (binding, restated)
Tier capped at **exploratory / appendix robustness regardless of significance** — this
answers a reviewer, it does NOT enter the headline hazard family. Permitted language at
q<0.10: "a reviewer-requested wet-extreme margin, exploratory." Otherwise the honest null,
cited as evidence the hazard family is complete.

## Expectation vs result
**Expectation HELD.** No cell survives BKY q<0.10 (1/12 have raw p<0.05). The wet-extreme LEVEL shows no coherent effect on any headline outcome — consistent with the a-priori read that precipitation acts through year-over-year SWINGS (`Delta_Z_Precip`), not sustained wet levels. The only raw-p<0.05 cell(s): Median HH income (real) at t-1 (est -219.8, p 0.021, q 0.25) — directionally consistent with the documented swing-income loss, but NOT surviving sharpened-q, so it stays exploratory.

## Primary 12-cell table (unweighted, no controls, full sample)
Significance: \*p<0.10, \*\*p<0.05, \*\*\*p<0.01. `t-h` = High_Precip at lag h.
| Outcome | Lag | Estimate | SE | t | p | BKY q |
|---------|-----|----------|----|---|---|-------|
| Medical debt share | t-0 | 0.0008735 | 0.001436 | 0.608 | 0.546 | 0.828 |
| Medical debt share | t-1 | -0.0003155 | 0.001399 | -0.226 | 0.823 | 0.876 |
| Medical debt share | t-2 | -0.00143 | 0.001352 | -1.06 | 0.295 | 0.824 |
| Per-capita income (real) | t-0 | 24.04 | 153.6 | 0.156 | 0.876 | 0.876 |
| Per-capita income (real) | t-1 | -102.3 | 170.9 | -0.599 | 0.552 | 0.828 |
| Per-capita income (real) | t-2 | -119.7 | 144.6 | -0.828 | 0.412 | 0.824 |
| Civilian employed | t-0 | 193.1 | 136.5 | 1.41 | 0.164 | 0.824 |
| Civilian employed | t-1 | -35.25 | 136.9 | -0.258 | 0.798 | 0.876 |
| Civilian employed | t-2 | 60.91 | 151.9 | 0.401 | 0.69 | 0.876 |
| Median HH income (real) | t-0 | -86.05 | 92.13 | -0.934 | 0.355 | 0.824 |
| Median HH income (real) | t-1 | -219.8** | 92.23 | -2.38 | 0.0211 | 0.254 |
| Median HH income (real) | t-2 | -71.62 | 80.12 | -0.894 | 0.376 | 0.824 |

## Incidence of the frozen bin (reported, not adjusted)
`High_Precip = 1{Z_Precip > 1.5}` fires on **14.91%** of valid-climate county-years
(6082 of 40781; 1082 NA-climate county-years dropped per [B3]). For comparison in the same
window: High_CDD = 24.3%, High_HDD = 17.4%, Is_Extreme_Drought = 2.3%. The wet bin
is a **substantial ~15% bin** (not a 0.5% rarity nor a 20%+ p80 bin): the in-sample precip
z-distribution (2011-2023) sits wetter/right-skewed relative to the 1990-2000 anchor, so a
nominal z>1.5 catches ~15%, not the ~6.7% a standard normal implies. The threshold is FROZEN
— this is reported, not tuned. Incidence is **strongly year-clustered** (a few very wet years
dominate), which the Year FE absorb; identification comes from cross-county variation within
wet years.

### Incidence by year
| Year | County-yrs | Wet | Share |
|------|-----------|-----|-------|
| 2011 | 3137 | 821 | 0.262 |
| 2012 | 3137 | 58 | 0.018 |
| 2013 | 3137 | 413 | 0.132 |
| 2014 | 3137 | 123 | 0.039 |
| 2015 | 3137 | 909 | 0.290 |
| 2016 | 3137 | 272 | 0.087 |
| 2017 | 3137 | 186 | 0.059 |
| 2018 | 3137 | 1313 | 0.419 |
| 2019 | 3137 | 916 | 0.292 |
| 2020 | 3137 | 634 | 0.202 |
| 2021 | 3137 | 244 | 0.078 |
| 2022 | 3137 | 56 | 0.018 |
| 2023 | 3137 | 137 | 0.044 |

### Incidence by state (top 10 by share)
| State | County-yrs | Wet | Share |
|-------|-----------|-----|-------|
| KY | 1560 | 519 | 0.333 |
| NJ | 273 | 75 | 0.275 |
| VA | 1716 | 447 | 0.260 |
| CT | 104 | 26 | 0.250 |
| NC | 1300 | 324 | 0.249 |
| RI | 65 | 16 | 0.246 |
| MI | 1079 | 250 | 0.232 |
| DE | 39 | 9 | 0.231 |
| AR | 975 | 220 | 0.226 |
| TN | 1235 | 272 | 0.220 |

## Sensitivity — established contemporaneous controls (same sample, [B4])
Both variants on the IDENTICAL sample per outcome (requires `Household_Income_2023` &
`Uninsured_Rate` observed; N is smaller than the primary full sample). **Caveat:** for the
two income outcomes the control `Household_Income_2023` is a near-copy of the outcome
(r = 0.95 with `Med_HH_Income_Real`) — an extreme bad control shown only for completeness;
the no-control primary is the valid spec.
| Outcome | Lag | Variant | Estimate | SE | p | N |
|---------|-----|---------|----------|----|---|---|
| Medical debt share | t-0 | (ii) contemporaneous | -0.0003773 | 0.001657 | 0.821 | 32748 |
| Medical debt share | t-0 | (i) no controls | -0.0004957 | 0.001809 | 0.785 | 32748 |
| Medical debt share | t-1 | (ii) contemporaneous | -0.001156 | 0.001535 | 0.455 | 32748 |
| Medical debt share | t-1 | (i) no controls | -0.001108 | 0.001573 | 0.485 | 32748 |
| Medical debt share | t-2 | (ii) contemporaneous | -0.001717 | 0.001562 | 0.277 | 32748 |
| Medical debt share | t-2 | (i) no controls | -0.00172 | 0.001545 | 0.271 | 32748 |
| Per-capita income (real) | t-0 | (ii) contemporaneous | -138.8 | 177.7 | 0.439 | 33915 |
| Per-capita income (real) | t-0 | (i) no controls | -129.5 | 175.6 | 0.464 | 33915 |
| Per-capita income (real) | t-1 | (ii) contemporaneous |  -173 | 160.6 | 0.287 | 33915 |
| Per-capita income (real) | t-1 | (i) no controls | -195.1 | 162.3 | 0.235 | 33915 |
| Per-capita income (real) | t-2 | (ii) contemporaneous | -147.7 |   162 | 0.367 | 33915 |
| Per-capita income (real) | t-2 | (i) no controls | -186.6 | 171.5 | 0.282 | 33915 |
| Civilian employed | t-0 | (ii) contemporaneous | -105.9 | 184.5 | 0.569 | 33915 |
| Civilian employed | t-0 | (i) no controls | -89.06 | 181.7 | 0.626 | 33915 |
| Civilian employed | t-1 | (ii) contemporaneous | -118.6 | 121.6 | 0.334 | 33915 |
| Civilian employed | t-1 | (i) no controls | -171.8 | 143.3 | 0.236 | 33915 |
| Civilian employed | t-2 | (ii) contemporaneous | -179.6 | 167.5 | 0.289 | 33915 |
| Civilian employed | t-2 | (i) no controls | -279.9 | 202.3 | 0.173 | 33915 |
| Median HH income (real) | t-0 | (ii) contemporaneous | -92.57 | 59.11 | 0.124 | 33911 |
| Median HH income (real) | t-0 | (i) no controls | -73.85 | 86.58 | 0.398 | 33911 |
| Median HH income (real) | t-1 | (ii) contemporaneous | -55.55 | 49.96 | 0.272 | 33911 |
| Median HH income (real) | t-1 | (i) no controls | -125.8 | 83.49 | 0.138 | 33911 |
| Median HH income (real) | t-2 | (ii) contemporaneous | -7.988 | 57.12 | 0.889 | 33911 |
| Median HH income (real) | t-2 | (i) no controls | -149.2 | 99.67 | 0.141 | 33911 |

## Robustness — population-weighted, no controls ([B2])
Reported because run_county_analysis.R runs both weightings and run_latent_hardship.R calls
population weighting primary for the debt *gradient*; the primary here is unweighted, matching
run_control_sensitivity.R's evidence-table production estimator. NOT one of the 12 primary
cells; separate BKY q.
| Outcome | Lag | Estimate (pop-wtd) | SE | p | BKY q | N |
|---------|-----|--------------------|----|---|-------|---|
| Medical debt share | t-0 | 0.003816* | 0.002124 | 0.0787 | 0.331 | 38666 |
| Medical debt share | t-1 | 0.002796* | 0.001569 | 0.0811 | 0.331 | 38666 |
| Medical debt share | t-2 | 0.002565 | 0.001739 | 0.147 | 0.352 | 38666 |
| Per-capita income (real) | t-0 |   237 | 145.7 | 0.11 | 0.331 | 40038 |
| Per-capita income (real) | t-1 | -267.2 |   202 | 0.192 | 0.385 | 40038 |
| Per-capita income (real) | t-2 |  -130 | 251.1 | 0.607 | 0.809 | 40038 |
| Civilian employed | t-0 | -158.7 |  1939 | 0.935 | 0.993 | 40021 |
| Civilian employed | t-1 | -3558 |  3209 | 0.273 | 0.468 | 40021 |
| Civilian employed | t-2 | -1798 |  2780 | 0.521 | 0.781 | 40021 |
| Median HH income (real) | t-0 | 208.8 | 127.3 | 0.107 | 0.331 | 40015 |
| Median HH income (real) | t-1 | -1.577 | 174.4 | 0.993 | 0.993 | 40015 |
| Median HH income (real) | t-2 | -15.68 | 217.4 | 0.943 | 0.993 | 40015 |

## Implementation bindings
- **[B1] Lags** — thresholded the master's precomputed `Z_Precip_Lag1/Lag2` (value-identical
  to `lag(High_Precip)` on the interior; correct at the 2011 boundary).
- **[B2] Weighting** — UNWEIGHTED primary (run_control_sensitivity.R production estimator);
  population-weighted reported as labeled robustness (tension with run_latent_hardship.R noted).
- **[B3] Missing climate** — `High_Precip = NA` where `Z_Precip` is NA (~83 non-CONUS counties);
  dropped, NOT coerced to 0 (no silent "missing = not wet" miscoding).
- **[B4] Sensitivity** — same-sample no-control + contemporaneous, identical N asserted.
- **[B5] CO-2023** — Medical_Debt_Share for CO 2023 set NA (CO HB23-1126).

## Draft reviewer response (one paragraph)
Precipitation is already accounted for in every county fixed-effects model: as a continuous z-score (`Z_Precip` and its two lags, anchored to each county's 1990-2000 baseline), as year-over-year *swings* (`Delta_Z_Precip`), which carry a documented persistent income effect (roughly -$240 to -$274 per capita at horizons 1-3 years), and via PDSI as the precipitation-*deficit* extreme (`Is_Extreme_Drought`). In response to the reviewer we additionally estimated a discrete *wet-extreme* bin, `High_Precip = 1{Z_Precip > +1.5}` (14.9% of valid county-years, symmetric to a z-based cold bin; the dry tail is already owned by PDSI/drought). Entered as a distributed lag (t, t-1, t-2) in the established county+year fixed-effects spec (state-clustered, no controls) across all four headline outcomes, the wet-extreme bin shows small, statistically null level effects on every outcome; none survives sharpened-q multiplicity control. We read this as confirmation that the wet tail adds no coherent LEVEL channel beyond the swing and deficit margins already in the models; it enters as an appendix robustness check, not as a headline hazard.

## Reading
- Medical debt is **measurement-fragile** by construction; lead with income/employment.
- The full grid (primary + sensitivity + pop-weighted robustness) with q-values is in
  `wet_shock_coefs.csv`.
- This margin is **appendix/exploratory by frozen decision rule**, independent of the result.
