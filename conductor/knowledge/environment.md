# Knowledge: Environment, Toolchain & Run Conventions

Read this before running R scripts, installing packages, or touching `.claude/` config.

## Two-R-version boundary (critical)

- **Main pipeline: R 4.2.2** (`C:/Program Files/R/R-4.2.2/bin/Rscript.exe`).
- **Frontier DiD only: R 4.5.3** (`C:/Program Files/R/R-4.5.3/bin/Rscript.exe`) — the
  packages `DRDID`, `did`, `HonestDiD`, `fwildclusterboot` are unavailable on CRAN for
  4.2.2. `Code/did_robustness/` is the ONLY code that runs on 4.5.3.
- Every frontier script header states which R it needs. Keep that convention for new scripts.
- Install gotchas: the CRAN package is **`DRDID`** (uppercase — lowercase `drdid` is
  silently "not available"); **`fwildclusterboot` is archived on CRAN** — install from
  r-universe (`https://s3alfisc.r-universe.dev`).

## Run conventions

- R runs are **script files**, never inline `Rscript -e`.
- Each process/estimation script **self-logs via `sink()`** to
  `Analysis/<family>/build_logs/<script>.log`.
- Non-interactive always; tests are plain `Rscript Code/tests/test_*.R` (testthat).
- Spatial work needs **only `terra`** (bundles GDAL/GEOS/PROJ; reads rasters and vector
  boundaries) — `sf`/`tigris` are NOT required. Census cartographic boundaries live in
  `Data/Geo/cb_2018_us_{state,county}_20m` (auto-downloaded). County zonal extraction
  ≈ 90s/year.

## Claude Code configuration

- **Hooks must invoke `python`, not `python3`** — `python3` resolves to the Microsoft
  Store stub on this machine and fails silently (both hooks were dead for two days in
  Jul 2026 before this was caught). Real interpreter: `C:\Python314\python.exe`.
- Hooks in `.claude/hooks/`:
  - `session_start.py` (SessionStart) — injects active tracks + next open tasks + git state.
  - `track_edits.py` (PostToolUse on Edit|Write) — appends to `.claude/session_edits.log`.
  - `detect_wrapup.py` (UserPromptSubmit) — on wrap-up keywords, injects the edit log +
    diff stat and tells Claude to invoke the `session-end` skill.
- Skills in `.claude/skills/`: `nber-economist-writing-style`, `session-end`.
- After editing a hook, self-test it by piping a sample JSON payload
  (`echo '{"tool_input":{"file_path":"X"}}' | python .claude/hooks/track_edits.py`).

## LaTeX

- `pdflatex` via MiKTeX: `C:/Users/ahwaz/AppData/Local/Programs/MiKTeX/miktex/bin/x64/`.
- Hyperlinked Beamer appendices need **two `pdflatex` passes** to resolve buttons.
