# Advisor Robustness Package (Aug 2026) — Synthesis

**Track:** `advisor_feedback_20260807`. **Date:** 2026-08-07. **Status:** all five
analysis items complete; one construction question flagged back to the advisor (MAD).

Origin: advisor meeting, early Aug 2026 — four directives: (1) test spillovers,
(2) justify clustering per Abadie–Athey–Imbens–Wooldridge (QJE 2023), (3) extend the
time window / show horizon choice doesn't drive results, (4) report mean absolute
deviation in the impulse context. Everything runs on existing machinery + the Census
2023 county adjacency file (only new data input). R 4.5.2 (post-migration — see
`conductor/knowledge/environment.md`).

## One-line verdicts

| # | Item | Verdict | Detail |
|---|---|---|---|
| 1.1 | Spatial spillovers (SUTVA) | **Amplify, don't confound** | Own-vs-neighbor split unidentified (r=0.94–0.97); neighbor block jointly significant for income & employment (p≈0.006); own+neighbor total exceeds own-only baseline (income −157 vs −133; employment −1,090 vs −714). Headlines = lower bounds on regional exposure. | `spillover_synthesis.md` |
| 1.2 | AAIW clustering justification | **State clustering validated** | County clustering anticonservative by up to 7 orders of magnitude; Conley 200 km ≈ state (0.0029 vs 0.0026); headlines survive every defensible level (worst case Conley 300 km: income p=.008, employment p=.029). | `clustering_justification.md` |
| 1.3 | Window extension (BEA) | **Stable, precision improves** | PDSI_Lag1 −99 to −132 across 1990/2000/2011 starts; full window makes contemporaneous PDSI significant (−149, p=5e-6); 2024 forward year moves nothing. 2011–2023 stays the primary estimand population. | `window_extension_note.md` |
| 1.4 | Horizon-choice sensitivity | **Does not drive verdicts** | No sign flips; extension moves h=0–2 by <1 SE; only *shortening* matters (K=2 understates cold employment). Refinements: debt scar transient (gone by h=4); cold employment persists h=3–4 (p=.009/.006). | `horizon_sensitivity_note.md` |
| 1.5 | MAD impulse scaling | **Debt scar = 45% of a typical annual move** | Construction-invariant for debt/income; employment raw-vs-FE scalings diverge 4.3× (persistent series) — **flagged: confirm preferred construction with advisor**. | `mad_scaling_note.md` |

## Does any headline claim need qualification?

**No demotions.** Every robustness direction either strengthens or refines:

- **Drought → income:** strengthened three ways (regional total-exposure larger;
  survives all inference levels incl. border-free Conley; stable back to 1990 with
  improving precision).
- **Cold → employment:** strengthened (regional total larger; persists to h=4 in LP;
  too-short horizons *understate* it). One honest caveat carried in the horizon note:
  the DL h=2 cell loses significance at K≥4 via mechanical SE inflation — the claim
  does not rest on that cell.
- **Drought → debt scar (h=2):** confirmed and refined — transient (fades by h=4),
  large in deviation units (45% of a typical annual move), no drought spillover
  signal (consistent with the standing measurement-fragility caveat).
- **Premium/pass-through claims:** untouched by this track (no premium outcomes here).

**Essay-prose additions (guidance for thesis_completion 2.4/2.5):**
1. Robustness appendix gains four ready subsections (spillovers, inference levels,
   window/horizon, MAD scaling) — each note above is written to be lifted.
2. Qualifier language for headline claims: "county coefficients capture local
   exposure; adjacent-county exposure adds a same-signed regional component the local
   coefficient understates."
3. The clustering note doubles as the inference-methods paragraph (AAIW-cited).

## Open item

MAD construction for the employment rows (raw year-to-year vs FE-residual scaling
diverge on a persistent series) — advisor to confirm preferred lead; table reports
both either way.
