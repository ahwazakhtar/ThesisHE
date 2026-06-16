# Track Specification: Hospital Supply-Side Integration

## Description
Restores the proposal's **Chapter 2 (supply side / hospital finances)** by weaving hospital outcomes through the existing three-paper structure (Option 2). The current analysis is demand-heavy: hospitals survive only as `Hosp_BadDebt_PerCapita`, one county-summed outcome. This track builds a **hospital-year panel** from the NASHP Hospital Cost Tool (HCT) and adds supply-side estimates — with **provider heterogeneity** — to each of the Incidence, Persistence, and Inequality papers.

## Unit of analysis (key design decision)
Provider heterogeneity (ownership, safety-net status, system affiliation, bed size, payer mix) is a **hospital-level** attribute that county aggregation destroys. The supply-side analysis therefore runs at the **hospital (CCN) × year** level: each hospital is mapped to its county via Zip Code → county crosswalk, and that county's climate shocks (and SVI) are attached. Hospital FE + year FE; cluster at state (or county). This complements — does not replace — the existing county-summed `Hosp_BadDebt_PerCapita`.

## Data
- **NASHP HCT** `Data/Hosp_Data/NASHP 2011-2023 HCT Data 2025 Feb.xlsx` (sheet `Downloadable`, 114 cols, hospital-year). Already loaded via `readxl` in `process_zip_county_map.R`.
- **Zip→county crosswalk** (`Data/Zip County Crosswalk/`) to map hospital Zip Code → `fips_code`.
- **County climate / SVI / demographics** intermediates (existing) joined on `fips_code` × Year.
- **Medicaid expansion** state-year adoption table (small, hardcoded from KFF expansion dates) — new.

## Variable scope

### Supply-side outcomes (hospital-year)
| Variable | NASHP source | Note |
|----------|--------------|------|
| `Hosp_OperatingMargin` | Operating Profit Margin | headline financial-health outcome |
| `Hosp_NetMargin` | Net Profit Margin | |
| `Hosp_UncompCare` | Uninsured and Bad Debt Cost **+** Net Charity Care Cost | uncompensated care (\$), inflation-adjusted |
| `Hosp_UncompCare_PctNPR` | the two "% of Net Patient Revenue" fields summed | the core Ch. 2 ratio |
| `Hosp_NetPatientRevenue` | Net Patient Revenue | scale / denominator |
| `Hosp_Expenses` | Hospital Expenses (Inclusive of All Services) | |
| `Hosp_NetIncome` | Net Income (Loss) | balance-sheet flow |
| `Hosp_FundBalance` | Fund Balance | balance-sheet stock |

### Provider-heterogeneity moderators (hospital-year / hospital-level)
| Moderator | NASHP source | Use |
|-----------|--------------|-----|
| `SafetyNet` | Medicaid Payer Mix + (Charity & Uninsured/Bad Debt Payer Mix) → top-quartile flag | core heterogeneity axis |
| `Ownership` | Hospital Ownership Type | for-profit / nonprofit / government |
| `SystemAffiliated` | `Independent` flag / Health System ID | market power; vs. independent |
| `MarketConcentration` | county-level HHI from system/hospital revenue shares | market power |
| `BedSize` | Bed Size | size / rural proxy |
| `MedicaidExpansion` | state-year adoption (KFF) | policy moderator |
| `MedicaidPayerMix`, `MedicarePayerMix`, `CommercialPayerMix` | payer-mix fields | exposure to public payers |

### Geography / keys
`CCN#` (hospital id), `Year`, `Zip Code` → `fips_code` (crosswalk), `State`.

## Objectives
- Build a clean hospital-year panel (`Data/intermediate_hospital_panel.rds`) with the outcomes + moderators above, mapped to county.
- **Incidence (Paper 1):** climate shocks → uncompensated care and operating margin (hospital FE + year FE, distributed lags).
- **Persistence (Paper 2):** onset/persist/exit and cumulative-dose dynamics on hospital financials (reuse `transition_symmetry.R`, `cumulative_dose.R`).
- **Provider heterogeneity (Paper 3, supply-side):** Shock × {SafetyNet, Ownership, MedicaidExpansion, MarketConcentration} interactions — the supply-side analogue of the SVI amplification.
- Integrate findings into the three-paper synthesis docs and the committee deck.

## Out of scope
- The Chapter 3 structural model (separate, later).
- Re-architecting the county-summed `Hosp_BadDebt_PerCapita` (kept as-is for the consumer-side hospital channel).

## Acceptance Criteria
- Hospital-year panel built and mapped to county; coverage (n hospitals, county-match rate, year span) reported and tested.
- Supply-side incidence, persistence, and heterogeneity estimates produced with hospital + year FE.
- Provider-heterogeneity interactions (esp. safety-net and Medicaid-expansion) tabulated with an explicit verdict on whether climate-driven hospital strain concentrates in safety-net / high-Medicaid providers.
- Each of the three synthesis docs gains a supply-side subsection; the deck gains hospital slides.
