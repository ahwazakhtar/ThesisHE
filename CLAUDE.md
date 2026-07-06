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
~2011–2026. Entirely R-based; two R installs (see `conductor/knowledge/environment.md`).

**Snapshot (Jul 2026)** — the track registry (`conductor/tracks.md`) and each `plan.md`
are the source of truth; this is orientation only:
- Analysis layers complete with deep robustness: state + county FE, event studies,
  persistence/dose, exposure index (EJ), hospital supply side, mechanisms, DiD frontier
  robustness, premium mediation.
- Headline findings: drought **income** losses (robust; employment fragile); drought debt
  **scars** (h=2); **cold employment compounds** with cumulative exposure; climate harm
  **amplified in high-SVI counties** (real-economy outcomes); **no coherent premium
  pass-through**; mechanisms led by Medicare morbidity + broad labor exposure.
- Active: `thesis_completion_20260704` (umbrella — essay drafts are the critical path),
  `mechanisms_revision_20260704`. Open user gates: Conductor verification checklists.

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

## Script Run Order (main pipeline, R 4.2.2)

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
- **Medical debt is measurement-fragile** (credit-bureau artifact; aggregation-sensitive
  EJ direction). Lead claims with income/employment/premiums.

Conventions:
- `fixest::feols` for all FE models — no `plm`/`sandwich` in production code.
- Tests: `testthat`, plain `Rscript Code/tests/test_*.R`; >80% coverage for new code.
- New analysis outputs go to `Analysis/<family>/` (never the `Analysis/` root); add an
  `Analysis/INDEX.md` row. Historical docs intentionally cite pre-Jul-2026 root paths.
- R 4.2.2 for everything except `Code/did_robustness/` (R 4.5.3) — details in
  `conductor/knowledge/environment.md`.
- Hooks invoke `python` (not `python3` — MS Store stub trap).
- All planning documents go in `Plans/`.
