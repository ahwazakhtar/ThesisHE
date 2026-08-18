# Knowledge: Writing, Thesis Architecture & Presentations

Read this before drafting or revising any thesis prose, abstract, response document,
or slide deck.

## Text/ layout (reorganized Jul 2026)

One folder per document family — `final_writing/` (the essay-drafting workspace:
outlines, browser harnesses, author-owned drafts, agent reviews — see its `WORKFLOW.md`),
`drafts/` (earlier thesis-bound prose), `technical_note/`, `correspondence/` (feedback +
responses), `presentations/` (dated decks), `submissions/`, `poster/`, `reference/`
(proposal + style exemplar). Map with per-document status: `Text/INDEX.md`. Never write
to the `Text/` root; essay drafts now land in `Text/final_writing/` (harness export;
drafts are author-written — Claude outlines and reviews but never edits prose unasked).
The harness HTMLs must stay in `final_writing/` (inline exhibits use relative paths
into `Analysis/`).

## Thesis architecture

- **Essay 1 is Medicare-led since 2026-08-17** (advisor sign-off pending —
  `Plans/essay1_restructure_20260817.md`): §4 Medicare morbidity is the centerpiece;
  §6 Household economic capacity keeps the distributed-lag income result; the 2012 drought
  experiment + farm/nonfarm decomposition live in **Appendix A**; **Appendix B** carries
  shock-definition (baseline-horizon) and estimation-horizon robustness. The essay1
  harness localStorage key is `essay1harness.v2.` (v1 = pre-reframe author drafts,
  recoverable by reverting the key constant); display order = writing order, export
  sorts by `.doc` (document order).
- The proposal (`Text/reference/v2_Akhtar_Proposal.pdf`) has a **demand/supply structure**:
  Ch.1 consumers (premiums + medical debt), Ch.2 hospitals (operating margins,
  uncompensated care, financing, provider heterogeneity), Ch.3 structural. The working
  reorganization is **three essays — Incidence / Persistence / Inequality** (demand-heavy;
  the hospital supply side is woven through via `hospital_supply_side_20260615`).
  Whether the three-essay structure replaces the structural Ch.3 is an **open committee
  decision** (memo drafted: `Text/correspondence/committee_memo_ch3_structure.md`).
- Framing rules for results (see also `knowledge/econometrics.md`): lead drought→income
  with the **window-stable distributed-lag relationship**; the 2012 2×2 −$1,311 is a **raw
  event contrast** that must be paired with its farm/nonfarm decomposition (≈$900 = farm
  reversion from the 2011 commodity-price peak; nonfarm −$261…−$414 baseline-invariant but
  never significant — evidence-table Row 1, AMENDED 2026-08-17). Caveat employment; frame
  medical debt as a measurement outcome; lead mechanisms with morbidity/utilization + labor
  exposure, with agriculture as the tested-and-bounded hypothesis and migration as a caveat.

## Claim discipline (binding, Jul 2026)

- **`Plans/master_evidence_table.md` governs every claim in every prose surface**
  (abstracts, essays, memos, decks, submissions): the Permitted-language column is binding;
  RETIRED rows must not reappear. Status FROZEN-READY (clean-room certified 2026-07-13).
- `Plans/exhibit_registry.md` is the manuscript exhibit inventory (generating script +
  master stamp per exhibit); new exhibits get a row.
- Submitted documents (`Text/submissions/`) are never silently rewritten — corrections go
  in an `*_ERRATA.md` beside them for the author to act on.

## NBER writing style

- Use the **`nber-economist-writing-style` skill** for any thesis prose. Reverse-engineered
  from `Text/reference/w33491.pdf` (Aguilar-Gomez, Graff Zivin & Neidell 2025); annotated exemplars
  in the skill's `reference/exemplars.md`.
- The most-enforced rule: **no antithetical "X, not Y" epigrams** (0 in 30 source pages;
  "rather than" only for substantive mechanism contrasts). Also: every number anchored to
  a baseline ("From a mean of…"), graded hedging, disarm-the-alternative structure,
  idiom confined to intro/conclusion.

## Existing write-ups (reuse, don't re-derive)

- Three-essay abstracts + umbrella: `Text/drafts/thesis_paper_abstracts.md`.
- Technical note: `Text/technical_note/technical_note_empirical_framework.{tex,html}` (§2.5.4 WCB note,
  §2.5.5 BEA pre-trends, §6 mechanisms).
- Mechanism documents: `Text/correspondence/reviewer_response_mechanisms_nber.md` (+ `_email.md`),
  `Text/drafts/mechanisms_section.md` (§6), verdict in `Analysis/mechanism/mechanism_verdict.md`.
- Premium mediation write-up: `Text/drafts/premium_mediation_writeup.md`.
- **References RESOLVED (2026-08-14, web-verified — full details in
  `Text/final_writing/TK_resolutions.md` §C):** Audi, Hamadi, Capen, Tawk & Williams
  (2025), *J. Hospital Administration* 14(2):16–23 (hurricane risk × hospital
  cost-to-charge ratios); Doremus, Jacqz & Johnston (2022), *JEEM* 112:102609 (energy
  spending gap). Bonus verified cite: Hoerling et al. (2014), *BAMS* 95(2) — the 2012
  drought "arrived without early warning" (supports the sharp-onset design claim).
- **Essay anchors settled (author decision 2026-08-13):** essays anchor to the **E1-T1
  descriptive exhibit** values (mean PCPI $53,145 → −$1,311 ≈ **2.5%**; employment
  48,068; debt share 0.19; all dollars 2023). The task-1.5 candidates ($46,269/50,113)
  are superseded for essay prose; the reviewer-response subsample-denominator question
  applies to that document only. Also settled: **ESI premiums dropped from Essay 1**
  (the untraced $18 must not reappear); drought→debt leads with the county +0.54 pp.

## Presentations (Beamer)

- Use the `beamer-presentation` skill.
- Hyperlinked appendix pattern: `\begin{frame}[label=x]` + `\hyperlink{x}{\beamergotobutton{...}}`
  / `\beamerreturnbutton`, with `\appendix` before the detail slides; needs **two pdflatex
  passes**. Buttons on already-full slides overflow — free space first (drop a caption,
  shrink a figure).
- **Presentation `.tex`/`.pdf` are gitignored** — existing committee decks were never
  force-added; new decks stay untracked unless the user asks to `git add -f`.
