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
- **Suggested:**  Lead each with cold-employment compounding — the designated headline — and carry debt second, framed as a measurement critique.
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
- **Suggested:**  Rewrite §1 ¶4 as a results walkthrough with the section pointers the abstract cannot carry.
- **Why:** In the combined volume a reader meets the same paragraph twice within a page.
- **Source:** —

### Missing section · HIGH · claim
**No “What identifies compounding?” honesty box**

- **As written:** Abstract, §1 and §10 state cold compounding with no estimator caveat. The honest content exists in §6 and §8 but never reaches them.
- **Suggested:**  Add the required subsection, including the sentence that the result is “a pattern supported by particular estimators, not an estimator-invariant law.”
- **Why:** The framing plan mandates this box. The smooth quadratic dose term is flat and wrong-signed (+417); the levels outcome is weighting-sensitive (−5,522 unweighted vs −41,573 weighted). Row 17 also requires naming the estimator whenever the ~5,500 figure is cited.
- **Source:** dissertation_writing_and_framing_plan_20260712.md §7 · Row 17

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
- **Suggested:**  5 Energy burden — or report the non-farm labor moderator in the section.
- **Why:** The climate-exposed non-farm labor share is constructed at length in §2 and named in the heading, then never reported in §5 or anywhere else in the essay.
- **Source:** —

### L64 · §5 · HIGH · claim
**Undercuts §4's headline with no foreshadowing**

- **As written:** In a joint specification with other moderators, energy burden absorbs the explanatory role: the Social Vulnerability Index interaction is no longer significant (Table E3-T3).
- **Suggested:**  Keep the sentence — but foreshadow it in §4 and carry the qualification into §9 and §10.
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

### L58 · §4 · MEDIUM · number
**Rounding**

- **As written:** …though the sign flips for per-capita income (+$1,270, p = 0.007).
- **Suggested:**  …though the sign flips for per-capita income (+$1,270, p = 0.006).
- **Why:** p = 0.00623. The −$435 / p = 0.0002 half is exact. Separately: this sign reversal between two income measures is stated and then abandoned — it closes the essay's main results section as an orphan.
- **Source:** Analysis/exposure_index/exposure_chei_coefs.csv
