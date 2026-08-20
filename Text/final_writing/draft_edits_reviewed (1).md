# Draft edits — reviewed

Generated from the proof sheet. `Suggested` is the text as it now stands,
including any rewrite made in the review page.

## Essay 1 — Deferred Costs

### L7 · Abstract · CRITICAL · claim
**Farm channel contradicts the essay's own decomposition**

- **As written:** I find that the unpriced costs strain household budgets: drought lowers county incomes at a one-year lag through both farm and non-farm channels, and is robust to the window used for estimation.
- **Suggested:**  I find that the unpriced costs strain household budgets: drought lowers county incomes contemporaneously through a nonfarm channel of $261 to $414, stable across multiple choices of estimation windows.  _(rewritten)_
- **Why:** Two errors in one clause. §6 reports the contemporaneous term (−$149), not a one-year lag. And Appendix A establishes the farm component is 2011 commodity-price reversion, not drought damage — it collapses from −$907 to −$14 once the baseline pools 2009–2011. This is the last surviving sentence of the pre-restructure framing.
- **Source:** master_evidence_table.md Row 1 (amended 2026-08-17) · essay1_draft.md §6, App. A.2

### L17 · §1 · CRITICAL · claim
**Air quality peaks contemporaneously, not at a lag**

- **As written:** …reproducing Deryugina et al. (2019) within this panel; cold and air-quality shocks operate at longer lags.
- **Suggested:**  …reproducing Deryugina et al. (2019) within this panel; cold shocks operate at longer lags, while air quality shocks peak in the year of incidence.  _(rewritten)_
- **Why:** Air-quality emergency visits decline monotonically: 5.00 → 3.64 → 2.83. §4 line 69 of this same draft says exactly that, so the introduction contradicts the results section and E1-T6.
- **Source:** medicare_channel_coefs.csv · Analysis/mechanism/medicare_table.tex

### L67 · §4 · CRITICAL · prose
**The style exemplar's own citation has leaked into the manuscript**

- **As written:** …the costs of extreme weather are rarely instantaneous and reveal themselves over time. (Aguilar-Gomez, Graff Zivin, and Neidell, 2025)
- **Suggested:**  …the costs of extreme weather are rarely instantaneous and reveal themselves over time.
- **Why:** This is the NBER paper used as the writing-style exemplar, not a work this essay cites. It sits after a terminal period as an orphan parenthetical, appears in no bibliography, and reaches the typeset PDF. Delete it.
- **Source:** Text/reference/w33491.pdf — style exemplar, not a source

### L71 · §4 · CRITICAL · claim
**The agricultural null has no estimate behind it**

- **As written:** …reproduce Deryugina et al. (2019) within this panel, and interacting drought with agricultural dependence yields a null, so the morbidity channel requires no farm-income intermediary.
- **Suggested:**  …reproduce Deryugina et al. (2019) within this panel.  _(rewritten)_
- **Why:** ag_channel_coefs.csv contains no Medicare outcome at all — only income, employment, debt and premiums. And where the drought-by-agriculture interaction does exist, on employment, it is significant at all three lags (−0.0061 p=0.026; +0.0126 p=0.0005; +0.0086 p=0.004). This claim is load-bearing for the essay's non-agricultural framing.
- **Source:** Analysis/mechanism/ag_channel_coefs.csv · employment_rescaled_coefs.csv

### L96 · §5 · CRITICAL · claim
**Asserts the pass-through the paragraph just ruled out — and has the signs backwards**

- **As written:** Therefore we see higher premiums in years and counties with heat shocks, and lower premiums in cold county-years.
- **Suggested:**  — delete the sentence —
- **Why:** Three sentences earlier the paragraph concludes there is no coherent local pass-through; this sentence then reports a directional finding from those same unstable coefficients, with Therefore presenting it as an inference. It is also backwards at the primary specification: at the rating-area level heat is −$10.40 and cold +$12.57. The pattern described is the county specification the draft itself calls confounded seven lines earlier.
- **Source:** Analysis/mediation/premium_passthrough.csv, RAxYr rows · evidence table Row 8

### L108 · §5 · CRITICAL · claim
**The 92–99 percent range holds for two cells, not all nine**

- **As written:** …nearly all of the original effect remains: 98.7 percent for drought at a two-year lag, 92.2 percent for cold at a one-year lag, and between 92 and 99 percent across the remaining cells.
- **Suggested:**  …nearly all of the original effect remains for the two cells the essay headlines: 98.7 percent for drought at a two-year lag and 92.2 percent for cold at a one-year lag. Remaining shock-by-lag estimates for other exposures remain statistically non-significant and uninformative.  _(rewritten)_
- **Why:** The two named cells are right. The other seven span 0.171 to 1.139 — heat at one lag retains 17 percent, not 92. The source scopes the 93–99 percent figure to the two headline effects only.
- **Source:** Analysis/mediation/debt_mediation.csv · premium_mediation_summary.md §(ii)

### L112 · §5 · CRITICAL · claim
**Wrong twice in one sentence**

- **As written:** State per-capita health spending shows no robust climate signal and instead tracks income and unemployment (unemployment p = 0.06).
- **Suggested:**  State per-capita health spending shows one climate-shock association with extreme cold, +$205 (p = 0.014), and also tracks increases in unemployment (p = 0.06), but not income (p = 0.40).  _(rewritten)_
- **Why:** Cold is a significant climate signal at +$205 (p = 0.014), so "no robust climate signal" is false. And income does not track: p = 0.397. Only the unemployment clause survives.
- **Source:** Analysis/state/regression_results_summary.csv, Total_Per_Capita_Health_Exp_Real block

### L134 · §8 · CRITICAL · prose
**Two predicates collided**

- **As written:** Lastly, household budgets absorb unpriced costs strain after shocks as drought lowers local incomes.
- **Suggested:**  Lastly, these unpriced costs are absorbed in strained household budgets, as drought lowers local incomes.  _(rewritten)_
- **Why:** Unparseable as written — pick one verb. This is the third of the three answers the conclusion promises, so it is the sentence a reader stops on.
- **Source:** —

### L136 · §8 · CRITICAL · prose
**Two broken sentences, one contradicting §4's central premise**

- **As written:** These insights inform the second and third essays in the dissertation where I explore whether the time-dynamics of these costs (persistence, compounding etc) and the distributional nature of these costs. … As in the case of credit-bureau debt, Medicare and BEA income accounts have access filters and costs selectively recorded.
- **Suggested:**  These insights inform the second and third essays, which examine how these costs evolve — whether they persist or compound — and how they are distributed. … Medicare and the BEA income accounts observe different populations under different rules, so no single ledger sees the whole burden.
- **Why:** The first sentence has no predicate after “whether” and stops mid-thought — and it is the sentence handing the reader off to Essays 2 and 3. The second asserts Medicare has access filters, directly contradicting §4's “administratively complete”, on which the entire Medicare claim rests.
- **Source:** self-contradiction with essay1_draft.md §4

### L73 · §4 · HIGH · number
**Moments appear in no committed output**

- **As written:** …the baseline share of employment in climate-exposed non-farm industries (construction, manufacturing, transportation, and utilities; mean 25.2 percent, standard deviation 6.0 percentage points)…
- **Suggested:**  …the baseline share of employment in climate-exposed non-farm industries (construction, manufacturing, transportation, and utilities; mean 24.9 percent, standard deviation 6.1 percentage points)…
- **Why:** Neither figure exists in any committed output — they survive only in the draft and a harness edits file. Recomputed from source: 24.94% / 6.08 pp over 3,221 counties. The energy-burden moments quoted alongside (3.4% / 1.1 pp) do check out.
- **Source:** Data/intermediate_industry_composition.rds, recomputed

### L85 · §5 · HIGH · claim
**Collapse attributed to controls; it is a sample restriction**

- **As written:** …the debt share rises by 0.58 percentage points at a two-year lag in the county panel (p = 0.02), an estimate that does not survive the addition of income and uninsurance controls…
- **Suggested:**  …the debt share rises by 0.58 percentage points at a two-year lag in the county panel (p = 0.02), an estimate that does not survive sample restrictions imposed by controls. On the identical sample it falls to 0.09 points (p = 0.76) before any controls are added…  _(rewritten)_
- **Why:** The committed verdict reads "STABLE — contemporaneous controls are innocuous… Total-effect language is safe". Full sample 0.00576 (p=0.029) → identical-sample, no control 0.00091 (p=0.757). The controls then move it only a further 31 percent.
- **Source:** Analysis/control_sensitivity/control_sensitivity_summary.md

### L174 · App. A.3 · HIGH · number
**Range scoped to the wrong outcomes**

- **As written:** …ACS controls for aging, tenure, and in-migration leave 94 to 104 percent of each effect intact…
- **Suggested:**  …ACS controls for aging, tenure, and in-migration leave 94 -104 percent of the debt and hospital effects intact, though the cold-income estimates attenuate by 58 percent…  _(rewritten)_
- **Why:** The county decomposition spans 0.576 to 1.044. The source explicitly scopes 94–104 percent to "the debt and hospital outcomes" and names the PCPI cold cell (0.58) as material attenuation. The state mirror is wider still (−2.04 to 3.52).
- **Source:** demographic_mediator_decomposition.csv · Analysis/state/synthesis.md §7

### L19 · §1 · HIGH · number
**Bound disagrees with §5 and with the source**

- **As written:** …within-state responses are bounded below roughly 5 to 8 percent of the mean premium.
- **Suggested:**  …within-state responses are bounded below roughly 4-8 percent of the mean premium.  _(rewritten)_
- **Why:** §5 says "6 to 7 percent" for the same object; neither matches. Across the six primary cells δ* runs 2.0–8.0 percent of the mean, and the source's bottom line is ~4–8 percent for heat and cold. Pick one and propagate.
- **Source:** Analysis/mediation/passthrough_bounds.csv, delta_pct_mean

### L130 · §7 · HIGH · prose
**Promises three, delivers two**

- **As written:** Three future extensions would sharpen our understanding… Working-age administrative utilization data — all-payer claims — would test the morbidity channel in the same population as the credit bureau debt. Patient-flow measures of hospital exposure would replace the location-county assignment used on the provider side.
- **Suggested:**  Two future extensions would sharpen our understanding…  _(rewritten)_
- **Why:** Two are delivered. The paragraph also terminates on a trailing space, so it reads as stopping mid-list.
- **Source:** —

### L71 · §4 · HIGH · claim
**The lead result does not survive state-by-year fixed effects, and the robustness paragraph omits it**

- **As written:** The five-way robustness paragraph covers outcome selection, multiple testing, spatial correlation, recurring treatment, and attribution — but never the state-by-year specification.
- **Suggested:**  Add a sixth check: Absorbing state-by-year shocks leaves the heat–spending response at one lag imprecise (+$34, p = 0.15), so the estimate rests on variation across states within a year as well as within them; the emergency-visit responses are unaffected.
- **Why:** conley_robustness.csv gives est_stateXyear = 33.85, p = 0.153 against 174.6 (p = 0.004) under state clustering. This is the essay's headline Medicare cell, and the omission is the kind a referee finds first.
- **Source:** Analysis/mechanism/conley_robustness.csv, heat_medicare_lag1

### L120 · §6 · HIGH · claim
**Employment fragility hedged as “matching caution” instead of stated**

- **As written:** …the 2012 event reduced employment by roughly 2,000 jobs per treated county - about 4 percent of mean county employment (Appendix A.3). Because the employment series begins in 2011, no pre-onset leads exist, and I treat the estimate with matching caution.
- **Suggested:**  …the 2012 event reduced employment by roughly 2,000 jobs per treated county - about 4 percent of mean county employment (Appendix A.3). That estimate is materially more fragile than the income one: it attenuates by about 58 percent under the doubly-robust estimator (−871, SE 433) and reverses sign in the pooled estimator (+2,609, SE 2,245). With no pre-onset leads available, I report it as event-specific and secondary.
- **Why:** Row 2 requires the decline be reported with explicit prominence to its fragility — the DRDID attenuation and the pooled sign reversal. The draft substitutes a vague phrase and a different caveat; both facts sit only in Appendix A.3.
- **Source:** master_evidence_table.md Row 2 · did_robustness_summary.md

### L83 (also L7, L19) · HIGH · claim
**Appendix B sets a range the front matter ignores**

- **As written:** Cold shocks raise the medical-debt share by 1.35 percentage points at a one-year lag in the state panel (p = 0.012)…
- **Suggested:**  Cold shocks raise the medical-debt share by 0.85 to 1.35 percentage points at a one-year lag in the state panel (p = 0.012 to 0.044 across baseline choices)…
- **Why:** The draft's own Appendix B concludes: “I therefore cite that response as a 0.85 to 1.35 percentage-point range wherever baseline robustness is at issue.” The abstract, §1 and §5 all cite the endpoint alone. Fix all three surfaces or drop the appendix commitment.
- **Source:** essay1_draft.md App. B · baseline_horizon_sensitivity.csv

### L89 vs L96 · §5 · HIGH · claim
**The sign-instability argument leans on a specification the essay calls confounded**

- **As written:** L89: …a county-plus-year-fixed-effects premium regression is confounded. L96: The cold coefficient at the two-year lag runs -$15.5 at the county level, +$12.6 at the rating-area level, and -$16.7 at the state level…
- **Suggested:**  The cold coefficient at the two-year lag runs +$12.6 at the rating-area level and -$16.7 at the state level; heat runs -$10.5 and +$93. County-level estimates are reported in the appendix only, since roughly 86 percent of premium variance is state-by-year.  _(rewritten)_
- **Why:** The essay's core evidence for “no coherent pass-through” is sign flips across levels — but one of those levels is declared confounded seven lines earlier. A referee will press exactly here.
- **Source:** premium_passthrough.csv · evidence table Row 8

### L104 · §5 · HIGH · prose
**Self-cancelling within one paragraph**

- **As written:** For these two hazards the exercise is uninformative. … What the data do pin down for heat and cold is an upper limit: whatever the response is, it is no larger than about 6 to 7 percent of the average benchmark premium.
- **Suggested:**    _(rewritten)_
- **Why:** The “upper limit” is the same minimum detectable effect restated as a percentage of the mean — relabelling an uninformative bound as a finding. Say it once and stop.
- **Source:** passthrough_bounds.csv, delta_pct_mean

### L108 · §5 · HIGH · claim
**Deduction rests on a universal null the essay denies four lines earlier**

- **As written:** If premiums do not move when climate shocks hit, then the increase in medical debt cannot be running through premiums, because there is no price change for it to run through.
- **Suggested:**  If premiums do not move when climate shocks - specifically drought - hit, then the increase in medical debt cannot be running through premiums, because there is no price change for it to run through.  _(rewritten)_
- **Why:** §5 states four lines earlier that heat and cold “give no answer at all”. The antecedent holds for drought only, so the deduction cannot be stated in general terms.
- **Source:** passthrough_bounds.csv · debt_mediation.csv

### L53 · §3 · HIGH · prose
**Contradicts itself in consecutive sentences**

- **As written:** The choice matters: clustering at the county level would be anticonservative… It is also not decisive for the results - Conley standard errors with a 200-km kernel essentially reproduce state clustering, and leaves the headline estimates intact.
- **Suggested:**  The choice matters for inference but not for the point estimates: Conley standard errors with a 200-km kernel essentially reproduce state clustering and leave the headline estimates intact.
- **Why:** “The choice matters” then “it is also not decisive” read as a contradiction; the distinction intended is inference versus estimates. Also a subject–verb break (“reproduce … and leaves”).
- **Source:** —

### L55, L73 · §4 · HIGH · prose
**§4 does two jobs and the roadmap only announces one**

- **As written:** Heading: 4 Medicare morbidity and utilization … L73: Turning to the labor market, the lagged burden of climate shocks operates substantially outside the agricultural mechanism.
- **Suggested:**  Move L73–L75 into §6 (“Household economic capacity: income and employment”), where the roadmap already places employment. If they stay, split §4 into 4.1 Medicare morbidity and 4.2 Labor-market exposure, and amend the §1 roadmap to announce both.
- **Why:** The last third of §4 reports county employment interactions — a different population, panel and outcome from the Medicare results the section is named for. §1's roadmap assigns §4 to “the Medicare morbidity evidence” and employment to §6, so it never mentions this material.
- **Source:** essay1_draft.md §1 roadmap vs §4, §6

### L174 · App. A.3 · HIGH · claim
**Says HonestDiD cannot run; a committed run exists and is adverse**

- **As written:** Second, HonestDiD-style sensitivity analysis cannot run on a cohort with no in-panel pre-period; the long BEA window and the farm/nonfarm decomposition substitute for it…
- **Suggested:**  Second, HonestDiD-style sensitivity analysis cannot run on the 2012 cohort, which has no in-panel pre-period. Run on the pooled cohorts, where a pre-period does exist, the income bounds include zero at every value of the smoothness parameter. The long BEA window and the farm/nonfarm decomposition substitute for it on the 2012 cohort…  _(rewritten)_
- **Why:** honestdid_sensitivity.csv exists and every PCPI_Real bound has excludes_0 = FALSE, already at M-bar = 0.5. Stating the method “cannot run” while an adverse run sits in the repository reads as suppression.
- **Source:** Analysis/did/robustness/honestdid_sensitivity.csv · did_robustness_summary.md §3

### L104 · §5 · MEDIUM · number
**Two different premium baselines, both called the average**

- **As written:** …no larger than about 6 to 7 percent of the average benchmark premium of $366 per month.
- **Suggested:**  …no larger than ~6-7 percent of the population-weighted mean benchmark premium in the rating-area estimation sample of $366/month.  _(rewritten)_
- **Why:** Both $366 and §3's $374 are correct but differently defined — $374 is the unweighted county-year mean, $366 the population-weighted mean over the pass-through sample (unweighted, that sample gives $394). Nothing in the text distinguishes them.
- **Source:** passthrough_bounds.csv mean_premium · descriptive_stats_summary.csv

### L71 · §4 · MEDIUM · number
**Index p-value is the component's, not the index's**

- **As written:** …the index is significant at the same time lags where the component outcomes are (heat at one lag, p = 0.007; cold at two lags, p = 0.002).
- **Suggested:**  …the index is significant at the same time lags where the component outcomes are (heat at one lag, p = 0.007; cold at two lags, p = 0.001).
- **Why:** The Anderson index p at High_HDD_Lag2 is 0.00117. The 0.002 quoted is the p of the component emergency-visit coefficient.
- **Source:** Analysis/mechanism/multipletesting_anderson.csv, row 6

### L71 · §4 · MEDIUM · number
**One of the two named responses does not clear the correction**

- **As written:** …the heat and air-quality emergency-department responses survive at q < 0.05.
- **Suggested:**  …the heat response at one year and the contemporaneous air-quality response survive at q < 0.05.
- **Why:** Heat at t0 does not survive (q = 0.056, survives_BKY_05 = FALSE). Only heat t1 and air quality t0 clear. Separately, that q-file is built on stale p-values and should be regenerated.
- **Source:** Analysis/mechanism/multipletesting_qvalues.csv

### L53 · §3 · MEDIUM · number
**Inherits an arithmetic error from the source memo**

- **As written:** …clustering at the county level would be anticonservative by up to seven orders of magnitude on headline p-values.
- **Suggested:**  …clustering at the county level would be extremely non-conservative on p-values.  _(rewritten)_
- **Why:** 2.8e-13 against 0.0026 is roughly ten orders. The draft faithfully reproduces a mistake in clustering_justification.md; that memo needs the same fix. This claim also has no evidence-table row.
- **Source:** Analysis/advisor_robustness/clustering_justification.md:53

### L7 · Abstract · MEDIUM · prose
**Typo in the first sentence**

- **As written:** Climate shocks impose healthcare costs that continue to emerge after the exteme event has passed.
- **Suggested:**  Climate shocks impose healthcare costs that continue to emerge after the extreme event has passed.
- **Why:** First sentence of the manuscript.
- **Source:** —

### L69 · §4 · MEDIUM · claim
**Air-quality result stated with no monitoring caveat attached**

- **As written:** Air-quality shocks raise emergency visits by 5.0 per 1,000 contemporaneously (p = 0.0002), 3.6 at one year, and 2.8 at two.
- **Suggested:**  Air-quality shocks raise emergency visits by 5.0 per 1,000 contemporaneously (p = 0.0002), 3.6 at one year, and 2.8 at two. Caveat: we observe this in the 1,194 counties with an operating monitor, which are disproportionately urban.  _(rewritten)_
- **Why:** Row 13 requires the sparse-monitoring caveat. The draft has it, but in §3, two sections upstream, and never repeats it where the claim is made or in the abstract.
- **Source:** master_evidence_table.md Row 13 · essay1_draft.md §3

### L33 · §2 · MEDIUM · claim
**States generally what Row 24 restricts to one hazard — and Essay 3 states it correctly**

- **As written:** The third essay shows the recorded response is smaller precisely where uninsurance is higher, the visibility gradient this structure predicts.
- **Suggested:**  The third essay shows the recorded response to drought is smaller where uninsurance is higher.  _(rewritten)_
- **Why:** Row 24 permits the coverage gradient for drought × uninsurance only (q = 0.012), not as a general access gradient. Essay 3 §7 states it correctly, so as written the two essays disagree.
- **Source:** master_evidence_table.md Row 24 · essay3_draft.md §7

### L106 · §5 · MEDIUM · claim
**Says the opposite of what is meant, and adds a hazard never estimated**

- **As written:** In general, I can only reject a premium response to a drought shock and the data are inconclusive with regards to other shocks such as heat, cold and air pollution.
- **Suggested:**  For drought alone the data rule out a response above $7.41 per member-per-month.  _(rewritten)_
- **Why:** “Reject a premium response” reads as rejecting the null when the test rejects a large response. And no air-quality premium cell exists anywhere — Row 8 covers cold, heat and drought only. Also a one-sentence orphan paragraph.
- **Source:** passthrough_bounds.csv · master_evidence_table.md Row 8

### L98–L106 · §5 · MEDIUM · prose
**Five paragraphs in a register found nowhere else in the volume**

- **As written:** Finding no effect can mean two very different things. … Drought gives a clear answer. … This is a real finding about how the market prices risk. … Heat and cold give no answer at all.
- **Suggested:**  Compress to one methods paragraph (what an equivalence bound is and why it is needed) and one results paragraph (drought bounded, heat and cold not). Move the tutorial to a footnote, and delete the self-appraisal.
- **Why:** Short declaratives, second-person tutorial framing and “More importantly” appear nowhere else in the three essays. “A real finding” is an explicit self-appraisal, which the style guide bans outright.
- **Source:** WORKFLOW.md — NBER style constraints

### A.3, L53 · unregistered · MEDIUM · claim
**Five claims with no evidence-table row**

- **As written:** Spillover lower-bound argument (A.3); seven-orders-of-magnitude clustering figure (L53); heat's +4,460 cumulative-dose contrast (Essay 2 §7); the post-exit decay horizon (Essay 2, ×4); burden-concentration shares (Essay 3 §8).
- **Suggested:**  Add a row to master_evidence_table.md for each before the claims freeze, or remove the claim. The spillover and clustering material belongs to the open advisor_feedback_20260807 track and postdates the frozen table.
- **Why:** If the evidence table is the binding claim inventory, an assertion with no row has not passed the gate. A.3's spillover paragraph also calls the 2012 income contrast “the headline”, which the 2026-08-17 restructure demoted.
- **Source:** master_evidence_table.md — absence

### Throughout · MEDIUM · prose
**Person drifts between I, we and one**

- **As written:** “we see higher premiums” (L96) · “we find” (L118) · “we can take out” (L126) · “our understanding” (L130) · “one consults” (L23)
- **Suggested:**  Settle on the first-person singular throughout, as Essays 2 and 3 already do.
- **Why:** The drift happens within paragraphs, and the other two essays are consistent — so the volume is inconsistent as well as the essay.
- **Source:** —

## Essay 2 — Scarring and Compounding

### L59, L89 (also L7, L17) · CRITICAL · number
**45 percent belongs to a different estimand**

- **As written:** Scaled by the mean absolute deviation of year-to-year changes in the county's debt share, the two-year asymmetry equals about 45 percent of a typical annual movement (mean absolute deviation of year-to-year changes).
- **Suggested:**  Scaled by the mean absolute deviation of year-to-year changes in the county's debt share, the two-year asymmetry equals about 72 percent of a typical annual movement (mean absolute deviation of year-to-year changes).  _(rewritten)_
- **Why:** 45 percent is the local-projection impulse: 0.01164 / 0.0259 = 0.449. The onset–exit asymmetry is 0.01874, giving 0.72. Stated four times — abstract, §1, §5, conclusion. The trailing parenthetical also repeats its own sentence's opening clause verbatim.
- **Source:** mad_scaling_table.csv · delta_symmetry_test.csv (Drought, h=2, unweighted)

### L59, L89 (also L7, L17) · CRITICAL · claim
**Two estimands conflated — the asymmetry does not fade at h=4**

- **As written:** Extending the local-projection horizon shows the asymmetry fading by the fourth year after exit.
- **Suggested:**  Extending the local-projection horizon shows that the drought shock-response fades by the fourth year. Since we perform the symmetry test only to a three-year horizon, the asymmetry remains significant (+0.015, p = 0.039).  _(rewritten)_
- **Why:** The symmetry grid stops at h = 3, and there the asymmetry is still significant. No h = 4 symmetry test exists. What fades at h = 4 is the LP impulse — a different quantity. Also stated four times, and the decay horizon has no evidence-table row.
- **Source:** delta_symmetry_test.csv (h=3: +0.01457, p=0.0387) · horizon_sensitivity_note.md

### L79 · §8 · CRITICAL · number
**Cohort size wrong by a factor of two**

- **As written:** …the admissible cold-onset cohorts are 2013 (171 counties) and 2014 (24 counties)…
- **Suggested:**  …the admissible cold-onset cohorts are 2013 (171 counties) and 2014 (59 counties)…
- **Why:** The committed file gives 59, uniform across all seven outcomes and every event time, and the aggregate confirms it: 171 + 59 = 230 treated at e = 0. The 24 survives only in a hand-written narrative.
- **Source:** Analysis/did/did_cs_att_gt.csv · did_cs_event_time.csv:157

### L57 · §5 · CRITICAL · claim
**Household-level persistence claimed from county aggregates**

- **As written:** The debt accrued during a drought remains on a household's credit file after at least 2 periods after the drought ends.
- **Suggested:**  At the county level the elevated debt share persists for at least two years after exit. Part of that persistence is compositional as drought raises net out-migration the following year and so the estimate is a bound on what the estimates would have been with the same underlying population.  _(rewritten)_
- **Why:** A literal same-household claim the design cannot support, from a county panel. Row 16 requires the out-migration caveat stated explicitly and co-located; it currently sits in §8, three sections and ~1,200 words later. The sentence also does not parse ("after at least 2 periods after").
- **Source:** master_evidence_table.md Row 16

### L19 · §1 · CRITICAL · prose
**Doubled word in the contribution sentence**

- **As written:** This essay turns turns the informal language of scarring and compounding into operational estimands…
- **Suggested:**  This essay turns the informal language of scarring and compounding into operational estimands…
- **Why:** Also in the same sentence: "estimands of symmetry tests" reads as the wrong preposition, and "applies it" has no clear antecedent.
- **Source:** —

### L47 · §3 · CRITICAL · prose
**Two clause fragments fused**

- **As written:** These provide the long-run complement to the transition estimates and an estimator and are built for staggered adoption.
- **Suggested:**  These provide the long-run complement to the transition estimates, and emerge from an estimator built for staggered adoption.  _(rewritten)_
- **Why:** Does not parse as written.
- **Source:** —

### L59 · §5 · CRITICAL · prose
**Capitalisation**

- **As written:** IT is also approximately 10 percent of the mean debt share of ~19 percent.
- **Suggested:**  It is also approximately 10 percent of the mean debt share of ~19 percent.
- **Why:** The paragraph also ends on a trailing space.
- **Source:** —

### Abstract, §1, §5, §10 · CRITICAL · claim
**The essay leads with debt-as-harm in four places**

- **As written:** Abstract, introduction, §5 (first results section) and conclusion all open on: “Drought debt scars: the two-year onset-exit asymmetry in the medical-debt share is +0.019…”
- **Suggested:**  Abstract (from “The dynamics are shock-specific”): The dynamics are hazard-specific. Cold compounds: counties at ten or more cumulative cold-years have employment roughly 5,500 lower than counties with one to three, and the gap reaches roughly 5,000 jobs a decade after onset in the event study. Heat saturates into a level difference that does not grow with further exposure. Drought is episodic, and the mark it leaves falls on a measurement-fragile ledger: the two-year onset–exit asymmetry in the credit-bureau medical-debt share is +0.019 (p < 0.001), about 72 percent of a typical annual movement, though that series records hardship only after insurance, billing, and credit-file filters, and part of the persistence is out-migration rather than the same households carrying debt forward. The horizon over which climate raises costs is itself hazard-specific, so single-year exposure measures understate the burden of recurring cold.§5 opening (replaces the first two sentences): The symmetry test asks whether leaving a shock undoes what entering it did. For heat and cold employment the onset and exit coefficients offset; for drought and the credit-bureau debt share they do not. At a two-year horizon their sum — the asymmetry — is +0.019 (p < 0.001; Table E2-T3), so the recorded debt share does not return to its pre-shock path within the horizon the test reaches. What follows is a statement about a ledger rather than a welfare measure: bureau debt records hardship only after an insurance relationship, a billed encounter, and a credit file, and the third essay shows the recorded response is weakest where coverage is thinnest.§10 (replaces the three verdicts): The answers are hazard-specific. Cold employment compounds — a binned cumulative-dose gap of roughly 5,500 jobs and an event-study gap of roughly 5,000 a decade after onset — though the smooth dose term is flat and the levels contrast is weighting-sensitive, so this is a pattern that particular estimators support rather than an estimator-invariant law. Heat saturates into a level difference. Drought is episodic, and its mark is a recorded-debt asymmetry of +0.019, about 72 percent of a typical annual movement, partly compositional and visible only in a ledger that filters hardship before recording it.§1 ¶4 is rewritten under the next card. A structural alternative — swapping §5 and §6 so dose leads — is cleaner against Row 24 but cascades through the roadmap and every cross-reference.
- **Why:** Evidence-table Row 24 reads, verbatim: “Do not lead any essay with debt-as-harm.” Unconditional. Cold compounding is the pre-designated headline (Row 17); it comes second everywhere. Essay 2 also never once describes debt as measurement-fragile — an exhaustive grep returns nothing.
- **Source:** master_evidence_table.md Rows 16, 24 · CLAUDE.md cross-cutting rules

### L67, L79 · §6, §8 · HIGH · number
**Pre-dedup figures I previously cleared in error**

- **As written:** The population-weighted contrast is far larger (−42,453, p = 0.006)… the smooth quadratic dose term is flat and insignificant (+435 between the tenth and first cold-year).
- **Suggested:**  The population-weighted contrast is far larger (−41,573, p = 0.005)… the smooth quadratic dose term is flat and insignificant (+417 between the tenth and first cold-year).
- **Why:** Both are pre-dedup vintages, each stated twice. Committed: −41,572.9 (SE 14,878.9, p = 0.0052) and +416.78 (SE 345.66, p = 0.228). My earlier edit list stated Essay 2 had no stale numbers — that was wrong.
- **Source:** Analysis/cumulative_dose/cumulative_dose_marginal.csv

### L57 vs L7, L17 · HIGH · number
**Same estimate, two significance thresholds**

- **As written:** …their sum (the asymmetry) is +0.019 (p < 0.01; Table E2-T3).
- **Suggested:**  …their sum (the asymmetry) is +0.019 (p < 0.001; Table E2-T3).
- **Why:** p = 0.00073, and E2-T3 — cited in the same sentence — prints <0.001. The abstract and §1 already say p < 0.001, so §5 is the outlier.
- **Source:** delta_symmetry_test.csv (Drought, Medical_Debt_Share, h=2, unweighted)

### L13 · §1 · HIGH · prose
**Promises four hazards, delivers three**

- **As written:** This essay provides that evidence for the four hazards of heat, cold, drought and air pollution.
- **Suggested:**  This essay provides that evidence for heat, cold, and drought.
- **Why:** Air pollution appears once more, in the data description, and is never estimated. §9 "Interpretation by hazard" covers three.
- **Source:** —

### Abstract vs L17 · HIGH · prose
**Abstract and introduction are byte-identical**

- **As written:** Abstract sentences 3–8 and §1 paragraph 4 match exactly, from “The dynamics are shock-specific” to “…understate the burden of recurring cold.” §10 repeats the same content a third time.
- **Suggested:**  The dynamics are hazard-specific, and the essay reports them in that order. Section 5 tests reversibility: for heat and cold employment the onset and exit coefficients offset one another, while for drought and the recorded debt share they do not. Section 6 turns to accumulation, where counties at ten or more cumulative cold-years have employment roughly 5,500 lower than counties at one to three; Section 7 corroborates that with a staggered event study putting the gap near 5,000 jobs a decade after onset, and Section 8 qualifies it by showing the estimate is sensitive to how counties are weighted and to which cohorts survive to event-time ten. Heat, by contrast, saturates — its cumulative-dose profile is flat. Drought leaves its mark in the debt ledger rather than in employment, and Section 8 shows that mark is partly compositional.
- **Why:** In the combined volume a reader meets the same paragraph twice within a page.
- **Source:** —

### Missing section · HIGH · claim
**No “What identifies compounding?” honesty box**

- **As written:** Abstract, §1 and §10 state cold compounding with no estimator caveat. The honest content exists in §6 and §8 but never reaches them.
- **Suggested:**  Insert at the end of §7, before §8:What identifies compounding?Three estimators speak to cold compounding, and they do not fully agree. The binned cumulative-dose contrast puts employment 5,522 lower at ten or more cold-years than at one to three (SE 1,196, p < 0.001), and the staggered event study puts the gap at 4,982 a decade after onset (p = 0.003), rising monotonically from roughly 150 in the onset year through 2,600 at five years. The smooth quadratic dose term does not agree: the implied difference between the tenth and the first cold-year is +417 (SE 346, p = 0.23) — flat, and signed the other way. The levels outcome is also not weighting-invariant, since the same binned contrast is −41,573 when counties are weighted by population, which reflects the weight of large counties rather than a larger per-county effect. And the event-time-ten estimate rests on the 2013 cohort alone, because the 2014 cohort has no tenth post-onset year inside the panel. Compounding is therefore a pattern supported by particular estimators, not an estimator-invariant law. Wherever the roughly 5,500-job figure appears in this essay it is the unweighted binned contrast, and it carries that qualification.Once this exists, §8's “two further reasons” passage can point at it instead of restating the same three numbers.
- **Why:** The framing plan mandates this box. The smooth quadratic dose term is flat and wrong-signed (+417); the levels outcome is weighting-sensitive (−5,522 unweighted vs −41,573 weighted). Row 17 also requires naming the estimator whenever the ~5,500 figure is cited.
- **Source:** dissertation_writing_and_framing_plan_20260712.md §7 · Row 17

### L79 · §8 · HIGH · claim
**A negative coefficient described as a rise, with no outcome definition**

- **As written:** IRS county-to-county migration flows show drought raising net out-migration the following year (−0.0021, p = 0.047).
- **Suggested:**  IRS county-to-county migration flows show drought lowering the net in-migration rate by 0.21 percentage points the following year (p = 0.047) — that is, raising net outflows. Row 19 asks that this be read as a bounded, suggestive contributor to the drought scar rather than a decomposition of it.
- **Why:** As written the sign and the verb point opposite ways, and the outcome is never defined, so a reader cannot tell which direction −0.0021 represents. Row 19 also requires the “suggestive, not a decomposition” framing, which is dropped.
- **Source:** migration_selection_coefs.csv · master_evidence_table.md Row 19

### L51 · §4 (and Essay 3 L25) · HIGH · prose
**Neither essay is self-contained as a standalone paper**

- **As written:** The panel, shock definitions, and estimation conventions follow the first essay. … The first essay's Appendix B shows the definitions are robust…
- **Suggested:**  Give each standalone paper a short self-contained data and design section — panel, four shock definitions, fixed effects, clustering rationale, and a one-line pointer to the companion essay for the robustness detail. Duplication across the three papers is acceptable; a dangling cross-reference is not.
- **Why:** In essay2.pdf and essay3.pdf these point at nothing. Essay 2 currently has no stated identification assumption, no clustering justification and no data table of its own.
- **Source:** rendered_rug/essay2.pdf · essay3.pdf

### L57 · §5 · MEDIUM · claim
**Premium adjustment was applied to a different quantity**

- **As written:** …and 99 percent of it survives premium adjustment.
- **Suggested:**  …and 99 percent of the lag-2 drought–debt coefficient survives premium adjustment.
- **Why:** The mediation file decomposes the coefficient (0.0206 → 0.0203), not the onset–exit asymmetry. No premium-adjusted asymmetry exists in any committed file.
- **Source:** Analysis/mediation/premium_mediation_summary.md §(ii)

### L57 · §5 · MEDIUM · claim
**“Unchanged” holds for the p-values, not the estimate**

- **As written:** …is unchanged under no, lagged, and contemporaneous control sets estimated on the identical sample (p < 0.001 in each)…
- **Suggested:**  …remains significant under no, lagged, and contemporaneous control sets estimated on the identical sample (p < 0.001 in each), though the point estimate moves between 0.019 and 0.025…
- **Why:** The point estimate runs 0.0187 → 0.0230 / 0.0252 / 0.0239, and the source flags two of the three variants materially_diff_vs_no_control = TRUE.
- **Source:** Analysis/control_sensitivity/control_sensitivity_table.csv, drought_asym rows

### L53 · §4 · MEDIUM · number
**“Chronic” given the share for any drought year**

- **As written:** Therefore, episodes begin and end quickly, and chronic extreme drought is rare (2.3 percent of county-years).
- **Suggested:**  Therefore, episodes begin and end quickly, and chronic extreme drought is rare as persisting spells are 0.5 percent of county-years, against 2.3 percent for any extreme-drought year.  _(rewritten)_
- **Why:** 2.3 percent is the mean of the extreme-drought indicator, i.e. any drought county-year. Chronic — the persistence cell — is 175 / 37,644 = 0.46 percent. Essay 1 §3 uses 2.3 percent correctly, as the overall share.
- **Source:** transition_episode_counts.csv · descriptive_stats_print.tex

### L67 & L79 · MEDIUM · prose
**The same three numbers reported twice**

- **As written:** §6: …−5,522… the population-weighted contrast is far larger (−42,453)… the smooth quadratic dose term implies +435… §8: …the unweighted binned contrast is −5,522, the population-weighted version is −42,453, and the smooth quadratic dose term is flat and insignificant (+435).
- **Suggested:**  Report them once — in the new “What identifies compounding?” box — and have §6 and §8 cross-reference it.
- **Why:** Verbatim repetition of an estimate triple, framed once as a robustness aside and once as a caveat. Both instances also carry the pre-dedup values corrected elsewhere in this sheet.
- **Source:** —

### L61 · §5 · MEDIUM · prose
**One-sentence orphan citing a table already cited**

- **As written:** Table E2-T3 reports symmetry tests for the full grid of hazards and outcomes.
- **Suggested:**  Merge into the paragraph above, where E2-T3 is already cited four lines earlier.
- **Why:** A standalone paragraph that repeats a cross-reference and adds nothing.
- **Source:** —

### L23, L27 · MEDIUM · prose
**Two subject–verb agreement errors, one in a thesis sentence**

- **As written:** L23: …a different policy object from one whose costs arrives once. L27: I define four different types of “adjustment” that takes place after a climate shock.
- **Suggested:**  L23: …a different policy object from one whose costs arrive once. L27: I define four different types of adjustment that take place after a climate shock.
- **Why:** L23 is §2's thesis sentence. L27 also scare-quotes its four regime names five times in one paragraph — set them in italics on first use instead.
- **Source:** —

### L65 · §6 · MEDIUM · prose
**Antithetical construction the style guide prohibits**

- **As written:** Cumulative dose asks a different question from symmetry: not whether a single episode unwinds, but whether the marginal cold year hurts more as a county's exposure history accumulates.
- **Suggested:**  Cumulative dose asks whether the marginal cold year hurts more as a county's exposure history accumulates — a different question from whether a single episode unwinds.
- **Why:** “X, not Y” epigrams are a named prohibition in WORKFLOW.md. The same pattern recurs in Essay 1 App. B (“information rather than fragility”) and Essay 3 §3 and §8.
- **Source:** WORKFLOW.md — NBER style constraints

### L91 · §10 · MEDIUM · prose
**Refers to bounds the essay never reported**

- **As written:** Longer panels and working-age administrative data would tighten the persistence bounds reported here.
- **Suggested:**  Longer panels and working-age administrative data would extend the horizons these tests can reach.
- **Why:** The essay reports point estimates and p-values, not bounds. The symmetry grid stops at h = 3 and the event study at ten years — the real limit is horizon, which the replacement names.
- **Source:** delta_symmetry_test.csv · horizon_sensitivity_note.md

### §1 · missing · MEDIUM · prose
**No contribution-to-literature paragraph**

- **As written:** §1 moves from motivation straight to methods and results. Essay 1 (L23) and Essay 3 (L19) both name their two or three closest antecedents and state what they add.
- **Suggested:**  Add a short paragraph naming the nearest antecedents — Hsiang and Jina (2014) and Deryugina, Kawano and Levitt (2018) on persistence of local shocks — and stating what the onset/exit decomposition adds to them.
- **Why:** Structurally the thinnest of the three introductions, and the omission is conspicuous beside its siblings. §10 also has no back-of-envelope projection.
- **Source:** essay1_draft.md §1 · essay3_draft.md §1

## Essay 3 — Unequal and Unrecorded

### L54 · §4 · CRITICAL · number
**Calls a significant effect insignificant — contradicting the table cited beside it**

- **As written:** …drought is associated with lower benchmark premiums in the least vulnerable counties (−$55 at the 25th percentile, statistically not significant)…
- **Suggested:**  …drought is associated with lower benchmark premiums in the least vulnerable counties (−$55 at the 25th percentile, p = 0.03)…
- **Why:** The low-vulnerability marginal effect is significant at p = 0.030 — and E3-T2, cited in this very sentence, prints 0.030 in the adjacent column.
- **Source:** exposure_interaction_coefs.csv, Drought_Lag2 × Benchmark_Silver_Real

### L56 · §4 · CRITICAL · claim
**Income does not replicate at the state level**

- **As written:** Both income and spending interactions replicate at the state level.
- **Suggested:**  The health-spending interaction replicates at the state level; the income interactions do not, and are insignificant for every hazard.
- **Why:** Every state-level Personal_Income_Per_Capita_Real interaction is ns (p = 0.36, 0.94, 0.22, 0.13, 0.14), and the cold marginal effects run the wrong way at high vulnerability. Only health spending replicates. The upstream synthesis makes the same overclaim.
- **Source:** exposure_interaction_state_coefs.csv

### L7 · Abstract · CRITICAL · prose
**The abstract's closing thesis does not parse**

- **As written:** Therefore, places with higher social vulnerability is where the real-economy cost of climate aggregate, and bureau debt is least informative about hardship…
- **Suggested:**  Therefore, the real-economy costs of climate shocks concentrate in places with higher social vulnerability, and bureau debt is least informative about hardship…
- **Why:** Two agreement errors and a missing head noun after "climate". This is the sentence carrying the paper's thesis.
- **Source:** —

### L54 · §4 · CRITICAL · prose
**Sentence collapses, and the inference is false**

- **As written:** The first essay found no coherent average pass-through of climate shocks into premiums and therefore the finding here is distributional that premium increases precisely where households are least able to absorb them.
- **Suggested:**  The first essay found no coherent average pass-through of climate shocks into premiums; the finding here is distributional in that premiums rise precisely where households are least able to absorb them.  _(rewritten)_
- **Why:** Ungrammatical, and "therefore" is a false inference: an average null does not imply a distributional finding. Worth noting the cross-essay tension too — Essay 1 §5 says drought is "null at every level", which this section never reconciles.
- **Source:** —

### L11 · §1 · CRITICAL · prose
**Typo in the opening sentence**

- **As written:** A heat wave of the a given magnitude is not the same event everywhere.
- **Suggested:**  A heat wave of a given magnitude is not the same event everywhere.
- **Why:** First sentence of the essay. Same sentence later: "the data sources one looks to measure these crises" is missing an infinitive marker.
- **Source:** —

### L19 · §1 · CRITICAL · prose
**Not idiomatic — meaning is unrecoverable**

- **As written:** …it shows that the medical debt data is contrary for understandable reasons…
- **Suggested:**  …it shows that credit-bureau debt runs counter to the amplification pattern, for understandable reasons…
- **Why:** "Is contrary" does not carry "behaves counterintuitively" in English. Also "data is".
- **Source:** —

### L7 · Abstract · HIGH · number
**Abstract disagrees with the body on a headline magnitude**

- **As written:** …cold's per-capita income effect is roughly eight times larger there…
- **Suggested:**  …cold's per-capita income effect is roughly ten times larger there…
- **Why:** The only item from the first edit list still outstanding. §1, §4 and §10 now say ten; the ratio is 459 / 45.6 = 10.1.
- **Source:** exposure_interaction_coefs.csv, Cold_HDD × PCPI_Real

### L33 · §2 · HIGH · number
**BRFSS is not a SAHIE input**

- **As written:** …Small Area Health Insurance Estimates (SAHIE), a model-based estimate combining the Behavioral Risk Factor Surveillance System and the ACS.
- **Suggested:**  …Small Area Health Insurance Estimates (SAHIE), a model-based estimate combining the ACS with IRS tax returns, SNAP participation, Medicaid and CHIP records, and Census population estimates.
- **Why:** SAHIE's model inputs do not include BRFSS. A sourcing claim about the data, so worth getting right even though it carries no estimate.
- **Source:** Census SAHIE methodology — no repo file asserts BRFSS

### L60 · §5 heading · HIGH · prose
**Heading promises a result the section never reports**

- **As written:** 5 Energy burden and non-farm labor exposure
- **Suggested:**  5 Energy burdenA decision, not a wording fix. Either cut “and non-farm labor exposure” from the heading and delete the moderator's construction paragraph in §2, or report it — Essay 1 §4 already carries the estimate (heat × exposed non-farm share, −0.0052, p = 0.006), so the section could add: “The climate-exposed non-farm labor share carries a gradient of its own: in a heat year, a county one standard deviation above the mean loses an additional 0.5 percent of employment (p = 0.006), though it does not survive the joint specification (p = 0.058).”
- **Why:** The climate-exposed non-farm labor share is constructed at length in §2 and named in the heading, then never reported in §5 or anywhere else in the essay.
- **Source:** —

### L64 · §5 · HIGH · claim
**Undercuts §4's headline with no foreshadowing**

- **As written:** In a joint specification with other moderators, energy burden absorbs the explanatory role: the Social Vulnerability Index interaction is no longer significant (Table E3-T3).
- **Suggested:**  Keep the §5 sentence as written; add the qualification at the three places that ignore it.§4, end of L56: …Section 7 shows why that reversal is a fact about recording rather than about hardship. One qualification travels with all of these gradients: entered jointly with energy burden, the vulnerability index's own interaction no longer separates from zero (Section 5). The results below therefore describe where climate harm lands, not which characteristic of a place makes it land there.§9 (replaces the first two sentences): Beyond this, some limitations remain. The vulnerability index is a composite, so which component drives amplification is not identified — and Section 5 gives that point its sharpest form: entered against energy burden, the index's interaction does not survive. The index marks where the burden concentrates without isolating what makes a place vulnerable. The moderators are time-invariant baselines, so vulnerability that evolves with exposure is not modeled.§10, add the clause: …and drought pushes benchmark premiums up where vulnerability is high — though the index does not survive a joint test against energy burden, so it identifies where the burden falls rather than why.
- **Why:** This guts §4, the essay's headline section. §4 never mentions it, §9's limitations never mention it, and §10 restates the vulnerability results as if intact. A referee will read the paper as contradicting its own lead finding one section later.
- **Source:** Analysis/mechanism/horserace_coefs.csv, full_joint spec

### L76 · §7 · HIGH · claim
**The two cells compared are different hazards**

- **As written:** …drought's debt response concentrates in less-vulnerable counties…; at the state level, cold's debt response amplifies in more-vulnerable states… The same outcome flips sign across geographic scales.
- **Suggested:**  …The vulnerability gradient in measured debt is not stable across hazards or across geographic scales.
- **Why:** Nothing here demonstrates the same hazard flipping sign across levels — one cell is drought at county level, the other cold at state level. The abstract, §1 and §10 all repeat the same-outcome claim.
- **Source:** exposure_interaction_coefs.csv · exposure_interaction_state_coefs.csv

### L70 · §6 · HIGH · claim
**A result that cuts against the section, framed as reinforcing it**

- **As written:** Drought also moves hospital accounts in dollar terms: the cumulative effect on uncompensated care is −$3.88 million per hospital in the winsorized specification (p < 0.001).
- **Suggested:**  Drought moves hospital accounts in the opposite direction: uncompensated care falls by $3.88 million per hospital (p < 0.001), consistent with federal buffers such as crop insurance and USDA disaster payments which sever (a potential) causal chain from farm income to uncompensated care.  _(rewritten)_
- **Why:** "Also" frames as reinforcement a result that runs against the section's thesis: drought lowers uncompensated care. The sign is never interpreted and the paragraph ends on a trailing space. The buffering explanation already exists in Text/drafts/mechanisms_section.md, with a first stage showing indemnities spike on exactly that shock.
- **Source:** hospital_incidence_coefs.csv (winsorized) · Text/drafts/mechanisms_section.md

### L58 · §4 · HIGH · claim
**Main results section closes on an unexplained sign reversal**

- **As written:** A composite heat-vulnerability index … a one-standard-deviation increase is associated with median household income lower by $435 (p = 0.0002), though the sign flips for per-capita income (+$1,270, p = 0.006).
- **Suggested:**  An exploratory composite heat-vulnerability index … lower by $435 (p = 0.0002). Per-capita income moves the other way (+$1,270, p = 0.006), a divergence consistent with per-capita income rising mechanically where population falls; the composite is reported as a descriptive summary and is not used to price harm.
- **Why:** Two highly significant coefficients with opposite signs, stated and abandoned, closing the essay's headline section. The registry marks the composite exploratory and “not a causal price” — the draft never says so.
- **Source:** exposure_chei_coefs.csv · Plans/exhibit_registry.md CHEI note

### L50 · §4 · HIGH · claim
**Heat-induced job gains asserted with no mechanism**

- **As written:** In the least vulnerable counties heat appears to be, on net, absorbable; in the most vulnerable it costs jobs.
- **Suggested:**  In the least vulnerable counties the point estimate is positive, which I do not read as a benefit of heat: it is more plausibly composition, since the least vulnerable counties are also the larger and more service-oriented ones. What the interaction identifies is the difference between the two ends, not the level at either.
- **Why:** An employment gain of 886 jobs from extreme heat is a striking result that “absorbable” papers over. §3 already says the design identifies heterogeneity rather than levels — apply that here.
- **Source:** exposure_interaction_coefs.csv, Heat_CDD × Civilian_Employed

### L92 · §9 · HIGH · claim
**Limitations omit everything that actually threatens the paper**

- **As written:** Beyond this, some limitations remain. The vulnerability index is a composite, so which component drives amplification is not identified. The moderators are time-invariant baselines…
- **Suggested:**  Add the three real threats: the index's interaction does not survive a joint test against energy burden (§5); the debt sign flips compared across scales are different hazards rather than one outcome (§7); and the composite index reverses sign between two income measures (§4).
- **Why:** Two generic limitations, neither of which a referee would raise, while three specific ones documented in the essay's own sections go unmentioned.
- **Source:** essay3_draft.md §4, §5, §7

### L54 vs Essay 1 L96 · HIGH · claim
**Cross-essay contradiction on drought and premiums**

- **As written:** Essay 3: drought at a two-year lag pushes benchmark premiums up in vulnerable counties (interaction p = 0.001). Essay 1 §5: …heat runs +$19.5, -$10.5, and +$93; drought is null at every level.
- **Suggested:**  Add to Essay 3 §4: The first essay reports no average drought effect on premiums at any level of aggregation; that average conceals opposing margins — down $55 per month at the 25th vulnerability percentile and up $14 at the 75th — which is what the interaction identifies.
- **Why:** In the combined volume a reader meets a null in Chapter 1 and a signed effect in Chapter 3 for the same object. The reconciliation is real, but it is only implied — and by the broken sentence flagged separately at L54.
- **Source:** exposure_interaction_coefs.csv · premium_passthrough.csv

### L58 · §4 · MEDIUM · number
**Rounding**

- **As written:** …though the sign flips for per-capita income (+$1,270, p = 0.007).
- **Suggested:**  …though the sign flips for per-capita income (+$1,270, p = 0.006).
- **Why:** p = 0.00623. The −$435 / p = 0.0002 half is exact. Separately: this sign reversal between two income measures is stated and then abandoned — it closes the essay's main results section as an orphan.
- **Source:** Analysis/exposure_index/exposure_chei_coefs.csv

### L90 · §9 · MEDIUM · prose
**“Therefore” follows from nothing, and repeats a caveat already made**

- **As written:** The halves are complementary: selective observability explains why the unequal burden can be invisible… Therefore I frame the vulnerability interactions as heterogeneity and not causal moderation.
- **Suggested:**  Delete the sentence. The framing choice follows from non-random assignment of vulnerability, which §3 already states.
- **Why:** The connective claims an inference the preceding sentence does not support, the point duplicates §3, and the paragraph ends on a trailing space. “Heterogeneity and not causal moderation” is also the banned antithetical form.
- **Source:** essay3_draft.md §3

### L84 · §8 · MEDIUM · prose
**Named methodological antecedent with no citation**

- **As written:** As a descriptive metric in the style of the Lancet Countdown, the country absorbs on the order of 70 to 105 million person-years of extreme-heat exposure each year…
- **Suggested:**  Add the citation to references.bib and cite it, or drop the attribution and describe the construction directly.
- **Why:** The only named antecedent in the volume carrying no reference. It would also need a row in the renderer's citation map to typeset.
- **Source:** references.bib — absent

### L96, L98 · §10 · MEDIUM · prose
**Wrong interrogative, and an advocacy close**

- **As written:** …and when the instruments used to measure financial hardship fail to record them. … signifying the ever-present need to invest in better data capturing the lived experience of vulnerable populations.
- **Suggested:**  …and where the instruments used to measure financial hardship fail to record them. … so a hardship statistic built on credit records will understate the burden by most in the places bearing the most of it.
- **Why:** The essay is about place, not timing. And the closing clause is advocacy register rather than NBER — the replacement states the measurement consequence instead. §10 also has no back-of-envelope magnitude.
- **Source:** WORKFLOW.md — NBER style constraints

### L27 · §2 · MEDIUM · prose
**A nine-year vintage used as a time-invariant baseline, unexplained**

- **As written:** I use the 2014-2022 vintage as a time-invariant county baseline…
- **Suggested:**  I use the 2014–2022 average of the index as a time-invariant county baseline, since the components move slowly and a fixed baseline avoids conditioning on vulnerability that itself responds to exposure…
- **Why:** “The 2014-2022 vintage” reads as a single release; averaging nine years into a time-invariant measure needs the one-clause justification the replacement supplies.
- **Source:** —

### L27, L29, L33 · MEDIUM · prose
**ACS never expanded in this essay**

- **As written:** …percentile ranks across four ACS-derived themes… Census ACS table C24030… combining the … and the ACS.
- **Suggested:**  Expand at first use: …four themes derived from the American Community Survey (ACS)…
- **Why:** Essay 1 expands it; Essay 3 does not, and the standalone essay3.pdf has no other source for it. ACA, BEA, CMS, AQI, ERS and HIX are never expanded anywhere in the volume body — worth a sweep.
- **Source:** —

## Exhibits — Typeset tables and figures

### E1-T7 · CRITICAL · number
**The state row is computed against the county panel's baseline**

- **As written:** All three credit-bureau rows carry baseline 18.8%, and the note says responses are “expressed as a percentage of that ledger's own mean”.
- **Suggested:**  Compute the state row's baseline from the state panel and recompute its percent-of-baseline; the county rows keep 18.8%.
- **Why:** create_essay1_ledger_exhibits.R:236 takes mean(panel$Medical_Debt_Share) from the county panel and applies it to the state row too, so the state row's “7.19% of baseline” is against the wrong ledger — and the note asserts the opposite. This is a genuine error, not a judgement call.
- **Source:** Code/create_essay1_ledger_exhibits.R:236

### E3-T4 vs E3-F4 · HIGH · number
**Table and its own figure disagree on units by 100×**

- **As written:** Table header: Uncompensated care (% of net patient revenue) · Figure panel: Uncompensated care (share of net patient revenue) — same CSV, same 0.0294.
- **Suggested:**  Settle against the NASHP source column and make both say the same thing. The magnitudes imply a decimal share, so the table header is the likely error.
- **Why:** A reader comparing the table to its own figure sees a hundredfold discrepancy. Resolving it needs the source workbook, which was not opened.
- **Source:** Data/Hosp_Data/NASHP 2011-2023 HCT Data 2025 Feb.xlsx

### E3-T5 · HIGH · claim
**One predicted direction stated for three moderators with two orientations**

- **As written:** Note: “A negative value there means the measured response is SMALLER where the moderator is higher — the pattern predicted…”
- **Suggested:**  Split the note by orientation: for uninsurance and rurality a negative interaction is the predicted attenuation; for hospital access, where higher means more visible, the predicted sign is positive.
- **Why:** run_latent_hardship.R codes HospAccess as higher_is_worse = FALSE and builds it from log1p(hosp_n) — more hospitals means more visibility. A reader scoring those three rows by the note gets them backwards.
- **Source:** Code/run_latent_hardship.R:198-215

### Registry vs renderer · HIGH · claim
**Eleven registered exhibits have no home, and one placed exhibit has no row**

- **As written:** Unplaced: E1-T3, E1-T5, E1-T9, E1-F2, E1-F3, E2-T2, E2-T4, E2-T5, E2-F2, E2-F3, E2-F5. Placed but unregistered: E1-F0.
- **Suggested:**  For each: cite it, or retire the registry row. Essay 2 is the urgent case — it loses half its registered exhibits, including E2-T4 (the −5,522 cumulative-dose contrast) and E2-T5 (cross-estimator), which are its headline results.
- **Why:** The earlier “all 27 registered exhibits placed, none stranded” counted the renderer's map, not the registry. The build report cannot detect a registry row the map never mentions.
- **Source:** Plans/exhibit_registry.md vs render_rug.js EXHIBITS

### E3-F6, E2-F4, E1-F4, E3-F2 · MEDIUM · prose
**Series and significance encoded by colour alone**

- **As written:** E3-F6: four burden curves in salmon / olive / cyan / purple, same weight, no direct labels. E2-F4: two hazards by colour. E1-F4, E3-F2: significance as red vs grey.
- **Suggested:**  Add a second channel: direct end-of-line labels or dash patterns on E3-F6; shape as well as colour on E2-F4; and on E1-F4 and E3-F2 keep the colour but add a filled/hollow distinction.
- **Why:** All four collapse in greyscale, and salmon against olive is the canonical red–green failure. A printed committee copy loses the encoding entirely.
- **Source:** —

### E3-T2, E3-F2 · MEDIUM · prose
**“Cumulative cold-years” is never defined anywhere**

- **As written:** One of five hazard rows in E3-T2 and E3-F2, with no definition in the table note, the figure, the glossary, or Essay 3's prose.
- **Suggested:**  Add to the E3-T2 note: “Cumulative cold-years counts the extreme-cold years a county has accumulated over the panel to that point.”
- **Why:** A reader cannot tell whether it is a count, a z-score or a dose. A grep of essay3_draft.md returns zero hits for the term.
- **Source:** cumulative_dose_marginal.csv
