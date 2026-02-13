# Structured Review of Analysis Plans

This review evaluates `state_analysis_plan.md` and `county_level_analysis_plan.md` with reference to `GEMINI.md` and `Analysis/econometric_review.md`. It focuses on scope, data construction, identification, econometric robustness, and execution risks from a PhD-level economics perspective.

## Executive Summary

1. The plans are ambitious and methodologically plausible, but the scope is too broad relative to the identification strength. Pre-specifying primary outcomes and exposures is essential to reduce multiple-testing risk.
2. Time coverage is overstated in several places. The actual sample will vary substantially by outcome (HIX premiums, medical debt, hospital data), which must be documented explicitly.
3. Climate shock definitions rely on full-sample means and quintiles, which can introduce look-ahead bias and conflate trend with shock. A fixed baseline period or rolling baseline is needed.
4. Inference is fragile with 50 state clusters. Standard clustered SEs are likely understated; small-sample corrections or wild cluster bootstrap should be routine.
5. The MAUP concerns in `Analysis/econometric_review.md` are real. County-level premium regressions cannot claim county-level variation in treatment; inference must respect rating-area or state-level treatment granularity.

## 1. Scope and Research Design

1. The project bundles multiple exposures (drought, heat, cold, CDD/HDD, precipitation) and multiple outcomes (premiums, medical debt share/median, hospital bad debt, NHE spending). This creates a large hypothesis space. A PhD examiner will expect a clear hierarchy of primary vs secondary outcomes and exposures.
2. The framing mixes causal and descriptive language. If causal claims are intended, the estimand must be stated explicitly, and the identification assumptions must be defensible. Otherwise, the language should be descriptive or associational.
3. The state plan implies national scope (1996-2025). The county plan implies 2011-2025. These dates are inconsistent with the observed data sources. The plan should include outcome-specific windows and justify any truncation.

## 2. Data Coverage and Sample Consistency

1. HIX premiums do not exist prior to 2014 (and vary by state in early years). Claims of 2011-2025 coverage for premium outcomes are not accurate.
2. Medical debt data from Urban Institute starts later than 2011 and is pre-adjusted to 2023 dollars. The plan correctly notes this, but it must explicitly constrain the sample to available years.
3. Hospital cost data ends in 2023. The crosswalk used for ZIP to county mapping ends in 2023. Any analysis after 2023 should either exclude this outcome or justify extrapolation.
4. MEPS-IC and CMS NHE series have specific endpoints. If they are used in state-level analysis, the panel is necessarily unbalanced unless the period is truncated.
5. The plan should include a short table of outcome-specific sample windows and a description of how the unbalanced panel is handled (drop years, impute, or allow unbalanced FE).

## 3. Variable Construction and Measurement

### 3.1 Climate Shocks and Baselines

1. Z-scores and quintiles appear to be computed using full-sample means and distributions. This risks look-ahead bias and obscures structural climate change trends.
2. Recommended fix: use a fixed baseline period (e.g., 1996-2010 or 1981-2010 NOAA normals) to define means and variances. Alternatively, use rolling or expanding windows and report sensitivity.
3. Drought bins (PDSI thresholds) are standard, but robustness to threshold choice should be documented.
4. The rationale for a Z-score threshold of 1.5 should be justified or tested against alternative cutoffs (1.0, 2.0).

### 3.2 Inflation and Real Dollar Consistency

1. Medical debt is in 2023 dollars. All other dollar outcomes must be converted using CPI_2023 / CPI_t. This is correctly stated but should be treated as a non-negotiable requirement.
2. The plan should explicitly document the CPI series used and the exact deflation formula in the script header.

### 3.3 Mapping and Aggregation

1. Rating Area to county is a broadcast. This creates artificial precision and inflates effective sample size. This is acknowledged in `Analysis/econometric_review.md` and must be repeated explicitly in the plan.
2. ZIP to county mapping using residential ratios is standard, but the crosswalk is time-varying. The plan should verify that the crosswalk year matches the hospital data year and state clearly how missing ZIPs are handled.
3. State-level drought applied to counties is valid for estimating state-level exposure impacts, but county-level FE with state-level treatment can induce large within-state correlation in errors, reinforcing the need for state clustering.

## 4. Identification and Causal Threats

### 4.1 Core Identification Assumption

1. The fixed-effects design assumes that, conditional on state/county FE and year FE, climate shocks are exogenous to unobserved drivers of health finance outcomes. This is plausible but not guaranteed.
2. Time-varying confounders such as industry composition shifts, migration, and policy responses can correlate with drought exposure. These should be discussed explicitly as potential sources of bias.

### 4.2 Controls and Post-Treatment Bias

1. Controls like income and unemployment may be affected by climate shocks. Including them can block part of the total effect and bias estimates toward zero.
2. Recommendation: estimate models both with and without these controls and interpret them as different estimands (total vs direct effects).

### 4.3 Dynamic Effects and Lag Structure

1. The 0-2 year lag window is reasonable but may be too short for medical debt or long-term premium adjustments.
2. Recommendation: test extended lag structures (0-4) or use distributed-lag smoothing (Almon or spline). Report cumulative effects.

### 4.4 Parallel Trends and Placebo Tests

1. The use of "parallel trends" language is not well-suited to continuous climate exposure. A better diagnostic is to include leads of climate shocks as placebo tests.
2. Recommendation: add 1-2 year leads for each exposure and report if coefficients are close to zero.

## 5. Inference and Standard Errors

1. With state-level treatment and only 50 clusters, conventional cluster-robust SEs are biased downward.
2. Recommendation: use CR2 or CRV3 corrections, or wild cluster bootstrap p-values, as a standard robustness check.
3. County-level outcomes with rating-area premiums may warrant two-way clustering (state and rating area), depending on software support.
4. Spatial correlation is likely in county outcomes. Consider Conley or spatial HAC as a robustness check if feasible.

## 6. State-Level Plan Specific Comments

1. The state-level analysis asserts significant effects for drought and cold shocks. These results should be presented cautiously as conditional associations unless stronger identification is demonstrated.
2. The plan does not mention state-specific trends or region-year FE. These can help address slowly evolving state-level confounders. At minimum, report sensitivity to including state trends.
3. The plan references DiD for policy interactions (e.g., Medicaid expansion). If these are pursued, the policy timing and treatment definition must be spelled out and pre-trends tested.

## 7. County-Level Plan Specific Comments

1. The two-specification strategy (shock vs burden) is appropriate and should remain separate unless multicollinearity is demonstrably low.
2. The rating-area robustness check is strong and should be treated as a primary validity check for premium results.
3. The plan should clarify whether county-level climate shocks are centered relative to each county’s own baseline. If so, cross-county comparability of coefficient magnitudes can be limited; discuss interpretation.
4. Outcomes such as medical debt share are bounded. Consider logit or fractional response as a robustness check, or at least verify that linear models do not predict outside bounds.

## 8. Multiple Hypothesis Testing and Pre-Specification

1. The number of outcomes and exposures makes false positives likely.
2. Recommendation: define a primary outcome and primary exposure for each level, and apply FDR or Bonferroni-style adjustments as sensitivity checks.

## 9. Practical Execution Risks

1. Unbalanced panels: ensure that `fixest` or `plm` settings handle missingness correctly. Report the number of observations by outcome and by model.
2. Crosswalk consistency: if ZIP or rating areas change across years, ensure that year-specific crosswalks are applied and document how changes are reconciled.
3. Inflation conversion: verify that CPI series is consistently applied across all scripts and outcomes.
4. Documentation: the plan should include a data provenance table or appendix with source, URL, access date, and transformations.

## 10. Recommended Additions to the Plans

1. Add an explicit section on estimands and identification assumptions.
2. Add a table of outcome-specific sample windows.
3. Add a short section on inference strategy (cluster corrections, bootstrap).
4. Add a robustness checklist, including lead tests, alternative thresholds, continuous exposures, and alternative baseline definitions.
5. Add a multiple-testing guardrail (pre-specified primary outcomes or FDR).

## Priority Actions (Ordered)

1. Document outcome-specific sample windows and align all claims with actual availability.
2. Replace full-sample Z-score/quintile baselines with fixed or rolling baselines.
3. Add small-sample robust inference for state clustering and report as standard.
4. Pre-specify primary outcomes and exposures to reduce multiple testing concerns.
5. Add placebo leads and extended lag sensitivity.

## Notes on `Analysis/econometric_review.md`

1. The MAUP warning is correct and should be echoed explicitly in the county plan narrative.
2. State-level clustering is non-negotiable for drought and rating-area premiums. The plan should treat county-level clustering as invalid for these outcomes.
3. The separation of shock vs burden specifications is appropriate and should not be relaxed without explicit collinearity diagnostics.
