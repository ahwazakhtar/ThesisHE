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

## Render pipeline (rewritten 2026-08-20)

**`Text/final_writing/render_rug.js` is the current renderer.** It reads the three author
drafts and emits four documents into `rendered_rug/`, styled after
`Econometrics_Economics_Thesis_Paper_template/`:

| Output | Class | What it is |
|---|---|---|
| `essay{1,2,3}.pdf` | `article` | standalone papers, own title page, abstract, glossary, references |
| `thesis.pdf` | `report` | the volume, one `\chapter` per essay, contents + glossary + one reference list |

Both targets come from the same code path (a `mode` flag), so they cannot drift. Superseded:
`render_thesis.js`, `render_draft_to_tex.js`, `render_harness_to_tex.js` (the last renders
harness pre-fill, not author prose) — all still write to `rendered/`.

**Two conventions the drafts must follow.**

1. *Cite exhibits by registry token* (`Table E1-T7`, `Figure E3-F2`). The renderer rewrites each
   to `\ref{}`, so the PDF prints a sequential number and the token never reaches a reader. A
   token with no entry in the `EXHIBITS` map is left as literal text, and the build report lists
   any registered exhibit the prose never cites — neither failure is silent.
   **This is how Essays 2 and 3 came to render with ZERO exhibits** (found 2026-08-20): they
   cited "Table 1" / "Figure 4", which matched nothing, for the whole life of the old renderer.
2. *Cite works in plain text.* A fixed `CITATIONS` list maps citation strings to
   `\citep`/`\citet` against `references.bib`; bibtex/apalike generates the list. A new citation
   needs **both** a bib entry and a row in that list, or it renders as plain text.

`prefer` pins an exhibit to the paragraph that actually analyses it; `anchor` places by keyword
for exhibits the prose never cites by number. `$$ … $$` passes through raw, with a trailing
`%%label` becoming `\label{eq:…}`.

### Rendering traps found the hard way

- **A `tabularx` inside a `table` float CANNOT break across pages, and overflow is lost
  silently.** E1-T0b overflowed by 1012pt — two whole panels, five rows and the table note never
  reached the PDF, with only a "Float too large for page" warning. Any table taller than a page
  must use `write_tex_table(longtable = TRUE)`, which resolves the X column to an explicit width
  (`resolve_X()`) because `longtable` has no X column type. **Treat every "Float too large"
  warning as lost content, not cosmetics.**
- **`\theHsection` must be restored alongside `\thesection`.** Resetting the section counter for
  a per-chapter appendix without it makes the appendix reuse the *hyperref anchors* of §1.1/§1.2,
  so TOC and bookmark links jump to the wrong pages. `\ref` still resolves, so the logs stay
  clean — check `thesis.toc` for `section.N.appendix.X` names bleeding into later chapters.
- **A regex meant for U+00A0 matched every space** and turned the document non-breaking (384
  overfull boxes). Write the non-breaking space as a ` ` escape, never as the literal
  character.
- **Converting the Unicode minus to `$-$`** creates unbreakable inline math that blocks
  line-breaking; use `\textminus{}`.
- Markdown export from a harness carries **prose only** — attached figures do not survive, which
  is why the `EXHIBITS` map exists.

### Review surface

`Text/final_writing/draft_edits_review.html` — a side-by-side proof sheet (current text against
suggested edit, filterable by essay/severity/kind) with editable suggestions autosaved to
`localStorage` and a Markdown export. Regenerate the local copy by re-wrapping the artifact
source with a doctype, reset, theme toggle and `Save .md` button; the hosted artifact sandboxes
downloads, so it carries clipboard export only.

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
  (the untraced $18 must not reappear).
- **County medical-debt cells CORRECTED 2026-08-18 (re-estimated; see
  `conductor/knowledge/econometrics.md`).** Drought→debt no longer leads with "county
  +0.54 pp (p<0.01)" — the county mirror gives **+0.58 pp at p=0.024**, and it dies under
  income/uninsurance controls. Cold→debt has **no citable county figure at all** (the
  mirror is −0.27 pp, p=0.46, wrong-signed); cite the **state** cell 1.35 pp (p=0.012)
  alone.
- **Full reference list exists** (`Text/final_writing/references.{tex,bib}`, 16 works
  web-verified 2026-08-18) — extend that file rather than re-verifying cites ad hoc. One
  open item: de Chaisemartin & D'Haultfœuille is cited in text as 2024 but published
  **ReStat 108(4):863–880 (2026)**.

## Presentations (Beamer)

- Use the `beamer-presentation` skill.
- Hyperlinked appendix pattern: `\begin{frame}[label=x]` + `\hyperlink{x}{\beamergotobutton{...}}`
  / `\beamerreturnbutton`, with `\appendix` before the detail slides; needs **two pdflatex
  passes**. Buttons on already-full slides overflow — free space first (drop a caption,
  shrink a figure).
- **Presentation `.tex`/`.pdf` are gitignored** — existing committee decks were never
  force-added; new decks stay untracked unless the user asks to `git add -f`.
