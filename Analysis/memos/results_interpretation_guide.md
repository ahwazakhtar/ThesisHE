# Results Interpretation Guide — Top Economics Journal Framing

## 1. Identification Story

The causal claim rests on a county-level panel with two-way fixed effects:

- **County FE** absorb all time-invariant county characteristics (geography, baseline infrastructure, political lean)
- **Year FE** absorb national trends (ACA rollout, macro cycles, national climate trends)
- **National p80 thresholds** (1990–2000 baseline) define treatment objectively — a county is "treated" only when it exceeds a fixed national extreme (CDD ≥ 1,902; HDD ≥ 5,752), not merely a warmer-than-usual year for that county
- **Recurring treatment** with **pre-trend checks** at h=−2 validate parallel trends where they hold (High_HDD, High_CDD) and flag concerns where they don't (Is_Extreme_Drought on premiums)

---

## 2. Core Results

### Headline Finding

Extreme cold (High_HDD ≥ 5,752 degree-days) is the dominant climate shock for health costs.

| Channel | Effect | Interpretation |
|---------|--------|---------------|
| Premiums (+$31) | Insurers price in cold-winter counties' higher utilization | Supply-side pass-through |
| Hospital bad debt (+$4.43/capita) | Cold causes acute health events (falls, hypothermia, respiratory); uninsured/underinsured can't pay | Demand-side burden |
| Medical debt share (+0.29pp) | Marginal, consistent direction | Household financial stress |
| Median HH income (building pattern) | Effect grows through h=3 | Possible adaptation spending or labor market response |

### The CDD Null as a Finding

Counties with CDD ≥ 1,902 are predominantly Sun Belt — they may be **adapted** (ubiquitous AC, heat-resilient infrastructure). However:

- `Med_HH_Income_Real`: −$265 (p=0.004) — significant negative contemporaneous effect
- `PCPI_Real`: +$492 (p=0.078) — marginally significant positive effect on per capita income

This suggests CDD *does* affect the economy, but the health cost system absorbs it differently. The **asymmetry** between cold (health cost channel) and heat (income channel) is a publishable contribution.

---

## 3. Anticipated Reviewer Pushback

### Pre-Trend Failures

`Is_Extreme_Drought` and `High_AQI_Max` fail parallel trends (p < 0.05 at h=−2) on premium outcomes. Response:

- Report transparently (already done in synthesis tables)
- Frame drought/AQI premium results as **suggestive, not causal**
- Emphasize that High_HDD and High_CDD results **pass** pre-trends

### Recurring Treatment Design

Reviewers trained on staggered-adoption DiD (Callaway & Sant'Anna 2021; Sun & Abraham 2021) will ask why those estimators are not used. Response:

- Treatment is **recurring and reversible** — a county can be shocked in 2015, not in 2016, shocked again in 2017
- This is a **dynamic panel impulse-response** design, not a canonical staggered-adoption setting
- Cite Jordà (2005) for LP justification; de Chaisemartin & D'Haultfœuille (2020) for heterogeneous-treatment robustness discussion

### DL vs. LP Consistency

Where DL and LP agree (High_HDD on premiums: corr=0.97, 100% same sign), the evidence is strong. Where they diverge, discuss which identifying assumptions are more credible in context.

---

## 4. Economic Magnitudes

Contextualize coefficients rather than just reporting them:

- **$31 premium increase** on a ~$450 benchmark silver plan ≈ **7% increase** from a single extreme cold year
- **$4.43 hospital bad debt per capita** × county population = aggregate burden (e.g., a county of 100,000 people absorbs $443,000 in additional hospital bad debt)
- Compare to other known premium drivers (age rating, tobacco surcharge, ACA risk corridor phase-out)
- **−$265 median HH income** from extreme heat ≈ 0.5% of median income — economically meaningful but not catastrophic

---

## 5. Suggested Results Section Structure

1. **Contemporaneous effects table** (h=0, all shocks × all outcomes) — the "main result"
2. **Dynamic profiles** for significant shock-outcome pairs (High_HDD → premiums, bad debt) — show impulse fades by h=2–3 ("transient" pattern)
3. **Robustness panel:** DL/LP consistency, shock-history controls, population weighting sensitivity, rating-area clustering
4. **Economic channels:** Income and employment outcomes as mechanism evidence — cold doesn't just raise costs, it affects labor markets with a delay
5. **Compound shocks:** Exploratory (thin support ~2.2%), but dose-response on premiums is significant (p=0.015)

---

## 6. Literature Positioning

| Paper | Their Finding | Your Extension |
|-------|--------------|----------------|
| Deschênes & Greenstone (2011) | Temperature–mortality relationship | Extend to **financial** outcomes (premiums, debt, income) |
| Barreca et al. (2016) | Adaptation to heat over time | Your CDD null is consistent with adaptation story |
| Deryugina (2017) | Fiscal costs of hurricanes | **Routine** cold extremes (not disasters) have measurable health cost effects |
| Currie & Rossin-Slater (2013) | In utero storm exposure → birth outcomes | Complement with post-birth financial burden channel |
| Miller et al. (2021) | ACA coverage expansion effects on medical debt | Your climate shocks operate *within* the ACA regime, identifying a separate cost driver |

The **asymmetry** between heat (income channel) and cold (health cost channel) is the novel contribution — climate adaptation literature focuses on mortality and energy demand; this paper shows the **financial intermediation** channel through insurance markets and hospital balance sheets.

---

## 7. Key Caveats to Acknowledge

- **SUTVA concerns:** Climate shocks are spatially correlated — neighboring counties likely experience similar shocks. State-level clustering partially addresses this, but spatial spillovers in insurance markets (rating areas span multiple counties) remain.
- **Measurement:** CDD/HDD are degree-day aggregates, not direct measures of extreme weather events. They capture cumulative thermal stress, not peak intensity.
- **External validity:** Results reflect 2011–2023, a period of ACA market stabilization. Pre-ACA or post-subsidy-expansion periods may differ.
- **Compound shock support:** Only ~2.2% of observations experience multiple simultaneous shocks. Compound results are exploratory.
