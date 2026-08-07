# Event-Study Horizon-Choice Robustness — Note

**Track:** `advisor_feedback_20260807`, Task 1.4 (spec O3b). **Date:** 2026-08-07.
**Scripts:** `Code/run_horizon_sensitivity.R`, `Code/plot_horizon_sensitivity.R`
(R 4.5.2) → `horizon_sensitivity.csv`,
`Analysis/plots/advisor_robustness/horizon_sensitivity.png`; build log in `build_logs/`.

## Design

The event study (`run_event_study.R`) hard-codes h = −2…+3. The horizon choice binds
differently in its two approaches, so the test has two parts:

1. **DL (single dynamic distributed-lag regression)** — lag depth K is a joint modeling
   choice; adding lags can move the h=0–2 coefficients. Re-estimated at K ∈ {2,3,4,5}
   (leads fixed at 2, ref h=−1; K=3 is shipped).
2. **LP (Jordà)** — each horizon is a separate regression, so h=0–2 estimates are
   invariant to which horizons are run *by construction*. Extending to h=4,5 documents
   the impulse tail and the shrinking edge sample (N annotated per horizon).

Headline pairs: drought→debt share (the h=2 scar), drought→PCPI, cold(HDD)→employment.
Unweighted, state clustering, event-study controls, CO-2023 debt exclusion.

## Results

**DL lag depth (deviations scaled by the K=3 clustered SE):**
- Debt: all h=0–2 deviations ≤ 0.08 SE across K — invariant.
- PCPI: deviations ≤ 0.37 SE; all DL h=0–2 terms null at every K (the DL income
  action sits at h=2 ≈ +480–500, stable for K=2–4).
- Employment: extending beyond the shipped depth moves points ≤ ~0.35 SE (h=0:
  −597 → −633 → −632 for K=3→4→5). The only material sensitivity is *shortening* to
  K=2, which attenuates h=0/h=1 by ~0.6 SE (−597 → −375) — consistent with the
  cumulative-dose finding that cold effects build; a too-short window understates
  them. **Honest caveat:** the DL employment h=2 point estimate *grows* with K
  (−728 → −837 → −819) but the SE inflates faster (344 → 506 → 681; p 0.04 → 0.10 →
  0.24) — a mechanical precision loss from the collinear deep-lag block and edge-year
  loss, not attenuation. The cold-employment claim does not rest on this cell (primary
  evidence: Spec-2 county FE lag block and cumulative dose).

**LP extended tail:**
- Debt scar at h=2 reproduced (β = 0.0116, p = 1.4e-4) and shown to be **transient**:
  h=3 fades (0.0066, p = 0.08), h=4–5 null. Extension refines, not overturns.
- Cold employment persistence is **reinforced** at longer horizons: h=3 −381
  (p = 0.009), h=4 −402 (p = 0.006), h=5 −248 (p = 0.09).
- Drought PCPI LP: no long-horizon reversal (h=4–5 null); the marginal +742 at h=1
  (p = 0.0497) is the event-study family's known pattern (binary extreme-drought
  indicator, distinct from the continuous-PDSI county FE headline), unchanged by the
  extension.

## Verdict

**Horizon choice does not drive the headline verdicts.** No sign flips anywhere;
h=0–2 coefficients move well under 1 clustered SE when the window is extended in
either approach; the only sensitivity runs in the conservative direction (a too-short
DL window understates the cold-employment effect). Extensions add refinements — the
debt scar is transient (gone by h=4); cold employment persists through h=4.
