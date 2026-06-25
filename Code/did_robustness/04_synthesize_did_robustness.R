# =============================================================================
# DiD Frontier-Robustness — 04. Synthesis
# =============================================================================
# STATUS: WRITTEN, NOT YET RUN (deferred — see track plan.md, Phase 4).
#
# Collates the three robustness CSVs (wild bootstrap, doubly-robust, HonestDiD)
# into a single markdown summary for the technical note and committee packet.
# Run AFTER 01-03.
#
# Run (R 4.5.3):
#   "C:/Program Files/R/R-4.5.3/bin/Rscript.exe" Code/did_robustness/04_synthesize_did_robustness.R
#
# Output: Analysis/did/robustness/did_robustness_summary.md
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(readr) })
source("Code/did_robustness/00_did_robustness_common.R")

read_if <- function(f) {
  p <- file.path(OUT_DIR, f)
  if (file.exists(p)) read_csv(p, show_col_types = FALSE) else NULL
}
wcb   <- read_if("wild_bootstrap_2x2.csv")
dr2x2 <- read_if("dr_2x2_drought_2012.csv")
csdr  <- read_if("dr_csdid_drought.csv")
honest<- read_if("honestdid_sensitivity.csv")

md <- c(
  "# DiD Frontier-Robustness — Summary",
  "",
  "Robustness layer for the 2012 drought natural-experiment DiD. Run on R 4.5.3.",
  "Estimand: effect of *first* drought onset (ITT; treatment recurs and is 'on'",
  "only ~13% of treated post-period county-years).",
  "",
  "## 1. Few-treated-cluster inference (wild cluster bootstrap + randomization)",
  if (is.null(wcb)) "_pending — run 01_" else
    knitr::kable(wcb %>% select(Outcome, ATT, p_analytic, p_wcb_webb, p_randinf,
                                n_treated_states), format = "pipe", digits = 4),
  "",
  "## 2. Doubly-robust DiD with baseline covariates",
  if (is.null(dr2x2)) "_pending — run 02_" else
    knitr::kable(dr2x2 %>% select(Outcome, ATT, SE, ci_lo, ci_hi),
                 format = "pipe", digits = 4),
  "",
  "### CS doubly-robust simple ATT",
  if (is.null(csdr)) "_pending — run 02_" else
    knitr::kable(csdr, format = "pipe", digits = 4),
  "",
  "## 3. HonestDiD parallel-trends sensitivity (breakdown M-bar)",
  if (is.null(honest)) "_pending — run 03_" else
    knitr::kable(honest, format = "pipe", digits = 4),
  "")

writeLines(md, file.path(OUT_DIR, "did_robustness_summary.md"))
cat("Wrote", file.path(OUT_DIR, "did_robustness_summary.md"), "\n")
