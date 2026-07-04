# Premium Pass-through and the Debt Channel

*Draft section fragment for Essay 1 (Incidence). NBER style. Generated from
`Code/run_premium_mediation.R`; results in `Analysis/mediation/`.*

The proposal set out to estimate two objects the reduced form leaves implicit: the rate at which
climate shocks pass through into health-insurance premiums, and the extent to which the medical debt
that follows a shock is the downstream trace of those higher premiums. Both are recoverable from the
county panel, and together they locate where in the insurance system a weather shock becomes a
household liability.

Premiums absorb part of the claims that a cold shock generates. In counties that experience an
extreme-cold year, the benchmark silver premium rises by about \$28 per month, roughly 7 percent of
the \$375 sample-average benchmark, and the estimate is precise under both state clustering
(*p* = 0.008) and rating-area clustering (*p* < 0.001). The lowest-cost bronze premium moves
similarly (about \$20 per month). Heat passes through with a two-year lag of comparable size (about
\$21 per month, *p* = 0.01 under rating-area clustering), consistent with the rate-setting cycle
translating a realized morbidity surge into the following cycle's rates. The pass-through is
uneven across hazards: extreme drought raises the benchmark premium by an imprecise \$14 per month
(*p* = 0.27), so the premium response to climate is concentrated in the temperature hazards that most
clearly raise medical claims rather than a uniform repricing of environmental risk. Because premiums
are set at the rating-area level, these are pass-through rates onto a price that many counties share;
they should be read as the insurer-side response to shocks realized somewhere in the rating area.

Whether that pass-through is what carries the debt is a separate question, and the answer is largely
no. Re-estimating the shock-to-debt relationships with and without contemporaneous and lagged
benchmark premiums on the identical sample, the debt effects are almost untouched by premium
adjustment. Of the cold-driven increase in the medical-debt share at a one-year lag, 93 percent
survives the addition of premium controls; of the two-year drought effect, 99 percent survives. The
premium-mediated portion is on the order of a twentieth to a hundredth of each effect. The medical
debt that accumulates after a shock therefore does not arrive mainly through repriced insurance; it
accumulates through the more direct route of out-of-pocket costs and lost income landing on
household balance sheets, the same real-economy channel the income and employment results trace.

Read together, the two estimates sharpen the dissertation's claim of an unpriced margin. Insurers do
move premiums in response to the temperature shocks that raise claims, and by a non-trivial amount,
so the environmental signal is not invisible to the market. But the premium adjustment is partial
across hazards and, where it occurs, it does not account for the debt households take on — so the
burden that the reduced form measures sits predominantly outside the priced insurance contract.

*Caveats.* This is a difference-method decomposition rather than a causally identified mediation:
the premium is itself an outcome of the shock, so the split into mediated and direct components
assumes no premium-debt confounding conditional on the county and year fixed effects. Premiums enter
at the rating-area level, so the mediated share is a lower bound on any true county-level premium
channel. The premium series begins in 2014 with the ACA marketplaces, so this decomposition runs on
the 2014–2023 window (about 23,600 county-years); the base debt coefficients here are larger than the
full-panel headlines because they are estimated on that later, marketplace-era sample, and it is the
surviving *fraction*—invariant to the sample—that carries the mediation conclusion.
