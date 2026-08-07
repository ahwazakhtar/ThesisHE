# MAD Scaling of the Impulse Responses — Note

**Track:** `advisor_feedback_20260807`, Task 1.5 (spec O4). **Date:** 2026-08-07.
**Script:** `Code/run_mad_scaling.R` (R 4.5.2) → `mad_scaling_table.csv`; build log in
`build_logs/`. Descriptive — no hypothesis.

## Construction (both reported, per the spec's open question)

- **MAD_diff** (lead): mean |y_t − y_{t−1}| within county, pooled 2011–2023 — the
  typical year-to-year move.
- **MAD_fe** (secondary): mean |residual| from y ~ 1 | county + year FE — the
  within-variation the FE impulse models actually operate on.

| Outcome | MAD_diff | MAD_fe | ratio |
|---|---|---|---|
| Medical_Debt_Share | 0.0259 (2.59 pp) | 0.0260 | 0.99 |
| PCPI_Real | $2,263 | $2,348 | 0.96 |
| Civilian_Employed | 711 jobs | 3,069 | **0.23** |

## Impulses as shares of typical deviation (LP, h ≤ 3)

| Impulse | β | share of MAD_diff | share of MAD_fe |
|---|---|---|---|
| Drought → debt share, h=2 (the scar) | +0.0116 (p=1.4e-4) | **+0.45** | +0.45 |
| Drought → debt share, h=3 | +0.0066 (p=.08) | +0.26 | +0.25 |
| Cold → employment, h=3 | −381 (p=.009) | **−0.54** | −0.12 |
| Cold → employment, h=0–2 (ns) | −228 to −283 | −0.32 to −0.40 | −0.07 to −0.09 |
| Drought → PCPI, h=1 | +742 (p=.0497) | +0.33 | +0.32 |

## Reading

- **Debt and income:** the two scalings agree (ratios 0.96–0.99), so the "share of a
  typical deviation" is construction-invariant. The h=2 debt scar equals **~45% of a
  typical county's year-to-year move** in the debt share — a substantively large
  impulse in deviation units.
- **Employment diverges (flagged for advisor, per spec):** the year-to-year scaling
  says the cold impulse is large (−0.3 to −0.5 of a typical annual move); the
  FE-residual scaling says modest (−0.07 to −0.12). The gap is mechanical:
  Civilian_Employed is strongly persistent/trending, so within-county FE residuals
  (level deviations from a 13-year county mean, MAD 3,069) dwarf annual changes
  (MAD 711). Neither is wrong — they answer different questions ("how big vs a typical
  annual move" vs "how big vs the within-variation the model uses"). **Lead with
  MAD_diff** (the advisor's "to get an idea" reading); report MAD_fe alongside for the
  employment rows. → Confirm preferred construction with the advisor at the next
  meeting.
