# Track Specification: County-Level Analysis Refinement

## Description
This track focuses on refining the county-level econometric analysis by implementing event studies, expanding the set of socioeconomic outcomes, and updating the climate shock baseline.

## Objectives
- **Methodological Update:** Recalculate climate Z-scores using a pre-1996 historical baseline to ensure climate shocks are measured against a stable historical climate.
- **Socioeconomic Expansion:** Integrate county-level data for "hours worked" and "income" to analyze broader economic impacts of climate shocks.
- **Event Study Modeling:** Implement event studies and difference-in-differences (diff-in-diff) specifications for various shocks (heat, drought, precipitation).
- **Descriptive Evidence:** Generate comprehensive descriptive statistics to visualize trends and provide context for the regression results.

## Scope
- Update `Code/create_county_master.R` (or relevant scripts) for Z-score recalculation.
- Acquire and merge socioeconomic data (hours worked, income).
- Develop new R scripts for event study analysis and descriptive statistics.
- Update `Analysis/` with new regression tables and figures.

## Acceptance Criteria
- Z-scores are verified to be calculated using the pre-1996 mean and standard deviation.
- "Hours worked" and "income" variables are successfully integrated into the county master panel.
- Event study plots and regression tables for heat, drought, and precipitation shocks are generated.
- Descriptive statistic tables/plots show clear data trends as requested.
