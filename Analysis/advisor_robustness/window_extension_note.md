# Estimation-Window Robustness (BEA Income) — Note

**Track:** `advisor_feedback_20260807`, Task 1.3 (spec O3a). **Date:** 2026-08-07.
**Script:** `Code/run_window_extension.R` (R 4.5.2) → `window_extension_results.csv`;
build log in `build_logs/`.

## Design

Advisor-requested robustness: does the 2011–2023 window choice drive the drought→income
headline? PCPI_Real (BEA CAINC1) and the climate blocks span 1990–2024 in the county
master, so the full FE model (PDSI + High_CDD + High_HDD blocks, county + year FE,
state clustering) re-runs on 2000–2023, 1990–2023, and forward on 2011–2024. All
windows run **without ACS controls** (they exist only ~2012–2022 and would truncate
the panel; headlines are control-robust per `Analysis/control_sensitivity/`), with the
no-controls 2011–2023 window as the like-for-like anchor. ACS outcomes
(Med_HH_Income_Real, Civilian_Employed) start in 2011 and are out of scope by design.

## Results (drought terms, PCPI_Real)

| Window | pdsi_val | PDSI_Lag1 | PDSI_Lag2 | N |
|---|---|---|---|---|
| 2011–2023 (anchor) | −59 (p=.34) | **−132 (p=.003)** | −75 (p=.19) | 39,728 |
| 2000–2023 | −59 (p=.28) | **−99 (p=.0002)** | −93 (p=.03) | 73,344 |
| 1990–2023 (full) | **−149 (p=5e-6)** | **−107 (p=8e-5)** | −95 (p=.02) | 97,792 |
| 2011–2024 (forward) | −62 (p=.33) | **−115 (p=.006)** | −63 (p=.21) | 42,784 |

(Negative PDSI = drought; negative coefficient = income falls in drought. Full grid
incl. CDD/HDD terms in the CSV.)

## Verdict

**The window choice does not drive the headline.** The lagged drought–income effect is
same-signed and of stable magnitude (−99 to −132 real $ per capita per PDSI point) in
every window, and its precision *improves* as the panel lengthens. The full 1990–2023
window additionally renders the contemporaneous PDSI term significant (−149, p=5e-6)
and the second lag marginal-significant — longer exposure history strengthens, not
weakens, the drought result (consistent with the spillover finding that regional
drought exposure amplifies). Extending forward to the populated 2024 BEA year moves
nothing.

Caveats to carry into prose: the extended windows cross regime boundaries (pre-ACA
insurance markets, different drought climatology incl. the 1988–89 aftermath and
2000s Southwest droughts), so the 2011–2023 window remains the primary estimand
population; the extension is a stability check, not a re-specification. The
contemporaneous-term significance in 1990–2023 is reported as window-specific — the
standing "effect loads on lagged drought" claim is unchanged for the primary window.
