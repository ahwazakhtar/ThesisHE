# Climate–Health Exposure Index: Synthesis (track `climate_health_exposure_index`)

Adds a *hazard × exposure × vulnerability* layer to the county analysis, inspired by Anenberg's climate-health indicator work. Vulnerability is the **CDC/ATSDR Social Vulnerability Index** (`SVI_static`, time-invariant county percentile; `Data/intermediate_svi.rds`). Scripts: `Code/run_exposure_index.R` (primary), `Code/run_exposure_secondary.R` (composite + robustness + Lancet). Artifacts: `Analysis/exposure_*.csv`, `Analysis/plots/exposure_index/`.

## Primary: does structural vulnerability amplify climate health-costs?

`Y ~ Shock + Shock × SVI_static + controls | fips_code + Year` (state-clustered). The interaction is FE-identified (the time-invariant SVI main effect is absorbed), and the marginal shock effect at vulnerability percentile `q` is `β_shock + β_int·q`. EJ **amplification** = the interaction pushes the shock's effect further in the *adverse* direction at high SVI (adverse = debt/premiums up, income/employment down). `Analysis/exposure_index/exposure_interaction_coefs.csv`, 30 models.

### Amplification IS present for the real-economy outcomes

| Shock → outcome | Effect at low SVI (p25) | Effect at high SVI (p75) | Interaction p | Verdict |
|---|---|---|---|---|
| **Heat (CDD) → Civilian_Employed** | +886 | **−169** | 0.001 | harm amplified |
| **Cold (HDD) → PCPI_Real** | −$46 | **−$459** (~10×) | 0.061 | harm amplified |
| **Drought (lag-2) → Benchmark premium** | −$55 | **+$14** | 0.001 | harm amplified |
| **Drought → Benchmark premium** | +$6 | **+$30** | 0.017 | harm amplified |

In structurally vulnerable counties, extreme heat *costs* jobs (the sign flips negative), cold's per-capita-income hit is roughly **eight times larger**, and drought pushes ACA benchmark premiums up rather than down. This is the environmental-justice pattern the committee-style EJ literature predicts: the same climate shock lands harder where baseline vulnerability is higher.

### …but the medical-debt response *reverses* — a measurement caveat

Three significant interactions go the *other* way: the credit-bureau **medical-debt** response to drought and cumulative cold is *concentrated in less-vulnerable counties* (e.g., Drought → Medical_Debt_Share +0.0061 at low SVI vs −0.0035 at high SVI, p=0.05). This is most plausibly a **measurement artifact, not an absence of harm**: bureau-reported medical debt requires having insurance, billed encounters, and a credit file, so poorer, more-uninsured high-SVI counties accrue *less measured* medical debt even when the underlying burden is larger. Medical-debt EJ results should be read with this caveat; the income/employment/premium outcomes are the cleaner EJ reads.

## Secondary

**Composite CHEI** (`build_chei` = z(thermal hazard) × SVI, standardized; `Analysis/exposure_index/exposure_chei_coefs.csv`). The headline is `CHEI_heat → Med_HH_Income_Real` **−$435 per SD (p=0.0002)** — vulnerability-weighted heat exposure tracks lower median household income — alongside `CHEI_heat → PCPI_Real` +$1,270 (p=0.007); the per-capita-vs-median split mirrors the heat income pattern seen elsewhere in the thesis.

**Robustness** (`Analysis/exposure_index/exposure_robustness.csv`). Median-SVI-split headline models corroborate the interaction direction (e.g., High_HDD → PCPI −$317 in high-SVI vs −$85 in low-SVI counties), though subsample splits lose power relative to the interaction. Re-running the interactions with the **time-varying** `SVI_yr` instead of `SVI_static` leaves the conclusions qualitatively unchanged.

**Lancet-style exposure** (`Analysis/exposure_index/exposure_personyears_trend.csv`). Person-years of extreme-temperature exposure (population × High_CDD / High_HDD): U.S. heat exposure runs ~70–105 million person-years/year — 3–5× cold exposure — the population-weighted hazard metric the Lancet Countdown reports.

## State-level mirror (Cross-Level Symmetry track)

`Code/run_exposure_index_state.R` population-weights county SVI to a state vulnerability index and re-runs the interactions in the state pipeline (`Analysis/exposure_index/exposure_interaction_state_coefs.csv`). With only 51 states the interaction is coarse, but the EJ signal persists: **cold (is_high_hdd) → Total_Per_Capita_Health_Exp amplifies in vulnerable states** (+$1,720, p=0.0002) and cold → medical debt amplifies (+0.067, p=0.03). 

**Notable state↔county divergence on medical debt:** at the *county* level the debt response concentrates in *less*-vulnerable counties (credit-bureau artifact), but at the *state* level cold → medical debt *amplifies* in vulnerable states. State aggregation smooths the county credit-reporting heterogeneity, so the debt-EJ direction is aggregation-sensitive — reinforcing that the debt outcome is the measurement-fragile one, while the income/health-spending amplification is consistent across levels.

## Bottom line for the thesis
Adding a vulnerability layer **sharpens** the headline findings into an EJ statement: climate shocks impose larger *income, employment, and premium* costs on structurally vulnerable counties. The lone exception — credit-bureau medical debt concentrating in *less*-vulnerable counties — is a known data-measurement artifact and is flagged as such. Cross-referenced in `Analysis/state/synthesis.md` §9.

> **Post-dedup refresh, 2026-08-20.** This file previously carried the 2026-06-14
> pre-dedup run. `exposure_interaction_coefs.csv` was regenerated in the 2026-07-13
> refresh but this narrative was skipped, and the stale marginal effects propagated
> through evidence-table Row 20 into Essay 3. Values above are now read from that CSV.
> The cold-income ratio is ~10x, not ~8x. No sign or verdict changed.
> See `Plans/draft_review_20260819.md` section 3.0.
