# Knowledge: Econometric Design Decisions

Read this before writing or modifying any estimation script, and before promoting a new
specification to a "finding." These are settled decisions with reasons — do not re-derive
them from scratch, and do not silently deviate.

## Standing estimation conventions

- All FE models use `fixest::feols` (never `plm`/`sandwich` in production; `plm` appears
  only inside tests as a cross-check).
- County regressions cluster at the **state** level (nests rating areas and matches the
  level of the climate shocks).
- Moderators are **structural/baseline** (e.g., 2015 ag typology, baseline SVI) — never a
  contemporaneous outcome like current farm income; that's a bad control.
- Reusable helpers: `Code/transition_symmetry.R::lincom()` (linear-combination Wald tests)
  and `Code/cumulative_dose.R` (cumulative shock-years) — used across delta, dose, and
  exposure scripts. Check them before writing new machinery.

## Specification decisions (with reasons)

- **Drought block pruning:** primary county specs use PDSI only (`drought_vars_primary`:
  pdsi_val + Lag1/Lag2) — PDSI/PHDI/PMDI are near-collinear and inflate VIF. The full
  9-variable block survives as `drought_vars_robust_full` for robustness. VIF via auxiliary
  OLS on the within-transformed predictor matrix; logged to
  `Analysis/county/county_vif_diagnostics.txt` (post-pruning max ≈ 5.33).
- **Rating-area structure:** counties in one rating area share premiums by construction.
  Primary clustering is state; premium outcomes also get `*_RA_Cluster` variants in
  `run_county_analysis.R`. Median rating area = 4 counties; 33.5% are 1-to-1.
- **ACA premium regressions — two binding design rules** (from the T1.1 mediation work):
  (a) *rate-filing timing*: plan-year-t rates are locked mid-t-1 on experience through
  ~t-2 → use **lagged shocks only** (t-2 primary); a contemporaneous shock is not in the
  insurer's information set. (b) *level of analysis*: premiums are a rating-area/state
  object (~86% of premium variance is state×year) — county+Year-FE premium specs are
  confounded, and State×Year FE **over-absorbs** (legal statewide pass-through lives in the
  deleted cell), so "collapses under State×Year FE" is NOT evidence of confounding. Estimate
  at rating-area×year (primary, within-state) and state×year (secondary, between-state);
  county premium specs are a labeled transparency trail. Cluster on state, not RA.
  **Verdict: no coherent pass-through** (signs flip across levels); 92–99% of the
  shock→debt effect survives premium adjustment.
- **Event-study design:** `run_event_study.R` is a dynamic panel impulse-response (DL + LP),
  NOT canonical staggered adoption — treatment recurs (counties enter/exit shock status).
  5 shocks (`Is_Extreme_Drought`, `High_CDD`, `High_HDD`, `High_AQI_Max`, `Any_Shock`) +
  compound specs.

## Interpretation rules

- **Medical debt is the measurement-fragile outcome.** Credit-bureau debt requires
  insurance + billed encounters + a credit file, so poor/uninsured (high-SVI) areas accrue
  less *measured* debt. Its EJ direction is aggregation-sensitive (amplifies at state
  level, reverses at county level). Income/employment/premium outcomes are consistent
  across levels — lead EJ claims with those.
- **`effect_bottom/effect_overall` ratios are unstable** when the overall effect ≈ 0 —
  read significance and sign, not the raw ratio.
- **Mechanism verdict (settled Jul 2026):** agriculture is *one* channel, not *the*
  channel. Lead with (1) the Medicare morbidity/utilization channel (heat/cold/AQI raise
  standardized spending & ED visits; non-agricultural; reproduces Deryugina et al. 2019
  in-panel) and (2) broad labor exposure (cold→employment survives in the bottom ag
  tercile; heat→employment loads on `ClimateExposed_NonFarm_Share`). Energy burden is a
  distinct distributional channel (r = 0.11 with SVI). The drought effect is event-specific
  (2012) and partly population selection (drought→out-migration, p = 0.05).
  Full verdict: `Analysis/mechanism/mechanism_verdict.md`.

## DiD (2012 drought cohort) — settled facts

- **The estimand is ITT**: the 2012 cohort is in extreme drought only ~13% of its
  post-2012 county-years, so the ATT is "effect of first drought onset," not "effect of
  being droughted." The "2012 Midwest drought" label is a misnomer — the extreme-PDSI
  cohort is GA (45 counties) + Mountain West + Plains.
- **Income is the robust result** (−$1,311 unconditional; DRDID −$1,451; p_wcb 0.036,
  p_ri 0.0075; 1990–2011 BEA pre-trends flat). **Employment is fragile** (DR attenuates
  ~58%; pooled CS-dr reverses to null/positive with positive pre-trends) — lead with
  income, caveat employment. The 2012 effect is event-specific, not the effect of a
  typical drought cohort.
- **HonestDiD needs ≥1 testable pre-period** — the 2012 cohort has none (panel starts
  2011 = its e=−1), so HonestDiD runs only on the pooled multi-cohort CS event-study
  (already null); it cannot vindicate the 2012 experiment. Influence-function vcov from
  `did::aggte` must be scaled **1/n²** (`t(inf)%*%inf/n^2`), not 1/n.
- **`boottest` chokes on FE-heavy models** — never run it with thousands of absorbed FEs.
  FWL it: `fixest::demean` both y and the treatment, bootstrap the 1-regressor residual
  model (point estimate and cluster structure preserved).
- **`DRDID::drdid` needs a numeric `idname`** (`as.integer(factor(fips_code))`).

## Before promoting a new spec to a finding — checklist

Distilled from review catches that materially changed results (the premium pass-through
correction, the 484 duplicate rows, the ≤2023 filter, a significance cherry-pick):

1. Is the outcome estimated at the level the institution sets it (premiums → rating
   area/state; debt → household/county)?
2. Are FEs absorbing the variation the effect must travel through (over-absorption)?
3. Is any moderator/control a contemporaneous outcome (bad control)?
4. Is the panel unique on its unit×time key? (`stopifnot` it.)
5. Do sample filters match the data's actual span (no silent year truncation)?
6. Is clustering at the shock level, not the convenient level?
7. Any subsample effect: is the denominator the subsample mean, not the full-sample mean?
8. Would the sign/magnitude survive the project's own adjacent results (e.g., a premium
   response mis-signed vs the Medicare morbidity result is suspect)?

## Lessons from the Jul-13 code-quality remediation (audit-hardened; commits 034e156–2e22c11)

- **Two implementations of "the same" estimator → the one with proper influence-function
  covariance governs; quarantine the other, never average.** The manual CS event-time
  aggregation (`run_did_analysis.R`, cohort-size weights, independence SEs) said drought
  e=0 = −$1,050 "p=0.002"; the frontier `did::att_gt` DR estimator says −$324 (SE 276),
  null. Cohort-time cells share never-treated controls — independence SEs are always too
  small. Headline inference must cite `Analysis/did/robustness/dr_csdid_*` only.
- **A null can headline only once bounded** (MDE 2.80×SE + TOST δ*=|β|+1.645×SE against a
  substantive benchmark). The verdict may be hazard-split — state it per hazard; never
  generalize a tight bound from one hazard to the family (drought STRONG, heat/cold soft).
- **Bad-control sensitivity = same-sample triple** (no controls / lagged / contemporaneous,
  identical N asserted). Distinguish control-fragility from SAMPLE-fragility: the county
  debt cells lose significance because requiring controls to be *observed* changes the
  sample, not because conditioning absorbs the pathway. Different caveat, different fix.
- **Dose/exposure-history results are within-county descriptive contrasts**, not marginal
  effects of exogenously assigned shock-years (B6); state clustering primary for premium
  claims, RA clustering sensitivity-only — never select significance on RA SEs (B5).
- **Trust only the truthful test runner** (`Code/tests/testthat.R`, clean process per file,
  nonzero on failure, self-tested). The pre-fix runner was false-green (exit 0 with 36
  errors). Reproduction is certified in `Analysis/reproduction_certificate.md` (masters
  rebuild byte-identically; 32/32 suites; 13/13 headline rows match the evidence table).
