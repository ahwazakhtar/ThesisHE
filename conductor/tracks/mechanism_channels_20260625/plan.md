# Implementation Plan: Mechanisms — Agricultural Channel & Beyond

Track spec: `./spec.md`. Responds to `Text/external_reader_feedback.md`. Reuses the existing
county estimator (`run_county_analysis.R`) and helpers (`cumulative_dose.R`); adds **no new
estimator** — the contribution is a structural agricultural-dependence moderator plus a
mechanism narrative.

Sequencing: Phase 1 (ag-dependence data) is the gate. Phase 2 (the agricultural bound) is the
primary deliverable. Phases 3–4 are lighter (other channels + definitional write-up) and are
independent. Phase 5 synthesizes; Phase 6 tests + closes out.

---

## Phase 0: Scoping & data audit

- [ ] **Task: Confirm reachable agricultural data.**
    - [ ] Verify USDA ERS County Typology 2015 download URL/format (keyless CSV).
    - [ ] Confirm BEA farm-earnings table + line codes (CAINC5N "Farm earnings" vs CAINC4) reachable with existing `BEA_API_KEY`; pick one and document.
    - [ ] Confirm an ACS ag-employment variable (`C24030` / `DP03`) returns for 2011–2023.
    - [ ] Decide the composite `Ag_Dependence` definition (USDA flag + baseline farm-earnings share; ACS ag-emp share as cross-check). Record in spec/header.

## Phase 1: Build the agricultural-dependence moderator (data gate)

- [ ] **Task: Download ag data.**
    - [ ] New `Code/download_county_agriculture.R`: USDA ERS typology CSV; BEA farm + total earnings (all counties, all years); ACS ag-sector employment. Save raws under `Data/County_Agriculture/`.
- [ ] **Task: Process to a structural moderator.**
    - [ ] New `Code/process_county_agriculture.R`: FIPS zero-pad via `formatC(..., width=5, flag="0")` (avoid the `%05s` space-pad trap); compute `Farm_Earnings_Share` and `Ag_Emp_Share` **averaged over a pre/baseline window** (time-invariant); attach `Ag_Dependent` (USDA) and `Ag_Dependence_Tercile`. Output `Data/intermediate_ag_dependence.rds`.
    - [ ] Tests `Code/tests/test_ag_dependence.R` (testthat): schema; FIPS all 5-digit; coverage / county-match rate; tercile cut sanity; farm-share ∈ [0,1] plausible range.

## Phase 2: Bound the agricultural channel (PRIMARY)

- [ ] **Task: Heterogeneity + subsample estimates.**
    - [ ] New `Code/run_mechanism_agriculture.R`: load county master + ag-dependence; for each (outcome, shock) in the headline set —
        - **Spec A (interaction):** `Y ~ Shock(+lags) + Shock×Ag_Dependence + controls | County + Year`, cluster State. Does the effect *load* on agricultural counties?
        - **Spec B (subsample):** re-estimate the baseline within the **bottom ag-dependence tercile**. The surviving effect = the part **not** explained by agriculture.
    - [ ] Outcomes: `PCPI_Real`, `Med_HH_Income_Real`, `Civilian_Employed`, `Benchmark_Silver_Real`, `Lowest_Bronze_Real`, medical-debt share. Shocks: `Is_Extreme_Drought`, `High_HDD`, `High_CDD` (ag-relevant drought/cold lead).
    - [ ] Export `Analysis/mechanism/ag_channel_coefs.csv` + plots; compute and record `effect_low_ag / effect_overall` per pair.
- [ ] **Task: Verdict.** State which headline findings are **mostly agricultural** (effect collapses in low-ag counties) vs. which **persist in non-agricultural counties** (the residual needing other channels). Watch the medical-debt measurement-fragility caveat.

## Phase 3: Other channels (bounded, suggestive)

- [ ] **Task: Map the channel set.** New `Analysis/mechanism/mechanism_channels.md`:
    - [ ] **Hospital-finance channel** — cross-reference `hospital_supply_side_20260615` results (do not re-estimate).
    - [ ] **Air-quality / health channel** — summarize existing AQI results as a morbidity-utilization pathway.
    - [ ] **Energy-burden & labor-reallocation** — add a feasible proxy if data allows (e.g. heating/cooling-degree-day cost intuition; ag→nonfarm employment shift using `Civilian_Employed` already in panel), explicitly labeled **suggestive, not identified**.

## Phase 4: Definitional write-up (reviewer's "set-aside" items)

- [ ] **Task: Document shocks-as-distributional-draws.** Add to `Text/technical_note_empirical_framework.html`: shocks are z-score deviations anchored to the **1990–2000** baseline (per-county mean/SD) — i.e. defined as departures from each county's own historical distribution, addressing "unanticipatable given historical averages."
- [ ] **Task: Document multiple-shock handling.** Same note: cumulative-dose (`cumulative_dose.R`) and compound/`Any_Shock` specs already absorb shock multiplicity; reference them.

## Phase 5: Synthesis & integration

- [ ] **Task: Mechanisms subsection.** Fold the agricultural bound + other-channel map into the relevant synthesis doc(s) and the technical note; one-paragraph reviewer-facing answer to "how much cannot be explained by agriculture?"
- [ ] **Task: (Optional) deck slide** summarizing the agricultural-channel bound, if a committee deck update is wanted.

## Phase 6: Tests & conductor close-out

- [ ] **Task: Tests** for `run_mechanism_agriculture.R` interaction/subsample machinery on a synthetic panel (sign recovery; tercile split correctness).
- [ ] **Task: Conductor close-out** — changelog / GEMINI / CLAUDE updates and conductor commit per `workflow.md`.
- [ ] **User Manual Verification gate.**

---

### Notes / lessons (live)
- Use **structural / baseline** ag-dependence as the moderator — never contemporaneous farm
  income (bad control on the causal path).
- FIPS zero-pad with `formatC(as.integer(fips), width=5, flag="0")`, NOT `sprintf("%05s", …)`.
- County master `State` is a 2-letter abbreviation; any state-name join needs the abbrev→name map.
- Lead the agricultural-bound narrative with the **real-economy** outcomes (income/employment);
  medical debt is the measurement-fragile, aggregation-sensitive outcome.
