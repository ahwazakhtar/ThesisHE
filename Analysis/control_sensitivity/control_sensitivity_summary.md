# Bad-Control Sensitivity — Same-Sample Control Variants (audit A5 / O4)

_Generated 2026-07-13 12:46:13. Track code_quality_remediation_20260713 task 3.1. Input: `Data/county_level_master.csv` (md5 `6acb472b010f502292dfc31dcb4cb345`)._

Each headline county / transition / dose cell is re-estimated in three variants on the
**identical** estimation sample (rows non-missing for every variable used by any variant):
**(i) no controls** (shock terms + county/unit + year FE only), **(ii) lagged controls**
(one-year lags of `Household_Income_2023` and `Uninsured_Rate`), **(iii) contemporaneous
controls** (the current production spec). All specs: `fixest::feols`, `fips_code`+`Year` FE,
State-clustered, unweighted — matching each cell's production estimator. The two debt cells
use the ESTABLISHED single-shock-family county debt spec (run_latent_hardship.R L32); the
transition and dose cells replicate run_delta_analysis.R and run_cumulative_dose.R exactly.

**Materiality** (project dedup criterion): a variant differs materially from the no-control
spec when `|coef - coef_nocontrol| > 0.1 * SE(no-control)`. The no-control spec is primary
for total-effect language; a collapse/amplification means the contemporaneous-control spec
is a mediation/sensitivity spec and total-effect claims must cite the no-control number.

## Replication / code-fidelity check (published production coefficients reproduced via the exact production code paths)

| Anchor | Published | Reproduced | abs diff | tol | within tol | N | vintage |
|--------|-----------|------------|----------|-----|------------|---|---------|
| run_county_analysis_Spec2_High_HDD_Lag1 |  0.0013 | 0.00131351 | 1.3513e-05 |  0.0001 | TRUE | 32533 | post-dedup / current (EXACT) |
| run_delta_asymmetry_h2 | 0.01823 | 0.0187377 | 0.000507671 |   0.001 | TRUE | 29834 | PRE-DEDUP published (audit A6: delta=June) |
| run_cumulative_dose_binned_10p_vs_1to3 | -5667.55 | -5522.02 | 145.528 |     250 | TRUE | 33959 | PRE-DEDUP published (audit A6: dose=June 14) |

Anchor notes:
- `run_county_analysis_Spec2_High_HDD_Lag1` — run_county_analysis.R Spec2_Base Unweighted, contemporaneous controls; county_regression_coefs.csv col(2).
- `run_delta_asymmetry_h2` — delta_symmetry_test.csv Drought/Medical_Debt_Share/h=2/Unweighted; post-dedup reproduces within dedup movement.
- `run_cumulative_dose_binned_10p_vs_1to3` — cumulative_dose_marginal.csv HDD/Civilian_Employed/Unweighted; post-dedup reproduces within dedup movement.

The single-family cold_debt / drought_debt cells have no separate published with-controls
coefficient (run_county_analysis.R's drought block is continuous PDSI, and its cold
High_HDD_Lag1 lives inside the bundled Spec-2 anchor above); their contemporaneous-control
values are consistent with that anchor under the same controls and are reported, not asserted.

## Comparison table (all variants, same sample per cell)

| Cell | Variant | Coefficient | SE | p | N | %Δ vs no-control | material vs no-control |
|------|---------|-------------|----|---|---|------------------|------------------------|
| cold_debt | (i) no controls | 0.00144068 | 0.00170653 | 0.403 | 29789 | +0.0% | FALSE |
| cold_debt | (ii) lagged controls | 0.00143049 | 0.00155561 | 0.362 | 29789 | -0.7% | FALSE |
| cold_debt | (iii) contemporaneous | 0.0014083 | 0.00154261 | 0.366 | 29789 | -2.2% | FALSE |
| drought_debt | (i) no controls | 0.000914898 | 0.0029361 | 0.757 | 29789 | +0.0% | FALSE |
| drought_debt | (ii) lagged controls | 0.000552414 | 0.00242967 | 0.821 | 29789 | -39.6% | TRUE |
| drought_debt | (iii) contemporaneous | 0.000631475 | 0.00251506 | 0.803 | 29789 | -31.0% | FALSE |
| drought_asym | (i) no controls | 0.0229996 | 0.00661037 | 0.000503 | 26876 | +0.0% | FALSE |
| drought_asym | (ii) lagged controls | 0.0252424 | 0.00625138 | 5.39e-05 | 26876 | +9.8% | TRUE |
| drought_asym | (iii) contemporaneous | 0.0238595 | 0.00632457 | 0.000162 | 26876 | +3.7% | TRUE |
| cold_dose | (i) no controls | -5269.82 | 1298.01 | 4.91e-05 | 30868 | -0.0% | FALSE |
| cold_dose | (ii) lagged controls | -5461.54 | 1171.97 | 3.16e-06 | 30868 | +3.6% | TRUE |
| cold_dose | (iii) contemporaneous | -5284.93 | 1190.48 | 9.02e-06 | 30868 | +0.3% | FALSE |

## Sample-sensitivity diagnostic (why the identical-sample no-control differs from the evidence-table headline)

The **no-control** coefficient on each cell's OWN full sample (outcome + shock terms + FE,
no control-availability filter) vs. on the identical sample (which requires income &
uninsurance — and their lags — to be OBSERVED). A large gap means the coefficient is driven
by the rows that DROP once you demand the controls be observed — a sample/measurement
fragility that is SEPARATE from (and larger than) the bad-control question.

| Cell | No-control, full sample | p | N | No-control, identical sample | p | N |
|------|-------------------------|---|---|------------------------------|---|---|
| cold_debt | 0.00552435 | 0.0082 | 38732 | 0.00144068 | 0.403 | 29789 |
| drought_debt | 0.00575533 | 0.029 | 38732 | 0.000914898 | 0.757 | 29789 |
| drought_asym | 0.00826412 | 0.0568 | 38732 | 0.0229996 | 0.000503 | 26876 |
| cold_dose | -5429.57 | 3.54e-05 | 40136 | -5269.82 | 4.91e-05 | 30868 |

**Debt cells are sample-fragile.** The significant headline-scale debt coefficients
(cold ~0.0055, p<0.01; drought ~0.0058, p<0.05) exist only on the FULL 2011-2023 debt panel;
restricting to the subsample where SAHIE uninsurance & income are OBSERVED (2013-2022,
data-complete counties) collapses them to ~0.001 (null) BEFORE any control is added. This is
the medical-debt measurement fragility the project already flags — the debt headline rests on
rows the control-conditioned spec cannot see, not on a bad-control pathway. The transition
(asymmetry) and dose employment cells are NOT sample-fragile in this way.

## Per-cell verdicts

### cold_debt — Cold -> medical-debt share (High_HDD lag 1), county panel
- No-control: coef = 0.00144068 (SE 0.00170653, p = 0.403).
- Lagged controls: coef = 0.00143049 (-0.7% vs no-control; material = FALSE).
- Contemporaneous controls: coef = 0.0014083 (-2.2% vs no-control; material = FALSE).
- **Verdict: STABLE — contemporaneous controls are innocuous; no-control and contemporaneous specs agree within 0.1 SE. Total-effect language is safe.**
- No sign or significance change between the no-control and contemporaneous specs.

### drought_debt — Drought -> medical-debt share (Is_Extreme_Drought lag 2), county panel
- No-control: coef = 0.000914898 (SE 0.0029361, p = 0.757).
- Lagged controls: coef = 0.000552414 (-39.6% vs no-control; material = TRUE).
- Contemporaneous controls: coef = 0.000631475 (-31.0% vs no-control; material = FALSE).
- **Verdict: STABLE — contemporaneous controls are innocuous; no-control and contemporaneous specs agree within 0.1 SE. Total-effect language is safe.**
- No sign or significance change between the no-control and contemporaneous specs.

### drought_asym — Drought debt onset/exit asymmetry at h=2 (beta_Onset + beta_Exit)
- No-control: coef = 0.0229996 (SE 0.00661037, p = 0.000503).
- Lagged controls: coef = 0.0252424 (+9.8% vs no-control; material = TRUE).
- Contemporaneous controls: coef = 0.0238595 (+3.7% vs no-control; material = TRUE).
- **Verdict: ROBUST (minor shift) — material by the 0.1-SE rule but +3.7%, with no sign or significance change; the headline conclusion is unchanged.**
- No sign or significance change between the no-control and contemporaneous specs.

### cold_dose — Cold cumulative-dose employment: 10+ vs 1-3 cumulative cold-years
- No-control: coef = -5269.82 (SE 1298.01, p = 4.91e-05).
- Lagged controls: coef = -5461.54 (+3.6% vs no-control; material = TRUE).
- Contemporaneous controls: coef = -5284.93 (+0.3% vs no-control; material = FALSE).
- **Verdict: STABLE — contemporaneous controls are innocuous; no-control and contemporaneous specs agree within 0.1 SE. Total-effect language is safe.**
- No sign or significance change between the no-control and contemporaneous specs.

## Reading (expectation vs observed) + implications for task 3.2

Expectation (recorded a priori): county+year FE make the weather shocks plausibly
quasi-random, so no-control coefficients should move only modestly on the SAME sample; the
debt cells were flagged as the exception (contemporaneous income/uninsurance were expected to
sit on the shock->debt pathway and to strengthen the debt cells when removed).

Observed:
1. **Bad controls are innocuous on the identical sample — for ALL four headlines.** No sign
   flips, no significance changes between the no-control and contemporaneous-control specs;
   coefficients agree within ~0.1-0.4 SE. The transition (drought debt asymmetry, h=2) and
   dose (cold employment 10+ vs 1-3) headlines are robust to control choice AND stay strongly
   significant in every variant — total-effect language is safe for them (acceptance
   criterion 5). The audit A5 'bad control blocks part of the effect' concern does NOT
   materialize once the comparison holds the sample fixed.
2. **The expected debt 'strengthening' is a SAMPLE effect, not a control effect.** The debt
   cells DO look far larger without controls — but only because dropping the controls also
   drops the control-availability filter, re-admitting data-sparse rows that carry the effect
   (see the sample-sensitivity table). On the identical sample the controls barely move the
   debt coefficient. So the a-priori 'debt cells strengthen without controls' expectation is
   confirmed in direction but re-attributed to sample composition, not pathway absorption.
3. **The debt headlines are sample-fragile (a measurement caveat, not a bad-control caveat).**
   The evidence-table debt cells (cold +~1.1pp; drought +~0.5pp) rest on the full 2011-2023
   panel; they vanish on the subsample where income/uninsurance are observed. This reinforces
   the project's standing 'medical debt is measurement-fragile / secondary' verdict.

Implications for task 3.2 (orchestrator, evidence-table language):
- Drought debt-scar asymmetry (Row 16) and cold employment dose (Row 17): keep as stated;
  they survive no-control / lagged-control / contemporaneous-control identically. Total-effect
  language is warranted (no bad-control contamination).
- Cold->debt (Row 4) and drought->debt (Row 5): the contemporaneous controls are NOT the
  problem; the coefficient is sample-fragile. Any total-effect claim must note that the
  significant magnitude does not survive on the control-observed subsample — consistent with
  the debt-measurement caveat. Do not attribute the attenuation to bad controls.
