# Descriptive Statistics Report: County-Level Panel

**Generated:** 2026-03-02
**Panel:** 3,155 U.S. counties, 2011–2023 (41,376 county-year observations)
**Script:** `Code/run_descriptive_stats.R`
**Data:** `Data/county_level_master.csv` (53 columns)

---

## 1. Panel Overview

| Dimension | Value |
|-----------|-------|
| Counties | 3,155 |
| Years | 2011–2023 |
| County-year observations | 41,376 |
| Climate variables | ~0.3% missing (high coverage) |
| Premium variables | ~24.7% missing (not all counties have HIX plans) |
| Hospital variables | ~23.1% missing (counties with no hospital reports) |
| AQI variables | ~67.7% missing (EPA monitor coverage is sparse) |
| Socioeconomic (BEA/ACS) | ~1.7–1.8% missing |

---

## 2. Climate Shock Variables

| Variable | N | Mean | SD | Min | Median | Max |
|----------|---|------|----|-----|--------|-----|
| Temp Z-score (1990–2000 baseline) | 41,256 | 0.89 | 1.07 | −3.26 | 1.02 | 5.31 |
| Precip Z-score (1990–2000 baseline) | 41,256 | 0.18 | 1.36 | −7.92 | 0.10 | 8.42 |
| Extreme Heat (High CDD, top quintile) | 40,766 | 0.30 | 0.46 | 0 | 0 | 1 |
| Extreme Cold (High HDD, top quintile) | 40,766 | 0.16 | 0.37 | 0 | 0 | 1 |
| PDSI (annual mean) | 40,766 | 0.33 | 2.17 | −7.62 | 0.20 | 10.48 |
| Extreme Drought (PDSI ≤ −4) | 41,256 | 0.02 | 0.15 | 0 | 0 | 1 |

**Key findings:**
- The positive mean Z-score for temperature (0.89) confirms a systematic warming trend across counties during 2011–2023 relative to the 1990–2000 baseline.
- Extreme heat shocks (High CDD) occurred in **29.7%** of county-years; extreme cold (High HDD) in **16.4%**.
- Extreme drought (PDSI ≤ −4) is rare at **2.3%** of county-years, but concentrated in Western states and drought years (2012, 2020–2022).
- Precipitation Z-scores are near-symmetric around zero (median 0.10), suggesting no long-term directional trend in precipitation.

---

## 3. Health and Financial Outcome Variables

| Variable | N | Mean | SD | Median |
|----------|---|------|----|--------|
| Medical Debt Share (%) | 39,304 | 0.19% | 0.10% | 0.18% |
| Median Medical Debt ($2023) | 26,804 | $954 | $391 | $891 |
| Benchmark Silver Premium ($2023) | 31,157 | $375 | $121 | $346 |
| Lowest Bronze Premium ($2023) | 31,157 | $301 | $89 | $283 |
| Hospital Bad Debt ($2023) | 31,825 | $6.9M | $21.9M | $1.7M |
| Hospital Charity Care ($2023) | 31,825 | $10.1M | $49.6M | $0.9M |
| Uninsured Rate (%) | 35,007 | 12.0% | 6.0% | 11.0% |

**Key findings:**
- Medical debt share is tightly distributed (mean 0.19%, SD 0.10%), with right-skew reflecting high-debt rural counties.
- Hospital bad debt and charity care show extreme right-skew (large urban hospital systems drive the high means); the median bad debt is $1.7M vs a mean of $6.9M.
- Benchmark Silver premiums average $375/month (2023 dollars), with substantial geographic variation (SD = $121). The 5th percentile is ~$24 and the 95th is over $600.
- Uninsured rates range from 0–66% across county-years, with a median of 11%.

---

## 4. Socioeconomic Outcome Variables

| Variable | N | Mean | SD | Median |
|----------|---|------|----|--------|
| Per Capita Personal Income ($2023, BEA) | 40,680 | $53,882 | $15,986 | $50,866 |
| Median HH Income ($2023, ACS) | 40,626 | $62,614 | $16,461 | $60,370 |
| Civilian Employed (count, ACS) | 40,632 | 50,077 | 175,055 | 10,733 |

**Key findings:**
- Per capita personal income (BEA) and ACS median HH income are consistent in direction but differ by ~$9k — reflecting the different concepts (individual vs household) and sources.
- Civilian employed counts are heavily right-skewed; the median county employs ~10,700 people while the mean is ~50,000, driven by large metro counties.
- Mean PCPI grew from approximately $47k to $62k (2023 dollars) between 2011 and 2023, reflecting real income growth.

---

## 5. Time-Series Trends

See plots in `Analysis/plots/`:

### Climate Shocks (`ts_climate_shocks.png`)
- Extreme heat (High CDD) shows the clearest temporal variation, peaking during heat-wave years.
- Extreme drought spiked notably around 2012 and 2020–2022.
- Extreme cold shows less systematic trend.

### Health Outcomes (`ts_outcomes.png`)
- Medical debt share shows a declining trend post-2016, potentially reflecting Medicaid expansion effects playing out.
- The uninsured rate declined substantially through 2016 (ACA effects) then stabilized.
- Silver premiums rose sharply 2013–2018, then moderated after reinsurance programs and premium tax credits were adjusted.

### Income (`ts_income.png`)
- Both BEA per capita income and ACS median HH income show steady upward trends in real terms across the study period.
- The gap between the two series is consistent (~$8–10k), reflecting the household vs individual unit of analysis.

---

## 6. Data Quality Notes

- **AQI variables** (67.7% missing): EPA air quality monitors cover roughly one-third of counties. Regressions using AQI will use county FE with unbalanced panels — interpret AQI coefficients with caution.
- **Hospital data** (23% missing): NASHP HCT data covers hospitals that report to CMS. Counties with only critical-access hospitals or no hospitals are missing.
- **Premium data** (24.7% missing): HIX premiums unavailable for counties in states that didn't participate in HealthCare.gov or where no plans were offered.
- **Negative hospital charity care min**: One county-year has a large negative value (−$408M), indicating a reversal/correction in reported charity care. Winsorization should be applied before regression use.
