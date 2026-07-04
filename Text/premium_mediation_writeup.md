# Premium Pass-through and the Debt Channel

*Draft section fragment for Essay 1 (Incidence). NBER style. Generated from
`Code/run_premium_mediation.R`; results in `Analysis/mediation/`.*

The proposal set out to estimate two objects the reduced form leaves implicit: the rate at which
climate shocks pass through into health-insurance premiums, and the extent to which the medical debt
that follows a shock is the downstream trace of those higher premiums. Both are recoverable from the
county panel, but the first turns entirely on a question of units, because ACA premiums are not a
county object.

## The level of analysis is the whole problem

Individual-market rates are built at the geographic rating-area level, from a single statewide risk
pool, and filed and reviewed one state at a time. In the data this administrative structure is
overwhelming: about 86 percent of the variance in the benchmark premium is state-by-year, and only
roughly a third of its standard deviation is within a state in a given year. A regression of a
premium on a county-level shock with county and national-year fixed effects therefore identifies
almost nothing local; it lets state-by-year premium dynamics — the post-2017 "silver loading" spike,
insurer entry and exit, 1332 waivers — load onto whatever county variable happens to correlate with
them. The rate-filing calendar compounds the point: plan-year-*t* rates are filed around mid-*t−1* on
claims experience through roughly *t−2*, so only *lagged* shocks are even eligible to pass through,
with the two-year lag the fully-observed window.

The tell that the county specification is not identifying pass-through is that its coefficients are
not stable in sign. The two-year cold coefficient on the benchmark premium runs −\$15.5 per month
under county and year fixed effects, +\$12.6 once the estimate is taken within states, and −\$16.7
between states; the heat coefficient runs +\$19.5, then −\$10.5, then +\$93. A genuine price response
does not change sign with the fixed-effect structure. Each apparent effect is an artifact of which
slice of variance — within-state or between-state — the fixed effects leave standing. Adding
state-by-year fixed effects to the county regression collapses both the +\$19.5 heat and the −\$15.5
cold coefficients to about +\$2 (*p* = 0.53 and 0.47), which is where the earlier, spurious county
results came from.

The question is therefore estimated at the two levels the institutions actually use, each mapped to
a distinct margin.

## Within states: no coherent local pass-through

The geographic rating factor is the only channel through which a purely local shock could enter a
premium, so the within-state test — rating-area by year, with rating-area and state-by-year fixed
effects — is the one that speaks to the local margin. Here the estimates are small, a few percent of
the \$375 average benchmark, and they do not cohere. Cold carries a positive coefficient that is
marginally significant (+\$12.6, *p* = 0.03 on the benchmark; +\$8.9, *p* = 0.01 on bronze), but that
sign reverses between states and is not accompanied by any heat response (heat is −\$10.5, *p* = 0.23).
With six coefficients per premium tier and no agreement across tiers, levels, or hazards, the
within-state evidence does not support a local pass-through. That reading is what the institutions
predict: the rating factor is directed to provider *unit-cost* differences across areas rather than to
local morbidity or utilization, the single risk pool averages a county shock across the whole state,
and HHS risk adjustment (45 CFR Part 153) moves money between plans on relative enrollee risk, muting
the incentive to price a local health shock in the first place.

## Between states: co-movement that is not pricing

The between-state test — state by year, with state and year fixed effects — recovers the statewide
margin the index rate *may* legally reflect, and there the premium is not flat: state benchmark
premiums rise with a two-year heat anomaly (+\$93 per month, *p* = 0.02; +\$54 on bronze, *p* = 0.01).
Two features rule this out as claims pricing. The magnitude is implausible — \$93 is a quarter of the
mean premium for a fully heat-exposed state-year, an order of magnitude larger than the roughly 1–2
percent of claims that this project's own Medicare estimates attribute to a heat-driven morbidity
surge. And the sign on cold is backwards for a claims story: the same Medicare analysis finds cold
*raises* standardized spending, so pass-through pricing predicts a positive cold coefficient, whereas
the state-level estimate is negative and insignificant (−\$16.7, *p* = 0.54). The between-state
pattern reads as lagged temperature anomalies tracking the *level* of a state's premium trajectory,
not as insurers repricing realized climate claims.

## The unpriced margin, located

Drought, the one hazard with enough within-county variation for the county design to say anything, is
null at every level. Across all three levels and both premium tiers, no hazard produces a sign-stable,
magnitude-credible pass-through. The honest conclusion is that the individual market does not
coherently reprice the local health-cost consequences of climate shocks — which is the dissertation's
unpriced margin, now located rather than asserted: the within-state margin where a local shock could
enter is quiet, and the between-state co-movement that is not quiet is too large and mis-signed to be
pricing. This sits comfortably in the literature, where health-insurer pass-through of cost shocks is
partial even in the best cases and geographic pooling averages local shocks away, and where no prior
work has estimated climate pass-through into health premiums at all.

## Mediation: a corollary of the null first stage

Whether premiums carry the medical debt that follows a shock is then nearly answered by the first
stage. Re-estimating the shock-to-debt relationships with and without contemporaneous and lagged
premiums on the identical sample, 92 percent of the one-year cold effect and 99 percent of the
two-year drought effect survive premium adjustment. With no coherent premium response to the shocks
in the first place, there is no premium channel for the debt to travel through, so the debt
accumulates by the more direct route of out-of-pocket costs and lost income landing on household
balance sheets — the same real-economy channel the income and employment results trace.

One caution on method deserves to be explicit, because it governs how far the state-by-year fix
travels. Absorbing state-by-year variation is the right benchmark *here* precisely because the
premium is administratively generated at that level — the fixed effect removes the rate-setting
process, not the treatment. Household outcomes are not state-set, and a cold wave is itself a
state-level event, so the same fixed effect applied to debt, income, or employment would delete
treatment rather than confounding. The asymmetry is deliberate and is developed in the cross-level
symmetry results; it should not be read as license to absorb state-by-year variation from the
household regressions.

*Caveats.* The mediation is a difference-method decomposition rather than a causally identified
mediation; the premium is itself a shock outcome, so the split assumes no premium-debt confounding
given the fixed effects. Premiums enter at the rating-area level, so any mediated share is a lower
bound on a county-level channel. The premium series begins in 2014 with the ACA marketplaces, so the
mediation runs on 2014–2025 and its base debt coefficients exceed the full-panel headlines; the
surviving *fraction*, invariant to the sample, carries the conclusion. Inference is clustered on
state throughout — the level at which both the shocks and the rate-setting process operate; the
rating-area-clustered variant, which uses more clusters and understates the correlated error, is
reported but not used to judge significance. The multi-rating-area "split" counties are collapsed to
one row per county-year here as a stopgap for the upstream one-row-per-county-year fix.
