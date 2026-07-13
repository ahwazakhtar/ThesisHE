# The Costs in Context: A Sufficient-Statistics Policy Synthesis

*Integrated policy synthesis for the general conclusion. Every magnitude in this
section traces to a certified coefficient in `Plans/master_evidence_table.md` and to the
numeric hand-off in `Analysis/policy/sufficient_stats_summary.md`; the underlying rows
are in `Analysis/policy/sufficient_stats.csv` and `Analysis/policy/concentration_curve.csv`.
No coefficient in this section was estimated here — the exercise translates results the
preceding essays already established.*

---

## Purpose: a bounded translation instead of a structural model

The three essays estimate what climate shocks cost, how those costs persist, and where
they land. A reader arriving from a policy office will ask the natural next question: how
large are these costs in dollars, jobs, and people, and where should scarce adaptation or
insurance resources go? The dissertation proposal answered that question with a
semi-structural microsimulation — rating-area-by-income-bin subsidy counterfactuals,
welfare accounting, and an efficiency–equity frontier calibrated on California. I do not
build that model here. A microsimulation of this kind would require behavioral and
distributional parameters the reduced-form estimates do not identify, and its headline
numbers would inherit whatever those imposed parameters assumed. The credibility the
empirical chapters earn through careful identification would be spent on a modeling layer
the data cannot discipline.

I therefore replace it with a sufficient-statistics exercise, in the sense public economics
gives the term: rather than recover deep structural parameters and then compute welfare, I
carry the already-estimated reduced-form effects, and nothing else, into policy-relevant
magnitudes.[^suffstat] Each magnitude is a certified coefficient multiplied by an exposed
count, carrying that coefficient's own confidence interval forward by the delta method (or,
for the headline income event, its certified wild-cluster bootstrap interval). This buys
honesty at the price of ambition. I cannot report a single national welfare loss, and I do
not try to; what I can report is a small set of transparent scenario bands, each tied to one
estimand, one population, and one unit, with its uncertainty attached.

The exercise is deliberately conservative in two further respects. First, every coefficient
it uses is one the preceding essays already certified against the frozen evidence table — the
computation re-verified all twelve of them against their frozen values before producing a
number — so the bands introduce no new estimate and inherit no new specification search.
Second, the exercise keeps the two sources of uncertainty separate: it carries the statistical
uncertainty in each estimated coefficient explicitly into every band, and it treats the exposed
counts as fixed at their observed values, so a reader can see that the reported intervals are
coefficient intervals and not a composite of estimation and sampling noise. The remainder of this section states the one strong
institutional claim the pricing evidence licenses, presents the scenario bands and explains why
they must never be added together, shows where the burden concentrates, closes with a comparison
to the federal transfers that already exist for the crop side of drought, and ends by stating
plainly what the exercise does not do.

[^suffstat]: The sufficient-statistics approach to welfare and policy analysis — using reduced-form
elasticities and estimated responses in place of a fully specified structural model — is standard in
modern public economics (Chetty 2009, "Sufficient Statistics for Welfare Analysis: A Bridge Between
Structural and Reduced-Form Methods," *Annual Review of Economics* 1: 451–488).

## The unpriced margin as an institutional null

The pricing evidence delivers an institutional finding about what a regulated insurance
market records in its local prices. The individual ACA market shows no coherent local
pass-through of these climate-health shocks. The estimated
premium responses flip sign as the geographic unit changes — negative at the county level,
positive at the rating-area level, negative again at the state level — so there is no stable
local premium-lag response to scale into a mispricing figure (evidence table Row 8). I do
not manufacture one. The unpriced margin is reported as an institutional null and as a
bounded floor, and I decline to convert it into a mispricing dollar total precisely because
the stable pass-through coefficient such a total would require does not exist.

The floor can nonetheless be bounded, and for one hazard the bound is strong. The
directly-measured Medicare morbidity cost of extreme heat provides a yardstick for what a
"morbidity-scale" cost looks like: $112 per beneficiary-year contemporaneously and $177 at
a one-year lag (Row 10), which expressed per member-month is $9.33 to $14.75 PMPM. Against
that yardstick, the completed pass-through analysis yields a certified drought equivalence
bound of δ\* = $7.40 PMPM (Row 8) — the largest local premium response the drought data are
statistically consistent with. Because $7.40 is between 50 and 79 percent of the
$9.33–$14.75 benchmark, the data rule out drought pass-through above roughly one-half to
four-fifths of a morbidity-scale cost. The complement is a provable floor: for drought, at
least 21 to 50 percent of a morbidity-scale cost — at least $1.93 to $7.35 PMPM, or roughly
$23 to $88 per member-year — cannot be flowing through local premiums.

The bound δ\* is an equivalence-test object, and reading it correctly matters for the strength
of the claim. It is the smallest pass-through the drought premium data are consistent with at
the top of the rejection region — the largest true local response that the data would fail to
distinguish from the estimate — so a true pass-through above δ\* is statistically rejected. A
conventional test that fails to reject zero would establish only that the data are uninformative;
an equivalence test that rejects everything above $7.40 PMPM establishes something stronger, that
whatever the true local drought pass-through is, it is smaller than a fixed fraction of the
morbidity cost. That is why the drought floor is a genuine finding and not merely an imprecisely
estimated null.

This strong claim is licensed for drought only. For heat and cold, the analogous
equivalence bounds (δ\* ≈ $24.6 and $22.0 PMPM) exceed the morbidity benchmark, so
equivalence with full pass-through cannot be rejected; the most I can say for those hazards
is that within-state premium responses are bounded at roughly 5 to 8 percent of the $366
mean monthly premium, and not tightly. There is no universal equivalence bound here, and no
blanket statement that regulated pricing leaves all climate costs unpriced. The claim is
hazard-specific by construction.

The institutional mechanics of the ACA individual market predict exactly this pattern. Each
state operates as a single statewide risk pool. Geographic rating within a state is
permitted only for differences in unit cost, not for differences in local morbidity, so a
county whose population grows sicker after a drought cannot see that morbidity reflected in
its own premiums. And the federal Part 153 risk-adjustment program transfers funds among
insurers within a state to offset differences in enrolled risk, further muting any local
signal. A market built this way should not price a localized health shock into local
premiums, and the sign-flipping coefficients are what that non-pricing looks like in the
data. The policy content of the null is therefore institutional. When morbidity rises in a
place, the individual market does not record that fact in that place's price; a mechanism
that assumes premiums will surface climate-health costs where they occur is assuming
something the market's own rules forbid.

This reframes the original proposal's premium-subsidy question. A subsidy program designed to
correct a local mispricing of climate risk presumes that a mispricing signal exists in local
premiums to be corrected. For drought, the pricing evidence says a morbidity-scale cost is
demonstrably absent from that signal, and the institutional rules explain why it would be; a
place-based premium instrument keyed to the local price would find no coherent signal to act on.
The margin that goes unpriced is real and, for drought, bounded from below, but it surfaces as a
gap between a directly-measured morbidity cost and a flat local price, not as a premium
coefficient a subsidy formula could invert. Any policy response to it has to be built on the
directly-measured cost, because that is the ledger in which the cost is actually recorded.

## Scenario bands: five magnitudes, each standing alone

Table P1 collects the five scenario bands. Each row is a self-contained calculation: one
estimand, one population, one unit, one interval. They are ordered from the sharpest causal
design to the most measurement-fragile, and they are deliberately expressed in different
units — dollars, jobs, and people — because they measure different things. The bands are
never summed and never averaged; the reasons are given after the table and are essential to
reading it correctly.

The interval on each band is a coefficient interval carried forward, and it is worth being
explicit about what it does and does not contain. For every band except the 2012 event I take
the estimated per-unit coefficient and its standard error and propagate them to the aggregate
by the delta method, so the reported band widens in exact proportion to the statistical
uncertainty in the underlying regression coefficient. For the 2012 income event I use the
certified wild-cluster bootstrap interval rather than an analytic one, because that event is
identified off a small number of treated clusters and the bootstrap interval is the inference
the essay defends. In every case the exposed count is held at its observed value; I do not add
a sampling distribution for the number of exposed people or counties on top of the coefficient
uncertainty. The bands are therefore honest about estimation error in the effect and silent
about second-order uncertainty in the exposure base, and they should be read as ranges on the
effect, applied to a fixed and known population, rather than as full predictive intervals.

**Table P1. Sufficient-statistics scenario bands.** *(Source rows in
`Analysis/policy/sufficient_stats.csv`; dollar figures from the panel's real series are
CPI-deflated to 2023 dollars; Medicare figures are CMS price-standardized dollars.)*

| Band | Estimand (short) | Point | 95% band | Per-unit coefficient | Exposed count |
|---|---|---|---|---|---|
| 2012-style drought event, income | Event-specific ITT of first drought onset; not annualizable | −$7.09B | [−$15.75B, −$0.75B] | −$1,311 / capita | 5,410,588 people (139 counties) |
| &nbsp;&nbsp;*(doubly-robust alternative)* | Same event, DRDID estimator; strengthens | −$7.85B | [−$13.32B, −$2.39B] | −$1,451 / capita | *(same)* |
| Typical recurring drought year, income | Multi-cohort ITT at onset (frontier CS-dr, e=0); **bounded null** | −$5.08B | [−$13.55B, +$3.39B] | −$324 / capita | 15,665,133 people |
| Cold cumulative employment gap | Within-county exposure-history contrast (10+ vs 1–3 cumulative cold-years) | −2.39M jobs | [−3.40M, −1.37M] | −5,522 jobs / county | 432 counties |
| Drought debt scar | Onset/exit asymmetry (h=2); measurement-fragile; directional lower bound | 1.29M people | [0.54M, 2.04M] | +0.01874 share / episode | 68.9M resident (UB); 47.2M credit-visible |
| Direct Medicare morbidity (heat, contemporaneous) | Administrative burden, 65+/disabled; parallel direct evidence | $1.87B / yr | [$0.44B, $3.30B] | $112 / beneficiary-yr | 16,744,857 beneficiaries |

*Companion Medicare bands (same estimand): heat at a one-year lag, $2.94B/yr [$1.23B,
$4.65B] at $176/beneficiary-year; cold at a two-year lag, $0.39B/yr [$0.11B, $0.67B] at
$87/beneficiary-year.*

### The 2012-style drought event

The 2012 drought event reduced per-capita income by $1,311 in first-onset counties relative
to never-exposed counties (Row 1). Applied to the 5.4 million residents of the 139 treated
counties, that per-capita loss aggregates to $7.09 billion for the event, with a certified
wild-cluster bootstrap interval of [−$15.75B, −$0.75B]. The doubly-robust estimator gives a
somewhat larger per-capita effect (−$1,451, aggregating to $7.85 billion) with a tighter
interval that excludes zero more decisively; I report it as a robustness point that
strengthens the headline, and it is not a second, independent band to be counted alongside
the first. This is the estimand a policymaker should keep in view when a single severe drought
lands on a specific set of counties: it is the cost of one event, with the observed design and
the observed treated geography. It is an intention-to-treat effect of first onset, it is not
annualizable, and it is not a general drought-response function. The next band shows that this
qualifier is itself an empirical finding.

### The typical recurring drought year

Extending the same design to every drought cohort and reading the immediate (event-time
zero) response gives a per-capita point estimate of −$324, which across the 15.7 million
people in an average drought year aggregates to −$5.08 billion — but with a 95 percent band
of [−$13.55B, +$3.39B] that comfortably spans zero. The long-run pooled average is if
anything slightly positive (+$350 per capita) and also indistinguishable from zero. I
present this bounded null as a finding about generalization. A typical drought year's income
effect is bounded near zero, while a 2012-scale event is not; the sharp $1,311 loss is a
property of that event and its treated geography, and it does not license a claim that
drought in general moves local income by an amount of that magnitude. Reading the wide,
zero-spanning band as an embarrassment would invert its meaning. It is the quantitative
statement that the headline result is event-specific, and it is what keeps the 2012 number
from being misused as a national annual drought cost.

### The cold cumulative employment gap

The counties that have accumulated ten or more cold-shock years carry a standing employment
gap of about 5,522 jobs each relative to counties with only one to three such years (Row 17).
Across the 432 counties that have reached the 10+ threshold, that per-county gap aggregates
to roughly 2.39 million jobs, with a band of [−3.40M, −1.37M]. Two disclosures travel with
this band. First, the estimand is a within-county exposure-history contrast, not the
marginal causal effect of exogenously assigned shock-years; it compares counties with long
against short cold-exposure histories, and long-history counties may differ in ways the
fixed effects do not fully absorb. Second, the magnitude is estimator-dependent. The binned
contrast and the staggered event study support compounding — the latter shows the gap
widening to about 5,000 jobs a decade after onset — while the smooth quadratic dose term is
flat. I cite the binned contrast and the event study, disclose the flat quadratic, and treat
this as a scenario range that particular estimators support rather than an estimator-invariant
law.

### The drought debt scar

Medical debt accrued during a drought does not fully unwind when the drought ends: the
onset/exit asymmetry at a two-year horizon is +0.0187 (p = 0.0015), a scar that survives
multiplicity correction and premium adjustment (Row 16). Translating the per-episode share
into people requires a credit-visible population base, which is not directly available.
Using total resident population across the 603 ever-drought counties as an upper-bound
denominator gives about 1.29 million additional people carrying medical debt in collections,
with a band of [0.54M, 2.04M]; applying a documented credit-visibility adjustment (×0.685)
gives about 884,000 [0.37M, 1.40M]. Both figures come with the standing caveat that
credit-bureau medical debt is measurement-fragile: it requires an insured, billed encounter
and an open credit file to appear at all, and its response reverses sign across geographic
scales. The count is best read as a directional lower bound on the number of people affected,
because out-migration from drought counties and selection into credit visibility both remove
affected people from the measure. I report this band because persistence is a genuine policy
concern, and I attach every measurement caveat to it directly; I do not lead the synthesis with
it.

### The direct Medicare morbidity band

Extreme heat raises standardized Medicare spending by $112 per beneficiary-year
contemporaneously (Row 10). Across the 16.7 million beneficiaries in heat-shock county-years,
that is $1.87 billion per year, with a band of [$0.44B, $3.30B]; the one-year-lag response is
larger ($176 per beneficiary-year, $2.94 billion), and cold contributes a smaller two-year-lag
band ($87 per beneficiary-year, $0.39 billion). This band provides separate direct evidence of
a morbidity and utilization channel for the 65-and-over and disabled Medicare population over
2014–2023, reproducing the Deryugina et al. (2019) utilization result in this panel. It is a parallel
administrative burden measured directly in claims; it is not mediation of the 2012 drought
income loss, and I do not present it as a demonstrated chain into working-age household debt,
because it describes a different population entirely.

### Why the bands must not be summed

The bands measure different populations, in different units, under different estimands, over
different time bases, and adding them would be an arithmetic error dressed as a total. The
populations overlap and would be double-counted: drought-exposed residents appear in the
income band, the debt band, and — where they are elderly — the Medicare band. The units are
incommensurable: an event-level dollar loss, a standing count of jobs, a count of people with
a debt tradeline, and an annual claims flow do not share a denominator, and no social welfare
function that would convert them into one is identified here. The time bases differ: the 2012
income figure is the cost of a single event, the Medicare figures are per-year flows, and the
cold employment figure is a standing gap relative to a comparison group. Most fundamentally,
the estimands are not the same object — one is a sharp event-specific ITT, one is a bounded
null, one is an exposure-history contrast, one is a measurement-fragile asymmetry, and one is
a direct administrative response. Averaging incompatible estimands or summing incommensurable
units would produce a single confident number with no defensible interpretation, which is the
outcome the sufficient-statistics discipline exists to prevent. Each band should be read, and
cited, on its own.

## Where the burden concentrates

A policymaker's second question is where these costs land, and whether targeting resources by
place would capture a disproportionate share of the burden. Table P2 and Figure P1 answer this
descriptively, ranking each band's burden-bearing counties from most to least vulnerable — where
vulnerability is the mean of standardized CDC social-vulnerability and DOE energy-burden indices —
and reporting the cumulative burden share held by the top decile and top quintile of counties.
These are descriptive concentration shares, not causal welfare weights; the separate finding that
climate harm is *amplified* in high-vulnerability counties (the shock × SVI interaction, Row 20)
is deliberately not folded into these aggregates, which use a uniform coefficient within each band.

Keeping the two apart is deliberate, and the distinction is easy to blur. The concentration table asks a mechanical accounting question — given a single
per-unit effect applied everywhere, what share of the resulting burden falls on vulnerable places
simply because of how exposure and population are distributed across the vulnerability ranking? The
amplification result asks a different, causal question — is the per-unit effect itself larger where
vulnerability is higher? Folding the amplification gradient into these aggregates would let a place
count twice, once for holding more of the exposed population and again for a larger estimated effect,
and would convert a descriptive burden share into an implicit welfare weight the design does not
support. I therefore report the concentration shares under a uniform coefficient and leave the
amplification finding to stand on its own in the distributional essay, where it is estimated and
defended as a heterogeneous marginal effect. A reader who wants the full distributional picture
should hold both in view: vulnerable counties bear a disproportionate share of the per-county and
beneficiary burdens shown here, and, separately, the per-capita effects themselves run larger in
high-vulnerability places for income, employment, and premiums.

**Table P2. Burden concentration by county vulnerability.** *(Cumulative shares; data in
`Analysis/policy/concentration_curve.csv`. "Burden" is the share of the band's total burden borne
by the most-vulnerable counties; "pop" is those counties' share of the band's population.)*

| Band | Top-decile burden / pop | Top-quintile burden / pop |
|---|---|---|
| 2012 drought income | 0.035 / 0.035 | 0.075 / 0.075 |
| Drought debt scar | 0.015 / 0.015 | 0.032 / 0.032 |
| Cold cumulative employment | 0.102 / 0.042 | 0.201 / 0.107 |
| Heat Medicare (annual) | 0.021 / 0.017 | 0.043 / 0.036 |
| Cold Medicare (annual) | 0.048 / 0.023 | 0.128 / 0.089 |
| Heat exposure (person-years, descriptive) | 0.029 / 0.017 | 0.097 / 0.057 |

The honest reading of this table begins with what does *not* concentrate. For the income and
debt-scar bands, the per-capita coefficient is uniform across counties, so within-band burden
mechanically tracks population: the most-vulnerable decile bears 3.5 percent of the 2012 income
burden and holds 3.5 percent of the population, and the debt-scar shares match at 1.5 percent.
For these two bands, a vulnerability-targeted map is essentially a population map, and claiming
otherwise would misrepresent the calculation. Targeting the per-capita bands by vulnerability
adds little beyond targeting by population.

The genuine concentration is in the per-county cold employment band and, more modestly, in the
beneficiary bands. Because the cold employment burden is a fixed job gap per qualifying county
and the counties that have accumulated long cold-exposure histories skew toward more-vulnerable
places, the most-vulnerable decile bears 10.2 percent of the standing employment gap while
holding only 4.2 percent of the band's population — about 2.4 times its population share — and
the top quintile bears 20.1 percent against a 10.7 percent population share. The Medicare bands
concentrate similarly if less sharply: the most-vulnerable decile of cold-Medicare counties
bears 4.8 percent of that burden against a 2.3 percent population share (about 2.1 times). Figure
P1 plots the full concentration curves; the cold-employment curve bows visibly above the
45-degree line while the income and debt curves lie on it. The targeting statement the reduced
form supports is therefore specific: place-based targeting captures a disproportionate share of
the burden for the per-county exposure-history and beneficiary bands, where vulnerable counties
carry roughly twice their population share, but not for the per-capita income and debt bands,
where burden and population coincide.

**Figure P1. Burden-concentration (Lorenz-style) curves: cumulative population share versus
cumulative burden share, by band.** *(Data in `Analysis/policy/concentration_curve.csv`, 6,109
rows; the 45-degree line marks proportional-to-population burden.)*

## A benchmark from existing federal transfers

Federal transfers already flow to these counties for the crop side of drought, which makes them
a natural benchmark for the scale of the health-finance side. Over 2012–2023, USDA Risk
Management Agency crop-insurance indemnities paid the 139 treated counties $1.92 billion in
drought-specific indemnities (and $5.48 billion across all perils). The single 2012 event's local
per-capita income loss, at $7.09 billion, is 3.7 times the twelve-year drought-indemnity flow to
the same counties, 1.29 times the all-peril flow, and 10.4 times the $681 million drought crop
payout in 2012 alone.

The comparison carries a unit caveat that must be stated whenever the ratio is used. The income
loss is an event-level intention-to-treat effect — a per-capita coefficient multiplied by
population for one event — while the RMA figure is a multi-year realized dollar flow, and the two
compensate different margins: crop indemnities replace lost farm revenue, whereas the DiD measures
the broader local per-capita income margin. This is a framing contrast about relative orders of
magnitude, not a like-for-like net position or a claim that RMA "should" cover the gap. Read with
that caveat, it locates the health-finance incidence of a single drought at several times the
scale of the established federal transfer for that same drought's crop losses in the same places —
which is the reduced-form answer to the proposal's original question about where a subsidy or
transfer program aimed at climate risk would find under-addressed exposure.

The value of the RMA benchmark is that it supplies a scale a policy reader already trusts. Federal
crop insurance is a mature, congressionally-funded program with a known annual outlay, so anchoring
the health-finance incidence to it converts an abstract $7 billion into a concrete multiple of a
transfer whose order of magnitude is a settled fact. It also identifies the shape of the gap: the
existing federal instrument for drought is organized around the agricultural margin, while the local
per-capita income margin the dissertation measures is broader than agriculture and, in this event,
several times larger than the crop transfer directed at the same counties. I stop short of a
normative recommendation, because the estimand is a single event and the comparison is a
scale contrast rather than a benefit-cost account. What the comparison licenses is the observation
that the health-finance incidence of drought is large relative to the transfer infrastructure that
currently exists for drought, and that this incidence falls on a margin that infrastructure was not
built to reach.

## What this synthesis does not do

The discipline of the exercise is as much in what it withholds as in what it reports.

It reports no welfare total. The bands are in incompatible units and are governed by no common
social welfare function, so there is no defensible way to collapse dollars, jobs, people, and
claims flows into a single figure, and I do not.

It reports no national causal aggregate. Every band is confined to its estimated population and
geography; the 2012 event is event-specific and does not generalize, as the bounded typical-recurring
null makes explicit, so scaling any band to the nation would assign a coefficient to counties whose
data never entered it.

It reports no premium-coefficient aggregation. There is no stable local pass-through coefficient to
multiply by enrollment — the coefficients flip sign across geographic levels — so the unpriced margin
is stated as a bounding share and an institutional null, and never as an enrollment-scaled mispricing
dollar total.

It reports no projection. No climate scenario is applied to future exposure and no future-year
magnitude is produced; every number here is in-sample, describing exposure that has already occurred
rather than exposure a warming climate will bring.

And it reports no propagation chain. The Medicare morbidity band and the income, debt, and premium
bands are held as parallel evidence across distinct ledgers and populations, and nothing here claims
that morbidity mediates the income loss or that either flows into household debt. The value of the
synthesis is that it makes the certified estimates policy-legible while refusing every aggregation the
estimates cannot bear.
