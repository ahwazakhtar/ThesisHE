# Response to External Reader — Mechanisms

**Re:** your comments on the climate → health-cost results (see `external_reader_feedback.md`)
**From:** Ahwaz Akhtar
**Date:** 2026-07-01

Thank you for these comments. The mechanism question was the right pressure to put on the
reduced-form results, and pursuing it materially strengthened the thesis. I take your points below
in the order you raised them. The headline is one sentence: **agriculture is one channel, not the
channel** — and I can now show that *within the same county panel* rather than assert it. The full
apparatus lives in a new mechanism analysis (`Analysis/mechanism/mechanism_channels.md`, a
literature-grounded channel map; `Analysis/mechanism/mechanism_verdict.md`, the estimates) and in
three new sections of the technical note (§§1.2, 1.3, 6).

---

## 1. Your central question: how much *cannot* be explained by the agricultural income channel?

I took your leading hypothesis seriously and built a test around it. The design turns on measuring
agricultural dependence as a **structural, pre-treatment** county attribute — the USDA ERS 2015
farming-dependent typology and a baseline (2001–2010) farm-earnings share — and never as
contemporaneous farm income, which would sit on the causal path and constitute a bad control. For
each outcome and shock I then do two things: (a) interact the shock with agricultural dependence, to
ask whether the effect *loads* on farm counties; and (b) re-estimate inside the **bottom tercile of
agricultural dependence** — urban and service counties, where by construction any surviving effect
is *not* the farm channel. The identification logic is that if agriculture were the whole story, the
effect must vanish once the farm intermediary is removed. It does not.

Three findings answer your question directly.

**(i) The health-cost and utilization response is entirely non-agricultural.** One explanation for
the reduced-form results is that they run through farm income. To examine this directly, I bring in
county Medicare data (CMS Geographic Variation, 2014–2023), which measure medical cost and
utilization with no farm-income intermediary:

- Extreme heat raises standardized Medicare spending by **$112 per beneficiary** contemporaneously,
  **$177** at a one-year lag, and **$75** at two years (all *p* < 0.02) `[TK: express each as % of the
  ~$X per-beneficiary baseline mean]`, and raises ED visits by **7.8 and 9.5 per 1,000** at the
  contemporaneous and one-year horizons (*p* = 0.006, 0.0002) `[TK: baseline ED rate per 1,000]`.
- Extreme cold raises both at a two-year lag (**$85** in spending, **9.0** ED visits per 1,000;
  *p* = 0.009, 0.002).
- Poor air quality raises ED visits by **4.8 / 3.3 / 2.8 per 1,000** across three lags (all
  significant) — an in-panel reproduction of Deryugina et al. (2019).

None of this can run through farm income. It is a morbidity channel measured directly in
administrative health data, and it would operate in any county with a hospital.

**(ii) Where the effect looks like income or employment, it is broad *labor* exposure, not
cropland.** Here too the natural alternative is the farm story, and here too it fails the
bottom-tercile test. The cold → employment effect *survives and strengthens* in the least-agricultural
counties (**−2,011 jobs** in the bottom-ag tercile, *p* = 0.05, versus **−721** overall) `[TK:
baseline county employment, to render both as %]` — the opposite of what attrition of a farm channel
would predict. The heat → employment effect, in turn, loads on a county's share of employment in
climate-exposed **non-farm** industries — construction, mining, manufacturing, transport, utilities
(interaction **−689**, *p* = 0.009). Taken together, these two results point to the
labor-productivity mechanism of Graff Zivin & Neidell (2014) and Somanathan et al. (2021), which is
precisely what the agricultural story does *not* predict.

**(iii) The agricultural channel is real but narrow.** Consistent with a companion
difference-in-differences robustness exercise, the drought → income effect appears to be
*event-specific* — driven by the 2012 cohort rather than a general "droughted-county" law — and the
farm-dependence interactions are noisy in the recurring-treatment panel. I read agriculture as a
bound on the phenomenon, not the whole of it.

**One-paragraph answer.** A substantial part of what the reduced form captures operates outside the
agricultural income channel. The health-cost response is measured directly in Medicare data and
requires no farm-income intermediary; the employment response loads on climate-exposed non-farm
industries; and the distributional amplification operates through energy burden as well as farming
(§2). Agriculture contributes a real but event-specific, partly selection-driven drought effect. The
design bounds the agricultural channel rather than partitioning the effect into shares, so the claim
is the well-identified one that agriculture cannot be the whole story.

## 2. What other channels are in play?

Beyond morbidity and labor exposure, three further channels are in play — two I estimate (energy
burden and a supply-side provider channel), one I flag honestly as a caveat (migration).

**Energy burden is a distinct distributional channel.** Using DOE LEAD data, heat damage concentrates
in high-energy-burden counties (interaction **−1,380 jobs**, *p* < 0.001; **−$370** in income,
*p* < 0.001) `[TK: baselines for jobs and income, to anchor both as %]`. One might suspect this is
simply the social-vulnerability channel under another name — but county energy burden is only weakly
correlated with the social-vulnerability index I use elsewhere (*r* = 0.11), so this is an
*independent* margin. It is the affordability and adaptation mechanism of Doremus et al. (2022) and
Barreca et al. (2016), in which low-income households — who bear roughly 2.6 times the burden (8.9
percent of income versus 3.4 percent) — cut necessities to pay energy bills.

**The supply-side, provider-finance channel is a real gap, and an instructive result.** You asked
about mechanisms on the demand side; the question has a supply-side twin — do these shocks strain
*hospitals*? I estimate this on a hospital-year panel (NASHP; ∼5,100 hospitals, 2011–2023), and I
want to be transparent about a counterintuitive finding and how it resolves.

- Drought is associated with **lower** uncompensated care and **null** operating margins. At first
  blush this is surprising, but it is consistent with both theory and the one comparable study. It
  matches Audi et al. (2024–25), which regresses FEMA hurricane risk on a hospital financial ratio and
  recovers the same sign. Federal buffers — Section 1135 Medicaid disaster waivers, crop insurance and
  USDA disaster payments, DSH — sever the farm-income → uninsurance → uncompensated-care chain; climate
  demand surges are revenue-*positive* (billable ED visits); and deferred elective care plus
  out-migration mechanically lower *measured* uncompensated care. The published rural-hospital-closure
  literature omits climate and agricultural variables entirely, so this is a gap the thesis fills
  rather than a contested result.
- *Crucially for your question, this provider effect is not agricultural either.* The drought →
  uncompensated-care effect does not load on farm counties (interaction null) and survives essentially
  unchanged in the least-agricultural counties (**−0.0043** versus **−0.0051** overall, *p* = 0.01).
  This points to a general accounting-and-utilization response rather than a farm-income channel.
- *And where provider strain does appear, it concentrates exactly where theory predicts — safety-net
  hospitals.* Interacting the shocks with a safety-net indicator, extreme heat raises uncompensated
  care significantly more at safety-net hospitals (**+0.023** at a one-year lag, *p* < 0.001;
  **+0.020** at two years, *p* < 0.0001) — consistent with safety-net providers, whose operating
  margins are more than six times lower, absorbing the demand-side morbidity surge of Channel 1. This
  is the supply-side counterpart of the Channel 1 morbidity surge, concentrated among the providers
  least able to buffer it.

**Migration and selection place a bound on the scarring interpretation.** You rightly worry about adjustment
margins. Using IRS county-to-county flows, drought raises net **out-migration** the following year
(**−0.0021**, *p* = 0.05), so part of the persistent drought "scar" reflects *who leaves* rather than
same-population loss. I report this as a caveat on the scarring interpretation rather than a clean
channel. (I do not read the heat → in-migration coefficient as a shock response; it is confounded by
secular Sun Belt growth.)

I should flag one landmine the literature review surfaced. I do **not** rely on the original
Deschênes–Greenstone (2007) aggregate farm-profit figure, which contained coding errors later
corrected (Fisher et al. 2012). The random-weather identification method survives; that specific
magnitude does not.

## 3. On shocks as draws from a distribution ("anticipatable given historical averages")

You suggested setting this aside as definitional; I have nonetheless made it explicit (technical note
§1.2). Every shock is defined as a **departure from the individual county's own long-run
distribution**, not a national threshold. The binary heat and cold indicators mark the top quartile
of *that county's* historical degree-day distribution, and the continuous measures are z-scores
standardized to a **frozen 1990–2000 baseline** that precedes the study window. A "shock" is
therefore, by construction, an unusual draw relative to the distribution that county's residents,
firms, and insurers would have formed expectations around — which is exactly the "draw from a
distribution" object you have in mind. This removes any mechanical dependence between the shock
definition and the 2011–2023 outcomes: county fixed effects absorb secular trends, year fixed effects
absorb nationally common shocks, and what remains is an idiosyncratic, county-specific tail
realization.

## 4. On handling multiple shocks

Also now written up explicitly (§1.3). Shock multiplicity is absorbed three ways, so that no county's
multi-hazard exposure is collapsed to a single indicator. First, every specification carries the
contemporaneous shock plus two lags. Second, a compound `Any_Shock` indicator captures being hit by
at least one hazard, with co-occurring hazards entered separately. Third, the persistence analysis
replaces the on/off indicator with a running **count of shock-years** — a cumulative dose — modelling
repeated exposure as an increasing dose rather than as independent one-offs.

---

## Bottom line

Your instinct was the right one to test, and the test paid off. The reduced-form relationships
operate **substantially outside agriculture** — through a directly measured morbidity and utilization
channel, broad labor exposure, and an energy-burden margin — with agriculture a real but narrower,
event-specific, partly selection-driven contributor. The design bounds the agricultural channel
rather than decomposing the effect into shares, so it establishes that agriculture is one channel
among several rather than the channel. I have added the mechanism map, the in-panel
estimates, and the two definitional write-ups you flagged. I would welcome your read on whether this
bounds the agricultural channel to your satisfaction, and whether the non-agricultural channels are
framed with the right degree of caution.

*Supporting materials: `Analysis/mechanism/mechanism_channels.md`,
`Analysis/mechanism/mechanism_verdict.md`, coefficient tables and forest plots under
`Analysis/mechanism/`, and technical-note §§1.2, 1.3, 6.*
