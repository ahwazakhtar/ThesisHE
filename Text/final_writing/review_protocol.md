# Review Protocol — fresh-eyes writing review

Each review is run by a **separate agent with no drafting context**, so it reads the text
the way a committee member would. Claude (main session) launches it and files the report.

## Inputs the reviewer reads (and nothing else unless listed in the request)

1. The draft section(s) under review: `Text/final_writing/essayN_draft.md`
2. The outline spec: `Text/final_writing/essayN_outline.md`
3. The binding claim table: `Plans/master_evidence_table.md`
4. Style rules: `.claude/skills/nber-economist-writing-style/` (incl. `reference/exemplars.md`)
5. On request: specific `Analysis/` output files for number verification

## Review dimensions (report in this order)

1. **Clarity** — sentences a committee member must reread; overloaded sentences carrying
   identification + population + estimate + robustness + caveat at once (the known risk,
   per re-audit item i); undefined terms used before definition.
2. **Coherence & flow** — does each paragraph do one job; do transitions carry the
   argument; does the section deliver what the outline assigned it; orphaned material.
3. **Claim discipline** — every quantitative/causal sentence checked against the evidence
   table row cited in the outline: exact figure, tier-appropriate prominence, required
   caveat co-located (not deferred to a distant section), no RETIRED language. Flag any
   number that cannot be matched to a row.
4. **NBER style** — antithetical epigrams (forbidden), unanchored numbers (must have a
   baseline/denominator), hedging calibrated to the robustness record, idiom outside
   intro/conclusion, passive-voice pileups.
5. **Economy** — what can be cut; duplicated content that has another home (one-result-
   one-home rule, writing plan §3).

## Output format (the agent writes this file; main session saves it)

`Text/final_writing/reviews/essayN_review_<yyyymmdd>_<scope>.md`:

- **Verdict** (2–3 sentences: is the section committee-ready, and what is the one biggest
  fix).
- **Must-fix** — numbered list; each item quotes the offending text, names the dimension,
  and states the problem. For claim-discipline items, cite the evidence-table row.
- **Should-fix** — same format, lower stakes.
- **Line edits offered, not applied** — optional suggested rewordings, clearly marked as
  suggestions for the author to rewrite in their own words.
- **What works** — brief, so revision doesn't destroy the good parts.

The reviewer never edits the draft file.

## Launch template (for the main session)

Agent type: general-purpose. Prompt skeleton:

> You are a fresh-eyes reviewer for a PhD economics dissertation chapter. You have no
> prior context on this project. Read `<draft path>` (§X only), `<outline path>` (the
> spec for §X), `Plans/master_evidence_table.md` (binding claim language), and the style
> rules in `.claude/skills/nber-economist-writing-style/`. Then write a review following
> `Text/final_writing/review_protocol.md` §"Review dimensions" and §"Output format".
> Return the full review text; do not edit any file except writing your report to
> `Text/final_writing/reviews/<name>.md`.
