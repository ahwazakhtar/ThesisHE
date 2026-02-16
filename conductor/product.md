# Initial Concept
This is a research project focused on the aggregation and analysis of United States health, climate, and economic data. The project relies on R for data acquisition and subsequent analysis. The primary goal is constructing a multi-dimensional dataset spanning several years (mostly ~2011-2026) to investigate relationships between environmental factors (Climate, AQI), health costs (HIX premiums, Hospital costs, Medical debt), and policy.

# Product Definition

## Target Audience
The primary audience for this research includes academic researchers, thesis committees, and scholars specializing in environmental economics, public health, and econometric modeling.

## Project Goals
- **Quantify Climate Impact:** Investigate and quantify the causal relationships between extreme climate events (such as drought and cold shocks) and their impact on health insurance premiums, hospital costs, and medical debt.
- **Dataset Construction:** Construct a robust, multi-dimensional longitudinal dataset at both state and county levels, integrating diverse sources for longitudinal econometric analysis.
- **Empirical Policy Evidence:** Provide empirical, data-driven evidence to inform policy discussions regarding the systemic financial burdens of climate change on the US healthcare system.

## Research Workflow & Components
- **Data Engineering:** Perform sophisticated state-level and county-level data consolidation, including Zip-to-County mapping, population weighting, and feature engineering of local climate shocks (Z-scores) and absolute extremes.
- **Econometric Modeling:** Execute rigorous Fixed-Effects (FE) econometric models with state-level clustering to account for unobserved heterogeneity and ensure statistical validity.
- **Analysis & Reporting:** Generate comprehensive visualizations and statistical summaries of regression results (coefficients, standard errors, p-values) to communicate research findings effectively.

## Current Focus
The project is currently focused on refining county-level analysis using local climate shocks and population weighting, while simultaneously synthesizing state-level findings for the final research paper or thesis.
