# Product Guidelines

## Communication & Documentation Style
- **Academic Precision:** Documentation and research papers must maintain a formal, objective, and precise tone, adhering strictly to peer-reviewed academic standards.
- **Methodological Depth:** A priority is placed on creating a detailed and permanent record of the economic methodology and data nuances, ensuring that the rationale behind modeling choices is as well-documented as the results themselves.

## Data Integrity & Transparency
- **Reproducibility:** All R scripts in the `Code/` directory and data transformations must be documented with sufficient detail to allow for complete replication of results by independent researchers.
- **Methodological Auditability:** Maintain rigorous documentation of complex feature engineering steps, particularly for non-trivial transformations like Zip-to-County crosswalks and population weighting, ensuring the logic is auditable.

## Presentation of Findings
- **Standardized Reporting:** Regression results must be presented in a standardized, academic format (e.g., Stargazer-style tables) to ensure consistency and comparability across different reports and chapters.
- **Visual Clarity & Impact:** Data visualizations (e.g., via `ggplot2`) should prioritize clarity, professional aesthetics, and clear labeling to effectively illustrate trends and the impact of climate shocks.
- **Contextual Depth:** Every table and figure must be accompanied by comprehensive documentation—either via detailed footnotes or appendices—explaining variables, lag structures, and clustering methods.

## Code Documentation Standards
- **Functional Commenting:** R scripts should include concise, high-value comments that explain the *why* behind specific logic, data cleaning steps, or statistical modeling decisions.
- **Architectural Overview:** High-level READMEs or methodology summaries in the `Analysis/` directory must be maintained to provide an overview of the purpose and flow of the script library.
