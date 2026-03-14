# County-Level Regression Results
**Generated:** 2026-03-09 12:24:24
**Input:** Data/county_level_master.csv
**Model:** Two-way FE (fips_code + Year), cluster = State (primary), `fixest::feols`
**Specs:** Spec1 = Z-Temp/Z-Precip (relative shocks); Spec2 = High CDD/HDD (absolute burden); _AQI = +AQI_Shock; _RA_Cluster = Rating-Area clustered SEs

Significance: \*p<0.10, \*\*p<0.05, \*\*\*p<0.01

---

## Outcome: `Medical_Debt_Share`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 32,882 | **Within-R² =** 0.0244 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.0007 | 0.0006 | -1.192 | 0.2393 |
| PDSI_Lag1 | -0.0003 | 0.0005 | -0.660 | 0.5128 |
| PDSI_Lag2 | 0.0001 | 0.0005 | 0.129 | 0.8976 |
| Z_Temp | -0.0025* | 0.0014 | -1.809 | 0.0769 |
| Z_Temp_Lag1 | -0.0015 | 0.0009 | -1.610 | 0.1140 |
| Z_Temp_Lag2 | -0.0027** | 0.0010 | -2.671 | 0.0103 |
| Z_Precip | 0.0011 | 0.0008 | 1.400 | 0.1679 |
| Z_Precip_Lag1 | 0.0011 | 0.0009 | 1.200 | 0.2360 |
| Z_Precip_Lag2 | -0.0004 | 0.0007 | -0.526 | 0.6014 |
| Household_Income_2023 | 0.0000* | 0.0000 | 1.810 | 0.0767 |
| Uninsured_Rate | 0.2299*** | 0.0695 | 3.305 | 0.0018 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 32,882 | **Within-R² =** 0.0186 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.0001 | 0.0004 | 0.262 | 0.7948 |
| PDSI_Lag1 | 0.0001 | 0.0003 | 0.349 | 0.7288 |
| PDSI_Lag2 | -0.0001 | 0.0003 | -0.311 | 0.7575 |
| High_CDD | -0.0040 | 0.0032 | -1.281 | 0.2066 |
| High_CDD_Lag1 | -0.0038 | 0.0024 | -1.595 | 0.1175 |
| High_CDD_Lag2 | -0.0045** | 0.0017 | -2.646 | 0.0110 |
| High_HDD | 0.0038** | 0.0017 | 2.200 | 0.0327 |
| High_HDD_Lag1 | 0.0013 | 0.0014 | 0.913 | 0.3660 |
| High_HDD_Lag2 | 0.0031* | 0.0017 | 1.844 | 0.0715 |
| Household_Income_2023 | 0.0000* | 0.0000 | 1.794 | 0.0793 |
| Uninsured_Rate | 0.2475*** | 0.0725 | 3.412 | 0.0013 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 32,863 | **Within-R² =** 0.0591 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.0001 | 0.0004 | -0.219 | 0.8278 |
| PDSI_Lag1 | -0.0005 | 0.0004 | -1.334 | 0.1886 |
| PDSI_Lag2 | -0.0006 | 0.0003 | -1.668 | 0.1020 |
| Z_Temp | -0.0000 | 0.0007 | -0.070 | 0.9448 |
| Z_Temp_Lag1 | -0.0002 | 0.0005 | -0.386 | 0.7016 |
| Z_Temp_Lag2 | -0.0014* | 0.0008 | -1.794 | 0.0792 |
| Z_Precip | 0.0009 | 0.0007 | 1.203 | 0.2350 |
| Z_Precip_Lag1 | 0.0014* | 0.0007 | 1.959 | 0.0560 |
| Z_Precip_Lag2 | 0.0011* | 0.0006 | 1.834 | 0.0731 |
| Household_Income_2023 | 0.0000*** | 0.0000 | 4.236 | 0.0001 |
| Uninsured_Rate | 0.3322*** | 0.0684 | 4.857 | 0.0000 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 32,863 | **Within-R² =** 0.0567 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.0004 | 0.0003 | 1.155 | 0.2538 |
| PDSI_Lag1 | 0.0002 | 0.0003 | 0.596 | 0.5539 |
| PDSI_Lag2 | -0.0001 | 0.0003 | -0.202 | 0.8406 |
| High_CDD | 0.0005 | 0.0026 | 0.197 | 0.8447 |
| High_CDD_Lag1 | -0.0008 | 0.0025 | -0.317 | 0.7528 |
| High_CDD_Lag2 | -0.0016 | 0.0025 | -0.665 | 0.5091 |
| High_HDD | 0.0054** | 0.0021 | 2.641 | 0.0112 |
| High_HDD_Lag1 | 0.0019 | 0.0019 | 1.000 | 0.3222 |
| High_HDD_Lag2 | 0.0037* | 0.0020 | 1.843 | 0.0717 |
| Household_Income_2023 | 0.0000*** | 0.0000 | 4.393 | 0.0001 |
| Uninsured_Rate | 0.3579*** | 0.0681 | 5.254 | 0.0000 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,453 | **Within-R² =** 0.106 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.0006 | 0.0007 | 0.844 | 0.4032 |
| PDSI_Lag1 | 0.0004 | 0.0006 | 0.704 | 0.4846 |
| PDSI_Lag2 | 0.0003 | 0.0005 | 0.668 | 0.5077 |
| Z_Temp | 0.0014 | 0.0011 | 1.250 | 0.2175 |
| Z_Temp_Lag1 | 0.0017 | 0.0012 | 1.380 | 0.1741 |
| Z_Temp_Lag2 | 0.0015 | 0.0011 | 1.390 | 0.1712 |
| Z_Precip | -0.0008 | 0.0008 | -0.954 | 0.3450 |
| Z_Precip_Lag1 | -0.0002 | 0.0010 | -0.241 | 0.8105 |
| Z_Precip_Lag2 | -0.0003 | 0.0007 | -0.432 | 0.6680 |
| Household_Income_2023 | 0.0000*** | 0.0000 | 6.225 | 0.0000 |
| Uninsured_Rate | 0.4993*** | 0.1183 | 4.221 | 0.0001 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,453 | **Within-R² =** 0.1009 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.0001 | 0.0005 | 0.243 | 0.8087 |
| PDSI_Lag1 | 0.0002 | 0.0004 | 0.560 | 0.5780 |
| PDSI_Lag2 | 0.0001 | 0.0003 | 0.327 | 0.7452 |
| High_CDD | 0.0023 | 0.0038 | 0.613 | 0.5430 |
| High_CDD_Lag1 | 0.0007 | 0.0043 | 0.158 | 0.8755 |
| High_CDD_Lag2 | 0.0027 | 0.0050 | 0.534 | 0.5957 |
| High_HDD | 0.0099* | 0.0052 | 1.888 | 0.0651 |
| High_HDD_Lag1 | -0.0008 | 0.0042 | -0.186 | 0.8532 |
| High_HDD_Lag2 | 0.0047 | 0.0040 | 1.180 | 0.2440 |
| Household_Income_2023 | 0.0000*** | 0.0000 | 6.014 | 0.0000 |
| Uninsured_Rate | 0.5447*** | 0.1122 | 4.857 | 0.0000 |

---

## Outcome: `Medical_Debt_Median_2023`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 23,080 | **Within-R² =** 0.0197 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -2.3444 | 4.3016 | -0.545 | 0.5883 |
| PDSI_Lag1 | -1.0876 | 3.4974 | -0.311 | 0.7572 |
| PDSI_Lag2 | -1.2896 | 3.3035 | -0.390 | 0.6980 |
| Z_Temp | 14.8721* | 7.5504 | 1.970 | 0.0548 |
| Z_Temp_Lag1 | -3.0084 | 5.2279 | -0.575 | 0.5677 |
| Z_Temp_Lag2 | 19.5351** | 7.8067 | 2.502 | 0.0159 |
| Z_Precip | 3.1939 | 3.7242 | 0.858 | 0.3955 |
| Z_Precip_Lag1 | 4.5839 | 5.4925 | 0.835 | 0.4082 |
| Z_Precip_Lag2 | 8.0837* | 4.7605 | 1.698 | 0.0961 |
| Household_Income_2023 | -0.0024** | 0.0009 | -2.555 | 0.0139 |
| Uninsured_Rate | 1766.6499*** | 475.1310 | 3.718 | 0.0005 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 23,080 | **Within-R² =** 0.0141 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -2.0936 | 3.2525 | -0.644 | 0.5229 |
| PDSI_Lag1 | 2.6559 | 2.1448 | 1.238 | 0.2217 |
| PDSI_Lag2 | 0.0994 | 2.2654 | 0.044 | 0.9652 |
| High_CDD | -7.5365 | 17.1303 | -0.440 | 0.6620 |
| High_CDD_Lag1 | 14.2638 | 15.4956 | 0.921 | 0.3620 |
| High_CDD_Lag2 | 10.1475 | 14.3912 | 0.705 | 0.4842 |
| High_HDD | 10.6395 | 11.2395 | 0.947 | 0.3487 |
| High_HDD_Lag1 | -1.3308 | 10.8089 | -0.123 | 0.9025 |
| High_HDD_Lag2 | -0.6903 | 16.6406 | -0.041 | 0.9671 |
| Household_Income_2023 | -0.0024** | 0.0010 | -2.473 | 0.0171 |
| Uninsured_Rate | 1650.5434*** | 470.3152 | 3.509 | 0.0010 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 23,069 | **Within-R² =** 0.0464 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 2.3042 | 2.8589 | 0.806 | 0.4243 |
| PDSI_Lag1 | 4.1411 | 2.7825 | 1.488 | 0.1434 |
| PDSI_Lag2 | -1.1058 | 2.0934 | -0.528 | 0.5998 |
| Z_Temp | 18.5244*** | 5.1975 | 3.564 | 0.0009 |
| Z_Temp_Lag1 | -0.1481 | 4.5595 | -0.032 | 0.9742 |
| Z_Temp_Lag2 | 16.1985*** | 4.3866 | 3.693 | 0.0006 |
| Z_Precip | 1.0724 | 3.3667 | 0.319 | 0.7515 |
| Z_Precip_Lag1 | -2.3231 | 5.6087 | -0.414 | 0.6806 |
| Z_Precip_Lag2 | 5.7231 | 4.7687 | 1.200 | 0.2361 |
| Household_Income_2023 | -0.0026* | 0.0014 | -1.784 | 0.0809 |
| Uninsured_Rate | 1863.3559*** | 362.3917 | 5.142 | 0.0000 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 23,069 | **Within-R² =** 0.0331 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.1936 | 3.1489 | -0.061 | 0.9512 |
| PDSI_Lag1 | 2.6301 | 2.4018 | 1.095 | 0.2791 |
| PDSI_Lag2 | -1.0455 | 2.5122 | -0.416 | 0.6792 |
| High_CDD | -19.4716 | 17.0738 | -1.140 | 0.2599 |
| High_CDD_Lag1 | -4.0033 | 21.2046 | -0.189 | 0.8511 |
| High_CDD_Lag2 | -20.8606 | 19.3018 | -1.081 | 0.2853 |
| High_HDD | 31.2452** | 13.1541 | 2.375 | 0.0217 |
| High_HDD_Lag1 | 18.8966 | 17.3872 | 1.087 | 0.2827 |
| High_HDD_Lag2 | 26.6204 | 28.1978 | 0.944 | 0.3500 |
| Household_Income_2023 | -0.0030** | 0.0014 | -2.152 | 0.0366 |
| Uninsured_Rate | 1737.0908*** | 417.1971 | 4.164 | 0.0001 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,372 | **Within-R² =** 0.0855 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 6.2481 | 4.3038 | 1.452 | 0.1532 |
| PDSI_Lag1 | 2.4927 | 4.7190 | 0.528 | 0.5998 |
| PDSI_Lag2 | -5.8879** | 2.7807 | -2.117 | 0.0395 |
| Z_Temp | 15.6985* | 8.4530 | 1.857 | 0.0696 |
| Z_Temp_Lag1 | 11.1577 | 7.5371 | 1.480 | 0.1454 |
| Z_Temp_Lag2 | 18.2424*** | 6.1031 | 2.989 | 0.0044 |
| Z_Precip | -8.8677* | 4.9422 | -1.794 | 0.0792 |
| Z_Precip_Lag1 | -9.9642 | 6.6624 | -1.496 | 0.1414 |
| Z_Precip_Lag2 | 2.3536 | 4.8535 | 0.485 | 0.6300 |
| Household_Income_2023 | -0.0004 | 0.0017 | -0.222 | 0.8251 |
| Uninsured_Rate | 2438.8503*** | 659.7049 | 3.697 | 0.0006 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,372 | **Within-R² =** 0.0683 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.0931 | 2.9802 | -0.031 | 0.9752 |
| PDSI_Lag1 | -2.7279 | 2.0358 | -1.340 | 0.1867 |
| PDSI_Lag2 | -5.2418* | 2.8766 | -1.822 | 0.0748 |
| High_CDD | -50.3255** | 24.0503 | -2.093 | 0.0418 |
| High_CDD_Lag1 | -37.5098 | 36.7127 | -1.022 | 0.3121 |
| High_CDD_Lag2 | -34.5357 | 29.8360 | -1.158 | 0.2529 |
| High_HDD | 12.2201 | 37.8463 | 0.323 | 0.7482 |
| High_HDD_Lag1 | -32.7002 | 21.5318 | -1.519 | 0.1355 |
| High_HDD_Lag2 | 9.1988 | 32.3445 | 0.284 | 0.7774 |
| Household_Income_2023 | -0.0015 | 0.0015 | -1.017 | 0.3145 |
| Uninsured_Rate | 3001.0426*** | 681.3946 | 4.404 | 0.0001 |

---

## Outcome: `Benchmark_Silver_Real`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 27,584 | **Within-R² =** 0.0217 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 3.1808 | 2.3500 | 1.354 | 0.1824 |
| PDSI_Lag1 | 3.9049 | 2.4574 | 1.589 | 0.1188 |
| PDSI_Lag2 | 1.3539 | 3.7248 | 0.363 | 0.7179 |
| Z_Temp | -10.8823 | 7.5630 | -1.439 | 0.1568 |
| Z_Temp_Lag1 | 3.7752 | 4.9506 | 0.763 | 0.4495 |
| Z_Temp_Lag2 | 0.9983 | 5.3354 | 0.187 | 0.8524 |
| Z_Precip | -2.8500 | 2.4004 | -1.187 | 0.2411 |
| Z_Precip_Lag1 | -5.8034 | 3.9574 | -1.466 | 0.1492 |
| Z_Precip_Lag2 | -5.3370* | 3.1387 | -1.700 | 0.0957 |
| Household_Income_2023 | -0.0007** | 0.0003 | -2.646 | 0.0110 |
| Uninsured_Rate | 179.8749 | 117.6254 | 1.529 | 0.1329 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 27,584 | **Within-R² =** 0.0196 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 2.1647 | 1.5160 | 1.428 | 0.1599 |
| PDSI_Lag1 | 0.4697 | 1.1836 | 0.397 | 0.6933 |
| PDSI_Lag2 | 0.3451 | 2.9945 | 0.115 | 0.9087 |
| High_CDD | 5.8144 | 10.4462 | 0.557 | 0.5804 |
| High_CDD_Lag1 | 8.6653 | 12.3440 | 0.702 | 0.4861 |
| High_CDD_Lag2 | 21.5870* | 11.6491 | 1.853 | 0.0702 |
| High_HDD | 28.0954*** | 10.0438 | 2.797 | 0.0074 |
| High_HDD_Lag1 | -24.4939* | 14.4853 | -1.691 | 0.0975 |
| High_HDD_Lag2 | -8.0476 | 8.0870 | -0.995 | 0.3248 |
| Household_Income_2023 | -0.0008** | 0.0003 | -2.624 | 0.0117 |
| Uninsured_Rate | 179.2457 | 122.4952 | 1.463 | 0.1500 |

#### Spec 1 (Rating-Area Clustered SEs)
**N =** 27,584 | **Within-R² =** 0.0217 | **Cluster =** rating_area_id | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 3.1808* | 1.6539 | 1.923 | 0.0550 |
| PDSI_Lag1 | 3.9049** | 1.9812 | 1.971 | 0.0493 |
| PDSI_Lag2 | 1.3539 | 3.0511 | 0.444 | 0.6574 |
| Z_Temp | -10.8823** | 5.2287 | -2.081 | 0.0379 |
| Z_Temp_Lag1 | 3.7752 | 3.8175 | 0.989 | 0.3232 |
| Z_Temp_Lag2 | 0.9983 | 3.2229 | 0.310 | 0.7569 |
| Z_Precip | -2.8500 | 1.9667 | -1.449 | 0.1479 |
| Z_Precip_Lag1 | -5.8034* | 3.2738 | -1.773 | 0.0769 |
| Z_Precip_Lag2 | -5.3370** | 2.4076 | -2.217 | 0.0271 |
| Household_Income_2023 | -0.0007*** | 0.0003 | -2.721 | 0.0067 |
| Uninsured_Rate | 179.8749** | 81.5747 | 2.205 | 0.0279 |

#### Spec 2 (Rating-Area Clustered SEs)
**N =** 27,584 | **Within-R² =** 0.0196 | **Cluster =** rating_area_id | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 2.1647** | 0.9600 | 2.255 | 0.0246 |
| PDSI_Lag1 | 0.4697 | 0.9219 | 0.510 | 0.6106 |
| PDSI_Lag2 | 0.3451 | 2.4701 | 0.140 | 0.8889 |
| High_CDD | 5.8144 | 7.5777 | 0.767 | 0.4433 |
| High_CDD_Lag1 | 8.6653 | 8.5327 | 1.016 | 0.3103 |
| High_CDD_Lag2 | 21.5870*** | 8.2337 | 2.622 | 0.0090 |
| High_HDD | 28.0954*** | 7.6932 | 3.652 | 0.0003 |
| High_HDD_Lag1 | -24.4939*** | 8.3234 | -2.943 | 0.0034 |
| High_HDD_Lag2 | -8.0476 | 6.1221 | -1.315 | 0.1893 |
| Household_Income_2023 | -0.0008*** | 0.0003 | -2.763 | 0.0059 |
| Uninsured_Rate | 179.2457** | 82.8255 | 2.164 | 0.0309 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 27,570 | **Within-R² =** 0.0294 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 4.0637 | 4.7945 | 0.848 | 0.4010 |
| PDSI_Lag1 | -2.1548 | 2.0198 | -1.067 | 0.2915 |
| PDSI_Lag2 | 0.8855 | 1.8020 | 0.491 | 0.6254 |
| Z_Temp | 2.6887 | 4.5954 | 0.585 | 0.5613 |
| Z_Temp_Lag1 | 5.4078 | 4.3457 | 1.244 | 0.2195 |
| Z_Temp_Lag2 | 4.1515 | 3.9494 | 1.051 | 0.2986 |
| Z_Precip | -1.8536 | 4.6854 | -0.396 | 0.6942 |
| Z_Precip_Lag1 | 0.5378 | 4.6608 | 0.115 | 0.9086 |
| Z_Precip_Lag2 | -5.5319 | 4.2895 | -1.290 | 0.2035 |
| Household_Income_2023 | -0.0007 | 0.0004 | -1.602 | 0.1158 |
| Uninsured_Rate | 333.9008 | 221.0096 | 1.511 | 0.1375 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 27,570 | **Within-R² =** 0.0338 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 2.7239 | 3.2582 | 0.836 | 0.4074 |
| PDSI_Lag1 | -2.1139** | 1.0292 | -2.054 | 0.0456 |
| PDSI_Lag2 | -1.8116 | 2.1047 | -0.861 | 0.3937 |
| High_CDD | 20.3050** | 9.1650 | 2.216 | 0.0316 |
| High_CDD_Lag1 | 31.4240*** | 11.5451 | 2.722 | 0.0091 |
| High_CDD_Lag2 | 35.3479*** | 10.4670 | 3.377 | 0.0015 |
| High_HDD | 21.8866** | 8.5084 | 2.572 | 0.0133 |
| High_HDD_Lag1 | -20.7742 | 20.1466 | -1.031 | 0.3077 |
| High_HDD_Lag2 | -0.7200 | 11.9114 | -0.060 | 0.9521 |
| Household_Income_2023 | -0.0009* | 0.0005 | -1.941 | 0.0583 |
| Uninsured_Rate | 400.2515* | 214.6752 | 1.864 | 0.0685 |

#### Spec 1 (Rating-Area Clustered SEs)
**N =** 27,570 | **Within-R² =** 0.0294 | **Cluster =** rating_area_id | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 4.0637 | 2.5189 | 1.613 | 0.1073 |
| PDSI_Lag1 | -2.1548 | 1.3750 | -1.567 | 0.1177 |
| PDSI_Lag2 | 0.8855 | 1.5358 | 0.577 | 0.5645 |
| Z_Temp | 2.6887 | 2.7649 | 0.972 | 0.3313 |
| Z_Temp_Lag1 | 5.4078** | 2.3042 | 2.347 | 0.0193 |
| Z_Temp_Lag2 | 4.1515** | 2.0507 | 2.024 | 0.0435 |
| Z_Precip | -1.8536 | 3.1166 | -0.595 | 0.5523 |
| Z_Precip_Lag1 | 0.5378 | 3.5046 | 0.153 | 0.8781 |
| Z_Precip_Lag2 | -5.5319 | 4.4809 | -1.235 | 0.2176 |
| Household_Income_2023 | -0.0007** | 0.0003 | -2.312 | 0.0212 |
| Uninsured_Rate | 333.9008*** | 129.0106 | 2.588 | 0.0099 |

#### Spec 2 (Rating-Area Clustered SEs)
**N =** 27,570 | **Within-R² =** 0.0338 | **Cluster =** rating_area_id | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 2.7239 | 1.9493 | 1.397 | 0.1629 |
| PDSI_Lag1 | -2.1139*** | 0.6607 | -3.200 | 0.0015 |
| PDSI_Lag2 | -1.8116 | 1.5282 | -1.185 | 0.2364 |
| High_CDD | 20.3050*** | 6.5191 | 3.115 | 0.0019 |
| High_CDD_Lag1 | 31.4240*** | 8.8214 | 3.562 | 0.0004 |
| High_CDD_Lag2 | 35.3479*** | 9.4209 | 3.752 | 0.0002 |
| High_HDD | 21.8866*** | 7.5808 | 2.887 | 0.0041 |
| High_HDD_Lag1 | -20.7742 | 13.9583 | -1.488 | 0.1373 |
| High_HDD_Lag2 | -0.7200 | 7.5318 | -0.096 | 0.9239 |
| Household_Income_2023 | -0.0009*** | 0.0003 | -3.049 | 0.0024 |
| Uninsured_Rate | 400.2515*** | 120.0941 | 3.333 | 0.0009 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,444 | **Within-R² =** 0.035 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 3.0229 | 5.8573 | 0.516 | 0.6082 |
| PDSI_Lag1 | -3.7191* | 2.1408 | -1.737 | 0.0889 |
| PDSI_Lag2 | -1.1958 | 2.2299 | -0.536 | 0.5943 |
| Z_Temp | 9.4330* | 5.3600 | 1.760 | 0.0849 |
| Z_Temp_Lag1 | 3.6666 | 6.8515 | 0.535 | 0.5951 |
| Z_Temp_Lag2 | 2.5226 | 5.3384 | 0.473 | 0.6387 |
| Z_Precip | 3.8772 | 5.9993 | 0.646 | 0.5212 |
| Z_Precip_Lag1 | 1.3012 | 5.0844 | 0.256 | 0.7991 |
| Z_Precip_Lag2 | -4.0946 | 4.3253 | -0.947 | 0.3486 |
| Household_Income_2023 | -0.0002 | 0.0007 | -0.263 | 0.7939 |
| Uninsured_Rate | -95.6660 | 351.2265 | -0.272 | 0.7865 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,444 | **Within-R² =** 0.0368 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 4.2595 | 4.4039 | 0.967 | 0.3384 |
| PDSI_Lag1 | -3.3628*** | 1.2440 | -2.703 | 0.0095 |
| PDSI_Lag2 | -2.8676 | 2.6155 | -1.096 | 0.2785 |
| High_CDD | 27.3792* | 16.1178 | 1.699 | 0.0960 |
| High_CDD_Lag1 | 30.0544* | 15.6479 | 1.921 | 0.0609 |
| High_CDD_Lag2 | 36.5349** | 14.1880 | 2.575 | 0.0132 |
| High_HDD | 41.7960** | 19.1634 | 2.181 | 0.0342 |
| High_HDD_Lag1 | -45.7753 | 40.7803 | -1.122 | 0.2674 |
| High_HDD_Lag2 | 3.9592 | 20.4825 | 0.193 | 0.8476 |
| Household_Income_2023 | 0.0002 | 0.0008 | 0.251 | 0.8027 |
| Uninsured_Rate | 74.0619 | 313.6326 | 0.236 | 0.8143 |

---

## Outcome: `Hosp_BadDebt_PerCapita`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 26,733 | **Within-R² =** 0.0065 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.2564 | 0.3723 | -0.689 | 0.4943 |
| PDSI_Lag1 | 0.0047 | 0.3942 | 0.012 | 0.9906 |
| PDSI_Lag2 | 0.0058 | 0.4092 | 0.014 | 0.9887 |
| Z_Temp | -1.2527 | 0.8365 | -1.497 | 0.1410 |
| Z_Temp_Lag1 | -0.3081 | 0.5587 | -0.552 | 0.5839 |
| Z_Temp_Lag2 | -2.4120*** | 0.7511 | -3.211 | 0.0024 |
| Z_Precip | 0.1282 | 0.5860 | 0.219 | 0.8278 |
| Z_Precip_Lag1 | 0.9614 | 0.6401 | 1.502 | 0.1398 |
| Z_Precip_Lag2 | -0.1444 | 0.6725 | -0.215 | 0.8309 |
| Household_Income_2023 | 0.0003 | 0.0002 | 1.663 | 0.1029 |
| Uninsured_Rate | 150.7313*** | 51.8674 | 2.906 | 0.0056 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 26,733 | **Within-R² =** 0.0052 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.0551 | 0.3429 | -0.161 | 0.8731 |
| PDSI_Lag1 | 0.5711* | 0.3116 | 1.833 | 0.0732 |
| PDSI_Lag2 | 0.0103 | 0.2067 | 0.050 | 0.9605 |
| High_CDD | 2.3919 | 1.9799 | 1.208 | 0.2331 |
| High_CDD_Lag1 | 2.1242 | 1.8011 | 1.179 | 0.2442 |
| High_CDD_Lag2 | 1.8803 | 2.5012 | 0.752 | 0.4560 |
| High_HDD | 5.3342*** | 1.9367 | 2.754 | 0.0083 |
| High_HDD_Lag1 | -0.2403 | 1.1019 | -0.218 | 0.8283 |
| High_HDD_Lag2 | 2.2247 | 1.5750 | 1.412 | 0.1644 |
| Household_Income_2023 | 0.0003 | 0.0002 | 1.633 | 0.1092 |
| Uninsured_Rate | 165.9765*** | 52.0446 | 3.189 | 0.0025 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 26,733 | **Within-R² =** 0.0192 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.3150 | 0.2592 | 1.215 | 0.2304 |
| PDSI_Lag1 | 0.2252 | 0.4904 | 0.459 | 0.6481 |
| PDSI_Lag2 | 0.3703 | 0.2395 | 1.546 | 0.1288 |
| Z_Temp | -1.0788** | 0.4243 | -2.543 | 0.0144 |
| Z_Temp_Lag1 | 0.2968 | 0.4682 | 0.634 | 0.5293 |
| Z_Temp_Lag2 | -2.0844*** | 0.4847 | -4.300 | 0.0001 |
| Z_Precip | 0.1477 | 0.4138 | 0.357 | 0.7228 |
| Z_Precip_Lag1 | 0.5184 | 0.7983 | 0.649 | 0.5193 |
| Z_Precip_Lag2 | -0.4238 | 0.7212 | -0.588 | 0.5596 |
| Household_Income_2023 | 0.0004** | 0.0002 | 2.016 | 0.0496 |
| Uninsured_Rate | 141.7232 | 98.8142 | 1.434 | 0.1581 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 26,733 | **Within-R² =** 0.015 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.5057*** | 0.1726 | 2.930 | 0.0052 |
| PDSI_Lag1 | 0.5018* | 0.2832 | 1.772 | 0.0829 |
| PDSI_Lag2 | 0.4951* | 0.2478 | 1.998 | 0.0515 |
| High_CDD | 1.1489 | 1.4176 | 0.810 | 0.4217 |
| High_CDD_Lag1 | 2.8883* | 1.6413 | 1.760 | 0.0850 |
| High_CDD_Lag2 | 2.0539 | 1.4949 | 1.374 | 0.1760 |
| High_HDD | 4.2291** | 1.9556 | 2.163 | 0.0357 |
| High_HDD_Lag1 | -0.8208 | 1.5361 | -0.534 | 0.5956 |
| High_HDD_Lag2 | -0.7382 | 1.5141 | -0.488 | 0.6281 |
| Household_Income_2023 | 0.0004** | 0.0002 | 2.192 | 0.0333 |
| Uninsured_Rate | 166.7291 | 101.1986 | 1.648 | 0.1061 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,291 | **Within-R² =** 0.0372 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.4862 | 0.3401 | 1.430 | 0.1595 |
| PDSI_Lag1 | 0.3176 | 0.7321 | 0.434 | 0.6664 |
| PDSI_Lag2 | 0.7587*** | 0.2568 | 2.955 | 0.0049 |
| Z_Temp | -0.8653 | 0.7285 | -1.188 | 0.2409 |
| Z_Temp_Lag1 | 0.5737 | 0.7001 | 0.819 | 0.4167 |
| Z_Temp_Lag2 | -2.2550*** | 0.7305 | -3.087 | 0.0034 |
| Z_Precip | -0.2947 | 0.4418 | -0.667 | 0.5081 |
| Z_Precip_Lag1 | -0.1269 | 0.9535 | -0.133 | 0.8947 |
| Z_Precip_Lag2 | -0.6989 | 0.6489 | -1.077 | 0.2870 |
| Household_Income_2023 | 0.0006** | 0.0003 | 2.098 | 0.0413 |
| Uninsured_Rate | 152.6699 | 127.3864 | 1.198 | 0.2367 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,291 | **Within-R² =** 0.0243 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.2279 | 0.2166 | 1.052 | 0.2981 |
| PDSI_Lag1 | 0.3210 | 0.3098 | 1.036 | 0.3054 |
| PDSI_Lag2 | 0.7206*** | 0.2071 | 3.479 | 0.0011 |
| High_CDD | 1.1959 | 1.9794 | 0.604 | 0.5486 |
| High_CDD_Lag1 | 3.5102* | 2.0641 | 1.701 | 0.0956 |
| High_CDD_Lag2 | 1.8035 | 1.9186 | 0.940 | 0.3520 |
| High_HDD | 2.7274 | 2.1941 | 1.243 | 0.2200 |
| High_HDD_Lag1 | 1.7431 | 1.8384 | 0.948 | 0.3479 |
| High_HDD_Lag2 | -1.3841 | 2.4106 | -0.574 | 0.5686 |
| Household_Income_2023 | 0.0006** | 0.0003 | 2.396 | 0.0206 |
| Uninsured_Rate | 78.8749 | 144.7790 | 0.545 | 0.5885 |

---

## Outcome: `PCPI_Real`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,980 | **Within-R² =** 0.029 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -31.7362 | 120.1430 | -0.264 | 0.7928 |
| PDSI_Lag1 | -57.4353 | 96.4864 | -0.595 | 0.5545 |
| PDSI_Lag2 | -8.5422 | 77.0621 | -0.111 | 0.9122 |
| Z_Temp | 256.0669 | 170.2387 | 1.504 | 0.1392 |
| Z_Temp_Lag1 | 149.0897 | 141.3025 | 1.055 | 0.2968 |
| Z_Temp_Lag2 | 71.6834 | 116.2233 | 0.617 | 0.5404 |
| Z_Precip | -70.8721 | 107.8875 | -0.657 | 0.5144 |
| Z_Precip_Lag1 | -142.2800 | 161.6411 | -0.880 | 0.3832 |
| Z_Precip_Lag2 | -189.1451* | 102.6916 | -1.842 | 0.0718 |
| Household_Income_2023 | 0.1259** | 0.0480 | 2.624 | 0.0117 |
| Uninsured_Rate | -10367.5333** | 4755.9033 | -2.180 | 0.0343 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,980 | **Within-R² =** 0.0284 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -109.3232 | 78.4322 | -1.394 | 0.1699 |
| PDSI_Lag1 | -133.7258*** | 41.7115 | -3.206 | 0.0024 |
| PDSI_Lag2 | -75.3826 | 55.5199 | -1.358 | 0.1810 |
| High_CDD | 459.6674* | 252.0861 | 1.823 | 0.0746 |
| High_CDD_Lag1 | 480.2041** | 201.7804 | 2.380 | 0.0214 |
| High_CDD_Lag2 | 457.3599 | 296.6834 | 1.542 | 0.1299 |
| High_HDD | 124.3521 | 269.3939 | 0.462 | 0.6465 |
| High_HDD_Lag1 | 281.0939 | 576.9150 | 0.487 | 0.6284 |
| High_HDD_Lag2 | 812.5743* | 461.1840 | 1.762 | 0.0846 |
| Household_Income_2023 | 0.1261** | 0.0479 | 2.634 | 0.0114 |
| Uninsured_Rate | -11063.0873** | 5056.2128 | -2.188 | 0.0337 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,961 | **Within-R² =** 0.4449 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -75.5408 | 53.9510 | -1.400 | 0.1680 |
| PDSI_Lag1 | 12.2789 | 100.3165 | 0.122 | 0.9031 |
| PDSI_Lag2 | -112.9387** | 44.6225 | -2.531 | 0.0148 |
| Z_Temp | -53.7560 | 118.2685 | -0.455 | 0.6515 |
| Z_Temp_Lag1 | 86.1603 | 109.7738 | 0.785 | 0.4365 |
| Z_Temp_Lag2 | 183.0688* | 91.2335 | 2.007 | 0.0506 |
| Z_Precip | -79.9490 | 76.0069 | -1.052 | 0.2982 |
| Z_Precip_Lag1 | -204.9992* | 115.0922 | -1.781 | 0.0813 |
| Z_Precip_Lag2 | -48.4791 | 82.5021 | -0.588 | 0.5596 |
| Household_Income_2023 | 0.6361*** | 0.0915 | 6.952 | 0.0000 |
| Uninsured_Rate | -12235.2511 | 8100.3606 | -1.510 | 0.1376 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,961 | **Within-R² =** 0.4416 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -111.8226*** | 41.0269 | -2.726 | 0.0090 |
| PDSI_Lag1 | -108.5313** | 44.2107 | -2.455 | 0.0179 |
| PDSI_Lag2 | -137.3646*** | 38.0336 | -3.612 | 0.0007 |
| High_CDD | -2.8320 | 311.7021 | -0.009 | 0.9928 |
| High_CDD_Lag1 | -116.3690 | 334.5798 | -0.348 | 0.7295 |
| High_CDD_Lag2 | -86.4909 | 296.6346 | -0.292 | 0.7719 |
| High_HDD | -25.9911 | 190.5995 | -0.136 | 0.8921 |
| High_HDD_Lag1 | -9.6402 | 139.1784 | -0.069 | 0.9451 |
| High_HDD_Lag2 | 89.4649 | 150.2815 | 0.595 | 0.5545 |
| Household_Income_2023 | 0.6328*** | 0.0907 | 6.981 | 0.0000 |
| Uninsured_Rate | -16236.2771** | 7382.1328 | -2.199 | 0.0328 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,432 | **Within-R² =** 0.4415 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -205.7395*** | 37.2682 | -5.521 | 0.0000 |
| PDSI_Lag1 | -54.4972 | 114.4702 | -0.476 | 0.6362 |
| PDSI_Lag2 | -65.3002 | 61.6802 | -1.059 | 0.2952 |
| Z_Temp | -274.6975** | 119.7268 | -2.294 | 0.0263 |
| Z_Temp_Lag1 | -315.8850*** | 116.8292 | -2.704 | 0.0095 |
| Z_Temp_Lag2 | -231.6035** | 101.5369 | -2.281 | 0.0271 |
| Z_Precip | 158.1048*** | 51.1835 | 3.089 | 0.0034 |
| Z_Precip_Lag1 | 38.8305 | 170.4376 | 0.228 | 0.8208 |
| Z_Precip_Lag2 | 67.5108 | 145.7577 | 0.463 | 0.6454 |
| Household_Income_2023 | 0.5574*** | 0.0893 | 6.245 | 0.0000 |
| Uninsured_Rate | 16670.6835 | 21641.7801 | 0.770 | 0.4450 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,432 | **Within-R² =** 0.4292 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -102.3784*** | 28.4817 | -3.595 | 0.0008 |
| PDSI_Lag1 | -35.0920 | 44.6613 | -0.786 | 0.4360 |
| PDSI_Lag2 | -29.5563 | 37.8134 | -0.782 | 0.4383 |
| High_CDD | -165.6305 | 359.6098 | -0.461 | 0.6472 |
| High_CDD_Lag1 | -486.0184 | 419.4915 | -1.159 | 0.2525 |
| High_CDD_Lag2 | -875.3747* | 451.7339 | -1.938 | 0.0587 |
| High_HDD | 145.8949 | 425.7926 | 0.343 | 0.7334 |
| High_HDD_Lag1 | -327.3353 | 351.5242 | -0.931 | 0.3565 |
| High_HDD_Lag2 | 225.9336 | 318.8660 | 0.709 | 0.4821 |
| Household_Income_2023 | 0.5659*** | 0.0831 | 6.810 | 0.0000 |
| Uninsured_Rate | 8168.3005 | 15130.4630 | 0.540 | 0.5918 |

---

## Outcome: `Med_HH_Income_Real`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,976 | **Within-R² =** 0.4307 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -1.5082 | 20.5363 | -0.073 | 0.9418 |
| PDSI_Lag1 | -8.0057 | 21.6934 | -0.369 | 0.7138 |
| PDSI_Lag2 | -2.2955 | 17.0682 | -0.134 | 0.8936 |
| Z_Temp | -70.9319** | 31.7648 | -2.233 | 0.0303 |
| Z_Temp_Lag1 | -36.2068 | 26.6452 | -1.359 | 0.1807 |
| Z_Temp_Lag2 | -70.7085** | 34.5122 | -2.049 | 0.0461 |
| Z_Precip | 14.7297 | 25.5808 | 0.576 | 0.5675 |
| Z_Precip_Lag1 | 27.1444 | 31.2856 | 0.868 | 0.3900 |
| Z_Precip_Lag2 | 9.6306 | 25.9548 | 0.371 | 0.7123 |
| Household_Income_2023 | 0.5059*** | 0.0183 | 27.602 | 0.0000 |
| Uninsured_Rate | -7194.3365*** | 2445.0625 | -2.942 | 0.0050 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,976 | **Within-R² =** 0.4306 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 13.6679 | 14.3034 | 0.956 | 0.3442 |
| PDSI_Lag1 | 7.2847 | 14.3025 | 0.509 | 0.6129 |
| PDSI_Lag2 | 4.3881 | 13.1504 | 0.334 | 0.7401 |
| High_CDD | -247.0024** | 95.3314 | -2.591 | 0.0127 |
| High_CDD_Lag1 | 6.2090 | 56.8432 | 0.109 | 0.9135 |
| High_CDD_Lag2 | 31.7503 | 87.2136 | 0.364 | 0.7175 |
| High_HDD | 161.4830** | 79.4371 | 2.033 | 0.0477 |
| High_HDD_Lag1 | 62.8321 | 48.9412 | 1.284 | 0.2055 |
| High_HDD_Lag2 | 198.9887*** | 49.8939 | 3.988 | 0.0002 |
| Household_Income_2023 | 0.5056*** | 0.0183 | 27.561 | 0.0000 |
| Uninsured_Rate | -6822.8259*** | 2436.8711 | -2.800 | 0.0074 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,957 | **Within-R² =** 0.8071 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -23.5560* | 13.5776 | -1.735 | 0.0893 |
| PDSI_Lag1 | -17.5580 | 11.6078 | -1.513 | 0.1371 |
| PDSI_Lag2 | 9.2389 | 30.2989 | 0.305 | 0.7618 |
| Z_Temp | -88.0102*** | 23.9822 | -3.670 | 0.0006 |
| Z_Temp_Lag1 | -64.0355*** | 17.7657 | -3.604 | 0.0008 |
| Z_Temp_Lag2 | -59.8145** | 25.8396 | -2.315 | 0.0250 |
| Z_Precip | -20.0608 | 26.4387 | -0.759 | 0.4518 |
| Z_Precip_Lag1 | 27.9058 | 22.8223 | 1.223 | 0.2275 |
| Z_Precip_Lag2 | 0.7846 | 32.4008 | 0.024 | 0.9808 |
| Household_Income_2023 | 0.6749*** | 0.0237 | 28.446 | 0.0000 |
| Uninsured_Rate | -10390.6920*** | 3637.0345 | -2.857 | 0.0064 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,957 | **Within-R² =** 0.8058 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -15.7453 | 11.7329 | -1.342 | 0.1861 |
| PDSI_Lag1 | 12.0730 | 8.3255 | 1.450 | 0.1537 |
| PDSI_Lag2 | 13.3651 | 25.2040 | 0.530 | 0.5984 |
| High_CDD | -3.0953 | 68.5152 | -0.045 | 0.9642 |
| High_CDD_Lag1 | 18.4765 | 73.5552 | 0.251 | 0.8028 |
| High_CDD_Lag2 | -0.2959 | 73.2628 | -0.004 | 0.9968 |
| High_HDD | 172.8838*** | 47.5370 | 3.637 | 0.0007 |
| High_HDD_Lag1 | 20.2027 | 53.9227 | 0.375 | 0.7096 |
| High_HDD_Lag2 | 54.1791 | 68.4403 | 0.792 | 0.4326 |
| Household_Income_2023 | 0.6766*** | 0.0244 | 27.724 | 0.0000 |
| Uninsured_Rate | -9863.4509** | 3781.1225 | -2.609 | 0.0122 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,432 | **Within-R² =** 0.8885 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -42.6305** | 20.7755 | -2.052 | 0.0458 |
| PDSI_Lag1 | -34.8937* | 20.4321 | -1.708 | 0.0943 |
| PDSI_Lag2 | 41.7700 | 39.1004 | 1.068 | 0.2909 |
| Z_Temp | -128.1445* | 74.5781 | -1.718 | 0.0923 |
| Z_Temp_Lag1 | -134.7817*** | 37.6423 | -3.581 | 0.0008 |
| Z_Temp_Lag2 | -162.9135*** | 45.3632 | -3.591 | 0.0008 |
| Z_Precip | 22.7643 | 37.0977 | 0.614 | 0.5424 |
| Z_Precip_Lag1 | 34.1065 | 48.3552 | 0.705 | 0.4841 |
| Z_Precip_Lag2 | -21.6565 | 37.2331 | -0.582 | 0.5636 |
| Household_Income_2023 | 0.7016*** | 0.0129 | 54.504 | 0.0000 |
| Uninsured_Rate | -8981.3549 | 6260.6502 | -1.435 | 0.1580 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,432 | **Within-R² =** 0.8828 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -26.5826* | 13.7198 | -1.938 | 0.0587 |
| PDSI_Lag1 | -5.2258 | 15.8699 | -0.329 | 0.7434 |
| PDSI_Lag2 | 36.4020 | 33.5528 | 1.085 | 0.2835 |
| High_CDD | 48.8932 | 167.1844 | 0.292 | 0.7712 |
| High_CDD_Lag1 | 19.6804 | 188.6974 | 0.104 | 0.9174 |
| High_CDD_Lag2 | 16.7953 | 180.3710 | 0.093 | 0.9262 |
| High_HDD | 155.3964 | 109.0581 | 1.425 | 0.1608 |
| High_HDD_Lag1 | -110.8473 | 94.4321 | -1.174 | 0.2464 |
| High_HDD_Lag2 | -24.6076 | 100.7001 | -0.244 | 0.8080 |
| Household_Income_2023 | 0.7070*** | 0.0141 | 50.062 | 0.0000 |
| Uninsured_Rate | -15597.0298** | 7211.2798 | -2.163 | 0.0357 |

---

## Outcome: `Civilian_Employed`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,980 | **Within-R² =** 0.0386 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -18.8126 | 160.6380 | -0.117 | 0.9073 |
| PDSI_Lag1 | 0.0702 | 104.1534 | 0.001 | 0.9995 |
| PDSI_Lag2 | -70.5221 | 65.5569 | -1.076 | 0.2875 |
| Z_Temp | 423.5842 | 275.8339 | 1.536 | 0.1313 |
| Z_Temp_Lag1 | -47.7891 | 86.6077 | -0.552 | 0.5837 |
| Z_Temp_Lag2 | 788.0824** | 326.2915 | 2.415 | 0.0197 |
| Z_Precip | 46.4810 | 218.9102 | 0.212 | 0.8328 |
| Z_Precip_Lag1 | -87.6651 | 241.4805 | -0.363 | 0.7182 |
| Z_Precip_Lag2 | 19.8665 | 133.4860 | 0.149 | 0.8823 |
| Household_Income_2023 | 0.3600*** | 0.0842 | 4.274 | 0.0001 |
| Uninsured_Rate | -13610.2386 | 16552.0001 | -0.822 | 0.4151 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,980 | **Within-R² =** 0.0348 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -39.6471 | 67.5990 | -0.587 | 0.5603 |
| PDSI_Lag1 | -25.0999 | 37.7246 | -0.665 | 0.5091 |
| PDSI_Lag2 | -121.7223 | 74.1032 | -1.643 | 0.1071 |
| High_CDD | 42.9618 | 250.8225 | 0.171 | 0.8647 |
| High_CDD_Lag1 | 461.2256 | 279.7949 | 1.648 | 0.1059 |
| High_CDD_Lag2 | 385.5913* | 197.4537 | 1.953 | 0.0568 |
| High_HDD | -468.4261** | 229.7954 | -2.038 | 0.0472 |
| High_HDD_Lag1 | -290.6311 | 228.8855 | -1.270 | 0.2104 |
| High_HDD_Lag2 | -678.3389** | 328.8952 | -2.062 | 0.0447 |
| Household_Income_2023 | 0.3602*** | 0.0836 | 4.311 | 0.0001 |
| Uninsured_Rate | -17074.3181 | 17707.9444 | -0.964 | 0.3399 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,961 | **Within-R² =** 0.2977 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 5289.5554*** | 1854.6626 | 2.852 | 0.0064 |
| PDSI_Lag1 | 2084.9351*** | 580.7472 | 3.590 | 0.0008 |
| PDSI_Lag2 | 9.1739 | 1654.1898 | 0.006 | 0.9956 |
| Z_Temp | -1255.4300 | 1252.3684 | -1.002 | 0.3213 |
| Z_Temp_Lag1 | 952.2513 | 1484.9204 | 0.641 | 0.5245 |
| Z_Temp_Lag2 | 3216.1157 | 2393.6091 | 1.344 | 0.1855 |
| Z_Precip | -5742.3888*** | 1854.1648 | -3.097 | 0.0033 |
| Z_Precip_Lag1 | -3803.0859*** | 1101.5813 | -3.452 | 0.0012 |
| Z_Precip_Lag2 | -1199.4008 | 1011.9103 | -1.185 | 0.2419 |
| Household_Income_2023 | 2.4148*** | 0.7483 | 3.227 | 0.0023 |
| Uninsured_Rate | -1335020.6292** | 536047.1132 | -2.490 | 0.0163 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,961 | **Within-R² =** 0.2835 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 2472.2578* | 1380.9564 | 1.790 | 0.0799 |
| PDSI_Lag1 | 673.5530 | 527.9262 | 1.276 | 0.2083 |
| PDSI_Lag2 | -841.3962 | 1041.9164 | -0.808 | 0.4234 |
| High_CDD | -2930.5382 | 2177.5648 | -1.346 | 0.1848 |
| High_CDD_Lag1 | -3248.2058 | 3176.2841 | -1.023 | 0.3117 |
| High_CDD_Lag2 | -4538.3520 | 5264.8284 | -0.862 | 0.3931 |
| High_HDD | 2586.8870 | 2696.3373 | 0.959 | 0.3423 |
| High_HDD_Lag1 | 2744.3037 | 2148.9208 | 1.277 | 0.2079 |
| High_HDD_Lag2 | 3987.5514 | 3034.5699 | 1.314 | 0.1952 |
| Household_Income_2023 | 2.3302*** | 0.7444 | 3.130 | 0.0030 |
| Uninsured_Rate | -1436638.1346** | 552617.7339 | -2.600 | 0.0124 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,432 | **Within-R² =** 0.3441 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 4391.1015* | 2579.1347 | 1.703 | 0.0953 |
| PDSI_Lag1 | 981.5555 | 872.4081 | 1.125 | 0.2663 |
| PDSI_Lag2 | 862.0746 | 1008.3501 | 0.855 | 0.3969 |
| Z_Temp | -5030.3530* | 2764.5831 | -1.820 | 0.0752 |
| Z_Temp_Lag1 | 386.7531 | 1988.1831 | 0.195 | 0.8466 |
| Z_Temp_Lag2 | -2343.2542 | 2312.3012 | -1.013 | 0.3161 |
| Z_Precip | -5335.3889** | 2633.5027 | -2.026 | 0.0485 |
| Z_Precip_Lag1 | -3534.7133* | 1786.7772 | -1.978 | 0.0538 |
| Z_Precip_Lag2 | -2068.1952* | 1037.0384 | -1.994 | 0.0519 |
| Household_Income_2023 | 3.3245** | 1.2465 | 2.667 | 0.0105 |
| Uninsured_Rate | -1021211.2126** | 461652.5326 | -2.212 | 0.0319 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,432 | **Within-R² =** 0.2991 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 1787.1984 | 1634.7886 | 1.093 | 0.2799 |
| PDSI_Lag1 | -354.9334 | 642.8520 | -0.552 | 0.5835 |
| PDSI_Lag2 | 538.2412 | 341.8436 | 1.575 | 0.1221 |
| High_CDD | 2887.8473 | 2854.4937 | 1.012 | 0.3169 |
| High_CDD_Lag1 | -2133.4484 | 1778.3520 | -1.200 | 0.2363 |
| High_CDD_Lag2 | -6310.6838* | 3288.0463 | -1.919 | 0.0610 |
| High_HDD | -9894.0566 | 7487.8964 | -1.321 | 0.1928 |
| High_HDD_Lag1 | -5532.3193 | 3925.4428 | -1.409 | 0.1653 |
| High_HDD_Lag2 | 1947.4403 | 5119.9421 | 0.380 | 0.7054 |
| Household_Income_2023 | 2.9116** | 1.3642 | 2.134 | 0.0381 |
| Uninsured_Rate | -1206978.7621** | 541960.8517 | -2.227 | 0.0308 |

