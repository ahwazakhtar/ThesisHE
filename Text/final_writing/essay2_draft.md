# Essay 2 - Scarring and Compounding: The Dynamic Economic Costs of Recurring Climate Exposure

<!-- Assembled from essay2_harness.html on 2026-08-18. Unedited paragraphs still carry the SUGGESTED text - rewrite before freezing. -->

## Abstract

Whether a changing climate raises costs over the long run depends on what happens once a shock ends: whether the damage reverses, leaves a one-time scar, or compounds as shocks recur. Using a U.S. county panel from 2011 to 2023, I decompose each climate shock into onset, persistence, and exit; test whether entering and leaving a shock offset one another; and estimate how outcomes respond to accumulated shock-years, checking the results against a staggered event-study estimator. The dynamics are shock-specific. Drought debt scars: the two-year onset-exit asymmetry in the medical-debt share is +0.019 (p < 0.001), about 45 percent of a typical annual movement. This is a scar that fades by the fourth year after exit and partly reflects out-migration. Cold, on the other hand, compounds: counties at 10+ cumulative cold-years have employment roughly 5,500 lower than counties having 1-3 years of exposure, and the gap approaches 5,000 jobs a decade after onset in the event study. Heat saturates into a level difference, and chronic extreme drought is extremely rare. The horizon over which climate raises costs is itself hazard-specific, so single-year exposure measures understate the burden of recurring cold.

## 1 Introduction

Whether a changing climate raises health and economic costs over the long run depends less on any single bad year than on what happens after it. When the drought breaks or the cold season ends, the damage may reverse, it may leave a one-time scar, or as shocks recur it may compound.

A large literature measures the contemporaneous and short-lag effects of temperature and drought on output and health (Dell, Jones, and Olken, 2014), with a smaller strand on the persistence of local shocks (Hsiang and Jina, 2014; Deryugina, Kawano, and Levitt, 2018). Much less is known about adjustment: whether the same shock's effects unwind on exit, and whether recurrence raises the marginal harm. This essay provides that evidence for heat, cold, and drought.

Using a U.S. county panel from 2011 to 2023, I decompose each climate shock into its onset, its persistence, and its exit; test whether entering and leaving a shock offset one another, which I take as the operational definition of reversibility; estimate how outcomes respond to the cumulative number of shock-years a county has accumulated; and check the dose results against a staggered event-study estimator. The estimands are built to distinguish four adjustment regimes: reversal, scarring, saturation, and compounding.

The dynamics are shock-specific. Drought debt scars: the two-year onset-exit asymmetry in the medical-debt share is +0.019 (p < 0.001), about 45 percent of a typical annual movement. This is a scar that fades by the fourth year after exit and partly reflects out-migration. Cold, on the other hand, compounds: counties at 10+ cumulative cold-years have employment roughly 5,500 lower than counties having 1-3 years of exposure, and the gap approaches 5,000 jobs a decade after onset in the event study. Heat saturates into a level difference, and chronic extreme drought is extremely rare. The horizon over which climate raises costs is itself hazard-specific, so single-year exposure measures understate the burden of recurring cold.

This essay turns the informal language of scarring and compounding into operational estimands of symmetry tests, dose contrasts, and event-study gaps, and applies it uniformly across hazards in one unified panel. Section 2 explains why persistence matters; Section 3 sets out the transition framework and estimands; Section 4 summarizes the data and exposure support. Sections 5 through 7 report the symmetry, cumulative-dose, and long-run results; Section 8 examines migration and composition; Section 9 interprets the results by hazard; Section 10 concludes.

## 2 Why persistence matters

The welfare cost of a climate shock depends on what happens after it ends. A loss that reverses within a year and an equal-sized loss that persists have very different discounted burdens, and a shock whose marginal harm grows with recurrence is a different policy object from one whose costs arrive once. Further, if repeated exposure compounds, counties facing recurring hazards face rising marginal damages, and adaptation capital there pays a growing dividend. If effects saturate, the gap is a fixed level difference, and the policy question shifts toward transfers and insurance for the exposed geographies rather than protection against the next marginal year. Lastly, persistence also matters for measurement. Contemporaneous exposure metrics - this year's shock against this year's outcome - understate hazards whose harm accumulates across years. [CITE: Dell, Jones, and Olken (2012)]

## 3 Transition framework and estimands

I define four different types of adjustment that take place after a climate shock. Under "reversal", exit offsets onset and the shock leaves no lasting mark. Under "scarring", exit fails to offset onset and a gap remains after the shock ends. Under "saturation", effects persist at a level but do not grow with additional exposure. Under "compounding", the marginal harm grows as exposure recurs. Figure E2-F1 illustrates the four paths.

I decompose each hazard into onset, persistence, and exit indicators and test symmetry - whether the onset and exit coefficients sum to zero - as the operational definition of reversibility. A rejected symmetry test with a same-signed sum is scarring. Local projections then trace the post-exit path, which is what distinguishes a transient scar from a permanent one. [CITE: Jordà (2005)]

$$
Y_{it} \;=\; \alpha_i \;+\; \gamma_t \;+\; \beta^{\mathrm{on}} O_{it}
\;+\; \beta^{\mathrm{pe}} R_{it} \;+\; \beta^{\mathrm{ex}} E_{it} \;+\; \varepsilon_{it},
\qquad H_0:\; \beta^{\mathrm{on}} + \beta^{\mathrm{ex}} = 0
%%transition
$$

Cumulative-dose estimands separate saturation from compounding: binned contrasts across accumulated shock-years and a smooth quadratic in dose. If effects saturate, high-dose and mid-dose counties look alike; if they compound, the gap grows with accumulated years. I interpret these as within-county exposure-history contrasts throughout.

$$
Y_{it} \;=\; \alpha_i \;+\; \gamma_t \;+\; \sum_{b} \phi_b \,
\mathbf{1}\{C_{it} \in b\} \;+\; \varepsilon_{it},
\qquad C_{it} \;=\; \sum_{\tau \le t} S_{i\tau}
%%dose
$$

Finally, staggered event-study estimates in the Callaway and Sant'Anna (2021) framework compare treated cohorts with not-yet-treated and never-treated counties over a decade of event time. These provide the long-run complement to the transition estimates, and emerge from an estimator built for staggered adoption.

## 4 Data and recurring exposure

The panel, shock definitions, and estimation conventions follow the first essay. Briefly: a county-year panel over 2011–2023 covering roughly 3,100 counties; four binary shock bins - heat and cold marked by national 80th-percentile degree-day cutoffs from a 1990–2000 pre-study baseline, extreme drought by an absolute Palmer threshold, and poor air quality by the EPA exceedance level; county and year fixed effects; and state-clustered standard errors. The first essay's Appendix B shows the definitions are robust to longer baseline horizons and to the choice of estimation horizon.

Table E2-T1 reports the transition support over 2011–2023. Drought is episodic in the data: 511 onset transitions and 705 exits against only 175 persisting county-years, across 603 counties ever exposed. Therefore, episodes begin and end quickly, and chronic extreme drought is rare: persisting spells are 0.5 percent of county-years, against 2.3 percent for any extreme-drought year. Heat and cold are different: 903 and 1,032 onsets sit alongside 8,125 and 5,485 persisting county-years, so exposure recurs and accumulates which is the variation the cumulative-dose estimates use. The transition regressions run on roughly 27,000 to 34,000 county-years, depending on outcome and horizon.

## 5 Onset–exit symmetry results

The symmetry test asks whether leaving a shock undoes what entering it did. For heat and cold employment the onset and exit coefficients offset; for drought and the credit-bureau debt share they do not. At a two-year horizon their sum - the asymmetry - is +0.019 (p < 0.001; Table E2-T3), so the recorded debt share does not return to its pre-shock path within the horizon the test reaches. What follows is a statement about a ledger rather than a welfare measure: bureau debt records hardship only after an insurance relationship, a billed encounter, and a credit file, and the third essay shows the recorded response is weakest where coverage is thinnest. Part of the persistence is compositional, since drought raises net outflows the following year, so the estimate bounds same-population persistence rather than measuring it. The asymmetry survives a sharpened multiple-testing correction at q < 0.05, remains significant under no, lagged, and contemporaneous control sets estimated on the identical sample (p < 0.001 in each), though the point estimate moves between 0.019 and 0.025, and 99 percent of the lag-2 drought-debt coefficient survives premium adjustment.

The scar is large relative to how much the series normally moves. Scaled by the mean absolute deviation of year-to-year changes in the county's debt share, the two-year asymmetry equals about 72 percent of a typical annual movement. It is also approximately 10 percent of the mean debt share of ~19 percent. Extending the local-projection horizon shows the drought impulse fading by the fourth year. At the three-year horizon, the furthest the symmetry test reaches, the asymmetry remains significant (+0.015, p = 0.039). Table E2-T3 reports symmetry tests for the full grid of hazards and outcomes.

## 6 Cumulative-dose results

Cumulative dose asks whether the marginal cold year hurts more as a county's exposure history accumulates - a different question from whether a single episode unwinds. I count the cold-shock years each county has accumulated over the panel and compare outcomes across accumulated doses, using a binned contrast - ten or more cumulative cold-years versus one to three - and a smooth quadratic dose term, with county and year fixed effects throughout.

In the unweighted binned contrast, a county at ten or more cumulative cold-years has employment 5,522 lower than a county at one to three (SE 1,196, p = <0.01) - about 11 percent of mean county employment of 48,068. The population-weighted contrast is far larger (−41,573, p = 0.005), reflecting the weight of large counties in levels-based outcomes. The smooth quadratic dose term implies a marginal-effect difference between the tenth and first cold-year of +417 - flat and statistically insignificant. The binned estimator survives humidity adjustment, an adjustment for population aging, the stricter 90th-percentile definition of extreme cold, and all three control variants estimated on the identical sample (p < 0.001 in each).

## 7 Long-run and recurring-treatment comparisons

A staggered difference-in-differences in the Callaway and Sant'Anna (2021) framework traces the employment gap in event time. Employment in cold-treated counties is 4,982 lower a decade after onset (p = 0.003), and the gap compounds  with time from roughly 150 in the onset year to 2,600 at five years and 4,900 at ten. The decade-out estimate rests on a single pre-year by construction; pooling the available pre-period leaves it essentially unchanged (−4,990, p = 0.005). The medical-debt share is also higher a decade after onset, but that gap is flat through 2022 and appears entirely in 2023, the year credit-bureau medical-debt reporting rules changed, so I do not read it as compounding evidence and note it only with that caveat.

Horizon choices do not drive these verdicts. Extending estimation horizons change the short-horizon estimates by less than one standard error, and cold employment losses persist at three- and four-year horizons in local projections (p = 0.009 and 0.006). Only shortening matters: truncating the horizon at two years understates cold compounding.

Heat behaves differently. Its cumulative-dose profile shows no negative gradient - the binned ten-plus versus one-to-three contrast is +4,460 jobs (p = 0.06), against cold's −5,522 (Figure E2-F4) - so heat's persistent gap is a level difference rather than one that grows with accumulated exposure (saturation). Chronic extreme drought, by contrast, is too rare in the panel to estimate a dose response at all - only 175 persisting county-years against 511 onsets - so drought in these data is episodic, which is why its dynamics were examined through onset and exit rather than accumulation.

## 8 Migration, composition, and survivorship

Some of the persistence has a demographic component. IRS county-to-county migration flows show drought lowering the net in-migration rate by 0.21 percentage points the following year (p = 0.047) - that is, raising net outflows. I read this as a bounded, suggestive contributor to the drought scar rather than a decomposition of it. [CITE: Mullins and Bharadwaj (2021)] Part of the persistent debt gap may therefore be composition as households that remain differ in characteristics from those who left. The same logic applies to the long-run cold gaps, for two further reasons. First, the compounding estimate is not invariant to how counties are weighted, as Section 7 sets out. Second, the Callaway-Sant'Anna aggregation does not hold the treated population fixed as event time lengthens: the admissible cold-onset cohorts are 2013 (171 counties) and 2014 (59 counties), and because the panel ends in 2023, only the 2013 cohort has ten years of post-onset data to contribute an event-time-10 estimate — a county onsetting in 2014 drops out of that average by construction.

## 9 Interpretation by hazard

The dynamics are hazard-specific. Drought is episodic: its recorded-debt scar is real at a two-year horizon, fades by the fourth year, and is partly compositional. Cold compounds under the binned cumulative-dose contrast and the staggered event-study estimator with employment gaps that widen a decade after onset. Heat saturates into a level difference that does not grow with additional exposure.

It follows that the policy-relevant horizon is itself hazard-specific. Single-year exposure measures understate the burden of recurring cold, while long averages dilute the episodic sharpness of drought. Adaptation targeting inherits the same logic: compounding favors protecting counties with recurring exposure before the next marginal year arrives, while saturation favors supporting the already-exposed stock.

## 10 Conclusion

This essay asked what happens when a climate shock ends or recurs: whether its economic effects reverse, scar, saturate, or compound. The answers are hazard-specific. Drought debt scars - a two-year onset-exit asymmetry of +0.019, about 45 percent of a typical annual movement in the debt share, fading by the fourth year after exit. Cold employment compounds, with a binned cumulative-dose gap of roughly 5,500 jobs and an event-study gap of roughly 5,000 a decade after onset. Heat saturates into a level difference.

The broader implication is about measurement. Because the horizon over which climate raises costs is hazard-specific, exposure measures that stop at the current year systematically understate recurring hazards. Longer panels and working-age administrative data would extend the horizons these tests can reach.