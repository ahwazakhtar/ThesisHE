# Implementation Plan: Mechanisms — Agricultural Channel & Beyond

Track spec: `./spec.md`. Responds to `Text/external_reader_feedback.md`. Reuses the existing
county estimator (`run_county_analysis.R`) and helpers (`cumulative_dose.R`); adds **no new
estimator** — the contribution is a structural agricultural-dependence moderator plus a
mechanism narrative.

Sequencing: Phase 1 (ag-dependence data) is the gate. Phase 2 (the agricultural bound) is the
primary deliverable. Phases 3–4 are lighter (other channels + definitional write-up) and are
independent. Phase 5 synthesizes; Phase 6 tests + closes out.

---

## Phase 0: Scoping & data audit — DONE 2026-07-01 (scope expanded to 5 sources per user "get everything")

Expanded from ag-only to the full mechanism-testing data set. All endpoints verified live.

- [x] **Ag data (Channel 1):**
    - USDA ERS County Typology **2015** CSV (keyless): `https://www.ers.usda.gov/media/6176/ers-county-typology-codes-2015-edition.csv`. FIPS col `FIPStxt`; farm-dependent = `Economic Types Type_2015_Update non-overlapping == 1` (== `Farming_2015_Update == 1`). Data quirks: misspelled label "Maufacturing"; hyphen in `Mining_2015-Update`. Def: farm earnings ≥25% of earnings OR farm emp ≥16%, over 2010–2012.
    - BEA **CAINC5N** (existing key): **LineCode 81** = Farm earnings (111-112); **LineCode 35** = Earnings by place of work (total). `Farm_Earnings_Share = 81/35`. NAICS series covers 2001+ → baseline-average **2001–2010** (pre-study, structural). (CAINC4 alt: 12=Farm income, 35=Earnings.)
- [x] **Industry composition (Channel 2):** ACS **C24030** (existing key), male lines 003–027 / female 029–053. `Ag_Emp_Share = (004+030)/001` (ag/forestry/fishing/hunting only); `ClimateExposed_NonFarm_Share = (mining 005/031 + construction 006/032 + manufacturing 007/033 + transport&warehousing 011/037 + utilities 012/038)/001`. ACS5 county 2011+.
- [x] **Migration (Channel 7):** IRS SOI county-to-county, keyless `https://www.irs.gov/pub/irs-soi/countyinflow<TOK>.csv` / `countyoutflow<TOK>.csv`, tokens 1112…2021 (2011→2021). Cols `y1/y2_statefips,countyfips,state,countyname,n1,n2,agi`; summary rows state FIPS 96/97/98 (97-000=total US migration); non-migrant = origin==destination; suppression = -1; agi in $000s. 2018-19+ dropped whole-state rows + raised threshold to 20.
- [~] **Health utilization/spending (Channel 3):** CMS Medicare Geographic Variation county PUF — audit agent running.
- [~] **Energy burden (Channel 4):** DOE LEAD (NREL/OpenEI) — audit agent running; likely a single cross-sectional vintage (tract→county aggregate), NOT a time series.

## Phase 1: Build the moderators & mechanism data (data gate)

Build runs are self-logged to `Analysis/mechanism/build_logs/*.log`. R runs via script files (not inline `-e`), on R 4.2.2.

- [x] **Task: Ag-dependence moderator.** `download_county_agriculture.R` (USDA CSV + BEA CAINC5N 81/35) + `process_county_agriculture.R` → `Data/intermediate_ag_dependence.rds`. Built 2026-07-01: 3,183 counties; **444 farming-dependent** (USDA non-overlapping type, matches ERS headline; `Ag_Dependent_Flag`=507 broader), `Farm_Earnings_Share` (baseline-avg 2001–2010) for 3,116 counties (median 2%, max 73%), balanced terciles.
- [x] **Task: Climate-exposed industry-share moderator.** `download_county_industry.R` (ACS C24030) + `process_county_industry.R` → `Data/intermediate_industry_composition.rds`. Built: 41,869 county-years (2011–2023), `ClimateExposed_NonFarm_Share` baseline median 25% (5–67%), `Ag_Emp_Share` median 3%, `ClimateExposed_Tercile`, all shares ∈[0,1]. THE variable separating the labor channel from agriculture.
- [x] **Task: County migration (IRS SOI).** `download_county_migration.R` + `process_county_migration.R` → `Data/intermediate_migration.rds`. Built: 29,422 county-years (2012–2021), net-migration rate ~0-centered. CAVEAT: 2021 coverage drops to 1,150 counties (2020-21 disclosure/COVID suppression).
- [x] **Task: Medicare spending/utilization (CMS).** `download_county_medicare.R` (resolves URL via data.json) + `process_county_medicare.R` → `Data/intermediate_medicare_spending.rds`. Built: 31,949 county-years (**2014–2023** — PUF starts 2014), std payment PC median $9,825, ER visits/1000 median 639. (Fix: select-only read via `colClasses="NULL"` — full-char read segfaults the 58MB/246-col file.)
- [x] **Task: Energy burden (DOE LEAD).** `download_county_energy.R` (51 state ZIPs → county AMI CSV, discard ZIP) + `process_county_energy.R` → `Data/intermediate_energy_burden.rds`. Built 2026-07-01: 3,144 counties; overall burden median 3.3%, **low-income (≤80% AMI) median 8.7%** (~2.6× — the distributional signature that maps to high-SVI amplification). TIME-INVARIANT (single 2022 vintage).
- [x] **Task: Tests** `Code/tests/test_mechanism_data.R` (testthat) — all 6 pass: FIPS zero-pad idiom; per-intermediate schema, 5-digit FIPS, no dup keys, share ∈[0,1], tercile sanity, 444 farm-dependent, low-income>overall energy burden.
- [x] **Data-gate validation:** `Code/diagnostics/check_mechanism_merge.R` — all 5 intermediates merge onto county master at 97.3–98.5%. Unmatched ~2% are known FIPS boundary cases (CT 2022 planning regions `091xx`↔old `090xx`; AK renames `02280/02201`; CO `089xx`; DC/Baltimore). Log in build_logs/.

**Phase 1 COMPLETE (2026-07-01).** All five mechanism data sources built, validated, tested. Ready for Phase 2 estimation. Raws under `Data/County_{Agriculture,Industry,Migration,Health_Spending,Energy}/` are large and NOT for git; commit only the R scripts + intermediates decision docs.

## Phase 2: Bound the agricultural channel + test the surviving channels (PRIMARY)

All specs reuse the county estimator (`fixest::feols`, County+Year FE, state-clustered),
per `run_county_analysis.R`. Moderators/outcomes come from the Phase-1 intermediates merged
onto `county_level_master.csv` by `fips_code`. Headline shocks: `Is_Extreme_Drought`,
`High_HDD`, `High_CDD` (+ lags); AQI (`Max_AQI`/`High_AQI_Max`, `Median_AQI`) added for the
morbidity channel.

- [x] **Task 2a: Agricultural-channel bound (PRIMARY).** `Code/run_mechanism_agriculture.R` →
      `Analysis/mechanism/ag_channel_coefs.csv` (270 rows). Spec A (interaction `Shock×Ag_z`) + Spec B
      (bottom-ag-tercile subsample) for 6 outcomes × 3 shocks. Ratio `effect_bottom/effect_overall`
      logged (fragile when overall≈0 — lead on significance, not the ratio).
- [x] **Task 2b: Labor-channel test.** Same script, moderator `ClimateExposed_NonFarm_Share`
      (`Labor_z` interaction + exposed-tercile). **Early signal:** heat(CDD)→employment loads on
      `Labor_z` (−689, p=0.009), NOT primarily on ag; cold(HDD)→medical-debt loads on `Labor_z`
      (+0.0021, p=0.03) — non-agricultural signatures. Full synthesis deferred to 2f.
- [x] **Task 2c: Medicare morbidity/utilization regressions (Channel 3).** `Code/run_mechanism_medicare.R`
      → `Analysis/mechanism/medicare_channel_coefs.csv` (120 rows), 2014–2023. **Strong results:**
      heat(CDD)→std spending +$112/+$177(Lag1)/+$75 per beneficiary (all p<0.02) and →ED visits
      +7.8/+9.5(Lag1); cold(HDD) Lag2 →+$85 spending & +9.0 ED visits; **AQI→ED visits +4.8/+3.3/+2.8
      (all sig)** — reproduces Deryugina et al. 2019 pollution-morbidity in-panel. Subsample_low_ag
      rows in CSV for the separability read. Caveat logged: Medicare=65+/disabled, 2014–2023.
- [x] **Task 2d: Energy-burden distributional test (Channel 4).** `Code/run_mechanism_secondary.R` →
      `Analysis/mechanism/energy_channel_coefs.csv`. **Result:** heat damage concentrates in
      high-energy-burden counties (`High_CDD×EnergyBurden_z` −1,380 employment p<0.001; −$370 income
      p<0.001). Honest cross-check: `corr(energy burden, SVI_static)=0.11` — a partly DISTINCT
      vulnerability axis, not an SVI restatement. Low-income burden 8.9% vs 3.4% overall.
- [x] **Task 2e: Migration selection check (Channel 7 caveat).** Same script →
      `migration_selection_coefs.csv`. **Result:** `Is_Extreme_Drought` Lag1 → net migration −0.0021
      (p=0.047): drought counties lose population → part of the scar is SELECTION. (Heat→in-migration
      = Sun Belt confound, not interpreted.) Bounded caveat, not a decomposition.
- [x] **Task 2f: Verdict.** `Analysis/mechanism/mechanism_verdict.md` + 3 forest plots
      (`Code/run_mechanism_synthesis.R` → `Analysis/mechanism/plots/`). Answers the reviewer's ratio
      question: (1) morbidity/utilization channel is ENTIRELY non-agricultural and cleanest-identified;
      (2) cold-employment survives/strengthens in low-ag counties + heat-employment loads on non-farm
      labor; (3) agricultural signature is real but event-specific (2012) and partly selection.

**Phase 2 COMPLETE (2026-07-01).** Ag bound + labor test + Medicare morbidity + energy-burden +
migration selection all estimated; verdict written. Lead the write-up with morbidity + labor
exposure (robust, non-agricultural, in-panel); energy burden as independent distributional channel;
agriculture as narrower event-specific contributor.

## Phase 3: Other channels (bounded, suggestive)

- [x] **Task: Map the channel set.** `Analysis/mechanism/mechanism_channels.md` DRAFTED 2026-07-01 (lit-review grounded; not yet committed).
    - [x] **Hospital-finance channel** — cross-referenced `hospital_supply_side_20260615`; flagged as a GAP in external lit (thin) → likely our own contribution.
    - [x] **Air-quality / health channel** — morbidity/utilization pathway written (Deryugina et al. 2019 PM2.5 IV; IJPH 2025 county utilization).
    - [x] **Energy-burden & labor-reallocation** — energy-burden channel (Doremus et al. 2022) + AC-adaptation micro-foundation for high-SVI (Barreca et al. 2016); labeled suggestive. Optional HDD/CDD×SVI proxy estimate left as a Phase 3 follow-up.
    - Grounded in a verified deep-research pass (artifact `tasks/w9et4j0km.output`): 25 primary sources, 24 confirmed / 1 refuted claims. **Refuted:** D&G's +$1.3B aggregate farm-profit figure (Fisher et al. 2012 coding errors) — do not cite. **Gaps:** health-insurance pricing (Ch.6) and migration/reallocation (Ch.7) have no identified external estimate; treat as caveats/open questions.
    - **Steers Phase 2:** the decisive separability test the lit implies is the weekday/weekend + low-ag-tercile split; labor-supply-in-exposed-non-farm-industry, morbidity/utilization, and energy burden are the channels predicted to SURVIVE in low-ag counties.

## Phase 4: Definitional write-up (reviewer's "set-aside" items)

- [ ] **Task: Document shocks-as-distributional-draws.** Add to `Text/technical_note_empirical_framework.html`: shocks are z-score deviations anchored to the **1990–2000** baseline (per-county mean/SD) — i.e. defined as departures from each county's own historical distribution, addressing "unanticipatable given historical averages."
- [ ] **Task: Document multiple-shock handling.** Same note: cumulative-dose (`cumulative_dose.R`) and compound/`Any_Shock` specs already absorb shock multiplicity; reference them.

## Phase 5: Synthesis & integration

- [ ] **Task: Mechanisms subsection.** Fold the agricultural bound + other-channel map into the relevant synthesis doc(s) and the technical note; one-paragraph reviewer-facing answer to "how much cannot be explained by agriculture?"
- [ ] **Task: (Optional) deck slide** summarizing the agricultural-channel bound, if a committee deck update is wanted.

## Phase 6: Tests & conductor close-out

- [x] **Task: Tests** `Code/tests/test_mechanism_estimation.R` (5 pass): synthetic-panel interaction/subsample sign recovery, tercile split correctness, ag/medicare CSV schema integrity, Medicare 2014–2023 window. (`test_mechanism_data.R` covers the Phase-1 builds — 6 pass.)
- [x] **Task: Conductor close-out** — changelog / GEMINI / CLAUDE / tracks.md updated; conductor commit (Session 8, 2026-07-01).
- [ ] **User Manual Verification gate.**

---

### Notes / lessons (live)
- Use **structural / baseline** ag-dependence as the moderator — never contemporaneous farm
  income (bad control on the causal path).
- FIPS zero-pad with `formatC(as.integer(fips), width=5, flag="0")`, NOT `sprintf("%05s", …)`.
- County master `State` is a 2-letter abbreviation; any state-name join needs the abbrev→name map.
- Lead the agricultural-bound narrative with the **real-economy** outcomes (income/employment);
  medical debt is the measurement-fragile, aggregation-sensitive outcome.
