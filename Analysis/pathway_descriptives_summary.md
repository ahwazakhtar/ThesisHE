# Pathway Descriptives — Summary

**Date:** 2026-05-21
**Source script:** `Code/run_pathway_descriptives.R`

Companion descriptive evidence for `Text/propagation_pathways.md`. 
All figures generated from the existing annual county panel 
(`Data/county_level_master.csv`, restricted to 2011-2023).

## Figures

- **p1_shock_prevalence_by_region.png** — Climate-shock county shares by Census region over 2011-2023. 
  Confirms regional structure: drought peaks in 2012/2022 (Midwest/West/South), HDD peaks 2013 (Midwest/Northeast), 
  AQI spikes 2020/2023 (West/Northeast wildfire smoke).
- **p2_shock_outcome_correlations.png** — Pooled Pearson correlations. Raw, *not* within-FE; shown to 
  motivate the pathway directions and to flag that uncontrolled associations are small (|rho| typically < 0.10), 
  underscoring why the FE/LP/DiD designs are necessary.
- **p3_delta_shock_vs_delta_outcome.png** — Mean year-over-year change in outcome conditional on shock 
  onset vs exit. Visually previews the Phase 2 delta/LP findings: drought onset depresses PCPI and raises 
  Medical_Debt_Share; exit reverses these.
- **p4_debt_share_by_income_quartile.png** — Medical_Debt_Share trajectory by county income quartile, 
  separated by Any_Climate_Shock. Supports the income-pathway claim: the shock-vs-no-shock gap in 
  Medical_Debt_Share is largest for the lowest-income quartile, smaller for the highest.

## Pathway-figure mapping

| Pathway | Most relevant figure(s) |
|---------|-------------------------|
| Heat -> delayed care | p1 (CDD regional structure), p3 (CDD onset/exit deltas) |
| Cold -> shifted utilization | p1 (HDD prevalence), p3 (HDD onset/exit deltas) |
| Drought -> income -> debt | p3 (drought onset depresses PCPI; raises debt), p4 (income gradient) |
| AQI -> respiratory/cardiac | p1 (AQI regional concentration; wildfire spike 2023) |

