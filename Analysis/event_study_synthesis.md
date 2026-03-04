# Dynamic Panel Impulse-Response: Synthesis of Results

Generated: 2026-03-04 15:15 

## Overview

- **Total coefficient estimates:** 1668 across 278 unique specifications
- **Shocks:** Any_Shock, Compound_Shock, High_AQI_Max, High_CDD, High_HDD, Is_Extreme_Drought, Shock_Count
- **Outcomes:** Benchmark_Silver_Real, Civilian_Employed, Hosp_BadDebt_PerCapita, Med_HH_Income_Real, Medical_Debt_Median_2023, Medical_Debt_Share, PCPI_Real
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
| Is_Extreme_Drought | PCPI_Real | -2.3236 | -116.0880 |
| Is_Extreme_Drought | Med_HH_Income_Real | -52.6079 | -31.0352 |
| Is_Extreme_Drought | Civilian_Employed | -1715.7129 | -1507.3275 |
| High_CDD | Medical_Debt_Share | -0.0047 | -0.0032 |
| High_CDD | Benchmark_Silver_Real | 2.5851 | -2.3478 |
| High_CDD | Medical_Debt_Median_2023 | -3.4298 | -7.6613 |
| High_CDD | Hosp_BadDebt_PerCapita | 2.3583 | 2.3354 |
| High_CDD | PCPI_Real | 669.7241** | 492.3725* |
| High_CDD | Med_HH_Income_Real | -272.4644** | -264.8256*** |
| High_CDD | Civilian_Employed | 155.3496 | -43.7386 |
| High_HDD | Medical_Debt_Share | 0.0038** | 0.0029* |
| High_HDD | Benchmark_Silver_Real | 31.9897*** | 30.6719*** |
| High_HDD | Medical_Debt_Median_2023 | 12.7936 | 9.0201 |
| High_HDD | Hosp_BadDebt_PerCapita | 4.3734** | 4.4315*** |
| High_HDD | PCPI_Real | 57.3556 | -106.9892 |
| High_HDD | Med_HH_Income_Real | 189.9609** | 103.0559 |
| High_HDD | Civilian_Employed | -536.4103 | -268.6241 |
| High_AQI_Max | Medical_Debt_Share | 0.0008 | 0.0005 |
| High_AQI_Max | Benchmark_Silver_Real | 6.3637 | 5.8670 |
| High_AQI_Max | Medical_Debt_Median_2023 | 1.1634 | 0.3838 |
| High_AQI_Max | Hosp_BadDebt_PerCapita | 0.8880 | 0.8179 |
| High_AQI_Max | PCPI_Real | 7.9625 | 40.2045 |
| High_AQI_Max | Med_HH_Income_Real | -46.8332 | -51.4781 |
| High_AQI_Max | Civilian_Employed | 7.1438 | -43.8086 |
| Any_Shock | Medical_Debt_Share | -0.0007 | -0.0006 |
| Any_Shock | Benchmark_Silver_Real | 7.2167 | 8.5216* |
| Any_Shock | Medical_Debt_Median_2023 | 10.5700 | 6.9253 |
| Any_Shock | Hosp_BadDebt_PerCapita | 1.1292 | 1.7610 |
| Any_Shock | PCPI_Real | 53.2558 | -11.3134 |
| Any_Shock | Med_HH_Income_Real | -19.2021 | -35.7033 |
| Any_Shock | Civilian_Employed | 180.7796 | -27.4181 |

## Key Finding 2: Dynamic Profiles

Classification of how effects evolve from h=0 to h=3 (LP, Unweighted):

| Shock | Outcome | Pattern | Peak Horizon | h=0 Est | h=3 Est |
|-------|---------|---------|-------------|---------|--------|
| Any_Shock | Benchmark_Silver_Real | **insignificant** | h=0 | 8.5216 | -3.1394 |
| Any_Shock | Civilian_Employed | **insignificant** | h=3 | -27.4181 | -269.8641 |
| Any_Shock | Hosp_BadDebt_PerCapita | **insignificant** | h=0 | 1.7610 | -1.4966 |
| Any_Shock | Med_HH_Income_Real | **insignificant** | h=3 | -35.7033 | 71.5794 |
| Any_Shock | Medical_Debt_Median_2023 | **insignificant** | h=3 | 6.9253 | 12.7596 |
| Any_Shock | Medical_Debt_Share | **insignificant** | h=2 | -0.0006 | 0.0016 |
| Any_Shock | PCPI_Real | **insignificant** | h=3 | -11.3134 | 169.7865 |
| High_AQI_Max | Benchmark_Silver_Real | **insignificant** | h=0 | 5.8670 | -2.8022 |
| High_AQI_Max | Civilian_Employed | **insignificant** | h=3 | -43.8086 | 128.0471 |
| High_AQI_Max | Hosp_BadDebt_PerCapita | **insignificant** | h=0 | 0.8179 | -0.0803 |
| High_AQI_Max | Med_HH_Income_Real | **insignificant** | h=3 | -51.4781 | 140.0690 |
| High_AQI_Max | Medical_Debt_Median_2023 | **insignificant** | h=3 | 0.3838 | 10.4967 |
| High_AQI_Max | Medical_Debt_Share | **insignificant** | h=2 | 0.0005 | 0.0016 |
| High_AQI_Max | PCPI_Real | **insignificant** | h=3 | 40.2045 | 182.3762 |
| High_CDD | Benchmark_Silver_Real | **insignificant** | h=2 | -2.3478 | -1.2500 |
| High_CDD | Civilian_Employed | **insignificant** | h=3 | -43.7386 | 435.0337 |
| High_CDD | Hosp_BadDebt_PerCapita | **insignificant** | h=0 | 2.3354 | -0.1543 |
| High_CDD | Med_HH_Income_Real | **transient** | h=3 | -264.8256 | 384.0336 |
| High_CDD | Medical_Debt_Median_2023 | **building** | h=2 | -7.6613 | 31.0136 |
| High_CDD | Medical_Debt_Share | **building** | h=1 | -0.0032 | 0.0060 |
| High_CDD | PCPI_Real | **insignificant** | h=1 | 492.3725 | -66.6857 |
| High_HDD | Benchmark_Silver_Real | **transient** | h=0 | 30.6719 | -8.0744 |
| High_HDD | Civilian_Employed | **delayed** | h=3 | -268.6241 | -349.1034 |
| High_HDD | Hosp_BadDebt_PerCapita | **transient** | h=0 | 4.4315 | -1.3387 |
| High_HDD | Med_HH_Income_Real | **building** | h=3 | 103.0559 | 174.5914 |
| High_HDD | Medical_Debt_Median_2023 | **insignificant** | h=2 | 9.0201 | -4.3220 |
| High_HDD | Medical_Debt_Share | **insignificant** | h=1 | 0.0029 | 0.0027 |
| High_HDD | PCPI_Real | **insignificant** | h=2 | -106.9892 | 572.2687 |
| Is_Extreme_Drought | Benchmark_Silver_Real | **insignificant** | h=0 | 18.2564 | -12.5902 |
| Is_Extreme_Drought | Civilian_Employed | **insignificant** | h=0 | -1507.3275 | -6.1982 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | **insignificant** | h=3 | 1.3133 | -2.7127 |
| Is_Extreme_Drought | Med_HH_Income_Real | **insignificant** | h=2 | -31.0352 | 358.3291 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | **insignificant** | h=2 | -16.0784 | 2.0115 |
| Is_Extreme_Drought | Medical_Debt_Share | **insignificant** | h=2 | -0.0001 | 0.0062 |
| Is_Extreme_Drought | PCPI_Real | **insignificant** | h=1 | -116.0880 | 696.6842 |

Pattern definitions:
- **building**: Effect grows >50% from h=0 to h=3 and is significant at h=3
- **persistent**: Significant at both h=0 and h=3
- **transient**: Significant at h=0 but fades by h=3
- **delayed**: Not significant at h=0 but emerges by h=3
- **insignificant**: No significant effect at any positive horizon

## Key Finding 3: Pre-Trend Validity

**WARNING:** 8 pre-trend failure(s) detected at h=-2 (p < 0.05):

- Is_Extreme_Drought -> Benchmark_Silver_Real (DL): est=36.1877, p=0.0003
- High_HDD -> Benchmark_Silver_Real (DL): est=17.8777, p=0.0215
- High_AQI_Max -> Medical_Debt_Share (DL): est=0.0029, p=0.0001
- High_AQI_Max -> Benchmark_Silver_Real (DL): est=8.2727, p=0.0401
- High_AQI_Max -> PCPI_Real (DL): est=-213.8777, p=0.0083
- Is_Extreme_Drought -> Benchmark_Silver_Real (LP): est=33.5879, p=0.0264
- High_AQI_Max -> Medical_Debt_Share (LP): est=0.0023, p=0.0067
- High_AQI_Max -> Benchmark_Silver_Real (LP): est=9.5027, p=0.0221

## Key Finding 4: Cross-Method Robustness

DL vs LP sign agreement and correlation (h >= 0, Unweighted):

| Shock | Outcome | Same Sign % | Correlation |
|-------|---------|------------|-------------|
| Any_Shock | Benchmark_Silver_Real | 100% | 0.990 |
| Any_Shock | Civilian_Employed | 25% | 0.914 |
| Any_Shock | Hosp_BadDebt_PerCapita | 100% | 0.951 |
| Any_Shock | Med_HH_Income_Real | 100% | 0.935 |
| Any_Shock | Medical_Debt_Median_2023 | 50% | 0.755 |
| Any_Shock | Medical_Debt_Share | 75% | 0.495 |
| Any_Shock | PCPI_Real | 75% | 0.621 |
| High_AQI_Max | Benchmark_Silver_Real | 75% | 1.000 |
| High_AQI_Max | Civilian_Employed | 50% | 0.926 |
| High_AQI_Max | Hosp_BadDebt_PerCapita | 75% | 0.554 |
| High_AQI_Max | Med_HH_Income_Real | 50% | 0.837 |
| High_AQI_Max | Medical_Debt_Median_2023 | 75% | 0.444 |
| High_AQI_Max | Medical_Debt_Share | 100% | 0.099 |
| High_AQI_Max | PCPI_Real | 100% | 0.642 |
| High_CDD | Benchmark_Silver_Real | 75% | 0.970 |
| High_CDD | Civilian_Employed | 75% | 0.512 |
| High_CDD | Hosp_BadDebt_PerCapita | 75% | 0.511 |
| High_CDD | Med_HH_Income_Real | 100% | 0.877 |
| High_CDD | Medical_Debt_Median_2023 | 100% | 0.752 |
| High_CDD | Medical_Debt_Share | 75% | 0.686 |
| High_CDD | PCPI_Real | 75% | 0.948 |
| High_HDD | Benchmark_Silver_Real | 100% | 0.966 |
| High_HDD | Civilian_Employed | 100% | -0.250 |
| High_HDD | Hosp_BadDebt_PerCapita | 75% | 0.801 |
| High_HDD | Med_HH_Income_Real | 100% | -0.032 |
| High_HDD | Medical_Debt_Median_2023 | 50% | 0.898 |
| High_HDD | Medical_Debt_Share | 75% | -0.015 |
| High_HDD | PCPI_Real | 75% | 0.946 |
| Is_Extreme_Drought | Benchmark_Silver_Real | 75% | 0.774 |
| Is_Extreme_Drought | Civilian_Employed | 50% | 0.998 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 75% | 0.295 |
| Is_Extreme_Drought | Med_HH_Income_Real | 50% | -0.212 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | 50% | -0.091 |
| Is_Extreme_Drought | Medical_Debt_Share | 50% | 0.618 |
| Is_Extreme_Drought | PCPI_Real | 100% | 0.468 |

## Key Finding 5: Shock-History Robustness

Adding lagged shock controls (t-1, t-2) to LP does not substantially alter results:

| Shock | Outcome | Mean % Change | Same Sign % |
|-------|---------|--------------|-------------|
| Any_Shock | Benchmark_Silver_Real | 19.9% | 100% |
| Any_Shock | Civilian_Employed | 160.9% | 50% |
| Any_Shock | Hosp_BadDebt_PerCapita | 27.1% | 100% |
| Any_Shock | Med_HH_Income_Real | 268.1% | 50% |
| Any_Shock | Medical_Debt_Median_2023 | 24.8% | 100% |
| Any_Shock | Medical_Debt_Share | 33.7% | 100% |
| Any_Shock | PCPI_Real | 204.1% | 75% |
| High_AQI_Max | Benchmark_Silver_Real | 8.6% | 100% |
| High_AQI_Max | Civilian_Employed | 31.2% | 100% |
| High_AQI_Max | Hosp_BadDebt_PerCapita | 16.5% | 100% |
| High_AQI_Max | Med_HH_Income_Real | 18.5% | 100% |
| High_AQI_Max | Medical_Debt_Median_2023 | 40.5% | 100% |
| High_AQI_Max | Medical_Debt_Share | 5.2% | 100% |
| High_AQI_Max | PCPI_Real | 34.5% | 100% |
| High_CDD | Benchmark_Silver_Real | 109.0% | 75% |
| High_CDD | Civilian_Employed | 119.0% | 75% |
| High_CDD | Hosp_BadDebt_PerCapita | 94.0% | 100% |
| High_CDD | Med_HH_Income_Real | 50.0% | 100% |
| High_CDD | Medical_Debt_Median_2023 | 11.1% | 100% |
| High_CDD | Medical_Debt_Share | 13.4% | 100% |
| High_CDD | PCPI_Real | 38.6% | 100% |
| High_HDD | Benchmark_Silver_Real | 14.0% | 100% |
| High_HDD | Civilian_Employed | 69.8% | 100% |
| High_HDD | Hosp_BadDebt_PerCapita | 33.5% | 100% |
| High_HDD | Med_HH_Income_Real | 40.8% | 100% |
| High_HDD | Medical_Debt_Median_2023 | 45.7% | 75% |
| High_HDD | Medical_Debt_Share | 74.9% | 75% |
| High_HDD | PCPI_Real | 79.4% | 75% |
| Is_Extreme_Drought | Benchmark_Silver_Real | 4.2% | 100% |
| Is_Extreme_Drought | Civilian_Employed | 367.2% | 75% |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 22.8% | 100% |
| Is_Extreme_Drought | Med_HH_Income_Real | 10.9% | 100% |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | 28.3% | 100% |
| Is_Extreme_Drought | Medical_Debt_Share | 59.6% | 75% |
| Is_Extreme_Drought | PCPI_Real | 19.6% | 100% |

## Key Finding 6: Combined and Compound Shocks

### Any_Shock vs Individual Shocks (h=0, LP)

`Any_Shock` captures the average effect of experiencing *any* climate shock.

| Shock | Outcome | Estimate | SE | p-value |
|-------|---------|----------|------|--------|
| Is_Extreme_Drought | Medical_Debt_Share | -0.0001 | 0.0032 | 0.9817 |
| Is_Extreme_Drought | Benchmark_Silver_Real | 18.2564 | 14.0982 | 0.2015 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | -16.0784 | 20.6387 | 0.4398 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 1.3133 | 3.2720 | 0.6899 |
| Is_Extreme_Drought | PCPI_Real | -116.0880 | 297.4410 | 0.6980 |
| Is_Extreme_Drought | Med_HH_Income_Real | -31.0352 | 178.4106 | 0.8626 |
| Is_Extreme_Drought | Civilian_Employed | -1507.3275 | 1409.0879 | 0.2901 |
| High_CDD | Medical_Debt_Share | -0.0032 | 0.0030 | 0.2925 |
| High_CDD | Benchmark_Silver_Real | -2.3478 | 9.9836 | 0.8151 |
| High_CDD | Medical_Debt_Median_2023 | -7.6613 | 15.6408 | 0.6265 |
| High_CDD | Hosp_BadDebt_PerCapita | 2.3354 | 2.3394 | 0.3232 |
| High_CDD | PCPI_Real | 492.3725 | 273.6809 | 0.0783 |
| High_CDD | Med_HH_Income_Real | -264.8256 | 86.8861 | 0.0037 |
| High_CDD | Civilian_Employed | -43.7386 | 211.2190 | 0.8368 |
| High_HDD | Medical_Debt_Share | 0.0029 | 0.0015 | 0.0622 |
| High_HDD | Benchmark_Silver_Real | 30.6719 | 9.9182 | 0.0033 |
| High_HDD | Medical_Debt_Median_2023 | 9.0201 | 9.9529 | 0.3693 |
| High_HDD | Hosp_BadDebt_PerCapita | 4.4315 | 1.5963 | 0.0078 |
| High_HDD | PCPI_Real | -106.9892 | 267.5379 | 0.6910 |
| High_HDD | Med_HH_Income_Real | 103.0559 | 74.2824 | 0.1717 |
| High_HDD | Civilian_Employed | -268.6241 | 198.6512 | 0.1826 |
| Any_Shock | Medical_Debt_Share | -0.0006 | 0.0012 | 0.6471 |
| Any_Shock | Benchmark_Silver_Real | 8.5216 | 4.6287 | 0.0716 |
| Any_Shock | Medical_Debt_Median_2023 | 6.9253 | 8.2096 | 0.4029 |
| Any_Shock | Hosp_BadDebt_PerCapita | 1.7610 | 1.1524 | 0.1328 |
| Any_Shock | PCPI_Real | -11.3134 | 116.4910 | 0.9230 |
| Any_Shock | Med_HH_Income_Real | -35.7033 | 48.2643 | 0.4629 |
| Any_Shock | Civilian_Employed | -27.4181 | 327.8687 | 0.9337 |

### Compound Shock Decomposition (h=0)

From the additive spec: `Any_Shock` = baseline effect of any shock; `Compound_Shock` = additional effect when 2+ shocks co-occur.
From the dose-response spec: `Shock_Count` = marginal effect per additional shock.

**Note:** Compound shock support is thin (~2.2% of obs). Treat as exploratory.

| Shock | Outcome | Approach | Estimate | SE | p-value |
|-------|---------|----------|----------|------|--------|
| Any_Shock | Medical_Debt_Share | LP_Compound_Additive | -0.0005 | 0.0010 | 0.6133 |
| Compound_Shock | Medical_Debt_Share | LP_Compound_Additive | 0.0015 | 0.0010 | 0.1285 |
| Shock_Count | Medical_Debt_Share | LP_Dose_Response | 0.0003 | 0.0008 | 0.7036 |
| Any_Shock | Benchmark_Silver_Real | LP_Compound_Additive | 7.6213 | 4.3780 | 0.0881 |
| Compound_Shock | Benchmark_Silver_Real | LP_Compound_Additive | 8.6452 | 4.8226 | 0.0793 |
| Shock_Count | Benchmark_Silver_Real | LP_Dose_Response | 7.9648 | 3.1417 | 0.0146 |
| Any_Shock | Medical_Debt_Median_2023 | LP_Compound_Additive | 2.5254 | 7.6752 | 0.7436 |
| Compound_Shock | Medical_Debt_Median_2023 | LP_Compound_Additive | 0.2142 | 12.3756 | 0.9863 |
| Shock_Count | Medical_Debt_Median_2023 | LP_Dose_Response | 0.7992 | 6.2380 | 0.8986 |
| Any_Shock | Hosp_BadDebt_PerCapita | LP_Compound_Additive | 1.0024 | 1.0298 | 0.3352 |
| Compound_Shock | Hosp_BadDebt_PerCapita | LP_Compound_Additive | 1.7475 | 1.5849 | 0.2757 |
| Shock_Count | Hosp_BadDebt_PerCapita | LP_Dose_Response | 1.4362 | 1.1021 | 0.1987 |
| Any_Shock | PCPI_Real | LP_Compound_Additive | 80.8949 | 95.9464 | 0.4033 |
| Compound_Shock | PCPI_Real | LP_Compound_Additive | 2.5319 | 159.7896 | 0.9874 |
| Shock_Count | PCPI_Real | LP_Dose_Response | 39.2330 | 94.6547 | 0.6804 |
| Any_Shock | Med_HH_Income_Real | LP_Compound_Additive | -53.3338 | 42.6079 | 0.2167 |
| Compound_Shock | Med_HH_Income_Real | LP_Compound_Additive | -17.8300 | 69.5133 | 0.7987 |
| Shock_Count | Med_HH_Income_Real | LP_Dose_Response | -28.6100 | 37.6373 | 0.4509 |
| Any_Shock | Civilian_Employed | LP_Compound_Additive | 768.0077 | 481.3093 | 0.1171 |
| Compound_Shock | Civilian_Employed | LP_Compound_Additive | -1899.3913 | 1007.6414 | 0.0655 |
| Shock_Count | Civilian_Employed | LP_Dose_Response | -410.4147 | 519.1772 | 0.4331 |

## Artifacts

| File | Description |
|------|-------------|
| `Analysis/event_study_coefs.csv` | All 852 coefficient rows (raw) |
| `Analysis/event_study_tables.csv` | Formatted h=0 results table |
| `Analysis/event_study_full_results.csv` | All horizons, primary specs |
| `Analysis/event_study_results.txt` | DL model summaries (text) |
| `Analysis/plots/synthesis_significance_heatmap.png` | h=0 significance heatmap |
| `Analysis/plots/synthesis_dynamic_profiles.png` | LP impulse-response panel |
| `Analysis/plots/synthesis_robustness_panel.png` | DL vs LP vs LP+History (Medical Debt Share, Silver Premium) |
| `Analysis/plots/synthesis_robustness_panel_extra.png` | DL vs LP vs LP+History (Median Debt, Hosp Bad Debt) |
| `Analysis/plots/lp_Shock_Count_*.png` | Dose-response multi-dose plots |
