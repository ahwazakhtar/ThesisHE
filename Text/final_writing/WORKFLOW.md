# Final Writing — Workflow

**Created:** 2026-08-13 · **Track:** `thesis_completion_20260704`, tasks 2.4–2.5.
**Principle:** the dissertation is written **in the author's own words**. Claude supplies
structure, content requirements, and review — never draft prose for the manuscript body.

## The loop (per section)

1. **Outline (Claude).** `essayN_outline.md` specifies, paragraph by paragraph: what the
   paragraph must accomplish, the exact numbers it may cite (with the binding permitted
   language from `Plans/master_evidence_table.md`), the caveats that must sit *beside* the
   claim, and the exhibits to reference.
2. **Draft (author).** You write the prose into `essayN_draft.md` in this folder, section
   by section, in your own words. Follow the recommended *writing order* in the outline
   (results first, introduction last), not the document order.
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

1. Essay 1 (`essay1_outline.md` — ready) → sections in the outline's writing order.
2. Essay 2, then Essay 3 (outlines produced when Essay 1 drafting is underway; they reuse
   Essay 1's data/methods spine in shortened form).
3. General introduction and policy synthesis/conclusion only after all three drafts exist
   (plan §11 Stages 5–6). `Text/drafts/policy_section.md` already holds the policy content.
