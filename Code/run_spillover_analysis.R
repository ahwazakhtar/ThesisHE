# run_spillover_analysis.R — spatial spillover test on the headline county FE specs
# (advisor_feedback_20260807, Task 1.1; spec O1).
#
# PURPOSE -------------------------------------------------------------------
# The SUTVA caveat (results_interpretation_guide.md §7) says climate shocks are
# spatially correlated and spillovers are unaddressed. This script tests it directly:
# for each shock variable in the primary Spec-2 block (PDSI drought + High_CDD +
# High_HDD, each with 2 lags), build the neighbor exposure — the mean over adjacent
# counties (Census 2023 adjacency, own county excluded); for binary shocks this is
# the share of neighbors in shock — and add the neighbor block to the headline specs.
#
# DESIGN --------------------------------------------------------------------
# Mirrors run_county_analysis.R Spec2_Base exactly (fips + Year FE, cluster = State,
# controls Household_Income_2023 + Uninsured_Rate, CO-2023 debt exclusion), with one
# deliberate deviation: baseline and spillover models are estimated on the SAME
# complete-case sample (union of both models' RHS) so coefficient movement is
# attributable to the neighbor terms, not sample change (econometrics.md same-sample
# lesson). Outcomes: PCPI_Real, Med_HH_Income_Real (secondary), Medical_Debt_Share,
# Civilian_Employed.
#
# EXPECTATION (pre-registered in track spec O1): own-shock coefficients stable
# (within ±25%) when the neighbor block enters; neighbor terms same-signed, smaller,
# likely insignificant under state clustering. A large own-coefficient shift is a
# debugging trigger first, finding second.
#
# INPUTS : Data/county_level_master.csv, Data/Geo/county_adjacency2023.txt
# OUTPUTS: Analysis/advisor_robustness/spillover_results.csv        (all coefficients)
#          Analysis/advisor_robustness/spillover_comparison.csv     (own-coef stability + joint tests)
#          Analysis/advisor_robustness/build_logs/run_spillover_analysis.log
# R 4.5.2.

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
})
source("Code/pipeline_utils.R")
source("Code/spillover_utils.R")
source("Code/cumulative_dose.R")   # lincom(): own + neighbor total-exposure combination

close_log <- open_build_log("advisor_robustness", "run_spillover_analysis")
on.exit(close_log(), add = TRUE)

# 1. Load ------------------------------------------------------------------
df <- read.csv("Data/county_level_master.csv")
cat("Master:", nrow(df), "rows,", dplyr::n_distinct(df$fips_code), "counties\n")

# Debt reporting-rule exclusion (same policy as run_county_analysis.R): CO 2023 only.
n_excl <- sum(toupper(trimws(df$State)) == "CO" & df$Year == 2023 &
                !is.na(df$Medical_Debt_Share))
df$Medical_Debt_Share[toupper(trimws(df$State)) == "CO" & df$Year == 2023] <- NA_real_
cat("CO-2023 debt exclusion: ", n_excl, "obs removed\n")
df$State <- as.factor(df$State)

# 2. Neighbor exposures ----------------------------------------------------
adj <- parse_county_adjacency("Data/Geo/county_adjacency2023.txt")
cat("Adjacency:", nrow(adj), "directed edges,", length(unique(adj$fips)), "counties\n")

shock_vars <- c("pdsi_val", "PDSI_Lag1", "PDSI_Lag2",
                "High_CDD", "High_CDD_Lag1", "High_CDD_Lag2",
                "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2")
stopifnot(all(shock_vars %in% names(df)))
for (v in shock_vars) {
  df <- build_neighbor_exposure(df, adj, v, out_var = paste0("Nbr_", v))
}
nbr_vars <- paste0("Nbr_", shock_vars)

# Coverage diagnostics: counties with no observed neighbor (islands etc.)
no_nbr <- df %>%
  filter(Year == 2015) %>%
  summarise(n = sum(Nbr_pdsi_val_n == 0), total = dplyr::n())
cat("Counties with zero observed neighbors (2015):", no_nbr$n, "of", no_nbr$total, "\n")
cat("  by state (islands, CT-2022 planning-region rename, AK/HI climate gaps expected):\n")
zero_2015 <- df %>% filter(Year == 2015, Nbr_pdsi_val_n == 0)
print(sort(table(as.character(zero_2015$State)), decreasing = TRUE))

controls <- intersect(c("Household_Income_2023", "Uninsured_Rate"), names(df))
outcomes <- c("PCPI_Real", "Med_HH_Income_Real", "Medical_Debt_Share", "Civilian_Employed")

# Collinearity diagnostic: PDSI is climate-division-level, so own and neighbor
# exposures are expected to be strongly correlated — individual own-vs-neighbor
# coefficients are then poorly separated and the interpretable objects are the
# joint neighbor Wald test and the own+neighbor total-exposure combination.
cat("\nOwn vs neighbor raw correlations (analysis window 2011-2023):\n")
dw <- df %>% filter(Year >= 2011, Year <= 2023)
for (v in shock_vars) {
  cat(sprintf("  %-15s r = %.3f\n", v,
              cor(dw[[v]], dw[[paste0("Nbr_", v)]], use = "complete.obs")))
}

# 3. Estimation ------------------------------------------------------------
tidy_model <- function(m, outcome, model, weighting) {
  ct <- as.data.frame(coeftable(m))
  data.frame(
    Outcome = outcome, Model = model, Weighting = weighting,
    Term = rownames(ct),
    Estimate = ct[, 1], SE = ct[, 2], t = ct[, 3], p = ct[, 4],
    N = nobs(m), Counties = m$fixef_sizes[["fips_code"]],
    stringsAsFactors = FALSE
  )
}

results <- list()
comparison <- list()

for (y in outcomes) {
  for (wt in c("Unweighted", "Population")) {
    if (wt == "Population" && !"Population" %in% names(df)) next

    vars_needed <- c(y, shock_vars, nbr_vars, controls, "fips_code", "Year", "State")
    if (wt == "Population") vars_needed <- c(vars_needed, "Population")
    d <- df[complete.cases(df[, vars_needed]), ]
    if (nrow(d) == 0) { cat("  [skip]", y, wt, "- empty sample\n"); next }

    f_base  <- as.formula(paste(y, "~", paste(c(shock_vars, controls), collapse = "+"),
                                "| fips_code + Year"))
    f_spill <- as.formula(paste(y, "~", paste(c(shock_vars, nbr_vars, controls), collapse = "+"),
                                "| fips_code + Year"))
    w <- if (wt == "Population") d$Population else NULL

    m_base  <- feols(f_base,  data = d, cluster = "State", weights = w)
    m_spill <- feols(f_spill, data = d, cluster = "State", weights = w)

    cat("\n=== ", y, " (", wt, ")  N =", nobs(m_spill),
        " counties =", m_spill$fixef_sizes[["fips_code"]],
        " states =", length(unique(d$State)), "===\n")
    print(summary(m_spill, n = 30))

    results[[paste(y, wt, "base")]]  <- tidy_model(m_base,  y, "Baseline",  wt)
    results[[paste(y, wt, "spill")]] <- tidy_model(m_spill, y, "Spillover", wt)

    # Joint Wald test on the full neighbor block (clustered vcov)
    wtest <- fixest::wald(m_spill, keep = "^Nbr_", print = FALSE)

    cb <- coeftable(m_base); cs <- coeftable(m_spill)
    for (v in shock_vars) {
      b0 <- cb[v, 1]; b1 <- cs[v, 1]
      nv <- paste0("Nbr_", v)
      tot <- lincom(m_spill, stats::setNames(c(1, 1), c(v, nv)))
      comparison[[paste(y, wt, v)]] <- data.frame(
        Outcome = y, Weighting = wt, Term = v,
        Beta_Baseline = b0, SE_Baseline = cb[v, 2],
        Beta_Spillover = b1, SE_Spillover = cs[v, 2],
        Pct_Change = 100 * (b1 - b0) / abs(b0),
        Nbr_Beta = cs[nv, 1], Nbr_SE = cs[nv, 2], Nbr_p = cs[nv, 4],
        Total_Beta = tot$estimate, Total_SE = tot$std.error, Total_p = tot$p.value,
        Joint_Nbr_Wald_p = wtest$p, N = nobs(m_spill),
        stringsAsFactors = FALSE
      )
    }
  }
}

# 4. Write outputs ----------------------------------------------------------
res_df  <- dplyr::bind_rows(results)
comp_df <- dplyr::bind_rows(comparison)
write.csv(res_df,  "Analysis/advisor_robustness/spillover_results.csv",    row.names = FALSE)
write.csv(comp_df, "Analysis/advisor_robustness/spillover_comparison.csv", row.names = FALSE)

cat("\n\n==================== OWN-COEFFICIENT STABILITY SUMMARY ====================\n")
key_terms <- c("pdsi_val", "PDSI_Lag1", "PDSI_Lag2", "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2")
print(comp_df %>%
        filter(Term %in% key_terms, Weighting == "Unweighted") %>%
        mutate(across(where(is.numeric), ~round(.x, 4))) %>%
        select(Outcome, Term, Beta_Baseline, Beta_Spillover, Nbr_Beta, Nbr_p,
               Total_Beta, Total_SE, Total_p, Joint_Nbr_Wald_p),
      row.names = FALSE)

cat("\nWrote Analysis/advisor_robustness/spillover_results.csv (",
    nrow(res_df), "rows ) and spillover_comparison.csv (", nrow(comp_df), "rows )\n")
