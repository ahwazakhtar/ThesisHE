# Essay 1 Outline — Deferred Costs: Climate Shocks, Local Economic Capacity, and Health-Market Ledgers

**Spec date:** 2026-08-13 · **Sources:** writing plan §6 (`Plans/dissertation_writing_and_framing_plan_20260712.md`),
`Plans/master_evidence_table.md` (Table A — row numbers cited as "Row N" below are BINDING),
`Plans/exhibit_registry.md` (E1-* exhibits), `Analysis/advisor_robustness/synthesis.md` (Aug 2026 additions).
**Target:** ~45–60 pages + appendix. **Draft file:** `essay1_draft.md` (author-written prose).

## Recommended WRITING order (≠ document order)

1. §5 Main income result → 2. §6 Identification & falsification → 3. §7 External validity
→ 4. §3 Data → 5. §4 Design → 6. §8 Medicare → 7. §9 Ledgers → 8. §2 Background
→ 9. §10 Interpretation → 10. §11 Conclusion → 11. §1 Introduction → 12. Abstract (last).

Write the introduction late enough that it describes the paper that exists.

## The three headline findings of this essay (never more — writing plan §10)

- **H1 (Row 1):** the 2012 drought event lowered per-capita income by ~$1,311 in first-onset counties.
- **H2 (Row 10):** direct Medicare morbidity/utilization responses to heat, cold, and AQI.
- **H4 (Row 8):** no coherent ACA local pass-through, with hazard-specific bounds.

Employment is **confirmatory-fragile** (Row 2), debt is a **secondary/measurement ledger**
(Rows 4–5), mechanisms are **supporting** (Rows 11b, 12). Do not promote any of them.

## Two author decisions to make BEFORE drafting §9 (evidence-table "untraceable" section)

- [ ] **The "$18 ESI premium" claim (Row 6):** no spec traces to +$18 at lag 2. Either identify
  the exact MEPS-IC spec behind it, restate to a traced coefficient (county drought L1 +$20.70,
  p<0.05, labeled ESI), or **drop ESI premiums from this essay** (recommended: drop — the ACA
  pass-through result is the premium story; ESI adds an untraced number and a second premium
  object to defend).
- [ ] **Drought→debt "~0.7 pp" (Row 5):** the state coefficient (0.72 pp) is not significant
  (p=0.18); the significant figure is the county 0.54 pp (p<0.01, sample-fragile). Recommended:
  report the county 0.54 pp with its level and fragility stated, and point forward to the
  Essay-2 scar as the robust drought→debt form.

---

# Abstract (write LAST; 180–250 words)

One paragraph containing exactly: (i) the question — what economic and healthcare costs
follow climate shocks, and which financial institutions record or price them; (ii) the primary
design — 2012 drought first-onset counties vs never-exposed controls; (iii) the headline income
estimate with one robustness clause (−$1,311; WCB/RI; flat two-decade pre-trend; strengthens
under DRDID) and the event-specific qualifier; (iv) one sentence on Medicare direct evidence
($112 now / $177 next year per beneficiary; ED +8–10/1,000; 65+/disabled); (v) one sentence
on ledgers (debt lagged but measurement-fragile; no coherent ACA pass-through, tight bound
for drought only); (vi) one contribution sentence (locating the cost in lagged local outcomes
and identifying which institutional ledgers record it). **Do not** enumerate lags, robustness
methods, or secondary outcomes. The current abstract in `Text/drafts/thesis_paper_abstracts.md`
is claim-accurate but dense — unpack, don't copy.

---

# §1 Introduction (~5–7 pp; write LAST)

**Flow (writing plan):** delayed costs are hard to observe → 2012 drought as a sharp event →
Medicare as separate direct evidence → ledgers respond unevenly → contributions.

- **¶1 Hook (economic problem, no results yet).** Climate damages are usually measured in
  contemporaneous mortality or output; but for households, costs can surface *after* the
  weather normalizes — in next year's income, next year's medical bills — and whether anyone
  *records* those costs depends on the institution doing the measuring. NBER-style concrete
  opening; idiom allowed here. No statistics yet.
- **¶2 The measurement problem.** Three reasons delayed incidence is hard: attribution over
  time, endogenous adaptation/migration, and the fact that each administrative ledger
  (credit bureaus, insurers, Medicare, employers) observes a different population under
  different rules. This paragraph plants the "ledger" vocabulary the whole dissertation uses.
- **¶3 What this paper does (design sentence 1).** The 2012 drought as a sharp natural
  experiment: 139 counties experiencing their *first* extreme-drought onset in 2012
  (Georgia, the Mountain West, and the Plains — **never "Midwest"**, Row 3) vs 2,534
  never-exposed counties; ITT of first onset on per-capita income.
- **¶4 Headline result 1.** Income fell ~$1,311 per capita (anchor: mean county PCPI
  ≈ $46,269 → ≈2.8%); robust to wild-cluster bootstrap (p=0.036) and randomization
  inference (p=0.0075), a flat 1990–2011 pre-trend, and strengthens to −$1,451 under a
  doubly-robust estimator. **In the same paragraph:** this is the effect of the 2012 event,
  not a general drought-response function — the pooled multi-cohort average is null at
  onset (−$324, SE 276) and long-run (Row 1 permitted language).
- **¶5 Headline result 2 (Medicare).** Separate, *parallel* direct evidence of a morbidity
  channel — never "mediates" (re-audit item ii): heat raises standardized Medicare spending
  $112/beneficiary contemporaneously and $177 the next year (baselines: $10,359/beneficiary
  → 1.1% and 1.7%) and ED visits by ~8–10 per 1,000 (baseline 629 → 1.2–1.5%); reproduces
  Deryugina et al. (2019) in-panel; non-agricultural; 65+/disabled population only.
- **¶6 Headline result 3 (ledgers).** The financial ledgers record this harm unevenly: cold
  raises the medical-debt share 1.35 pp at a one-year lag but debt is measurement-fragile;
  ACA benchmark premiums show **no coherent local pass-through** — coefficients flip sign
  across county/rating-area/state, within-state responses bounded below ≈5–8% of the mean
  premium, and the data rule out morbidity-scale pass-through **for drought only** (Row 8).
- **¶7 Contributions (3, mapped to literatures).** (i) causal incidence: a defended event
  estimate of local income cost (climate-econ literature: Deschênes–Greenstone, Deryugina,
  Hsiang); (ii) direct administrative morbidity evidence in the same panel (health econ);
  (iii) the institutional-visibility result — which ledgers record/price the harm
  (household finance + economics of measurement). One sentence each on what is *new*.
- **¶8 Roadmap.** One short paragraph.

**Style guard:** each result paragraph carries its own caveat; do not stack all caveats in a
final hedging paragraph. No "X, not Y" epigram constructions anywhere.

---

# §2 Institutional and conceptual background (~4–5 pp)

- **¶1 Conceptual frame (no structural model).** Shock → {health/utilization; labor
  productivity & local income; household liquidity; provider demand} observed through
  {Medicare; employers; ACA rating areas; credit bureaus; hospitals}. Reproduce the simple
  schematic from writing plan §5 as a figure or displayed text.
- **¶2 Why ledgers can disagree and still be informative.** Each ledger differs in
  eligibility, geographic aggregation, reporting rules, timing. Inconsistent responses are
  *evidence about recording*, not noise. (This defuses the "your outcomes disagree"
  committee question in advance — disarm-the-alternative structure.)
- **¶3 ACA premium institutions (needed for §9).** Rating-area-level price setting, state
  review, single statewide risk pool, unit-cost-only geographic rating factor, §153 federal
  risk adjustment, and the rate-filing calendar (plan-year-t rates filed mid-t−1 on
  experience through ~t−2 → only lagged shocks can be in the insurer information set).
  Keep mechanical; this is the *reason* the null is interpretable.
- **¶4 Credit-bureau debt institutions (needed for §9 + Essay 3 cross-ref).** Bureau
  medical debt requires insurance, a billed encounter, and a credit file; reporting-rule
  changes over the window. One paragraph, then point to Essay 3 for the full measurement
  critique.
- **¶5 The 2012 drought event.** Meteorology and geography of the 2012 extreme-drought
  onset (PDSI < −4), which counties were hit first, agricultural vs non-agricultural
  economies affected. Sets up cohort construction.

---

# §3 Data and construction of shocks (~5–6 pp) — this is the SHARED SPINE (write once, reuse shortened in Essays 2–3)

- **¶1 Panel scope.** County panel 2011–2023, ~3,100 counties (master: 118,732 rows ×
  3,232 counties, certified unique on fips×year — Row 27); state panel ~1996–2025 for the
  longer debt/premium series; all dollar values inflation-adjusted (state the base year).
- **¶2 Climate data & shock definitions.** NOAA/PRISM inputs; the four binary shock bins
  (High_CDD heat, High_HDD cold, extreme drought PDSI<−4, High_AQI) + z-score construction;
  historical-baseline windows; humidity (PRISM tdmean) held for robustness. Note the
  reviewer-requested wet bin exists and is null (Row 29) — one sentence, appendix pointer.
- **¶3 Outcomes by ledger.** BEA per-capita income; employment; Urban Institute credit-bureau
  medical-debt share; ACA benchmark premiums (rating-area, 2014–2025); CMS Geographic
  Variation Medicare (65+/disabled, 2014–2023); each with its population and observation
  window stated in one table — **E1-T1** (`Analysis/descriptive/descriptive_stats_table_main`).
- **¶4 Moderators used here.** Climate-exposed non-farm labor share; DOE LEAD energy-burden
  z. (SVI belongs to Essay 3 — do not introduce it here beyond a cross-reference.)
- **¶5 Fixed-effects & inference conventions.** `fixest` county+year FE, state-clustered;
  **the AAIW clustering paragraph goes here** (advisor item 1.2): county clustering is
  anticonservative by up to 7 orders of magnitude; Conley 200 km ≈ state clustering
  (p 0.0029 vs 0.0026); headlines survive every defensible level (worst case Conley 300 km:
  income p=0.008). Cite Abadie–Athey–Imbens–Wooldridge (QJE 2023). Lift from
  `Analysis/advisor_robustness/clustering_justification.md`.
- **¶6 Measurement limitations preview.** One paragraph: debt is a bureau artifact;
  premiums are a regulated price, not a cost; Medicare covers 65+/disabled only. Each gets
  full treatment where used.

---

# §4 The 2012 drought design (~4–5 pp)

- **¶1 Why 2012.** First-onset logic: counties whose *first* extreme-drought exposure in
  the panel era is 2012 → clean event timing, no prior-treatment contamination; never-exposed
  counties as controls avoids forbidden comparisons.
- **¶2 Cohort construction.** 139 treated vs 2,534 never-exposed; geography = Georgia +
  Mountain West + Plains (**Row 3: never "Midwest"**). Balance table — **E1-T2**. Map —
  **E1-F1** (to be generated; add registry row when built).
- **¶3 Estimating equation.** 2×2 DiD, fips+Year FE, ITT of first onset; define the ATT
  estimand precisely (event-specific, treated-geography — Gate B checklist: treatment,
  comparison, unit/period, FE, clustering, assumption, threat+test).
- **¶4 Identifying assumption & threats.** Parallel trends absent onset; threats: selection
  into drought geography, differential rural trends, spillovers to controls. Each threat
  names its §6 test. **Spillover qualifier (advisor 1.1) verbatim concept:** "county
  coefficients capture local exposure; adjacent-county exposure adds a same-signed regional
  component the local coefficient understates" — so the local ATT is a lower bound on
  regional exposure, not confounded by it.
- **¶5 Inference plan.** 17 treated states → few-cluster problem; pre-commit to analytic +
  wild-cluster bootstrap (Webb weights) + randomization inference. One sentence forward to
  §6.

---

# §5 Main income result (~4–5 pp) — WRITE THIS FIRST

- **¶1 The estimate.** ATT on real PCPI = **−$1,311** (analytic p=0.027) — **E1-T3**.
  Anchor immediately: mean county PCPI ≈ $46,269 → ≈2.8% of per-capita income; also express
  as dollars per county-resident-year. State population it applies to (139 treated
  counties' residents).
- **¶2 Robust inference.** WCB (Webb) p=0.036, CI [−2,911, −138]; RI p=0.0075 —
  **E1-T4**. One-sentence explanation of *why* WCB/RI are the right tools with 17 treated
  clusters (points back to §3 ¶5 / AAIW note).
- **¶3 Doubly-robust check.** DRDID **−$1,451** (SE 515, CI [−2,461, −441]) — conditioning
  on composition *strengthens* the effect; interpret (rural/urban covariate balance).
- **¶4 Dynamics.** Event-time profile — **E1-F3** (`dr_csdid_eventtime.csv`, frontier
  values only). Describe onset timing and persistence within this panel; hand the
  *persistence question itself* to Essay 2 in one sentence (one-result-one-home).
- **¶5 Magnitude in context.** Compare to drought-agriculture literature estimates and to
  the county income base; note advisor item 1.3: the effect is stable extending the window
  back to 1990 (PDSI_Lag1 −$99 to −$132 across 1990/2000/2011 starts) with improving
  precision — the 2011–2023 window is a conservative choice, not a cherry-pick.

---

# §6 Identification and falsification (~5–6 pp)

- **¶1 Two-decade pre-trend.** BEA income 1990–2011: differential trend **−$69/yr (p=0.44)**
  — flat — **E1-F2**. State explicitly that this substitutes for HonestDiD (which cannot
  run on the 2012 cohort — no in-panel pre-period) and covers the "future shocks predict
  past outcomes" falsification (Row 26). The event-study joint Wald rejection (F=6.9) is
  business-cycle wiggle, not secular drift — say so and note DRDID conditions on it.
- **¶2 Leave-one-treated-state-out.** ATT envelope [−1,687, −914]; never exits the WCB CI;
  CO/NE drops lift analytic p to 0.075/0.057 — exactly the few-cluster sensitivity WCB
  already handles (frame as *why* WCB is primary, not as a weakness discovered).
- **¶3 Placebo onsets.** B=1,000 placebo distribution centered on zero; two-sided p=0.009.
- **¶4 Spatial robustness (advisor package).** Spillover analysis: own-vs-neighbor split
  unidentified (neighbor exposure correlation r=0.94–0.97) but the neighbor block is
  jointly significant and own+neighbor total exceeds own-only — **headline is a lower
  bound on regional exposure** (lift from `spillover_synthesis.md`). Conley SEs to 300 km:
  income worst case p=0.008.
- **¶5 Specification robustness roll-up.** Humidity, demographics (Row 25 clean nulls),
  threshold sensitivity — one summary paragraph + table **E1-T4**; full grids to appendix.
- **¶6 What this design does NOT establish.** Event-specific ITT; treated-geography
  external validity limits; no mechanism identification inside the DiD. Two sentences,
  forward pointer to §7 and §10.

---

# §7 External validity and pooled cohorts (~3–4 pp)

- **¶1 The question.** Is 2012 a window onto droughts generally? Answer via estimands, not
  hope: pooled multi-cohort frontier estimator (`did::att_gt`, doubly-robust).
- **¶2 The pooled answer.** Onset (e=0) = **−$324 (SE 276): null**; long-run simple ATT
  **+$350 (SE 585): null/reversed**. **NEVER cite the manual aggregation's −$1,050/p=0.002**
  (invalid independence SEs — coding audit A4; manual-CS output is descriptive only,
  E1-T5 note). The 2012 effect is event-specific *even at onset*.
- **¶3 Why 2012 differs (interpretation, hedged).** Candidate explanations: severity,
  first-onset sharpness, agricultural-cycle timing, control-group composition across
  cohorts. Graded hedging — "consistent with", no adjudication.
- **¶4 Employment (the fragile secondary — Row 2).** The ~2,000-job decline clears WCB
  (p=0.003) and RI (p=0.037) but attenuates ~58% under DRDID (−871, SE 433, barely
  excludes 0) and **reverses sign** in the pooled estimator (+2,609, SE 2,245). Report
  with fragility given equal prominence to the estimate; explicitly not a co-headline;
  event-specific. LOO envelope [−2,156, −1,854] shows the fragility is conditioning, not
  geography.

---

# §8 Direct Medicare utilization evidence (~5–6 pp)

**Framing rule (re-audit item ii, Row 10):** *parallel direct evidence of a separate
morbidity channel* — never mediation of the income result, never extended to working-age
debt. Population: 65+/disabled, 2014–2023, CMS Geographic Variation.

- **¶1 Why Medicare.** Administrative, near-universal for 65+, standardized payments →
  direct observation of utilization without insurance-composition confounds; and it
  answers "where is the health mechanism?" with measurement rather than inference.
- **¶2 Design.** Distributed-lag FE (fips+Year, state-clustered) on standardized per-capita
  spending and ED visits/1,000; within-county heat/cold/AQI variation; N=30,641
  county-years, 3,124 counties — **E1-T6** (`medicare_channel_coefs.csv`).
- **¶3 Heat results.** Spending +$112 contemporaneous (p=0.013), +$177 at L1 (p=0.001),
  +$75 at L2 (p=0.003) — anchor every one: baseline $10,359/beneficiary → 1.1% / 1.7% /
  0.7%. ED +7.8/1,000 (p=0.006), L1 +9.5 (p=0.0002) on a base of 629 → 1.2% / 1.5%.
  (Registry values $111.6/$175.6 — cite from the post-dedup CSV when building the table.)
- **¶4 Cold and AQI.** Cold L2 +$85 and +9.0 ED; AQI ED +4.8/1,000 (p=0.0003, Row 14).
  Dynamic profiles — **E1-F4**.
- **¶5 Robustness.** Anderson utilization index; sharpened BKY q<0.05 (heat→ED, AQI→ED);
  Conley SEs tighter; `did_multiplegt_dyn` confirms heat +$80 at h=2; reproduces
  Deryugina et al. (2019) in-panel. Non-agricultural: Drought×Ag interaction null.
- **¶6 The labor-exposure margin (mechanism-supporting, Rows 11b/12).** The burden
  "operates substantially outside agriculture" (**not** "primarily through" — Row 11b):
  heat × climate-exposed non-farm labor share on log employment −0.0052 (p=0.006),
  survives division×year FE (−0.0042, p=0.015) and Conley (p=0.033); heat × energy-burden z
  −0.0084 (p=0.005), survives division×year FE and the log horse-race (−0.0068, p=0.019).
  Present as interaction gradients, not headline employment levels. **Forbidden:** the
  −2,011/−721 low-ag cold figures (Row 11a RETIRED — levels artifact, dies in logs).
  **Do not** claim the energy-burden *income* margin (not robust, Row 12).
- **¶7 Scope discipline.** One paragraph: different population from the income result and
  from working-age debt; no chain claimed. (This is the honest seam between H1 and H2 —
  give it its own paragraph rather than a subordinate clause.)

---

# §9 Financial-ledger responses: debt and ACA premiums (~6–7 pp)

- **¶1 Section logic.** Having shown real costs (income) and direct morbidity (Medicare),
  ask which financial ledgers record or price them. Two ledgers: credit-bureau medical
  debt (recording) and ACA premiums (pricing). Ledger-comparison exhibit — **E1-T7** and
  summary figure **E1-F5** (build at drafting; add registry row).
- **¶2 Debt: cold.** Cold shock → medical-debt share **+1.35 pp at L1** (state FE,
  p=0.012; county mirror +1.2 pp, p<0.001 — cite each with its level, never "~1.1", Row 4).
  Anchored to the mean debt share. Lagged **association**, not a causal 2×2. Survives p90
  threshold and humidity; the county cell is sample-fragile (significant full-panel, null
  on the control-observed subsample — state as a measurement caveat).
- **¶3 Debt: drought (author decision above).** County +0.54 pp at L2 (p<0.01); the state
  primary is not significant (0.72 pp, p=0.18) — say so plainly (Row 5, flagged
  contradiction 2: a level-of-aggregation disagreement the prose must not paper over).
  One forward sentence: the robust drought→debt object is the Essay-2 exit-asymmetry scar.
- **¶4 Debt: why fragile.** Bureau debt requires insurance + billed encounter + credit
  file; reporting-rule changes; aggregation sensitivity. Two-three sentences; full critique
  lives in Essay 3 (one-result-one-home).
- **¶5 Premiums: design.** Two-level pass-through on lagged (t−2) shock shares —
  rating-area×year primary (RA + State^Year FE, state-clustered), state×year secondary;
  county specs shown only as a labeled transparency trail (misspecified — ≈86% of premium
  variance is state×year). Timing: t−2 because of the rate-filing calendar (§2 ¶3).
- **¶6 Premiums: the null.** Coefficients flip sign across levels — cold t−2: −$15.5
  (county) → +$12.6 (RA) → −$16.7 (state); heat: +$19.5 → −$10.5 → +$93; drought null
  everywhere. Sign instability across the institutions' own levels = **no coherent local
  pass-through** (Row 8). Between-state heat (+$54–93/mo) is ~10× too large for a claims
  channel and cold is mis-signed vs. the essay's own Medicare result → premium-*level*
  correlate, not pricing.
- **¶7 Premiums: equivalence bounds (the teeth).** Against the full-morbidity benchmark
  $9.33–$14.75 PMPM: **drought** β=3.13 (SE 2.60), δ*=$7.40 → rules out pass-through
  >50–79% of the benchmark (STRONG); **heat** δ*=$24.6 and **cold** δ*=$22.0 exceed the
  band → equivalence with full pass-through *not* rejected; within-state responses ≤≈5–8%
  of the mean premium (~$366/mo). **The tight "rules out morbidity-scale pass-through"
  sentence is DROUGHT-ONLY** (Row 8). `passthrough_bounds.csv`.
- **¶8 Mediation corollary.** 92–99% of each shock→debt coefficient survives premium
  adjustment (drought L2 0.987; cold L1 0.922) — the expected corollary of a null first
  stage; label **decomposition, not causal mediation** (Row 9).
- **¶9 Institutional interpretation.** The null is *explained*, not mysterious: single
  statewide risk pool, unit-cost-only geographic rating, §153 risk adjustment. The
  "unpriced margin" phrase is permitted **only** as the institutional-null contribution —
  the actuarial-repricing narrative is RETIRED (Row 7). Keep hazard-specific; no blanket
  "insurers leave climate costs unpriced."
- **¶10 Systemic spending null (Row 15).** State per-capita health spending shows no
  robust climate signal and tracks income/unemployment — the contrast that motivates
  looking at *lagged household* ledgers in the first place. (Optionally move to §2 or §5
  as motivation; it must appear exactly once.)

---

# §10 Interpretation and limitations (~3–4 pp)

- **¶1 What the three results jointly say.** Real local costs exist (H1), direct morbidity
  is measurable in administrative data (H2), and the pricing institution does not locally
  price it (H4) — triangulation across ledgers, **not** an identified propagation chain
  (Row 28 framing).
- **¶2 External validity.** Event-specific ITT; treated geography; pooled null; Medicare
  population limits; marketplace-era premium window.
- **¶3 Measurement limits.** Debt (bureau artifact), premiums (regulated price), ACS
  smoothing on demographic margins. Co-locate each with one sentence of consequence.
- **¶4 What would change the conclusions.** Working-age utilization data; patient-flow
  (catchment) hospital exposure; longer post-2012 horizon. Honest, short.

# §11 Conclusion (~1.5–2 pp)

- **¶1** Restate the question and the three findings in plain economic language (no new
  numbers beyond the headline three; each with its one-clause qualifier).
- **¶2** Institutional lesson: where climate costs are recorded (Medicare, income) vs
  not priced (ACA premiums) vs selectively recorded (bureau debt) — hands the baton to
  Essays 2 (persistence) and 3 (distribution/observability) in one sentence each.
- **¶3** Policy sentence(s): what a regulator/adaptation planner should take — bounded,
  pointing to the sufficient-statistics synthesis chapter. No new claims.

---

# Appendix inventory (build as needed while drafting)

| App. | Content | Source |
|---|---|---|
| A | Cohort definitions + balance | E1-T2 inputs |
| B | Clustering/WCB detail + AAIW discussion | `clustering_justification.md`, `did_robustness_summary.md` |
| C | LOO estimates, placebo distribution | `falsification_summary.md` |
| D | Full lag grids (income/employment/debt) | county/state family outputs |
| E | Premium institutional detail + equivalence calculations | `premium_mediation_summary.md`, `passthrough_bounds*` |
| F | Debt reporting-rule treatment | Row 4/5 sources |
| G | Spillover analysis (advisor 1.1) | `spillover_synthesis.md` |
| H | Window extension 1990– (advisor 1.3) + horizon sensitivity (1.4) | `window_extension_note.md`, `horizon_sensitivity_note.md` |
| I | MAD impulse scaling (advisor 1.5 — pending advisor's construction choice for employment) | `mad_scaling_note.md` |
| J | Wet-shock bin null (Row 29) | `wet_shock_summary.md` |

# Standing prohibitions for this essay (from the evidence table)

1. "Midwest drought" (Row 3). 2. Manual-CS −$1,050 / p=0.002 (Row 1). 3. Employment as
co-headline (Row 2). 4. "~1.1 pp" cold-debt without level attribution (Row 4). 5. The
−2,011/−721 low-ag cold employment figures (Row 11a). 6. "Primarily through labor
exposure" (Row 11b — use "substantially outside agriculture"). 7. Energy-burden *income*
effect as robust (Row 12). 8. Actuarial-repricing narrative (Row 7). 9. Blanket
"unpriced climate costs" — the tight bound is drought-only (Row 8). 10. Significance
selected on rating-area SEs (Row 8 — state clustering primary). 11. Medicare as mediator
of the income result (Row 10). 12. The $18 ESI figure until traced (Row 6).

# Two references still incomplete (author to supply exact citations — do not guess)

- Audi et al. 2024–25 (FEMA hurricane risk × hospital financial ratios)
- Doremus et al. 2022 (energy burden / affordability adaptation)
