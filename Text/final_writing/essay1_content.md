# Essay 1 — Pre-filled Paragraph Content

**How to use:** each ¶ block lists its content units **in narrative order**. Turn each unit
into one to two sentences in your own words, in sequence; the `→` line is the hand-off idea
into the next paragraph. Units are deliberately telegraphic — they are ingredients, not prose.
Flags: **[DECIDE]** author choice needed · **[CITE]** literature reference for you to supply ·
**[BUILD]** exhibit not yet generated. Companion map: `essay1_outline.md` (row/exhibit keys
live there; numbers here are already permitted-language-compliant).

Baselines used throughout (**updated 2026-08-13 to the registry exhibit E1-T1, post-dedup**
— see `TK_resolutions.md` §B): mean county PCPI **$53,145** (2023 USD) → −$1,311 ≈ **2.5%**
(the raw event contrast — per the 2026-08-17 reframe, cite it only alongside its
farm/nonfarm decomposition; the baseline-invariant nonfarm decline is −$261 to −$414 ≈
**0.5–0.8%**);
mean county employment **48,068**; mean medical-debt share **0.19**; Medicare standardized
spending **$10,359/beneficiary**; ED visits **629 per 1,000**; mean benchmark premium
**≈$374/month** county-master / **≈$366/month** RA panel (both monthly, 2023 USD). All
dollars = **2023 dollars**. Treated-cohort anchors: median 2012 population **12,817**;
cohort total **5.29M** residents.

> **Note (2026-08-13):** the `[TK]` items below were resolved in the *harness*
> (`essay1_harness.html`), which is the working surface — see `TK_resolutions.md` for
> every value, source, and confidence level. This file keeps the original marks as the
> audit trail of what needed resolving.

> **RESTRUCTURE (2026-08-17, Medicare-led — `Plans/essay1_restructure_20260817.md`,
> advisor sign-off pending):** the essay is now Medicare-led with the drought natural
> experiment demoted to Appendix A. New map: §4 Medicare (main result, WRITE FIRST) ·
> §5 Financial ledgers · §6 Household economic capacity (NEW) · §7 Interpretation ·
> §8 Conclusion · Appendix A.1–A.4 = old §4/§5/§6/§7. Section labels below are renamed;
> **the harness is authoritative** — a few inline cross-references in ingredient lines
> may still cite pre-restructure section numbers.

---

# A.2 The event contrast and its decomposition (Appendix A)
**(REFRAMED 2026-08-17 after the baseline decomposition — see
`Analysis/did/did_2x2_baseline_sensitivity_drought2012.csv` and
`did_farm_nonfarm_eventstudy_drought2012.csv`. The raw −$1,311 is now presented as a
raw event contrast that the section decomposes; the durable drought–income evidence is
the window-stable distributed-lag relationship. Evidence-table Row 1 amended.)**

### A.2 ¶1 — The raw event contrast
1. Design recap in one clause: 139 first-onset counties vs 2,534 never-exposed, county+year FE, ITT of the 2012 onset.
2. Raw contrast: real per-capita income fell **$1,311** relative to never-exposed controls (analytic p=0.028) — the mean treated-control gap over the onset year and the eleven years that follow.
3. Anchor: against the mean county PCPI of $53,145 (E1-T1), ≈2.5%.
4. Geography anchor: the 139 treated counties (Georgia, Mountain West, Plains) — an event- and geography-specific ITT.
5. Signpost: this section asks what that contrast measures — inference first, then composition, then a decomposition that separates farm commodity-price movements from the drought's economic damage.
→ with 17 treated states, analytic p-values are not the right yardstick — inference next.

### A.2 ¶2 — Robust inference
1. Few-cluster problem: treated counties sit in 17 states; state-clustered analytic SEs can overstate precision.
2. Wild-cluster bootstrap (Webb weights): **p=0.036**, CI **[−2,911, −138]** — excludes zero.
3. Randomization inference: **p=0.0075**.
4. Interpretation: the contrast is not a cluster-count artifact (ties back to the §3 AAIW paragraph). Inference and interpretation are separate questions; the next paragraphs turn to interpretation.
→ composition first.

### A.2 ¶3 — Composition (doubly-robust check)
1. Concern: treated counties are more rural/agricultural than the average never-exposed county; simple 2×2 could load composition differences.
2. DRDID (covariate-adjusted, doubly robust): ATT **−$1,451** (SE 515, CI [−2,461, −441]) — conditioning on observables does not erode the contrast.
3. Caveat to carry: DRDID shares the design's single pre-year (2011) baseline, so it does not address baseline timing — that is ¶4–¶5's job.
→ what does the response look like over event time?

### A.2 ¶4 — Dynamics and the baseline question
1. Within-panel event study around the 2012 onset: gap opens at onset (−$1,561, p=0.008) and year one (−$1,609, p<0.001), narrows through 2015, re-widens to −$1,300…−$1,900 in the later post years; averaging identity: −$1,311 = mean of the twelve post-year gaps (`Code/diagnostics/eventstudy_full_window_drought2012.R`).
2. Extending leads (2001–2010; farm-data window): the 2008–2010 gaps sit at −$1,459 to −$1,591 relative to 2011 — statistically indistinguishable from zero (p=0.17–0.32) but of the same magnitude as the post-period gaps.
3. State the implication plainly: the pooled ATT is baseline-dependent — widening the pre-period to 2009–2011 moves it from −$1,311 (p=0.028) to −$285 (p=0.64) (`did_2x2_baseline_sensitivity_drought2012.csv`).
4. Disarm setup: this pattern could reflect either a genuine anticipation-free design failing parallel trends, or a treated-specific income spike in 2011 itself. The county income accounts let us test which — decomposition next.
→ separate farm from nonfarm income.

### A.2 ¶5 — Farm and nonfarm decomposition
1. BEA CAINC5N farm earnings (2001–2023, 2023 USD): treated-county farm income per capita spiked to **$4,339 in 2011** vs $1,903–2,438 over 2007–2010, while controls rose far less ($2,404 vs ~$1,325–1,796) — 2011 was the record farm-income year (commodity-price peak).
2. The 2008–2010 leads decompose ≈85% into the farm component (−$1,293 to −$1,358 of −$1,459 to −$1,591); nonfarm leads are −$133 to −$265.
3. Farm-component ATT: −$907 (p=0.13) against the 2011 baseline; **−$14 (p=0.95)** against pooled 2009–2011 — consistent with mean reversion from the 2011 peak rather than drought damage.
4. Nonfarm ATT is baseline-invariant: **−$394/−$261/−$261/−$286/−$414** across pre-periods starting 2011/2010/2009/2007/2002 — sign-stable, ≈0.5–0.8% of mean PCPI, onset-year gaps −$536 and −$542 (p≈0.08), never significant at conventional levels.
5. Reading (NBER-hedged): the raw −$1,311 conflates reversion of farm income from its 2011 commodity-price peak with the drought's economic damage; the component that survives every baseline choice is a modest, imprecisely estimated nonfarm decline.
6. Connect to the thesis theme: county income ledgers in agricultural places embed commodity-price cycles — separating them is part of the essay's measurement contribution.
→ what, then, is the durable form of the drought–income relationship?

### A.2 ¶6 — The durable form and magnitude in context
1. Window-stable distributed-lag evidence (advisor 1.3): PDSI coefficient **−$99 to −$132** per unit across 1990/2000/2011 start years, precision improving; full window makes the contemporaneous term significant (**−$149, p=5×10⁻⁶**); adding 2024 changes nothing. This does not depend on any single baseline year.
2. Positioning: the distributed-lag relationship is the primary drought–income evidence; the 2012 experiment contributes the decomposition — an audit of what event contrasts in agricultural counties measure.
3. Literature yardstick **[CITE: Deschênes–Greenstone; Deryugina 2017]**: the nonfarm event magnitude (≈0.5–0.8% of income) and the distributed-lag response are within the range of climate-economy income effects; do NOT cite the $6.9B/−$1,311 aggregate arithmetic (superseded).
4. Hand-off: whether losses reverse, scar, or compound → Essay 2.
→ the identification case in full (§6 pre-trend test now read alongside the decomposition).

---

# A.3 Identification and falsification (Appendix A)

### A.3 ¶1 — Two-decade pre-trend
1. The decisive parallel-trends evidence: BEA county income 1990–2011 (21 pre-periods; all 139 treated and 2,483/2,534 controls covered).
2. Differential linear pre-trend: **−$69/year (SE 89, p=0.44) — flat**.
3. Honest disclosure: the event-study joint Wald test rejects (F=6.9, p<0.001) — this is rural-vs-urban business-cycle wiggle, not secular drift; it is exactly the composition the DRDID conditions on, and doing so strengthens the effect (−$1,451).
4. Why no HonestDiD: the 2012 cohort has no in-panel pre-period, so HonestDiD cannot run; the two-decade BEA test is the substitute, and it also covers the "future shocks predict past outcomes" falsification.
→ next: is the result driven by any single treated state?

### A.3 ¶2 — Leave-one-treated-state-out
1. Drop each of the 17 treated states in turn: ATT envelope **[−1,687, −914]**.
2. The envelope never exits the WCB confidence interval.
3. Dropping Colorado or Nebraska lifts the analytic p to 0.075/0.057 — this is the few-cluster sensitivity that motivated using WCB in the first place, and WCB already accounts for it (frame as design working as intended, not as a discovered weakness).
→ from geography to timing: placebo onsets.

### A.3 ¶3 — Placebo onsets
1. Randomly reassign the onset year across the panel, B=1,000 draws.
2. Placebo distribution centered on zero; the actual estimate sits in the far tail — two-sided **p=0.009**.
→ from timing to space: what if the drought hurt neighbors of treated counties too?

### A.3 ¶4 — Spatial robustness (spillovers + Conley)
1. SUTVA concern: drought in county A can depress income in adjacent county B (shared labor and product markets).
2. Own-vs-neighbor decomposition is unidentified here — own and neighbor exposure correlate at r=0.94–0.97 — so do not over-claim the split.
3. What is identified: the neighbor-exposure block is jointly significant (p≈0.006), and own+neighbor total exposure effects **exceed** the own-only baseline (income −157 vs −133 per unit; employment −1,090 vs −714).
4. The standing qualifier (use this framing wherever the headline appears): county coefficients capture *local* exposure; adjacent-county exposure adds a same-signed regional component the local coefficient understates — the headline is a **lower bound on regional exposure**, and spillovers amplify rather than confound.
5. Conley spatial SEs out to 300 km: income worst case p=0.008 (200 km ≈ state clustering: p 0.0029 vs 0.0026).
→ remaining specification checks, briefly.

### A.3 ¶5 — Specification roll-up
1. Humidity: adding PRISM dew-point leaves headline coefficients essentially unchanged (cold-debt example stable to three significant figures, 0.01363→0.01368) — heat/drought bins are not proxying humidity.
2. Demographics: ACS aging/tenure/in-migration controls leave 94–104% of each effect intact — clean nulls closing two confounding channels; caveat: ACS smoothing limits detection of fast demographic responses.
3. Threshold sensitivity (p90 vs z-based shock definitions) leaves conclusions unchanged; full grids in Appendix D.
→ close the section by drawing the boundary of what is claimed.

### A.3 ¶6 — What this design does not establish
1. The estimand is the ITT of the 2012 first onset for the treated geography — event-specific by construction.
2. The design does not identify mechanism (agricultural vs labor vs demand channels) — direct evidence on a health channel comes separately in §8.
3. Whether the estimate generalizes to other droughts is an empirical question with its own section — next.
→ §7.

---

# A.4 External validity, pooled cohorts, and employment (Appendix A)

### A.4 ¶1 — The question and the tool
1. Question: is 2012 a window onto droughts generally, or one event's fingerprint?
2. Answer via estimands, not assertion: staggered multi-cohort design over all first-onset cohorts, doubly-robust frontier estimator (`did::att_gt` / Callaway–Sant'Anna aggregation).
→ the pooled answer.

### A.4 ¶2 — The pooled answer
1. Pooled onset effect (e=0): **−$324 (SE 276) — null**.
2. Pooled long-run simple ATT: **+$350 (SE 585) — null/reversed**.
3. Conclusion, stated plainly: the 2012 income effect is event-specific **even at onset**; the paper claims the event, not a drought-response function.
4. (Never resurrect the manual aggregation's −$1,050/p=0.002 — invalid independence SEs; the manual layer is descriptive only.)
→ why would 2012 differ?

### A.4 ¶3 — Why 2012 differs (hedged)
1. Candidates, each one sentence, all "consistent with": (a) severity — 2012 was an extreme-of-extremes event; (b) first-onset sharpness vs partially adapted later cohorts; (c) agricultural-calendar timing of the 2012 onset; (d) control-group composition differs across cohorts.
2. Do not adjudicate among them; the data cannot.
→ the same event-specificity discipline applied to the secondary outcome: employment.

### A.4 ¶4 — Employment: the fragile secondary
1. The 2012 event also shows an employment ATT of roughly **−2,000 jobs** (analytic p=0.0001; against mean county employment of 50,113, ≈4%).
2. It clears the few-cluster bar (WCB p=0.003; RI p=0.037) and the LOO envelope [−2,156, −1,854] never flips significance.
3. But — give this equal prominence — it attenuates ~58% under DRDID (−871, SE 433, CI barely excluding zero) and **reverses sign** in the pooled estimator (+2,609, SE 2,245) with positive pre-trends.
4. Verdict language: the fragility is conditioning/generalization, not cluster count; report as event-specific and secondary — explicitly not a co-headline with income.
→ real costs established; now the direct health-channel evidence.

---

# Appendix B — Shock-definition and horizon robustness (NEW 2026-08-17)

### B.1 — Climate-baseline horizon
1. Scope fact first: drought (PDSI ≤ −4) is an absolute threshold — baseline-independent. Exposed definitions: temp/precip z-scores (baseline mean/SD) and national CDD/HDD p80 cutoffs.
2. Variants: 1990–2000 (primary) / 1990–2005 / 1990–2010 — both alternatives end pre-2011 → no look-ahead for the outcome window.
3. Validation: 1990–2000 rebuild matches shipped flags **0/40,781 mismatches**; replicas reproduce published coefficients to the digit (`Analysis/advisor_robustness/baseline_horizon_sensitivity.csv`).
4. Stability: cutoffs move ≤~2% (CDD p80 1902→1943; HDD 5752→5702); flag shares shift ≤1.1pp; Medicare heat spending **$112/$107/$113** (L0), **$176/$179/$180** (L1); ED 7.8/7.3/8.7 and 9.4/9.4/10.3; county cold employment −714/−607/−613 jobs (L2), p=.035–.039.
5. The one sensitivity: state cold→debt L1 attenuates **1.35pp (p=.012) → 1.03 (p=.027) → 0.85 (p=.044)** — sign-stable, significant at 5% under every baseline; mechanism = warming-period baseline raises the reference mean, so z<−1.5 selects milder cold years. Cite as a **0.85–1.35pp range** wherever baseline robustness is at issue.
→ estimation horizon.

### B.2 — Estimation-horizon (lag-structure) sensitivity
1. Advisor item 1.4 (`horizon_sensitivity.csv`): h_max ∈ {2,3,4,5} in the event-study machinery.
2. No sign flips; h=0–2 headline coefficients move <1 SE under extension; only SHORTENING to a 2-year horizon is consequential (understates cold employment).
3. Longer horizons inform rather than destabilize: debt scar transient by h=4; cold employment persists h=3–4 (p=.009/.006) → Essay 2.
4. Note: the other advisor-package subsections (spillovers, clustering/AAIW, MAD scaling — `Analysis/advisor_robustness/synthesis.md`) can join this appendix at drafting.

---

# §4 Medicare morbidity and utilization — the main result (WRITE FIRST)

### §4 ¶1 — Why Medicare leads (REFRAMED 2026-08-17)
1. The essay's question is about healthcare costs and their recording — start where the recording is best: administrative, near-universal, price-standardized.
2. Medicare (CMS Geographic Variation): 65+/disabled, standardized payments strip price variation — direct observation of utilization free of insurance-composition churn.
3. Framing sentence (binding): **direct measurement of a morbidity channel** — no inference from economic damage; not extended to working-age households.
→ design in one paragraph.

### §4 ¶2 — Design
1. Distributed-lag FE: county+year FE, state-clustered; within-county variation in heat/cold/AQI shock bins; lags 0–2.
2. Sample: 30,641 county-years, 3,124 counties, 2014–2023; outcomes: standardized per-beneficiary spending, ED visits per 1,000.
→ heat first.

### §4 ¶3 — Heat results
1. Spending: **+$112** per beneficiary contemporaneous (p=0.013), **+$177** at one-year lag (p=0.001), +$75 at two years (p=0.003).
2. Anchor each: on a $10,359 base, that is **1.1% / 1.7% / 0.7%**.
3. ED visits: **+7.8 per 1,000** (p=0.006), +9.5 at L1 (p=0.0002) — on a base of 629, **1.2% / 1.5%**.
4. Note the lag structure itself: the L1 peak is the "deferred cost" pattern in the paper's title showing up in administrative health data.
→ cold and air quality complete the picture.

### §4 ¶4 — Cold and AQI
1. Cold: spending +$85 and ED +9.0 per 1,000 at the two-year lag — slower-moving than heat.
2. AQI: ED **+4.8 per 1,000** (p=0.0003), +3.3 at L1, +2.8 at L2.
3. Figure E1-F4: dynamic profiles by hazard.
→ robustness.

### §4 ¶5 — Robustness
1. Anderson summary index of utilization: heat L1 p=0.007, cold L2 p=0.002 — not an artifact of outcome selection.
2. Multiple testing: heat→ED and AQI→ED survive sharpened BKY q<0.05.
3. Conley SEs are tighter than state-clustered; frontier recurring-treatment estimator (`did_multiplegt_dyn`) confirms heat ≈ +$80 at h=2.
4. External anchor: reproduces Deryugina et al. (2019) in-panel **[CITE]**.
5. Non-agricultural: Drought×Ag interaction null — the morbidity channel needs no farm-income intermediary.
→ the same "outside agriculture" point holds for the labor margin.

### §4 ¶6 — The labor-exposure margin (mechanism-supporting)
1. Claim ceiling (binding): the lagged burden **operates substantially outside agriculture** — not "primarily through" any single channel.
2. Heat × climate-exposed non-farm labor share, on log employment: **−0.0052 (p=0.006)**; survives division×year FE (−0.0042, p=0.015) and Conley SEs (p=0.033).
3. Heat × energy-burden z: **−0.0084 (p=0.005)**; survives division×year FE (−0.0078, p=0.002) and the joint horse-race (−0.0068, p=0.019).
4. Status: interaction gradients — supporting evidence, not headline employment levels; energy burden's *income* margin is not robust and is not claimed.
5. (Retired figures −2,011/−721 must not appear; they die in logs.)
→ scope seam before moving to ledgers.

### §4 ¶7 — Scope discipline
1. Plain statement: the Medicare population (65+/disabled) is not the population of the income result, nor of working-age credit-bureau debt.
2. So the paper claims triangulation — real income costs (§5) and directly measured morbidity (§8) coexist after climate shocks — not an identified chain from one to the other.
→ which financial ledgers record any of this? §9.

---

# §5 Financial-ledger responses: debt and ACA premiums

### §5 ¶1 — Section logic
1. Two ledgers, two functions: credit-bureau medical debt (does the harm get *recorded*?) and ACA premiums (does it get *priced*?).
2. Preview: recorded partially and with lags (debt); not priced locally in any coherent way (premiums).
3. Exhibits: ledger table E1-T7; comparison figure E1-F5 **[BUILD at drafting]**.
→ debt first, cold shock leading.

### §5 ¶2 — Debt: cold
1. Cold shock → medical-debt share **+1.35 pp at a one-year lag** (state FE, p=0.012); the county mirror gives +1.2 pp (p<0.001) — always cite each figure with its level.
2. Anchor to the mean debt share [pull the mean from the descriptive table when drafting].
3. Status: a lagged **association** (distributed-lag FE), not a causal 2×2 like §5.
4. Robustness: survives the stricter p90 shock definition (+1.38 pp, p=0.003) and humidity adjustment (0.01363→0.01368).
5. Caveat co-located: the county cell is sample-fragile — significant on the full panel, null on the control-observed subsample; a measurement caveat, not a bad-control problem.
→ drought's debt response is weaker and level-dependent.

### §5 ¶3 — Debt: drought **[DECIDE — recommended resolution below]**
1. County level: **+0.54 pp at a two-year lag** (p<0.01). State primary FE: 0.72 pp, **p=0.18 — not significant**.
2. State the disagreement plainly: significance depends on the level of aggregation; the prose must not paper over it.
3. Forward sentence: the robust drought→debt object is dynamic — the onset–exit asymmetry (the "scar") in Essay 2 — not this contemporaneous lag level.
→ why bureau debt behaves this way.

### §5 ¶4 — Debt: why fragile
1. Bureau medical debt requires an insurance relationship, a billed encounter, and a credit file — three filters between harm and record.
2. Reporting-rule changes over the window alter what enters the bureau file (Appendix F).
3. One sentence: Essay 3 develops the full measurement critique (visibility gradients); here it suffices that debt is a *selective* ledger.
→ from recording to pricing: premiums.

### §5 ¶5 — Premiums: design
1. Institutional facts drive the spec (from §2): rates set at rating-area level, reviewed per state, filed mid-year-t−1 on experience through ~t−2 → only **lagged** shocks (t−2 primary) can be in the insurer information set.
2. Two-level estimation at the levels the institutions use: **rating-area×year primary** (RA + state^year FE, population-weighted, state-clustered) and **state×year secondary** (state + year FE).
3. County-level premium specs are shown only as a labeled transparency trail — ≈86% of premium variance is state×year, so a county+year-FE premium regression is confounded.
→ results.

### §5 ¶6 — Premiums: the null
1. The pattern is sign instability across the institution's own levels: cold t−2 runs **−$15.5 (county) → +$12.6 (RA) → −$16.7 (state)**; heat runs **+$19.5 → −$10.5 → +$93**; drought is null at every level.
2. Verdict: **no coherent local pass-through** — a stable price response would keep its sign as aggregation moves through the levels at which prices are actually set.
3. Dismiss the one big number: the between-state heat coefficient (+$54–93/month) is ~10× too large for a claims channel and state-level cold is mis-signed against this essay's own Medicare result (cold *raises* spending) — a temperature correlate of premium levels, not pricing.
→ how much pass-through can the data rule out?

### §5 ¶7 — Premiums: equivalence bounds
1. Benchmark: full pass-through of the measured morbidity costs ≈ **$9.33–$14.75 per member-month**.
2. Drought: β=3.13 (SE 2.60), equivalence bound δ*=$7.40 → the data **rule out pass-through larger than 50–79% of the morbidity benchmark** — the tight bound (this sentence is drought-only, binding).
3. Heat (δ*=$24.6) and cold (δ*=$22.0) exceed the benchmark band → equivalence with full pass-through is *not* rejected; those responses are only bounded at ≈5–8% of the ~$366 mean monthly premium.
4. Language check: no blanket "insurers leave climate costs unpriced" — hazard-specific throughout.
→ the mediation corollary.

### §5 ¶8 — Mediation corollary
1. If premiums don't respond, the shock→debt effects cannot run through premiums: **92–99%** of each shock→debt coefficient survives premium adjustment (drought L2: 98.7%; cold L1: 92.2%).
2. Label: a difference-method **decomposition, not causal mediation**; RA-level premiums make the mediated share a lower bound.
→ why the null makes institutional sense.

### §5 ¶9 — Institutional interpretation
1. The null is explained, not anomalous: a single statewide risk pool, a geographic rating factor limited to unit costs, and §153 federal risk adjustment all mute any *local* claims signal before it reaches a local premium.
2. Permitted framing: regulated pricing does not *locally* price the environmental lag structure — the "unpriced margin" is the institutional-null contribution (the old actuarial-repricing narrative is retired).
→ close the ledger section with the spending contrast.

### §5 ¶10 — Systemic spending null
1. State per-capita health spending shows no robust climate signal and tracks income and unemployment (unemployment p=0.06).
2. Function of this fact: it is *why* the paper looks for climate costs in lagged household and administrative ledgers rather than in contemporaneous system spending — the costs are real (§5, §8) but system-level spending aggregates don't show them.
3. [If you prefer this as motivation, move it to §2 or the introduction — it must appear exactly once.]
→ §10.

---

# §6 Household economic capacity: income and employment (NEW 2026-08-17)

### §6 ¶1 — Why economic capacity, and the durable income result
1. Bridge logic: medical costs become medical debt when household budgets cannot absorb them — §5's ledger results presuppose a financing margin; this section documents it.
2. Durable form: distributed-lag drought–income relationship, window-stable (PDSI coefficient **−$99 to −$132** across 1990/2000/2011 starts; contemporaneous **−$149, p=5×10⁻⁶** full window; 2024 adds nothing).
→ the 2012 event, summarized.

### §6 ¶2 — The 2012 event, summarized (full treatment: Appendix A)
1. Raw 2×2 contrast −$1,311 (≈2.5%; WCB p=0.036, RI p=0.0075) over the onset year + eleven following.
2. Decomposition: ~$900 = farm income reverting from the record 2011 commodity-price peak ($4,339/capita treated vs $1,903–2,438 in 2007–10); farm ATT −$907→−$14 under pooled baselines.
3. Baseline-invariant nonfarm: −$261 to −$414 (≈0.5–0.8%), sign-stable, onset-year gaps p≈0.08, never conventionally significant.
4. Measurement lesson (contribution): agricultural-county income ledgers embed the commodity-price cycle; event contrasts inherit it unless decomposed. Exhibit: E1-F6.
→ employment.

### §6 ¶3 — Employment, and the bridge to interpretation
1. 2012 event: ~−2,000 jobs/county (≈4% of mean 48,068; clears WCB/RI) but attenuates ~58% under DRDID, reverses sign pooled — event-specific, secondary (Appendix A.4).
2. ACS employment starts 2011 — no pre-onset leads exist; matching caution.
3. Close: capacity results support the plausibility of §5's debt responses without an identified chain.
→ interpretation and limits.

---

# §7 Interpretation and limitations

### §7 ¶1 — What the three results jointly say
1. One-sentence synthesis: after climate shocks, real local income costs exist (H1), morbidity is directly measurable in administrative health data (H2), and the regulated pricing institution does not coherently price either locally (H4).
2. The connective claim is triangulation across ledgers that observe different populations under different rules — explicitly not an identified propagation chain.
→ boundaries.

### §7 ¶2 — External validity
1. The income estimate: event-specific ITT, treated-geography; pooled estimator says it does not generalize even at onset.
2. Medicare: 65+/disabled only, 2014–2023.
3. Premiums: ACA individual market, marketplace era 2014–2025; the tight bound is drought-only.
→ measurement.

### §7 ¶3 — Measurement limits
1. Debt: bureau artifact — insurance, billing, credit-file filters (consequence: understates hardship where coverage/credit access is thin — Essay 3's subject).
2. Premiums: a regulated price, not a marginal-cost readout; a null is informative about institutions, not about costs being absent.
3. ACS-based moderators smooth over time → fast demographic adjustment is hard to detect.
→ what would move the needle.

### §7 ¶4 — What would change the conclusions
1. Working-age administrative utilization data (all-payer claims) would test the morbidity channel where debt lives.
2. Patient-flow/catchment-based hospital exposure would sharpen provider incidence (currently location-county).
3. A longer post-2012 horizon would tighten persistence bounds (Essay 2 pushes this as far as the panel allows).
→ conclude.

# §8 Conclusion

### §8 ¶1 — Findings restated (REORDERED 2026-08-17, Medicare first)
1. Question restated in one sentence (healthcare costs + which institutions record/price them).
2. Three findings, one sentence each, Medicare first: Medicare +$112/+$177 per beneficiary and +8–10 ED visits/1,000 (65+/disabled; direct, non-agricultural); no coherent ACA pass-through (sign-unstable across levels; drought bounded at 50–79% of morbidity costs); household capacity strains — window-stable distributed-lag income relationship, with the 2012 event decomposing into farm commodity-price reversion plus a modest, imprecise nonfarm decline (−$261 to −$414, sign-stable across every baseline).
→ the lesson.

### §8 ¶2 — Institutional lesson + baton
1. The harm is *recorded* where administration is universal (Medicare, BEA income), *selectively recorded* where access filters intervene (bureau debt), and *not locally priced* where regulation pools risk statewide (ACA premiums).
2. Hand-offs: whether these costs persist or compound → Essay 2; who bears them and when ledgers under-record them → Essay 3. One sentence each.
→ policy close.

### §8 ¶3 — Policy close
1. For adaptation and health-finance policy: cost estimates built from any single ledger will miss systematically; the sufficient-statistics synthesis (final chapter) aggregates only within transparent scenario bounds.
2. No new numbers here; end on the institutional point, where idiom is permitted.

---

# §2 Institutional and conceptual background (write after results sections)

### §2 ¶1 — Conceptual frame
1. Display the schematic (writing plan §5): climate exposure → {health/utilization; labor productivity & local income; household liquidity; provider demand}, each observed through a different institution {Medicare | employers | ACA rating areas | credit bureaus | hospitals}.
2. One sentence per arrow, defining the outcome ledger it maps to in this essay.
→ why the ledgers can disagree.

### §2 ¶2 — Ledgers disagree informatively
1. Each institution differs in eligibility (who is observed), geography (the level at which the record is kept), rules (what triggers a record), and timing (when it appears).
2. Therefore identical underlying harm can produce different — even opposite-signed — ledger responses; the pattern of recording is itself an economic object.
3. Disarm in advance: apparent inconsistency across outcomes below is measured, expected, and interpreted — not noise to be averaged away.
→ the two institutions needing detail: ACA pricing and bureau debt.

### §2 ¶3 — ACA premium institutions
1. Rating-area price setting; state regulatory review; single statewide risk pool per insurer-market.
2. Geographic rating factor may reflect unit costs only (not local morbidity); §153 federal risk adjustment redistributes claims risk across insurers statewide.
3. Rate calendar: plan-year-t rates filed ~mid-t−1 on experience through ~t−2, locked before the plan year — no mid-year re-rating.
4. Two implications, stated now and used in §9: only lagged shocks can enter the information set; and any local claims signal is institutionally muted before reaching a local premium.
→ bureau debt.

### §2 ¶4 — Credit-bureau debt institutions
1. The three filters: insurance relationship → billed encounter → credit file; hardship failing any filter never enters the ledger.
2. Reporting-rule changes over the window (collection thresholds, reporting delays) shift the recorded object over time (Appendix F).
3. Cross-ref: Essay 3 shows the response is *smaller* where uninsurance is higher — the visibility gradient.
→ the event that anchors the causal design.

### §2 ¶5 — The 2012 drought event
1. Meteorology: 2012 = the most severe/extensive U.S. drought in decades **[CITE: e.g., NOAA/Hoerling-type retrospective]**; extreme drought defined here as PDSI < −4.
2. First-onset geography in this panel: Georgia, the Mountain West, the Plains (say explicitly this is *not* the popular "Midwest" image).
3. Treated economies range from agricultural to not — which matters later (§8: the burden operates substantially outside agriculture).
→ data.

# §3 Data and construction of shocks (SHARED SPINE)

### §3 ¶1 — Panel scope
1. County panel 2011–2023: ~3,100 counties in estimation samples; master certified unique on county×year (118,732 rows, 3,232 counties, build-time assertions).
2. State panel ~1996–2025 carries the longer debt/premium series; all dollars deflated to [state the base year — pull from `create_state_master.R` when drafting].
→ shocks.

### §3 ¶2 — Climate data and shock definitions
1. Inputs: NOAA temperature/degree-days, PDSI; PRISM humidity (robustness); EPA AQI.
2. Shock bins: High_CDD (heat), High_HDD (cold), extreme drought (PDSI<−4), High_AQI — each defined against the county's own historical baseline via z-scores (state the window and threshold z>1.5 / pdsi rule precisely from `analysis_pre_processing.R`).
3. Continuous precipitation z enters all county models; a reviewer-requested wet-extreme bin (z>+1.5) yields 0/12 significant cells at BKY q<0.10 — the hazard family is complete; appendix J.
→ outcomes.

### §3 ¶3 — Outcomes by ledger (one table: E1-T1)
1. BEA per-capita personal income (county, annual); civilian employment; Urban Institute credit-bureau medical-debt share; ACA benchmark premiums (rating-area, 2014–2025); CMS Geographic Variation Medicare spending/utilization (65+/disabled, 2014–2023).
2. For each: population observed, geographic level, window — the table does the work; prose highlights only that the windows and populations *differ by design* (the ledger logic).
→ moderators.

### §3 ¶4 — Moderators used in this essay
1. Climate-exposed non-farm labor share (construction/outdoor industries) and DOE LEAD energy-burden z-score.
2. SVI and hospital-side moderators belong to Essay 3; one cross-reference sentence only.
→ estimation conventions.

### §3 ¶5 — Fixed effects and inference (the AAIW paragraph)
1. All FE models: `fixest`, county+year (state+year for state panel), SEs clustered at the state level.
2. Justification per Abadie–Athey–Imbens–Wooldridge (2023) **[CITE]**: clustering follows the level of treatment assignment/correlation — climate shocks are spatially correlated well beyond counties.
3. Evidence: county clustering is anticonservative by up to seven orders of magnitude on headline p-values; Conley (200 km) SEs ≈ state-clustered (p 0.0029 vs 0.0026); every defensible level leaves the headlines intact (worst case, Conley 300 km: income p=0.008, employment p=0.029).
4. Lift the full paragraph structure from `Analysis/advisor_robustness/clustering_justification.md`.
→ measurement preview.

### §3 ¶6 — Measurement limitations preview
1. One sentence each, full treatment deferred: debt = bureau artifact (§9 ¶4); premiums = regulated price (§9 ¶9); Medicare = 65+/disabled only (§8 ¶7).
→ design section.

# A.1 The 2012 drought design (Appendix A)

### A.1 ¶1 — Why 2012, why first onset
1. Identification wants sharp, unanticipated, spatially delimited exposure: the 2012 onset provides it.
2. First-onset restriction: treated counties experience their *first* panel-era extreme drought in 2012 — clean event time, no prior-treatment contamination.
3. Never-exposed controls: comparison counties never experience extreme drought in the window — avoids the staggered-DiD forbidden comparison problem entirely.
→ cohort.

### A.1 ¶2 — Cohort construction
1. Result: 139 treated vs 2,534 never-exposed counties; map E1-F1 **[BUILD]**; balance table E1-T2.
2. Geography named precisely: Georgia + Mountain West + Plains.
3. Balance read: treated counties are smaller/more rural — motivating both the DRDID covariate adjustment and the two-decade pre-trend test.
→ equation.

### A.1 ¶3 — Estimating equation
1. 2×2 DiD: outcome on Treated×Post(2012), county FE + year FE; state-clustered SEs.
2. Estimand, stated with all Gate-B elements: ITT of first extreme-drought onset, 139 treated counties (GA/Mountain West/Plains), 2011–2023, relative to never-exposed counties, under parallel trends absent onset.
→ assumptions and threats.

### A.1 ¶4 — Identifying assumption and threats
1. Assumption: treated and never-exposed counties would have trended in parallel absent the 2012 onset.
2. Threat 1 — selection into drought-prone geography → test: two-decade BEA pre-trend (§6 ¶1).
3. Threat 2 — single-state or regional idiosyncrasy → test: LOO (§6 ¶2), placebo onsets (§6 ¶3).
4. Threat 3 — spillovers to "control" neighbors → analysis (§6 ¶4); direction: same-signed, so the local ATT is a lower bound on regional exposure.
→ inference plan.

### A.1 ¶5 — Inference plan
1. 17 treated states → few treated clusters; pre-commit to reporting analytic, wild-cluster-bootstrap (Webb), and randomization-inference p-values side by side.
2. One sentence forward to §6/E1-T4.
→ the result.

---

# §1 Introduction — WRITE LAST (content units final, order fixed)

### §1 ¶1 — Hook
1. Concrete image: a drought (or heat wave) ends; the weather normalizes; the bills have not arrived yet. The costs show up next year — in county income, in Medicare claims, in collection accounts.
2. The question is not only how large climate costs are, but **which institution's books they show up on** — and some books miss them.
3. (Idiom permitted here; no numbers; no citations yet if the rhythm is better without.)

### §1 ¶2 — The measurement problem
1. Why delayed incidence is hard: attribution across years; adaptation and migration muddy the treated population; and every administrative ledger observes a different population under different recording rules.
2. Existing literature measures contemporaneous mortality/output **[CITE: Deschênes–Greenstone; Hsiang review]**; the financial after-path of a shock through household and health-market ledgers is much less mapped **[CITE: household-finance/medical-debt lit, e.g., Dobkin et al.-style]**.

### §1 ¶3 — What this paper does
1. Three moves in one panel: (i) a sharp natural experiment for local economic incidence — the 2012 drought, 139 first-onset counties (Georgia, Mountain West, Plains) vs 2,534 never-exposed; (ii) direct administrative morbidity measurement in Medicare; (iii) a test of whether two financial ledgers — credit-bureau debt and ACA premiums — record or price any of it.
2. Data sentence: harmonized county/state panel (~1996–2025) linking NOAA/PRISM/EPA exposure to BEA income, employment, bureau debt, ACA premiums, CMS Medicare.

### §1 ¶4 — Result 1 (Medicare) — REORDERED 2026-08-17
1. Lead result: heat raises standardized Medicare spending $112 now / $177 next year (1.1%/1.7% of $10,359) and ED visits ~8–10/1,000 (1.2–1.5% of 629); cold and AQI at lags; reproduces Deryugina et al. in-panel.
2. Population qualifier in the same breath: 65+/disabled, 2014–2023; non-agricultural (Drought×Ag null).
3. The lag structure is the "deferred costs" pattern of the title.

### §1 ¶5 — Result 2 (ledgers)
1. Debt: cold +1.35 pp at one-year lag (state; county +1.2 pp) — recorded, but measurement-fragile (three filters).
2. Premiums: no coherent local pass-through — sign flips across county/RA/state; within-state ≤5–8% of mean premium; morbidity-scale pass-through ruled out FOR DROUGHT (50–79%); heat/cold loosely bounded.
3. Corollary: 92–99% of the debt response survives premium adjustment.

### §1 ¶6 — Result 3 (household capacity + the decomposition)
1. Distributed-lag income: −$99 to −$132 per PDSI unit, stable across 1990/2000/2011 windows; contemporaneous −$149 (p=5×10⁻⁶) full window.
2. The 2012 experiment as an audit (Appendix A): raw contrast −$1,311 ≈ 2.5% (WCB p=0.036, RI p=0.0075); ~$900 = farm reversion from the 2011 commodity-price peak; baseline-invariant nonfarm −$261 to −$414 (≈0.5–0.8%), sign-stable, imprecise.
3. Contribution framing: agricultural-county event contrasts conflate the commodity-price cycle with climate damage unless the income ledger is decomposed.
4. Estimand qualifier: event-specific; pooled multi-cohort onset −$324 (SE 276), null.

### §1 ¶7 — Contributions (REORDERED 2026-08-17)
1. Direct morbidity: administrative utilization responses measured in the same panel as the economic outcomes — the health channel by measurement, not inference (nearest: Deryugina et al. 2019).
2. Institutional visibility: a new fact about *recording* — regulated ACA pricing shows no coherent local response and bureau debt records selectively; which ledger you read determines whether you see the cost.
3. Climate-economy measurement: the farm/nonfarm decomposition — agricultural-county event contrasts inherit the commodity-price cycle embedded in the income ledger **[CITE: Deschênes–Greenstone 2007; Deryugina 2017]**.

### §1 ¶8 — Roadmap
1. New order: §2 institutions · §3 data · §4 Medicare · §5 ledgers · §6 household capacity · Appendix A (2012 experiment + decomposition) · §7 interpretation · §8 conclusion.

---

# Abstract — WRITE VERY LAST

String, in order, exactly these units (target 180–250 words; REORDERED 2026-08-17):
1. Question (one sentence — healthcare costs and which institutions record/price them).
2. Data (harmonized panel clause: exposure → Medicare, debt, premiums, income).
3. Medicare sentence FIRST ($112/$177; ED +8–10/1,000; 65+/disabled; direct; deferred-cost lag structure).
4. Ledger sentence (debt lagged but measurement-fragile; premiums: no coherent pass-through, drought tightly bounded).
5. Capacity sentence (window-stable distributed-lag income; 2012 event contrast decomposes into farm price reversion + modest imprecise nonfarm decline — appendix).
6. Contribution sentence (measuring deferred morbidity costs directly; identifying which ledgers record or price them).
