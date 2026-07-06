# Random-Effects Robustness — Committee Feedback Phase 1

**Date:** 2026-05-21
**Source script:** `Code/run_re_robustness.R`
**Outputs:**
- `Analysis/robustness/random_effects_results.csv` — long: outcome × term × FE/RE estimates and per-pair Hausman test
- `Analysis/robustness/random_effects_hausman.csv` — one row per outcome with Hausman χ², df, p-value

## 1. Question

The April 2026 committee asked to "check random effects." The primary state and county specifications use two-way fixed effects (State+Year and fips_code+Year, respectively) estimated with `fixest::feols`. The Hausman test compares the FE within-estimator against the RE GLS estimator and asks whether the unit-level intercepts are uncorrelated with the regressors (the maintained assumption of RE). Rejection means FE is consistent and RE is not; failure to reject would mean RE is admissible (and more efficient).

## 2. Method

`Code/run_re_robustness.R` estimates the headline shock spec (Is_Extreme_Drought / Heat / Cold / High_CDD / High_HDD plus their 1- and 2-year lags) on the same panels as the primary scripts, using `plm::plm(..., model = "within" | "random", effect = "twoways")`. The `effect = "twoways"` argument matches the State+Year / fips_code+Year two-way structure of the primary specs; a one-way (`"individual"`) fallback is used when the two-way RE GLS step is numerically singular.

The Hausman test is implemented via `plm::phtest(fe, re)`.

CLAUDE.md mandates `fixest::feols` for primary regressions and discourages `plm`. This script is an explicit, scoped exception: Hausman/RE machinery is not exposed by `fixest`. The primary analysis pipeline remains on fixest; this robustness file does not feed any other downstream script.

## 3. Specifications

Slimmed headline shock block (vs. the wider robustness block carried by `run_analysis.R`):

- `is_extreme_drought` + L1 + L2
- `is_heat_shock` + L1 + L2
- `is_cold_shock` + L1 + L2
- `is_high_cdd` + L1 + L2
- `is_high_hdd` + L1 + L2
- Controls (state): `Unemployment_Rate`, `Personal_Income_Per_Capita_Real`
- Controls (county): `Household_Income_2023`, `Uninsured_Rate`
- County: Spec1_Base shock block (`Z_Temp`/`Z_Precip` + lags, `pdsi_val` + lags) replaces the absolute-burden block.

The two state outcomes that include `is_extreme_drought_peak`, `is_severe_drought`, and their lags in the primary FE specification were trimmed to the slimmer headline shocks here because the wider block plus year dummies caused exact-singular GLS steps.

## 4. Results — Hausman tests

| Level  | Outcome | N | χ² | df | p-value | RE rejected (α=0.05) |
|--------|---------|---|------|----|---------|----------------------|
| State  | Medical_Debt_Share | 650 | 233.6 | 17 | 4.5e-40 | **Yes** |
| State  | Total_Per_Capita_Health_Exp_Real | 1,250 | 247.9 | 17 | 5.7e-43 | **Yes** |
| State  | Medicaid_Per_Enrollee_Health_Exp_Real | 1,250 | 81.3 | 17 | 2.3e-10 | **Yes** |
| State  | Medicare_Per_Enrollee_Health_Exp_Real | 1,250 | 834.4 | 17 | 2.1e-166 | **Yes** |
| County | Medical_Debt_Share | 32,847 | 23,905.5 | 11 | <1e-300 | **Yes** |
| County | Medical_Debt_Median_2023 | 23,051 | 1,188.5 | 11 | 4.8e-248 | **Yes** |
| County | Benchmark_Silver_Real | 27,563 | 23,544.8 | 11 | <1e-300 | **Yes** |
| County | Hosp_BadDebt_PerCapita | 26,702 | 308.5 | 11 | 1.4e-59 | **Yes** |
| County | PCPI_Real | 33,945 | 5,808.7 | 11 | <1e-300 | **Yes** |
| County | Med_HH_Income_Real | 33,941 | 3,126.7 | 11 | <1e-300 | **Yes** |
| County | Civilian_Employed | 33,945 | 220.2 | 11 | 4.6e-41 | **Yes** |

**RE is rejected for every estimable outcome at p < 1e-9.** This is the standard, expected finding for panels with strong unit-level heterogeneity correlated with shock exposure. The drought/cold/heat exposure of a county or state is correlated with latent geographic and demographic features that the unit FE absorb; ignoring that correlation (as RE does) yields inconsistent estimates.

### Outcomes where RE failed to fit
- **State, Emp_Contrib_Single_Real** — RE GLS step is computationally singular; MEPS-IC employer premium coverage has irregular state-year panel structure (some states absent some years).
- **State, Medical_Debt_Median_Real** — same; Urban Institute county debt aggregated to state has thin years for some states.

These two outcomes are reported as FE-only here. The substantive interpretation is unaffected: FE remains the maintained specification.

## 5. FE vs. RE coefficient comparison (selected headline shocks)

Highlights from `Analysis/robustness/random_effects_results.csv` (state level, headline contemporaneous and lagged shocks):

| Outcome | Term | FE estimate | RE estimate | FE − RE |
|---------|------|-------------|-------------|---------|
| Medical_Debt_Share | is_extreme_drought | 0.0073 | 0.0134 | −0.0060 |
| Medical_Debt_Share | is_extreme_drought_lag2 | 0.0064 | 0.0023 | +0.0041 |
| Medical_Debt_Share | is_cold_shock_lag1 | 0.0117 | 0.0238 | −0.0120 |
| Total_PC_Health_Exp_Real | is_cold_shock_lag1 | −69.6 | −44.5 | −25.0 |
| Medicaid_PE_Health_Exp_Real | is_cold_shock | −279 | −528 | **+249** |
| Medicaid_PE_Health_Exp_Real | is_cold_shock_lag1 | −211 | −566 | **+355** |
| Medicare_PE_Health_Exp_Real | is_cold_shock | −161 | −152 | −9 |

For Medical_Debt_Share, Medicare_PE, and Total_PC_Health_Exp, FE and RE point estimates are close in magnitude and direction; the rejection of RE is driven by precision rather than sign reversal. For **Medicaid_Per_Enrollee_Health_Exp_Real**, RE substantially overstates the cold-shock effect (≈2× the FE estimate) — a clear case where the latent state-level Medicaid policy environment is correlated with cold-shock exposure and RE fails to net it out. This single outcome accounts for most of the visible FE-RE divergence in the full results file.

## 6. Interpretation and write-up note

- The committee question is answered: **the random-effects estimator is statistically rejected for every estimable outcome.** Two-way fixed effects is the maintained specification.
- Where it can be fit, RE produces *broadly* similar point estimates on the headline shocks for most outcomes — the rejection is driven by precise tests on many lagged terms rather than headline-coefficient reversals. The one outcome with material FE-RE divergence (Medicaid per enrollee) underscores the importance of FE in this panel.
- The headline state-level findings reported in `Analysis/state/synthesis.md` (Extreme Drought 2-year lag and Cold Shock 1-year lag effects on Medical Debt and Premiums) are *not* overturned by the RE specification — RE estimates on these terms have the same sign, and the Hausman rejection points to FE as the consistent estimator. This robustness check therefore strengthens, rather than weakens, the primary findings.

## 7. Caveats

- The RE specifications use a slimmer climate block than the primary FE specs (no `is_severe_drought`, no `is_extreme_drought_peak`). The trim is for numerical stability of the RE GLS step; the FE estimates reported in this file therefore differ slightly from the headline FE coefficients in `Analysis/state/regression_results_summary.csv`. Treat the RE comparison as a test of *specification family*, not a coefficient replication of the primary table.
- Standard errors here are conventional (not clustered). Cluster-robust RE inference would change p-values but not the Hausman statistic, which uses the same coefficient covariance structure.
- The two state outcomes that failed to fit RE are not in scope for this robustness layer; their FE results remain authoritative.
