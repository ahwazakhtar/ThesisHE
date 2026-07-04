# Premium Pass-through and the Debt Channel

*Draft section fragment for Essay 1 (Incidence). NBER style. Generated from
`Code/run_premium_mediation.R`; results in `Analysis/mediation/`.*

The proposal set out to estimate two objects the reduced form leaves implicit: the rate at which
climate shocks pass through into health-insurance premiums, and the extent to which the medical debt
that follows a shock is the downstream trace of those higher premiums. Both are recoverable from the
county panel, and together they locate where in the insurance system a weather shock becomes a
household liability.

The pass-through has to be measured with the rate-setting calendar in mind. Insurers file
individual-market rates for plan year *t* around the middle of year *t−1*, using claims experience
through roughly *t−2*, and those rates are locked before the plan year begins; mid-year re-rating is
not permitted. A weather shock realized during year *t* is therefore absent from the insurer's
information set when the year-*t* premium is set, so only *lagged* shocks can pass through, with the
two-year lag the fully-observed window and the one-year lag only partial. Estimating the premium on
lagged shocks accordingly, the pass-through is weak and specific to heat. An extreme-heat year raises
the benchmark silver premium two years later by about \$20 per month and the lowest-cost bronze
premium by about \$13 per month—roughly 3 to 5 percent of the \$375 average benchmark—significant
under rating-area clustering (*p* = 0.01 and 0.006). This is the one response that is consistent in
both timing and sign with insurers pricing a realized morbidity surge: heat raises Medicare spending
and emergency-department use two years out, and rates move with it. Drought produces no reliable
premium response at any lag, and cold produces a two-year coefficient that is negative and precise
(about −\$17 per month), a sign the claims mechanism cannot rationalize and that I read as an
artifact of risk-adjustment transfers or market selection rather than evidence that cold lowers
premiums. The defensible conclusion is narrow: of the three hazards, only heat passes through into
premiums, and only at the lag the filing cycle allows.

Whether that pass-through carries the debt is a separate question, and the answer is largely no.
Re-estimating the shock-to-debt relationships with and without contemporaneous and lagged benchmark
premiums on the identical sample, the debt effects are almost untouched by premium adjustment. Of
the cold-driven increase in the medical-debt share at a one-year lag, 93 percent survives the
addition of premium controls; of the two-year drought effect, 99 percent survives. The
premium-mediated portion is on the order of a twentieth to a hundredth of each effect. This is what
one would expect given the pass-through estimates: the two hazards that generate the debt, cold and
drought, are precisely the two that do not raise premiums, so there is no premium channel available
to carry their effect. The medical debt that accumulates after a shock arrives through the more
direct route of out-of-pocket costs and lost income landing on household balance sheets, the same
real-economy channel the income and employment results trace.

Read together, the two estimates sharpen the dissertation's claim of an unpriced margin, and locate
it. Premiums respond to the environmental signal only for heat and only at the rate-cycle lag, so
the market prices a slice of the risk. But the hazards that drive the household debt burden pass
through neither into premiums nor through them, so that burden sits outside the priced insurance
contract. The unpriced margin is not a general failure to see climate in the data; it is
specifically the cold- and drought-driven health-cost incidence that the individual market never
reprices.

*Caveats.* The mediation is a difference-method decomposition rather than a causally identified
mediation: the premium is itself an outcome of the shock, so the split into mediated and direct
components assumes no premium-debt confounding conditional on the county and year fixed effects.
Premiums enter at the rating-area level, so the mediated share is a lower bound on any true
county-level premium channel. The premium series begins in 2014 with the ACA marketplaces, so both
equations run on the 2014–2023 window (about 23,600 county-years); the base debt coefficients here
are larger than the full-panel headlines because they are estimated on that later, marketplace-era
sample, and it is the surviving *fraction*—invariant to the sample—that carries the mediation
conclusion. The negative cold pass-through coefficient is reported for completeness but not
interpreted as a premium response.
