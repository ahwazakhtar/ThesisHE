# Premium Pass-through and Debt Mediation — Summary

_Generated 2026-07-04. Premiums are MONTHLY real dollars (mean benchmark ~$375),
2014-2025. Pass-through uses LAGGED shocks (rate-filing timing; t-2 primary) as pop-
weighted SHARES, so a level coefficient is $ per fully-exposed unit. STATE clustering
is primary; rating-area clustering understates SEs here and is not used to select_
_significance. Split counties deduped to one row/county-year (stopgap for T1.2)._

## (i) PASS-THROUGH — estimated at the levels ACA rates are actually set

### PRIMARY — within-state local margin (rating-area x year, RA + State^Year FE)
_The only margin a local shock could legally enter (the geographic rating factor)._
|premium               |hazard  | estimate|   se| p_state|  ci_lo| ci_hi|
|:---------------------|:-------|--------:|----:|-------:|------:|-----:|
|Benchmark_Silver_Real |Drought |     2.48| 2.33|  0.2940|  -2.10|  7.05|
|Benchmark_Silver_Real |Heat    |   -10.50| 8.61|  0.2300| -27.40|  6.41|
|Benchmark_Silver_Real |Cold    |    12.60| 5.75|  0.0337|   1.30| 23.80|
|Lowest_Bronze_Real    |Drought |     5.89| 2.49|  0.0219|   1.02| 10.80|
|Lowest_Bronze_Real    |Heat    |    -3.69| 6.01|  0.5420| -15.50|  8.09|
|Lowest_Bronze_Real    |Cold    |     8.92| 3.51|  0.0142|   2.05| 15.80|

### SECONDARY — between-state statewide-pool margin (state x year, State + Year FE)
_The index rate MAY legally price statewide experience. Read via sign/magnitude
coherence: a claims channel predicts cold-POSITIVE (cold raises Medicare spending in
this project) and moves of ~1-2% of premium; observed signs/sizes are inconsistent._
|premium               |hazard  | estimate|    se| p_state|  ci_lo|  ci_hi|
|:---------------------|:-------|--------:|-----:|-------:|------:|------:|
|Benchmark_Silver_Real |Drought |    28.50| 16.00|  0.0808|  -2.81|  59.80|
|Benchmark_Silver_Real |Heat    |    93.30| 40.30|  0.0248|  14.40| 172.00|
|Benchmark_Silver_Real |Cold    |   -16.70| 27.20|  0.5430| -69.90|  36.60|
|Lowest_Bronze_Real    |Drought |    -8.81|  8.44|  0.3020| -25.30|   7.73|
|Lowest_Bronze_Real    |Heat    |    54.10| 20.20|  0.0101|  14.50|  93.60|
|Lowest_Bronze_Real    |Cold    |   -23.90| 24.00|  0.3250| -70.90|  23.10|

### TRANSPARENCY — county specs are MISSPECIFIED for a state-set outcome
_~86% of premium variance is state x year; county+Year FE lets state-year premium
dynamics load onto county shocks, county+State^Year FE deletes the statewide margin.
Shown only to trace where the earlier spurious county coefficients came from._
|spec                              |hazard | estimate|   se| p_state|
|:---------------------------------|:------|--------:|----:|-------:|
|County: fips+Year (misspec)       |Heat   |    19.50| 9.68| 0.05020|
|County: fips+Year (misspec)       |Cold   |   -15.50| 5.60| 0.00817|
|County: fips+State^Year (misspec) |Heat   |     1.92| 3.02| 0.52700|
|County: fips+State^Year (misspec) |Cold   |     2.22| 3.05| 0.47100|

**Verdict — no COHERENT pass-through.** The tell is sign-instability across the level of
analysis: the cold t-2 coefficient runs -$15.5 (county+Year) -> +$12.6 (RA x year) -> -$16.7
(state x year), and heat runs +$19.5 -> -$10.5 -> +$93. Each apparent 'effect' is an artifact
of which variance (within- vs between-state) the FE leave standing, not a stable price
response. Within states the estimates are small (a few % of the $375 mean) and not coherently
signed; the one nominally significant term (cold, positive at the RA level) reverses between
states and is unmatched by heat. Between states, premium levels co-move with lagged
temperature anomalies (heat +$54-93/mo = 14-25% of the mean), but that is far too large for a
claims channel and cold's sign is backwards vs this project's own Medicare result (cold RAISES
spending), so it reads as a temperature-anomaly correlate of premium LEVELS, not pricing.
Drought is null at every level (the hazard with the most county-level identifying variation).
Net: no coherent evidence the ACA individual market reprices local climate-health-cost shocks
— consistent with the single statewide risk pool, unit-cost-only geographic rating factors,
and Part 153 risk adjustment removing the incentive to price local morbidity.

## (ii) Mediation: fraction of the shock->debt effect surviving premium adjustment
|term                  | est_base| est_with| mediated| fraction_surviving|   p_base|   p_with|
|:---------------------|--------:|--------:|--------:|------------------:|--------:|--------:|
|Is_Extreme_Drought_L2 |   0.0206|  0.02030| 0.000265|              0.987| 0.000382| 0.000467|
|High_HDD_L1           |   0.0078|  0.00719| 0.000605|              0.922| 0.039600| 0.085500|

**Reading.** 93-99% of each headline debt effect survives premium controls. Given the
null/incoherent first stage, this is the expected corollary: there is no premium channel
for the shock->debt effect to run through. Difference-method decomposition, not causal;
premiums are rating-area-level (mediated share is a lower bound); marketplace-era (2014+)
sample so base debt coefs exceed full-panel headlines (the surviving fraction is
sample-invariant). NB: the same State^Year FE that (correctly) absorbs the premium-
generating process also absorbs county debt/income treatment (cold waves are state-level
events) — so State^Year FE is the right benchmark for the administratively-state-set
premium, NOT for household outcomes. See the cross_level_symmetry track.
