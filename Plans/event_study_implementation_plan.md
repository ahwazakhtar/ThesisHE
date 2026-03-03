# Plan: Event Study Models for County-Level Climate Shocks

## Context

Phase 1 (Data Integration & Baseline Refinement) is complete. The county master panel has ~3,155 counties over 2011–2023 with binary shock indicators, outcomes, and controls. The existing `run_county_analysis.R` estimates static two-way FE models with distributed lags (0,1,2). This plan adds two complementary event study approaches that visualize the full dynamic response trajectory and test for pre-trends — standard requirements for a climate-economics thesis.

## Approach

Create a single new script `Code/run_event_study.R` implementing both methods side by side:

- **Approach A — Dynamic Distributed Lag**: Single regression per shock × outcome with leads and lags as separate regressors. Reference period h=−1 omitted. Produces coefficient plots via ggplot2.
- **Approach B — Local Projections (Jordà 2005)**: Separate regression per horizon h × shock × outcome. More robust to dynamic misspecification. Standard in climate-econ literature (Dell, Jones & Olken 2012).

Both share the same event window: h = {−2, −1, 0, +1, +2, +3}.

## Shocks, Outcomes, Controls

| Element | Variables |
|---|---|
| Shocks | `Is_Extreme_Drought`, `High_CDD`, `High_HDD` |
| Primary outcomes | `Medical_Debt_Share`, `Benchmark_Silver_Real` |
| Secondary outcomes | `Medical_Debt_Median_2023`, `Hosp_BadDebt_PerCapita` |
| Controls | `Household_Income_2023`, `Uninsured_Rate` |
| FE | `fips_code + Year` |
| Clustering | State (+ `rating_area_id` for premium outcomes) |

## Implementation Steps

### Step 1: Script skeleton and data prep
- Create `Code/run_event_study.R`
- Load master CSV, copy `safe_feols()` pattern from `run_county_analysis.R`
- Apply CO 2023 debt exclusion (same `debt_reporting_policy` logic)
- Compute `Hosp_BadDebt_PerCapita = Hosp_BadDebt_Total_Real / Population`
- Define config vectors: shocks, outcomes, controls, `h_min = -2`, `h_max = 3`

### Step 2: Lead/lag construction (in-script, not in pipeline)
- Sort by `fips_code`, `Year`, grouped by `fips_code`
- For each shock: create `{shock}_Lead1`, `{shock}_Lead2` (via `dplyr::lead()`), `{shock}_Lag3` (via `dplyr::lag()`). Existing `_Lag1`, `_Lag2` columns reused from master.
- For local projections: create `{outcome}_fwd{h}` = `lead(outcome, h)` for h=0..3, and `{outcome}_bwd{h}` = `lag(outcome, h)` for h=1,2. All grouped by `fips_code`.
- Print diagnostic: non-NA count per constructed column to document boundary losses.

### Step 3: Approach A — Dynamic Distributed Lag
For each (shock, outcome):
- Formula: `outcome ~ shock_Lead2 + shock + shock_Lag1 + shock_Lag2 + shock_Lag3 + controls | fips_code + Year`
  - `shock_Lead1` omitted (reference = h=−1)
  - 5 estimated coefficients for h = {−2, 0, +1, +2, +3}, plus reference zero at h=−1
- Run unweighted + population-weighted via `safe_feols()`
- For `Benchmark_Silver_Real`: also run with `cluster = ~rating_area_id`
- Extract coefficients into tidy data frame: `shock, outcome, horizon, estimate, std.error, p.value, ci_low, ci_high, N, approach, weighting`
- Insert reference row (h=−1, estimate=0, SE=0) manually

### Step 4: Approach B — Local Projections
For each (shock, outcome, h) where h ∈ {−2, −1, 0, +1, +2, +3}:
- Dependent variable:
  - h ≥ 0: `{outcome}_fwd{h}` (outcome shifted forward by h years)
  - h < 0: `{outcome}_bwd{|h|}` (outcome shifted backward by |h| years)
- Formula: `outcome_shifted ~ shock + controls | fips_code + Year`
  - `shock` is always contemporaneous (time t) binary indicator
- Run unweighted + weighted, extract coefficient on `shock`
- Collect into same tidy format, tagged `approach = "LP"`

### Step 5: Visualization
- **Per-approach plots** (ggplot2): one per shock × outcome
  - x = horizon, y = estimate, `geom_pointrange()` for 95% CI
  - Dashed zero line, dotted vertical line at h=−0.5 marking pre/post boundary
  - Save: `Analysis/plots/es_{shock}_{outcome}.png` (Approach A), `Analysis/plots/lp_{shock}_{outcome}.png` (Approach B)
- **Comparison overlay plots** for primary outcomes only (6 plots):
  - Both approaches on same axes, different colors
  - Save: `Analysis/plots/es_comparison_{shock}_{outcome}.png`

### Step 6: Export
- `Analysis/event_study_coefs.csv` — all coefficients from both approaches
- `Analysis/event_study_results.txt` — full Approach A model summaries (sink'd)
- Sample diagnostics per model: N, counties, states, year range

### Step 7: Tests
- Create `Code/tests/test_run_event_study.R` (testthat)
- Test lead/lag correctness on synthetic 3-county, 6-year panel
- Test reference period row is present with estimate=0 for Approach A
- Test LP horizon alignment (h=2 → outcome is 2 years forward)
- Test formula construction omits exactly Lead1

### Step 8: Update plan.md
- Mark event study task complete with commit SHA

## Key Design Decisions

1. **Leads/lags constructed in-script**, not added to `process_county_climate.R` or the master CSV. They're only needed for this analysis.
2. **Window h = −2 to +3**: With 13-year panel, effective estimation window for Approach A is 2014–2021 (8 years interior). Each LP horizon loses |h| years independently. Adequate for ~3,000 counties.
3. **Both weighted and unweighted** variants, matching existing `run_county_analysis.R` pattern.
4. **Panel contiguity check**: Must verify no year gaps per county before lead/lag construction, or fill with `tidyr::complete()`.

## Files to Create/Modify

| File | Action |
|---|---|
| `Code/run_event_study.R` | **Create** — main event study script |
| `Code/tests/test_run_event_study.R` | **Create** — testthat tests |
| `conductor/tracks/.../plan.md` | **Edit** — update task status |

## Verification

1. Run `Rscript Code/tests/test_run_event_study.R` — all tests pass
2. Run `Rscript Code/run_event_study.R` — completes without error
3. Check `Analysis/event_study_coefs.csv` — has rows for all 3 shocks × 4 outcomes × 6 horizons × 2 approaches
4. Check `Analysis/plots/` — es_*, lp_*, es_comparison_* PNGs exist
5. Visual check: pre-trend coefficients (h=−2, −1) should be near zero / insignificant; post-shock coefficients should show pattern consistent with existing distributed lag results
