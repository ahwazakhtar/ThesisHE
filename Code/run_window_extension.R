# run_window_extension.R — estimation-window robustness for the BEA income headline
# (advisor_feedback_20260807, Task 1.3; spec O3a).
#
# PURPOSE -------------------------------------------------------------------
# Advisor: extend the time window backward as a robustness check. Only BEA-derived
# outcomes can extend before 2011 (PCPI_Real spans 1990-2024 in the master; ACS
# outcomes Med_HH_Income_Real / Civilian_Employed start 2011 — OUT OF SCOPE here by
# design, stated not fudged). Controls (Household_Income_2023, Uninsured_Rate) are
# ACS/SAHIE-based and only exist ~2012-2022, so all windows run WITHOUT controls —
# justified by the control-sensitivity result (headlines control-robust;
# Analysis/control_sensitivity/). The 2011-2023 no-controls window is the anchor for
# comparability; a 2011-2024 forward window is included since BEA 2024 is populated.
#
# WINDOWS: 2011-2023 (anchor) | 2000-2023 | 1990-2023 (full) | 2011-2024 (forward)
#
# EXPECTATION (spec O3a): drought-income sign and rough magnitude stable across
# windows; regime caveats (pre-ACA, different drought climatology) documented in the
# note either way.
#
# INPUTS : Data/county_level_master.csv
# OUTPUTS: Analysis/advisor_robustness/window_extension_results.csv
#          Analysis/advisor_robustness/build_logs/run_window_extension.log
# R 4.5.2.

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
})
source("Code/pipeline_utils.R")

close_log <- open_build_log("advisor_robustness", "run_window_extension")
on.exit(close_log(), add = TRUE)

df <- read.csv("Data/county_level_master.csv")
df$fips_code <- pad_fips(df$fips_code)
df$State <- as.factor(df$State)

shock_vars <- c("pdsi_val", "PDSI_Lag1", "PDSI_Lag2",
                "High_CDD", "High_CDD_Lag1", "High_CDD_Lag2",
                "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2")
stopifnot(all(shock_vars %in% names(df)), "PCPI_Real" %in% names(df))

windows <- list(
  c(2011, 2023),   # anchor (baseline window, no controls)
  c(2000, 2023),
  c(1990, 2023),   # full BEA span
  c(2011, 2024)    # forward extension (BEA 2024 populated)
)

f <- as.formula(paste("PCPI_Real ~", paste(shock_vars, collapse = "+"),
                      "| fips_code + Year"))

rows <- list()
for (w in windows) {
  lab <- paste0(w[1], "-", w[2])
  d <- df %>% filter(Year >= w[1], Year <= w[2])
  d <- d[complete.cases(d[, c("PCPI_Real", shock_vars, "fips_code", "Year", "State")]), ]
  m <- feols(f, data = d, cluster = "State")
  cat("\n=== Window", lab, " N =", nobs(m), " counties =", m$fixef_sizes[["fips_code"]],
      " years =", length(unique(d$Year)), "===\n")
  print(summary(m, n = 12))
  ct <- coeftable(m)
  rows[[lab]] <- data.frame(
    Window = lab, Term = rownames(ct),
    Estimate = ct[, 1], SE = ct[, 2], p = ct[, 4],
    N = nobs(m), Counties = m$fixef_sizes[["fips_code"]],
    Years = length(unique(d$Year)),
    stringsAsFactors = FALSE
  )
}

out <- dplyr::bind_rows(rows)
write.csv(out, "Analysis/advisor_robustness/window_extension_results.csv", row.names = FALSE)

cat("\n\n============ DROUGHT TERMS ACROSS ESTIMATION WINDOWS (PCPI_Real) ============\n")
key <- c("pdsi_val", "PDSI_Lag1", "PDSI_Lag2")
print(out %>%
        filter(Term %in% key) %>%
        mutate(across(c(Estimate, SE, p), ~signif(.x, 3))) %>%
        select(Window, Term, Estimate, SE, p, N),
      row.names = FALSE)
cat("\nWrote Analysis/advisor_robustness/window_extension_results.csv (", nrow(out), "rows )\n")
