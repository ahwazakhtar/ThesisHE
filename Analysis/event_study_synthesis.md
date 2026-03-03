# Dynamic Panel Impulse-Response: Synthesis of Results

Generated: 2026-03-03 14:17 

## Overview

- **Total coefficient estimates:** 852 across 142 unique specifications
- **Shocks:** Any_Shock, Compound_Shock, High_CDD, High_HDD, Is_Extreme_Drought, Shock_Count
- **Outcomes:** Benchmark_Silver_Real, Hosp_BadDebt_PerCapita, Medical_Debt_Median_2023, Medical_Debt_Share
- **Approaches:** DL, DL_RA_Cluster, LP, LP_Compound_Additive, LP_Compound_Additive_RA, LP_Dose_Response, LP_Dose_Response_RA, LP_RA_Cluster, LP_ShockHistory
- **Horizon window:** h = {-2, -1 (ref), 0, +1, +2, +3}
- **Fixed effects:** County (fips_code) + Year
- **Clustering:** State-level (primary), Rating-area (premium robustness)

## Key Finding 1: Contemporaneous Effects (h=0)

| Shock | Outcome | DL Estimate | LP Estimate |
|-------|---------|-------------|-------------|
| Is_Extreme_Drought | Medical_Debt_Share | 0.0001 | -0.0001 |
| Is_Extreme_Drought | Benchmark_Silver_Real | 22.7261 | 18.2564 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | -18.6573 | -16.0784 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 1.3237 | 1.3133 |
| High_CDD | Medical_Debt_Share | 0.0002 | 0.0004 |
| High_CDD | Benchmark_Silver_Real | -0.3121 | 0.4991 |
| High_CDD | Medical_Debt_Median_2023 | 0.0681 | -1.0225 |
| High_CDD | Hosp_BadDebt_PerCapita | 0.4392 | 0.5690 |
| High_HDD | Medical_Debt_Share | 0.0024 | 0.0013 |
| High_HDD | Benchmark_Silver_Real | 42.8996*** | 41.7414** |
| High_HDD | Medical_Debt_Median_2023 | -10.2388 | -2.0654 |
| High_HDD | Hosp_BadDebt_PerCapita | 1.4675 | 0.4011 |
| Any_Shock | Medical_Debt_Share | 0.0014 | 0.0012 |
| Any_Shock | Benchmark_Silver_Real | 9.6927 | 11.2409 |
| Any_Shock | Medical_Debt_Median_2023 | -0.6604 | -0.4190 |
| Any_Shock | Hosp_BadDebt_PerCapita | 0.5852 | 0.5532 |

## Key Finding 2: Dynamic Profiles

Classification of how effects evolve from h=0 to h=3 (LP, Unweighted):

| Shock | Outcome | Pattern | Peak Horizon | h=0 Est | h=3 Est |
|-------|---------|---------|-------------|---------|--------|
| Any_Shock | Benchmark_Silver_Real | **insignificant** | h=0 | 11.2409 | -3.0135 |
| Any_Shock | Hosp_BadDebt_PerCapita | **insignificant** | h=2 | 0.5532 | 0.8336 |
| Any_Shock | Medical_Debt_Median_2023 | **insignificant** | h=2 | -0.4190 | 10.2989 |
| Any_Shock | Medical_Debt_Share | **building** | h=2 | 0.0012 | 0.0039 |
| High_CDD | Benchmark_Silver_Real | **insignificant** | h=3 | 0.4991 | -3.8722 |
| High_CDD | Hosp_BadDebt_PerCapita | **insignificant** | h=3 | 0.5690 | -1.6771 |
| High_CDD | Medical_Debt_Median_2023 | **insignificant** | h=2 | -1.0225 | 20.4573 |
| High_CDD | Medical_Debt_Share | **insignificant** | h=2 | 0.0004 | 0.0023 |
| High_HDD | Benchmark_Silver_Real | **transient** | h=0 | 41.7414 | 0.5585 |
| High_HDD | Hosp_BadDebt_PerCapita | **building** | h=3 | 0.4011 | 4.8987 |
| High_HDD | Medical_Debt_Median_2023 | **insignificant** | h=3 | -2.0654 | -11.8413 |
| High_HDD | Medical_Debt_Share | **building** | h=3 | 0.0013 | 0.0046 |
| Is_Extreme_Drought | Benchmark_Silver_Real | **insignificant** | h=0 | 18.2564 | -12.5902 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | **insignificant** | h=3 | 1.3133 | -2.7127 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | **insignificant** | h=2 | -16.0784 | 2.0115 |
| Is_Extreme_Drought | Medical_Debt_Share | **insignificant** | h=2 | -0.0001 | 0.0062 |

Pattern definitions:
- **building**: Effect grows >50% from h=0 to h=3 and is significant at h=3
- **persistent**: Significant at both h=0 and h=3
- **transient**: Significant at h=0 but fades by h=3
- **delayed**: Not significant at h=0 but emerges by h=3
- **insignificant**: No significant effect at any positive horizon

## Key Finding 3: Pre-Trend Validity

**WARNING:** 2 pre-trend failure(s) detected at h=-2 (p < 0.05):

- Is_Extreme_Drought -> Benchmark_Silver_Real (DL): est=36.1877, p=0.0003
- Is_Extreme_Drought -> Benchmark_Silver_Real (LP): est=33.5879, p=0.0264

## Key Finding 4: Cross-Method Robustness

DL vs LP sign agreement and correlation (h >= 0, Unweighted):

| Shock | Outcome | Same Sign % | Correlation |
|-------|---------|------------|-------------|
| Any_Shock | Benchmark_Silver_Real | 100% | 0.983 |
| Any_Shock | Hosp_BadDebt_PerCapita | 100% | 0.963 |
| Any_Shock | Medical_Debt_Median_2023 | 75% | 0.645 |
| Any_Shock | Medical_Debt_Share | 50% | -0.355 |
| High_CDD | Benchmark_Silver_Real | 50% | 0.966 |
| High_CDD | Hosp_BadDebt_PerCapita | 75% | 0.806 |
| High_CDD | Medical_Debt_Median_2023 | 50% | 0.835 |
| High_CDD | Medical_Debt_Share | 25% | -0.524 |
| High_HDD | Benchmark_Silver_Real | 100% | 0.999 |
| High_HDD | Hosp_BadDebt_PerCapita | 100% | 0.864 |
| High_HDD | Medical_Debt_Median_2023 | 75% | 0.525 |
| High_HDD | Medical_Debt_Share | 100% | 0.981 |
| Is_Extreme_Drought | Benchmark_Silver_Real | 75% | 0.774 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 75% | 0.295 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | 50% | -0.091 |
| Is_Extreme_Drought | Medical_Debt_Share | 50% | 0.618 |

## Key Finding 5: Shock-History Robustness

Adding lagged shock controls (t-1, t-2) to LP does not substantially alter results:

| Shock | Outcome | Mean % Change | Same Sign % |
|-------|---------|--------------|-------------|
| Any_Shock | Benchmark_Silver_Real | 5.7% | 100% |
| Any_Shock | Hosp_BadDebt_PerCapita | 31.5% | 75% |
| Any_Shock | Medical_Debt_Median_2023 | 6.9% | 100% |
| Any_Shock | Medical_Debt_Share | 3.6% | 100% |
| High_CDD | Benchmark_Silver_Real | 12.7% | 100% |
| High_CDD | Hosp_BadDebt_PerCapita | 5.5% | 100% |
| High_CDD | Medical_Debt_Median_2023 | 6.4% | 100% |
| High_CDD | Medical_Debt_Share | 11.6% | 100% |
| High_HDD | Benchmark_Silver_Real | 11.4% | 100% |
| High_HDD | Hosp_BadDebt_PerCapita | 40.7% | 100% |
| High_HDD | Medical_Debt_Median_2023 | 166.3% | 75% |
| High_HDD | Medical_Debt_Share | 128.3% | 100% |
| Is_Extreme_Drought | Benchmark_Silver_Real | 4.2% | 100% |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 22.8% | 100% |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | 28.3% | 100% |
| Is_Extreme_Drought | Medical_Debt_Share | 59.6% | 75% |

## Key Finding 6: Combined and Compound Shocks

### Any_Shock vs Individual Shocks (h=0, LP)

`Any_Shock` captures the average effect of experiencing *any* climate shock.

| Shock | Outcome | Estimate | SE | p-value |
|-------|---------|----------|------|--------|
| Is_Extreme_Drought | Medical_Debt_Share | -0.0001 | 0.0032 | 0.9817 |
| Is_Extreme_Drought | Benchmark_Silver_Real | 18.2564 | 14.0982 | 0.2015 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | -16.0784 | 20.6387 | 0.4398 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 1.3133 | 3.2720 | 0.6899 |
| High_CDD | Medical_Debt_Share | 0.0004 | 0.0015 | 0.8056 |
| High_CDD | Benchmark_Silver_Real | 0.4991 | 8.0518 | 0.9508 |
| High_CDD | Medical_Debt_Median_2023 | -1.0225 | 9.1315 | 0.9113 |
| High_CDD | Hosp_BadDebt_PerCapita | 0.5690 | 1.1602 | 0.6261 |
| High_HDD | Medical_Debt_Share | 0.0013 | 0.0026 | 0.6265 |
| High_HDD | Benchmark_Silver_Real | 41.7414 | 15.6768 | 0.0106 |
| High_HDD | Medical_Debt_Median_2023 | -2.0654 | 16.1800 | 0.8990 |
| High_HDD | Hosp_BadDebt_PerCapita | 0.4011 | 1.5681 | 0.7992 |
| Any_Shock | Medical_Debt_Share | 0.0012 | 0.0016 | 0.4546 |
| Any_Shock | Benchmark_Silver_Real | 11.2409 | 8.9767 | 0.2167 |
| Any_Shock | Medical_Debt_Median_2023 | -0.4190 | 9.7920 | 0.9661 |
| Any_Shock | Hosp_BadDebt_PerCapita | 0.5532 | 1.1977 | 0.6463 |

### Compound Shock Decomposition (h=0)

From the additive spec: `Any_Shock` = baseline effect of any shock; `Compound_Shock` = additional effect when 2+ shocks co-occur.
From the dose-response spec: `Shock_Count` = marginal effect per additional shock.

**Note:** Compound shock support is thin (~2.2% of obs). Treat as exploratory.

| Shock | Outcome | Approach | Estimate | SE | p-value |
|-------|---------|----------|----------|------|--------|
| Any_Shock | Medical_Debt_Share | LP_Compound_Additive | 0.0014 | 0.0016 | 0.3613 |
| Compound_Shock | Medical_Debt_Share | LP_Compound_Additive | -0.0043 | 0.0027 | 0.1189 |
| Shock_Count | Medical_Debt_Share | LP_Dose_Response | 0.0006 | 0.0015 | 0.6718 |
| Any_Shock | Benchmark_Silver_Real | LP_Compound_Additive | 9.0894 | 8.9416 | 0.3146 |
| Compound_Shock | Benchmark_Silver_Real | LP_Compound_Additive | 33.6092 | 13.7478 | 0.0183 |
| Shock_Count | Benchmark_Silver_Real | LP_Dose_Response | 12.6161 | 7.6757 | 0.1069 |
| Any_Shock | Medical_Debt_Median_2023 | LP_Compound_Additive | 0.8168 | 9.4967 | 0.9318 |
| Compound_Shock | Medical_Debt_Median_2023 | LP_Compound_Additive | -26.5273 | 16.7451 | 0.1199 |
| Shock_Count | Medical_Debt_Median_2023 | LP_Dose_Response | -2.1433 | 9.1298 | 0.8154 |
| Any_Shock | Hosp_BadDebt_PerCapita | LP_Compound_Additive | 0.4748 | 1.2172 | 0.6982 |
| Compound_Shock | Hosp_BadDebt_PerCapita | LP_Compound_Additive | 1.4523 | 2.0519 | 0.4826 |
| Shock_Count | Hosp_BadDebt_PerCapita | LP_Dose_Response | 0.6097 | 1.0187 | 0.5524 |

## Artifacts

| File | Description |
|------|-------------|
| `Analysis/event_study_coefs.csv` | All 852 coefficient rows (raw) |
| `Analysis/event_study_tables.csv` | Formatted h=0 results table |
| `Analysis/event_study_full_results.csv` | All horizons, primary specs |
| `Analysis/event_study_results.txt` | DL model summaries (text) |
| `Analysis/plots/synthesis_significance_heatmap.png` | h=0 significance heatmap |
| `Analysis/plots/synthesis_dynamic_profiles.png` | LP impulse-response panel |
| `Analysis/plots/synthesis_robustness_panel.png` | DL vs LP vs LP+History |
| `Analysis/plots/lp_Shock_Count_*.png` | Dose-response multi-dose plots |
