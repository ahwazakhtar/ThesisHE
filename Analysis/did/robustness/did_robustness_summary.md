# DiD Frontier-Robustness — Summary

Robustness layer for the 2012 drought natural-experiment DiD. Run on R 4.5.3.
Estimand: effect of *first* drought onset (ITT; treatment recurs and is 'on'
only ~13% of treated post-period county-years).

## 1. Few-treated-cluster inference (wild cluster bootstrap + randomization)
|Outcome            |        ATT| p_analytic| p_wcb_webb| p_randinf| n_treated_states|
|:------------------|----------:|----------:|----------:|---------:|----------------:|
|PCPI_Real          | -1310.6654|     0.0277|     0.0362|    0.0075|               17|
|Civilian_Employed  | -2042.6673|     0.0001|     0.0029|    0.0365|               17|
|Med_HH_Income_Real |  -990.7192|     0.2374|     0.2680|    0.0040|               17|
|Medical_Debt_Share |    -0.0062|     0.4970|     0.5976|    0.0835|               17|

## 2. Doubly-robust DiD with baseline covariates
|Outcome            |        ATT|       SE|      ci_lo|     ci_hi|
|:------------------|----------:|--------:|----------:|---------:|
|PCPI_Real          | -1451.2681| 515.2966| -2461.2494| -441.2869|
|Civilian_Employed  |  -870.8061| 432.8059| -1719.1056|  -22.5066|
|Med_HH_Income_Real | -1185.9167| 486.7253| -2139.8983| -231.9351|
|Medical_Debt_Share |    -0.0108|   0.0044|    -0.0194|   -0.0023|

### CS doubly-robust simple ATT
|Estimator    |Outcome            |       ATT|        SE|
|:------------|:------------------|---------:|---------:|
|CS_dr_simple |PCPI_Real          |  349.7688|  585.0131|
|CS_dr_simple |Civilian_Employed  | 2608.8282| 2244.6627|
|CS_dr_simple |Med_HH_Income_Real | -444.3031|  714.5853|
|CS_dr_simple |Medical_Debt_Share |   -0.0054|    0.0050|

## 3. HonestDiD parallel-trends sensitivity (breakdown M-bar)
|         lb|        ub|method |Delta   | Mbar|Outcome           |excludes_0 |
|----------:|---------:|:------|:-------|----:|:-----------------|:----------|
| -1156.0524|  421.6191|C-LF   |DeltaRM |  0.5|PCPI_Real         |FALSE      |
| -1700.0770|  929.3754|C-LF   |DeltaRM |  1.0|PCPI_Real         |FALSE      |
| -2271.3029| 1491.5342|C-LF   |DeltaRM |  1.5|PCPI_Real         |FALSE      |
| -2851.5958| 2062.7601|C-LF   |DeltaRM |  2.0|PCPI_Real         |FALSE      |
|  -194.6333|  654.0954|C-LF   |DeltaRM |  0.5|Civilian_Employed |FALSE      |
|  -328.6430|  820.0122|C-LF   |DeltaRM |  1.0|Civilian_Employed |FALSE      |
|  -500.9413|  998.6919|C-LF   |DeltaRM |  1.5|Civilian_Employed |FALSE      |
|  -686.0024| 1196.5159|C-LF   |DeltaRM |  2.0|Civilian_Employed |FALSE      |

