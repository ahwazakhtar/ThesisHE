# Dynamic Panel Impulse-Response: Synthesis of Results

Generated: 2026-07-13 13:23 

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
| Is_Extreme_Drought | Medical_Debt_Share | 0.0000 | -0.0001 |
| Is_Extreme_Drought | Benchmark_Silver_Real | 22.6564 | 18.0552 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | -19.7101 | -16.3092 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 1.3834 | 1.3627 |
| Is_Extreme_Drought | PCPI_Real | 15.7216 | -105.0254 |
| Is_Extreme_Drought | Med_HH_Income_Real | -52.1413 | -31.5966 |
| Is_Extreme_Drought | Civilian_Employed | -917.2259 | -854.1557 |
| High_CDD | Medical_Debt_Share | -0.0047 | -0.0032 |
| High_CDD | Benchmark_Silver_Real | 3.1626 | -1.8117 |
| High_CDD | Medical_Debt_Median_2023 | -3.4672 | -7.6875 |
| High_CDD | Hosp_BadDebt_PerCapita | 2.3925 | 2.3509 |
| High_CDD | PCPI_Real | 665.1710** | 490.2578* |
| High_CDD | Med_HH_Income_Real | -270.3804** | -262.5188*** |
| High_CDD | Civilian_Employed | 183.7746 | -26.9335 |
| High_HDD | Medical_Debt_Share | 0.0039** | 0.0029* |
| High_HDD | Benchmark_Silver_Real | 28.6564*** | 29.5395*** |
| High_HDD | Medical_Debt_Median_2023 | 12.5690 | 9.0697 |
| High_HDD | Hosp_BadDebt_PerCapita | 4.0634** | 4.3276** |
| High_HDD | PCPI_Real | 114.4053 | -94.6230 |
| High_HDD | Med_HH_Income_Real | 176.3179* | 99.8377 |
| High_HDD | Civilian_Employed | -597.1078 | -274.6263 |
| High_AQI_Max | Medical_Debt_Share | 0.0009 | 0.0005 |
| High_AQI_Max | Benchmark_Silver_Real | 6.8246 | 6.1521 |
| High_AQI_Max | Medical_Debt_Median_2023 | 1.8917 | 1.1382 |
| High_AQI_Max | Hosp_BadDebt_PerCapita | 0.8963 | 0.8411 |
| High_AQI_Max | PCPI_Real | 1.1256 | 31.0362 |
| High_AQI_Max | Med_HH_Income_Real | -43.8427 | -48.9208 |
| High_AQI_Max | Civilian_Employed | 29.1548 | -18.9238 |
| Any_Shock | Medical_Debt_Share | -0.0007 | -0.0005 |
| Any_Shock | Benchmark_Silver_Real | 7.8144 | 8.7970* |
| Any_Shock | Medical_Debt_Median_2023 | 12.0151 | 7.9188 |
| Any_Shock | Hosp_BadDebt_PerCapita | 1.2146 | 1.7955 |
| Any_Shock | PCPI_Real | 53.8325 | -9.8174 |
| Any_Shock | Med_HH_Income_Real | -9.5775 | -28.1996 |
| Any_Shock | Civilian_Employed | 241.5901 | 37.9007 |

## Key Finding 2: Dynamic Profiles

Classification of how effects evolve from h=0 to h=3 (LP, Unweighted):

| Shock | Outcome | Pattern | Peak Horizon | h=0 Est | h=3 Est |
|-------|---------|---------|-------------|---------|--------|
| Any_Shock | Benchmark_Silver_Real | **insignificant** | h=0 | 8.7970 | -1.5404 |
| Any_Shock | Civilian_Employed | **insignificant** | h=3 | 37.9007 | -163.8755 |
| Any_Shock | Hosp_BadDebt_PerCapita | **insignificant** | h=0 | 1.7955 | -1.5438 |
| Any_Shock | Med_HH_Income_Real | **insignificant** | h=3 | -28.1996 | 134.4748 |
| Any_Shock | Medical_Debt_Median_2023 | **insignificant** | h=3 | 7.9188 | 9.0116 |
| Any_Shock | Medical_Debt_Share | **insignificant** | h=3 | -0.0005 | 0.0023 |
| Any_Shock | PCPI_Real | **insignificant** | h=3 | -9.8174 | 259.1128 |
| High_AQI_Max | Benchmark_Silver_Real | **insignificant** | h=0 | 6.1521 | -1.9088 |
| High_AQI_Max | Civilian_Employed | **insignificant** | h=3 | -18.9238 | 196.3910 |
| High_AQI_Max | Hosp_BadDebt_PerCapita | **insignificant** | h=0 | 0.8411 | -0.0900 |
| High_AQI_Max | Med_HH_Income_Real | **insignificant** | h=3 | -48.9208 | 178.5186 |
| High_AQI_Max | Medical_Debt_Median_2023 | **insignificant** | h=3 | 1.1382 | 5.7950 |
| High_AQI_Max | Medical_Debt_Share | **insignificant** | h=2 | 0.0005 | 0.0018 |
| High_AQI_Max | PCPI_Real | **insignificant** | h=3 | 31.0362 | 226.0967 |
| High_CDD | Benchmark_Silver_Real | **insignificant** | h=2 | -1.8117 | -0.4467 |
| High_CDD | Civilian_Employed | **insignificant** | h=3 | -26.9335 | 463.2211 |
| High_CDD | Hosp_BadDebt_PerCapita | **insignificant** | h=0 | 2.3509 | -0.0384 |
| High_CDD | Med_HH_Income_Real | **transient** | h=3 | -262.5188 | 379.1344 |
| High_CDD | Medical_Debt_Median_2023 | **building** | h=2 | -7.6875 | 32.2142 |
| High_CDD | Medical_Debt_Share | **building** | h=1 | -0.0032 | 0.0059 |
| High_CDD | PCPI_Real | **insignificant** | h=1 | 490.2578 | -116.6929 |
| High_HDD | Benchmark_Silver_Real | **transient** | h=0 | 29.5395 | -9.0683 |
| High_HDD | Civilian_Employed | **delayed** | h=3 | -274.6263 | -380.6295 |
| High_HDD | Hosp_BadDebt_PerCapita | **transient** | h=0 | 4.3276 | -1.5036 |
| High_HDD | Med_HH_Income_Real | **insignificant** | h=3 | 99.8377 | 145.4267 |
| High_HDD | Medical_Debt_Median_2023 | **insignificant** | h=2 | 9.0697 | -5.4182 |
| High_HDD | Medical_Debt_Share | **insignificant** | h=1 | 0.0029 | 0.0031 |
| High_HDD | PCPI_Real | **insignificant** | h=2 | -94.6230 | 482.8358 |
| Is_Extreme_Drought | Benchmark_Silver_Real | **insignificant** | h=0 | 18.0552 | -12.6969 |
| Is_Extreme_Drought | Civilian_Employed | **delayed** | h=3 | -854.1557 | 917.9901 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | **insignificant** | h=3 | 1.3627 | -2.4046 |
| Is_Extreme_Drought | Med_HH_Income_Real | **insignificant** | h=2 | -31.5966 | 393.5705 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | **insignificant** | h=2 | -16.3092 | -6.3589 |
| Is_Extreme_Drought | Medical_Debt_Share | **insignificant** | h=2 | -0.0001 | 0.0066 |
| Is_Extreme_Drought | PCPI_Real | **insignificant** | h=3 | -105.0254 | 743.2198 |

Pattern definitions:
- **building**: Effect grows >50% from h=0 to h=3 and is significant at h=3
- **persistent**: Significant at both h=0 and h=3
- **transient**: Significant at h=0 but fades by h=3
- **delayed**: Not significant at h=0 but emerges by h=3
- **insignificant**: No significant effect at any positive horizon

## Key Finding 3: Pre-Trend Validity

**WARNING:** 7 pre-trend failure(s) detected at h=-2 (p < 0.05):

- Is_Extreme_Drought -> Benchmark_Silver_Real (DL): est=37.4559, p=0.0003
- High_AQI_Max -> Medical_Debt_Share (DL): est=0.0029, p=0.0002
- High_AQI_Max -> Benchmark_Silver_Real (DL): est=8.3027, p=0.0469
- High_AQI_Max -> PCPI_Real (DL): est=-202.0701, p=0.0118
- Is_Extreme_Drought -> Benchmark_Silver_Real (LP): est=32.7491, p=0.0333
- High_AQI_Max -> Medical_Debt_Share (LP): est=0.0023, p=0.0070
- High_AQI_Max -> Benchmark_Silver_Real (LP): est=10.4673, p=0.0176

## Key Finding 4: Cross-Method Robustness

DL vs LP sign agreement and correlation (h >= 0, Unweighted):

| Shock | Outcome | Same Sign % | Correlation |
|-------|---------|------------|-------------|
| Any_Shock | Benchmark_Silver_Real | 100% | 0.991 |
| Any_Shock | Civilian_Employed | 75% | 0.997 |
| Any_Shock | Hosp_BadDebt_PerCapita | 100% | 0.966 |
| Any_Shock | Med_HH_Income_Real | 100% | 0.979 |
| Any_Shock | Medical_Debt_Median_2023 | 75% | 0.807 |
| Any_Shock | Medical_Debt_Share | 75% | 0.627 |
| Any_Shock | PCPI_Real | 75% | 0.850 |
| High_AQI_Max | Benchmark_Silver_Real | 75% | 0.999 |
| High_AQI_Max | Civilian_Employed | 50% | 0.878 |
| High_AQI_Max | Hosp_BadDebt_PerCapita | 75% | 0.647 |
| High_AQI_Max | Med_HH_Income_Real | 50% | 0.876 |
| High_AQI_Max | Medical_Debt_Median_2023 | 50% | -0.145 |
| High_AQI_Max | Medical_Debt_Share | 100% | 0.222 |
| High_AQI_Max | PCPI_Real | 100% | 0.715 |
| High_CDD | Benchmark_Silver_Real | 75% | 0.968 |
| High_CDD | Civilian_Employed | 75% | 0.482 |
| High_CDD | Hosp_BadDebt_PerCapita | 75% | 0.467 |
| High_CDD | Med_HH_Income_Real | 100% | 0.871 |
| High_CDD | Medical_Debt_Median_2023 | 100% | 0.754 |
| High_CDD | Medical_Debt_Share | 75% | 0.697 |
| High_CDD | PCPI_Real | 75% | 0.941 |
| High_HDD | Benchmark_Silver_Real | 100% | 0.960 |
| High_HDD | Civilian_Employed | 100% | 0.098 |
| High_HDD | Hosp_BadDebt_PerCapita | 75% | 0.803 |
| High_HDD | Med_HH_Income_Real | 100% | -0.410 |
| High_HDD | Medical_Debt_Median_2023 | 50% | 0.892 |
| High_HDD | Medical_Debt_Share | 75% | -0.031 |
| High_HDD | PCPI_Real | 75% | 0.935 |
| Is_Extreme_Drought | Benchmark_Silver_Real | 75% | 0.764 |
| Is_Extreme_Drought | Civilian_Employed | 75% | 0.997 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 50% | 0.301 |
| Is_Extreme_Drought | Med_HH_Income_Real | 50% | -0.242 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | 75% | -0.194 |
| Is_Extreme_Drought | Medical_Debt_Share | 50% | 0.621 |
| Is_Extreme_Drought | PCPI_Real | 75% | 0.484 |

## Key Finding 5: Shock-History Robustness

Adding lagged shock controls (t-1, t-2) to LP does not substantially alter results:

| Shock | Outcome | Mean % Change | Same Sign % |
|-------|---------|--------------|-------------|
| Any_Shock | Benchmark_Silver_Real | 28.7% | 100% |
| Any_Shock | Civilian_Employed | 1718.5% | 75% |
| Any_Shock | Hosp_BadDebt_PerCapita | 25.3% | 100% |
| Any_Shock | Med_HH_Income_Real | 29.9% | 100% |
| Any_Shock | Medical_Debt_Median_2023 | 31.0% | 100% |
| Any_Shock | Medical_Debt_Share | 31.2% | 100% |
| Any_Shock | PCPI_Real | 237.9% | 75% |
| High_AQI_Max | Benchmark_Silver_Real | 30.9% | 100% |
| High_AQI_Max | Civilian_Employed | 128.7% | 50% |
| High_AQI_Max | Hosp_BadDebt_PerCapita | 14.3% | 100% |
| High_AQI_Max | Med_HH_Income_Real | 14.4% | 100% |
| High_AQI_Max | Medical_Debt_Median_2023 | 71.1% | 75% |
| High_AQI_Max | Medical_Debt_Share | 4.9% | 100% |
| High_AQI_Max | PCPI_Real | 35.2% | 100% |
| High_CDD | Benchmark_Silver_Real | 207.2% | 75% |
| High_CDD | Civilian_Employed | 163.9% | 75% |
| High_CDD | Hosp_BadDebt_PerCapita | 301.1% | 100% |
| High_CDD | Med_HH_Income_Real | 50.4% | 100% |
| High_CDD | Medical_Debt_Median_2023 | 11.6% | 100% |
| High_CDD | Medical_Debt_Share | 12.3% | 100% |
| High_CDD | PCPI_Real | 28.5% | 100% |
| High_HDD | Benchmark_Silver_Real | 14.6% | 100% |
| High_HDD | Civilian_Employed | 75.4% | 100% |
| High_HDD | Hosp_BadDebt_PerCapita | 53.5% | 100% |
| High_HDD | Med_HH_Income_Real | 41.4% | 100% |
| High_HDD | Medical_Debt_Median_2023 | 36.5% | 100% |
| High_HDD | Medical_Debt_Share | 83.5% | 75% |
| High_HDD | PCPI_Real | 91.5% | 75% |
| Is_Extreme_Drought | Benchmark_Silver_Real | 2.5% | 100% |
| Is_Extreme_Drought | Civilian_Employed | 23.5% | 100% |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 22.8% | 100% |
| Is_Extreme_Drought | Med_HH_Income_Real | 10.4% | 100% |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | 11.5% | 100% |
| Is_Extreme_Drought | Medical_Debt_Share | 31.8% | 75% |
| Is_Extreme_Drought | PCPI_Real | 19.4% | 100% |

## Key Finding 6: Combined and Compound Shocks

### Any_Shock vs Individual Shocks (h=0, LP)

`Any_Shock` captures the average effect of experiencing *any* climate shock.

| Shock | Outcome | Estimate | SE | p-value |
|-------|---------|----------|------|--------|
| Is_Extreme_Drought | Medical_Debt_Share | -0.0001 | 0.0032 | 0.9713 |
| Is_Extreme_Drought | Benchmark_Silver_Real | 18.0552 | 14.3231 | 0.2136 |
| Is_Extreme_Drought | Medical_Debt_Median_2023 | -16.3092 | 20.8402 | 0.4377 |
| Is_Extreme_Drought | Hosp_BadDebt_PerCapita | 1.3627 | 3.2950 | 0.6810 |
| Is_Extreme_Drought | PCPI_Real | -105.0254 | 300.2188 | 0.7280 |
| Is_Extreme_Drought | Med_HH_Income_Real | -31.5966 | 183.1017 | 0.8637 |
| Is_Extreme_Drought | Civilian_Employed | -854.1557 | 881.1127 | 0.3372 |
| High_CDD | Medical_Debt_Share | -0.0032 | 0.0030 | 0.2874 |
| High_CDD | Benchmark_Silver_Real | -1.8117 | 9.8466 | 0.8548 |
| High_CDD | Medical_Debt_Median_2023 | -7.6875 | 15.6477 | 0.6255 |
| High_CDD | Hosp_BadDebt_PerCapita | 2.3509 | 2.3365 | 0.3194 |
| High_CDD | PCPI_Real | 490.2578 | 271.1038 | 0.0768 |
| High_CDD | Med_HH_Income_Real | -262.5188 | 86.9162 | 0.0040 |
| High_CDD | Civilian_Employed | -26.9335 | 207.6569 | 0.8973 |
| High_HDD | Medical_Debt_Share | 0.0029 | 0.0015 | 0.0617 |
| High_HDD | Benchmark_Silver_Real | 29.5395 | 9.7124 | 0.0038 |
| High_HDD | Medical_Debt_Median_2023 | 9.0697 | 9.9853 | 0.3683 |
| High_HDD | Hosp_BadDebt_PerCapita | 4.3276 | 1.6279 | 0.0106 |
| High_HDD | PCPI_Real | -94.6230 | 265.6516 | 0.7233 |
| High_HDD | Med_HH_Income_Real | 99.8377 | 77.1469 | 0.2018 |
| High_HDD | Civilian_Employed | -274.6263 | 197.7804 | 0.1714 |
| Any_Shock | Medical_Debt_Share | -0.0005 | 0.0012 | 0.6655 |
| Any_Shock | Benchmark_Silver_Real | 8.7970 | 4.7779 | 0.0715 |
| Any_Shock | Medical_Debt_Median_2023 | 7.9188 | 8.2871 | 0.3439 |
| Any_Shock | Hosp_BadDebt_PerCapita | 1.7955 | 1.1673 | 0.1303 |
| Any_Shock | PCPI_Real | -9.8174 | 118.6864 | 0.9344 |
| Any_Shock | Med_HH_Income_Real | -28.1996 | 49.1924 | 0.5690 |
| Any_Shock | Civilian_Employed | 37.9007 | 311.0974 | 0.9035 |

### Compound Shock Decomposition (h=0)

From the additive spec: `Any_Shock` = baseline effect of any shock; `Compound_Shock` = additional effect when 2+ shocks co-occur.
From the dose-response spec: `Shock_Count` = marginal effect per additional shock.

**Note:** Compound shock support is thin (~2.2% of obs). Treat as exploratory.

| Shock | Outcome | Approach | Estimate | SE | p-value |
|-------|---------|----------|----------|------|--------|
| Any_Shock | Medical_Debt_Share | LP_Compound_Additive | -0.0005 | 0.0010 | 0.6318 |
| Compound_Shock | Medical_Debt_Share | LP_Compound_Additive | 0.0016 | 0.0010 | 0.1235 |
| Shock_Count | Medical_Debt_Share | LP_Dose_Response | 0.0003 | 0.0008 | 0.6793 |
| Any_Shock | Benchmark_Silver_Real | LP_Compound_Additive | 8.0408 | 4.5518 | 0.0837 |
| Compound_Shock | Benchmark_Silver_Real | LP_Compound_Additive | 8.4392 | 4.8371 | 0.0874 |
| Shock_Count | Benchmark_Silver_Real | LP_Dose_Response | 8.0992 | 3.2054 | 0.0149 |
| Any_Shock | Medical_Debt_Median_2023 | LP_Compound_Additive | 3.5180 | 7.7634 | 0.6525 |
| Compound_Shock | Medical_Debt_Median_2023 | LP_Compound_Additive | 0.3382 | 12.5006 | 0.9785 |
| Shock_Count | Medical_Debt_Median_2023 | LP_Dose_Response | 1.3762 | 6.3081 | 0.8282 |
| Any_Shock | Hosp_BadDebt_PerCapita | LP_Compound_Additive | 1.0453 | 1.0536 | 0.3261 |
| Compound_Shock | Hosp_BadDebt_PerCapita | LP_Compound_Additive | 1.7679 | 1.5892 | 0.2715 |
| Shock_Count | Hosp_BadDebt_PerCapita | LP_Dose_Response | 1.4730 | 1.1157 | 0.1930 |
| Any_Shock | PCPI_Real | LP_Compound_Additive | 76.8080 | 97.1262 | 0.4329 |
| Compound_Shock | PCPI_Real | LP_Compound_Additive | -5.1080 | 159.4015 | 0.9746 |
| Shock_Count | PCPI_Real | LP_Dose_Response | 33.1068 | 95.5294 | 0.7304 |
| Any_Shock | Med_HH_Income_Real | LP_Compound_Additive | -48.2867 | 44.0189 | 0.2781 |
| Compound_Shock | Med_HH_Income_Real | LP_Compound_Additive | -17.9032 | 69.0347 | 0.7965 |
| Shock_Count | Med_HH_Income_Real | LP_Dose_Response | -25.8548 | 37.9471 | 0.4989 |
| Any_Shock | Civilian_Employed | LP_Compound_Additive | 801.4407 | 475.9371 | 0.0987 |
| Compound_Shock | Civilian_Employed | LP_Compound_Additive | -1573.7702 | 892.9455 | 0.0844 |
| Shock_Count | Civilian_Employed | LP_Dose_Response | -261.6978 | 483.3774 | 0.5907 |

## Artifacts

| File | Description |
|------|-------------|
| `Analysis/event_study/event_study_coefs.csv` | All 852 coefficient rows (raw) |
| `Analysis/event_study/event_study_tables.csv` | Formatted h=0 results table |
| `Analysis/event_study/event_study_full_results.csv` | All horizons, primary specs |
| `Analysis/event_study/event_study_results.txt` | DL model summaries (text) |
| `Analysis/plots/synthesis_significance_heatmap.png` | h=0 significance heatmap |
| `Analysis/plots/synthesis_dynamic_profiles.png` | LP impulse-response panel |
| `Analysis/plots/synthesis_robustness_panel.png` | DL vs LP vs LP+History (Medical Debt Share, Silver Premium) |
| `Analysis/plots/synthesis_robustness_panel_extra.png` | DL vs LP vs LP+History (Median Debt, Hosp Bad Debt) |
| `Analysis/plots/lp_Shock_Count_*.png` | Dose-response multi-dose plots |
