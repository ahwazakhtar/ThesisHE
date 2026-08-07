# Clustering Justification — AAIW Design-Based Framework

**Track:** `advisor_feedback_20260807`, Task 1.2 (spec O2). **Date:** 2026-08-07.
**Reference:** Abadie, Athey, Imbens & Wooldridge, "When Should You Adjust Standard
Errors for Clustering?" NBER WP 24003 (QJE 2023).
**Script:** `Code/run_clustering_sensitivity.R` (R 4.5.2) →
`clustering_sensitivity.csv`; build log in `build_logs/`.
**Usable as:** essay-appendix inference note (source of truth for "why state clustering").

## The AAIW question

AAIW: clustering is not justified by residual correlation per se — it is justified by
the *design*: (i) **sampling-based** (units sampled in clusters) or (ii)
**assignment-based** (treatment assigned with cluster-level correlation). Clustering at
a level unsupported by either is a choice about the estimand's inferential population,
not a free conservatism upgrade.

## Application to this design

- **Sampling:** none — the county panel is a full census of US counties (3,048–3,232
  per outcome), not a cluster sample. The sampling rationale is inapplicable.
- **Assignment:** climate shocks are assigned by nature with strong spatial
  correlation far beyond the county: own-vs-neighbor shock correlations are
  **r = 0.94–0.97** (measured directly in Task 1.1: PDSI is climate-division-level;
  CDD/HDD are spatially smooth). Treating county shock histories as independent
  (county clustering) contradicts the measured assignment process.
- **Level chosen:** **state** — the coarsest feasible institutional level that (a)
  nests the within-state component of the assignment correlation, (b) nests rating
  areas, the institutional price-setting unit for the premium outcomes, and (c)
  retains enough clusters (47–51) for cluster-robust asymptotics. Where cluster count
  is critical (2012 DiD), inference is additionally verified by wild cluster bootstrap
  and randomization inference (p_wcb = 0.036, p_ri = 0.0075 — evidence table).
- **Residual cross-border correlation:** state clustering ignores correlation across
  state lines. Conley spatial-HAC SEs (border-free, triangular kernel; 100/200/300 km)
  bound this concern from the other direction.

## Sensitivity grid (identical point estimates; p-values by inference level)

Key headline terms, unweighted Spec-2 primary block (full grid incl. CDD terms in
`clustering_sensitivity.csv`; sign convention: negative PDSI = drought):

| Outcome | Term | β | p county | **p state** | p Conley 100 | **p Conley 200** | p Conley 300 |
|---|---|---|---|---|---|---|---|
| PCPI_Real | PDSI_Lag1 | −133 | 2.8e-13 | **0.0026** | 2.8e-05 | **0.0029** | 0.0079 |
| PCPI_Real | pdsi_val | −109 | 1.9e-06 | 0.175 | 0.024 | 0.135 | 0.213 |
| Civilian_Employed | High_HDD | −474 | 0.0030 | **0.041** | 0.037 | **0.043** | 0.043 |
| Civilian_Employed | High_HDD_Lag2 | −714 | 0.0004 | **0.035** | 0.020 | **0.028** | 0.029 |
| Medical_Debt_Share | High_HDD | 0.0038 | 1.5e-05 | 0.032 | 0.008 | 0.041 | 0.072 |
| Med_HH_Income_Real | High_HDD_Lag2 | 184 | 0.0098 | 0.0006 | 0.021 | 0.014 | 0.0021 |

## Findings

1. **County clustering is severely anticonservative** — p-values up to seven orders of
   magnitude smaller than state (PCPI PDSI_Lag1: 2.8e-13 vs 0.0026). Exactly the AAIW
   prediction when assignment correlation extends beyond the clustering level. Never
   use county-clustered inference in this design.
2. **Conley 200 km reproduces state-clustered inference almost exactly** (0.0029 vs
   0.0026; 0.043 vs 0.041; 0.028 vs 0.035). State borders are an adequate proxy for
   the spatial correlation range of the shocks — the state-clustering choice is
   validated from outside the clustering framework.
3. **Headline terms survive every defensible inference level.** Drought→income
   (PDSI_Lag1) and cold→employment (High_HDD, High_HDD_Lag2) are significant under
   state clustering and all three Conley cutoffs. At the most conservative (300 km),
   drought income p = 0.008, cold employment p = 0.029–0.043.
4. Contemporaneous `pdsi_val` on PCPI is not significant under state/Conley-200+ —
   consistent with the project's standing result that the income effect loads on
   lagged drought.

## Cross-references (not re-run)

- Heat-headline Conley SEs (Medicare morbidity, heat×labor interactions):
  `Analysis/mechanism/conley_robustness.csv` (B2, mechanisms_revision_20260704).
- Rating-area clustered premium variants: `run_county_analysis.R` `*_RA_Cluster`
  outputs — sensitivity-only, never selected on (econometrics.md B5).

## Verdict

State clustering is the design-appropriate primary level under AAIW: assignment-based
(nature assigns spatially correlated shocks), institution-nesting (rating areas), and
independently validated by border-free spatial HAC. The headline inference is not an
artifact of the clustering choice.
