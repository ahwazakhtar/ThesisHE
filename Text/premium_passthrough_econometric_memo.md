# Memo: Premium Pass-Through and the Debt Mediation Test (T1.1)

**To:** Dissertation author
**Re:** What happened in the pass-through/mediation analysis, why the specification changed twice, and why the final answer is a *located null* rather than a failed estimate
**Files:** `Analysis/mediation/premium_mediation_summary.md`, `Analysis/mediation/premium_passthrough.csv`, `Code/run_premium_mediation.R`, `Text/premium_mediation_writeup.md`

---

## 1. Background and motivation

The October 2025 proposal committed Essay 1 ("Incidence") to two objects that no prior literature has estimated: (a) the pass-through ρ of claims-relevant climate shocks into ACA individual-market benchmark premiums, and (b) a mediation test of whether the shock→medical-debt relationship documented in the reduced form travels *through* those premiums. Both matter because the essay's overarching claim is an "unpriced margin" — the assertion that insurers and policymakers do not price the environmental lag structure of health costs. That claim is only as strong as the evidence that premiums genuinely fail to respond. Task T1.1 delivers both objects, and the route it took — three successive specifications, each correcting an identification error in the last — is itself instructive, because the final conclusion rests on understanding *why* the earlier estimates were wrong.

## 2. Data and institutional setup

The estimation sample is the county×year panel restricted to the marketplace era. Premiums exist 2014–2025 (the ACA exchanges opened in 2014) for roughly 3,134 counties. The outcomes are the monthly real benchmark silver premium (mean ≈ $375) and the lowest-cost bronze premium; the mediation outcome is the county medical-debt share. The shocks are the project's standard binary top-quartile-of-own-history indicators: extreme cold (High_HDD), extreme heat (High_CDD), and extreme drought (PDSI-based).

Four institutional facts about ACA individual-market rating turn out to govern everything:

1. **Rates are set at the geographic rating-area level**, not the county level.
2. **Each state's individual-market enrollees form a single statewide risk pool**, and under 45 CFR 156.80 the geographic rating factor may reflect provider *unit costs* across areas but not local morbidity or utilization.
3. **HHS risk adjustment (45 CFR Part 153)** transfers money between plans based on relative enrollee risk, muting any residual incentive to price a local health shock.
4. **Plan-year-*t* rates are filed around mid-*t*−1** on claims experience through roughly *t*−2 and are locked before the year begins; there is no mid-year re-rating.

Empirically these institutions dominate the data: about 86% of benchmark-premium variance is state×year, and only about a third of the premium's standard deviation is within-state-year. These are under-65 premiums; the elderly are on Medicare — a fact that matters for the age profile of climate morbidity.

## 3. What we set out to estimate

**Equation (i), pass-through:** does a claims-relevant shock raise the benchmark premium? Schematically, premium_{i,t} = ρ·shock_{i,t−k} + unit FE + time FE + ε, with the lag k and — critically — the unit i to be determined by the institutions above.

**Equation (ii), mediation:** fit debt_{c,t} ~ shocks with and without contemporaneous and lagged premium controls on the identical complete-case sample. The ratio coef(with premium)/coef(base) is the fraction of the shock→debt effect *surviving* premium adjustment; one minus that fraction is the premium-mediated share. This is the standard difference-method decomposition — descriptive, not causally identified mediation, a caveat carried explicitly throughout.

## 4. What we did — three specifications, each superseding the last

**Specification 1 (naive county regression).** premium_{c,t} = β·(contemporaneous + lagged shocks)_{c} + county FE + year FE, state-clustered. This produced a significant *contemporaneous* cold coefficient of roughly +$28/month (~7% of the $375 mean) and was initially read as "cold passes through."

**Correction 1 — rate-filing timing.** The contemporaneous coefficient has no pass-through interpretation at all: plan-year-*t* rates are locked before year-*t* weather is realized, so a year-*t* shock is not in the insurer's information set when the rate is set. The specification was re-run on lagged shocks only, with t−2 primary (the fully observed filing window). The result flipped: heat +$19.5 at t−2 (p = 0.050), cold −$15.5 at t−2 (p = 0.008), drought null. This created a new puzzle — a *negative* cold coefficient, which no pricing story delivers.

**Investigation of the negative cold.** Four angles were pursued: institutional rate-setting mechanics; age composition (cold's health burden falls disproportionately on the Medicare-age population, while heat morbidity in insured spending skews working-age — which rationalizes a *null* under-65 cold coefficient but not a negative one); an in-data diagnostic; and the literature (no prior work links climate to health premiums; given the single risk pool and generally partial insurer pass-through, weak pass-through is the expected baseline). The in-data diagnostic found that adding state×year FE to the county regression collapsed *both* the heat and cold coefficients to approximately zero, and an intermediate conclusion was drawn: confound, report a flat null.

**Correction 2 — the decisive econometric review.** The review rejected that inference. "Coefficients collapse under state×year FE" does not establish a confound, because state×year FE *over-absorbs* here: any *legal* statewide morbidity pass-through lives in the statewide index rate — exactly the state×year cell those FE delete. And the test that had been skipped — the state×year-level regression itself — is not null. So *neither* county specification identifies the object: county + year FE lets state-year premium dynamics (the post-2017 CSR-defunding "silver-loading" spike, insurer entry/exit, 1332 waivers) load onto whatever county shock correlates with them, while county + state×year FE deletes the only margin where a legal effect could exist. The review also surfaced three bugs: 484 duplicate county-year rows from 54 multi-rating-area "split" counties, which corrupted the within-county lag construction; a ≤2023 filter silently discarding the 2024–25 premium years; and a significance filter that had been selecting the anti-conservative rating-area-clustered standard errors (rating-area clustering understates SEs when the shocks are effectively state-level events; state clustering is the correct floor).

**Final specification — a two-level decomposition at the levels ACA rates are actually set.**

- **Primary (within-state local margin):** premium_{a,t} = β·shockshare_{a,t−2} + rating-area FE + state×year FE, population-weighted, state-clustered — the only margin through which a *local* shock could legally enter (the geographic rating factor). N = 3,883 rating-area-years.
- **Secondary (between-state statewide-pool margin):** premium_{s,t} = β·shockshare_{s,t−2} + state FE + year FE — the margin the statewide index rate *may* legally price, interpreted through sign and magnitude coherence rather than p-values alone. N = 379 state-years.
- **County specs retained only as a labeled transparency trail** ("misspec"), to show where the earlier numbers came from.

Shocks aggregate to population-weighted *shares* in [0,1] at each level, so every coefficient reads as dollars per fully-exposed unit. Split counties were deduplicated to one row per county-year (stopgap pending the upstream T1.2 fix), the sample was extended through 2025, and state clustering was made primary throughout.

## 5. Final results

Benchmark silver premium, t−2 shocks, dollars per month per fully-exposed unit, state-clustered (from `premium_passthrough.csv`):

| Hazard | County: fips + Year (misspec) | RA×Year: RA + State×Year (primary) | State×Year: State + Year (secondary) |
|---|---|---|---|
| Cold (HDD) | **−15.5** (5.6), p = 0.008 | **+12.6** (5.7), p = 0.034 | −16.7 (27.2), p = 0.54 |
| Heat (CDD) | +19.5 (9.7), p = 0.050 | −10.5 (8.6), p = 0.23 | **+93.3** (40.3), p = 0.025 |
| Drought | −3.2 (11.8), p = 0.78 | +2.5 (2.3), p = 0.29 | +28.5 (16.0), p = 0.081 |
| County + State×Year check | Heat +1.9 (p = 0.53); Cold +2.2 (p = 0.47) | — | — |

Bronze tier, for coherence checks: at the RA level cold is +8.9 (p = 0.014) and drought +5.9 (p = 0.022) — small (1.6–2.4% of the mean) and unmatched on the benchmark tier for drought; at the state level heat is +54.1 (p = 0.010) and cold −23.9 (p = 0.32).

The headline pattern is the sign path across levels: **cold runs −$15.5 → +$12.6 → −$16.7; heat runs +$19.5 → −$10.5 → +$93.3.** A genuine price response does not change sign with the fixed-effect structure. Drought — the hazard with the most genuine county-level identifying variation — is null on the benchmark at every level.

**Mediation** (from the summary; debt share in shares, so 0.0206 = 2.06 pp):

| Term | Base coef | With premiums | Fraction surviving |
|---|---|---|---|
| Drought, t−2 | 0.0206 (p = 0.0004) | 0.0203 (p = 0.0005) | **0.987** |
| Cold (HDD), t−1 | 0.0078 (p = 0.040) | 0.0072 (p = 0.086) | **0.922** |

92% of the one-year cold→debt effect and 99% of the two-year drought→debt effect survive premium adjustment.

## 6. Conclusions and what they mean

**There is no coherent pass-through of local climate shocks into ACA individual-market premiums — and the sign instability is itself the diagnosis.** Each apparent effect in the table is an artifact of which slice of variance (within-state versus between-state) the fixed effects leave standing, not a stable price response. Within states — the only margin a local shock could legally enter — estimates are a few percent of the $375 mean and do not cohere: the one nominally significant term (cold, +$12.6 at the RA level) reverses sign between states and is unaccompanied by any heat response. Between states, premiums do co-move with a two-year heat anomaly (+$93/month benchmark, +$54 bronze), but two features rule out claims pricing: the magnitude is 14–25% of the mean premium, an order of magnitude beyond the ~1–2% claims effect the project's own Medicare estimates attribute to heat morbidity; and cold's between-state sign is *negative*, which is backwards for a claims story, since the same Medicare analysis finds cold *raises* standardized spending. That co-movement reads as lagged temperature anomalies tracking the *level* of a state's premium trajectory, not repricing.

The null is not a disappointment; it is the paper's thesis, located. The institutions predict exactly this: a single statewide risk pool averages a county shock away, the geographic rating factor is restricted to unit costs, and Part 153 risk adjustment removes the incentive to price local morbidity. The market has little structural reason to price a local climate-health shock — which *is* the "unpriced margin" the dissertation asserts, now demonstrated rather than assumed.

The mediation result is then the corollary of a null first stage: with no premium response, there is no premium channel for the debt to travel through. The 92–99% survival rates say the shock→debt effect accrues via out-of-pocket costs and lost income — the same real-economy channel the income and employment results trace.

**One asymmetry must not be lost.** Absorbing state×year variation is correct *here* because the premium is administratively generated at the state-year level — the FE removes the rate-setting process, not the treatment. The same FE applied to household outcomes (debt, income, employment) would be wrong, because a cold wave is itself a state-level event and state×year FE would delete treatment, not confounding. This analysis therefore does not undermine the household-level headline results; the asymmetry is developed in the cross_level_symmetry track.

## 7. Methodological lessons

1. **Match shock timing to institutional decision timing.** Rates are filed mid-*t*−1 on ~*t*−2 experience; a contemporaneous coefficient is uninterpretable as pass-through regardless of its p-value. Lagged shocks only, t−2 primary.
2. **The level of analysis is not innocuous.** Estimate at the level the outcome is generated. A county regression of a state-set outcome is confounded by construction — 86% of the variance never belonged to the county in the first place.
3. **"The coefficient collapses when I add FE X" is not automatically evidence of a confound.** Ask whether FE X over-absorbs the object of interest. Here, state×year FE deleted the only cell a legal statewide effect could occupy; the correct response was to *estimate at* that cell, not to absorb it and declare a null.
4. **Sign-coherence and magnitude-plausibility checks beat mechanical FE horse-races.** The decisive evidence against pass-through was not any single p-value but the sign flip across levels and the benchmark against the project's own Medicare claims estimates.
5. **Cluster at the level of treatment assignment (state), and never let the more-clusters variant pick your significance.** Rating-area clustering mechanically shrinks SEs when shocks are state-level events; it is reported as a variant only.
6. **Housekeeping matters for identification:** the 484 duplicate split-county rows corrupted lag construction, and the ≤2023 filter silently cost two premium years. Both would have contaminated any specification.
