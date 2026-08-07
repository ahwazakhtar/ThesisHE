# Spatial Spillover Test — Synthesis

**Track:** `advisor_feedback_20260807`, Task 1.1 (spec O1). **Date:** 2026-08-07.
**Script:** `Code/run_spillover_analysis.R` (R 4.5.2; helpers `Code/spillover_utils.R`,
tested by `Code/tests/test_spillover_utils.R`).
**Data:** `Data/county_level_master.csv` + Census 2023 county adjacency
(`Data/Geo/county_adjacency2023.txt`, 18,962 directed edges, 3,225 counties;
downloaded/validated by `Code/download_county_adjacency.R`).
**Outputs:** `spillover_results.csv` (all coefficients), `spillover_comparison.csv`
(stability + totals + joint tests), build log in `build_logs/`.

## Question

The SUTVA caveat (results guide §7): climate shocks are spatially correlated; do
spillovers from neighboring counties contaminate the headline county FE estimates?

## Design

Spec-2 primary block (PDSI + High_CDD + High_HDD, each with 2 lags), county + year FE,
state clustering, controls as in `run_county_analysis.R`, CO-2023 debt exclusion. For
each shock term, neighbor exposure = mean over Census-adjacent counties (own excluded;
for binary shocks this is the share of neighbors in shock). Baseline and spillover
models estimated on the same complete-case sample. Outcomes: PCPI_Real,
Med_HH_Income_Real, Medical_Debt_Share, Civilian_Employed; unweighted and
population-weighted.

## Identification caveat found in the data

Own and neighbor exposures are near-collinear — r = 0.959–0.966 (PDSI, climate-division
measurement), 0.936 (HDD), 0.965 (CDD). The own-vs-neighbor decomposition is therefore
NOT separately identified: individual coefficients swing in offsetting directions when
the neighbor block enters (the pre-registered ±25% own-stability check is mechanically
uninformative — dated note in the track spec). The identified objects are:

1. **Joint neighbor-block Wald test** — is there any spillover signal at all?
2. **Total-exposure lincom** (own + neighbor) — the effect of being in a shocked
   *region*, vs the baseline own-only coefficient.

## Results (unweighted; population-weighted agrees in sign)

| Headline claim | Baseline own β | Total exposure (own+nbr) | Joint nbr Wald p |
|---|---|---|---|
| Drought → income (PCPI, PDSI_Lag1) | −133 | **−157** (SE 49, p = 0.001) | 0.006 |
| Drought → income (PCPI, pdsi_val) | −109 | −142 (SE 97, p = 0.14) | 0.006 |
| Cold → employment (High_HDD) | −473 | **−855** (SE 348, p = 0.014) | 0.006 |
| Cold → employment (High_HDD_Lag2) | −714 | **−1,090** (SE 344, p = 0.002) | 0.006 |
| Drought → debt (Medical_Debt_Share, PDSI terms) | ≈0 | ≈0 (all p > 0.5) | 0.135 |

(Sign convention: negative PDSI = drought, so a negative PDSI coefficient = income falls
in drought. Full grid incl. CDD terms and Med_HH_Income_Real in `spillover_comparison.csv`.)

## Verdict

**Spillovers exist, are same-signed, and amplify — they do not confound.** Neighbor
exposure adds jointly significant signal for income and employment (p ≈ 0.006); the
total-exposure effect exceeds the own-only baseline for every surviving headline term.
The county coefficients in the headline claims are therefore best read as **lower
bounds on the effect of regional climate exposure**, not as estimates biased by
untreated-neighbor contamination. The debt outcome shows no drought spillover signal
(consistent with its measurement-fragility caveat). Essay prose qualifier: "county
estimates capture local exposure; adjacent-county exposure adds a same-signed regional
component that the local coefficient understates."

Coverage note: 111 of 3,219 county-years (2015 snapshot) have zero observed neighbors —
islands, the CT-2022 planning-region rename, and AK/HI climate gaps; they drop from the
spillover sample via complete-case (baseline estimated on the same sample, so the
comparison is clean).
