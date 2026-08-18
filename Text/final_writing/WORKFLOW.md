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

## Rendering the harnesses to PDF (added 2026-08-17)

`render_harness_to_tex.js` (this folder; gitignored — no `!*.js` whitelist) extracts each
harness's SECTIONS array in document order and emits LaTeX scaffolds with the exhibit
figures embedded:

```
node Text/final_writing/render_harness_to_tex.js
cd Text/final_writing/rendered
pdflatex -interaction=nonstopmode essay1_scaffold.tex   # likewise essay2/essay3
```

Outputs land in `Text/final_writing/rendered/` (untracked; regenerable). **The render
shows the pre-filled SUGGESTED text only** — author prose lives in the browser's
localStorage and is only reachable via the harness Export button. After exporting your
own draft, that markdown (not this scaffold render) becomes the manuscript source.
