# Claude Code Instructions

## Session Start

A `SessionStart` hook injects the active tracks, each track's next open task, and git
state. Confirm with the user which task to work on before starting. If the hook output is
missing, do it manually: read `conductor/tracks.md`, then the active tracks' `plan.md`
files, and state the next `[ ]` item.

---

## Project Overview

Academic econometrics thesis: climate shocks & air quality → health costs (HIX premiums,
hospital finances, medical debt) and local economies (income, employment) across the US,
~2011–2026. Entirely R-based; single R install since 2026-08-07 — R 4.5.2 (see
`conductor/knowledge/environment.md` migration note).

**Snapshot (Jul 2026)** — the track registry (`conductor/tracks.md`) and each `plan.md`
are the source of truth; this is orientation only:
- Analysis layers complete with deep robustness: state + county FE, event studies,
  persistence/dose, exposure index (EJ), hospital supply side, mechanisms, DiD frontier
  robustness, premium mediation.
- Headline findings (reordered 2026-08-17): **Medicare morbidity/utilization** (direct,
  robust, baseline-invariant); **no coherent premium pass-through**; drought debt
  **scars** (h=2); **cold employment compounds** with cumulative exposure
  (pooled-baseline-checked); climate harm **amplified in high-SVI counties**
  (real-economy outcomes); drought→income holds in **window-stable distributed-lag**
  form — the 2012 2×2 −$1,311 was shown 2026-08-17 to be ~$900 farm-price reversion
  off the 2011 baseline (nonfarm −$261…−$414, ns; evidence-table Row 1 AMENDED).
- Active: `thesis_completion_20260704` (umbrella — essay drafts are the critical path),
  `audit_response_20260712` (Phase 4 parked, Phase 5 close-out pending),
  `code_quality_remediation_20260713` (all phases implemented; §7 defense gate MET —
  awaiting final user sign-off), `advisor_feedback_20260807` (Aug advisor meeting:
  spillovers, AAIW clustering justification, window/horizon robustness, MAD impulse
  scaling — land before essay claims freeze). The aggregate test runner (`Code/tests/testthat.R`) is now
  truthful (clean process per file, nonzero on failure). Empirical package is
  **FROZEN-READY**: masters rebuild byte-identically, 32/32 suites pass, 13/13 headline
  rows match `Plans/master_evidence_table.md` (`Analysis/reproduction_certificate.md`);
  exhibits registered in `Plans/exhibit_registry.md`. **The committee approved the
  three-essay structure** (2026-07-13); Essay-3 framing = hybrid distribution+observability
  per `Plans/dissertation_writing_and_framing_plan_20260712.md`. Essay drafting
  (thesis_completion 2.4–2.5, both `[~]`) is the critical path: the drafting workspace is
  **`Text/final_writing/`** (browser harnesses with pre-filled permitted-language prose +
  inline exhibits; author writes in own words; see its `WORKFLOW.md`). **All three essay
  drafts exported 2026-08-18** (~38 of 68 Essay-1 paragraphs author-written; the rest still
  carry harness pre-fill and are marked as such). **Every registry exhibit now exists** —
  13 built 2026-08-18 (`create_data_source_tables.R`, `create_falsification_table.R`,
  `create_essay1_ledger_exhibits.R`, `create_essay23_exhibits.R`,
  `create_fig_conceptual_model.R`), including E1-F5, which had been pending since the
  registry was seeded. The **combined submission PDF** (`node
  Text/final_writing/render_thesis.js` → `rendered/thesis_submission.pdf`) carries all
  three essays, a glossary, web-verified references, and 7 estimating equations; see
  `conductor/knowledge/writing-and-latex.md` for the three-renderer map. **Essay 1 restructured Medicare-led 2026-08-17** (2012 drought experiment +
  farm/nonfarm decomposition → Appendix A; shock-definition/horizon robustness →
  Appendix B) — **advisor sign-off pending** (`Plans/essay1_restructure_20260817.md`;
  downstream surfaces — abstracts, technical note, policy §, deck — still carry the old
  framing until then).

---

## Knowledge Base — read before touching the matching area

| Before you… | Read |
|---|---|
| Touch any download/process/create script, debug a merge, cite dataset facts | `conductor/knowledge/data-pipeline.md` |
| Write/modify an estimation script, judge a new specification | `conductor/knowledge/econometrics.md` |
| Run R, install packages, edit `.claude/` hooks or skills | `conductor/knowledge/environment.md` |
| Draft/revise thesis prose, abstracts, responses, or slides | `conductor/knowledge/writing-and-latex.md` |
| Answer any question about results | `Analysis/INDEX.md` |

At session end, **merge** new lessons into these topic files (dedupe against what's
there) — do not append session-numbered lists here.

---

## Directory Structure

| Path | Purpose |
|------|---------|
| `Code/` | R scripts: `download_*` → `process_*`/`create_*` → `run_*` (+ `tests/`, `did_robustness/`, `diagnostics/`) |
| `Data/` | Raw + processed data; masters: `state_level_analysis_master.csv`, `county_level_master.csv` |
| `Analysis/` | Outputs, one folder per analysis family; **start at `Analysis/INDEX.md`** |
| `Text/` | Writing, one folder per family (`drafts/`, `technical_note/`, `correspondence/`, `presentations/`, `submissions/`, `poster/`, `reference/`) — **start at `Text/INDEX.md`**; never write to the `Text/` root |
| `Plans/` | ALL planning documents go here |
| `conductor/` | Workflow (`workflow.md`), track registry (`tracks.md`), specs/plans, `knowledge/` |
| `.claude/` | Hooks (`session_start`, `track_edits`, `detect_wrapup`) + skills |

## Script Run Order (main pipeline, R 4.5.2)

1. `Code/download_*.R` — populate raw data
2. `Code/create_state_master.R` — merge and inflation-adjust
3. `Code/analysis_pre_processing.R` — climate shock bins and lags
4. `Code/run_analysis.R` — state FE models
5. `Code/create_county_master.R` — county panel
6. `Code/run_county_analysis.R` — county FE models

---

## Conductor System

All work follows `conductor/workflow.md` (task lifecycle, commits, git notes, phase
checkpoints). `conductor/tracks.md` is the track registry; each track's `plan.md` is the
task-level source of truth — update it before and after every task.

| Marker | Meaning |
|--------|---------|
| `[ ]` | Not started |
| `[~]` | In progress |
| `[x]` | Complete (append 7-char commit SHA) |

---

## Session End

When the user signals wrap-up, a hook injects the session edit log and instructs you to
invoke the **`session-end` skill** — follow it (changelog entry, knowledge-file merge,
INDEX refresh, commit, clear edit log). If the hook missed the phrasing, invoke the skill
yourself.

---

## Cross-Cutting Rules (always in force)

Silent-corruption traps — these produce wrong results with no error:
- **FIPS zero-padding:** `sprintf("%05s", …)` pads with SPACES, silently dropping ~316
  counties with single-digit state codes. Always
  `formatC(as.integer(fips), width = 5, flag = "0")`.
- **County master `State` is a 2-letter abbreviation**; the state pipeline uses full names.
  Joining without an abbreviation→name map zero-matches silently.
- **Never hand-edit build outputs** (`Data/*master*.csv`, intermediates, `Analysis/`
  CSVs/results) — fix the generating script and re-run.
- **"Tests pass" claims must cite the clean-process runner** (`Rscript Code/tests/testthat.R`,
  rewritten 2026-07-13; exits nonzero on any failure). Its predecessor returned exit 0 with
  dozens of errors — never trust a green aggregate run predating the fix.
- **Medical debt is measurement-fragile** (credit-bureau artifact; aggregation-sensitive
  EJ direction; **2023 = reporting-regime change — any debt effect that appears only in
  2023 is an artifact candidate**, e.g. the demoted HDD e=10 +4.9pp cell). Lead claims
  with Medicare morbidity/premiums; income via the distributed-lag form.
- **Single-pre-year DiD anchors produce confident wrong headlines**: the 2×2 (pre =
  event−1) and every manual CS ATT(g,t) (pre = g−1) inherit the anchor year's
  idiosyncrasy — the −$1,311 income "result" was 2011-farm-peak reversion. Before
  headlining such a cell: pooled-baseline check + year-by-year gaps + (for income in ag
  counties) farm/nonfarm decomposition. Hazardous anchors: 2011 (farm peak), 2012
  (drought year), 2023 (debt regime). Details: `conductor/knowledge/econometrics.md`.
- **Log gradients must be translated at the MEDIAN county, not the mean:** county
  employment is heavily right-skewed (mean 48,068, median 10,773). Multiplying a `log_emp`
  coefficient by the mean inflates the jobs figure ~4.5× and reintroduces the county-size
  contamination the log rescaling removed. The E1-T1 anchor 48,068 is for *descriptive*
  statements only.
- **A figure in the evidence table is not proof it reproduces:** two county medical-debt
  cells (Rows 4, 5) had no committed county output behind them and, when re-estimated,
  came back wrong-signed / weaker than asserted (verified 2026-08-18 —
  `conductor/knowledge/econometrics.md`). Before citing a county cell, check that a
  machine-readable output actually contains it; `Analysis/county/county_regression_coefs.csv`
  is a LaTeX dump despite its name.
- **Real-dollar bases can diverge across pipelines:** the county master hardcodes **2023
  dollars**; the state master deflates to the *latest* CPI year in `us_cpi_annual.csv`
  (2025 rows present since Feb 2026). Verify the base before any cross-panel dollar
  comparison — details in `conductor/knowledge/data-pipeline.md`.

Conventions:
- `fixest::feols` for all FE models — no `plm`/`sandwich` in production code.
- Tests: `testthat`, plain `Rscript Code/tests/test_*.R`; >80% coverage for new code.
- New analysis outputs go to `Analysis/<family>/` (never the `Analysis/` root); add an
  `Analysis/INDEX.md` row. Historical docs intentionally cite pre-Jul-2026 root paths.
- R 4.5.2 for everything (single install since the 2026-08-07 migration; the old
  4.2.2/4.5.3 split is dissolved) — details in `conductor/knowledge/environment.md`.
- Hooks invoke `python` (not `python3` — MS Store stub trap).
- **File deletions require the user's approval** (enforced via `permissions.ask`); prefer
  moving debris to an `_archive/` folder. Edits/writes are pre-approved.
- All planning documents go in `Plans/`.
