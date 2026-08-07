# Knowledge: Environment, Toolchain & Run Conventions

Read this before running R scripts, installing packages, or touching `.claude/` config.

## R toolchain (MIGRATED 2026-08-07 — single-version now)

- **All code: R 4.5.2** (`C:/Program Files/R/R-4.5.2/bin/Rscript.exe`; user library
  `C:/Users/ahwaz/AppData/Local/R/win-library/4.5`). Core set installed 2026-08-07:
  `dplyr`, `tidyr`, `readr`, `fixest`, `testthat`.
- **Migration note (2026-08-07):** the previous two-R setup — main pipeline R 4.2.2 +
  frontier DiD R 4.5.3 — was found uninstalled (binaries and the 4.2 package library
  gone; only R 4.1.3 and 4.5.2 present). User decision: migrate everything to 4.5.2
  rather than reinstall 4.2.2. Consequences:
  - `Analysis/reproduction_certificate.md` (2026-07-13) certifies the **pre-migration
    4.2.2 environment** — it remains a valid historical record; any *re*-certification
    must be re-run under 4.5.2 and version-stamped.
  - The old two-R boundary is dissolved: `Code/did_robustness/` frontier packages
    (`DRDID`, `did`, `HonestDiD`, `fwildclusterboot`) are NOT yet installed under 4.5.2 —
    install on first need. Script headers stating "R 4.2.2"/"R 4.5.3" are historical;
    new scripts state "R 4.5.2".
  - First re-run of any master-building script should be compared against the committed
    outputs before results are cited (package-version drift check).
- Install gotchas (still true): the CRAN package is **`DRDID`** (uppercase — lowercase
  `drdid` is silently "not available"); **`fwildclusterboot` is archived on CRAN** —
  install from r-universe (`https://s3alfisc.r-universe.dev`).

## Run conventions

- R runs are **script files**, never inline `Rscript -e`.
- Each process/estimation script **self-logs via `sink()`** to
  `Analysis/<family>/build_logs/<script>.log`.
- Non-interactive always; tests are plain `Rscript Code/tests/test_*.R` (testthat).
- **Aggregate suite:** `Rscript Code/tests/testthat.R` — rewritten 2026-07-13 to run every
  test file in its own clean R process from the repo root and exit nonzero on ANY failure
  (the old runner was false-green). Report lands in `Analysis/test_reports/`; the runner's
  self-test (`test_runner_selftest.R` + `selftest_fixtures/`) is excluded from the default
  sweep by design.
- **Shared helpers in `Code/pipeline_utils.R`:** `pad_fips()` (the blessed FIPS zero-padder)
  and `open_build_log(family, script)` (sink-based build log with provenance header; close
  via `on.exit()`). New/touched scripts should use both.
- Spatial work needs **only `terra`** (bundles GDAL/GEOS/PROJ; reads rasters and vector
  boundaries) — `sf`/`tigris` are NOT required. Census cartographic boundaries live in
  `Data/Geo/cb_2018_us_{state,county}_20m` (auto-downloaded). County zonal extraction
  ≈ 90s/year.

## Git & search gotchas

- **The repo `.gitignore` is a whitelist** (`*` ignored, then `!*/`, `!*.md`, `!*.r`,
  `!*.pdf`, `!*.tex`, `!*.html`, plus `.claude` entries). Consequences: (a) new file
  types (`.docx`, `.csv`, `.png`, `.txt`, `.log`) are silently untracked; (b) moving a
  tracked file of a non-whitelisted type stages as a **deletion** — the new path needs
  `git add -f` to stay tracked (bit us with a relocated `.docx`, Jul 2026).
- **Don't trust a suspiciously empty directory search.** A ripgrep over `Code/` once
  returned zero hits for a string present in dozens of `.R` files; re-running with an
  explicit `glob: *.R` found all 152. Before concluding "no references exist," re-run
  the search with an explicit glob/type filter.

## Claude Code configuration

- **Hooks must invoke `python`, not `python3`** — `python3` resolves to the Microsoft
  Store stub on this machine and fails silently (both hooks were dead for two days in
  Jul 2026 before this was caught). Real interpreter: `C:\Python314\python.exe`.
- Hooks in `.claude/hooks/`:
  - `session_start.py` (SessionStart) — injects active tracks + next open tasks + git state,
    and **reconciles `tracks.md` markers against each `plan.md`** (the source of truth):
    read-only `⚠ Registry drift` warning when the registry understates a track (tasks
    `[x]`/`[~]` in plan.md but `[ ]` in the registry — the mis-classification that hid three
    finished tracks in Jul 2026). Never edits at startup.
  - `track_edits.py` (PostToolUse on Edit|Write) — appends to `.claude/session_edits.log`.
  - `detect_wrapup.py` (UserPromptSubmit) — on wrap-up keywords, injects the edit log +
    diff stat and tells Claude to invoke the `session-end` skill.
- **Registry-marker rule** (drift detector + session-end Step 5): a track's true marker is
  derived from its `plan.md` task lines — `[ ]` only if nothing is started, `[x]` only if
  *every* line incl. verification checkpoints is `[x]`, else `[~]`. `[ ]`→`[~]` is safe to
  automate; `[~]`→`[x]` needs the user's verification sign-off, so the detector reports it but
  never auto-closes. session-end Step 5 applies the fix and commits `tracks.md`.
- Skills in `.claude/skills/`: `nber-economist-writing-style`, `session-end` (9 steps;
  Step 5 = registry reconcile).
- After editing a hook, self-test it by piping a sample JSON payload
  (`echo '{"tool_input":{"file_path":"X"}}' | python .claude/hooks/track_edits.py`).

## LaTeX

- `pdflatex` via MiKTeX: `C:/Users/ahwaz/AppData/Local/Programs/MiKTeX/miktex/bin/x64/`.
- Hyperlinked Beamer appendices need **two `pdflatex` passes** to resolve buttons.
