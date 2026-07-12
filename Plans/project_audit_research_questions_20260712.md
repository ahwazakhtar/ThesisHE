# Project Audit: Research Questions, Project Direction, and Remaining Alpha

**Date:** July 12, 2026  
**Scope:** Strategic, read-only audit focused on the questions supported by the data, the coherence of the dissertation direction, identification limits, and the remaining opportunities for high-value analysis. This is not primarily a code-quality audit.

## Executive diagnosis

The project has substantial empirical depth, but it is currently trying to extract too many papers and causal narratives from a smaller set of genuinely defensible results.

The central issue is no longer a lack of analyses. It is the absence of a stable hierarchy of questions, estimands, and claims.

The strongest version of the dissertation is not:

> Climate shocks raise medical debt, premiums, hospital distress, employment losses, and inequality through several identified mechanisms.

The evidence supports something narrower and potentially more interesting:

> Climate shocks generate delayed and uneven economic and healthcare-utilization costs, but conventional financial indicators—medical debt, premiums, and hospital accounting measures—often fail to capture or price those costs coherently.

This framing connects the strongest findings:

- The 2012 drought caused a credible local income loss.
- Temperature shocks increase Medicare utilization and spending.
- Cold exposure has persistent labor-market consequences.
- Effects are amplified by labor exposure, energy burden, and vulnerability.
- ACA premium pass-through is incoherent or absent.
- Credit-bureau debt and hospital uncompensated-care measures behave inconsistently precisely where hardship may be greatest.

The resulting **measurement and pricing failure** may be more original than any individual climate coefficient.

## Where the project is lacking

### 1. The research questions remain broader than the identifying variation

The project asks causal questions about climate shocks generally, but its strongest causal result is one event: the 2012 drought.

That result survives:

- Wild-cluster inference: \(p=0.036\)
- Randomization inference: \(p=0.0075\)
- Doubly robust adjustment: approximately −$1,451 per capita
- A long 1990–2011 differential pretrend test

However, the pooled multi-cohort estimator is null or reverses sign. The evidence therefore establishes a credible effect of the 2012 drought, not a general drought response function.

Three questions need to remain distinct:

- **Event-specific:** What did the 2012 drought do?
- **Recurring exposure:** What typically happens in drought years?
- **Climate change:** What happens as the distribution of drought changes?

These correspond to different estimands. The current writing sometimes moves too easily among them.

### 2. “Health-finance costs” is not yet a single coherent outcome family

The project combines:

- Medicare utilization and spending
- Credit-bureau medical debt
- ACA premiums
- Hospital uncompensated care
- Income and employment

These do not measure successive stages of a demonstrated causal chain. They are separate ledgers observed for different populations, years, institutions, and geographic units.

The proposed conceptual chain is:

```text
Weather
  → morbidity/utilization
  → household liability or provider costs
  → income/liquidity pressure
  → medical debt
  → premiums
```

The project has evidence for several arrows, but not the complete chain. Premium pass-through is incoherent, causal premium mediation is unsupported, and Medicare largely observes older and disabled beneficiaries while medical debt is measured through credit records.

The thesis should describe this as **triangulation across financial ledgers**, not a fully identified propagation mechanism.

### 3. The premium story in the abstracts is contradicted by the completed analysis

The current Essay 1 abstract says shocks raise premiums after an actuarial lag and that policymakers leave the margin unpriced. The newer institutional-level analysis instead concludes:

- There is no coherent premium pass-through.
- Coefficients flip sign across county, rating-area, and state levels.
- About 92–99% of the debt coefficient survives premium adjustment.
- County premium specifications are explicitly labeled misspecified.

This is not a minor wording issue. It changes the research question.

The defensible question is no longer:

> How much do insurers pass climate-health costs into premiums?

It is:

> Why do measured morbidity and household financial effects fail to produce a stable local premium response under ACA pricing institutions?

That is a potentially strong institutional null, but the abstracts require immediate reconciliation.

### 4. Obsolete claims remain in headline documents

The abstracts still include:

- The −2,011-job effect in low-agricultural counties, which reportedly dies in log/per-worker specifications.
- Language suggesting the effects operate primarily through morbidity and broad labor exposure.
- A strong premium-repricing narrative contradicted by the mediation analysis.
- An employment headline for the 2012 drought without sufficient prominence given to its fragility and lack of generalization.
- Energy-burden language stronger than warranted for income, where the joint horse race is not robust.

The internal review documents understand these corrections. The public-facing claim architecture has not caught up.

### 5. The three essays may not yet be sufficiently distinct

“Incidence, Persistence, and Inequality” is elegant, but the essays reuse:

- The same county panel
- The same shock definitions
- Overlapping outcomes
- Related TWFE and local-projection specifications
- The same mechanism evidence

There is a risk that the committee sees one large paper divided by result type rather than three independent essays.

To make the structure work:

- **Essay 1** needs a sharp identification centerpiece: the 2012 drought and direct morbidity evidence.
- **Essay 2** needs a genuine estimand contribution: transition symmetry and cumulative recurring exposure, not simply longer lags.
- **Essay 3** needs a distributional object beyond interaction grids, ideally burden concentration or incidence accounting.

Essay 3 is presently the least independent. CHEI is useful descriptively, but a hazard × exposure × vulnerability index can look index-driven unless tied to a clear welfare or targeting estimand.

### 6. Annual county exposure is poorly matched to several health questions

Annual NOAA measures are appropriate for:

- Persistent drought
- Annual economic conditions
- Heating and cooling burden
- Longer-run financial outcomes

They are less well matched to:

- Acute morbidity
- Emergency visits
- Hospital operational stress
- Heat episodes
- Air-pollution events

Annual aggregation blurs intensity, duration, and timing. A county with one severe heat wave can resemble one with persistent moderate heat. Distributed annual lags then mix biological delay, institutional reporting delay, and temporal aggregation.

The writing should distinguish clearly among:

- Annual climate burden
- Discrete extreme episodes
- Anomalies relative to historical climate
- Cumulative exposure

These are currently sometimes treated interchangeably.

### 7. The outcome populations do not line up

Key samples differ substantially:

- **Medicare:** primarily age 65+ and disabled beneficiaries, 2014–2023
- **Medical debt:** credit-visible residents and intermittent snapshots
- **ACA premiums:** individual-market pricing set through rating-area and state institutions
- **Employment:** the working population
- **Hospital accounts:** provider-level reporting and accounting definitions

This makes statements such as “Medicare morbidity leads to household debt” suggestive, not directly demonstrated.

The SAHIE result—greater uninsurance associated with a smaller measured debt response—strengthens a measurement critique. It does not validate debt as a welfare outcome.

### 8. Hospital geography is a meaningful limitation

Hospital shocks are assigned using the hospital’s location county, but patient catchment areas often cross county boundaries. This is especially important for:

- Rural referral hospitals
- Safety-net systems
- Hospital markets spanning county borders
- Events that displace patients

The heat × safety-net result is promising, but it should be framed as exposure at the provider’s location, not necessarily exposure of the treated patient population.

Hospital accounting outcomes also contain:

- A known negative charity-care reversal
- Potential survivorship in cumulative-dose estimates
- Discretionary reporting behavior
- Possible endogenous exits

Until upstream winsorization or filtering is verified, hospital levels results remain vulnerable to a straightforward defense question.

### 9. A fundamental data-integrity issue remains open

The county master is not guaranteed to have one row per county-year because some counties map to multiple rating areas. Approximately 484 duplicate county-year rows were handled ad hoc in the mediation analysis.

This is higher priority than any new extension because it can alter:

- County weighting
- Standard errors
- Treatment counts
- Premium regressions
- Any analysis that silently treats rows as independent observations

The upstream uniqueness fix and a full before/after coefficient comparison should occur before final thesis tables are frozen.

### 10. Multiplicity was addressed late and locally

The mechanism analysis now includes Anderson indices and sharpened q-values. Nevertheless, the dissertation has searched across:

- Several hazards
- Multiple definitions
- Multiple lags
- Many outcomes
- Weighted and unweighted models
- Geographic scales
- Moderators
- Persistence specifications

A reader will evaluate the entire discovery process, not only the 14-cell mechanism family.

The final manuscript needs an explicit hierarchy:

1. Pre-designated headline tests
2. Confirmatory robustness tests
3. Mechanism-supporting evidence
4. Exploratory patterns

Without this hierarchy, even robust individual p-values can look selected from a large specification universe.

## Remaining alpha

There is remaining alpha, but most of it is conceptual and synthetic rather than another large regression grid.

### Highest alpha: make missing pass-through part of the contribution

The project can ask:

> When weather raises measured healthcare utilization and damages local economic capacity, which institutions actually record or price that harm?

This produces a coherent ledger comparison:

| Ledger | Observed response | Interpretation |
|---|---|---|
| Medicare utilization and spending | Clear response | Direct morbidity is visible |
| Income and employment | Event-specific and persistent responses | Economic capacity can deteriorate |
| ACA premiums | No coherent pass-through | Regulated pricing and risk pooling do not locally price the shock |
| Medical debt | Lagged but measurement-fragile | Credit records capture a selected margin |
| Hospital accounts | Uncompensated-care response, margins mostly null | Providers absorb or reclassify strain imperfectly |

This moves the dissertation beyond “weather affects outcome X” toward institutional incidence.

### High alpha: quantify burden concentration, not a full microsimulation

A bounded sufficient-statistics exercise could materially improve Essay 3:

- Number of exposed people or beneficiaries
- Per-unit robust effect
- Aggregate burden with uncertainty
- Share concentrated in the top SVI or energy-burden decile
- Comparison with existing federal agricultural disaster transfers

This would turn “inequality” from a coefficient-interaction essay into a distributional-incidence paper.

A national causal welfare total should not be claimed when the underlying coefficient is event-specific. Prefer scenario bands:

- Burden of a 2012-style drought event
- Typical recurring-shock estimate
- Direct Medicare burden
- High-vulnerability concentration

### High alpha: exploit the distinction between observed and latent hardship

One of the most interesting possible questions is:

> Does the measured financial response shrink where institutional access, insurance coverage, credit visibility, or healthcare utilization is weakest?

The SAHIE interaction already points in this direction. Existing data may support a disciplined analysis using:

- Uninsurance
- Credit visibility or medical-debt coverage, if available
- Rurality and provider access
- Hospital density
- Safety-net presence
- Income and SVI

This could turn “measurement-fragile debt” into a positive empirical contribution rather than leaving it only as a caveat.

### Moderate alpha: adaptation versus damage

The frozen 1990–2000 climate baseline creates an opportunity to separate:

- Anomaly relative to historical local climate
- Absolute physical burden
- Long-run climate normal or adaptation capacity

A disciplined horse race between anomaly and baseline climate could ask:

> Is harm driven by physical weather severity or by weather that exceeds local adaptation?

Some components already exist through z-scores, CDD/HDD, and baseline-climate interactions, but they are not organized as a central question. This is likely more valuable than adding another hazard.

### Moderate alpha: negative controls and timing falsification

Falsification would now add more credibility than additional positive findings:

- Future shocks predicting past outcomes
- Implausible lag timing
- Outcomes with no expected climate pathway
- Placebo onset years for the 2012 drought
- Alternative untreated regional comparison groups
- Leave-one-treated-state-out estimates

The last item is particularly useful because treated counties are geographically concentrated. It would show whether one state drives the drought-income estimate.

### Moderate alpha: heterogeneous 2012 treatment intensity

Instead of treating all exposed counties equally, a tightly pre-specified analysis could examine event intensity using:

- PDSI intensity
- Months in extreme drought
- Agricultural dependence
- Pre-event water dependence
- Baseline labor exposure

This could distinguish an actual dose response from a treated-region contrast. It should be tightly constrained to avoid another broad interaction search.

### Lower alpha: mortality

County mortality would provide a recognizable health-economics endpoint, but it is not automatically high return:

- Suppression can be substantial.
- Annual mortality may have low power for narrow shocks.
- The literature is already deep.
- It risks adding another outcome family without improving the financial-incidence contribution.

Mortality is most useful as a benchmark validation exercise, not as a new dissertation pillar.

### Low or negative alpha

The following should not be prioritized:

- More hazard types
- A full structural PTC microsimulation before the empirical essays exist
- More binary threshold grids
- More generic shock × moderator interactions
- Treating ACA premium coefficients as stable sufficient statistics
- Hospital closures before the existing hospital-accounting pipeline is cleaned
- Additional event-study variants without a sharply different estimand

## Recommended research-question hierarchy

### 1. Incidence

**Question:** What economic and healthcare-utilization costs follow plausibly exogenous climate shocks?

Lead with the 2012 drought income result and Medicare morbidity. Treat debt, premiums, and hospital accounts as secondary ledgers.

### 2. Persistence

**Question:** When do these costs reverse, scar, or compound?

Lead with transition symmetry and cumulative exposure. State explicitly that persistence can reflect continuing causal harm, adaptation, migration, or changing composition.

### 3. Institutional and distributional incidence

**Question:** Who experiences the harm, and which systems record, absorb, or fail to price it?

Combine SVI, energy burden, safety-net hospitals, uninsurance, measurement failure, and absent premium pass-through. This may be stronger and more distinctive than a generic “inequality” essay.

## Immediate priorities

Before pursuing new alpha:

1. Resolve the county-year duplicate problem upstream and rerun affected models.
2. Rewrite all abstracts to reflect the log specifications, fragile employment evidence, and incoherent premium pass-through.
3. Lock a small set of headline estimands and freeze the specification search.
4. Build one master evidence table with claim, estimand, population, years, unit, identifying variation, inference, robustness status, and permitted language.
5. Decide whether the third essay is truly “inequality” or the stronger “institutional incidence and measurement.”
6. Write the full papers before adding another outcome family.

## Clarifying questions for the author

1. Has the committee formally approved replacing the proposed structural policy chapter with the Incidence/Persistence/Inequality structure?
2. What is the defense deadline, and will one essay serve as the job-market paper?
3. Must the three essays be independently publishable papers, or can they operate as three empirical chapters of one integrated dissertation?
4. Which contribution should the project primarily own: climate and household financial distress, climate-health utilization, persistence/scarring, or institutional failure to price and measure climate costs?
5. Is the author willing to demote medical debt and premiums from headline outcomes if the strongest version of the evidence requires it?

