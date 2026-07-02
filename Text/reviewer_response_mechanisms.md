# Response to External Reader — Mechanisms

**Re:** your comments on the climate → health-cost results (see `external_reader_feedback.md`)
**From:** Ahwaz Akhtar
**Date:** 2026-07-01

Thank you for these comments — the mechanism question was exactly the right pressure to put on
the reduced-form results, and pursuing it materially strengthened the thesis. Below I take your
points in the order you raised them. The short version: **agriculture is one channel, not the
channel**, and I can now show that *within the same county panel* rather than assert it. Full
detail lives in a new mechanism analysis (`Analysis/mechanism/mechanism_channels.md`, a
literature-grounded channel map; `Analysis/mechanism/mechanism_verdict.md`, the estimates) and in
three new sections of the technical note (§1.2, §1.3, §6).

---

## 1. Your central question: how much *cannot* be explained by the agricultural income channel?

I took your leading hypothesis seriously and built a test around it. Agricultural dependence is
measured as a **structural, pre-treatment** county attribute — the USDA ERS 2015 farming-dependent
typology and a baseline (2001–2010) farm-earnings share — never contemporaneous farm income, which
would be a bad control sitting on the causal path. For each outcome and shock I then (a) interact
the shock with agricultural dependence (does the effect *load* on farm counties?) and (b)
re-estimate inside the **bottom tercile of agricultural dependence** — urban/service counties,
where any surviving effect is by construction *not* the farm channel.

Three findings answer your question directly:

**(i) The health-cost/utilization response is entirely non-agricultural — and it is the most
cleanly identified result in the project.** Bringing in county Medicare data (CMS Geographic
Variation, 2014–2023) lets me measure medical cost and utilization *directly*, with no farm-income
intermediary:

- Extreme heat raises standardized Medicare spending by **+$112 per beneficiary** contemporaneously,
  **+$177** at a one-year lag, and **+$75** at two years (all p < 0.02), and raises ED visits by
  **+7.8 and +9.5 per 1,000** (p = 0.006, 0.0002).
- Extreme cold raises both at a two-year lag (**+$85** spending, **+9.0** ED visits; p = 0.009, 0.002).
- **Poor air quality raises ED visits by +4.8 / +3.3 / +2.8 per 1,000** across three lags (all
  significant) — an in-panel reproduction of Deryugina et al. (2019).

None of this can run through farm income; it is a morbidity channel measured in administrative
health data, and it would operate in any county with a hospital.

**(ii) Where it looks like income/employment, it is broad *labor* exposure, not cropland.** The
cold → employment effect *survives and strengthens* in the least-agricultural counties (bottom-ag
tercile: **−2,011 jobs**, p = 0.05, versus −721 overall), and the heat → employment effect loads on
a county's share of employment in climate-exposed **non-farm** industries — construction, mining,
manufacturing, transport, utilities (interaction **−689**, p = 0.009). This is the labor-productivity
mechanism of Graff Zivin & Neidell (2014) and Somanathan et al. (2021), and it is precisely what
the agricultural story does *not* predict.

**(iii) The agricultural channel is real but narrow.** Consistent with a companion
difference-in-differences robustness exercise, the drought → income effect is *event-specific* (the
2012 cohort) rather than a general "droughted-county" law, and the clean farm-dependence
interactions are noisy in the recurring-treatment panel. Agriculture is a bound on the phenomenon,
not the whole of it.

**One-paragraph answer.** Most of what the reduced form captures is *not* the agricultural income
channel. The health-cost response is measured directly in Medicare data and is agriculture-free;
the employment response is broad labor exposure that survives in non-farm counties; and the
distributional amplification runs through energy burden as much as through farming (see §2).
Agriculture contributes a real but event-specific, partly selection-driven drought effect.

## 2. What other channels are in play?

Beyond morbidity and labor exposure, three further channels — two estimated (energy burden and the
supply-side provider channel), one flagged honestly as a caveat (migration):

- **Energy burden (a distinct distributional channel).** Using DOE LEAD data, heat damage
  concentrates in high-energy-burden counties (interaction **−1,380 jobs**, p < 0.001; **−$370
  income**, p < 0.001). Notably, county energy burden is only weakly correlated with the
  social-vulnerability index I use elsewhere (r = 0.11), so this is an *independent* margin — the
  affordability/adaptation mechanism of Doremus et al. (2022) and Barreca et al. (2016), where
  low-income households (who bear ~2.6× the burden: 8.9% vs 3.4% of income) cut necessities to pay
  energy bills.
- **The supply-side (provider-finance) channel — a real gap, and an instructive result.** You asked
  about mechanisms; the demand-side question has a supply-side twin — do these shocks strain
  *hospitals*? I built this on a hospital-year panel (NASHP, ~5,100 hospitals, 2011–2023) and want to
  be transparent about a counterintuitive finding and how it resolves.
  - **Drought is associated with *lower* uncompensated care and *null* operating margins** — the
    opposite of a naive "climate strains hospitals" story. This is not an anomaly: it matches the only
    comparable study (Audi et al. 2024–25, which regresses FEMA hurricane-risk on a hospital financial
    ratio and finds the same paradoxical sign), and it is *theoretically* expected — federal buffers
    (Section 1135 Medicaid disaster waivers, crop insurance / USDA disaster payments, DSH) sever the
    farm-income → uninsurance → uncompensated-care chain; climate demand surges are revenue-*positive*
    (billable ED visits); and deferred elective care plus out-migration lower *measured* uncompensated
    care mechanically. The published rural-hospital-closure literature omits climate and agricultural
    variables entirely, so this is a genuine gap the thesis fills rather than a contested result.
  - **Crucially for your question, this provider effect is *not* agricultural either.** The drought →
    uncompensated-care effect does not load on farm counties (interaction null) and *survives
    essentially unchanged in the least-agricultural counties* (−0.0043 vs −0.0051 overall, p = 0.01) —
    so it is a general accounting/utilization response, not a farm-income channel.
  - **And where provider strain *does* appear, it concentrates exactly where theory predicts — safety-net
    hospitals.** Interacting the shocks with a safety-net indicator, **extreme heat raises
    uncompensated care significantly more at safety-net hospitals** (+0.023 at a one-year lag, p < 0.001;
    +0.020 at two years, p < 0.0001) — consistent with safety-net providers (operating margins >6× lower)
    absorbing the demand-side morbidity surge of Channel 1. This is the supply-side face of the same
    morbidity mechanism, landing on the providers least able to buffer it.

- **Migration / selection (a bound, not a decomposition).** You rightly worry about adjustment
  margins. Using IRS county-to-county flows, drought raises net **out-migration** the following year
  (−0.0021, p = 0.05), so part of the persistent drought "scar" reflects *who leaves* rather than
  same-population loss. I report this as a caveat on the scarring interpretation rather than a clean
  channel. (I do not read the heat → in-migration coefficient as a shock response; it is confounded
  by secular Sun Belt growth.)

I should also flag one landmine the literature review surfaced: I do **not** rely on the original
Deschênes–Greenstone (2007) aggregate farm-profit figure, which contained coding errors later
corrected (Fisher et al. 2012). The random-weather identification method survives; that specific
magnitude does not.

## 3. On shocks as draws from a distribution ("anticipatable given historical averages")

You suggested setting this aside as definitional; I have nonetheless made it explicit (technical
note §1.2). Every shock is defined as a **departure from the individual county's own long-run
distribution**, not a national threshold: the binary heat/cold indicators mark the top quartile of
*that county's* historical degree-day distribution, and the continuous measures are z-scores
standardized to a **frozen 1990–2000 baseline** that precedes the study window. A "shock" is
therefore, by construction, an unusual draw relative to the distribution that county's residents,
firms, and insurers would have formed expectations around — which is exactly the "draw from a
distribution" object you have in mind, and it removes any mechanical dependence between the shock
definition and the 2011–2023 outcomes. County fixed effects absorb secular trends; year fixed
effects absorb nationally common shocks; what remains is idiosyncratic, county-specific tail
realization.

## 4. On handling multiple shocks

Also now written up explicitly (§1.3). Shock multiplicity is absorbed three ways, so no county's
multi-hazard exposure is collapsed to a single indicator: (a) every specification carries the
contemporaneous shock plus two lags; (b) a compound / `Any_Shock` indicator captures being hit by
at least one hazard and co-occurring hazards separately; and (c) the persistence analysis replaces
the on/off indicator with a running **count of shock-years** (a cumulative dose), modelling repeated
exposure as an increasing dose rather than independent one-offs.

---

## Bottom line

Your instinct was the right one to test, and the test paid off: the reduced-form relationships are
generated primarily by **non-agricultural** channels — a directly-measured morbidity/utilization
channel, broad labor exposure, and energy burden — with agriculture a real but narrower,
event-specific, partly selection-driven contributor. I have added the mechanism map, the in-panel
estimates, and the two definitional write-ups you flagged. I would welcome your read on whether this
bounds the agricultural channel to your satisfaction and whether the non-agricultural channels are
framed with the right degree of caution.

*Supporting materials: `Analysis/mechanism/mechanism_channels.md`,
`Analysis/mechanism/mechanism_verdict.md`, coefficient tables and forest plots under
`Analysis/mechanism/`, and technical-note §§1.2, 1.3, 6.*
