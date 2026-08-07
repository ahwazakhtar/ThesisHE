# Track Specification: Advisor Feedback August 2026 — Spillovers, Clustering Justification, Window & Horizon Robustness, MAD Scaling

**Created:** 2026-08-07
**Origin:** Advisor meeting (early Aug 2026). Four verbal directives, interpretations
confirmed with the author 2026-08-07:

1. **Spillovers** — test spatial spillovers of climate shocks directly (SUTVA).
2. **"Abadie NBER"** — the clustering paper: Abadie, Athey, Imbens & Wooldridge,
   *When Should You Adjust Standard Errors for Clustering?* (NBER WP 24003; QJE 2023).
   Provide a design-based justification of the clustering level.
3. **Extend time window** — framed as **robustness**: (a) extend the estimation window
   backward before 2011 where data allow, and (b) show that the choice of event-study
   horizons does not drive the headline results.
4. **MAD** — report the **mean absolute deviation** in the impulse-response context, so
   impulse magnitudes can be read against typical outcome deviations (how deviations are
   calculated/scaled in the impulse).

**Type:** Robustness/appendix track on existing machinery. No new data sources except the
Census county adjacency file (item 1). Results feed the essay robustness appendices
(`thesis_completion_20260704` 2.4/2.5); any change to a headline verdict must propagate to
`Plans/master_evidence_table.md` (owned by `audit_response_20260712`).

## Current state (verified 2026-08-07)

- **Clustering:** county regressions cluster at **state** (nests rating areas, matches
  shock level); premium outcomes have `*_RA_Cluster` variants in `run_county_analysis.R`
  (sensitivity-only — never select significance on RA SEs). Conley SEs already run on heat
  headlines (`feat(mechanism): B2`). No AAIW-style written justification exists anywhere
  in the repo (grep for "Abadie": zero hits).
- **Spillovers:** acknowledged as a caveat only
  (`Analysis/memos/results_interpretation_guide.md` §7 SUTVA bullet) — never estimated.
- **Windows:** outcome analysis window 2011–2023. BEA income/employment extends
  **1990–2023** (already used for the flat 1990–2011 pre-trend test); ACS-based outcomes
  (median HH income, civilian employed) cannot extend backward. Premiums 2025/26.
- **Event study:** `Code/run_event_study.R` — DL + LP (Jordà), h = −2…+3 (`h_max <- 3L`),
  reference h=−1. Persistence/debt-scar results at h=2.

## Objectives (expectation-first, per workflow principle 3)

- **O1 — Spillover test.** Add a neighboring-county shock exposure term (share of
  adjacent counties in shock, own county excluded; Census county adjacency file) to the
  headline county FE specs (drought→income, drought→debt, cold→employment).
  **Expectation:** own-shock coefficient stable (±25%) when the neighbor term enters;
  neighbor coefficient same-signed, smaller, likely insignificant under state clustering.
  A large own-coefficient shift is a debugging trigger first, finding second.
  **Contingency:** if neighbor exposure is significant and own-effect shifts materially,
  the headline claims gain a "local net of spillover" qualifier — propagate to the
  evidence table; do not silently absorb.
- **O2 — AAIW clustering justification (methods note, small sensitivity grid).**
  Write the design-based case for state clustering: shocks are assigned by nature at
  county level but spatially correlated within states; state is the coarsest level at
  which assignment correlation plausibly lives, and it nests rating areas (the premium
  price-setting unit). Sensitivity grid on the headline specs: county, state (primary),
  and existing Conley/RA variants cross-referenced — no new inference level becomes
  primary. **Expectation:** county clustering gives smaller SEs (anticonservative under
  spatial correlation); state stays primary either way.
- **O3a — Backward window extension (BEA outcomes only).** Re-estimate drought→income
  (BEA) on the longest feasible pre-2011 extension. **Expectation:** sign and rough
  magnitude stable; caveat that the extended window crosses regime boundaries (pre-ACA,
  different drought climatology) belongs in the write-up either way. ACS outcomes:
  explicitly out of scope (data start 2011) — say so, don't fudge.
- **O3b — Horizon-choice sensitivity.** Re-run the event study at h_max ∈ {2, 3, 4, 5}
  (LP loses one panel year per added horizon; document the shrinking estimation sample).
  **Expectation:** h=0…2 headline coefficients stable across h_max choices; long-horizon
  estimates noisy/wide. The claim being defended: horizon choice does not drive the
  headline verdicts.
- **O4 — MAD scaling of impulses.** Compute the within-county mean absolute deviation of
  each headline outcome (year-to-year deviations over the analysis window) and report
  each impulse-response coefficient as a share of it, alongside the dollar/level effect.
  Descriptive — no hypothesis. **Open construction question:** MAD of raw year-to-year
  changes vs MAD of residualized (FE-purged) deviations; compute both, lead with raw
  (advisor's "to get an idea" suggests the simple version), and confirm with the advisor
  if the two tell different stories.

## Non-goals

- No change to primary specifications, clustering level, or the frozen empirical package's
  headline rows unless an objective's contingency fires (then via the evidence table, with
  a dated spec note here).
- No de Chaisemartin estimator (stays with `did_frontier_robustness` → thesis_completion
  T2.2), no new outcome families, no reopening of closed tracks.

## Deliverables

`Analysis/advisor_robustness/` (new family, INDEX row): spillover results CSV + synthesis,
clustering sensitivity grid + methods note (note also usable as essay-appendix text),
window/horizon sensitivity CSVs + plots, MAD scaling table. Scripts:
`Code/run_spillover_analysis.R`, `Code/run_horizon_sensitivity.R` (or extensions of
existing runners where cleaner), tests per workflow.
