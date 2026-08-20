# Farm vs Nonfarm Decomposition of the Distributed-Lag Drought→Income Result

**Script:** `Code/run_farm_nonfarm_distributed_lag.R` (R 4.5.3). **Date:** 2026-08-19.
**Follows from:** `window_extension_note.md` (1.3, window-stability of `PDSI_Lag1` on
`PCPI_Real`) — that check was never split into farm vs nonfarm. The only farm/nonfarm
split on record was for the fragile 2012 single-event 2×2
(`Code/diagnostics/farm_nonfarm_decomposition_drought2012.R`), where ~85% of the raw
ATT turned out to be farm-price mean reversion off the 2011 baseline. This note asks
the same question of the **continuous distributed-lag spec** the essay actually leans on.

## Design

Same outcome construction as the 2012 decomposition (`Farm_PC_Real` from BEA CAINC5N
LineCode 81, deflated to 2023 USD via the county-master CPI series; `NonFarm_PCPI_Real`
= `PCPI_Real` − `Farm_PC_Real`), re-estimating the `run_window_extension.R`
distributed-lag formula (PDSI + 2 lags, High_CDD/HDD + 2 lags each, county+Year FE,
state-clustered) on all three outcomes.

## Result — primary window (2011–2023, matches the headline spec exactly)

| Outcome | `PDSI_Lag1` | SE | p | N |
|---|---:|---:|---:|---:|
| **Total** (`PCPI_Real`) | −132.0 | 42.2 | 0.003 | 39,728 |
| **Farm** (`Farm_PC_Real`) | −55.1 | 24.0 | **0.026** | 39,702 |
| **Nonfarm** (`NonFarm_PCPI_Real`) | −76.8 | 36.2 | **0.039** | 39,702 |

Farm + nonfarm (−55.1 − 76.8 = −131.9) reconstructs the total almost exactly (an
accounting identity on this near-identical sample, not an independent check), but the
substantive result is that **both components are individually significant at p<.05**
in the primary window. Nonfarm carries the larger point estimate (~58% of the total),
farm the rest (~42%).

**This differs from the 2012 event-study decomposition.** There, only farm moved (and
that move was pure mean reversion off the 2011 commodity-price peak); nonfarm was
sign-stable but never conventionally significant. Here, in the primary continuous
spec, nonfarm is not just "sign-stable" — it clears the same p<.05 bar as farm. The
drought→income channel in the distributed-lag spec is **not farm-only**; nonfarm
income moves too, and by a similar order of magnitude.

## Window-extension caveats (read before citing beyond the primary window)

1. **BEA farm earnings only cover 2001–2024** (`bea_cainc5n_earnings_raw.csv`), so the
   1990–2023 full-window check from `window_extension_note.md` cannot be reproduced
   for the farm split. The farthest back this decomposition can go is 2001–2023.
2. **The "2001–2023" farm/nonfarm split is NOT a like-for-like extension of the
   window-stability claim.** Diagnosed directly: restricting the sample to
   farm-data-available counties changes nothing (identical N and coefficients between
   the full master and the farm-matched sample over the same years) — the entire
   effect of moving from `window_extension_note.md`'s 2000–2023 window to this note's
   2001–2023 window is the loss of the single year **2000**. That one year alone
   swings the total-income `PDSI_Lag1` from −99.2 (p=.0002) to −48.4 (p=.140) in the
   full master, before any farm/nonfarm split is applied. Concretely, at 2001–2023:
   `Farm_PC_Real` PDSI_Lag1 = −48.3 (p=.0013) but `NonFarm_PCPI_Real` PDSI_Lag1 =
   −0.78 (p=.98) — nonfarm's contribution vanishes. **Do not read this as "nonfarm
   drops out over a longer panel"** — it is confounded with the year-2000
   sensitivity of the total effect itself, which is a separate, unresolved fragility
   in the window-stability claim (year-2000 alone carries outsized leverage) and
   should be investigated before the "stable across three decades" framing is
   reused without qualification.
3. **The "2011–2024" forward-window farm/nonfarm rows are uninformative** — they are
   numerically identical to 2011–2023 (same N=39,702, same coefficients) because
   `Population` is entirely missing for 2024 in `Data/county_level_master.csv`
   (3,213/3,213 NA), so `Farm_PC_Real` (which divides by `Population`) is NA for
   every 2024 row and those rows drop out via `complete.cases`. This is a genuine
   data-availability gap, not a finding — do not cite the 2011–2024 farm/nonfarm cells
   as forward-robustness confirmation.

## Bottom line

**In the primary 2011–2023 spec — the one the essay's income headline actually rests
on — the drought→income effect is not a farm-only story.** Both farm and nonfarm
per-capita income decline significantly with lagged drought severity, with nonfarm
the larger component. This is a materially different mechanism picture than the 2012
single-event result (farm-reversion artifact, null nonfarm) and should not be
conflated with it. The window-extension exercise that would confirm this split holds
across decades is **not currently available** (data coverage stops the farm series at
2001, and even the 2001 boundary interacts with an unresolved single-year sensitivity
in the total-income result) — flag as open before the essay asserts decade-stability
for the farm/nonfarm split specifically (decade-stability for the *total* PDSI_Lag1
effect stands, per `window_extension_note.md`).

**Outputs:** `Analysis/advisor_robustness/farm_nonfarm_distributed_lag_results.csv`;
build log in `build_logs/`.
