# Track Specification: Mechanisms Section — Second-Reviewer Revision

**Created:** 2026-07-04
**Origin:** Second-reviewer feedback (`Text/second_reviewer_feedback_mechanisms.md`), triaged in
`Plans/mechanisms_revision_plan_20260704.md` (Fable strategic review + three Sonnet reference/data
lookups).
**Parent:** `mechanism_channels_20260625` (this revises that track's §6 output — the four-channel
narrative and the agricultural-channel bounding).

## Motivation

A committee-side second reviewer accepted the reduced form but flagged nine issues in the mechanisms
section (§6): an unestimated "runs primarily through" decomposition claim, a scale problem in the
tercile comparisons, an unrun interaction horse-race, recurring-treatment DiD robustness, a
frozen-baseline heat-trend threat, a Medicare-doesn't-reach-debt gap, a testable-but-untested
provider-finance story, an IRS-non-filer caveat, and multiple-hypothesis testing. The tone is
pre-emptive armor, not attack — the goal is to adopt the fixes, concede the two weak points cleanly,
and lean on the robustness battery already built.

**Strategic frame (governs every decision):** the reviewer's deepest attacks (A3 energy burden, B2
heat trend) bite almost exclusively on **heat** coefficients, while the section's load-bearing
separability results are **cold/AQI** — and cold/drought are *anti-fragile* to the frozen-baseline
critique (warming makes cold shocks rarer → attenuation bias, not spurious findings). The spine
survives worst-case robustness outcomes; **energy burden is the sacrificial channel** (double-exposed
to A3 and B2).

## Objectives (the nine points; MUST / STRENGTHENS / DEFER as triaged)

- **A1** Soften "runs primarily through" → "operates substantially outside agriculture" (MUST); add an
  upper-bound accounting table in rescaled units for significant cells (STRENGTHENS). The literal
  $177/9.5-ED → 1.1pp-debt calibration is a **trap** (units/populations don't line up) — hedged
  order-of-magnitude compatibility paragraph or decline.
- **A2** Re-run employment specs in **log(Civilian_Employed)** + per-1,000 workers (MUST, FIRST) — the
  −2,011-vs-−721 "strengthening" is a county-size artifact in levels.
- **A3** Horse-race shock × {Ag, Labor, EnergyBurden, SVI, **poverty, baseline-climate**} jointly,
  standardized (minimal energy-burden version MUST; full STRENGTHENS). Concede energy burden if it
  attenuates.
- **B1** Recurring-treatment robustness: **leads-as-placebos** + **2012 2×2 event-study figure**
  (MUST); `twowayfeweights` negative-weight share + `did_multiplegt_dyn` on two headline pairs
  (STRENGTHENS); state that Goodman-Bacon / Borusyak–Jaravel–Spiess are staggered-only and don't
  extend. Full-grid robust estimator DEFERRED.
- **B2** **Division×year FE** on heat headlines (MUST); state×year FE + **Conley SEs** (STRENGTHENS);
  **decline the rolling climatology** (re-opens the scoped-out shock definition).
- **C1** Reframe Medicare as a **sentinel population** + lag-structure-by-channel calendar (MUST);
  **Census SAHIE** working-age-uninsured moderator bridge (STRENGTHENS). HCUP/HCCI/BRFSS declined.
- **C2** **USDA RMA Cause-of-Loss** drought→indemnity→uncompensated-care buffer test (STRENGTHENS,
  highest leverage-per-effort); trim five stories to the two evidenced (MUST). FSA payments deferred.
- **C3** IRS non-filer caveat — measured out-migration is a *lower bound*, so the selection share of
  the drought scar could be *larger* (cuts against scarring) (MUST, ~10 min).
- **C4** Per-channel **Romano–Wolf** (`wildrwolf`) + **Anderson (2008) index** + sharpened q-values on
  the post-A2 grid (STRENGTHENS/MUST); pre-concede the p≈0.05 casualties in text.

## Scope

- **Re-estimation surface:** `Code/run_mechanism_{agriculture,secondary,medicare,provider}.R` (the
  mechanism scripts), plus new helper/analysis scripts for the horse-race, RW/Anderson, RMA test,
  event-study figure, and SAHIE bridge. Outputs under `Analysis/mechanism/`.
- **Prose:** `Text/mechanisms_section.md` (§6.3, §6.5, §6.6 carry the exposed claims),
  `Text/reviewer_response_mechanisms_nber.md`, and a new response-to-second-reviewer document.
- **New data:** Census SAHIE (county×year 18–64 uninsured, 2011–2023), USDA RMA Cause-of-Loss
  indemnities (county×year, drought cause, 2011–2023). New intermediates in `Data/`.

## Out of scope (deferred / declined, with rationale)

- **Rolling climatology / redefining the shock** — the frozen 1990–2000 baseline is a defended design
  choice (technical-note §1.2); FE robustness (division×year, state×year) substitutes.
- **HCUP SID/SEDD** (purchase + DUA), **HCCI** (insured-only, application), **BRFSS/SMART** (MMSA not
  county) — access-infeasible in a ~3-week window.
- **USDA FSA disaster payments** — no public bulk county-year file (RMA indemnities carry C2).
- **Full-grid robust DiD re-estimation** — `did_multiplegt_dyn` on two headline pairs only.
- **Literal Medicare→debt calibration** — replaced by a hedged compatibility paragraph.

## Environment

- Main pipeline on **R 4.2.2**; the multiple-testing and recurring-treatment robustness layer on
  **R 4.5.3** (`C:/Program Files/R/R-4.5.3/bin/Rscript.exe`): `wildrwolf` + `fwildclusterboot`
  (r-universe `https://s3alfisc.r-universe.dev`, archived from CRAN), `DIDmultiplegtDYN`,
  `TwoWayFEWeights` (CRAN); `mutoss` (sharpened q-values, either R). Anderson index is hand-rolled
  (no package). Conley SEs via `fixest::vcov_conley` (main R). Every script header states its R.
- New R code self-documents + self-logs via `sink()` to `Analysis/mechanism/build_logs/*.log`.
- Tests via `testthat`, >80% for new code.

## Acceptance criteria

- Employment specs re-estimated in logs/per-1,000; §6.3 + energy-burden paragraph rewritten; the
  "strengthens" claim either survives in logs or is downgraded to "survives."
- Interaction horse-race run; energy burden's fate decided and reflected in the text.
- Negative-weight share reported; leads-as-placebos + 2012 event-study figure produced;
  `did_multiplegt_dyn` on the two headline pairs; staggered-only tools explicitly dispositioned.
- Division×year-FE (and where feasible state×year) + Conley-SE robustness columns on heat headlines.
- Medicare reframed as sentinel + lag calendar written; SAHIE working-age bridge estimated.
- RMA indemnity buffer test run; provider-finance stories trimmed to the evidenced two.
- IRS non-filer caveat added; migration downgraded to suggestive.
- Per-channel Romano–Wolf + Anderson indices + sharpened q-values tabled; marginal results pre-conceded.
- A1 language softened everywhere; upper-bound accounting table added (rescaled units, significant
  cells, homogeneity caveat); §6 rewritten end-to-end; second-reviewer response drafted.
- Tests where new code is introduced.
