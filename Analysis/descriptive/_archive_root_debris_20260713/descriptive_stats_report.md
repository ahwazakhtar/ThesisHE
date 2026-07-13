# Descriptive Statistics Report: County-Level Panel

**Generated:** 2026-07-13
**Panel:** 3,225 U.S. counties, 2011-2023 (41,863 county-year observations)
**Script:** `Code/run_descriptive_stats.R`
**Input data:** `Data/county_level_master.csv`

---

## 1. Sample Construction and Coverage

- Balanced county identifiers: 3,225 counties observed between 2011 and 2023.
- Analysis uses unbalanced outcome coverage where source data are not universal (AQI monitors, HIX, and hospital filings).
- Core climate series (temperature, precipitation, drought) are near-complete with low missingness.
- For debt outcomes, applied reporting-rule exclusion window(s): CO 2023 (60 county-year observations removed from debt variables).

Main output tables:
- `Analysis/descriptive/descriptive_stats_summary.csv`: numeric table with tails, winsorized moments, and weighted moments.
- `Analysis/descriptive/descriptive_stats_table_main.csv`: manuscript-ready condensed table.
- `Analysis/descriptive/descriptive_stats_table_main.tex`: LaTeX table for manuscript integration.
- `Analysis/descriptive/descriptive_period_comparison.csv`: early vs late period changes.
- `Analysis/descriptive/descriptive_period_comparison.tex`: LaTeX period-comparison table.
- `Analysis/descriptive/descriptive_tables.tex`: compile-ready LaTeX document with both descriptive tables.
- `Analysis/descriptive/descriptive_missingness_by_year.csv`: annual missingness diagnostics.
- `Analysis/descriptive/descriptive_correlation_matrix.csv`: pairwise correlation matrix for core variables.

---

## 2. Climate Shock Prevalence

Average prevalence over 2011-2023:
- Extreme Cold (High HDD): county-share average 17.4%, population-weighted average 6.8%.
- Extreme Drought (PDSI <= -4): county-share average 2.3%, population-weighted average 4.5%.
- Extreme Heat (High CDD): county-share average 24.3%, population-weighted average 27.5%.

Interpretation:
- Extreme heat is materially more common than extreme drought at the county-year level.
- Population-weighted prevalence differs from county-share prevalence, indicating non-random exposure by county size.

---

## 3. Health and Economic Outcomes: Early vs Late Period

- Benchmark Silver premium: $286 (2011-2016 mean) to $409 (2017-2023 mean), change 43.2% unweighted.
- Medical debt share: 0.22 to 0.162, change -26.2%.
- Uninsured rate: 0.141 to 0.099, change -29.5%.
- Per capita personal income (real): $50,279 to $55,602, change 10.6%.

Interpretation:
- Real income growth is strong in the late period, while insurance and debt outcomes move on different trajectories.
- These descriptive differences motivate panel fixed-effects models with lag structures and differential exposure measures.

---

## 4. Missing-Data Diagnostics

Highest-missing variables in the study sample:
- Median Medical Debt (2023 USD): 36.4%
- Benchmark Silver Premium (2023 USD): 26.7%
- Lowest Bronze Premium (2023 USD): 26.7%
- Hospital Bad Debt (2023 USD): 24.9%
- Hospital Charity Care (2023 USD): 24.9%

Implications for econometric work:
- AQI, premium, and hospital variables require unbalanced-panel inference and sensitivity checks.
- Population-weighted and unweighted specifications should both be reported where feasible.

---

## 5. Figures for Manuscript Use

- `Analysis/plots/fig1_climate_shock_prevalence.png`
- `Analysis/plots/fig2_outcome_index_trends.png`
- `Analysis/plots/fig3_distribution_shift.png`

Legacy compatibility outputs retained:
- `Analysis/plots/ts_climate_shocks.png`
- `Analysis/plots/ts_outcomes.png`
- `Analysis/plots/ts_income.png`
