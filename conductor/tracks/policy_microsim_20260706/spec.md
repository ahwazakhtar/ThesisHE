# Track Specification: Policy Frontier — Sufficient-Statistics Microsimulation

**Created:** 2026-07-06
**Origin:** Session-10 synthesis (`Plans/frontier_extensions_plan.md`), which mapped the October 2025 proposal (`Text/reference/v2_Akhtar_Proposal.pdf`, pp. 3, 33–37) against delivered work and found the Chapter-3 policy microsimulation to be the largest unbuilt promise. Companion diagnostics: `Plans/results_evolution_narrative.md`, `Plans/methods_retrospective.md`.

## Description

The proposal committed to a **semi-structural, cell-based policy microsimulation** — a
transparent calculator that translates the thesis's reduced-form elasticities into
counterfactual ACA subsidy design under climate risk:

> "Chapter 3 develops a structural framework nesting consumers … insurers … and hospitals …
> under a distribution of local climate shocks. Calibrated to reduced-form elasticities from
> Chapters 1–2 … the model simulates counterfactual policies: climate-risk adjusters in
> payment, geographically targeted premium support, disaster-triggered cost-sharing waivers,
> and provider stabilization instruments." (proposal p. 3)

The committee memo (`Text/correspondence/committee_memo_ch3_structure.md`) records that this was dropped when
Chapter 3 became the "Unequal Weather" inequality essay, and proposes a bounded
"sufficient-statistics policy section" (~2 weeks) as a substitute. **This track executes that
substitute first (Phase 1), then — gated on a committee decision — builds the lean version of
the proposal's own microsimulation design (Phases 2–4), with an optional climate-projection
layer (Phase 5).** Each phase is a complete, defensible deliverable even if later phases are
never built.

## Core design (key decisions)

- **Sufficient-statistics, not structural estimation.** Per the proposal's own design
  (pp. 33–37): cells at **rating area × year × FPL bin**; four statistics drive everything —
  (1) claims/cost sensitivity to exposure **β_z**, (2) premium pass-through **ρ** (2SLS,
  exposure-instrumented, HHI-interacted), (3) enrollment elasticity **ε_enroll(y)** by income,
  (4) optional OOP/utilization elasticity. Policy engine: **PTC = b(y) + σ·P̂ + g(z)** with
  subsidy level b(y), slope σ, and a capped geographic climate kicker g(z).
- **Calibrate only to survivors.** β_z inputs come from the robustness-hardened set (drought→
  income; cold dose-response; Medicare morbidity $/beneficiary; premium levels). The 2012
  employment effect and levels-only heterogeneity results do **not** enter. Simulated impacts
  inherit the first-onset **ITT** interpretation; dose counterfactuals use cumulative-dose
  estimates.
- **Pass-through is a scenario band, not a point estimate.** The mediation track
  (`Analysis/mediation/premium_mediation_summary.md`) found county-level pass-through
  incoherent. Estimate ρ at the **rating-area level** (where the price is set); if unstable,
  simulate with ρ ∈ {0, literature (~0.7–1.0), estimated} as sensitivity bands.
- **Medical debt is never a calibration target** (measurement-fragile outcome); it appears
  only in downstream narrative.
- **Uncertainty is a first-class output.** Propagate coefficient SEs through the calculator
  (parametric draws of the elasticity vector); report simulation intervals. Phase 5 adds
  climate-model spread as a second layer.
- **Rating-area price structure respected everywhere** — counties in a rating area share one
  price by construction; premiums are RA draws, never county draws.
- **Accounting identities are unit-tested** (`testthat`): subsidy formula, aggregation,
  welfare arithmetic — identities are testable in a way regressions are not.
- **Proactive methods discipline** (methods-retrospective lesson): estimand labels,
  multiple-testing posture, and uncertainty propagation are designed in from the start, not
  retrofitted.

## Data (all public; no new credentials)

| Input | Source | Status |
|---|---|---|
| Benchmark Silver / Lowest Bronze premiums, RA-mapped, 2014–2026 | in repo (`county_level_master.csv`, HIX pipeline) | in hand |
| Plan-level HIX detail (issuer×plan×county, deductibles, tiers) | `Data/HIX_Data/plan details/*.zip` | in hand, unexploited |
| Issuer participation by county (→ issuer count / HHI) | `Data/HIX_Data/issuer county report/*.csv` | in hand, unused |
| Medicare standardized cost/utilization (claims-cost fallback) | `Data/intermediate_medicare_spending.rds` | in hand |
| SVI, energy burden, SAHIE uninsured, ag/industry moderators | intermediates | in hand |
| RMA indemnities (existing-policy benchmark) | `Data/intermediate_rma_indemnity.rds` | in hand |
| IRS migration flows (population response) | `Data/intermediate_migration.rds` | in hand |
| Medicaid expansion toggle | `Code/medicaid_expansion.R` | in hand |
| **Marketplace enrollment by county × FPL bin** | CMS Marketplace OEP PUFs (2015→, keyless) | **to acquire** |
| **Subsidy rule crosswalk** (applicable % by FPL × year; ARPA/IRA 2021–2025; 2026 expiry) | statute/KFF tables (hand-built lookup) | **to build** |
| **Second-lowest-cost silver by RA** | derivable from plan-level HIX zips | **to derive** |
| **County CMIP6-LOCA2 projections** (27 models × SSP245/370/585, 1950–2100) | USGS ScienceBase (keyless) | **to acquire (Phase 5)** |

## Objectives

1. **Phase 1 (regardless of committee decision):** a §7-style sufficient-statistics policy
   section — national dollar burden from hardened coefficients, benchmarked against RMA
   indemnity flows, plus one geographic-targeting concentration statement (CHEI machinery).
2. **Phases 2–4 (committee-gated):** the lean microsimulation — cells, elasticities, PTC
   engine, counterfactual grid (σ ∈ {0.3, 0.5, 0.7}; targeted b(y); kicker
   g(z) = min{κ·(z−z⁹⁰), ḡ}·1{z>z⁹⁰}; **the 2026 enhanced-PTC expiry** as the
   headline live-policy counterfactual), outputs (coverage, affordability, outlays, logit-CS
   welfare) by income × SVI tercile, efficiency–equity frontiers, California worked
   calibration.
3. **Phase 5 (optional):** projection layer — attach LOCA2 county projections to the response
   functions (Hsiang et al. 2017 damage-function architecture) and re-run the subsidy
   counterfactuals under 2050 exposure with model-spread bands.
4. Throughout: uncertainty propagation, honest estimand labels, self-logging builds, tests.

## Out of scope (documented in `Plans/frontier_extensions_plan.md` §3 Tier 3b–3e / deprioritized)

- Full structural equilibrium model (insurer bidding, plan-choice logit on microdata).
- Employer-sponsored-insurance arm from MEPS-IC (a fourth paper, not an extension).
- Migration-response module (3b), LEAD-strata distributional microsim (3c), hospital-finance
  module (3d), wildfire-smoke retrofit (3e) — post-defense follow-ons unless pulled forward.
- Anything calibrated to credit-bureau medical debt.

## Decision gates

- **Gate A (after Phase 1):** committee decides whether the thesis defends with the policy
  section alone or proceeds to the microsimulation (Phases 2–4). Send/refresh
  `Text/correspondence/committee_memo_ch3_structure.md` with Phase-1 results attached.
- **Gate B (after Phase 4):** proceed to the projection layer (Phase 5) only if timeline
  permits; it is job-market-paper material, not a defense requirement.

## Engineering conventions

- New code under `Code/microsim/`; R 4.2.2 unless a frontier package forces 4.5.3 (state the
  R version in every script header per the two-R-version convention).
- Build runs self-log via `sink()` to `Analysis/microsim/build_logs/*.log`; runs are script
  files, never inline `Rscript -e`.
- Outputs to `Analysis/microsim/`; write-ups NBER-styled (`nber-economist-writing-style`).
- Large raw downloads (OEP PUFs, LOCA2) under `Data/` are not for git; commit scripts +
  intermediates decision docs only.
