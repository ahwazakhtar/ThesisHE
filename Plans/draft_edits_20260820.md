# Draft edits — consolidated

**Updated:** 2026-08-20 (rev. 2, after adversarial review) · **For:** the author.
**Sources:** `Plans/draft_review_20260819.md` (references, exhibits, flow) plus five
adversarial reviews run 2026-08-20 — Essay 1 numbers, Essays 2–3 numbers, claim discipline
against `master_evidence_table.md`, style/clarity, and exhibits/render.

Line numbers are as of 2026-08-20 15:40. Each item gives a unique find string.

---

## 0. Status of the first edit list

The pre-dedup number corrections issued this morning are **applied**, with one exception:

- **`essay3_draft.md:7`** (abstract) still reads "roughly **eight** times larger". The body,
  §4 and §10 now say ten. The ratio is 459/45.6 = 10.1. **Change "eight" to "ten".**

**Correction to that list:** it stated "Essay 2 — no stale numbers found." That was wrong.
Two pre-dedup figures are in Essay 2, each stated twice — see §1 below.

---

## 1. Numbers that are still wrong

### Essay 2 — pre-dedup values I missed

| Line | Find | Replace |
|---|---|---|
| 67, 79 | `−42,453` | `−41,573` |
| 67, 79 | `+435` | `+417` |

`cumulative_dose_marginal.csv`: population-weighted binned contrast −41,572.9 (SE 14,878.9,
p = 0.0052); unweighted quadratic ME difference +416.78 (SE 345.66, p = 0.228). The evidence
table labels −42,453 "pre-dedup" in the same cell.

### Essay 2 — wrong estimand attached to a number

| Line | Problem |
|---|---|
| 7, 17, 59, 89 | **"about 45 percent of a typical annual movement"** belongs to the local-projection *impulse* (0.01164 / 0.0259 = 0.449). The onset–exit **asymmetry** is 0.01874, i.e. **72 percent**. Stated four times. |
| 59, 89 (also 7, 17) | **"fading by the fourth year after exit"** — the symmetry grid stops at h = 3, where the asymmetry is still significant (+0.0146, p = 0.039). There is no h = 4 symmetry test. What fades at h = 4 is the LP impulse, a different estimand. |
| 79 | `2014 (24 counties)` → **59 counties** (`did_cs_att_gt.csv`; event-time aggregate confirms 171 + 59 = 230). |
| 57 | "**99 percent of it** survives premium adjustment" — the mediation file decomposes the lag-2 drought→debt *coefficient* (0.987), not the asymmetry. No premium-adjusted asymmetry exists. |
| 57 | "unchanged under no, lagged, and contemporaneous control sets" — the p-values hold, but the estimate moves 0.0187 → 0.0230 / 0.0252 / 0.0239, and the source flags two variants `materially_diff_vs_no_control = TRUE`. |
| 57 vs 7, 17 | Same asymmetry given as `p < 0.01` in §5 and `p < 0.001` in the abstract and §1. It is 0.00073; E2-T3 prints `<0.001`. |
| 53 | "**chronic** extreme drought is rare (2.3 percent of county-years)" — 2.3% is *any* extreme-drought county-year. Chronic (persisting) is 175/37,644 = **0.46%**. |
| 57, 89 | The `+0.019` asymmetry and the `−5,522` / `+4,460` contrasts are all **unweighted**; the table reports each under two weightings with different values. Say which. |

### Essay 1 — claims that misstate their own source

| Line | Problem |
|---|---|
| 108 (and 19) | "**between 92 and 99 percent across the remaining cells**" — the two named cells are right; the other seven span **0.171 to 1.139** (heat at one lag retains 17%). The source scopes 93–99% to the two *headline* cells only. |
| 71 | "**interacting drought with agricultural dependence yields a null**, so the morbidity channel requires no farm-income intermediary" — `ag_channel_coefs.csv` contains **no Medicare outcome**. Where the interaction exists (employment) it is significant at all three lags (−0.0061 p=0.026; +0.0126 p=0.0005; +0.0086 p=0.004). The claim as written has no estimate behind it. |
| 112 | "shows **no robust climate signal** and instead **tracks income**" — cold is **+$205, p = 0.014**; income is **p = 0.397**. Only the unemployment p = 0.06 holds. |
| 17 | "cold **and air-quality** shocks operate at longer lags" — air quality peaks contemporaneously (5.00 → 3.64 → 2.83). §4 line 69 says so. |
| 174 | "ACS controls … leave **94 to 104 percent** of each effect intact" — range is **0.576 to 1.044**; the source scopes 94–104% to *debt and hospital* outcomes and names the cold→income cell (0.58) as material attenuation. |
| 85 | drought→debt "does not survive the **addition of income and uninsurance controls**" — the committed verdict is "**STABLE** — controls are innocuous." The collapse is a **sample** restriction that happens before any control enters (0.00576 p=0.029 → 0.00091 p=0.757 on the identical sample). |
| 73 | "mean **25.2** percent, standard deviation **6.0** percentage points" — no committed output contains these. Recomputed: **24.94% / 6.08 pp**. (Energy burden 3.42 / 1.14 does check out.) |
| 71 | Anderson index "cold at two lags, **p = 0.002**" → **0.001**. (0.002 is the component ED coefficient's p.) |
| 71 | "the **heat and air-quality** ED responses survive at q < 0.05" — heat at t0 does **not** (q = 0.056). Only heat t1 and air quality t0 clear. |
| 53 | "anticonservative by up to **seven** orders of magnitude" → ≈ **ten** (2.8e-13 vs 0.0026). The source memo has the arithmetic error; the draft inherits it. |
| 19 vs 104 | Bound given as "**5 to 8 percent**" (§1) and "**6 to 7 percent**" (§5). Across the six primary cells δ\* runs 2.0–8.0% of the mean; the source's bottom line is "~4–8%" for heat/cold. |
| 104 vs 47 | "$366" (§5) vs "$374" (§3). Both correct but differently defined — $374 is the unweighted county-year mean, $366 the population-weighted mean over the rating-area estimation sample. Distinguish them in words. |

### Essay 3

| Line | Problem |
|---|---|
| 54 | "(−$55 at the 25th percentile, **statistically not significant**)" — it is **p = 0.030**, and E3-T2, cited in the same sentence, prints 0.030. |
| 56 | "**Both income and spending** interactions replicate at the state level" — every state income interaction is `ns` (p = 0.36, 0.94, 0.22, 0.13, 0.14), and cold runs the wrong way at high vulnerability. Only health spending replicates. |
| 33 | SAHIE described as combining the **Behavioral Risk Factor Surveillance System** and the ACS. SAHIE's inputs are ACS, IRS returns, SNAP, Medicaid/CHIP records and population estimates. BRFSS is not one. |
| 58 | composite index per-capita income `p = 0.007` → **0.006**. |
| 84 | "three to five times the cold burden" — true of the ratio of averages (4.06); year by year it spans 1.8× to 10.6×. |

---

## 2. Claim discipline — `master_evidence_table.md` violations

| Where | Problem | Governing text |
|---|---|---|
| **E1:7** | "drought lowers county incomes **at a one-year lag through both farm and non-farm channels**" — §6 reports the **contemporaneous** term (−$149), and Appendix A shows the farm component is 2011 commodity-price reversion, not drought damage. This is the last surviving sentence of the pre-restructure framing. | Row 1 (amended 2026-08-17) |
| **E2:7, 17, 57, 89** | Essay 2 **leads with debt-as-harm** in the abstract, the introduction's findings paragraph, §5 (its first results section) and the conclusion. Cold-employment compounding is the designated headline and comes second everywhere. | Row 24, verbatim: *"Do not lead any essay with debt-as-harm."* |
| **E2:57** | "The debt accrued during a drought **remains on a household's credit file**" — a same-household persistence claim from county aggregates. The out-migration caveat sits in §8, ~1,200 words later. | Row 16 requires it stated **explicitly** and co-located |
| **E2 (whole essay)** | Debt is **never** described as measurement-fragile. Grep returns nothing. | Row 16, Row 24, CLAUDE.md |
| **E2 (missing)** | No **"What identifies compounding?"** subsection. The honest content exists in §6 and §8 but never reaches the abstract, introduction or conclusion, and the required sentence — that this is "a pattern supported by particular estimators, not an estimator-invariant law" — appears nowhere. | Framing plan §7 |
| **E1:120** | The ~2,000-job employment decline is hedged only as "matching caution". | Row 2 requires **explicit prominence** to the 58% DRDID attenuation and the pooled sign reversal |
| **E1:7** | Cold→debt cited flat as 1.35 pp with no level, no association framing, no fragility note. **The draft's own Appendix B (L191)** says to cite it as **0.85–1.35 pp** wherever baseline robustness is at issue — a promise broken in the abstract, §1 and §5. | Row 4; self-inconsistency |
| **E1:69** | Air-quality result stated with no monitoring caveat at the point of claim; the 1,194-county limit is two sections upstream in §3. | Row 13 |
| **E1:33** | "the recorded response is smaller precisely where uninsurance is higher" stated **generally**; Row 24 restricts it to drought×uninsurance (q = 0.012). Essay 3 §7 states it correctly — the two essays disagree. | Row 24 |
| **E1:106** | "inconclusive with regards to other shocks such as heat, cold **and air pollution**" — no air-quality premium cell exists. | Row 8 |
| **Unregistered claims** | No evidence-table row exists for: the post-exit decay horizon (E2, ×4), the spillover lower-bound argument (E1 A.3), the seven-orders-of-magnitude clustering figure (E1:53), heat's +4,460 dose contrast (E2:75), or the burden-concentration shares (E3 §8). Each needs a row before the claims freeze, or removal. | — |

**Clean:** an exhaustive grep for every retired claim — "Midwest", −2,011, −721, the manual
−$1,050, the actuarial-repricing story — returns **zero hits** across all three drafts.

---

## 3. Prose — broken sentences and contradictions

### Unparseable or says the opposite of what is meant

| Where | Quote |
|---|---|
| E1:134 | "household budgets absorb unpriced costs strain after shocks" |
| E1:136 | "I explore whether the time-dynamics of these costs … and the distributional nature of these costs." — no predicate |
| E1:136 | "Medicare and BEA income accounts have access filters and costs selectively recorded" — contradicts §4's "administratively complete", on which the whole Medicare claim rests |
| E1:96 | "**Therefore** we see higher premiums in years and counties with heat shocks, and lower premiums in cold county-years" — asserts the coherent pass-through the paragraph just ruled out, and is backwards at the primary spec (heat −$10.40, cold +$12.57). **Delete the sentence.** |
| E1:106 | "I can only **reject a premium response** to a drought shock" — reads as rejecting the null; the test rejects a *large* response |
| E2:47 | "…the transition estimates **and an estimator and are built for staggered adoption**" |
| E2:57 | "remains on a household's credit file **after at least 2 periods after** the drought ends" |
| E3:7 | "places with higher social vulnerability **is where the real-economy cost of climate aggregate**" — the abstract's closing thesis |
| E3:54 | "the finding here is distributional that premium increases precisely where households are least able to absorb them" |
| E3:19 | "the medical debt data **is contrary** for understandable reasons" |
| E3:11 | "A heat wave of **the a** given magnitude" — opening sentence |
| E2:19 | "This essay **turns turns** the informal language" |
| E2:59 | "**IT is also** approximately 10 percent" |
| E1:7 | "exteme" |

### Self-contradictions and broken promises

| Where | Problem |
|---|---|
| E1:53 | "The choice matters … **It is also not decisive for the results**" in consecutive sentences |
| E1:89 vs 96 | The sign-instability argument is built partly on the county specification declared "confounded" seven lines earlier |
| E1:104 | "For these two hazards the exercise is **uninformative**" then "What the data **do pin down** … is an upper limit" — the same MDE relabelled as a finding |
| E1:108 | "**If premiums do not move when climate shocks hit**" — a universal null the essay denies for heat and cold four lines earlier |
| E1:130 | "**Three** future extensions" — two delivered; paragraph ends on a trailing space |
| E2:13 | "the **four** hazards of heat, cold, drought and air pollution" — air pollution never estimated; §9 covers three |
| E3:60 | §5 heading promises "**and non-farm labor exposure**" — never reported in §5 or anywhere |
| E3:64 vs §4 | "the Social Vulnerability Index interaction is **no longer significant**" guts §4's headline; §4, §9 and §10 never mention it |
| E3:76 | "**The same outcome flips sign** across geographic scales" — the two cells compared are *different hazards* |
| E3:54 vs E1:96 | E3 says drought pushes premiums up in vulnerable counties; E1 says drought is "null at every level". Unreconciled across the volume. |
| E1:67 | Ends with "**(Aguilar-Gomez, Graff Zivin, and Neidell, 2025)**" — the *style exemplar's* own citation, leaked in as an orphan parenthetical after a terminal period. It reaches the PDF. **Delete.** |

### Structure and register

- **E1:55 / roadmap:** §4 "Medicare morbidity and utilization" spends its last third on county
  employment gradients the roadmap assigns to §6. Move, or split §4 and amend the roadmap.
- **E1:98–106:** five paragraphs of equivalence-bound tutorial in a register found nowhere else,
  including a banned self-appraisal ("This is a real finding about how the market prices risk").
- **E2:7 vs 17:** the abstract and §1 ¶4 are **byte-identical**. §10 repeats it a third time.
- **E3:58, E3:70:** orphan results — the composite index's sign flip (−$435 vs +$1,270) and
  drought *lowering* uncompensated care by $3.88M, both stated and abandoned. The buffering
  explanation for the latter already exists in `Text/drafts/mechanisms_section.md`.
- **E1:22 etc.:** person drifts among I / we / one within paragraphs; Essays 2–3 use "I".
- **Self-containment:** E2:51 and E3:25 defer methods to "the first essay". In the standalone
  PDFs that dangles. Each needs a short self-contained data/design paragraph.
- **Undefined in every essay:** **ACA, BEA, CMS, AQI, ERS, HIX**; **ACS** undefined in Essay 3.
  (The standalone PDFs now carry the glossary — see §4 — but body prose should still expand
  on first use.)
- **The twelve unedited harness paragraphs** (E1 Appendices A–B) read as *better* than the
  author-written main text, not worse. The seam is real but runs the other way; four passages
  are stylistically not-your-voice (L180 rhetorical question, L194 "machinery" / "information
  rather than fragility", L174 and L191 60–90-word periodic sentences, L177 "amplify rather
  than confound").

---

## 4. Fixed at source — nothing for you to do

**Render defects** (`render_rug.js`, rebuilt and verified: 0 float overflows, 0 headheight
warnings, 0 undefined references or citations across all four documents):

- **Tables were being silently truncated.** E1-T0b overflowed the page by **1012pt** — two
  whole panels, five outcome rows and the table note never reached the PDF. E1-T0a lost its
  last row and its entire note; E1-T1 lost the sentence guarding the median-vs-mean trap.
  The four oversized tables now emit as `longtable` and break across pages.
- **Appendix A and B mis-pointed.** They reused the hyperref anchors of §1.1 and §1.2, so
  clicking them in the TOC jumped to pages 2 and 4. Fixed via `\theHsection`.
- **Landscape rotation was counter-productive** — inside `pdflscape`, `\textheight` still
  resolves to the portrait text width, so both rotated figures rendered at 432pt against a
  portrait figure's 446pt. Both are now portrait.
- **The standalone papers had no glossary.** Added.
- **Running head was clipped on every page** of the volume (54 warnings). Fixed.

**Exhibit defects:**

- A **third copy** of the `$<$0.001` escaping bug lived in `create_falsification_table.R`,
  so E1-T4 printed a literal `$<$0.001`. Fixed.
- E1-T8's note printed `\{}$1,300` — an over-escape I introduced yesterday. Fixed.

**Upstream narrative files** corrected this morning so the drafts cannot be re-contaminated
on the next harness export: `mechanism_verdict.md`, `exposure_index/synthesis.md`,
`mechanisms_section.md`, four evidence-table rows, and a correction banner on
`reproduction_certificate.md`.

---

## 5. Still open — exhibit issues needing a decision

These are real but involve a judgement I should not make for you:

1. **E1-T7's state row uses the county debt baseline.** All three credit-bureau rows carry
   18.8%, computed from the county panel; the state row's "7.19% of baseline" is therefore
   against the wrong ledger's mean, and the note claims otherwise.
2. **E3-T4 and E3-F4 disagree on units by 100×** — table header says "% of net patient
   revenue", the figure says "share of". Settling it needs the NASHP source column.
3. **E3-T5's note gives one predicted direction for three moderators with two orientations.**
   Hospital access is coded `higher_is_worse = FALSE`, so its predicted sign is *positive*;
   a reader scoring those three rows by the note gets them backwards.
4. **11 registered exhibits have no home in any essay** — E1-T3, E1-T5, E1-T9, E1-F2, E1-F3,
   E2-T2, E2-T4, E2-T5, E2-F2, E2-F3, E2-F5. Essay 2 loses half its registered exhibits,
   including E2-T4 (the −5,522 contrast) and E2-T5 (cross-estimator), which are its headline
   results. Conversely **E1-F0 is placed and cited but has no registry row.**
5. **Colour-only encoding** in E3-F6 (four series), E2-F4 (two hazards), E1-F4 and E3-F2
   (significance by red/grey). All fail in greyscale; E3-F6's salmon/olive pair is the
   canonical colour-blind failure.
6. **"Cumulative cold-years" is never defined** — not in E3-T2, E3-F2, the glossary, or
   Essay 3's prose.

---

## After editing

```
node Text/final_writing/render_rug.js
cd Text/final_writing/rendered_rug
for f in essay1 essay2 essay3 thesis; do
  pdflatex -interaction=nonstopmode $f && bibtex $f && \
  pdflatex -interaction=nonstopmode $f && pdflatex -interaction=nonstopmode $f
done
```

The harnesses and content packs still carry the pre-dedup figures; re-exporting from a
harness reintroduces them. Treat the drafts as authoritative from here.
