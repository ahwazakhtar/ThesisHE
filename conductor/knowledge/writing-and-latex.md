# Knowledge: Writing, Thesis Architecture & Presentations

Read this before drafting or revising any thesis prose, abstract, response document,
or slide deck.

## Text/ layout (reorganized Jul 2026)

One folder per document family — `drafts/` (thesis-bound prose), `technical_note/`,
`correspondence/` (feedback + responses), `presentations/` (dated decks), `submissions/`,
`poster/`, `reference/` (proposal + style exemplar). Map with per-document status:
`Text/INDEX.md`. Never write to the `Text/` root; new essay drafts go in `Text/drafts/`.

## Thesis architecture

- The proposal (`Text/reference/v2_Akhtar_Proposal.pdf`) has a **demand/supply structure**:
  Ch.1 consumers (premiums + medical debt), Ch.2 hospitals (operating margins,
  uncompensated care, financing, provider heterogeneity), Ch.3 structural. The working
  reorganization is **three essays — Incidence / Persistence / Inequality** (demand-heavy;
  the hospital supply side is woven through via `hospital_supply_side_20260615`).
  Whether the three-essay structure replaces the structural Ch.3 is an **open committee
  decision** (memo drafted: `Text/correspondence/committee_memo_ch3_structure.md`).
- Framing rules for results (see also `knowledge/econometrics.md`): lead with **income**
  (the robust DiD result), caveat employment; frame medical debt as a measurement outcome;
  lead mechanisms with morbidity/utilization + labor exposure, with agriculture as the
  tested-and-bounded hypothesis and migration as a caveat.

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
- **Outstanding items:** two incomplete references (Audi et al. 2024–25 — FEMA hurricane
  risk × hospital financial ratios; Doremus et al. 2022 — energy burden/affordability
  adaptation) and `[TK]` baseline denominators in the reviewer response — subsample
  effects need subsample means as denominators (author to confirm; candidates computed in
  thesis_completion plan task 1.5).

## Presentations (Beamer)

- Use the `beamer-presentation` skill.
- Hyperlinked appendix pattern: `\begin{frame}[label=x]` + `\hyperlink{x}{\beamergotobutton{...}}`
  / `\beamerreturnbutton`, with `\appendix` before the detail slides; needs **two pdflatex
  passes**. Buttons on already-full slides overflow — free space first (drop a caption,
  shrink a figure).
- **Presentation `.tex`/`.pdf` are gitignored** — existing committee decks were never
  force-added; new decks stay untracked unless the user asks to `git add -f`.
