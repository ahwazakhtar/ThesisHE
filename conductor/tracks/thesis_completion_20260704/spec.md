# Track Specification: Thesis Completion — Roadmap Execution

**Created:** 2026-07-04
**Origin:** `Plans/roadmap_recommendations_20260704.md` (companion evidence in
`Plans/project_assessment_20260704.md`). This track operationalizes that roadmap.
**Type:** Umbrella / master-execution track for the final thesis push. Where a task overlaps
an existing track, this plan **drives that track to closure** rather than duplicating it
(the overlapping tasks update *both* `plan.md` files).

## Framing principle (from the roadmap)

The econometrics is essentially finished. The binding constraint is now, in order:
1. **Inference protection** on the headline 2012-drought natural experiment,
2. **Prose** (no full essay manuscripts exist yet), and
3. **Stakes** (no welfare/policy quantification exists yet).

Every objective below is scored against those three. The rule of the whole track:
**protect the 2012 income result, then stop doing econometrics and write** — adding stakes
through a mediation estimate and a sufficient-statistics policy section rather than any new
machinery.

## Working assumptions (correct these if wrong — see Open Questions)

- **~9 months to defense** (roadmap sequencing assumes Jul 2026 → Mar 2027).
- **Essay 1 (Incidence) is the job-market paper** — it carries the natural experiment, the
  frontier robustness, and the reviewer-tested mechanisms narrative.
- **The Incidence / Persistence / Inequality structure replaces the proposed structural
  Chapter 3** — pending explicit committee sign-off (Task 1.4 forces that conversation).

## Objectives (tiered exactly as the roadmap)

### Tier 0 — do regardless of timeline (~2–3 weeks)
- **T0.1 Few-treated-cluster inference on the 2012 DiD.** Run the *existing*
  `Code/did_robustness/01_wild_cluster_bootstrap.R` (wild cluster bootstrap-t, Webb weights,
  null imposed, via FWL-demeaned residual model + Fisher randomization inference) on R 4.5.3.
  This is the only open item that can *retroactively weaken an existing headline*, so it is
  first. Closes `did_frontier_robustness_20260625` **Phase 1**.
- **T0.2 Close the DiD frontier track.** Run `04_synthesize_did_robustness.R`, fold the
  bootstrap p-values into `Text/technical_note/technical_note_empirical_framework.{html,tex}`, write the
  Phase-5 `testthat` suite. Closes `did_frontier_robustness_20260625` **Phases 4–5**.
- **T0.3 Extend the 2012 DiD pre-period with BEA income (1990–2011).** The panel starts 2011
  so the 2012 cohort has *no testable pre-period* — the single biggest identification hole in
  the strongest result. BEA CAINC1 per-capita income is already downloaded back to 1990
  (`process_county_socioeconomic.R`). Build 1990–2011 PCPI pre-trends for the ~139 treated vs
  ~2,534 never-exposed counties; show/test two-decade parallel pre-trends. (Employment cannot
  be extended — ACS starts 2011 — and income is the robust result anyway.)
- **T0.4 Draft the committee memo on Chapter 3.** A written memo/email for the author to send,
  asking the committee to confirm the Incidence/Persistence/Inequality structure replaces the
  structural model, and offering the sufficient-statistics section (T1.3) as the scaled-down
  policy component if they still want one. **User-decision gate** — this track drafts, the
  author sends.
- **T0.5 Housekeeping.** Fix the two incomplete references (Audi et al. 2024–25; Doremus et
  al. 2022) and the two `[TK]` baseline denominators in the reviewer-response file; delete
  stray `*.tmp.*` artifacts; batch the open Conductor verification gates.

### Tier 1 — the core push (~2–3 months): write, and add stakes
- **T1.1 Premium pass-through / mediation** (the one undelivered *and* cheap proposal-era
  analysis). Two equations: shock → benchmark premium (pass-through ρ), then medical-debt
  share with/without premium controls (fraction-surviving decomposition, reusing the
  `run_demographic_mediators.R` machinery). Everything needed is already in the county master.
- **T1.2 Data-integrity fix.** Enforce one-row-per-county-year in the county master upstream
  (the ~3% multi-rating-area duplicate rows, currently deduped ad hoc downstream). Re-run the
  affected regressions, confirm nothing moves, log it. Closes the `county_analysis_refinement`
  deferred item.
- **T1.3 Sufficient-statistics policy section** (the honest, tractable descendant of Ch. 3 —
  a section, not a model): (a) price the "unpriced margin" (premium lag responses × exposed
  enrollment → aggregate mispricing in dollars); (b) aggregate the scars (dose-bin job losses
  and drought debt scar × exposed population → national annual burden with honest error
  bands); (c) one targeting statement (top-decile counties' share of total harm).
- **T1.4 Essay 1 full draft** (job-market paper), assembled from existing parts (abstracts,
  technical note, mechanisms section, decks) in NBER style. Writing discipline: lead with
  income (robust), caveat employment (fragile), frame medical debt as measurement, lead
  mechanisms with morbidity + labor exposure.
- **T1.5 Essays 2 & 3 full drafts** — share Essay 1's data/methods sections, so faster.

### Tier 2 — if time allows (~1 month each; only after Tier 1 drafts exist)
- **T2.1 County mortality from CDC WONDER** (keyless, public, county-year): all-cause +
  cardiovascular/respiratory vs the four shocks; reproduces the Barreca/Deryugina benchmark
  in-panel; pre-empts "where is health in this health-economics thesis?"
- **T2.2 Recurring-treatment frontier estimator** (de Chaisemartin–D'Haultfœuille
  `did_multiplegt_dyn` or Borusyak–Jaravel–Spiess), income outcome only, R 4.5.3 — addresses
  the on/off treatment estimand directly rather than via the first-onset recast.
- **T2.3 Hospital closures as the supply-side extreme outcome** — shock → closure-hazard model
  (closure events derivable from CCN exit in the NASHP panel). Guard the reverse-causality
  direction (closures → local economy).

## Explicitly out of scope (per the roadmap's "recommend against")

- The full structural microsimulation (multi-month, high modeling risk; offer T1.3 instead).
- Reviving wildfire smoke / FEMA disasters as *headline* hazards (AQI identification is thin;
  acknowledge the demotion in one paragraph and move on).
- New exposure platforms (satellite NDVI/LST, mobility-based exposure) — already decided out
  of scope in the CHEI spec; keep them there.

## Environment

- Main pipeline on **R 4.2.2** (`C:/Program Files/R/R-4.2.2/bin/Rscript.exe`).
- DiD frontier layer (T0.1–T0.2, T2.2) on **R 4.5.3**
  (`C:/Program Files/R/R-4.5.3/bin/Rscript.exe`) — `DRDID`, `did`, `HonestDiD`,
  `fwildclusterboot`, and (for T2.2) `DIDmultiplegt` / `did_multiplegt_dyn` live only there.
- New R code self-documents (source provenance + decision rationale) and self-logs runs via
  `sink()` to `Analysis/**/build_logs/*.log`, per project convention. Runs are script files,
  not inline `Rscript -e`.
- Tests via `testthat`, >80% coverage target for new code.

## Acceptance criteria (track-level)

- **T0.1** wild-bootstrap + randomization-inference p-values reported next to the analytic p
  for PCPI_Real and Civilian_Employed; explicit statement of whether the income (and
  employment) effects clear 0.05 under the cluster-robust corrections.
- **T0.2** `did_robustness_summary.md` written; technical note updated with the bootstrap
  p-values; `testthat` suite passes; `did_frontier_robustness_20260625` closed.
- **T0.3** a 1990–2011 pre-trend figure + a test (or reported estimate) of parallel pre-trends
  for treated vs never-exposed; one paragraph in the technical note stating the verdict.
- **T0.4** committee memo drafted and handed to the author.
- **T0.5** references complete, `[TK]`s resolved, `*.tmp.*` gone, verification gates batched.
- **T1.1** pass-through ρ estimated with SE; fraction-of-debt-effect-surviving-premium-controls
  reported; write-up paragraph.
- **T1.2** county master certified one-row-per-county-year at build; affected regressions
  re-run and shown to be materially unchanged; logged.
- **T1.3** three numbers with honest error bands (aggregate mispricing $, national scar burden
  $, top-decile harm share %); one policy section written.
- **T1.4 / T1.5** complete Essay 1/2/3 manuscripts in NBER style.
- **T2.1–T2.3** each: data/estimator built, results tabulated, one write-up paragraph, tests
  where new code is introduced. Gated on Tier-1 drafts existing first.

## Open questions for the author (roadmap Part VI — answers refine this track)

1. **Timeline:** defense date / hard deadline? (assumed ~9 months.)
2. **Job-market paper:** which essay? (assumed Essay 1.)
3. **Chapter 3 status:** has the committee formally accepted the reorganization, or is a
   policy/welfare component still owed? (T0.4 forces this; T1.3 is the hedge.)
4. **Scope appetite:** new identification + welfare quantification, or writing-and-packaging
   only? (determines how much of Tier 2 is ever reached.)
