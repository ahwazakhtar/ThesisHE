# County-Level Regression Results
**Generated:** 2026-07-12 15:46:50
**Input:** Data/county_level_master.csv
**Model:** Two-way FE (fips_code + Year), cluster = State (primary), `fixest::feols`
**Specs:** Spec1 = Z-Temp/Z-Precip (relative shocks); Spec2 = High CDD/HDD (absolute burden); _AQI = +AQI_Shock; _RA_Cluster = Rating-Area clustered SEs

Significance: \*p<0.10, \*\*p<0.05, \*\*\*p<0.01

---

## Outcome: `Medical_Debt_Share`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 32,533 | **Within-R² =** 0.0237 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.0007 | 0.0006 | -1.183 | 0.2428 |
| PDSI_Lag1 | -0.0004 | 0.0005 | -0.716 | 0.4772 |
| PDSI_Lag2 | 0.0001 | 0.0005 | 0.105 | 0.9168 |
| Z_Temp | -0.0026* | 0.0014 | -1.846 | 0.0712 |
| Z_Temp_Lag1 | -0.0015 | 0.0009 | -1.615 | 0.1129 |
| Z_Temp_Lag2 | -0.0027** | 0.0010 | -2.670 | 0.0104 |
| Z_Precip | 0.0011 | 0.0008 | 1.400 | 0.1680 |
| Z_Precip_Lag1 | 0.0011 | 0.0009 | 1.213 | 0.2313 |
| Z_Precip_Lag2 | -0.0004 | 0.0007 | -0.493 | 0.6242 |
| Household_Income_2023 | 0.0000* | 0.0000 | 1.717 | 0.0925 |
| Uninsured_Rate | 0.2246*** | 0.0693 | 3.240 | 0.0022 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 32,533 | **Within-R² =** 0.0178 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.0001 | 0.0004 | 0.287 | 0.7751 |
| PDSI_Lag1 | 0.0001 | 0.0003 | 0.283 | 0.7786 |
| PDSI_Lag2 | -0.0001 | 0.0003 | -0.320 | 0.7505 |
| High_CDD | -0.0040 | 0.0031 | -1.283 | 0.2056 |
| High_CDD_Lag1 | -0.0038 | 0.0024 | -1.586 | 0.1194 |
| High_CDD_Lag2 | -0.0044** | 0.0017 | -2.638 | 0.0113 |
| High_HDD | 0.0038** | 0.0017 | 2.205 | 0.0324 |
| High_HDD_Lag1 | 0.0013 | 0.0014 | 0.923 | 0.3605 |
| High_HDD_Lag2 | 0.0031* | 0.0017 | 1.860 | 0.0692 |
| Household_Income_2023 | 0.0000* | 0.0000 | 1.704 | 0.0950 |
| Uninsured_Rate | 0.2424*** | 0.0723 | 3.352 | 0.0016 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 32,514 | **Within-R² =** 0.0501 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.0002 | 0.0004 | -0.599 | 0.5523 |
| PDSI_Lag1 | -0.0005 | 0.0004 | -1.282 | 0.2063 |
| PDSI_Lag2 | -0.0006 | 0.0004 | -1.640 | 0.1077 |
| Z_Temp | -0.0002 | 0.0007 | -0.319 | 0.7508 |
| Z_Temp_Lag1 | -0.0003 | 0.0006 | -0.455 | 0.6513 |
| Z_Temp_Lag2 | -0.0015* | 0.0008 | -1.960 | 0.0559 |
| Z_Precip | 0.0010 | 0.0007 | 1.310 | 0.1964 |
| Z_Precip_Lag1 | 0.0014* | 0.0007 | 1.864 | 0.0686 |
| Z_Precip_Lag2 | 0.0011* | 0.0006 | 1.773 | 0.0827 |
| Household_Income_2023 | 0.0000*** | 0.0000 | 3.873 | 0.0003 |
| Uninsured_Rate | 0.3220*** | 0.0655 | 4.920 | 0.0000 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 32,514 | **Within-R² =** 0.0475 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.0003 | 0.0004 | 0.972 | 0.3358 |
| PDSI_Lag1 | 0.0001 | 0.0003 | 0.493 | 0.6244 |
| PDSI_Lag2 | -0.0001 | 0.0003 | -0.157 | 0.8756 |
| High_CDD | 0.0004 | 0.0026 | 0.158 | 0.8755 |
| High_CDD_Lag1 | -0.0008 | 0.0025 | -0.327 | 0.7449 |
| High_CDD_Lag2 | -0.0017 | 0.0024 | -0.694 | 0.4913 |
| High_HDD | 0.0053** | 0.0021 | 2.522 | 0.0151 |
| High_HDD_Lag1 | 0.0018 | 0.0019 | 0.911 | 0.3670 |
| High_HDD_Lag2 | 0.0038* | 0.0021 | 1.844 | 0.0715 |
| Household_Income_2023 | 0.0000*** | 0.0000 | 4.058 | 0.0002 |
| Uninsured_Rate | 0.3463*** | 0.0639 | 5.420 | 0.0000 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,442 | **Within-R² =** 0.0908 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.0004 | 0.0007 | 0.629 | 0.5327 |
| PDSI_Lag1 | 0.0004 | 0.0006 | 0.689 | 0.4942 |
| PDSI_Lag2 | 0.0001 | 0.0004 | 0.228 | 0.8209 |
| Z_Temp | 0.0011 | 0.0012 | 0.951 | 0.3462 |
| Z_Temp_Lag1 | 0.0016 | 0.0012 | 1.371 | 0.1768 |
| Z_Temp_Lag2 | 0.0015 | 0.0011 | 1.379 | 0.1743 |
| Z_Precip | -0.0006 | 0.0008 | -0.797 | 0.4294 |
| Z_Precip_Lag1 | -0.0003 | 0.0010 | -0.269 | 0.7891 |
| Z_Precip_Lag2 | -0.0001 | 0.0007 | -0.144 | 0.8863 |
| Household_Income_2023 | 0.0000*** | 0.0000 | 6.437 | 0.0000 |
| Uninsured_Rate | 0.5026*** | 0.1285 | 3.911 | 0.0003 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,442 | **Within-R² =** 0.0858 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.0001 | 0.0005 | 0.147 | 0.8835 |
| PDSI_Lag1 | 0.0002 | 0.0004 | 0.405 | 0.6871 |
| PDSI_Lag2 | 0.0000 | 0.0003 | 0.065 | 0.9487 |
| High_CDD | 0.0018 | 0.0039 | 0.450 | 0.6551 |
| High_CDD_Lag1 | 0.0001 | 0.0043 | 0.018 | 0.9859 |
| High_CDD_Lag2 | 0.0021 | 0.0050 | 0.422 | 0.6751 |
| High_HDD | 0.0085 | 0.0057 | 1.488 | 0.1433 |
| High_HDD_Lag1 | -0.0017 | 0.0041 | -0.417 | 0.6789 |
| High_HDD_Lag2 | 0.0038 | 0.0043 | 0.881 | 0.3828 |
| Household_Income_2023 | 0.0000*** | 0.0000 | 6.048 | 0.0000 |
| Uninsured_Rate | 0.5334*** | 0.1233 | 4.328 | 0.0001 |

---

## Outcome: `Medical_Debt_Median_2023`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 22,925 | **Within-R² =** 0.0199 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -2.3838 | 4.3098 | -0.553 | 0.5828 |
| PDSI_Lag1 | -1.1375 | 3.5128 | -0.324 | 0.7475 |
| PDSI_Lag2 | -1.3552 | 3.3209 | -0.408 | 0.6851 |
| Z_Temp | 14.5599* | 7.6478 | 1.904 | 0.0631 |
| Z_Temp_Lag1 | -3.2612 | 5.2678 | -0.619 | 0.5389 |
| Z_Temp_Lag2 | 19.8456** | 7.7936 | 2.546 | 0.0142 |
| Z_Precip | 3.2794 | 3.7531 | 0.874 | 0.3867 |
| Z_Precip_Lag1 | 4.6487 | 5.4963 | 0.846 | 0.4020 |
| Z_Precip_Lag2 | 8.3046* | 4.7660 | 1.742 | 0.0880 |
| Household_Income_2023 | -0.0024** | 0.0009 | -2.582 | 0.0130 |
| Uninsured_Rate | 1778.6158*** | 477.8415 | 3.722 | 0.0005 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 22,925 | **Within-R² =** 0.0142 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -2.0307 | 3.2606 | -0.623 | 0.5364 |
| PDSI_Lag1 | 2.6520 | 2.1518 | 1.232 | 0.2239 |
| PDSI_Lag2 | 0.1053 | 2.2738 | 0.046 | 0.9633 |
| High_CDD | -7.6057 | 17.1416 | -0.444 | 0.6593 |
| High_CDD_Lag1 | 13.8109 | 15.4890 | 0.892 | 0.3771 |
| High_CDD_Lag2 | 10.0697 | 14.3765 | 0.700 | 0.4871 |
| High_HDD | 10.5937 | 11.2834 | 0.939 | 0.3526 |
| High_HDD_Lag1 | -1.1757 | 10.9661 | -0.107 | 0.9151 |
| High_HDD_Lag2 | -1.1329 | 16.6884 | -0.068 | 0.9462 |
| Household_Income_2023 | -0.0025** | 0.0010 | -2.501 | 0.0159 |
| Uninsured_Rate | 1658.9682*** | 473.1326 | 3.506 | 0.0010 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 22,914 | **Within-R² =** 0.0431 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 1.7287 | 2.9299 | 0.590 | 0.5580 |
| PDSI_Lag1 | 3.9717 | 2.7175 | 1.462 | 0.1505 |
| PDSI_Lag2 | -1.0030 | 2.2289 | -0.450 | 0.6548 |
| Z_Temp | 19.1374*** | 5.0708 | 3.774 | 0.0004 |
| Z_Temp_Lag1 | -1.2380 | 4.6568 | -0.266 | 0.7915 |
| Z_Temp_Lag2 | 15.8400*** | 4.5039 | 3.517 | 0.0010 |
| Z_Precip | 2.0063 | 3.3092 | 0.606 | 0.5472 |
| Z_Precip_Lag1 | -2.1701 | 5.6324 | -0.385 | 0.7018 |
| Z_Precip_Lag2 | 5.8913 | 4.8592 | 1.212 | 0.2314 |
| Household_Income_2023 | -0.0027* | 0.0015 | -1.785 | 0.0808 |
| Uninsured_Rate | 1900.1600*** | 412.1612 | 4.610 | 0.0000 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 22,914 | **Within-R² =** 0.0308 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.2067 | 3.2586 | -0.063 | 0.9497 |
| PDSI_Lag1 | 2.7135 | 2.3131 | 1.173 | 0.2467 |
| PDSI_Lag2 | -0.5538 | 2.4811 | -0.223 | 0.8243 |
| High_CDD | -19.5645 | 16.7396 | -1.169 | 0.2484 |
| High_CDD_Lag1 | -5.1498 | 20.6705 | -0.249 | 0.8043 |
| High_CDD_Lag2 | -21.4181 | 19.0543 | -1.124 | 0.2667 |
| High_HDD | 31.1861** | 13.1763 | 2.367 | 0.0221 |
| High_HDD_Lag1 | 18.3458 | 17.4418 | 1.052 | 0.2983 |
| High_HDD_Lag2 | 26.4888 | 28.2144 | 0.939 | 0.3526 |
| Household_Income_2023 | -0.0031** | 0.0014 | -2.151 | 0.0367 |
| Uninsured_Rate | 1711.2133*** | 471.5310 | 3.629 | 0.0007 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,345 | **Within-R² =** 0.074 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 5.8326 | 4.4404 | 1.314 | 0.1954 |
| PDSI_Lag1 | 1.9534 | 4.5735 | 0.427 | 0.6712 |
| PDSI_Lag2 | -6.2491** | 2.9270 | -2.135 | 0.0380 |
| Z_Temp | 15.2529* | 8.2901 | 1.840 | 0.0721 |
| Z_Temp_Lag1 | 8.4708 | 7.1071 | 1.192 | 0.2393 |
| Z_Temp_Lag2 | 18.4742*** | 5.3827 | 3.432 | 0.0013 |
| Z_Precip | -8.1430 | 4.8599 | -1.676 | 0.1005 |
| Z_Precip_Lag1 | -9.5170 | 6.6341 | -1.435 | 0.1580 |
| Z_Precip_Lag2 | 3.5419 | 4.5814 | 0.773 | 0.4433 |
| Household_Income_2023 | -0.0004 | 0.0018 | -0.220 | 0.8267 |
| Uninsured_Rate | 2528.8504*** | 742.3660 | 3.406 | 0.0014 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,345 | **Within-R² =** 0.0594 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.0706 | 3.1741 | 0.022 | 0.9823 |
| PDSI_Lag1 | -2.8742 | 1.9588 | -1.467 | 0.1490 |
| PDSI_Lag2 | -5.1392* | 3.0423 | -1.689 | 0.0978 |
| High_CDD | -51.1701** | 23.9480 | -2.137 | 0.0379 |
| High_CDD_Lag1 | -41.4307 | 35.9802 | -1.151 | 0.2554 |
| High_CDD_Lag2 | -37.5879 | 29.2419 | -1.285 | 0.2049 |
| High_HDD | 6.5604 | 39.8249 | 0.165 | 0.8699 |
| High_HDD_Lag1 | -38.1725* | 20.2657 | -1.884 | 0.0658 |
| High_HDD_Lag2 | 5.6380 | 32.8271 | 0.172 | 0.8644 |
| Household_Income_2023 | -0.0017 | 0.0015 | -1.130 | 0.2643 |
| Uninsured_Rate | 2965.3703*** | 846.1677 | 3.504 | 0.0010 |

---

## Outcome: `Benchmark_Silver_Real`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 27,222 | **Within-R² =** 0.0207 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 3.0524 | 2.3773 | 1.284 | 0.2054 |
| PDSI_Lag1 | 3.7931 | 2.4821 | 1.528 | 0.1332 |
| PDSI_Lag2 | 0.9692 | 3.6411 | 0.266 | 0.7913 |
| Z_Temp | -10.2327 | 7.2684 | -1.408 | 0.1658 |
| Z_Temp_Lag1 | 3.8335 | 4.9882 | 0.769 | 0.4460 |
| Z_Temp_Lag2 | 0.8967 | 5.3150 | 0.169 | 0.8668 |
| Z_Precip | -2.5197 | 2.3809 | -1.058 | 0.2953 |
| Z_Precip_Lag1 | -5.7043 | 4.0072 | -1.424 | 0.1612 |
| Z_Precip_Lag2 | -5.2583 | 3.1760 | -1.656 | 0.1045 |
| Household_Income_2023 | -0.0007** | 0.0003 | -2.585 | 0.0129 |
| Uninsured_Rate | 184.3799 | 119.7094 | 1.540 | 0.1302 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 27,222 | **Within-R² =** 0.0197 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 2.1756 | 1.5477 | 1.406 | 0.1664 |
| PDSI_Lag1 | 0.3589 | 1.1693 | 0.307 | 0.7603 |
| PDSI_Lag2 | -0.0079 | 2.8685 | -0.003 | 0.9978 |
| High_CDD | 6.2645 | 10.3077 | 0.608 | 0.5463 |
| High_CDD_Lag1 | 8.9765 | 12.2410 | 0.733 | 0.4670 |
| High_CDD_Lag2 | 21.4446* | 11.6548 | 1.840 | 0.0721 |
| High_HDD | 27.3440*** | 9.8212 | 2.784 | 0.0077 |
| High_HDD_Lag1 | -24.4478 | 14.7179 | -1.661 | 0.1034 |
| High_HDD_Lag2 | -8.0327 | 8.2374 | -0.975 | 0.3345 |
| Household_Income_2023 | -0.0008** | 0.0003 | -2.573 | 0.0133 |
| Uninsured_Rate | 184.3461 | 124.7076 | 1.478 | 0.1460 |

#### Spec 1 (Rating-Area Clustered SEs)
**N =** 27,222 | **Within-R² =** 0.0207 | **Cluster =** rating_area_id | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 3.0524* | 1.6838 | 1.813 | 0.0705 |
| PDSI_Lag1 | 3.7931* | 2.0078 | 1.889 | 0.0595 |
| PDSI_Lag2 | 0.9692 | 3.0054 | 0.322 | 0.7472 |
| Z_Temp | -10.2327** | 5.0083 | -2.043 | 0.0416 |
| Z_Temp_Lag1 | 3.8335 | 3.8222 | 1.003 | 0.3164 |
| Z_Temp_Lag2 | 0.8967 | 3.1480 | 0.285 | 0.7759 |
| Z_Precip | -2.5197 | 1.9453 | -1.295 | 0.1958 |
| Z_Precip_Lag1 | -5.7043* | 3.3227 | -1.717 | 0.0866 |
| Z_Precip_Lag2 | -5.2583** | 2.4291 | -2.165 | 0.0309 |
| Household_Income_2023 | -0.0007*** | 0.0003 | -2.629 | 0.0088 |
| Uninsured_Rate | 184.3799** | 81.7237 | 2.256 | 0.0245 |

#### Spec 2 (Rating-Area Clustered SEs)
**N =** 27,222 | **Within-R² =** 0.0197 | **Cluster =** rating_area_id | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 2.1756** | 1.0157 | 2.142 | 0.0327 |
| PDSI_Lag1 | 0.3589 | 0.9067 | 0.396 | 0.6924 |
| PDSI_Lag2 | -0.0079 | 2.4025 | -0.003 | 0.9974 |
| High_CDD | 6.2645 | 7.4941 | 0.836 | 0.4036 |
| High_CDD_Lag1 | 8.9765 | 8.4670 | 1.060 | 0.2896 |
| High_CDD_Lag2 | 21.4446*** | 8.2523 | 2.599 | 0.0096 |
| High_HDD | 27.3440*** | 7.5854 | 3.605 | 0.0003 |
| High_HDD_Lag1 | -24.4478*** | 8.4719 | -2.886 | 0.0041 |
| High_HDD_Lag2 | -8.0327 | 6.0323 | -1.332 | 0.1836 |
| Household_Income_2023 | -0.0008*** | 0.0003 | -2.669 | 0.0079 |
| Uninsured_Rate | 184.3461** | 83.2839 | 2.213 | 0.0273 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 27,208 | **Within-R² =** 0.0315 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 4.5211 | 5.1045 | 0.886 | 0.3803 |
| PDSI_Lag1 | -2.5150 | 2.2933 | -1.097 | 0.2784 |
| PDSI_Lag2 | 0.5984 | 1.9869 | 0.301 | 0.7646 |
| Z_Temp | 2.2726 | 4.8091 | 0.473 | 0.6387 |
| Z_Temp_Lag1 | 5.8639 | 4.7927 | 1.224 | 0.2272 |
| Z_Temp_Lag2 | 2.6296 | 3.8006 | 0.692 | 0.4924 |
| Z_Precip | -1.5144 | 4.4959 | -0.337 | 0.7377 |
| Z_Precip_Lag1 | 0.6177 | 4.9249 | 0.125 | 0.9007 |
| Z_Precip_Lag2 | -5.9178 | 4.7207 | -1.254 | 0.2162 |
| Household_Income_2023 | -0.0007 | 0.0005 | -1.443 | 0.1556 |
| Uninsured_Rate | 381.9483** | 187.2873 | 2.039 | 0.0471 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 27,208 | **Within-R² =** 0.0352 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 3.2671 | 3.4383 | 0.950 | 0.3469 |
| PDSI_Lag1 | -2.4270** | 1.0754 | -2.257 | 0.0287 |
| PDSI_Lag2 | -2.1263 | 2.0573 | -1.034 | 0.3066 |
| High_CDD | 19.8107** | 9.0164 | 2.197 | 0.0330 |
| High_CDD_Lag1 | 30.0525** | 11.6064 | 2.589 | 0.0128 |
| High_CDD_Lag2 | 32.8584*** | 10.3008 | 3.190 | 0.0025 |
| High_HDD | 20.6089** | 8.4070 | 2.451 | 0.0180 |
| High_HDD_Lag1 | -19.7550 | 20.0114 | -0.987 | 0.3286 |
| High_HDD_Lag2 | 1.3411 | 11.7834 | 0.114 | 0.9099 |
| Household_Income_2023 | -0.0009* | 0.0005 | -1.843 | 0.0716 |
| Uninsured_Rate | 426.0631** | 194.9141 | 2.186 | 0.0338 |

#### Spec 1 (Rating-Area Clustered SEs)
**N =** 27,208 | **Within-R² =** 0.0315 | **Cluster =** rating_area_id | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 4.5211 | 2.7544 | 1.641 | 0.1013 |
| PDSI_Lag1 | -2.5150* | 1.4704 | -1.710 | 0.0878 |
| PDSI_Lag2 | 0.5984 | 1.7288 | 0.346 | 0.7294 |
| Z_Temp | 2.2726 | 2.9275 | 0.776 | 0.4379 |
| Z_Temp_Lag1 | 5.8639** | 2.5646 | 2.286 | 0.0226 |
| Z_Temp_Lag2 | 2.6296 | 2.0352 | 1.292 | 0.1969 |
| Z_Precip | -1.5144 | 3.2284 | -0.469 | 0.6392 |
| Z_Precip_Lag1 | 0.6177 | 3.7406 | 0.165 | 0.8689 |
| Z_Precip_Lag2 | -5.9178 | 4.7308 | -1.251 | 0.2116 |
| Household_Income_2023 | -0.0007** | 0.0003 | -2.167 | 0.0307 |
| Uninsured_Rate | 381.9483*** | 118.7975 | 3.215 | 0.0014 |

#### Spec 2 (Rating-Area Clustered SEs)
**N =** 27,208 | **Within-R² =** 0.0352 | **Cluster =** rating_area_id | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 3.2671 | 2.0653 | 1.582 | 0.1143 |
| PDSI_Lag1 | -2.4270*** | 0.6905 | -3.515 | 0.0005 |
| PDSI_Lag2 | -2.1263 | 1.4948 | -1.422 | 0.1555 |
| High_CDD | 19.8107*** | 6.4514 | 3.071 | 0.0023 |
| High_CDD_Lag1 | 30.0525*** | 8.9308 | 3.365 | 0.0008 |
| High_CDD_Lag2 | 32.8584*** | 9.4398 | 3.481 | 0.0005 |
| High_HDD | 20.6089*** | 7.6062 | 2.709 | 0.0070 |
| High_HDD_Lag1 | -19.7550 | 14.0117 | -1.410 | 0.1592 |
| High_HDD_Lag2 | 1.3411 | 7.5951 | 0.177 | 0.8599 |
| Household_Income_2023 | -0.0009*** | 0.0003 | -2.829 | 0.0049 |
| Uninsured_Rate | 426.0631*** | 115.9864 | 3.673 | 0.0003 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,433 | **Within-R² =** 0.0386 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 3.6392 | 6.3220 | 0.576 | 0.5676 |
| PDSI_Lag1 | -4.4906* | 2.3719 | -1.893 | 0.0645 |
| PDSI_Lag2 | -1.4040 | 2.2615 | -0.621 | 0.5377 |
| Z_Temp | 8.3134 | 5.5995 | 1.485 | 0.1443 |
| Z_Temp_Lag1 | 4.3318 | 7.5039 | 0.577 | 0.5665 |
| Z_Temp_Lag2 | 0.3742 | 5.1666 | 0.072 | 0.9426 |
| Z_Precip | 4.0140 | 5.7002 | 0.704 | 0.4848 |
| Z_Precip_Lag1 | 2.0690 | 5.2725 | 0.392 | 0.6965 |
| Z_Precip_Lag2 | -4.2919 | 4.8940 | -0.877 | 0.3850 |
| Household_Income_2023 | -0.0003 | 0.0007 | -0.421 | 0.6758 |
| Uninsured_Rate | -36.0597 | 327.1718 | -0.110 | 0.9127 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,433 | **Within-R² =** 0.04 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 4.9463 | 4.7802 | 1.035 | 0.3061 |
| PDSI_Lag1 | -3.7985*** | 1.3727 | -2.767 | 0.0081 |
| PDSI_Lag2 | -3.1226 | 2.5585 | -1.220 | 0.2284 |
| High_CDD | 26.2929 | 16.0126 | 1.642 | 0.1073 |
| High_CDD_Lag1 | 27.3194* | 15.5583 | 1.756 | 0.0856 |
| High_CDD_Lag2 | 32.5812** | 13.6704 | 2.383 | 0.0212 |
| High_HDD | 39.3408** | 18.7697 | 2.096 | 0.0415 |
| High_HDD_Lag1 | -47.0008 | 40.6718 | -1.156 | 0.2537 |
| High_HDD_Lag2 | 6.0144 | 20.8775 | 0.288 | 0.7745 |
| Household_Income_2023 | 0.0001 | 0.0009 | 0.097 | 0.9235 |
| Uninsured_Rate | 20.0317 | 331.1469 | 0.060 | 0.9520 |

---

## Outcome: `Hosp_BadDebt_PerCapita`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 26,407 | **Within-R² =** 0.0064 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.2896 | 0.3663 | -0.791 | 0.4331 |
| PDSI_Lag1 | -0.0029 | 0.3971 | -0.007 | 0.9943 |
| PDSI_Lag2 | 0.0003 | 0.4176 | 0.001 | 0.9993 |
| Z_Temp | -1.2588 | 0.8475 | -1.485 | 0.1442 |
| Z_Temp_Lag1 | -0.3066 | 0.5649 | -0.543 | 0.5899 |
| Z_Temp_Lag2 | -2.4164*** | 0.7525 | -3.211 | 0.0024 |
| Z_Precip | 0.1691 | 0.5809 | 0.291 | 0.7722 |
| Z_Precip_Lag1 | 0.9701 | 0.6443 | 1.506 | 0.1388 |
| Z_Precip_Lag2 | -0.1580 | 0.6811 | -0.232 | 0.8176 |
| Household_Income_2023 | 0.0003 | 0.0002 | 1.638 | 0.1082 |
| Uninsured_Rate | 150.7657*** | 52.2293 | 2.887 | 0.0059 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 26,407 | **Within-R² =** 0.0052 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -0.0625 | 0.3483 | -0.179 | 0.8584 |
| PDSI_Lag1 | 0.5602* | 0.3136 | 1.786 | 0.0805 |
| PDSI_Lag2 | -0.0019 | 0.2099 | -0.009 | 0.9928 |
| High_CDD | 2.4076 | 1.9824 | 1.214 | 0.2306 |
| High_CDD_Lag1 | 2.1350 | 1.8060 | 1.182 | 0.2431 |
| High_CDD_Lag2 | 1.8904 | 2.5059 | 0.754 | 0.4544 |
| High_HDD | 5.2792*** | 1.9535 | 2.702 | 0.0095 |
| High_HDD_Lag1 | -0.3023 | 1.1396 | -0.265 | 0.7920 |
| High_HDD_Lag2 | 2.4117 | 1.6646 | 1.449 | 0.1540 |
| Household_Income_2023 | 0.0003 | 0.0002 | 1.616 | 0.1129 |
| Uninsured_Rate | 165.9454*** | 52.5554 | 3.158 | 0.0028 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 26,407 | **Within-R² =** 0.0187 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.1709 | 0.2564 | 0.667 | 0.5083 |
| PDSI_Lag1 | 0.1776 | 0.4952 | 0.359 | 0.7215 |
| PDSI_Lag2 | 0.3054 | 0.2407 | 1.269 | 0.2108 |
| Z_Temp | -1.0942** | 0.4363 | -2.508 | 0.0157 |
| Z_Temp_Lag1 | 0.3540 | 0.4918 | 0.720 | 0.4753 |
| Z_Temp_Lag2 | -2.1304*** | 0.5076 | -4.197 | 0.0001 |
| Z_Precip | 0.2472 | 0.4147 | 0.596 | 0.5540 |
| Z_Precip_Lag1 | 0.5793 | 0.8011 | 0.723 | 0.4732 |
| Z_Precip_Lag2 | -0.3879 | 0.7128 | -0.544 | 0.5888 |
| Household_Income_2023 | 0.0003* | 0.0002 | 1.859 | 0.0692 |
| Uninsured_Rate | 158.9398 | 96.8246 | 1.642 | 0.1074 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 26,407 | **Within-R² =** 0.0147 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.4039** | 0.1918 | 2.106 | 0.0406 |
| PDSI_Lag1 | 0.4502 | 0.3099 | 1.453 | 0.1530 |
| PDSI_Lag2 | 0.4288 | 0.2650 | 1.618 | 0.1124 |
| High_CDD | 1.0843 | 1.4258 | 0.760 | 0.4508 |
| High_CDD_Lag1 | 2.8823* | 1.6611 | 1.735 | 0.0893 |
| High_CDD_Lag2 | 2.1191 | 1.5136 | 1.400 | 0.1681 |
| High_HDD | 4.2836** | 1.9852 | 2.158 | 0.0361 |
| High_HDD_Lag1 | -0.8276 | 1.5644 | -0.529 | 0.5993 |
| High_HDD_Lag2 | -0.8455 | 1.5355 | -0.551 | 0.5845 |
| Household_Income_2023 | 0.0004** | 0.0002 | 2.016 | 0.0496 |
| Uninsured_Rate | 189.6545* | 98.7261 | 1.921 | 0.0608 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,280 | **Within-R² =** 0.0314 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.3277 | 0.3755 | 0.873 | 0.3873 |
| PDSI_Lag1 | 0.2354 | 0.7803 | 0.302 | 0.7642 |
| PDSI_Lag2 | 0.6570** | 0.2684 | 2.447 | 0.0182 |
| Z_Temp | -1.0111 | 0.7896 | -1.281 | 0.2066 |
| Z_Temp_Lag1 | 0.5554 | 0.7396 | 0.751 | 0.4564 |
| Z_Temp_Lag2 | -2.4451*** | 0.7657 | -3.193 | 0.0025 |
| Z_Precip | -0.1632 | 0.4652 | -0.351 | 0.7273 |
| Z_Precip_Lag1 | -0.0489 | 0.9992 | -0.049 | 0.9612 |
| Z_Precip_Lag2 | -0.6724 | 0.6285 | -1.070 | 0.2901 |
| Household_Income_2023 | 0.0005* | 0.0003 | 1.731 | 0.0900 |
| Uninsured_Rate | 157.1630 | 121.8308 | 1.290 | 0.2034 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,280 | **Within-R² =** 0.018 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 0.1223 | 0.2269 | 0.539 | 0.5926 |
| PDSI_Lag1 | 0.2494 | 0.3296 | 0.757 | 0.4531 |
| PDSI_Lag2 | 0.6326** | 0.2387 | 2.650 | 0.0109 |
| High_CDD | 0.9239 | 1.9866 | 0.465 | 0.6440 |
| High_CDD_Lag1 | 3.3207 | 2.1002 | 1.581 | 0.1205 |
| High_CDD_Lag2 | 1.8579 | 1.9253 | 0.965 | 0.3395 |
| High_HDD | 3.0750 | 2.2924 | 1.341 | 0.1862 |
| High_HDD_Lag1 | 1.9387 | 1.7687 | 1.096 | 0.2786 |
| High_HDD_Lag2 | -1.4070 | 2.5225 | -0.558 | 0.5796 |
| Household_Income_2023 | 0.0005** | 0.0003 | 2.167 | 0.0353 |
| Uninsured_Rate | 94.5665 | 143.0796 | 0.661 | 0.5119 |

---

## Outcome: `PCPI_Real`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,604 | **Within-R² =** 0.0289 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -31.9424 | 120.8082 | -0.264 | 0.7926 |
| PDSI_Lag1 | -53.4351 | 97.1547 | -0.550 | 0.5849 |
| PDSI_Lag2 | -0.0572 | 75.5150 | -0.001 | 0.9994 |
| Z_Temp | 241.5396 | 162.1380 | 1.490 | 0.1430 |
| Z_Temp_Lag1 | 160.1553 | 142.0146 | 1.128 | 0.2652 |
| Z_Temp_Lag2 | 76.4104 | 116.7289 | 0.655 | 0.5159 |
| Z_Precip | -72.5946 | 109.0664 | -0.666 | 0.5089 |
| Z_Precip_Lag1 | -144.6394 | 162.2173 | -0.892 | 0.3771 |
| Z_Precip_Lag2 | -196.0752* | 102.5334 | -1.912 | 0.0619 |
| Household_Income_2023 | 0.1250** | 0.0483 | 2.591 | 0.0127 |
| Uninsured_Rate | -11011.4153** | 4794.8529 | -2.297 | 0.0262 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,604 | **Within-R² =** 0.0282 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -108.9304 | 79.1222 | -1.377 | 0.1751 |
| PDSI_Lag1 | -132.8196*** | 41.7113 | -3.184 | 0.0026 |
| PDSI_Lag2 | -70.5853 | 54.9592 | -1.284 | 0.2053 |
| High_CDD | 454.2535* | 249.7017 | 1.819 | 0.0753 |
| High_CDD_Lag1 | 481.8870** | 201.1055 | 2.396 | 0.0206 |
| High_CDD_Lag2 | 463.3414 | 295.7516 | 1.567 | 0.1239 |
| High_HDD | 126.3323 | 272.7034 | 0.463 | 0.6453 |
| High_HDD_Lag1 | 233.4870 | 548.1636 | 0.426 | 0.6721 |
| High_HDD_Lag2 | 791.5885* | 448.8370 | 1.764 | 0.0843 |
| Household_Income_2023 | 0.1251** | 0.0482 | 2.596 | 0.0126 |
| Uninsured_Rate | -11738.2588** | 5099.8850 | -2.302 | 0.0258 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,585 | **Within-R² =** 0.4396 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -84.3109 | 54.3513 | -1.551 | 0.1276 |
| PDSI_Lag1 | 12.1151 | 100.2678 | 0.121 | 0.9043 |
| PDSI_Lag2 | -104.7997** | 45.1849 | -2.319 | 0.0248 |
| Z_Temp | -58.5163 | 123.1635 | -0.475 | 0.6369 |
| Z_Temp_Lag1 | 110.6467 | 113.8816 | 0.972 | 0.3362 |
| Z_Temp_Lag2 | 191.3839** | 93.8001 | 2.040 | 0.0470 |
| Z_Precip | -79.8640 | 77.6591 | -1.028 | 0.3090 |
| Z_Precip_Lag1 | -205.6632* | 114.1414 | -1.802 | 0.0780 |
| Z_Precip_Lag2 | -58.1508 | 78.4782 | -0.741 | 0.4624 |
| Household_Income_2023 | 0.6319*** | 0.0962 | 6.565 | 0.0000 |
| Uninsured_Rate | -13100.0587 | 9103.0182 | -1.439 | 0.1568 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,585 | **Within-R² =** 0.4361 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -120.9580*** | 41.0452 | -2.947 | 0.0050 |
| PDSI_Lag1 | -114.3608** | 44.9273 | -2.545 | 0.0143 |
| PDSI_Lag2 | -133.5638*** | 37.0427 | -3.606 | 0.0008 |
| High_CDD | -9.5321 | 313.2875 | -0.030 | 0.9759 |
| High_CDD_Lag1 | -90.1332 | 339.5005 | -0.265 | 0.7918 |
| High_CDD_Lag2 | -65.2268 | 304.5283 | -0.214 | 0.8313 |
| High_HDD | -44.3172 | 188.0680 | -0.236 | 0.8147 |
| High_HDD_Lag1 | -5.9469 | 138.8891 | -0.043 | 0.9660 |
| High_HDD_Lag2 | 117.9606 | 145.3994 | 0.811 | 0.4213 |
| Household_Income_2023 | 0.6290*** | 0.0955 | 6.590 | 0.0000 |
| Uninsured_Rate | -17031.6176** | 8303.4155 | -2.051 | 0.0458 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,421 | **Within-R² =** 0.4294 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -228.5170*** | 34.1327 | -6.695 | 0.0000 |
| PDSI_Lag1 | -59.0168 | 117.4341 | -0.503 | 0.6176 |
| PDSI_Lag2 | -69.7016 | 60.9555 | -1.143 | 0.2586 |
| Z_Temp | -286.8459** | 123.4685 | -2.323 | 0.0245 |
| Z_Temp_Lag1 | -278.0829** | 123.1703 | -2.258 | 0.0286 |
| Z_Temp_Lag2 | -243.3751** | 113.4440 | -2.145 | 0.0371 |
| Z_Precip | 163.4194*** | 45.1389 | 3.620 | 0.0007 |
| Z_Precip_Lag1 | 49.8946 | 166.1205 | 0.300 | 0.7652 |
| Z_Precip_Lag2 | 59.7788 | 141.2952 | 0.423 | 0.6742 |
| Household_Income_2023 | 0.5479*** | 0.0961 | 5.703 | 0.0000 |
| Uninsured_Rate | 14865.1254 | 24679.1021 | 0.602 | 0.5498 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,421 | **Within-R² =** 0.4187 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -121.1745*** | 29.0124 | -4.177 | 0.0001 |
| PDSI_Lag1 | -40.9302 | 45.0947 | -0.908 | 0.3687 |
| PDSI_Lag2 | -35.2284 | 33.6357 | -1.047 | 0.3003 |
| High_CDD | -216.0579 | 356.3587 | -0.606 | 0.5472 |
| High_CDD_Lag1 | -465.7479 | 424.1856 | -1.098 | 0.2778 |
| High_CDD_Lag2 | -832.2073* | 455.9339 | -1.825 | 0.0743 |
| High_HDD | 202.9496 | 419.0251 | 0.484 | 0.6304 |
| High_HDD_Lag1 | -261.2865 | 382.3312 | -0.683 | 0.4977 |
| High_HDD_Lag2 | 278.3302 | 328.0830 | 0.848 | 0.4005 |
| Household_Income_2023 | 0.5626*** | 0.0897 | 6.272 | 0.0000 |
| Uninsured_Rate | 9335.8744 | 20401.0446 | 0.458 | 0.6493 |

---

## Outcome: `Med_HH_Income_Real`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,600 | **Within-R² =** 0.4312 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -1.0378 | 20.6431 | -0.050 | 0.9601 |
| PDSI_Lag1 | -8.4026 | 21.9281 | -0.383 | 0.7033 |
| PDSI_Lag2 | -2.0163 | 17.2930 | -0.117 | 0.9077 |
| Z_Temp | -70.7963** | 32.0728 | -2.207 | 0.0322 |
| Z_Temp_Lag1 | -36.1321 | 26.8289 | -1.347 | 0.1845 |
| Z_Temp_Lag2 | -68.9655* | 34.7777 | -1.983 | 0.0532 |
| Z_Precip | 13.4512 | 25.6402 | 0.525 | 0.6023 |
| Z_Precip_Lag1 | 25.6544 | 31.2447 | 0.821 | 0.4157 |
| Z_Precip_Lag2 | 10.1914 | 26.0700 | 0.391 | 0.6976 |
| Household_Income_2023 | 0.5073*** | 0.0185 | 27.487 | 0.0000 |
| Uninsured_Rate | -7587.6652*** | 2427.3476 | -3.126 | 0.0030 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,600 | **Within-R² =** 0.431 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 13.4007 | 14.5374 | 0.922 | 0.3613 |
| PDSI_Lag1 | 6.5707 | 14.4880 | 0.454 | 0.6523 |
| PDSI_Lag2 | 4.9921 | 13.4108 | 0.372 | 0.7114 |
| High_CDD | -245.1980** | 95.6004 | -2.565 | 0.0136 |
| High_CDD_Lag1 | 9.6664 | 57.1198 | 0.169 | 0.8663 |
| High_CDD_Lag2 | 35.5740 | 87.2173 | 0.408 | 0.6852 |
| High_HDD | 154.5379* | 83.8442 | 1.843 | 0.0716 |
| High_HDD_Lag1 | 44.5106 | 53.1139 | 0.838 | 0.4063 |
| High_HDD_Lag2 | 184.0830*** | 50.2361 | 3.664 | 0.0006 |
| Household_Income_2023 | 0.5070*** | 0.0185 | 27.437 | 0.0000 |
| Uninsured_Rate | -7214.8820*** | 2420.3147 | -2.981 | 0.0045 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,581 | **Within-R² =** 0.8057 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -24.8224* | 12.8240 | -1.936 | 0.0589 |
| PDSI_Lag1 | -16.1240 | 12.6705 | -1.273 | 0.2094 |
| PDSI_Lag2 | 4.8246 | 27.6067 | 0.175 | 0.8620 |
| Z_Temp | -90.8690*** | 22.1129 | -4.109 | 0.0002 |
| Z_Temp_Lag1 | -53.8301*** | 16.1193 | -3.339 | 0.0017 |
| Z_Temp_Lag2 | -44.1691* | 22.7927 | -1.938 | 0.0587 |
| Z_Precip | -25.8047 | 25.4258 | -1.015 | 0.3153 |
| Z_Precip_Lag1 | 26.1420 | 24.6941 | 1.059 | 0.2952 |
| Z_Precip_Lag2 | 6.1712 | 31.5092 | 0.196 | 0.8456 |
| Household_Income_2023 | 0.6728*** | 0.0249 | 27.070 | 0.0000 |
| Uninsured_Rate | -10268.4041*** | 3200.4817 | -3.208 | 0.0024 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,581 | **Within-R² =** 0.8047 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -20.8551* | 12.0845 | -1.726 | 0.0910 |
| PDSI_Lag1 | 11.3688 | 8.3053 | 1.369 | 0.1775 |
| PDSI_Lag2 | 7.6448 | 22.0668 | 0.346 | 0.7306 |
| High_CDD | 0.5824 | 64.0847 | 0.009 | 0.9928 |
| High_CDD_Lag1 | 40.4210 | 59.6382 | 0.678 | 0.5012 |
| High_CDD_Lag2 | 6.7900 | 65.2719 | 0.104 | 0.9176 |
| High_HDD | 172.0945*** | 46.9545 | 3.665 | 0.0006 |
| High_HDD_Lag1 | 10.1905 | 50.5422 | 0.202 | 0.8411 |
| High_HDD_Lag2 | 51.2973 | 69.2869 | 0.740 | 0.4628 |
| Household_Income_2023 | 0.6745*** | 0.0254 | 26.596 | 0.0000 |
| Uninsured_Rate | -9650.1370*** | 3262.5247 | -2.958 | 0.0048 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,421 | **Within-R² =** 0.8864 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -33.5471** | 16.6378 | -2.016 | 0.0495 |
| PDSI_Lag1 | -22.0231 | 15.4603 | -1.424 | 0.1609 |
| PDSI_Lag2 | 34.2361 | 38.1844 | 0.897 | 0.3745 |
| Z_Temp | -104.5626* | 58.3821 | -1.791 | 0.0797 |
| Z_Temp_Lag1 | -102.3826*** | 28.3658 | -3.609 | 0.0007 |
| Z_Temp_Lag2 | -134.0874*** | 36.7676 | -3.647 | 0.0007 |
| Z_Precip | 4.0353 | 29.4101 | 0.137 | 0.8915 |
| Z_Precip_Lag1 | 9.8268 | 41.6412 | 0.236 | 0.8145 |
| Z_Precip_Lag2 | -26.4982 | 35.0087 | -0.757 | 0.4529 |
| Household_Income_2023 | 0.7095*** | 0.0125 | 56.676 | 0.0000 |
| Uninsured_Rate | -8171.5922 | 7192.0688 | -1.136 | 0.2616 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,421 | **Within-R² =** 0.8827 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -31.7810** | 14.4117 | -2.205 | 0.0324 |
| PDSI_Lag1 | -5.6029 | 15.0712 | -0.372 | 0.7117 |
| PDSI_Lag2 | 28.2728 | 32.8365 | 0.861 | 0.3936 |
| High_CDD | 44.6183 | 152.9497 | 0.292 | 0.7718 |
| High_CDD_Lag1 | 38.3133 | 169.7722 | 0.226 | 0.8224 |
| High_CDD_Lag2 | 19.2789 | 165.1227 | 0.117 | 0.9076 |
| High_HDD | 90.4593 | 126.5526 | 0.715 | 0.4783 |
| High_HDD_Lag1 | -124.4934 | 99.2684 | -1.254 | 0.2160 |
| High_HDD_Lag2 | -59.8750 | 108.3443 | -0.553 | 0.5831 |
| Household_Income_2023 | 0.7148*** | 0.0120 | 59.380 | 0.0000 |
| Uninsured_Rate | -12122.7092 | 8460.5919 | -1.433 | 0.1585 |

---

## Outcome: `Civilian_Employed`

### Unweighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,604 | **Within-R² =** 0.0391 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -52.5520 | 125.0716 | -0.420 | 0.6763 |
| PDSI_Lag1 | -11.4470 | 89.2083 | -0.128 | 0.8984 |
| PDSI_Lag2 | -68.5515 | 68.1229 | -1.006 | 0.3194 |
| Z_Temp | 419.1607 | 263.8856 | 1.588 | 0.1189 |
| Z_Temp_Lag1 | -8.3233 | 96.7849 | -0.086 | 0.9318 |
| Z_Temp_Lag2 | 799.1892** | 325.2532 | 2.457 | 0.0178 |
| Z_Precip | 57.6541 | 178.5046 | 0.323 | 0.7481 |
| Z_Precip_Lag1 | -73.7128 | 213.6617 | -0.345 | 0.7316 |
| Z_Precip_Lag2 | 29.7741 | 123.3518 | 0.241 | 0.8103 |
| Household_Income_2023 | 0.3466*** | 0.0785 | 4.415 | 0.0001 |
| Uninsured_Rate | -12442.7792 | 13795.0769 | -0.902 | 0.3717 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,604 | **Within-R² =** 0.0347 | **Cluster =** State | **Weighting =** Unweighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | -67.2957 | 52.5921 | -1.280 | 0.2070 |
| PDSI_Lag1 | -36.0321 | 42.3700 | -0.850 | 0.3994 |
| PDSI_Lag2 | -116.1591 | 74.9406 | -1.550 | 0.1278 |
| High_CDD | 31.1596 | 247.3121 | 0.126 | 0.9003 |
| High_CDD_Lag1 | 493.1441* | 273.6343 | 1.802 | 0.0779 |
| High_CDD_Lag2 | 433.5364** | 183.6843 | 2.360 | 0.0225 |
| High_HDD | -473.6254** | 225.2014 | -2.103 | 0.0408 |
| High_HDD_Lag1 | -334.5904 | 224.4616 | -1.491 | 0.1427 |
| High_HDD_Lag2 | -713.7980** | 328.0868 | -2.176 | 0.0346 |
| Household_Income_2023 | 0.3467*** | 0.0779 | 4.449 | 0.0001 |
| Uninsured_Rate | -16071.3648 | 15143.3514 | -1.061 | 0.2940 |

### Population-weighted

#### Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 33,585 | **Within-R² =** 0.2422 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 3958.0416** | 1591.8313 | 2.486 | 0.0165 |
| PDSI_Lag1 | 1342.7874** | 566.5099 | 2.370 | 0.0219 |
| PDSI_Lag2 | 24.7819 | 1554.5852 | 0.016 | 0.9873 |
| Z_Temp | -159.2114 | 1042.2985 | -0.153 | 0.8792 |
| Z_Temp_Lag1 | 1388.9487 | 1357.7236 | 1.023 | 0.3115 |
| Z_Temp_Lag2 | 3879.2246* | 2097.6092 | 1.849 | 0.0707 |
| Z_Precip | -4454.0976*** | 1595.8386 | -2.791 | 0.0076 |
| Z_Precip_Lag1 | -2669.4361** | 1043.4659 | -2.558 | 0.0138 |
| Z_Precip_Lag2 | -730.6466 | 961.4409 | -0.760 | 0.4511 |
| Household_Income_2023 | 2.2478*** | 0.7015 | 3.204 | 0.0024 |
| Uninsured_Rate | -1140080.0909** | 462857.2546 | -2.463 | 0.0175 |

#### Spec 2: High CDD/HDD (Absolute Burden)
**N =** 33,585 | **Within-R² =** 0.2297 | **Cluster =** State | **Weighting =** Population-weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 1563.6684 | 1086.6436 | 1.439 | 0.1568 |
| PDSI_Lag1 | 290.2849 | 687.9189 | 0.422 | 0.6750 |
| PDSI_Lag2 | -827.1987 | 1098.4789 | -0.753 | 0.4552 |
| High_CDD | -2891.8957 | 2116.8746 | -1.366 | 0.1784 |
| High_CDD_Lag1 | -1861.9741 | 2618.6956 | -0.711 | 0.4806 |
| High_CDD_Lag2 | -2845.1767 | 4429.8487 | -0.642 | 0.5238 |
| High_HDD | 2380.5557 | 2378.6524 | 1.001 | 0.3220 |
| High_HDD_Lag1 | 1525.0936 | 1649.4045 | 0.925 | 0.3599 |
| High_HDD_Lag2 | 2670.3577 | 2645.7291 | 1.009 | 0.3180 |
| Household_Income_2023 | 2.1656*** | 0.7066 | 3.065 | 0.0036 |
| Uninsured_Rate | -1228460.0454** | 472447.6339 | -2.600 | 0.0124 |

### Rating-Area Level Robustness (Pop-Weighted)

#### RA Robustness — Spec 1: Z-Temp/Z-Precip (Climate only)
**N =** 3,421 | **Within-R² =** 0.2764 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 3143.1094 | 2124.6052 | 1.479 | 0.1457 |
| PDSI_Lag1 | 385.4314 | 862.1844 | 0.447 | 0.6569 |
| PDSI_Lag2 | 723.0651 | 756.3053 | 0.956 | 0.3439 |
| Z_Temp | -3908.3592 | 2583.6920 | -1.513 | 0.1371 |
| Z_Temp_Lag1 | -421.8939 | 1410.6524 | -0.299 | 0.7662 |
| Z_Temp_Lag2 | -1600.8978 | 2263.3659 | -0.707 | 0.4829 |
| Z_Precip | -3981.0651* | 2082.2497 | -1.912 | 0.0620 |
| Z_Precip_Lag1 | -2600.7269 | 1749.4542 | -1.487 | 0.1438 |
| Z_Precip_Lag2 | -1586.4200* | 852.2495 | -1.861 | 0.0689 |
| Household_Income_2023 | 3.0791** | 1.3194 | 2.334 | 0.0239 |
| Uninsured_Rate | -854531.6323** | 420690.8936 | -2.031 | 0.0479 |

#### RA Robustness — Spec 2: High CDD/HDD (Absolute Burden)
**N =** 3,421 | **Within-R² =** 0.2447 | **Cluster =** State | **Weighting =** Pop-Weighted

| Term | Estimate | Std. Error | t value | p value |
|------|----------|------------|---------|---------|
| pdsi_val | 1189.2392 | 1408.7219 | 0.844 | 0.4028 |
| PDSI_Lag1 | -498.5598 | 607.6818 | -0.820 | 0.4161 |
| PDSI_Lag2 | 399.2335 | 300.1528 | 1.330 | 0.1899 |
| High_CDD | 2646.9429 | 2890.9906 | 0.916 | 0.3646 |
| High_CDD_Lag1 | -1207.9498 | 1921.8251 | -0.629 | 0.5327 |
| High_CDD_Lag2 | -4387.2742* | 2348.7361 | -1.868 | 0.0680 |
| High_HDD | -5622.4343 | 4172.9877 | -1.347 | 0.1843 |
| High_HDD_Lag1 | -3426.3180 | 3104.3364 | -1.104 | 0.2753 |
| High_HDD_Lag2 | 1954.8558 | 4020.6987 | 0.486 | 0.6291 |
| Household_Income_2023 | 2.8457** | 1.4112 | 2.016 | 0.0495 |
| Uninsured_Rate | -932355.4561* | 476426.5187 | -1.957 | 0.0563 |

