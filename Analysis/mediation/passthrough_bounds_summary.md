# Premium Pass-through — MDE & Equivalence (TOST) Bounds

_Generated 2026-07-13 (audit_response_20260712, task 2.1 / spec O4). Primary spec: rating-area x year,
RA + State^Year FE, population-weighted, state-clustered — IDENTICAL to the premium-mediation primary
spec. Outcome: `Benchmark_Silver_Real` (benchmark premium; pop-weighted sample mean **$366/mo**,
the object the morbidity benchmark maps to). Coefficients are $/fully-exposed-unit on pop-weighted
lagged shock SHARES; lag 2 primary (rate-filing timing), lag 1 secondary. Estimates RE-ESTIMATED here
and cross-checked against `premium_mediation_summary.md` (3 sig figs) and `premium_passthrough.csv`._

## Why bound the null

"No coherent pass-through" is only a headline if the null is BOUNDED. We report, per shock and lag:

- **MDE (80% power, alpha=.05 two-sided) = 2.80 x SE** — the smallest true pass-through this design
  could reliably detect.
- **TOST equivalence bound delta\* = |beta| + 1.645 x SE** — the smallest margin at which we can reject that
  the true effect is *as large as* delta\* (with the 90% CI).

## Benchmark: what FULL morbidity-cost pass-through would look like

The project measures heat raising standardized **Medicare** spending **$112/beneficiary** contemporaneously
and **$177/beneficiary** the following year (annual). Under FULL pass-through of a morbidity cost of that
scale to the marketplace risk pool, monthly premiums would rise **$112/12 = $9.33** to **$177/12 = $14.75
PMPM**. This is the band each bound is measured against.

> **POPULATION-MISMATCH CAVEAT (read first).** The benchmark uses MEDICARE (65+/disabled) morbidity as a
> proxy for the SCALE of climate morbidity cost in the ACA under-65 individual market (the audit's §7
> caveat) — not a claim the populations cost the same. Two institutions make the true marketplace
> pass-through *smaller* than even this proxy, so a small bound is EXPECTED on institutional grounds:
> (a) the geographic rating factor (45 CFR 156.80) prices provider UNIT COSTS, not local morbidity; and
> (b) ACA **Part 153 risk-adjustment transfers** move revenue within a state's single risk pool to
> neutralise morbidity differences, mechanically pushing MEASURED local pass-through toward zero. The
> band is therefore an UPPER reference for "full pass-through," and the institutions predict the local
> margin should not price it.

## Bounds (primary premium, `Benchmark_Silver_Real`)

|hazard  |lag | beta ($/mo)|    SE|90% CI          | MDE ($/mo)| delta* ($/mo)|delta* (% mean) |delta* x band |verdict |
|:-------|:---|-----------:|-----:|:---------------|----------:|-------------:|:---------------|:-------------|:-------|
|Drought |L2  |       3.130|  2.60|[-1.15, 7.40]   |       7.28|          7.40|2.02%           |0.50-0.79     |STRONG  |
|Drought |L1  |       0.699|  4.84|[-7.26, 8.66]   |      13.50|          8.66|2.36%           |0.59-0.93     |STRONG  |
|Heat    |L2  |     -10.400|  8.63|[-24.59, 3.79]  |      24.20|         24.60|6.72%           |1.67-2.63     |SOFTER  |
|Heat    |L1  |     -11.400| 10.90|[-29.37, 6.55]  |      30.60|         29.40|8.02%           |1.99-3.15     |SOFTER  |
|Cold    |L2  |      12.600|  5.75|[3.11, 22.03]   |      16.10|         22.00|6.02%           |1.49-2.36     |SOFTER  |
|Cold    |L1  |      -8.550|  5.01|[-16.79, -0.32] |      14.00|         16.80|4.59%           |1.14-1.80     |SOFTER  |

_`delta* x band` = delta\* as a multiple of the $14.75 (high) and $9.33 (low) benchmark; <1 on both means
the equivalence bound is inside the full-pass-through band (strong)._

## Per-shock verdicts (no cherry-picking — every cell reported)

**Drought, L2 (primary).** delta* = $7.40/mo (2.0% of the $366 mean; 79.3% of the $9.33 contemporaneous and 50.2% of the $14.75 following-year morbidity benchmark). The data RULE OUT a within-state benchmark-premium response as large as full morbidity-cost pass-through: we can rule out pass-through larger than ~50.2%-79.3% of the morbidity benchmark band.

**Drought, L1 (secondary).** delta* = $8.66/mo (2.4% of the $366 mean; 92.7% of the $9.33 contemporaneous and 58.7% of the $14.75 following-year morbidity benchmark). The data RULE OUT a within-state benchmark-premium response as large as full morbidity-cost pass-through: we can rule out pass-through larger than ~58.7%-92.7% of the morbidity benchmark band.

**Heat, L2 (primary).** delta* = $24.59/mo (6.7% of the $366 mean) EXCEEDS the $9.33-$14.75 benchmark band, so equivalence with full pass-through cannot be rejected for this cell. The honest claim is the softer one: a BOUNDED within-state response (delta* is 6.7% of the mean premium) plus cross-level sign instability (see the mediation summary) — not a tight institutional null.

**Heat, L1 (secondary).** delta* = $29.37/mo (8.0% of the $366 mean) EXCEEDS the $9.33-$14.75 benchmark band, so equivalence with full pass-through cannot be rejected for this cell. The honest claim is the softer one: a BOUNDED within-state response (delta* is 8.0% of the mean premium) plus cross-level sign instability (see the mediation summary) — not a tight institutional null.

**Cold, L2 (primary).** delta* = $22.03/mo (6.0% of the $366 mean) EXCEEDS the $9.33-$14.75 benchmark band, so equivalence with full pass-through cannot be rejected for this cell. The honest claim is the softer one: a BOUNDED within-state response (delta* is 6.0% of the mean premium) plus cross-level sign instability (see the mediation summary) — not a tight institutional null.

**Cold, L1 (secondary).** delta* = $16.79/mo (4.6% of the $366 mean) EXCEEDS the $9.33-$14.75 benchmark band, so equivalence with full pass-through cannot be rejected for this cell. The honest claim is the softer one: a BOUNDED within-state response (delta* is 4.6% of the mean premium) plus cross-level sign instability (see the mediation summary) — not a tight institutional null.

## Allocation-rule sensitivity — equal-split (primary) vs full-pop (old implicit)

The RA panel is rebuilt from source `Data/premiums_county.csv` (audit A3). A split county's population is EQUAL-SPLIT across its rating areas (primary). The **full-pop** rule instead assigns each split county's whole population to every rating area it touches (the pre-dedup implicit behavior; it reproduces the pre-dedup drought L2 beta ~2.48). Verdicts are **IDENTICAL** across the two rules (6/6 cells match) — the drought STRONG bound does not depend on the allocation choice.

|hazard  |lag | delta* (equal)|verdict (equal) | delta* (full-pop)|verdict (full-pop) |
|:-------|:---|--------------:|:---------------|-----------------:|:------------------|
|Drought |L2  |           7.40|STRONG          |              6.32|STRONG             |
|Drought |L1  |           8.66|STRONG          |              8.30|STRONG             |
|Heat    |L2  |          24.60|SOFTER          |             24.60|SOFTER             |
|Heat    |L1  |          29.40|SOFTER          |             29.40|SOFTER             |
|Cold    |L2  |          22.00|SOFTER          |             22.00|SOFTER             |
|Cold    |L1  |          16.80|SOFTER          |             16.70|SOFTER             |

## Bottom line

The strong bound is licensed for **drought** (both lags): its tight within-state SE (a few % of the $366 mean) puts delta\* BELOW the full-pass-through band, so the data rule out a benchmark-premium response as large as full Medicare-morbidity pass-through. For **heat** and **cold** the SEs are larger and delta\* exceeds the $9.33-$14.75 band: equivalence with full pass-through cannot be rejected for those hazards, so the honest claim is the softer one — a **bounded** within-state response (delta\* is only ~4-8% of the mean premium) combined with the **cross-level sign instability** documented in `premium_mediation_summary.md`. Either way the null is bounded to a small share of the premium, and no hazard shows a coherent, stably-signed local price response.

### Recorded expectation — did it hold?

Expectation (logged before the run): within-state SEs are small, so the MDE should sit below the full-pass-through band, licensing the strong verdict. **Held for 1 of 6 primary cells.** It holds for drought (tight SE) but NOT for heat/cold, whose SEs are large enough that the MDE/delta\* clears the (itself-small, 2.5-3.9% of $366) benchmark band. Verified as a finding, not a bug: the re-estimates reproduce the mediation summary to 3 sig figs (see build log).

## Robustness — `Lowest_Bronze_Real` (secondary outcome, not the headline object)

|hazard  |lag | beta ($/mo)|   SE| MDE ($/mo)| delta* ($/mo)|delta* (% mean) |verdict |
|:-------|:---|-----------:|----:|----------:|-------------:|:---------------|:-------|
|Drought |L2  |        5.23| 2.74|       7.66|          9.74|3.24%           |MIXED   |
|Drought |L1  |        4.29| 2.12|       5.92|          7.77|2.59%           |STRONG  |
|Heat    |L2  |       -3.74| 6.01|      16.80|         13.60|4.53%           |MIXED   |
|Heat    |L1  |       -7.45| 6.49|      18.20|         18.10|6.03%           |SOFTER  |
|Cold    |L2  |        8.85| 3.53|       9.88|         14.70|4.88%           |MIXED   |
|Cold    |L1  |        1.48| 3.96|      11.10|          8.00|2.66%           |STRONG  |

_Bronze is a 60%-actuarial-value plan (lower mean premium), so its %-of-mean and benchmark multiples are
not directly comparable to the silver benchmark; shown only to confirm the qualitative pattern is not an
artifact of the silver outcome._

---
_Method notes: MDE constant 2.80 = qnorm(.975)+qnorm(.80); TOST z = 1.645 = qnorm(.95). Sample-mean premium
is the pop-weighted mean over the exact feols estimation sample. Spec, weights, clustering and the ~484
duplicate-county-year dedup context are inherited verbatim from `run_premium_mediation.R` (read, not modified)._
