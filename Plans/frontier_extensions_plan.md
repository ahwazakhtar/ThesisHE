# Frontier Extensions Plan: From Reduced-Form Evidence to Policy Microsimulation

**Purpose:** Map how far the project can be pushed — technically and in policy relevance — building on the delivered empirical engine. Anchored in the October 2025 proposal's Chapter 3 microsimulation spec (`Text/reference/v2_Akhtar_Proposal.pdf`, pp. 33–37), the committee memo's acknowledged departure (`Text/correspondence/committee_memo_ch3_structure.md`), and a full inventory of data/methods assets in hand.
**Compiled:** 2026-07-06. Companion document: `Plans/results_evolution_narrative.md`.

---

## 1. Where the frontier is

The empirical work (incidence, persistence, inequality, mechanisms, hospital heterogeneity) is delivered and deepened well beyond the proposal. The unbuilt frontier is **the top of the pipeline it was all meant to feed**: the proposal's fully specified **sufficient-statistics policy microsimulation** — a transparent calculator that translates the estimated elasticities into counterfactual ACA subsidy design under climate risk. The proposal committed to it verbatim (p. 3):

> "Chapter 3 develops a structural framework nesting consumers (plan choice and delinquency risk), insurers (premium setting under risk adjustment/reinsurance), and hospitals (capacity and financing constraints) under a distribution of local climate shocks. Calibrated to reduced-form elasticities from Chapters 1–2 … the model simulates counterfactual policies: climate-risk adjusters in payment, geographically targeted premium support, disaster-triggered cost-sharing waivers, and provider stabilization instruments."

The committee memo records that this was dropped when Chapter 3 became the "Unequal Weather" inequality essay, and proposes a ~2-week "sufficient-statistics policy section" as a bounded substitute (memo lines 64–81). That substitute is not yet executed. **The proposal's own design (pp. 33–37) remains the blueprint** — a cell-based model at rating area × year × income bin, driven by four estimated statistics:

1. **β_z** — claims/cost sensitivity to climate exposure (∂C/∂z)
2. **ρ** — premium pass-through of costs (∂P/∂C), 2SLS instrumenting claims with exposure, with an HHI interaction
3. **ε_enroll(y)** — enrollment elasticity to net premium, by income bin
4. *(optional)* utilization/OOP price elasticity by care setting

Policy engine: PTC = b(y) + σ·P̂ + g(z) — base generosity **b(y)**, subsidy slope **σ**, and a capped **geographic climate kicker g(z)**. Outputs: coverage by income & SVI tercile, net-premium affordability, federal outlays, premium dispersion, provider-pressure mapping, and logit consumer-surplus welfare accounting with efficiency–equity frontiers. Counterfactuals: σ ∈ {0.3, 0.5, 0.7}; targeted b(y) changes; kicker g(z) = min{κ·(z−z⁹⁰), ḡ}·1{z>z⁹⁰}; combined packages. Worked calibration: California.

## 2. Assets already in hand (and what each unlocks)

The inventory (see data-asset detail in section 7) shows the microsimulation is **more buildable now than when proposed**, because the mechanism and hospital tracks created most of its inputs:

| Asset (in repo today) | Current use | Microsimulation role |
|---|---|---|
| Benchmark Silver + Lowest Bronze premiums, rating-area mapped, 2014–2026 | Core outcome | The **P** in the PTC engine; premium dispersion output |
| **Plan-level HIX data** (`Data/HIX_Data/plan details/*.zip`, issuer×plan×county, metal tiers, deductibles, cost sharing) | Barely used (only 2 aggregate series extracted) | Household OOP exposure under alternative plan choices; metal-tier substitution margin |
| **Issuer county reports** (`Data/HIX_Data/issuer county report/`, 2014–2026) | Unused | Issuer-count/HHI **market-power moderator** for the pass-through ρ regression — exactly the eq. (2) interaction the proposal specifies |
| Estimated shock→premium and shock→income/employment coefficients (hardened) | Papers 1–3 | The **β_z** statistics, with the robustness gauntlet already run |
| Medicare Geographic Variation (~155 cols; 5 extracted), 2014–2023 | Morbidity channel | Dollar-denominated **claims-cost sensitivity** by county — the fallback for unavailable HIX claims data, exactly the proposal's fallback path (p. 34) |
| SVI, energy burden (LEAD, household-stratum granularity), SAHIE uninsured, ag dependence, industry composition | Moderators | **Distributional incidence** dimensions of every counterfactual |
| IRS SOI migration flows (2012–2021, county in/out/AGI) | One caveat test | **Population-response module** — people and income leave shocked counties; feeds enrollment-base dynamics |
| RMA crop-insurance indemnities | One buffer test | **Existing-policy benchmark** — the federal transfer already flowing to shocked places, against which a climate kicker is compared |
| Medicaid expansion status (`Code/medicaid_expansion.R`) | Hospital moderator | **Policy toggle** (expansion vs non-expansion regimes change the subsidy-eligible population) |
| Hospital-year panel (NASHP, ownership/safety-net/margin) | Ch. 2 | **Provider-pressure mapping** UC = κ0 + κ_z·z (proposal p. 36) and provider-stabilization counterfactuals |
| DiD-robustness toolkit on R 4.5.3 (`did`, `DRDID`, `HonestDiD`, `fwildclusterboot`, `TwoWayFEWeights`) | 2012 cohort only | Reusable validation machinery for **any new policy-shock design** |
| Zip↔county crosswalk, rating-area mapping, FIPS conventions | Core plumbing | Cell-construction machinery for rating area × income bin |

**Genuinely missing inputs** (all public, keyless or standard):
- **Marketplace enrollment by county × income bin** — CMS Marketplace Open Enrollment PUFs publish county-level plan selections with FPL-bin breakdowns (2015→). Needed for cell weights and ε_enroll.
- **Subsidy rule crosswalk** — applicable-percentage schedules by FPL and year (statutory; small lookup table; must handle ARPA/IRA cliff removal 2021–2025 and its scheduled 2026 expiry — which is itself a live policy experiment *inside* the panel).
- **Second-lowest-cost silver by rating area** — likely derivable from the plan-level HIX zips already in `Data/HIX_Data/`.
- **Climate projections** — USGS publishes **county-averaged CMIP6-LOCA2 time series 1950–2100** (27 models × SSP2-4.5/3-7.0/5-8.5), including threshold/extreme-event metrics (sciencebase.gov; loca.ucsd.edu). Drop-in projection layer for the county panel. (PDSI projections are the weak spot — use published scPDSI-CMIP6 products or temperature/precip-implied proxies, and say so.)

## 3. Tiered roadmap

Tiers are ordered by (value ÷ effort) and are separable — each tier is a complete, defensible deliverable even if the next is never built.

### Tier 0 — Hygiene before any extension (days)
1. **Reconcile `Text/drafts/thesis_paper_abstracts.md` with `5c615dd`**: the −2,011 "strengthens in low-ag counties" claim died in logs but still headlines Essay 1's abstract.
2. Finish the premium-mediation writeup loop (`Analysis/mediation/` is untracked; commit it) and fill the two `[TK]` denominators + two incomplete references flagged in Session 9.
3. Close the open verification gates in `conductor/tracks.md` where user-driven.

### Tier 1 — The committee memo's "sufficient-statistics policy section" (~2 weeks)
The bounded substitute already proposed to the committee (memo lines 64–81), now made concrete:
1. **Price the burden**: aggregate the hardened coefficients (drought→income −$1,451/capita ITT; cold employment dose-response; Medicare $/beneficiary morbidity costs) into a national annual dollar burden with CIs — each number anchored to a baseline, per NBER style.
2. **Benchmark against existing policy**: compare the implied uncompensated burden to actual RMA indemnity flows (`intermediate_rma_indemnity.rds`) — "the federal government already writes climate checks; they go to crops, not to health-finance."
3. **One geographic-targeting statement**: rank counties by (hazard × SVI × population) using the existing CHEI machinery; report the concentration of burden (e.g., share borne by top-decile counties) — the empirical case for *any* geographically targeted instrument.
4. Write as a §7 policy section using the `nber-economist-writing-style` skill.

*Risk: low. Uses only in-repo data. This is the minimum credible answer to "so what should policy do?"*

### Tier 2 — The proposal's microsimulation, faithfully but leanly (~4–8 weeks)
Build the cell-based calculator exactly as specified on pp. 33–37, with the proposal's own fallbacks:
1. **Cells**: rating area × year × FPL bin (4–6 bins), 2014–2023. Weights from CMS OEP county PUFs; rating-area aggregation via existing crosswalk. *(Respect the many-counties-one-price structure — premiums are rating-area draws, not county draws.)*
2. **β_z**: reuse hardened shock→premium coefficients; add Medicare standardized-cost sensitivity as the claims-cost fallback (proposal p. 34: premiums conditional on FE "serve as sufficient statistics for expected claims").
3. **ρ (pass-through)**: 2SLS of premiums on Medicare-proxied claims instrumented by exposure, interacted with an **issuer-count/HHI variable built from the unused issuer county reports**. *Honest caveat: the mediation track found premium pass-through incoherent at the county level — estimate ρ at the rating-area level where the price is actually set, and if it remains unstable, bound the simulation with ρ ∈ {0, literature values (~0.7–1.0 from ACA pass-through studies), estimated} as scenario bands rather than a point estimate. A fragile ρ becomes a sensitivity dimension, not a fatal flaw.*
4. **ε_enroll(y)**: estimate from OEP enrollment responses to net-premium variation induced by benchmark movements within rating area; calibrate against literature values (Finkelstein–Hendren–Shepard; Tebaldi) as a check.
5. **PTC engine + counterfactuals**: implement the accounting identity; run the proposal's σ/b(y)/g(z) grid; **add one counterfactual the proposal couldn't foresee — the 2026 enhanced-PTC expiry — which turns the model into a commentary on a live policy debate.**
6. **Outputs**: coverage, affordability, outlays, and welfare (logit CS) by income × SVI tercile; efficiency–equity frontiers; California worked calibration as promised.
7. **Engineering**: new `Code/microsim/` (R 4.5.3 side if any frontier packages needed; otherwise base pipeline), self-logging per build convention, `testthat` on the accounting identities (subsidy formula, aggregation, welfare) — identities are unit-testable in a way regressions are not.

*Risk: moderate. The pass-through estimate is the known weak joint (pre-bounded above). Everything else is accounting plus elasticities already estimated or calibratable.*

### Tier 3 — Frontier extensions (each ~2–6 weeks, independent)
Ranked by scientific payoff:

- **3a. Projection layer (highest payoff).** Attach USGS county-level CMIP6-LOCA2 projections (27 models, 3 SSPs, to 2100) to the estimated response functions, Hsiang et al. (2017, *Science*) damage-function style: project the health-finance and income burden to 2050 under each SSP with model-spread uncertainty bands, then re-run the Tier-2 subsidy counterfactuals under projected exposure. This converts the thesis from retrospective to forward-looking — "what does the ACA subsidy schedule need to look like in 2050?" *Caveats to own: extrapolation beyond support, adaptation held fixed (state the Lucas critique explicitly), PDSI projection weakness.*
- **3b. Population-response module.** Use IRS migration flows to estimate shock→out-migration/AGI-flow elasticities (the mechanism track already found drought→out-migration at p=0.05), and let cell populations respond in the simulation. Distinguishes "place burden" from "people burden" — directly answers the selection caveat in the mechanism verdict.
- **3c. Distributional deepening via LEAD strata.** The DOE LEAD data is household-stratum (income × tenure × building × fuel) but currently collapsed to two county scalars. Rebuild energy-burden incidence by income decile and add an energy-assistance lever (LIHEAP-style transfer) to the policy grid. This is the closest the project can get to true *spatial microsimulation* (synthetic-population methods per the 2025 systematic review, IOP *Environ. Res.: Climate*) without licensing restricted microdata.
- **3d. Hospital-finance module.** Extend the provider-pressure mapping into a mini provider ledger using the unexploited NASHP columns (payer mix, system affiliation): simulate a provider-stabilization instrument (disaster-triggered uncompensated-care fund) and the Medicaid-expansion toggle. Closes the proposal's "provider stabilization instruments" promise.
- **3e. Wildfire-smoke exposure retrofit (optional, closes a proposal gap).** NOAA HMS smoke-plume days + gridded smoke-PM2.5 are public and keyless; one processing script adds the proposal's missing headline hazard as a robustness/extension exposure for both the demand and hospital panels.

### Explicitly deprioritized
- Full structural equilibrium model (insurer bidding, plan choice logit estimated on microdata): months of work, restricted data (marketplace enrollee microdata), and the sufficient-statistics design was chosen over it *in the proposal itself*.
- Employer-sponsored-insurance arm from the 729 MEPS-IC files: real option, but a fourth paper, not an extension.
- Anything built on credit-bureau medical debt as the simulation outcome — it is the measurement-fragile series; debt appears only as a downstream narrative, never a calibration target.

## 4. Discipline rules (from the robustness journey)

The evolution narrative's lessons constrain the microsimulation:
1. **Calibrate only to survivors.** β_z inputs come from the hardened set (income scarring, cold dose-response, Medicare morbidity, premium levels). The 2012 employment effect and the levels-only heterogeneity results do not enter.
2. **ITT, not "effect of being droughted."** Simulated shock impacts inherit the first-onset ITT interpretation; dose counterfactuals use the cumulative-dose estimates, not scaled-up 2012 numbers.
3. **Event-specificity bands.** Where the pooled-cohort estimate differs from 2012 (employment), the simulation reports the range, not the headline.
4. **Uncertainty is a first-class output.** Propagate coefficient SEs (parametric draw or bootstrap of the elasticity vector) through the calculator; report simulation intervals, not just points. In Tier 3a, add climate-model spread as a second uncertainty layer.
5. **Rating-area price structure is respected everywhere** (many counties, one price; cluster accordingly).

## 5. Suggested sequencing and committee decision points

```
Tier 0 (days)  →  Tier 1 (§7 policy section, ~2 wks)  →  [Committee decision]
                                                        ├─ defend with Tier 1 only
                                                        └─ Tier 2 microsim (~4–8 wks)  →  [optional] Tier 3a projection
                                                                                        →  [optional] 3b–3e as appendices/post-defense papers
```

- **Decision point 1 (now):** send the committee memo; Tier 1 proceeds regardless (it is the memo's own proposal).
- **Decision point 2 (post-Tier 1):** Tier 2 is the difference between "a thesis with a policy section" and "a thesis that delivers the proposal's promised policy calculator." If the timeline allows one more chapter-scale effort, this is it — and Tier 3a (projections) is the piece that would carry a job-market paper beyond the dissertation.
- Tier 3b–3e are post-defense/publication extensions unless a committee member pulls one forward.

## 6. Proposal-vs-delivered status (reference)

| Promised (proposal page) | Status |
|---|---|
| Climate → ACA benchmark premiums, rating-area level (p.2) | Delivered |
| Climate → county medical debt (p.2) | Delivered (measurement-fragile) |
| Joint premium+debt elasticities / mediation channel (p.2, pp.15–16) | In progress (`Analysis/mediation/` — pass-through found incoherent; documented as a finding) |
| Exposure set incl. wildfire smoke + FEMA disasters (p.13, p.22) | Not built as framed (pivot to cold+drought); Tier 3e closes partially |
| SVI/uninsured distributional heterogeneity (p.16) | Delivered (Essay 3) |
| Hospital panel: HCRIS+S-10+AHA (p.21) | Substituted with NASHP HCT panel (delivered) |
| Market-power & Medicaid-expansion heterogeneity (p.3) | Partial (thinner than promised; Tier 2 issuer-HHI + 3d deepen) |
| Provider credit-spread/financing margin (p.3) | Not started (deprioritized) |
| **Ch. 3 sufficient-statistics microsimulation (pp. 3, 33–37)** | **Not started — this plan's Tier 2** |
| Structural platform: reduced-form → counterfactual guidance (p.3) | Not started — Tiers 1–3 |

## 7. Key external references for the frontier

- Hsiang et al. (2017), "Estimating economic damage from climate change in the United States," *Science* — the reduced-form → projection → damage-function architecture (Tier 3a template). https://www.science.org/doi/10.1126/science.aal4369
- Systematic review of spatial microsimulation for climate-health policy (2025), *Environ. Res.: Climate* — situates Tier 2/3c methodologically; only ~7 such models exist, so a county-calibrated US health-finance microsim is publishable methods territory. https://iopscience.iop.org/article/10.1088/2752-5295/ae7598
- USGS CMIP6-LOCA2 county-level time series and extreme-event metrics, 1950–2100 — the projection input. https://www.usgs.gov/data/cmip6-loca2-threshold-and-extreme-event-metric-projections-1950-2100-contiguous-united-states ; https://loca.ucsd.edu/
- Climate damage functions review (*REEP* 2020) — framing for translating panel elasticities into damages. https://www.journals.uchicago.edu/doi/10.1093/reep/rez021
- Deryugina et al. (2019) — the morbidity-channel anchor already reproduced in-panel; its mortality-cost apparatus is the model for dollarizing the Medicare channel.
