# State-Level Regression Results
**Generated:** 2026-03-09 12:24:03
**Input:** Data/analysis_ready_dataset.csv
**Model:** Two-way FE (State + Year), cluster = State, `fixest::feols`

Significance: \*p<0.10, \*\*p<0.05, \*\*\*p<0.01

---

## Outcome: `Emp_Contrib_Single_Real`

#### Primary FE (State + Year)
**N =** 650 | **Within-R² =** 0.1095 | **Cluster =** State

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| is_extreme_drought | 63.5750** | 31.2590 | 2.034 | 0.0474 |
| is_extreme_drought_lag1 | -25.4189 | 31.1215 | -0.817 | 0.4180 |
| is_extreme_drought_lag2 | -16.7412 | 51.9554 | -0.322 | 0.7487 |
| is_severe_drought | 86.4065*** | 30.0370 | 2.877 | 0.0059 |
| is_severe_drought_lag1 | 65.1362** | 24.8487 | 2.621 | 0.0116 |
| is_severe_drought_lag2 | -9.6751 | 23.5352 | -0.411 | 0.6828 |
| is_heat_shock | -19.4610 | 22.4673 | -0.866 | 0.3906 |
| is_heat_shock_lag1 | -13.3279 | 21.8358 | -0.610 | 0.5444 |
| is_heat_shock_lag2 | -19.9019 | 21.2711 | -0.936 | 0.3541 |
| is_cold_shock | -26.6327 | 37.0886 | -0.718 | 0.4761 |
| is_cold_shock_lag1 | -75.4262* | 39.7811 | -1.896 | 0.0639 |
| is_cold_shock_lag2 | -39.2372 | 39.5509 | -0.992 | 0.3260 |
| is_high_cdd | -1.4394 | 32.2196 | -0.045 | 0.9645 |
| is_high_cdd_lag1 | 6.6169 | 20.0580 | 0.330 | 0.7429 |
| is_high_cdd_lag2 | -4.6966 | 26.2275 | -0.179 | 0.8586 |
| is_high_hdd | 48.7937 | 32.4618 | 1.503 | 0.1392 |
| is_high_hdd_lag1 | 36.2725 | 22.3516 | 1.623 | 0.1110 |
| is_high_hdd_lag2 | 22.0088 | 23.0195 | 0.956 | 0.3437 |
| AQI_Median_Wtd | 1.0647 | 2.2310 | 0.477 | 0.6353 |
| AQI_Median_Wtd_lag1 | -4.4947* | 2.5314 | -1.776 | 0.0820 |
| AQI_Median_Wtd_lag2 | -3.2569 | 4.4496 | -0.732 | 0.4677 |
| AQI_Max_State | 0.0036 | 0.0069 | 0.517 | 0.6074 |
| AQI_Max_State_lag1 | 0.0044 | 0.0049 | 0.909 | 0.3680 |
| AQI_Max_State_lag2 | 0.0016 | 0.0061 | 0.263 | 0.7940 |
| Pct_PM25_State | 20.8032*** | 5.8369 | 3.564 | 0.0008 |
| Pct_PM25_State_lag1 | -9.7241 | 7.3445 | -1.324 | 0.1916 |
| Pct_PM25_State_lag2 | -6.7736 | 6.3014 | -1.075 | 0.2877 |
| Pct_PM10_State | 22.6789*** | 6.8392 | 3.316 | 0.0017 |
| Pct_PM10_State_lag1 | -12.2879 | 9.4004 | -1.307 | 0.1973 |
| Pct_PM10_State_lag2 | -10.2990 | 8.1435 | -1.265 | 0.2120 |
| Pct_Ozone_State | 19.7211*** | 6.1457 | 3.209 | 0.0024 |
| Pct_Ozone_State_lag1 | -7.3261 | 7.4511 | -0.983 | 0.3303 |
| Pct_Ozone_State_lag2 | -8.1235 | 6.5410 | -1.242 | 0.2202 |
| Pct_CO_State | 24.9356** | 10.4473 | 2.387 | 0.0209 |
| Pct_CO_State_lag1 | -30.5791* | 18.1569 | -1.684 | 0.0985 |
| Pct_CO_State_lag2 | -2.7218 | 17.4718 | -0.156 | 0.8768 |
| Pct_Unhealthy_State | -4.1955 | 22.0089 | -0.191 | 0.8496 |
| Pct_Unhealthy_State_lag1 | 66.5246*** | 16.8606 | 3.946 | 0.0003 |
| Pct_Unhealthy_State_lag2 | 17.9250 | 16.9898 | 1.055 | 0.2966 |
| Unemployment_Rate | 0.1611 | 9.1878 | 0.018 | 0.9861 |
| Personal_Income_Per_Capita_Real | -0.0026 | 0.0046 | -0.569 | 0.5720 |

---

## Outcome: `Medical_Debt_Share`

#### Primary FE (State + Year)
**N =** 650 | **Within-R² =** 0.0922 | **Cluster =** State

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| is_extreme_drought | 0.0082 | 0.0052 | 1.569 | 0.1230 |
| is_extreme_drought_lag1 | 0.0033 | 0.0070 | 0.475 | 0.6367 |
| is_extreme_drought_lag2 | 0.0072 | 0.0053 | 1.364 | 0.1789 |
| is_severe_drought | -0.0030 | 0.0040 | -0.748 | 0.4582 |
| is_severe_drought_lag1 | -0.0038 | 0.0042 | -0.905 | 0.3699 |
| is_severe_drought_lag2 | -0.0013 | 0.0047 | -0.269 | 0.7892 |
| is_heat_shock | 0.0029 | 0.0025 | 1.125 | 0.2662 |
| is_heat_shock_lag1 | 0.0032 | 0.0020 | 1.617 | 0.1124 |
| is_heat_shock_lag2 | 0.0028 | 0.0028 | 0.999 | 0.3225 |
| is_cold_shock | 0.0075 | 0.0063 | 1.197 | 0.2370 |
| is_cold_shock_lag1 | 0.0135** | 0.0052 | 2.623 | 0.0116 |
| is_cold_shock_lag2 | 0.0061 | 0.0042 | 1.448 | 0.1541 |
| is_high_cdd | 0.0052 | 0.0044 | 1.182 | 0.2428 |
| is_high_cdd_lag1 | -0.0030 | 0.0044 | -0.672 | 0.5050 |
| is_high_cdd_lag2 | -0.0050* | 0.0026 | -1.902 | 0.0630 |
| is_high_hdd | -0.0030 | 0.0049 | -0.606 | 0.5474 |
| is_high_hdd_lag1 | 0.0034 | 0.0055 | 0.609 | 0.5451 |
| is_high_hdd_lag2 | 0.0020 | 0.0057 | 0.343 | 0.7333 |
| AQI_Median_Wtd | -0.0001 | 0.0004 | -0.375 | 0.7090 |
| AQI_Median_Wtd_lag1 | -0.0002 | 0.0004 | -0.418 | 0.6777 |
| AQI_Median_Wtd_lag2 | 0.0000 | 0.0004 | 0.048 | 0.9622 |
| AQI_Max_State | 0.0000 | 0.0000 | 0.305 | 0.7615 |
| AQI_Max_State_lag1 | 0.0000** | 0.0000 | 2.393 | 0.0206 |
| AQI_Max_State_lag2 | 0.0000* | 0.0000 | 1.846 | 0.0709 |
| Pct_PM25_State | 0.0000 | 0.0009 | 0.026 | 0.9796 |
| Pct_PM25_State_lag1 | 0.0004 | 0.0005 | 0.713 | 0.4794 |
| Pct_PM25_State_lag2 | 0.0010 | 0.0008 | 1.300 | 0.1997 |
| Pct_PM10_State | -0.0004 | 0.0011 | -0.339 | 0.7360 |
| Pct_PM10_State_lag1 | 0.0010 | 0.0008 | 1.229 | 0.2251 |
| Pct_PM10_State_lag2 | 0.0011 | 0.0011 | 0.996 | 0.3240 |
| Pct_Ozone_State | -0.0002 | 0.0009 | -0.211 | 0.8339 |
| Pct_Ozone_State_lag1 | 0.0004 | 0.0005 | 0.755 | 0.4539 |
| Pct_Ozone_State_lag2 | 0.0007 | 0.0008 | 0.993 | 0.3255 |
| Pct_CO_State | -0.0023 | 0.0017 | -1.354 | 0.1820 |
| Pct_CO_State_lag1 | 0.0020 | 0.0022 | 0.892 | 0.3767 |
| Pct_CO_State_lag2 | 0.0036 | 0.0032 | 1.130 | 0.2640 |
| Pct_Unhealthy_State | -0.0004 | 0.0032 | -0.121 | 0.9043 |
| Pct_Unhealthy_State_lag1 | -0.0025 | 0.0034 | -0.720 | 0.4750 |
| Pct_Unhealthy_State_lag2 | 0.0008 | 0.0034 | 0.243 | 0.8088 |
| Unemployment_Rate | 0.0033* | 0.0017 | 1.884 | 0.0655 |
| Personal_Income_Per_Capita_Real | 0.0000 | 0.0000 | 1.285 | 0.2050 |

---

## Outcome: `Medical_Debt_Median_Real`

#### Primary FE (State + Year)
**N =** 649 | **Within-R² =** 0.1549 | **Cluster =** State

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| is_extreme_drought | -14.6946 | 33.4890 | -0.439 | 0.6627 |
| is_extreme_drought_lag1 | -27.7392 | 31.3392 | -0.885 | 0.3804 |
| is_extreme_drought_lag2 | 41.8379 | 46.2963 | 0.904 | 0.3706 |
| is_severe_drought | -66.7921*** | 19.1083 | -3.495 | 0.0010 |
| is_severe_drought_lag1 | -37.4872** | 17.9655 | -2.087 | 0.0421 |
| is_severe_drought_lag2 | -61.7662** | 30.3658 | -2.034 | 0.0474 |
| is_heat_shock | 32.7072* | 18.0642 | 1.811 | 0.0763 |
| is_heat_shock_lag1 | 29.5388* | 15.4689 | 1.910 | 0.0621 |
| is_heat_shock_lag2 | 47.7466** | 23.0065 | 2.075 | 0.0432 |
| is_cold_shock | -13.0044 | 37.4712 | -0.347 | 0.7300 |
| is_cold_shock_lag1 | 32.8066 | 33.6334 | 0.975 | 0.3341 |
| is_cold_shock_lag2 | 29.3732 | 29.3358 | 1.001 | 0.3216 |
| is_high_cdd | 13.4051 | 24.7303 | 0.542 | 0.5902 |
| is_high_cdd_lag1 | 0.7779 | 32.8229 | 0.024 | 0.9812 |
| is_high_cdd_lag2 | -26.4481 | 38.3763 | -0.689 | 0.4940 |
| is_high_hdd | 58.9330** | 22.1904 | 2.656 | 0.0106 |
| is_high_hdd_lag1 | 33.6352 | 25.1973 | 1.335 | 0.1881 |
| is_high_hdd_lag2 | 36.1874 | 26.3947 | 1.371 | 0.1766 |
| AQI_Median_Wtd | 4.1028 | 2.9670 | 1.383 | 0.1730 |
| AQI_Median_Wtd_lag1 | 1.4506 | 2.1303 | 0.681 | 0.4991 |
| AQI_Median_Wtd_lag2 | -2.1894 | 2.7602 | -0.793 | 0.4315 |
| AQI_Max_State | -0.0033 | 0.0044 | -0.739 | 0.4636 |
| AQI_Max_State_lag1 | 0.0183** | 0.0068 | 2.671 | 0.0102 |
| AQI_Max_State_lag2 | 0.0077 | 0.0069 | 1.118 | 0.2689 |
| Pct_PM25_State | 1.5271 | 9.1672 | 0.167 | 0.8684 |
| Pct_PM25_State_lag1 | -1.5042 | 4.0858 | -0.368 | 0.7143 |
| Pct_PM25_State_lag2 | 3.0151 | 4.6663 | 0.646 | 0.5212 |
| Pct_PM10_State | -1.1715 | 9.9193 | -0.118 | 0.9065 |
| Pct_PM10_State_lag1 | 9.2296 | 5.5536 | 1.662 | 0.1029 |
| Pct_PM10_State_lag2 | 0.0461 | 5.0546 | 0.009 | 0.9928 |
| Pct_Ozone_State | 1.3232 | 9.2434 | 0.143 | 0.8868 |
| Pct_Ozone_State_lag1 | -1.8981 | 4.2493 | -0.447 | 0.6571 |
| Pct_Ozone_State_lag2 | 1.5284 | 4.5407 | 0.337 | 0.7378 |
| Pct_CO_State | -13.4777 | 15.1899 | -0.887 | 0.3793 |
| Pct_CO_State_lag1 | -2.9390 | 11.7469 | -0.250 | 0.8035 |
| Pct_CO_State_lag2 | 26.0839** | 10.4547 | 2.495 | 0.0160 |
| Pct_Unhealthy_State | -49.5998** | 18.8778 | -2.627 | 0.0115 |
| Pct_Unhealthy_State_lag1 | -39.7149*** | 13.3214 | -2.981 | 0.0045 |
| Pct_Unhealthy_State_lag2 | -8.4365 | 31.1994 | -0.270 | 0.7880 |
| Unemployment_Rate | 0.4969 | 11.6390 | 0.043 | 0.9661 |
| Personal_Income_Per_Capita_Real | 0.0018 | 0.0055 | 0.328 | 0.7443 |

---

## Outcome: `Total_Per_Capita_Health_Exp_Real`

#### Primary FE (State + Year)
**N =** 550 | **Within-R² =** 0.1699 | **Cluster =** State

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| is_extreme_drought | 159.8436 | 107.2760 | 1.490 | 0.1426 |
| is_extreme_drought_lag1 | 54.6289 | 46.7271 | 1.169 | 0.2480 |
| is_extreme_drought_lag2 | 83.2921 | 57.1621 | 1.457 | 0.1515 |
| is_severe_drought | 42.9832 | 66.8640 | 0.643 | 0.5233 |
| is_severe_drought_lag1 | 14.0565 | 53.7514 | 0.262 | 0.7948 |
| is_severe_drought_lag2 | 36.2447 | 55.3847 | 0.654 | 0.5159 |
| is_heat_shock | -26.4595 | 42.5240 | -0.622 | 0.5367 |
| is_heat_shock_lag1 | -33.8388 | 46.4316 | -0.729 | 0.4696 |
| is_heat_shock_lag2 | -41.4446 | 48.4259 | -0.856 | 0.3963 |
| is_cold_shock | 205.2749** | 80.6526 | 2.545 | 0.0141 |
| is_cold_shock_lag1 | 155.6681 | 126.4417 | 1.231 | 0.2241 |
| is_cold_shock_lag2 | 96.8344 | 71.3240 | 1.358 | 0.1808 |
| is_high_cdd | 137.3194 | 104.3556 | 1.316 | 0.1943 |
| is_high_cdd_lag1 | 47.8515 | 86.4284 | 0.554 | 0.5823 |
| is_high_cdd_lag2 | -21.1952 | 88.8742 | -0.238 | 0.8125 |
| is_high_hdd | 37.8728 | 42.1897 | 0.898 | 0.3737 |
| is_high_hdd_lag1 | -4.8469 | 60.0572 | -0.081 | 0.9360 |
| is_high_hdd_lag2 | 92.0311* | 52.1017 | 1.766 | 0.0836 |
| AQI_Median_Wtd | -7.7699 | 6.2763 | -1.238 | 0.2216 |
| AQI_Median_Wtd_lag1 | -7.0688 | 7.9116 | -0.893 | 0.3760 |
| AQI_Median_Wtd_lag2 | -5.0573 | 8.8951 | -0.569 | 0.5723 |
| AQI_Max_State | -0.0182 | 0.0155 | -1.172 | 0.2470 |
| AQI_Max_State_lag1 | -0.0441*** | 0.0134 | -3.293 | 0.0018 |
| AQI_Max_State_lag2 | -0.0172 | 0.0138 | -1.247 | 0.2183 |
| Pct_PM25_State | -5.2296 | 15.8936 | -0.329 | 0.7435 |
| Pct_PM25_State_lag1 | -10.1538 | 9.8053 | -1.036 | 0.3055 |
| Pct_PM25_State_lag2 | -2.8964 | 8.5766 | -0.338 | 0.7370 |
| Pct_PM10_State | 5.5847 | 19.5350 | 0.286 | 0.7762 |
| Pct_PM10_State_lag1 | -14.6293 | 12.1038 | -1.209 | 0.2326 |
| Pct_PM10_State_lag2 | -4.4195 | 10.1465 | -0.436 | 0.6651 |
| Pct_Ozone_State | -2.5076 | 16.1502 | -0.155 | 0.8772 |
| Pct_Ozone_State_lag1 | -6.0700 | 10.0724 | -0.603 | 0.5495 |
| Pct_Ozone_State_lag2 | -3.4396 | 9.1746 | -0.375 | 0.7094 |
| Pct_CO_State | -7.1470 | 30.5023 | -0.234 | 0.8157 |
| Pct_CO_State_lag1 | 17.3474 | 26.9715 | 0.643 | 0.5231 |
| Pct_CO_State_lag2 | -58.7794* | 30.3628 | -1.936 | 0.0587 |
| Pct_Unhealthy_State | 1.2138 | 55.0861 | 0.022 | 0.9825 |
| Pct_Unhealthy_State_lag1 | 74.7716 | 61.3547 | 1.219 | 0.2288 |
| Pct_Unhealthy_State_lag2 | -8.4917 | 51.8890 | -0.164 | 0.8707 |
| Unemployment_Rate | 59.8489* | 31.5007 | 1.900 | 0.0633 |
| Personal_Income_Per_Capita_Real | 0.0179 | 0.0210 | 0.855 | 0.3968 |

---

## Outcome: `Medicaid_Per_Enrollee_Health_Exp_Real`

#### Primary FE (State + Year)
**N =** 550 | **Within-R² =** 0.2105 | **Cluster =** State

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| is_extreme_drought | -566.1642** | 278.3056 | -2.034 | 0.0473 |
| is_extreme_drought_lag1 | 97.6543 | 230.1342 | 0.424 | 0.6732 |
| is_extreme_drought_lag2 | 135.2005 | 190.6064 | 0.709 | 0.4815 |
| is_severe_drought | -525.7577** | 203.0244 | -2.590 | 0.0126 |
| is_severe_drought_lag1 | -524.5177*** | 149.0674 | -3.519 | 0.0009 |
| is_severe_drought_lag2 | -288.4018** | 139.3817 | -2.069 | 0.0438 |
| is_heat_shock | -64.5296 | 115.4276 | -0.559 | 0.5787 |
| is_heat_shock_lag1 | -74.5797 | 108.3713 | -0.688 | 0.4946 |
| is_heat_shock_lag2 | -185.4813 | 121.1424 | -1.531 | 0.1322 |
| is_cold_shock | -81.7854 | 313.3850 | -0.261 | 0.7952 |
| is_cold_shock_lag1 | 136.4737 | 244.7084 | 0.558 | 0.5796 |
| is_cold_shock_lag2 | 245.9723 | 154.8243 | 1.589 | 0.1186 |
| is_high_cdd | -181.2970 | 111.5707 | -1.625 | 0.1106 |
| is_high_cdd_lag1 | -84.3175 | 198.2728 | -0.425 | 0.6725 |
| is_high_cdd_lag2 | -117.2155 | 139.2720 | -0.842 | 0.4041 |
| is_high_hdd | 53.7063 | 213.0677 | 0.252 | 0.8020 |
| is_high_hdd_lag1 | 39.9275 | 144.8106 | 0.276 | 0.7839 |
| is_high_hdd_lag2 | -183.3299 | 193.5527 | -0.947 | 0.3482 |
| AQI_Median_Wtd | 44.3247** | 19.9314 | 2.224 | 0.0308 |
| AQI_Median_Wtd_lag1 | 11.5903 | 17.7312 | 0.654 | 0.5164 |
| AQI_Median_Wtd_lag2 | 15.7330 | 21.7023 | 0.725 | 0.4719 |
| AQI_Max_State | 0.0465 | 0.0382 | 1.220 | 0.2283 |
| AQI_Max_State_lag1 | -0.1281*** | 0.0305 | -4.204 | 0.0001 |
| AQI_Max_State_lag2 | -0.1340*** | 0.0312 | -4.300 | 0.0001 |
| Pct_PM25_State | -39.3612 | 24.3177 | -1.619 | 0.1119 |
| Pct_PM25_State_lag1 | 4.9468 | 30.5990 | 0.162 | 0.8722 |
| Pct_PM25_State_lag2 | 16.7968 | 29.7857 | 0.564 | 0.5754 |
| Pct_PM10_State | -35.8959 | 37.0960 | -0.968 | 0.3380 |
| Pct_PM10_State_lag1 | 4.2194 | 39.3212 | 0.107 | 0.9150 |
| Pct_PM10_State_lag2 | 11.4976 | 32.3950 | 0.355 | 0.7242 |
| Pct_Ozone_State | -33.7900 | 27.3331 | -1.236 | 0.2223 |
| Pct_Ozone_State_lag1 | 5.6298 | 31.1213 | 0.181 | 0.8572 |
| Pct_Ozone_State_lag2 | -4.1221 | 32.1434 | -0.128 | 0.8985 |
| Pct_CO_State | -270.2547*** | 96.7698 | -2.793 | 0.0074 |
| Pct_CO_State_lag1 | 39.3423 | 88.9668 | 0.442 | 0.6603 |
| Pct_CO_State_lag2 | 155.2810 | 98.9051 | 1.570 | 0.1229 |
| Pct_Unhealthy_State | 54.0786 | 127.2038 | 0.425 | 0.6726 |
| Pct_Unhealthy_State_lag1 | -66.7711 | 181.7092 | -0.367 | 0.7149 |
| Pct_Unhealthy_State_lag2 | 1.8238 | 107.8268 | 0.017 | 0.9866 |
| Unemployment_Rate | 81.3254 | 82.9117 | 0.981 | 0.3315 |
| Personal_Income_Per_Capita_Real | 0.0888** | 0.0380 | 2.337 | 0.0236 |

---

## Outcome: `Medicare_Per_Enrollee_Health_Exp_Real`

#### Primary FE (State + Year)
**N =** 550 | **Within-R² =** 0.1816 | **Cluster =** State

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| is_extreme_drought | 107.8881 | 99.6535 | 1.083 | 0.2843 |
| is_extreme_drought_lag1 | 42.5798 | 70.1592 | 0.607 | 0.5467 |
| is_extreme_drought_lag2 | 44.7747 | 63.0530 | 0.710 | 0.4810 |
| is_severe_drought | -86.8009* | 49.0235 | -1.771 | 0.0828 |
| is_severe_drought_lag1 | -144.3158*** | 35.2932 | -4.089 | 0.0002 |
| is_severe_drought_lag2 | -54.7966 | 65.3622 | -0.838 | 0.4059 |
| is_heat_shock | -57.7837 | 41.4245 | -1.395 | 0.1693 |
| is_heat_shock_lag1 | 24.7110 | 37.0792 | 0.666 | 0.5083 |
| is_heat_shock_lag2 | 84.3049* | 44.4170 | 1.898 | 0.0636 |
| is_cold_shock | 53.3330 | 118.0141 | 0.452 | 0.6533 |
| is_cold_shock_lag1 | 105.9669 | 105.8389 | 1.001 | 0.3216 |
| is_cold_shock_lag2 | 73.5788 | 115.2520 | 0.638 | 0.5262 |
| is_high_cdd | 7.8119 | 42.7580 | 0.183 | 0.8558 |
| is_high_cdd_lag1 | 144.7125** | 61.6961 | 2.346 | 0.0231 |
| is_high_cdd_lag2 | 137.2325*** | 50.1772 | 2.735 | 0.0087 |
| is_high_hdd | -56.8053 | 66.5105 | -0.854 | 0.3972 |
| is_high_hdd_lag1 | -110.0967* | 61.3244 | -1.795 | 0.0788 |
| is_high_hdd_lag2 | -192.6830*** | 60.9426 | -3.162 | 0.0027 |
| AQI_Median_Wtd | 8.4033 | 7.0328 | 1.195 | 0.2379 |
| AQI_Median_Wtd_lag1 | 7.7805 | 7.5603 | 1.029 | 0.3085 |
| AQI_Median_Wtd_lag2 | 5.7058 | 6.5676 | 0.869 | 0.3892 |
| AQI_Max_State | -0.0123 | 0.0124 | -0.993 | 0.3257 |
| AQI_Max_State_lag1 | -0.0220* | 0.0126 | -1.750 | 0.0864 |
| AQI_Max_State_lag2 | -0.0041 | 0.0112 | -0.365 | 0.7167 |
| Pct_PM25_State | -0.8194 | 12.3781 | -0.066 | 0.9475 |
| Pct_PM25_State_lag1 | -8.7960 | 11.1340 | -0.790 | 0.4333 |
| Pct_PM25_State_lag2 | -2.5822 | 9.6675 | -0.267 | 0.7905 |
| Pct_PM10_State | -4.4751 | 14.5646 | -0.307 | 0.7599 |
| Pct_PM10_State_lag1 | -0.0211 | 16.3488 | -0.001 | 0.9990 |
| Pct_PM10_State_lag2 | -17.7946* | 10.0302 | -1.774 | 0.0823 |
| Pct_Ozone_State | 1.4478 | 13.9940 | 0.103 | 0.9180 |
| Pct_Ozone_State_lag1 | -10.9174 | 11.0412 | -0.989 | 0.3276 |
| Pct_Ozone_State_lag2 | -6.4454 | 12.5863 | -0.512 | 0.6109 |
| Pct_CO_State | -28.4773 | 27.2564 | -1.045 | 0.3012 |
| Pct_CO_State_lag1 | -0.7883 | 15.8951 | -0.050 | 0.9606 |
| Pct_CO_State_lag2 | -12.1734 | 25.2845 | -0.481 | 0.6323 |
| Pct_Unhealthy_State | 97.6867** | 42.4555 | 2.301 | 0.0257 |
| Pct_Unhealthy_State_lag1 | 102.4275** | 47.2617 | 2.167 | 0.0351 |
| Pct_Unhealthy_State_lag2 | 99.3367*** | 27.6498 | 3.593 | 0.0008 |
| Unemployment_Rate | 35.3604 | 33.3097 | 1.062 | 0.2936 |
| Personal_Income_Per_Capita_Real | -0.0214* | 0.0114 | -1.880 | 0.0660 |

