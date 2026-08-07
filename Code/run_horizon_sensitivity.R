# run_horizon_sensitivity.R — event-study horizon-choice robustness
# (advisor_feedback_20260807, Task 1.4; spec O3b).
#
# PURPOSE -------------------------------------------------------------------
# Advisor: does the choice of event-study horizons change the headline results?
# The event study (run_event_study.R) hard-codes h = -2..+3. Two designs, because the
# question binds differently in the two approaches:
#   (a) DL (single dynamic distributed-lag regression): the lag depth K IS a joint
#       modeling choice — adding lags can move the h=0..2 coefficients. We re-estimate
#       the DL with K in {2,3,4,5} (leads fixed at 2, ref h=-1) and track h=0..2.
#   (b) LP (Jorda): each horizon is a SEPARATE regression, so h=0..2 estimates are
#       invariant to which horizons are run BY CONSTRUCTION (stated, not tested).
#       Extending to h=4,5 documents the impulse tail and the per-horizon estimation
#       sample (each added horizon loses one panel year at the edge).
#
# Headline pairs (unweighted, state clustering, controls as in run_event_study.R):
#   Is_Extreme_Drought -> Medical_Debt_Share  (debt scar at h=2 headline)
#   Is_Extreme_Drought -> PCPI_Real
#   High_HDD           -> Civilian_Employed   (cold employment headline)
#
# EXPECTATION (spec O3b): DL h=0..2 coefficients stable across K; LP long-horizon
# estimates noisy/wide. Claim defended: horizon choice does not drive the verdicts.
#
# INPUTS : Data/county_level_master.csv
# OUTPUTS: Analysis/advisor_robustness/horizon_sensitivity.csv
#          Analysis/plots/advisor_robustness/horizon_sensitivity.png
#          Analysis/advisor_robustness/build_logs/run_horizon_sensitivity.log
# R 4.5.2.

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(fixest)
})
source("Code/pipeline_utils.R")

close_log <- open_build_log("advisor_robustness", "run_horizon_sensitivity")
on.exit(close_log(), add = TRUE)

# 1. Load + mirror run_event_study.R prep ----------------------------------
df <- read.csv("Data/county_level_master.csv")
df$fips_code <- pad_fips(df$fips_code)
df$Medical_Debt_Share[toupper(trimws(df$State)) == "CO" & df$Year == 2023] <- NA_real_
cat("Applied debt exclusion: CO 2023\n")
df$State <- as.factor(df$State)

controls <- intersect(c("Household_Income_2023", "Uninsured_Rate"), names(df))
pairs <- list(
  list(s = "Is_Extreme_Drought", o = "Medical_Debt_Share"),
  list(s = "Is_Extreme_Drought", o = "PCPI_Real"),
  list(s = "High_HDD",           o = "Civilian_Employed")
)
shocks   <- unique(vapply(pairs, `[[`, "", "s"))
outcomes <- unique(vapply(pairs, `[[`, "", "o"))
K_grid   <- 2:5
H_LP     <- 5L

# Contiguity fill (as in run_event_study.R), then leads/lags to depth 5
df <- df %>%
  arrange(fips_code, Year) %>%
  group_by(fips_code) %>%
  complete(Year = min(Year):max(Year)) %>%
  ungroup() %>%
  arrange(fips_code, Year)

for (s in shocks) {
  df <- df %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      !!paste0(s, "_Lead2") := dplyr::lead(.data[[s]], 2),
      !!paste0(s, "_LagES1") := dplyr::lag(.data[[s]], 1),
      !!paste0(s, "_LagES2") := dplyr::lag(.data[[s]], 2),
      !!paste0(s, "_LagES3") := dplyr::lag(.data[[s]], 3),
      !!paste0(s, "_LagES4") := dplyr::lag(.data[[s]], 4),
      !!paste0(s, "_LagES5") := dplyr::lag(.data[[s]], 5)
    ) %>%
    ungroup()
}
for (o in outcomes) {
  for (h in 0:H_LP) {
    df <- df %>%
      group_by(fips_code) %>%
      arrange(Year) %>%
      mutate(!!paste0(o, "_fwd", h) := dplyr::lead(.data[[o]], h)) %>%
      ungroup()
  }
}

rows <- list()

# 2. (a) DL lag-depth sensitivity ------------------------------------------
cat("\n=== DL: lag depth K in {", paste(K_grid, collapse = ","), "} ===\n")
for (p in pairs) {
  s <- p$s; o <- p$o
  for (K in K_grid) {
    lag_terms <- paste0(s, "_LagES", seq_len(K))
    rhs <- c(paste0(s, "_Lead2"), s, lag_terms, controls)
    f <- as.formula(paste(o, "~", paste(rhs, collapse = "+"), "| fips_code + Year"))
    m <- feols(f, data = df, cluster = "State", notes = FALSE)
    ct <- coeftable(m)
    hmap <- c(setNames(s, "0"), setNames(lag_terms, as.character(seq_len(K))))
    for (h_str in names(hmap)) {
      tm <- hmap[[h_str]]
      rows[[paste("DL", s, o, K, h_str)]] <- data.frame(
        Approach = "DL", Shock = s, Outcome = o, K_or_Hmax = K,
        Horizon = as.integer(h_str),
        Estimate = ct[tm, 1], SE = ct[tm, 2], p = ct[tm, 4], N = nobs(m),
        stringsAsFactors = FALSE
      )
    }
    cat(sprintf("  %s -> %s | K=%d | N=%d | h0=%.4g h1=%.4g h2=%.4g\n",
                s, o, K, nobs(m), ct[s, 1], ct[hmap[["1"]], 1], ct[hmap[["2"]], 1]))
  }
}

# 3. (b) LP extended tail ----------------------------------------------------
cat("\n=== LP: horizons 0..", H_LP, " (each its own regression; sample shrinks) ===\n")
for (p in pairs) {
  s <- p$s; o <- p$o
  for (h in 0:H_LP) {
    dep <- paste0(o, "_fwd", h)
    f <- as.formula(paste(dep, "~", paste(c(s, controls), collapse = "+"),
                          "| fips_code + Year"))
    m <- feols(f, data = df, cluster = "State", notes = FALSE)
    ct <- coeftable(m)
    rows[[paste("LP", s, o, h)]] <- data.frame(
      Approach = "LP", Shock = s, Outcome = o, K_or_Hmax = H_LP,
      Horizon = h,
      Estimate = ct[s, 1], SE = ct[s, 2], p = ct[s, 4], N = nobs(m),
      stringsAsFactors = FALSE
    )
    cat(sprintf("  %s -> %s | h=%d | N=%d | beta=%.4g (p=%.3g)\n",
                s, o, h, nobs(m), ct[s, 1], ct[s, 4]))
  }
}

out <- dplyr::bind_rows(rows)
write.csv(out, "Analysis/advisor_robustness/horizon_sensitivity.csv", row.names = FALSE)

# 4. Stability summary -------------------------------------------------------
cat("\n\n========== DL h=0..2 STABILITY ACROSS LAG DEPTH K (the binding choice) ==========\n")
# Deviations are scaled by the K=3 clustered SE (raw % is meaningless for the
# near-zero coefficients); K=3 is the shipped h_max of run_event_study.R.
se3 <- out %>%
  filter(Approach == "DL", Horizon <= 2, K_or_Hmax == 3) %>%
  select(Shock, Outcome, Horizon, SE_K3 = SE, p_K3 = p)
stab <- out %>%
  filter(Approach == "DL", Horizon <= 2) %>%
  select(Shock, Outcome, Horizon, K_or_Hmax, Estimate) %>%
  pivot_wider(names_from = K_or_Hmax, values_from = Estimate, names_prefix = "K") %>%
  left_join(se3, by = c("Shock", "Outcome", "Horizon")) %>%
  mutate(
    Dev_K2_in_SE = abs(K2 - K3) / SE_K3,   # shortening below shipped depth
    Dev_K4_in_SE = abs(K4 - K3) / SE_K3,   # extending beyond shipped depth
    Dev_K5_in_SE = abs(K5 - K3) / SE_K3
  ) %>%
  mutate(across(where(is.numeric), ~signif(.x, 4)))
print(as.data.frame(stab), row.names = FALSE)

cat("\nWrote Analysis/advisor_robustness/horizon_sensitivity.csv (", nrow(out), "rows )\n")
