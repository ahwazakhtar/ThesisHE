# Mechanism Map: What Explains the Climate → Health-Cost Results

**Track:** `mechanism_channels_20260625` (Phase 3 deliverable).
**Purpose:** Answer the external reviewer's central question — *"How much of what you're
finding cannot be explained by the agricultural income channel, and what other channels might
be in play?"* — by mapping the candidate mechanisms to the published causal literature and, for
each, asking whether it is **empirically separable from agriculture** in a US county panel.

**Method note.** The literature synthesis below is drawn from a fanned-out, adversarially-verified
web research pass (2026-07-01): 6 search angles → 25 primary/secondary sources fetched → 111
candidate claims → 25 verified by 3-vote adversarial review (24 confirmed, 1 refuted). Every
magnitude cited below is tied to a named source that survived that verification. The refuted claim
is documented in §"Claims that did *not* survive" so we do not repeat it.

---

## The headline answer (for the reviewer)

**Agriculture is a real channel but cannot be the whole story.** Three independent lines of
evidence establish that the climate → income/health-cost relationship is *broad-based*, not
farm-specific:

1. **The macro benchmark.** Country-level output is concave in temperature (peaking ~13 °C
   annual mean), and — critically — *agricultural and non-agricultural aggregate production
   share a similar temperature response* in both rich and poor countries (Burke, Hsiang &
   Miguel 2015, *Nature*). If only agriculture were exposed, non-farm output would not track
   temperature the way it does.

2. **The decisive US-county signature.** Over 40 years of US county income data, the
   productivity of individual days falls ~1.7% per 1 °C above 15 °C, a single weekday above
   30 °C costs a county ~$20/person in annual income — **but hot *weekends* produce minimal
   effects** (Deryugina & Hsiang 2014, NBER w20750). Crops are exposed every day; an effect
   that appears only on *workdays* implicates **human work activity**, not the cornfield. This
   weekday/weekend asymmetry is the single cleanest separability test in the literature.

3. **The direct health-cost channel.** Temperature and air-pollution shocks raise hospital
   admissions, Medicare/Medicaid spending, and medical costs *measured in administrative health
   data* — outcomes that are not mediated by farm income at all (Deryugina et al. 2019, AER;
   IJPH 2025).

**Bottom line to report:** the effects we estimate that **survive in low-agriculture (urban/
service) counties** are, by construction, *not* the agricultural channel. The literature
predicts three such survivors — labor-supply in climate-exposed non-farm industries, healthcare
utilization, and energy burden. The farm channel should, in turn, **scale with a county's
cropland / farm-employment share** — which is exactly what our `Ag_Dependence` moderator
(Phase 2) is built to test.

---

## Channel-by-channel map

Legend for **Separable from agriculture in our panel?**
— **Yes (survives low-ag):** literature predicts a non-zero effect in urban/service counties → a
positive finding there is evidence *against* the agriculture-only story.
— **Scales with ag:** literature predicts the effect concentrates in farm-dependent counties →
loads on the `Ag_Dependence` interaction.

### 1. Agricultural income channel *(the reviewer's hypothesis)*
- **Story:** Drought / extreme heat / cold depress crop yields → farm income → local income →
  downstream premium / debt / employment effects.
- **Evidence & magnitudes:**
  - Deschênes & Greenstone (2007, *AER*) established the identification — *random year-to-year
    weather variation on agricultural profits.* (The **method** is canonical; their specific
    +$1.3B aggregate-profit *number* was later refuted — see below.)
  - Schlenker & Roberts (2009, *PNAS*): yields rise with temperature up to sharp thresholds
    (corn 29 °C, soybeans 30 °C, cotton 32 °C) then fall steeply; projected end-of-century
    losses −30 to −46% (slow warming) to −63 to −82% (rapid). The damaging exposure is
    **degree-days above a threshold**, not average warming — a specific, separable exposure.
  - Developing-country macro: Dell, Jones & Olken (2012, *AEJ:Macro*) — higher temperatures
    reduce the *growth rate* of output in poor countries through multiple channels (agricultural
    output, industrial output, stability). The growth-rate (not level) result is the conceptual
    parallel to **our h=2 scarring** finding.
- **Expected sign:** cold/drought → ↓ farm income → ↓ local income.
- **Separable from agriculture in our panel?** This *is* the agricultural channel — it should
  **scale with ag dependence** (load on `Shock × Ag_Dependence`; strong in the top ag tercile,
  weak/absent in the bottom tercile).

### 2. Labor productivity & labor supply under temperature extremes
- **Story:** Heat cuts worker productivity and labor supply across *all* climate-exposed sectors
  (agriculture, construction, mining, manufacturing, utilities), not farming alone → lower
  earnings and employment.
- **Evidence & magnitudes:**
  - Graff Zivin & Neidell (2014, *JLE*): large reductions in US labor supply in high-exposure
    industries (~1 hour lost per worker at >100 °F); but because the US industrial base is
    diversified away from exposed sectors, the *aggregate* employment effect is small — implying
    **effects concentrate in counties with a high share of climate-exposed industry.**
  - Somanathan et al. (2021, *JPE*, Indian manufacturing): annual plant output falls ~2% per
    1 °C, driven by a fall in the output elasticity of labor (productivity + absenteeism) —
    "large enough to explain previously observed output losses in cross-country panels."
  - The Deryugina & Hsiang (2014) weekday-only US income dip is the direct fingerprint of this
    channel operating on the aggregate economy.
- **Expected sign:** heat (and cold, via a different physiology) → ↓ productivity → ↓ earnings /
  employment.
- **Separable from agriculture in our panel? **Yes (survives low-ag).** The decisive test: does
  the employment/income effect persist in the bottom ag tercile but *load on climate-exposed
  non-farm industry share*? Our `Civilian_Employed` outcome + ACS industry composition can carry
  this. **This is the strongest non-agricultural candidate.**

### 3. Morbidity / healthcare-utilization channel
- **Story:** Heat, cold, and air pollution raise illness and mortality → hospital admissions,
  ED visits, and public/private medical spending rise — a health-cost effect that does **not**
  pass through farm income.
- **Evidence & magnitudes:**
  - Deryugina, Heutel, Miller, Molitor & Reif (2019, *AER*): using **wind-direction changes as
    an instrument** for PM2.5, a 1 µg/m³ one-day increase causes 0.61 additional deaths per
    million elderly (3-day window) and raises *healthcare use and medical costs* among the US
    elderly (Medicare universe). Cleanly causal.
  - IJPH (2025), US county panel 2000–2019: **10 extra extreme-heat days (>90 °F) → +1.56%
    hospital admissions, +0.85% Medicaid transfers ($11.78/capita); 10 extra cold days
    (10–20 °F) → +1.58% admissions, +1.32% inpatient days; extreme cold (<10 °F) → +0.22%
    Medicare transfers ($4.30/capita).** (Associational lagged-DV panel, not a natural
    experiment — small magnitudes; cite as corroborating, not identifying.)
  - Barreca, Clay, Deschênes, Greenstone & Shapiro (2016, *JPE*): **residential AC adoption
    explains essentially the entire 20th-century decline in the temperature-mortality
    relationship**; electricity/healthcare access did *not* reduce hot-day mortality. Ties the
    health channel to an **affordability/adaptation** margin → directly rationalizes our
    **high-SVI amplification.**
- **Expected sign:** heat/cold/PM2.5 → ↑ utilization → ↑ medical costs / premiums.
- **Separable from agriculture in our panel? **Yes (survives low-ag).** Measured in health data,
  no farm-income intermediary. Directly relevant to our **premium** and **medical-debt**
  outcomes; the AQI variables already in the panel are the natural probe for the pollution arm.

### 4. Energy-burden / household financial-distress channel
- **Story:** Extreme temperatures raise heating/cooling needs; low-income households under-consume
  protective energy (AC unaffordable) and cut **food and other necessities** to pay energy
  bills → financial distress. Inherently distributional (worse where SVI is high).
- **Evidence & magnitudes:**
  - Doremus, Jacqz & Johnston (2022, *JEEM*): both income groups respond similarly (in %) to
    *moderate* temperatures, but low-income households' energy spending is **half as responsive**
    to *extreme* temperatures, with parallel disparities in the **food-spending** response —
    "consistent with low-income households cutting back on necessities to afford their energy
    bills." (Authors frame the food crowd-out as *suggestive*, not a direct distress measure.)
- **Expected sign:** temperature extremes → ↑ energy burden → ↓ necessity spending / ↑ distress.
- **Separable from agriculture in our panel? **Yes (survives low-ag).** Operates in any county
  regardless of cropland. Best mapped to our **high-SVI heterogeneity** and household-distress
  outcomes; a feasible suggestive proxy uses HDD/CDD against the SVI split (Phase 3 optional
  estimate).

### 5. Hospital / provider-finance channel  *(confirmed gap — our result matches the sparse literature)*
*(Dedicated supply-side literature review, 2026-07-02.)*
- **Story:** Climate shocks raise uncompensated care / compress hospital operating margins, feeding
  back into local pricing and access.
- **State of the literature (now surveyed):** the hospital-finance-specific, drought/chronic-stress
  version of this question is **genuinely understudied**. The evidence base for "climate strains
  hospital finances" rests almost entirely on **acute, physically-destructive** events — hurricanes
  and wildfires (Katrina: 5 New Orleans hospitals, GAO-08-681R, $135M→$405M cumulative operating
  losses from post-storm labor costs; Sandy NYC HHC ≈ $810M; Camp Fire / Feather River permanent
  closure) — whose mechanism (building damage, evacuation, elevated labor cost) has **no drought
  analog.** The best-*identified* paper is Wilkoff, Lopez, Murphy & Tzur-Ilan (working paper): wildfire
  smoke raises hospital **municipal-bond borrowing costs** (~$1.6M extra interest on a $90M issue),
  a chronic-exposure channel closer to drought's character.
- **Our null/negative result is CONSISTENT with the literature, not an anomaly.** The one study that
  runs the same regression logic — Audi, Hamadi et al. (2024–25), FEMA hurricane-risk percentile on a
  hospital financial ratio for ~1,030 Southeastern hospitals — found a **paradoxical** sign (higher
  risk → *better* cost-to-charge ratio; authors flag "requires further investigation"). Our
  `hospital_supply_side` incidence result (drought → **lower** uncompensated care, −$6.2M cumulative,
  p<1e-11; **null** operating margins) points the same way.
- **Why a null/negative is theoretically sensible (four literature-backed reasons):**
  1. **Federal buffers sever the income→uninsurance→uncompensated-care chain** the reviewer assumes —
     Section 1135 Medicaid disaster waivers, crop insurance / USDA disaster payments, and DSH.
  2. **Demand surges are revenue-positive** — heat/pollution ED visits are billable admissions
     (Channel 3), which can offset expected "strain."
  3. **Deferred elective care + selective out-migration lowers *measured* uncompensated care
     mechanically** without improving underlying finances — and uncompensated care is a discretionary
     accounting category (bad-debt vs. charity classification varies by policy), i.e. as
     **measurement-fragile** as credit-bureau medical debt.
  4. **Hospital distress is driven by capital structure / occupancy / ownership, not local income** —
     a national Altman-Z study (7,900 hospital-years) found median income and uninsured rate
     *insignificant* for distress (urban odds actually higher).
- **The gap is confirmed, not tested-and-rejected:** the rural-hospital-closure prediction literature
  (systematic review, BMC HSR 2025; Sheps/Holmes distress models) **omits climate and agricultural
  variables entirely.** No peer-reviewed paper links farm-income/commodity/drought shocks to
  hospital-level finances; even the 1980s Farm Crisis lacks a hospital-specific quantitative study.
- **Caveat — reverse causality:** the rural-closure→local-economy DiD literature (Vogler SSRN 3750200;
  Alexander & Richards, *JPubE* 2023) runs the *opposite* direction, and some work finds local decline
  *precedes* closure — so any drought→closure claim must guard against reverse causality.
- **Disposition:** owned by the **`hospital_supply_side_20260615` track** (NASHP hospital-year panel);
  cross-reference, don't re-estimate the incidence models here. Frame the thesis's own supply-side
  results as **filling a genuine gap**, with the null/negative response explained by the four
  mechanisms above rather than treated as a puzzle. Provider *heterogeneity* (does any strain
  concentrate in safety-net / high-Medicaid / non-expansion hospitals?) is the natural separability
  test — see the verdict doc.
- **Separable from agriculture? Yes — now tested** (`run_mechanism_provider.R`). The drought →
  uncompensated-care effect is **not** agricultural: `Drought × Ag_z` null, and the effect survives
  unchanged in the bottom ag tercile (−0.0043, p=0.01). And the provider heterogeneity the literature
  predicts is present: **heat raises uncompensated care significantly more at safety-net hospitals**
  (`CDD × SafetyNet` +0.023 Lag1 p<0.001, +0.020 Lag2 p<1e-4) — the supply-side face of the morbidity
  channel, on the providers least able to buffer it.

### 6. Insurance-pricing / climate-risk channel  *(GAP for health insurance)*
- **Story:** Climate risk feeds into premiums — well documented for **property** insurance,
  thinly documented for **health** insurance.
- **Evidence:** No verified evidence on climate risk → **health-insurance** premiums
  specifically. Industry/secondary material (e.g., Mercer) anticipates "climate-risk cost
  adjustments" to health premiums via higher utilization, but this is prospective/secondary, not
  an identified estimate.
- **Open question for the thesis:** Is our premium result mediated by **local morbidity/
  utilization** (Channel 3), by **rating-area medical-cost trends**, or by something else? Our
  rating-area premium structure means premiums move at the rating-area level — consistent with a
  medical-cost-trend pathway rather than a direct farm-income one.
- **Separable from agriculture? Yes in principle** — a premium effect surviving in low-ag
  counties points to the utilization/medical-cost pathway, not farm income.

### 7. Migration & sectoral labor reallocation  *(GAP / identification caveat)*
- **Story:** Out-migration and sector-switching are *adjustment margins* that could attenuate —
  or bias — county-level income/employment estimates (population selection vs. same-population
  income loss).
- **Evidence:** No verified claim on out-migration/reallocation surfaced in this pass (the
  seasonal-employment JEEM 2024 county paper was fetched but did not yield a verified
  reallocation claim).
- **Disposition:** Flag as an **identification caveat**, not a mechanism we can bound with the
  current data: how much of the h=2 "scarring" reflects **who leaves** vs. **who stays and earns
  less**? A future extension (county population flows / IRS migration data) could address it.

### 8. Credit, debt & household financial-distress dynamics
- **Story:** Income shocks that households cannot smooth accumulate as medical debt / financial
  distress — the persistence (scarring) mechanism behind our h=2 medical-debt result.
- **Evidence:** Supported indirectly — the energy-burden crowd-out (Channel 4) and the
  growth-rate/scarring macro result (Dell-Jones-Olken, Channel 1) together rationalize why a
  transitory weather shock leaves a *persistent* debt footprint.
- **Separable from agriculture? Yes (survives low-ag)** to the extent it rides on Channels 2–4.
- **Standing caveat (our own):** medical debt is the **measurement-fragile, aggregation-sensitive**
  outcome (credit-bureau medical debt requires insurance + billed encounters + a credit file).
  **Lead the mechanism narrative with the real-economy outcomes (income, employment)**; treat
  medical debt as corroborating.

---

## What agriculture *can* and *cannot* explain (synthesis)

| | Effect **loads on ag** counties → *consistent with* agriculture | Effect **survives in low-ag** counties → *not* agriculture |
|---|---|---|
| **Drought → income/employment** | Plausibly partly agricultural (farm-income channel is real) | Labor-supply in exposed non-farm sectors; energy burden |
| **Cold (HDD) → employment (compounding)** | Weak ag story for cold-employment compounding | Labor productivity/supply; energy burden; heating-cost distress |
| **Premiums** | Little direct ag pathway | Morbidity/utilization → medical-cost-trend pricing |
| **Medical debt (h=2 scar)** | — | Rides on Channels 2–4; but measurement-fragile |

**Most credible non-agricultural channels for a US county panel (ranked):**
1. **Labor productivity & supply in climate-exposed non-farm industries** — strongest theory +
   the decisive weekday-only US-county evidence; testable via the low-ag tercile + industry share.
2. **Morbidity / healthcare-utilization** — directly measured in health administrative data;
   maps to our premium/debt outcomes and the existing AQI variables.
3. **Energy-burden / household distress** — rationalizes the high-SVI amplification via the
   AC-affordability adaptation margin (Barreca; Doremus).
4. **Hospital-finance strain** — thin external literature; the thesis's own supply-side track is
   the primary evidence (likely an original contribution).

---

## The empirical test this motivates (hand-off to Phase 2)

The literature converts the reviewer's question into a **falsifiable within-panel test**:

- **Spec A (interaction):** `Y ~ Shock(+lags) + Shock × Ag_Dependence + controls | County + Year`,
  cluster State. Does the effect *load* on agricultural counties?
- **Spec B (subsample):** re-estimate within the **bottom ag-dependence tercile** (urban/service
  counties). The surviving effect there is, by construction, **not** the agricultural channel;
  report `effect_low_ag / effect_overall` per (outcome, shock) pair.

Expected pattern given the literature: drought→income partly loads on ag but leaves a residual;
cold→employment and premium/utilization effects **persist in low-ag counties** → agriculture is
*a* channel, not *the* channel. `Ag_Dependence` = USDA ERS 2015 Farming-dependent flag (primary),
with baseline BEA farm-earnings share and ACS ag-employment share as cross-checks.

---

## Claims that did *not* survive verification (do not cite)

- **Refuted (0-3):** "Predicted climate change modestly *increases* US aggregate agricultural
  profits (~+$1.3B / +4%), implying US farm-climate impacts are small." — This is Deschênes &
  Greenstone's (2007) original aggregate-profit figure, which contained coding errors (Fisher,
  Hanemann, Roberts & Schlenker 2012, *AER* comment). The **random-weather identification method
  survives; the specific magnitude does not.** Do not cite it as evidence farm impacts are small.

## Verified-source appendix (primary sources)

| # | Source | Channel | Access |
|---|--------|---------|--------|
| BHM 2015 | Burke, Hsiang & Miguel, *Nature* 527 | 1 (macro benchmark) | nature.com/articles/nature15725 |
| DJO 2012 | Dell, Jones & Olken, *AEJ:Macro* 4(3) | 1 (growth-rate/scarring) | aeaweb.org 10.1257/mac.4.3.66 |
| D&G 2007 | Deschênes & Greenstone, *AER* 97(1) | 1 (identification) | aeaweb.org 10.1257/aer.97.1.354 |
| S&R 2009 | Schlenker & Roberts, *PNAS* | 1 (crop thresholds) | pnas.org 10.1073/pnas.0906865106 |
| GZ&N 2014 | Graff Zivin & Neidell, *JLE* | 2 (labor supply) | journals.uchicago.edu 10.1086/671766 |
| Som. 2021 | Somanathan et al., *JPE* | 2 (plant productivity) | journals.uchicago.edu 10.1086/713733 |
| D&H 2014 | Deryugina & Hsiang, NBER w20750 | 2 (weekday US income) | nber.org/papers/w20750 |
| DHMMR 2019 | Deryugina et al., *AER* | 3 (PM2.5 mortality/cost) | nber.org/papers/w22796 |
| IJPH 2025 | Int'l J. Public Health | 3 (heat/cold utilization) | ssph-journal.org …ijph.2025.1607160 |
| BCDGS 2016 | Barreca et al., *JPE* | 3/4 (AC adaptation) | journals.uchicago.edu 10.1086/684582 |
| DJJ 2022 | Doremus, Jacqz & Johnston, *JEEM* 112 | 4 (energy burden) | sciencedirect.com S0095069622000018 |

*(Full 25-source list, including secondary/industry sources for Channels 5–6, in the research
run artifact `tasks/w9et4j0km.output`.)*
