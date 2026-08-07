# run_clustering_sensitivity.R — inference-level sensitivity grid for the headline
# county FE specs (advisor_feedback_20260807, Task 1.2; spec O2).
#
# PURPOSE -------------------------------------------------------------------
# Advisor-requested application of Abadie, Athey, Imbens & Wooldridge, "When Should
# You Adjust Standard Errors for Clustering?" (NBER WP 24003; QJE 2023): justify the
# clustering level by the DESIGN (where treatment assignment is correlated), and show
# the headline inference across candidate levels. Companion methods note:
# Analysis/advisor_robustness/clustering_justification.md.
#
# DESIGN --------------------------------------------------------------------
# One model per outcome — the Spec-2 primary block of run_county_analysis.R (PDSI +
# High_CDD + High_HDD with 2 lags, controls, fips + Year FE, unweighted). Point
# estimates are identical across rows by construction; only the vcov changes:
#   cluster_county  — anticonservative if assignment is correlated beyond county
#                     (it is: own-vs-neighbor shock r = 0.94-0.97, Task 1.1)
#   cluster_state   — PRIMARY (coarsest level nesting the assignment correlation and
#                     the rating-area price-setting unit)
#   conley_100/200/300km — spatial HAC, ignores state borders (200 km primary,
#                     matching run_mechanism_conley.R / B2)
# Cross-references (not re-run): B2 Conley heat results in
# Analysis/mechanism/conley_robustness.csv; RA-cluster premium variants in
# run_county_analysis.R (sensitivity-only per econometrics.md).
#
# EXPECTATION (spec O2): county clustering gives smaller SEs (anticonservative under
# spatially correlated assignment); state stays primary either way; Conley ~200km
# should roughly agree with state-level inference.
#
# INPUTS : Data/county_level_master.csv, Data/Geo/cb_2018_us_county_20m (centroids)
# OUTPUTS: Analysis/advisor_robustness/clustering_sensitivity.csv
#          Analysis/advisor_robustness/build_logs/run_clustering_sensitivity.log
# R 4.5.2.

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
  library(terra)
})
source("Code/pipeline_utils.R")

close_log <- open_build_log("advisor_robustness", "run_clustering_sensitivity")
on.exit(close_log(), add = TRUE)

# 1. Load ------------------------------------------------------------------
df <- read.csv("Data/county_level_master.csv")
df$fips_code <- pad_fips(df$fips_code)
n_excl <- sum(toupper(trimws(df$State)) == "CO" & df$Year == 2023 &
                !is.na(df$Medical_Debt_Share))
df$Medical_Debt_Share[toupper(trimws(df$State)) == "CO" & df$Year == 2023] <- NA_real_
cat("CO-2023 debt exclusion:", n_excl, "obs removed\n")
df$State <- as.factor(df$State)

# County centroids for Conley (same source as run_mechanism_conley.R)
shp <- terra::vect("Data/Geo/cb_2018_us_county_20m")
ctr <- terra::crds(terra::centroids(shp))
cen <- data.frame(fips_code = pad_fips(shp$GEOID), lon = ctr[, 1], lat = ctr[, 2])
df <- left_join(df, cen, by = "fips_code")
cat("Centroids merged:", sum(!is.na(df$lat[!duplicated(df$fips_code)])), "counties\n")

shock_vars <- c("pdsi_val", "PDSI_Lag1", "PDSI_Lag2",
                "High_CDD", "High_CDD_Lag1", "High_CDD_Lag2",
                "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2")
controls <- intersect(c("Household_Income_2023", "Uninsured_Rate"), names(df))
outcomes <- c("PCPI_Real", "Med_HH_Income_Real", "Medical_Debt_Share", "Civilian_Employed")

# 2. Grid ------------------------------------------------------------------
getrow <- function(m, vc, vc_label, outcome, n_clusters = NA) {
  ct <- coeftable(summary(m, vcov = vc))
  data.frame(
    Outcome = outcome, Vcov = vc_label, Term = rownames(ct),
    Estimate = ct[, 1], SE = ct[, 2], p = ct[, 4],
    N = nobs(m), N_Clusters = n_clusters,
    stringsAsFactors = FALSE
  )
}

rows <- list()
for (y in outcomes) {
  vars_needed <- c(y, shock_vars, controls, "fips_code", "Year", "State", "lat", "lon")
  d <- df[complete.cases(df[, vars_needed]), ]
  f <- as.formula(paste(y, "~", paste(c(shock_vars, controls), collapse = "+"),
                        "| fips_code + Year"))
  m <- feols(f, data = d, cluster = "State")

  cat("\n===", y, " N =", nobs(m), " counties =", m$fixef_sizes[["fips_code"]],
      " states =", length(unique(d$State)), "===\n")

  rows[[paste(y, "county")]] <- getrow(m, ~fips_code, "cluster_county", y,
                                       m$fixef_sizes[["fips_code"]])
  rows[[paste(y, "state")]]  <- getrow(m, ~State, "cluster_state", y,
                                       length(unique(d$State)))
  for (km in c(100, 200, 300)) {
    vc <- vcov_conley(m, lat = "lat", lon = "lon", cutoff = km)
    rows[[paste(y, "conley", km)]] <- getrow(m, vc, paste0("conley_", km, "km"), y)
  }
}

# 3. Write ------------------------------------------------------------------
out <- dplyr::bind_rows(rows)
write.csv(out, "Analysis/advisor_robustness/clustering_sensitivity.csv", row.names = FALSE)

cat("\n\n============== HEADLINE TERMS ACROSS INFERENCE LEVELS (p-values) ==============\n")
key_terms <- c("pdsi_val", "PDSI_Lag1", "PDSI_Lag2",
               "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2")
wide <- out %>%
  filter(Term %in% key_terms) %>%
  select(Outcome, Term, Estimate, Vcov, p) %>%
  tidyr::pivot_wider(names_from = Vcov, values_from = p) %>%
  mutate(across(where(is.numeric), ~round(.x, 4)))
print(as.data.frame(wide), row.names = FALSE)

cat("\nWrote Analysis/advisor_robustness/clustering_sensitivity.csv (", nrow(out), "rows )\n")
