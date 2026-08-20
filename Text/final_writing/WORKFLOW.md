# Final Writing — Workflow

**Created:** 2026-08-13 · **Track:** `thesis_completion_20260704`, tasks 2.4–2.5.
**Principle:** the dissertation is written **in the author's own words**. Claude supplies
structure, content requirements, and review — never draft prose for the manuscript body.

## The loop (per section)

1. **Outline + content (Claude).** Two layers per essay: `essayN_outline.md` is the map
   (section/paragraph structure, evidence-table row keys, exhibits, prohibitions);
   `essayN_content.md` pre-fills every paragraph with its content units in narrative
   order — claim, number with baseline, interpretation, co-located caveat, transition —
   as telegraphic fragments, not prose.
2. **Draft (author).** You string the content units into sentences in your own words,
   writing into `essayN_draft.md`, section by section. Follow the recommended *writing
   order* (results first, introduction last, abstract very last), not the document order.
   `[DECIDE]`/`[CITE]`/`[BUILD]` flags in the content file mark author decisions, missing
   citations, and exhibits still to generate.
3. **Review (fresh-eyes agent).** When a section (or batch of sections) is ready, say
   "review essay 1 §5" (or similar). Claude launches a reviewer agent per
   `review_protocol.md` — the agent reads only the draft, the outline, the evidence
   table, and the NBER style exemplar, so it arrives without this session's context.
   Its report lands in `reviews/essayN_review_<yyyymmdd>_<scope>.md`.
4. **Revise (author).** You accept/reject review points and revise. Claude can re-review,
   diff against the previous review, or verify a number against `Analysis/` outputs on
   request. Claude does not silently edit the draft.

## File conventions

| File | Owner | Purpose |
|---|---|---|
| `essayN_outline.md` | Claude | Paragraph-level content spec (updated if results/framing change) |
| `essayN_draft.md` | **Author** | The manuscript prose. Claude edits only on explicit request |
| `essayN_harness.html` | Claude | Browser writing harness: prompts left, editable suggested write-up right; edits autosave to localStorage; **Export** downloads the assembled `essayN_draft.md` (unedited paragraphs are marked `<!-- UNEDITED SUGGESTION -->`) — move the export into this folder to update the draft. Built exhibits render inline under their paragraph (relative paths into `Analysis/` — the harness must stay in this folder for images to resolve) |
| `reviews/` | Claude (agents) | Dated review reports; append-only, never overwritten |
| `WORKFLOW.md`, `review_protocol.md` | Claude | This process |

## Binding constraints on every draft

- **`Plans/master_evidence_table.md` governs every claim** — the Permitted-language column
  is law; RETIRED rows (e.g. "Midwest", the −2,011 low-ag figure, the actuarial-repricing
  story, the manual-CS −$1,050) must not appear.
- **NBER style** (`nber-economist-writing-style` skill; exemplar `Text/reference/w33491.pdf`):
  no antithetical "X, not Y" epigrams; every number anchored to a baseline; graded hedging;
  idiom confined to intro/conclusion.
- **No manually transcribed coefficients without a registry row** — every exhibit cited must
  exist in `Plans/exhibit_registry.md` (or get a new row when built).
- Drafting sequence and quality gates: `Plans/dissertation_writing_and_framing_plan_20260712.md`
  §11 (sequence), §13 (Gates A–F).

## Order of work

1. Essay 1 (`essay1_outline.md` + `essay1_content.md` + `essay1_harness.html` — all ready)
   → sections in writing order.
2. Essay 2 and Essay 3: `essay2_harness.html` / `essay3_harness.html` are ready and embed
   the outline + content layer directly (no separate `.md` packs); both reuse Essay 1's
   data/methods spine in shortened form.
3. General introduction and policy synthesis/conclusion only after all three drafts exist
   (plan §11 Stages 5–6). `Text/drafts/policy_section.md` already holds the policy content.

## Rendering to PDF (rewritten 2026-08-19)

`render_rug.js` is the current render path. It reads the three author drafts and
emits four documents into `rendered_rug/` (untracked; regenerable), styled after
`Econometrics_Economics_Thesis_Paper_template/`:

```
node Text/final_writing/render_rug.js
cd Text/final_writing/rendered_rug
for f in essay1 essay2 essay3 thesis; do
  pdflatex -interaction=nonstopmode $f && bibtex $f &&   pdflatex -interaction=nonstopmode $f && pdflatex -interaction=nonstopmode $f
done
```

- `essay1.pdf` / `essay2.pdf` / `essay3.pdf` — standalone `article`-class papers,
  each with its own title page, abstract, and reference list.
- `thesis.pdf` — the combined `report`-class volume, one chapter per essay, with
  contents, glossary, and a single reference list.

Both targets come from the same code path (a `mode` flag), so they cannot drift.

**Two conventions the drafts must follow.**

1. *Cite exhibits by registry token.* Write `Table E1-T7` / `Figure E3-F2` in the
   markdown. The renderer rewrites each into `\ref{}`, so the PDF prints a
   sequential number and the token never reaches a reader. A token with no entry
   in the renderer's `EXHIBITS` map is left as literal text — and the build report
   lists any registered exhibit the prose never cites, so neither failure is
   silent. (Before 2026-08-19 Essays 2 and 3 cited exhibits as bare "Table 1" /
   "Figure 4", which matched nothing: both essays rendered with **zero** exhibits.)
2. *Cite works in plain text.* The renderer maps a fixed list of citation strings
   (`CITATIONS` in the script) onto `\citep`/`\citet` against `references.bib`.
   A new citation needs a bib entry and one row in that list; until it has both it
   renders as plain text rather than failing.

`\FloatBarrier` is emitted at each section boundary so an inline exhibit stays in
the section that discusses it. `setspace` and `placeins` are not in a base TinyTeX
install; the generated `preamble.tex` falls back gracefully, but for exact
template fidelity run `tlmgr update --self && tlmgr install setspace placeins`.

The RUG crest on the template's title page is deliberately **not** reproduced.
Drop an institutional logo into `rendered_rug/` and uncomment the
`\includegraphics` line in `titlePage()` to restore one.

### Superseded renderers

`render_thesis.js`, `render_draft_to_tex.js`, and `render_harness_to_tex.js` write
into `rendered/`. They predate the template migration and are kept only for
comparison; `render_harness_to_tex.js` in particular renders the harness
pre-fill, not author prose.

