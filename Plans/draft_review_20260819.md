# Draft review — references, exhibits, flow

**Date:** 2026-08-19 · **Scope:** `Text/final_writing/essay{1,2,3}_draft.md`, every registered
exhibit, and the render path. **Companion:** `Plans/exhibit_registry.md`,
`Plans/master_evidence_table.md`.

Items marked **[fixed]** were applied this session. Items marked **[author]** are prose the
author wrote and are reported, not edited (per `Text/final_writing/WORKFLOW.md`).

---

## 1. Exhibit references

### 1.1 Essays 2 and 3 rendered with zero exhibits **[fixed]**

The renderer keys on registry tokens (`Table E2-T1`). Both drafts cited exhibits as bare
`Table 1` / `Figure 4`, which matched nothing, so `render_thesis.js` reported:

```
Essay 1: 13 exhibits placed
Essay 2: 0 exhibits placed
Essay 3: 0 exhibits placed
```

Every reference was mapped to its registry token. The build now reports 14 / 4 / 9 — all 27
registered exhibits placed, none stranded, none uncited.

### 1.2 Essay 1 reference errors **[fixed]**

| Location | Was | Now |
|---|---|---|
| §3, outcomes ¶ | "Table E1-T1 reports definitions, populations, and observation windows" | `E1-T0b` — E1-T1 is the summary-statistics table, cited correctly two ¶ later |
| §2, §5 | "(Appendix F)" ×2 | removed; no Appendix F exists and the next sentence already carries the point |
| §3 | "documented in Appendix J" | `Appendix B` |
| A.3 | "reported in full in Appendix D" | "reported in full in the robustness suite" |
| §6 | "(Appendix A.4)" | `A.3` — A.4 was absorbed into A.3 |
| A.2 | baseline-sensitivity grid described but never cited | now cites `Table E1-T8` |

### 1.3 Exhibits built but never cited **[fixed]**

- **E1-T8** (baseline sensitivity of the 2×2). Appendix A.2 asserts "widening the baseline
  from 2011 alone to 2009–2011 moves it from −$1,311 to −$285" — the grid behind that
  existed only as a CSV. Now typeset (`Code/create_essay1_ledger_exhibits.R`) and cited.
- **E3-T5** (debt visibility gradients). §7 discusses the gradients and cited nothing.

### 1.4 In-text tokens now become real cross-references **[fixed]**

The drafts keep the stable tokens; `render_rug.js` rewrites each into `\ref{}`, so the PDF
prints "Table 7" / "Figure 2.1" and the reader can click through. Zero undefined references
across all four documents.

---

## 2. Exhibit clarity

### 2.1 Escaping defects **[fixed]**

- `sig_p()` emitted `$<$0.001`; `tex_escape()` then escaped the dollars, so **seven tables**
  printed a literal `$<$0.001`. Root-caused in `Code/create_data_source_tables.R`: `sig_p()`
  now emits `<0.001` and `tex_escape()` maps `<`/`>` to `\textless{}`/`\textgreater{}`.
  A second copy of the same bug lived in `create_essay1_ledger_exhibits.R`'s local `fmt_p()`;
  it now delegates to `sig_p()`.
- The concentration-table note printed `10\textbackslash{}\%` (an over-escaped `\%` in the
  R source). Note rewritten.
- Negative dollars printed as `$-1,311`. New `usd()` helper puts the sign outside the
  currency symbol: `-$1,311`.

### 2.2 Pipeline names leaking into print **[fixed]**

| Exhibit | Was | Now |
|---|---|---|
| E3-T2 | `Drought_Lag2`, `Heat_CDD`, `Cold_HDD`, `Cold_CumYears` in the hazard column | "Extreme drought (2-year lag)", "Extreme heat", "Extreme cold", "Cumulative cold-years"; a `stopifnot` now fails the build if an unmapped name appears |
| E3-T5 | `HospAccess`, `Rurality`, `Uninsured` | "Hospital access", "Rurality", "Uninsured share" |
| E1-T1 | "Extreme Heat (High CDD indicator)", "PDSI annual mean", "Household Income from Debt Data" | "Extreme heat (cooling degree days above the national 80th percentile)", "Palmer Drought Severity Index, annual mean", "Household income, credit-bureau file" |
| E1-F4 | panel strips read `CDD > baseline p80`, `PDSI ≤ −4`; subtitle `county + year FE, state-clustered` | full-sentence hazard definitions; subtitle in plain language |
| E1-F5 | caption ended "(Code/create_essay1_ledger_exhibits.R)" | script path removed; provenance belongs in the registry |

### 2.3 E3-T5 printed six pairs of duplicate rows **[fixed]**

Each (hazard, moderator) cell is estimated population-weighted **and** unweighted; the table
dropped the `weighting` column, so twelve rows appeared as six visually identical pairs
carrying different numbers. The column is restored, the lag is now stated, a `q` column was
added (the essay cites `q = 0.012`), and a `stopifnot` guards against the defect returning.

### 2.4 Two figures were raw diagnostics **[fixed — new script]**

`E3-F2` and `E3-F4` shipped the plots the estimation scripts wrote for the analyst:
axes labelled `Civilian_Employed`, `Hosp_UncompCare_PctNPR`, `High_CDD`,
`Is_Extreme_Drought`, and a safety-net axis that was a bare `0` / `1`.

Rebuilt as `Code/create_essay3_figures.R` → `Analysis/plots/essay3/`:

- **E3-F2** — dumbbell across all five outcomes; the arrow runs from the marginal effect at
  the 25th vulnerability percentile to the 75th, with the interaction p per row. Colour marks
  whether the two ends are distinguishable, deliberately **not** which direction is "worse" —
  a fall in employment and a rise in medical debt are both bad, so one worse/better scale
  would mislabel half the panels.
- **E3-F4** — uncompensated care and operating margin, safety-net vs other hospitals, 95%
  intervals, one interaction p per hazard.

Both read the same committed CSVs as E3-T2 and E3-T4, so a figure and its table cannot
disagree. Registry rows updated.

### 2.5 Known gap, not fixed

`E1-T1`'s upstream domain is labelled "Climate and Air Quality" but **no air-quality series
is summarised** — air quality is described only in E1-T0a/T0b. The print layer now calls the
panel "Climate exposure", which is honest, but adding an AQI row means touching
`run_descriptive_stats.R`, which is inside the frozen reproduction package. Flagged rather
than done.

---

## 3. Numbers that disagree with their own exhibit **[author]**

These are prose figures that no longer match the committed coefficient files the tables are
built from. The tables are generated; the prose drifted.

### 3.0 Root cause: stale pre-dedup vintages, carried by hand-authored narrative files

**Established 2026-08-20 by re-estimation, not inference.** Every discrepancy in 3.1-3.3 is
the *exact* output of the same unchanged script run against the **pre-dedup** county master.
I re-ran both specifications against `Data/_archive/county_level_master_prededup_20260713.csv`
and against the current master:

```
PRE-DEDUP   heat spend L1 = 176.572 p=0.00142   |  POST-DEDUP  175.577 p=0.00151
PRE-DEDUP   heat ED    L1 =   9.491 p=0.00024   |  POST-DEDUP    9.440 p=0.00025
PRE-DEDUP   cold spend L2 =  85.476 p=0.00868   |  POST-DEDUP   86.788 p=0.00824
PRE-DEDUP   AQI  ED    L0 =   4.822 p=0.00028   |  POST-DEDUP    5.001 p=0.00022
PRE-DEDUP   AQI  ED    L1 =   3.335             |  POST-DEDUP    3.638

PRE-DEDUP   heat->employment   me 878.24 -> -184.27  int p=0.00096
PRE-DEDUP   cold->income       me -55.66 -> -471.70  int p=0.05638
PRE-DEDUP   drought L2->prem   me -54.14 ->   15.71  int p=0.00122
POST-DEDUP  heat->employment   me 885.79 -> -168.97  int p=0.00103
POST-DEDUP  cold->income       me -45.57 -> -459.33  int p=0.06103
POST-DEDUP  drought L2->prem   me -55.09 ->   14.12  int p=0.00121
```

The pre-dedup column reproduces the prose to the digit, p-values included — including the
cold interaction's original `p = 0.056`, which the evidence table later corrected to 0.061
while leaving the marginal effects alone. **The committed CSVs govern in every case**: the
pre-dedup panel double-counted 568 county-years, all in 2014-2026, which is exactly the
Medicare window. No sign, verdict, or qualitative claim changes.

**Why it survived the refresh.** The 2026-07-13 dedup correctly regenerated every coefficient
CSV. But the writing chain does not read those CSVs. It reads hand-authored narrative
markdown, which has no generator and was not regenerated:

| Stale source | Feeds | Refreshed on 2026-07-13? |
|---|---|---|
| `Analysis/mechanism/mechanism_verdict.md:39-42` | evidence-table Rows 10, 14 | **No** — commit `2e22c11` touched the file but fixed only the cold->employment bullet |
| `Analysis/exposure_index/synthesis.md:11-15` | evidence-table Row 20 | **No** — mtime still 2026-07-06; sibling narratives were refreshed, this one was skipped |
| `Text/drafts/mechanisms_section.md:39` | evidence-table Rows 11b/12 | **No** — the horse-race gradient's only narrative home |

From there the path is faithful transcription the whole way:
narrative `.md` -> `Plans/master_evidence_table.md` -> `essayN_outline.md` ->
`essayN_content.md` -> `essayN_harness.html` -> `essayN_draft.md`. **Nothing was invented at
the harness.** The harness copied its source correctly; the source was stale.

**The structural defect: regenerating analysis outputs does not regenerate the narrative
files the writing pipeline actually consumes.** Until the writing layer reads generated
artifacts, or the narrative files are rebuilt as part of every refresh, this recurs.

**Two gates that should have caught it and did not.**

- `Analysis/reproduction_certificate.md:122` compared `$177` against `$175.6` and marked it
  **"✓ (rounding)"**. A 1.4-unit gap does not round, and 9.5 vs 9.44 rounds the wrong way.
- `:126` (Row 20) printed both the stale and current marginal effects side by side, then the
  footnote at `:136-138` described them as "unchanged". Row 14 (the air-quality cells, the
  largest errors) was never traced at all.

**A knock-on that is not a find-and-replace.** The `$9.33-$14.75` per-member-per-month full
pass-through benchmark in Essay 1 §5 is *derived* from the $112-$177 Medicare range, and the
headline "50 to 79 percent of full pass-through" bound is derived from that. Both must be
recomputed from the corrected coefficients, not edited in place.

**Correction must start upstream.** Fixing only the drafts leaves the three narrative files,
the evidence table, `Text/drafts/`, five correspondence memos, the outlines, the content packs
and the harnesses carrying the stale figures — and the next export reintroduces them.

### 3.1 Essay 1 §4 vs Table E1-T6 (`medicare_channel_coefs.csv`, spec `overall`)

| Prose | Committed |
|---|---|
| heat, spending, 1-year lag: **$177, p = 0.001** | $175.58 → **$176, p = 0.002** |
| heat, ED visits, 1-year lag: **9.5** | **9.44** |
| cold, spending, 2-year lag: **$85** | **$86.8** |
| air quality, ED, same year: **4.8, p = 0.0003** | **5.00, p = 0.0002** |
| air quality, ED, 1-year lag: **3.3** | **3.64** |
| air quality, ED, 2-year lag: 2.8 | 2.83 ✓ |

The **$177** figure also appears in the abstract and §1.

### 3.2 Essay 3 §4 vs Table E3-T2 (`exposure_interaction_coefs.csv`)

| Prose | Committed |
|---|---|
| heat employment: **+878 → −184** | **+886 → −169** |
| cold income: **−$56 → −$472** | **−$45.6 → −$459** |
| drought (2-yr lag) premium: **−$54 → +$16** | **−$55.1 → +$14.1** |

### 3.3 Essay 3 §5 vs Table E3-T3

Prose: log-employment energy-burden gradient **−0.0068, p = 0.019**. Table (joint spec):
**−0.00647, p = 0.020**.

### 3.4 Essay 3 §7 — RETRACTED: the claim was correct **[reverted 2026-08-20]**

This section previously reported the heat-by-uninsurance gradient as unsupported. **That was
wrong.** The estimate is real and lives in a different analysis family:

`Analysis/mechanism/sahie_bridge_coefs.csv` — `High_CDD_Lag1:Uninsured_z` = **−0.00597,
p = 0.0118**, n = 39,167. An exact match for "−0.006 for heat at a one-year lag (p = 0.01)".

The drought half was correct as written too. The same file gives all three drought lags at
≈ −0.005 with p = 0.021, 0.0002 and 0.018 — so "about −0.005 per standard deviation for
drought (p < 0.03)" is an accurate summary of that block.

**Why the false positive.** §7's third paragraph was checked against
`Analysis/latent_hardship/`, because that is where Table E3-T5 comes from. But the paragraph
predates latent-hardship by six days and descends from the earlier SAHIE bridge. The two are
different by design: `Code/run_latent_hardship.R:25` freezes its scope to "ONLY two — cold
(High_HDD) at lag 1; extreme drought at lag 2", population-weighted and BKY-corrected, whereas
the bridge is unweighted and covers all three hazards at all three lags. Heat was excluded
from the pre-registered grid deliberately; it was never dropped.

The chain is clean end to end — bridge output → `mechanisms_revision` plan → evidence-table
Row 24, whose permitted language reads *"SAHIE: shock×uninsured on debt NEGATIVE (drought
~−0.005/SD p<0.03; heat −0.006 L1 p=0.01)"* → harness → draft.

The sentence has been restored, and now names both sources: the bridge estimates are labelled
uncorrected, and E3-T5 is cited for the pre-registered subset where only drought×uninsurance
clears q < 0.10. The heat cell is 1 of 18 uncorrected interactions in the bridge file and must
not be presented as multiplicity-robust.

---

## 4. Flow **[author]**

### 4.1 Essay 1

1. **The abstract contradicts the essay's own correction.** It says drought "lowers county
   incomes at a one-year lag through both farm and non-farm channels." §6 and Appendix A
   establish that the farm component is commodity-price reversion off the 2011 peak, *not*
   drought damage — that decomposition is claimed as a contribution in §1. The abstract still
   carries the pre-restructure framing.
2. **§4 does two jobs.** It is titled "Medicare morbidity and utilization", but its last two
   paragraphs are county employment × exposed-industry and × energy-burden gradients — a
   different population, a different panel, a different outcome. §1's section map does not
   mention them at all. They read naturally in §6 (household economic capacity).
3. **§5 contradicts itself in consecutive sentences.** After establishing that sign
   instability across geographies "indicates no coherent local pass-through", the paragraph
   closes: "Therefore we see higher premiums in years and counties with heat shocks, and lower
   premiums in cold county-years" — stating the unstable coefficients as a finding.
4. **§5's equivalence-bound passage runs five paragraphs in a tutorial register** ("Finding no
   effect can mean two very different things…") that is markedly different from the rest of
   the essay. Clear, but long and off-register for NBER style.
5. **§7 promises three extensions and lists two** (working-age all-payer claims; patient-flow
   hospital exposure). The paragraph also ends mid-thought with a trailing space.
6. **§8:** "household budgets absorb unpriced costs strain after shocks" — garbled.
7. Abstract typo: "exteme".
8. "(p = <0.01)" — malformed, in §1 and §6.
9. The abstract gives the cold→debt response as a point estimate of 1.35 pp; Appendix B
   concludes it should be cited as **0.85–1.35 pp** wherever baseline robustness is at issue.

### 4.2 Essay 2

1. **§1 ¶4 is a verbatim copy of the abstract** — same five sentences. One of the two should
   be rewritten.
2. §1: "This essay turns turns the informal language…" — doubled word.
3. §3: "These provide the long-run complement to the transition estimates and an estimator and
   are built for staggered adoption." — garbled.
4. §5: "IT is also approximately 10 percent…" — capitalisation.
5. §5: "about 45 percent of a typical annual movement (mean absolute deviation of year-to-year
   changes)" — the parenthetical repeats the clause that precedes it.
6. §5 ends on a one-line orphan paragraph ("Table E2-T3 reports symmetry tests for the full
   grid of hazards and outcomes.") that would sit better with the paragraph above it.
7. §2: "a shock whose marginal harm grows with recurrence is a different policy object from
   one whose costs arrives once" — agreement.
8. Abstract says the drought-debt asymmetry is `p < 0.001`; §5 says `p < 0.01` for the same
   estimate. Table E2-T3 says `<0.001`.

### 4.3 Essay 3

1. Abstract closes: "places with higher social vulnerability is where the real-economy cost of
   climate aggregate" — garbled, and it is the sentence carrying the paper's thesis.
2. §1: "A heat wave of the a given magnitude" — typo.
3. §4: "the finding here is distributional that premium increases precisely where households
   are least able to absorb them" — garbled.
4. **§4's closing paragraph is an orphan.** The composite heat-vulnerability index result is
   stated with a sign flip between median household income (−$435) and per-capita income
   (+$1,270) and no interpretation. The registry marks the composite as exploratory; either
   say so in the text or drop it.
5. **§6 states a result that cuts against the section's argument without reconciling it.**
   "the cumulative effect on uncompensated care is −$3.88 million per hospital (p < 0.001)" —
   drought *lowers* uncompensated care, in a section arguing vulnerable providers absorb more.
   `Text/drafts/mechanisms_section.md` already has the buffering explanation (crop insurance
   and USDA disaster payments severing the farm-income→uninsurance→uncompensated-care chain,
   with a first stage showing indemnities spike on exactly that shock). It has not been
   carried into the essay.
6. §7 opens "Credit-bureau medical debt is the one ledger that contradicts the amplification
   pattern", then reports that at the state level cold's debt response *amplifies* with
   vulnerability. Both facts are the point — the sign flips across scales — but as written the
   second reads as a contradiction of the first.
7. §9: "Therefore I frame the vulnerability interactions as heterogeneity and not causal
   moderation" — "therefore" does not follow from the sentence before it.

### 4.4 Cross-essay

Essays 2 and 3 defer their data and methods to "the first essay" and cite "the first essay's
Appendix B". That reads correctly in the combined volume. In the **standalone papers** it is a
dangling cross-document reference — each needs a short self-contained data paragraph before
circulating separately.

---

## 5. Render path

`Text/final_writing/render_rug.js` replaces `render_thesis.js`. See
`Text/final_writing/WORKFLOW.md` for the build commands and the two conventions the drafts
must follow. Outputs land in `rendered_rug/`: `essay1.pdf` (34 pp), `essay2.pdf` (10 pp),
`essay3.pdf` (17 pp), `thesis.pdf` (64 pp).

Also done:

- **Citations are now generated.** Plain-text citations map to `\citep`/`\citet` against
  `references.bib`; the reference list is produced by bibtex/apalike. 0 undefined citations.
- **`Audi et al. (2025)` was cited in Essay 3 §6 but appeared in neither `references.bib` nor
  `references.tex`.** Added from the resolved entry in `TK_resolutions.md`.
- **The de Chaisemartin year is reconciled.** The draft cited 2024 (working-paper vintage);
  the published record is 2026. natbib now takes the year from the bib, and the manual flag in
  `references.tex` was removed.
- **`setspace` and `placeins` are not in this TinyTeX install.** The generated preamble falls
  back so the documents compile; for exact template fidelity run
  `tlmgr update --self && tlmgr install setspace placeins`.
- **The RUG crest is deliberately not reproduced.** `titlePage()` carries a commented
  `\includegraphics` line for an institutional logo.

**12 paragraphs in Essay 1 still carry harness pre-fill** (`<!-- UNEDITED SUGGESTION -->`),
all in Appendix A and B. The renderer reports the count on every build.
