# Observed vs Latent Hardship — Gradient Summary (O6)

_Generated 2026-07-12. PRE-REGISTERED design (spec.md Phase-3 pre-specification, dated 2026-07-12)._
_Estimates **certified dedup-invariant (2026-07-13)**: the county master is now certified unique
on (fips_code, Year) (`fca5643`), and this analysis's `first()` dedup stopgap collapsed ~428
RA-split county-years losslessly (debt outcomes, shock lags, and Population are constant within
fips x Year), so every cell here is numerically identical pre/post-dedup. See
`Analysis/county_dedup_integrity.md` §4 (run_latent_hardship.R row = "No-op / exactly invariant")._

**Question.** Does the measured climate-shock -> medical-debt response *shrink* where hardship is
least observable to financial institutions (uninsurance, rurality, hospital scarcity, low income,
high SVI)? If so, credit-bureau debt understates harm where access/visibility is weakest.

**Spec.** Established county debt spec (`fixest::feols`, county + Year FE, STATE-clustered SEs) +
shock x moderator interaction; the full contemporaneous+L1+L2 shock family is entered and the
debt-relevant TARGET lag is reported (cold -> L1; drought -> L2). POPULATION-WEIGHTED is primary;
unweighted is robustness. Moderators are z-scored at BASELINE (2011-2013 window), time-invariant.
Multiplicity: BKY (2006) sharpened q-values over the full 20-cell grid (2 shocks x 5 moderators x
2 outcomes) within each weighting.

## Implementation bindings (frozen elements bound to available data)
- **Rurality (RUCC)** — RUCC absent from the repo; bound to z(-log baseline population) [B1].
- **Hospital access** — z(log1p distinct-CCN count in county, 2011-2013); absent-from-NASHP -> 0 [B2].
- **SVI** — `SVI_static` (repo's time-invariant baseline SVI) [B3].
- **Baseline window** — 2011-2013 [B4]. **Dedup** — first() stopgap, certified dedup-invariant 2026-07-13 [B5].

## Decision rule
**HONEST NULL: the >=2/3-at-q<0.10 bar is NOT cleared; medical debt stays a caveat.**

Rule (binding for permitted language): 'positive contribution' framing only if >=2 of 3 primary
moderators (uninsurance, rurality, hospital access) show attenuation at q<0.10 with consistent
signs for at least one shock cell; else the honest null. Claim tier capped at **mechanism-supporting**.

Per-shock tally (primary family, population-weighted, Medical_Debt_Share):
|shock   | n_attenuating_q10|mods_hit    |
|:-------|-----------------:|:-----------|
|cold    |                 0|            |
|drought |                 1|Uninsured_z |

Expected-sign check: 6 of 6 primary cells attenuate in the a-priori-predicted direction; 0 contradict.

## PRIMARY family — population-weighted, `Medical_Debt_Share` (6 cells)
`attenuates` = interaction shrinks the shock main effect toward zero in the moderator's predicted
direction (opposite-signed for uninsurance/rurality; same-signed for hospital access). q = BKY
sharpened q over the 20-cell weighted grid.
|shock   |moderator    | main_effect| interaction| se_interaction| p_interaction|  q_bky|attenuates |sig_q10 |
|:-------|:------------|-----------:|-----------:|--------------:|-------------:|------:|:----------|:-------|
|cold    |Uninsured_z  |     0.00296|   -1.49e-03|       0.002330|       0.52700| 1.0000|TRUE       |FALSE   |
|cold    |Rurality_z   |     0.00406|   -3.48e-04|       0.001560|       0.82400| 1.0000|TRUE       |FALSE   |
|cold    |HospAccess_z |     0.00429|    2.28e-04|       0.001150|       0.84400| 1.0000|TRUE       |FALSE   |
|drought |Uninsured_z  |     0.01060|   -5.47e-03|       0.001680|       0.00205| 0.0117|TRUE       |TRUE    |
|drought |Rurality_z   |     0.00635|   -2.51e-04|       0.000926|       0.78800| 1.0000|TRUE       |FALSE   |
|drought |HospAccess_z |     0.00699|    1.08e-05|       0.000494|       0.98300| 1.0000|TRUE       |FALSE   |

## SECONDARY grid — population-weighted (secondary moderators and/or `Medical_Debt_Median_2023`)
|outcome                  |shock   |moderator    | main_effect| interaction| se_interaction| p_interaction|   q_bky|attenuates |sig_q10 |
|:------------------------|:-------|:------------|-----------:|-----------:|--------------:|-------------:|-------:|:----------|:-------|
|Medical_Debt_Share       |cold    |BaseIncome_z |     0.00488|   -5.89e-04|       2.12e-03|      7.82e-01| 1.00000|FALSE      |FALSE   |
|Medical_Debt_Share       |cold    |SVI_z        |     0.00356|   -1.14e-03|       1.71e-03|      5.09e-01| 1.00000|TRUE       |FALSE   |
|Medical_Debt_Share       |drought |BaseIncome_z |     0.00435|    2.23e-03|       8.35e-04|      1.04e-02| 0.04960|TRUE       |TRUE    |
|Medical_Debt_Share       |drought |SVI_z        |     0.00843|   -2.71e-03|       7.54e-04|      7.78e-04| 0.00556|TRUE       |TRUE    |
|Medical_Debt_Median_2023 |cold    |Uninsured_z  |    39.70000|    2.32e+01|       1.41e+01|      1.06e-01| 0.35700|FALSE      |FALSE   |
|Medical_Debt_Median_2023 |cold    |Rurality_z   |   -34.70000|   -3.70e+01|       2.24e+01|      1.05e-01| 0.35700|FALSE      |FALSE   |
|Medical_Debt_Median_2023 |cold    |HospAccess_z |   -15.90000|    2.85e+01|       1.76e+01|      1.13e-01| 0.35700|FALSE      |FALSE   |
|Medical_Debt_Median_2023 |cold    |BaseIncome_z |    13.70000|    6.43e+00|       1.35e+01|      6.37e-01| 1.00000|TRUE       |FALSE   |
|Medical_Debt_Median_2023 |cold    |SVI_z        |    20.70000|    5.26e+00|       7.78e+00|      5.03e-01| 1.00000|FALSE      |FALSE   |
|Medical_Debt_Median_2023 |drought |Uninsured_z  |   130.00000|   -6.83e+01|       1.57e+01|      7.31e-05| 0.00104|TRUE       |TRUE    |
|Medical_Debt_Median_2023 |drought |Rurality_z   |    48.10000|   -1.37e+01|       1.98e+01|      4.93e-01| 1.00000|TRUE       |FALSE   |
|Medical_Debt_Median_2023 |drought |HospAccess_z |    74.30000|    2.84e+00|       9.33e+00|      7.62e-01| 1.00000|TRUE       |FALSE   |
|Medical_Debt_Median_2023 |drought |BaseIncome_z |    43.70000|    3.60e+01|       7.92e+00|      3.68e-05| 0.00104|TRUE       |TRUE    |
|Medical_Debt_Median_2023 |drought |SVI_z        |   104.00000|   -3.58e+01|       9.95e+00|      7.51e-04| 0.00556|TRUE       |TRUE    |

## Notes & reading
- Medical debt is **measurement-fragile** by construction (credit file + insurance + billed
  encounter required); this analysis tests whether that fragility is *systematic* along access/
  visibility gradients. A clean attenuation pattern would convert the caveat into a finding; a
  null leaves debt as a caveat and the real-economy (income/employment) results as the lead.
- The full 40-row grid (both weightings) with q-values is in `latent_hardship_gradients.csv`.
- Unweighted results are robustness only; the decision rule reads the population-weighted primary.

## Parking lot (pre-spec: further ideas go here, NOT into this analysis)
- Additional moderators (energy burden, ag dependence, %<138% FPL uninsured), more lags/hazards,
  nonlinearity in the gradient, an actual RUCC/land-area rurality measure, and a per-capita vs
  count hospital-access sensitivity are Phase-4 items, gated on Tier-1 essay drafts existing.
