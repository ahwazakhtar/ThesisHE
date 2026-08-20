# Outstanding — pick up here

**Left off:** 2026-08-20, end of day · **Read the drafts, not the proof sheet:**
`Text/final_writing/essay{1,2,3}_draft.md` are current.

---

## Where things stand

**70 edits applied to the drafts** — Essay 1 (32), Essay 2 (17), Essay 3 (21). Every one was
asserted to match its target exactly once, so nothing was applied blind. Backups:
`essay{1,2,3}_draft.md.bak_pre_edits_20260820`.

**PDFs rebuilt and clean:** 38 / 13 / 18 / 67 pages, zero float overflows, zero undefined
references or citations, zero overfull boxes.

```
node Text/final_writing/render_rug.js
cd Text/final_writing/rendered_rug
for f in essay1 essay2 essay3 thesis; do
  pdflatex -interaction=nonstopmode $f && bibtex $f && \
  pdflatex -interaction=nonstopmode $f && pdflatex -interaction=nonstopmode $f
done
```

Everything below is what did **not** get applied, because it needs a structural decision or a
sentence in your voice rather than a find-and-replace.

---

## 1. Essay 2 — three block replacements (the biggest item)

Evidence-table Row 24 says verbatim *"Do not lead any essay with debt-as-harm."* Essay 2 leads
with the drought debt scar in the abstract, §1, and the conclusion. The §5 opening is already
fixed; these three are not. Text is drafted and ready to place.

### 1a. Abstract (L7) — replace from *"The dynamics are shock-specific"* to the end

> The dynamics are hazard-specific. Cold compounds: counties at ten or more cumulative
> cold-years have employment roughly 5,500 lower than counties with one to three, and the gap
> reaches roughly 5,000 jobs a decade after onset in the event study. Heat saturates into a
> level difference that does not grow with further exposure. Drought is episodic, and the mark
> it leaves falls on a measurement-fragile ledger: the two-year onset–exit asymmetry in the
> credit-bureau medical-debt share is +0.019 (p < 0.001), about 72 percent of a typical annual
> movement, though that series records hardship only after insurance, billing, and credit-file
> filters, and part of the persistence is out-migration rather than the same households
> carrying debt forward. The horizon over which climate raises costs is itself hazard-specific,
> so single-year exposure measures understate the burden of recurring cold.

### 1b. §1 ¶4 (L17) — replace the whole paragraph

Currently **byte-identical** to the abstract. This version is a walkthrough the abstract cannot
carry, so it fixes the duplication as well as the ordering.

> The dynamics are hazard-specific, and the essay reports them in that order. Section 5 tests
> reversibility: for heat and cold employment the onset and exit coefficients offset one
> another, while for drought and the recorded debt share they do not. Section 6 turns to
> accumulation, where counties at ten or more cumulative cold-years have employment roughly
> 5,500 lower than counties at one to three; Section 7 corroborates that with a staggered event
> study putting the gap near 5,000 jobs a decade after onset, and Section 8 qualifies it by
> showing the estimate is sensitive to how counties are weighted and to which cohorts survive
> to event-time ten. Heat, by contrast, saturates — its cumulative-dose profile is flat.
> Drought leaves its mark in the debt ledger rather than in employment, and Section 8 shows
> that mark is partly compositional.

### 1c. §10 (L87) — replace the three verdicts

> The answers are hazard-specific. Cold employment compounds — a binned cumulative-dose gap of
> roughly 5,500 jobs and an event-study gap of roughly 5,000 a decade after onset — though the
> smooth dose term is flat and the levels contrast is weighting-sensitive, so this is a pattern
> that particular estimators support rather than an estimator-invariant law. Heat saturates into
> a level difference. Drought is episodic, and its mark is a recorded-debt asymmetry of +0.019,
> about 72 percent of a typical annual movement, partly compositional and visible only in a
> ledger that filters hardship before recording it.

**Structural alternative:** swapping §5 and §6 so cumulative dose leads the results is cleaner
against Row 24, but it cascades through the roadmap and every cross-reference. The rewrites
above avoid that.

---

## 2. Essay 2 — the missing honesty box

The framing plan (§7) mandates a *"What identifies compounding?"* subsection. It does not exist.
**Insert at the end of §7, before §8 (§8 begins at L75).**

> **What identifies compounding?**
>
> Three estimators speak to cold compounding, and they do not fully agree. The binned
> cumulative-dose contrast puts employment 5,522 lower at ten or more cold-years than at one to
> three (SE 1,196, p < 0.001), and the staggered event study puts the gap at 4,982 a decade
> after onset (p = 0.003), rising monotonically from roughly 150 in the onset year through
> 2,600 at five years. The smooth quadratic dose term does not agree: the implied difference
> between the tenth and the first cold-year is +417 (SE 346, p = 0.23) — flat, and signed the
> other way. The levels outcome is also not weighting-invariant, since the same binned contrast
> is −41,573 when counties are weighted by population, which reflects the weight of large
> counties rather than a larger per-county effect. And the event-time-ten estimate rests on the
> 2013 cohort alone, because the 2014 cohort has no tenth post-onset year inside the panel.
> Compounding is therefore a pattern supported by particular estimators, not an
> estimator-invariant law. Wherever the roughly 5,500-job figure appears in this essay it is the
> unweighted binned contrast, and it carries that qualification.

§8's *"two further reasons"* passage was already trimmed to point at Section 7, so it expects
this box to exist.

---

## 3. Essay 1 §4 — the section does two jobs

§4 is titled *"Medicare morbidity and utilization"*, but **L73–L75** report county **employment**
interactions — different population, different panel, different outcome. §1's roadmap assigns §4
to the Medicare evidence and employment to §6, so it never announces this material.

Two options:
- **Move L73–L75 into §6** (*"Household economic capacity: income and employment"*), where the
  roadmap already places employment. Cleanest.
- **Or split §4** into 4.1 Medicare morbidity and 4.2 Labor-market exposure, and amend the §1
  roadmap to announce both.

---

## 4. Essay 1 §5 — register, and one sentence still self-cancelling

**L98–L106** is five paragraphs of equivalence-bound tutorial in a voice found nowhere else in
the volume — short declaratives, second-person framing, *"More importantly"*, and an explicit
self-appraisal (*"This is a real finding about how the market prices risk"*) that the style guide
bans outright.

Suggested shape: one methods paragraph (what an equivalence bound is and why it is needed), one
results paragraph (drought bounded, heat and cold not), tutorial to a footnote, self-appraisal
deleted.

**Inside that block, L104 is still broken** — the card you left empty:

> For these two hazards the exercise is **uninformative**. … What the data **do pin down** for
> heat and cold is an upper limit…

The "upper limit" is the same minimum detectable effect restated as a percentage of the mean, so
the paragraph cancels itself. One direction: *"For these two hazards the exercise is
uninformative: the equivalence bound exceeds the benchmark it is meant to test against, so it
rules out neither full pass-through nor zero."* Then stop.

---

## 5. Essay 1 — person drift

I / we / one still alternate, sometimes within a paragraph. Essays 2 and 3 use "I" consistently,
so the volume is inconsistent too. Surviving instances include L118 *"we find"*, L126 *"we can
take out"*, L130 *"our understanding"*, L23 *"one consults"*. A sweep, not an edit.

---

## 6. Exhibits — six items, none are draft edits

| Exhibit | Issue |
|---|---|
| **E1-T7** | **A real error.** The state credit-bureau row is scaled against the **county** panel's baseline (18.8%), because `create_essay1_ledger_exhibits.R:236` computes `mean(panel$Medical_Debt_Share)` from the county panel and applies it to every row. Its "7.19% of baseline" is against the wrong ledger — and the table note claims otherwise. |
| **E3-T4 vs E3-F4** | Table header says *"% of net patient revenue"*, its own figure says *"share of"* — same CSV, same 0.0294, a hundredfold disagreement. Magnitudes imply a decimal share, so the header is the likely error. Needs the NASHP workbook to settle. |
| **E3-T5** | The note gives one predicted direction for three moderators with two orientations. `run_latent_hardship.R` codes `HospAccess` as `higher_is_worse = FALSE` — more hospitals means more visibility — so for those three rows the predicted sign is **positive**, not negative. |
| **Registry vs renderer** | **11 registered exhibits have no home:** E1-T3, E1-T5, E1-T9, E1-F2, E1-F3, E2-T2, E2-T4, E2-T5, E2-F2, E2-F3, E2-F5. Essay 2 loses half its registered exhibits, including **E2-T4** (the −5,522 contrast) and **E2-T5** (cross-estimator) — its headline results. Conversely **E1-F0 is placed and cited but has no registry row.** |
| **E3-F6, E2-F4, E1-F4, E3-F2** | Series and significance encoded by colour alone; all four collapse in greyscale, and E3-F6's salmon-against-olive is the canonical colour-blind failure. |
| **E3-T2, E3-F2** | *"Cumulative cold-years"* is never defined — not in the table note, the figure, the glossary, or Essay 3's prose. |

---

## 7. Housekeeping in the drafts

**Ten `[CITE: …]` flags.** These now render as real citations in the PDF (the renderer maps them
to `references.bib`), so they are harmless typeset but conspicuous in the markdown.

- Essay 1: L53 Conley · L71 Benjamini-Krieger-Yekutieli · L110 Kautter et al. · L154
  Cameron-Gelbach-Miller / MacKinnon-Webb / Young · L169 Deschênes-Greenstone / Deryugina ·
  L174 Rambachan-Roth
- Essay 2: L23 Dell-Jones-Olken · L29 Jordà · L77 Mullins-Bharadwaj
- Essay 3: L27 Flanagan et al.

**Twelve `<!-- UNEDITED SUGGESTION -->` paragraphs**, all in Essay 1's appendices — L142, 153,
156, 165, 168, 173, 176, 179, 182, 185, 190, 193. Worth knowing: the style review found these
read *better* than the author-written main text, not worse. Four passages are stylistically
not-your-voice: L179 opens on a rhetorical question, L193 uses "machinery" and an antithetical
epigram, L173 and L190 run 60–90-word periodic sentences.

**Also unresolved from the reviews** (each has a card in the proof sheet): five claims with no
evidence-table row — the spillover lower-bound argument, the clustering magnitude, heat's +4,460
dose contrast, the post-exit decay horizon, and the burden-concentration shares. Each needs a row
before the claims freeze, or removal.

---

## Reference

- **Proof sheet** (86 cards, editable, side-by-side): `Text/final_writing/draft_edits_review.html`
  — or https://claude.ai/code/artifact/cfdacc53-a43a-4c20-875a-993f5d7c6466
- **What was found and why:** `Plans/draft_review_20260819.md` (§3.0 has the pre-dedup root cause)
- **The edit list:** `Plans/draft_edits_20260820.md`
- **Your reviewed decisions:** `Text/final_writing/draft_edits_reviewed (1).md`
