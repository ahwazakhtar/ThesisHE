# Text Index

One folder per document family. **New files go into the matching folder, never the
`Text/` root.** Reorganized July 2026; historical docs (`changelog.md`, completed tracks'
`plan.md`) intentionally cite the old flat paths.

| Folder | Contents | Notes |
|---|---|---|
| `drafts/` | Thesis-bound prose: three-essay abstracts, mechanisms §6, premium-mediation write-up, pathway notes, policy synthesis | `thesis_paper_abstracts.md` is the current abstracts doc (`_structured.md` is the Jun 15 variant). `policy_section.md` (2026-07-13) is the sufficient-statistics policy synthesis for the general conclusion (thesis_completion 2.3). The three essay drafts (tasks 2.4–2.5) will live here. |
| `technical_note/` | The empirical-framework note: `.tex`/`.html` sources + rendered PDFs (Long, short) + LaTeX artifacts | The `.tex`/`.html` are the sources of truth; PDFs are dated exports. |
| `correspondence/` | Feedback received + responses sent (external reader, second reviewer, committee) | `reviewer_response_mechanisms_nber.md` **supersedes** the plain `reviewer_response_mechanisms.md`; `_email.md` is the short form. Second-reviewer thread: `second_reviewer_feedback_mechanisms.md` (received) → `response_to_second_reviewer.md` (reply). `committee_memo_ch3_structure.md` is drafted, awaiting the author to send. |
| `presentations/` | Dated committee + seminar Beamer decks (`.tex` + rendered PDFs) and the speaker script | Append-only archive; latest committee deck is `committee_presentation_20260615*`. Deck `.tex`/`.pdf` are gitignored by long-standing convention. |
| `submissions/` | Conference/showcase artifacts: conference abstract, GWSPH showcase, EuHEA proposal | |
| `poster/` | REACH poster (`reach_poster.tex` + renders) and `generate_poster_plots.R` (+ `plots/`) | Moved from repo-root `Poster/` Jul 2026. Run the plot script from the repo root: `Rscript Text/poster/generate_poster_plots.R`. Figure paths inside the `.tex` are folder-relative and unchanged. |
| `reference/` | External documents: `v2_Akhtar_Proposal.pdf` (the proposal), `w33491.pdf` (NBER style exemplar) | `w33491.pdf` is the source for the `nber-economist-writing-style` skill. |
| `_archive/` | Inert files | `persistence.txt` is empty (0 KB) — delete when the author approves. |
