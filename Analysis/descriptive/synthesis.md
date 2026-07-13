# Descriptive Statistics — Pointer

> **Read the fresh, script-generated report instead:**
> **[`descriptive_stats_report.md`](./descriptive_stats_report.md)** — regenerated
> **2026-07-13** by `Code/run_descriptive_stats.R` from the certified county master
> (`Data/county_level_master.csv`, 118,732 × 82, one row per `(fips_code, Year)`).

## Why this file is a pointer

`run_descriptive_stats.R` writes its narrative as **`descriptive_stats_report.md`**. This
`synthesis.md` was a manual rename of the March-04 report during the July 2026 `Analysis/`
reorganization; it is **not** written by the script, so it went stale (it carried the
pre-dedup 2026-03-04 panel counts, 42,360 study rows). `Analysis/INDEX.md` still lists this
filename as the descriptive family's "read first," so the file is retained here as a
redirect rather than archived, and its stale body has been removed.

The current numbers (fresh 2026-07-13, 41,863 study rows after the CO-2023 debt exclusion,
on the deduped master) live in:

- **`descriptive_stats_report.md`** — narrative report (read first).
- `descriptive_stats_summary.csv` — numeric moments (tails, winsorized, weighted).
- `descriptive_stats_table_main.{csv,tex}` — manuscript-ready condensed table.
- `descriptive_period_comparison.{csv,tex}`, `descriptive_missingness_by_year.csv`,
  `descriptive_correlation_matrix.csv` — supporting tables.
- Figures: `Analysis/plots/descriptive/`.

_Reconciled 2026-07-13 under `code_quality_remediation_20260713` Phase 5 (task 5.1)._
