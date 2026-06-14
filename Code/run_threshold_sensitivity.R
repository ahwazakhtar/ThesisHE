# ---------------------------------------------------------------------------
# run_threshold_sensitivity.R  (Persistence Extensions — Phase 5)
#
# Robustness sweep of the High_CDD / High_HDD top-quintile cut-points. The
# primary pipelines flag a county/state-year as High_CDD/High_HDD when its CDD/HDD
# exceeds the national p80 of the 1990-2000 baseline. This script re-derives the
# flags at p70, p80 (primary), and p90 and re-estimates:
#   - the primary STATE spec   (run_analysis.R climate block), and
#   - the primary county SPEC 2 (run_county_analysis.R: PDSI + High_CDD/HDD),
# extracting the High_CDD / High_HDD coefficients (contemporaneous + lags) at each
# cut-point so we can see whether the headline cold/heat-burden findings survive a
# stricter (p90) definition.
#
# Baselines are self-contained: the STATE file spans 1990-2025; the county
# 1990-2000 baseline comes from Data/intermediate_climate.rds (the master is
# 2011-2023 only). is_cold_shock_lag1 (z-temperature based, NOT a CDD/HDD cut) is
# reported for the state to confirm it is invariant to these cut-points.
#
# Output: Analysis/threshold_sensitivity_coefs.csv ; plots in
#         Analysis/plots/threshold_sensitivity/
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr); library(readr); library(fixest); library(ggplot2)
})

plot_dir <- "Analysis/plots/threshold_sensitivity"
dir.create("Analysis", showWarnings = FALSE)
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

cutoffs <- c(p70 = 0.70, p80 = 0.80, p90 = 0.90)

# Readable relabelling of the swept CDD/HDD term names.
relabel <- c(hc = "High_CDD", hc_l1 = "High_CDD_Lag1", hc_l2 = "High_CDD_Lag2",
             hh = "High_HDD", hh_l1 = "High_HDD_Lag1", hh_l2 = "High_HDD_Lag2",
             High_CDD = "High_CDD", High_CDD_Lag1 = "High_CDD_Lag1", High_CDD_Lag2 = "High_CDD_Lag2",
             High_HDD = "High_HDD", High_HDD_Lag1 = "High_HDD_Lag1", High_HDD_Lag2 = "High_HDD_Lag2",
             is_cold_shock_lag1 = "is_cold_shock_lag1")

get_cell <- function(ct, term, col) { v <- ct[ct$Term == term, col]; if (length(v) == 0) NA_real_ else as.numeric(v) }
rows <- list()

# ===========================================================================
# STATE
# ===========================================================================
cat("=== STATE threshold sweep ===\n")
s <- read_csv("Data/analysis_ready_dataset.csv", show_col_types = FALSE, progress = FALSE)
base_s <- s %>% filter(Year >= 1990, Year <= 2000)

state_outcomes <- intersect(c("Emp_Contrib_Single_Real", "Medical_Debt_Share",
  "Medical_Debt_Median_Real", "Total_Per_Capita_Health_Exp_Real",
  "Medicaid_Per_Enrollee_Health_Exp_Real", "Medicare_Per_Enrollee_Health_Exp_Real"), names(s))
# Primary climate vars OTHER than CDD/HDD (kept fixed across sweeps).
state_other <- intersect(c(
  "is_extreme_drought","is_extreme_drought_lag1","is_extreme_drought_lag2",
  "is_severe_drought","is_severe_drought_lag1","is_severe_drought_lag2",
  "is_extreme_drought_peak","is_extreme_drought_peak_lag1","is_extreme_drought_peak_lag2",
  "is_heat_shock","is_heat_shock_lag1","is_heat_shock_lag2",
  "is_cold_shock","is_cold_shock_lag1","is_cold_shock_lag2"), names(s))
state_controls <- intersect(c("Unemployment_Rate","Personal_Income_Per_Capita_Real"), names(s))
cdd_vars <- c("hc","hc_l1","hc_l2","hh","hh_l1","hh_l2")

for (cn in names(cutoffs)) {
  q <- cutoffs[[cn]]
  cdd_cut <- quantile(base_s$cdd_sum, q, na.rm = TRUE)
  hdd_cut <- quantile(base_s$hdd_sum, q, na.rm = TRUE)
  sc <- s %>%
    mutate(hc = as.integer(!is.na(cdd_sum) & cdd_sum >= cdd_cut),
           hh = as.integer(!is.na(hdd_sum) & hdd_sum >= hdd_cut)) %>%
    arrange(State, Year) %>% group_by(State) %>%
    mutate(hc_l1 = lag(hc,1), hc_l2 = lag(hc,2), hh_l1 = lag(hh,1), hh_l2 = lag(hh,2)) %>%
    ungroup()
  rhs <- paste(c(state_other, cdd_vars, state_controls), collapse = " + ")
  for (o in state_outcomes) {
    m <- tryCatch(feols(as.formula(paste(o, "~", rhs, "| State + Year")),
                        data = sc, cluster = ~State), error = function(e) NULL)
    if (is.null(m)) next
    ct <- as.data.frame(coeftable(m)); ct$Term <- rownames(ct)
    for (trm in c(cdd_vars, "is_cold_shock_lag1")) {
      if (!trm %in% ct$Term) next
      rows[[length(rows)+1]] <- data.frame(level = "State", cutoff = cn, outcome = o,
        term = relabel[[trm]], estimate = get_cell(ct, trm, "Estimate"),
        std.error = get_cell(ct, trm, "Std. Error"), p.value = get_cell(ct, trm, "Pr(>|t|)"),
        N = nobs(m), stringsAsFactors = FALSE)
    }
  }
}

# ===========================================================================
# COUNTY (Spec 2)
# ===========================================================================
cat("=== COUNTY Spec 2 threshold sweep ===\n")
ic <- readRDS("Data/intermediate_climate.rds")
base_c <- ic %>% filter(Year >= 1990, Year <= 2000)
m_df <- read_csv("Data/county_level_master.csv", show_col_types = FALSE, progress = FALSE)
if (all(c("Hosp_BadDebt_Total_Real","Population") %in% names(m_df)))
  m_df$Hosp_BadDebt_PerCapita <- m_df$Hosp_BadDebt_Total_Real / m_df$Population

# Debt reporting exclusion (CO 2023), matching run_county_analysis.R
debt_outcomes <- intersect(c("Medical_Debt_Share","Medical_Debt_Median_2023"), names(m_df))
if (length(debt_outcomes) > 0 && "State" %in% names(m_df)) {
  mask <- toupper(trimws(as.character(m_df$State))) == "CO" & as.integer(m_df$Year) == 2023
  for (v in debt_outcomes) m_df[[v]] <- ifelse(mask, NA_real_, as.numeric(m_df[[v]]))
}

county_outcomes <- intersect(c("Medical_Debt_Share","Medical_Debt_Median_2023",
  "Benchmark_Silver_Real","Hosp_BadDebt_PerCapita","PCPI_Real",
  "Med_HH_Income_Real","Civilian_Employed"), names(m_df))
drought_primary <- intersect(c("pdsi_val","PDSI_Lag1","PDSI_Lag2"), names(m_df))
county_controls <- intersect(c("Household_Income_2023","Uninsured_Rate"), names(m_df))

for (cn in names(cutoffs)) {
  q <- cutoffs[[cn]]
  cdd_cut <- quantile(base_c$cdd_val, q, na.rm = TRUE)
  hdd_cut <- quantile(base_c$hdd_val, q, na.rm = TRUE)
  mc <- m_df %>%
    mutate(hc = as.integer(!is.na(cdd_val) & cdd_val >= cdd_cut),
           hh = as.integer(!is.na(hdd_val) & hdd_val >= hdd_cut)) %>%
    arrange(fips_code, Year) %>% group_by(fips_code) %>%
    mutate(hc_l1 = lag(hc,1), hc_l2 = lag(hc,2), hh_l1 = lag(hh,1), hh_l2 = lag(hh,2)) %>%
    ungroup()
  rhs <- paste(c(drought_primary, cdd_vars, county_controls), collapse = " + ")
  for (o in county_outcomes) {
    m <- tryCatch(feols(as.formula(paste(o, "~", rhs, "| fips_code + Year")),
                        data = mc, cluster = ~State), error = function(e) NULL)
    if (is.null(m)) next
    ct <- as.data.frame(coeftable(m)); ct$Term <- rownames(ct)
    for (trm in cdd_vars) {
      if (!trm %in% ct$Term) next
      rows[[length(rows)+1]] <- data.frame(level = "County_Spec2", cutoff = cn, outcome = o,
        term = relabel[[trm]], estimate = get_cell(ct, trm, "Estimate"),
        std.error = get_cell(ct, trm, "Std. Error"), p.value = get_cell(ct, trm, "Pr(>|t|)"),
        N = nobs(m), stringsAsFactors = FALSE)
    }
  }
}

# ===========================================================================
# Export + plots
# ===========================================================================
res <- bind_rows(rows)
write_csv(res, "Analysis/threshold_sensitivity_coefs.csv")
cat(sprintf("\nSaved %d coefficient rows to Analysis/threshold_sensitivity_coefs.csv\n", nrow(res)))

cat("\n=== County Spec 2: High_HDD_Lag1 across cut-points (the cold-burden lag) ===\n")
print(as.data.frame(res %>% filter(level=="County_Spec2", term=="High_HDD_Lag1") %>%
        mutate(across(c(estimate,std.error,p.value), ~signif(.x,3))) %>%
        select(outcome, cutoff, estimate, p.value)), row.names = FALSE)

cat("\n=== State: High_HDD_Lag1 across cut-points ===\n")
print(as.data.frame(res %>% filter(level=="State", term=="High_HDD_Lag1") %>%
        mutate(across(c(estimate,std.error,p.value), ~signif(.x,3))) %>%
        select(outcome, cutoff, estimate, p.value)), row.names = FALSE)

# Plot: coefficient across cut-points, faceted, for the cold/heat burden lags
pd <- res %>% filter(term %in% c("High_HDD","High_HDD_Lag1","High_CDD","High_CDD_Lag1")) %>%
  mutate(cutoff = factor(cutoff, levels = c("p70","p80","p90")),
         ci_low = estimate - 1.96*std.error, ci_high = estimate + 1.96*std.error)
for (lv in unique(pd$level)) {
  sub <- pd %>% filter(level == lv)
  if (nrow(sub) == 0) next
  p <- ggplot(sub, aes(x = cutoff, y = estimate, group = term, color = term)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                    position = position_dodge(width = 0.4), size = 0.4) +
    facet_wrap(~ outcome, scales = "free_y") +
    labs(title = paste("Threshold sensitivity of High_CDD/HDD —", lv),
         x = "Top-quintile cut-point", y = "Coefficient", color = NULL) +
    theme_minimal(base_size = 10) +
    theme(plot.background = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA))
  ggsave(file.path(plot_dir, paste0("threshold_", lv, ".png")), p,
         width = 11, height = 7, dpi = 150, bg = "white")
}

cat("\n=== Threshold Sensitivity Complete ===\n")
