# Essay 1 Outline — Deferred Costs: Climate Shocks, Local Economic Capacity, and Health-Market Ledgers

**Spec date:** 2026-08-13 · **Sources:** writing plan §6 (`Plans/dissertation_writing_and_framing_plan_20260712.md`),
`Plans/master_evidence_table.md` (Table A — row numbers cited as "Row N" below are BINDING),
`Plans/exhibit_registry.md` (E1-* exhibits), `Analysis/advisor_robustness/synthesis.md` (Aug 2026 additions).
**Target:** ~45–60 pages + appendix. **Draft file:** `essay1_draft.md` (author-written prose).

> **RESTRUCTURE (2026-08-17, Medicare-led — supersedes the section map below; advisor
> sign-off pending):** the essay is now Medicare-led with the 2012 drought natural
> experiment demoted to Appendix A after the farm/nonfarm baseline decomposition
> (`Plans/essay1_restructure_20260817.md`; evidence-table Row 1 AMENDED). New document
> order: §1 Intro · §2 Background · §3 Data · **§4 Medicare (main result)** · §5 Ledgers ·
> **§6 Household economic capacity (NEW)** · §7 Interpretation · §8 Conclusion ·
> **Appendix A.1–A.3** · Appendix B.
>
> **CONDENSED 2026-08-18:** Appendix A is rewritten below under its own heading (11 ¶
> across A.1–A.3, down from 21 across A.1–A.4; former A.4 dissolved into A.3), and §3 gains
> **¶1b/¶4b** for the two new generated data tables (E1-T0a/E1-T0b). Those sections now use
> the NEW numbering. §8–§11 further down still use the OLD numbering (= new §4/§5/§7/§8) —
> map via the table in the restructure doc.

## Recommended WRITING order (≠ document order; post-restructure)

1. §4 Medicare (main result) → 2. §5 Ledgers → 3. §6 Household capacity
→ 4. Appendix A.1–A.3 (largely pre-written; condensed 2026-08-18) → 5. §3 Data → 6. §2 Background
→ 7. §7 Interpretation → 8. §8 Conclusion → 9. §1 Introduction → 10. Abstract (last).

Write the introduction late enough that it describes the paper that exists.

## The three headline findings of this essay (never more — writing plan §10)

**Reordered Medicare-first 2026-08-17** to match the restructure. The `H` labels are the
writing plan's hypothesis ids, not a ranking — they are kept unchanged so cross-references
to plan §10 still resolve; the *list order* is the essay's order of prominence.

- **H2 (Row 10) — the centerpiece.** Direct Medicare morbidity and utilization responses to
  heat, cold, and air quality (65+/disabled, 2014–2023): heat raises standardized spending
  $112/beneficiary contemporaneously and $177 at one lag, ED visits ~8–10 per 1,000.
  Directly measured, non-agricultural, reproduces Deryugina et al. (2019) in-panel.
- **H4 (Row 8).** No coherent ACA local pass-through — coefficients flip sign across
  county/rating-area/state; within-state responses bounded below ≈5–8% of the mean premium.
  The tight "rules out morbidity-scale pass-through" sentence is **drought-only**.
- **H1 (Row 1 — AMENDED 2026-08-17).** Climate stress reduces household economic capacity.
  **Lead this with the window-stable distributed-lag relationship** (−$99 to −$132 per PDSI
  unit across 1990/2000/2011 window starts). The 2012 figure of −$1,311 is a **raw event
  contrast, not a robust causal income loss**: ≈$900 of it is farm income reverting from the
  record 2011 commodity-price peak, and the baseline-invariant nonfarm component is −$261 to
  −$414 (≈0.5–0.8% of mean PCPI), sign-stable across every pre-period but never
  conventionally significant. Full treatment in **Appendix A**; the compact main-text
  version is **§6**.

Employment is **confirmatory-fragile** (Row 2), debt is a **secondary/measurement ledger**
(Rows 4–5), mechanisms are **supporting** (Rows 11b, 12). Do not promote any of them.

**Standing prohibitions attached to H1** (Row 1 permitted language): do not cite WCB/RI or
DRDID as vindicating the causal *magnitude* (DRDID shares the 2011 baseline); do not report
the two-decade trend as "flat" without its 21-year accumulation (≈−$1,450) and the joint
Wald rejection; do not cite the $6.9B aggregate arithmetic; never "Midwest" (Row 3).

## Author decisions — RESOLVED 2026-08-13

- [x] **The "$18 ESI premium" claim (Row 6): DROPPED.** ESI (employer-sponsored, MEPS-IC)
  premiums are removed from Essay 1 entirely — the ACA institutional null carries the
  premium story. Do not reintroduce the $18 or any ESI coefficient.
- [x] **Drought→debt (Row 5): county +0.54 pp (p<0.01) leads**, with the sample-fragility
  and the ns state primary (0.72 pp, p=0.18) disclosed beside it, and a forward pointer to
  the Essay-2 scar as the robust drought→debt form. (Harness §9 ¶3 already implements this.)
- [x] **Anchors: E1-T1 values** (mean PCPI $53,145 → headline ≈2.5%; mean employment
  48,068) — confirmed over the task-1.5 candidates; see `TK_resolutions.md` §B.

---

# Abstract (write LAST; 180–250 words)

**REORDERED 2026-08-17** — Medicare leads; the drought event is no longer the design
sentence. One paragraph containing exactly: (i) the question — what economic and healthcare
costs follow climate shocks, and which financial institutions record or price them; (ii) the
design in one clause — a US county panel, 2011–2023, with distributed-lag fixed-effects
estimates and a first-onset event study; (iii) **the headline result: direct Medicare
morbidity and utilization** ($112 now / $177 next year per beneficiary; ED +8–10 per 1,000;
65+/disabled, reproducing Deryugina et al. in-panel); (iv) one sentence on the ledgers (debt
lagged but measurement-fragile; no coherent ACA pass-through, with the tight bound for
drought only); (v) one sentence on household capacity — the **distributed-lag** income
relationship, with the 2012 event named as an event contrast whose farm component reverts
from the 2011 price peak; (vi) one contribution sentence (locating the cost in lagged local
outcomes and identifying which institutional ledgers record it).

**Do not** enumerate lags, robustness methods, or secondary outcomes. **Do not** cite
WCB/RI/DRDID in the abstract at all, and never describe the two-decade pre-trend as "flat"
(Row 1 forbids both — the trend must travel with its 21-year accumulation and the joint Wald
rejection wherever it appears). The abstract in `Text/drafts/thesis_paper_abstracts.md`
still carries the **pre-restructure** framing — it is a downstream surface awaiting advisor
sign-off (restructure doc §"Downstream surfaces"), so do not copy from it.

---

# §1 Introduction (~5–7 pp; write LAST)

**Flow (REORDERED 2026-08-17 to match the harness `s1p3`–`s1p6`):** delayed costs are hard
to observe → what the paper does → **Medicare as the direct, administrative result** →
ledgers record unevenly → household capacity, paired with its decomposition → contributions.
The pre-restructure flow led with the 2012 drought event; it no longer does.

- **¶1 Hook (economic problem, no results yet).** Climate damages are usually measured in
  contemporaneous mortality or output; but for households, costs can surface *after* the
  weather normalizes — in next year's income, next year's medical bills — and whether anyone
  *records* those costs depends on the institution doing the measuring. NBER-style concrete
  opening; idiom allowed here. No statistics yet.
- **¶2 The measurement problem.** Three reasons delayed incidence is hard: attribution over
  time, endogenous adaptation/migration, and the fact that each administrative ledger
  (credit bureaus, insurers, Medicare, employers) observes a different population under
  different rules. This paragraph plants the "ledger" vocabulary the whole dissertation uses.
- **¶3 What this paper does** [`s1p3`]. The county panel and the question — what healthcare
  and economic costs follow climate shocks, and which institutions record or price them.
  Name the four ledgers and the two designs in one sentence each: a distributed-lag
  fixed-effects panel for the recurring shocks, and the 2012 first-onset event (139
  counties — Georgia, the Mountain West, and the Plains, **never "Midwest"**, Row 3 — vs
  2,534 never-exposed) reported in Appendix A. Do **not** open on the drought experiment.
- **¶4 Result 1 — Medicare** [`s1p4`]. The direct, administratively-measured result: heat
  raises standardized Medicare spending $112/beneficiary contemporaneously and $177 the next
  year (baseline $10,359 → 1.1% and 1.7%) and ED visits by ~8–10 per 1,000 (baseline 629 →
  1.2–1.5%); cold and air quality likewise. Reproduces Deryugina et al. (2019) in-panel;
  non-agricultural; 65+/disabled population only. Never "mediates" (re-audit item ii) — this
  is parallel direct evidence, not a link in a chain.
- **¶5 Result 2 — ledgers** [`s1p5`]. The financial ledgers record the harm unevenly: cold
  raises the medical-debt share 1.35 pp at a one-year lag but debt is measurement-fragile;
  ACA benchmark premiums show **no coherent local pass-through** — coefficients flip sign
  across county/rating-area/state, within-state responses bounded below ≈5–8% of the mean
  premium, and the data rule out morbidity-scale pass-through **for drought only** (Row 8).
- **¶6 Result 3 — household capacity, with its decomposition** [`s1p6`]. Lead with the
  **window-stable distributed-lag** relationship (−$99 to −$132 per PDSI unit across
  1990/2000/2011 window starts). Then the 2012 event **in the same paragraph as its
  resolution** (Row 1 AMENDED — the two must never appear apart): the raw contrast is
  −$1,311, about **2.5% of mean county PCPI of $53,145** (E1-T1 anchor, 2023 USD — the
  $46,269/2.8% pair is **superseded**, see `TK_resolutions.md` §B), of which ≈$900 is farm
  income reverting from the record 2011 commodity-price peak; the baseline-invariant nonfarm
  component is −$261 to −$414 (≈0.5–0.8% of mean PCPI) and never conventionally significant.
  Event-specific: the pooled multi-cohort average is null at onset (−$324, SE 276).
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
- **¶1b Data sources and coverage — Table E1-T0a** (NEW 2026-08-18, author request).
  `Analysis/descriptive/data_sources_table.tex`, 14 sources, generated by
  `Code/create_data_source_tables.R`. **Every count in it is computed at build time** (year
  range over non-missing rows, non-missing obs, distinct units), so the table cannot drift
  from the delivered panel. Walk the reader down it **by group, not row by row**: climate
  and environment (NOAA nClimDiv, EPA AQS, PRISM) · economic ledgers (BEA, ACS) ·
  health-market ledgers (Urban Institute, HIX Compare, CMS) · moderators (ACS C24030, DOE
  LEAD, USDA ERS/BEA). Then say the three things the table cannot: **coverage ≠ estimation
  sample** (county outcomes 2011–2023, Medicare 2014–2023, premiums marketplace-era); AQI
  covers **1,194 monitored counties**, an urban-selection caveat that travels with every
  air-quality result; PRISM is CONUS only. One clause on the **real-dollar base
  divergence** — county series 2023 USD, state series 2025 USD (read from
  `us_cpi_annual.csv` at build time) — never move a dollar figure between panels.
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
- **¶4b Variable definitions — Table E1-T0b** (NEW 2026-08-18, author request).
  `Analysis/descriptive/variable_definitions_table.tex`, 20 variables in four panels
  (shocks / outcomes / moderators / auxiliary), same generator as E1-T0a; definitions are
  authored metadata, coverage columns are computed. **Keep the prose short — the table is
  the reference object.** Three construction facts must be stated here because later
  sections depend on them: (a) shocks are **binary** against a **fixed national 1990–2000
  p80 threshold**, not a within-county quantile, so shock status is comparable across
  counties and over time; (b) both labor moderators are **time-invariant and z-scored**, so
  their interactions are **per-SD gradients within a shock year, not employment levels** —
  this is the sentence that stops the §4 ¶6 mechanism gradients being read as job losses;
  (c) employment enters in **logs** (levels are county-size contaminated — the superseded
  −2,011 low-ag figure), and any log gradient translated into jobs is evaluated at the
  **median county's 10,773 workers, never the mean of 48,068** (the skew inflates it ~4.5×).
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

# Appendix A — The 2012 drought natural experiment (~8–10 pp)

> **CONDENSED 2026-08-18** (author request). Appendix A ran to 21 paragraphs across four
> subsections (old §4/§5/§6/§7, ~16–20 pp). It is now **11 paragraphs across three**:
> A.1 (5→2), A.2 (6→4), A.3 (former A.3 + A.4, 10→5). Nothing was dropped — the enumerable
> per-test prose moved into **Table E1-T4**, generated by `Code/create_falsification_table.R`
> with every statistic read from the committed robustness CSVs. This keeps advisor ask #2
> ("does the appendix satisfy the committee's natural-experiment ask?") answerable: the
> committee still sees every test, in a form a referee can scan. Harness ids in brackets.

## A.1 The 2012 drought design (~2 pp)

- **¶1 Why 2012, first onset, and the cohort** [`s4p1`] — *merged from old ¶1+¶2.*
  First-onset logic: counties whose *first* panel-era extreme drought is 2012 → clean event
  timing, no prior-treatment contamination; never-exposed controls avoid forbidden
  comparisons. 139 treated vs 2,534 never-exposed; geography = Georgia + Mountain West +
  Plains (**Row 3: never "Midwest"**). Balance **E1-T2**; map **E1-F1**. Treated counties
  smaller/more rural → motivates DRDID and the two-decade pre-trend test.
- **¶2 Equation, identifying assumption, and inference** [`s4p2`] — *merged from old
  ¶3+¶4+¶5.* 2×2 DiD, fips+Year FE, state-clustered; ITT of first onset, 139 counties,
  2011–2023, vs never-exposed, under parallel trends absent onset (Gate-B checklist in one
  sentence). Three threats, each mapped to a row of **E1-T4**: selection into drought
  geography; single-state idiosyncrasy; spillovers to controls. **Spillover qualifier
  (advisor 1.1):** county coefficients capture local exposure; adjacent-county exposure adds
  a same-signed regional component the local coefficient understates — the local ATT is a
  lower bound on regional exposure. 17 treated states → pre-commit to analytic + WCB (Webb)
  + RI side by side.

## A.2 The event contrast and its decomposition (~3–4 pp)

- **¶1 The raw contrast, its inference, and composition** [`s5p1`] — *merged from old
  ¶1+¶2+¶3; per-test detail now in E1-T4.* ATT on real PCPI **−$1,311** (analytic p=0.028)
  — **E1-T3** — anchored to mean county PCPI **$53,145** (E1-T1, 2023 USD) ≈ **2.5%**.
  Event- and geography-specific ITT. WCB p=0.036, CI [−$2,911, −$139]; RI p=0.0075. DRDID
  **−$1,451** (SE 515). Close on the caveat that sets up ¶2: DRDID shares the single 2011
  pre-year baseline.
- **¶2 Dynamics and the baseline question** [`s5p2`] — event study around 2012; pooled
  −$1,311 = mean of the twelve post-year gaps exactly; 2008–2010 leads −$1,459…−$1,591
  (ns, p=0.17–0.32) are the *same magnitude* as the post gaps; baseline sensitivity
  −$1,311 (pre=2011) → −$285 (pre=2009–2011) — **E1-T8**, fig **E1-F7**. Set up the two
  readings (differential trajectory vs treated-specific 2011 spike).
- **¶3 Farm and nonfarm decomposition** [`s5p3`] — **the payload; do not compress.**
  Treated farm income/capita $1,903–2,438 (2007–10) → **$4,339 in 2011**; 2008–10 leads
  ≈85% farm; farm ATT −$907 (p=0.13) vs 2011, −$14 (p=0.95) vs pooled 2009–2011; nonfarm
  baseline-invariant −$261…−$414 (≈0.5–0.8% of mean PCPI), never conventionally
  significant — **E1-F6**. Row 1 AMENDED.
- **¶4 Closer: hand-back to the main text** [`s5p4`] — the durable drought–income form is
  the window-stable distributed lag in **§6**; literature yardstick Deschênes–Greenstone
  (2007), Deryugina (2017). Do **not** cite the retired $6.9B aggregate arithmetic.

## A.3 Falsification, external validity, and employment (~3–4 pp)

- **¶1 Falsification suite (roll-up to Table E1-T4)** [`s6p1`] — *merged from old A.3
  ¶1+¶2+¶3+¶5.* **Report the table; in prose keep only the three judgements a table cannot
  make:** (a) parallel-trends evidence is genuinely mixed — slope −$69/yr (SE 89, p=0.44)
  does not reject, but accumulates to ≈−$1,450 over 21 years and the joint Wald **does**
  reject (F=6.9, p<0.001), with A.2 locating the drift in the farm component; (b) HonestDiD
  cannot run (no in-panel pre-period) — the 21-year BEA window plus the decomposition
  substitute and cover the future-shocks falsification (Row 26); (c) CO/NE drops lift
  analytic p to 0.075/0.057 — the few-cluster sensitivity WCB already prices in. Humidity,
  ACS demographics (Row 25 clean nulls), and p90 threshold grids get one sentence with a
  pointer to Appendix D — their statistics live only in narrative docs and are deliberately
  **not** transcribed into E1-T4.
- **¶2 Spatial robustness (advisor package)** [`s6p2`] — kept as its own paragraph because
  it carries a standing qualifier. Own-vs-neighbor split unidentified (r=0.94–0.97); the
  neighbor block is jointly significant (p≈0.006) and own+neighbor exceeds own-only →
  **headline is a lower bound on regional exposure**. Conley to 300 km: income worst case
  p=0.008; at 200 km Conley ≈ state clustering (0.0029 vs 0.0026).
- **¶3 External validity: pooled cohorts, and why 2012 differs** [`s6p3`] — *merged from
  old A.4 ¶1+¶2+¶3.* Pooled onset (e=0) **−$324 (SE 276): null**; long-run simple ATT
  **+$350 (SE 585)**. **NEVER cite the manual aggregation's −$1,050/p=0.002** (invalid
  independence SEs — audit A4; manual-CS is descriptive only, E1-T5 note). Fig **E1-F5**
  (csdid panels, descriptive-only subtitle). Then the hedged candidates in one sentence —
  severity, first-onset sharpness, agricultural-calendar timing, cross-cohort control
  composition — with no adjudication.
- **¶4 Employment: the fragile secondary (Row 2)** [`s6p4`] — ~2,000-job decline (analytic
  p=0.0001, ≈4% of mean county employment 48,068) clears WCB (p=0.003) and RI (p=0.037),
  LOO envelope [−2,156, −1,854] never flips; but attenuates ~58% under DRDID (−871, SE 433)
  and **reverses sign** pooled (+2,609, SE 2,245). Fragility is conditioning/generalization,
  not cluster count. Equal prominence; explicitly not a co-headline.
- **¶5 What this design does not establish** [`s6p5`] — *moved from old A.3 ¶6 to close the
  appendix.* Event-specific ITT for the treated geography (¶3 confirms); no mechanism
  identification inside the DiD; direct health-channel evidence is **§4 (Medicare)**; the
  durable income relationship is **§6**.

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
