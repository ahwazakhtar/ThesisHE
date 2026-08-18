# Climate-baseline horizon sensitivity (advisor follow-up, 2026-08-17).
#
# The shock definitions anchor to a 1990-2000 pre-study baseline: county z-scores
# (temp/precip mean+SD) and the national CDD/HDD p80 cutoffs
# (Code/process_county_climate.R:103-140). Drought (PDSI <= -4) is an absolute
# threshold and is baseline-INDEPENDENT, so the drought results are out of scope
# here. This diagnostic rebuilds Z_Temp/Z_Precip and High_CDD/High_HDD under
# longer baselines — 1990-2005 and 1990-2010 (both still pre-2011, so no
# look-ahead for the 2011-2023 county outcome window) — and re-runs the
# baseline-dependent headline specs:
#   1. Medicare morbidity (run_mechanism_medicare.R spec, exact replica):
#      {Mdcr_Std_Payment_PC, ER_Visits_per1000} ~ CDD/HDD block + MA_Rate +
#      Dual_Pct + log_benes | fips + Year, cluster State.
#   2. County ledger/economy (run_county_analysis.R primary unweighted spec):
#      {Medical_Debt_Share, Civilian_Employed} ~ spec1 (PDSI block + Z blocks)
#      and spec2 (PDSI block + High_CDD/HDD blocks) + Household_Income_2023 +
#      Uninsured_Rate | fips + Year, cluster State; CO-2023 debt exclusion.
# The 1990-2000 variant is a validation replica: its recomputed flags are
# compared 1:1 against the county master's shipped columns before any model runs.
#
# Output: Analysis/advisor_robustness/baseline_horizon_sensitivity.csv

suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(fixest) })
pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")

clim <- readRDS("Data/intermediate_climate.rds") %>%
  mutate(fips_code = pad_fips(fips_code)) %>%
  select(fips_code, Year, temp_val, precip_val, cdd_val, hdd_val,
         pdsi_val, PDSI_Lag1, PDSI_Lag2) %>%
  distinct(fips_code, Year, .keep_all = TRUE)

build_shocks <- function(baseline_end) {
  bs <- clim %>%
    filter(Year >= 1990, Year <= baseline_end) %>%
    group_by(fips_code) %>%
    summarize(t_m = mean(temp_val, na.rm = TRUE), t_s = sd(temp_val, na.rm = TRUE),
              p_m = mean(precip_val, na.rm = TRUE), p_s = sd(precip_val, na.rm = TRUE),
              .groups = "drop")
  base_dd <- clim %>% filter(Year >= 1990, Year <= baseline_end)
  cdd_p80 <- quantile(base_dd$cdd_val, 0.80, na.rm = TRUE)
  hdd_p80 <- quantile(base_dd$hdd_val, 0.80, na.rm = TRUE)
  cat(sprintf("  [1990-%d] CDD p80 = %.1f | HDD p80 = %.1f\n", baseline_end, cdd_p80, hdd_p80))
  clim %>%
    left_join(bs, by = "fips_code") %>%
    group_by(fips_code) %>% arrange(Year) %>%
    mutate(Z_Temp = (temp_val - t_m) / t_s,
           Z_Precip = (precip_val - p_m) / p_s,
           High_CDD = as.integer(!is.na(cdd_val) & cdd_val >= cdd_p80),
           High_HDD = as.integer(!is.na(hdd_val) & hdd_val >= hdd_p80),
           Z_Temp_Lag1 = lag(Z_Temp, 1), Z_Temp_Lag2 = lag(Z_Temp, 2),
           Z_Precip_Lag1 = lag(Z_Precip, 1), Z_Precip_Lag2 = lag(Z_Precip, 2),
           High_CDD_Lag1 = lag(High_CDD, 1), High_CDD_Lag2 = lag(High_CDD, 2),
           High_HDD_Lag1 = lag(High_HDD, 1), High_HDD_Lag2 = lag(High_HDD, 2)) %>%
    ungroup() %>%
    select(fips_code, Year, pdsi_val, PDSI_Lag1, PDSI_Lag2, starts_with("Z_"),
           starts_with("High_"))
}

# --- outcome data (climate columns dropped; shocks come from the variant) ---
master <- read.csv("Data/county_level_master.csv") %>%
  mutate(fips_code = pad_fips(fips_code)) %>%
  filter(Year >= 2011, Year <= 2023) %>%
  distinct(fips_code, Year, .keep_all = TRUE)
# CO-2023 debt reporting exclusion (per CLAUDE.md / run_county_analysis policy)
excl <- toupper(trimws(as.character(master$State))) == "CO" & master$Year == 2023
master$Medical_Debt_Share[excl] <- NA_real_
outc <- master %>%
  select(fips_code, Year, State, Medical_Debt_Share, Civilian_Employed,
         Household_Income_2023, Uninsured_Rate)

med <- readRDS("Data/intermediate_medicare_spending.rds") %>%
  mutate(fips_code = pad_fips(fips_code))

run_variant <- function(baseline_end) {
  sh <- build_shocks(baseline_end)
  d <- outc %>% inner_join(sh, by = c("fips_code", "Year"))
  dm <- d %>% left_join(med, by = c("fips_code", "Year")) %>%
    mutate(log_benes = ifelse(!is.na(Benes_Total) & Benes_Total > 0, log(Benes_Total), NA_real_))

  rows <- list()
  grab <- function(m, keep, outcome, spec) {
    if (is.null(m)) return(NULL)
    ct <- as.data.frame(coeftable(m)); ct$term <- rownames(ct)
    ct <- ct[ct$term %in% keep, ]
    if (!nrow(ct)) return(NULL)
    data.frame(Baseline = paste0("1990-", baseline_end), Outcome = outcome, Spec = spec,
               Term = ct$term, Estimate = ct[, 1], Std_Error = ct[, 2], p_value = ct[, 4],
               N = nobs(m), row.names = NULL)
  }
  sf <- function(f, data) tryCatch(feols(f, data = data, cluster = "State"),
                                   error = function(e) NULL)

  # 1. Medicare spec (exact mechanism replica)
  med_controls <- intersect(c("MA_Rate", "Dual_Pct", "log_benes"), names(dm))
  for (oc in c("Mdcr_Std_Payment_PC", "ER_Visits_per1000")) {
    for (blk in list(CDD = c("High_CDD", "High_CDD_Lag1", "High_CDD_Lag2"),
                     HDD = c("High_HDD", "High_HDD_Lag1", "High_HDD_Lag2"))) {
      f <- as.formula(paste(oc, "~", paste(c(blk, med_controls), collapse = "+"),
                            "| fips_code + Year"))
      rows[[length(rows) + 1]] <- grab(sf(f, dm), blk, oc, "medicare")
    }
  }

  # 2. County primary spec (run_county_analysis unweighted replica)
  pdsi_blk <- c("pdsi_val", "PDSI_Lag1", "PDSI_Lag2")
  s1 <- c(pdsi_blk, "Z_Temp", "Z_Temp_Lag1", "Z_Temp_Lag2",
          "Z_Precip", "Z_Precip_Lag1", "Z_Precip_Lag2")
  s2 <- c(pdsi_blk, "High_CDD", "High_CDD_Lag1", "High_CDD_Lag2",
          "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2")
  cty_controls <- c("Household_Income_2023", "Uninsured_Rate")
  for (oc in c("Medical_Debt_Share", "Civilian_Employed")) {
    for (sp in list(spec1 = s1, spec2 = s2)) {
      f <- as.formula(paste(oc, "~", paste(c(sp, cty_controls), collapse = "+"),
                            "| fips_code + Year"))
      keep <- setdiff(sp, pdsi_blk)  # report the baseline-dependent terms
      rows[[length(rows) + 1]] <- grab(sf(f, d %>% filter(!is.na(.data[[oc]]))),
                                       keep, oc, ifelse(identical(sp, s1), "county_spec1", "county_spec2"))
    }
  }
  bind_rows(rows)
}

# --- validation: 1990-2000 recomputed flags must match the shipped master ----
cat("Validation: recomputed 1990-2000 flags vs county master columns\n")
v <- build_shocks(2000)
chk <- master %>%
  select(fips_code, Year, m_cdd = High_CDD, m_hdd = High_HDD, m_zt = Z_Temp) %>%
  inner_join(v %>% select(fips_code, Year, High_CDD, High_HDD, Z_Temp),
             by = c("fips_code", "Year"))
cat(sprintf("  High_CDD mismatches: %d / %d | High_HDD: %d | max |dZ_Temp|: %.6f\n",
            sum(chk$m_cdd != chk$High_CDD, na.rm = TRUE), nrow(chk),
            sum(chk$m_hdd != chk$High_HDD, na.rm = TRUE),
            max(abs(chk$m_zt - chk$Z_Temp), na.rm = TRUE)))

# --- shock-set turnover across baselines ------------------------------------
s00 <- build_shocks(2000); s05 <- build_shocks(2005); s10 <- build_shocks(2010)
tv <- s00 %>% select(fips_code, Year, cdd0 = High_CDD, hdd0 = High_HDD) %>%
  inner_join(s05 %>% select(fips_code, Year, cdd5 = High_CDD, hdd5 = High_HDD),
             by = c("fips_code", "Year")) %>%
  inner_join(s10 %>% select(fips_code, Year, cdd10 = High_CDD, hdd10 = High_HDD),
             by = c("fips_code", "Year")) %>%
  filter(Year >= 2011, Year <= 2023)
cat(sprintf("\nShock-flag shares 2011-23: CDD %.3f / %.3f / %.3f | HDD %.3f / %.3f / %.3f (1990-2000/05/10)\n",
            mean(tv$cdd0), mean(tv$cdd5), mean(tv$cdd10),
            mean(tv$hdd0), mean(tv$hdd5), mean(tv$hdd10)))

res <- bind_rows(run_variant(2000), run_variant(2005), run_variant(2010))

# ============================================================================
# Part 2 — STATE pipeline (Row 4 headline: cold -> debt +1.35pp at lag 1).
# The state z-shocks (Z beyond +/-1.5) and national CDD/HDD p80 cutoffs anchor
# to 1990-2000 in Code/analysis_pre_processing.R:55-91. Rebuild them from the
# analysis-ready dataset's raw temp_mean/cdd_sum/hdd_sum under each baseline,
# keep every other column as shipped (drought blocks, AQI, controls), and
# re-run the exact run_analysis.R formula for Medical_Debt_Share.
# ============================================================================
st <- read.csv("Data/analysis_ready_dataset.csv", stringsAsFactors = FALSE)

state_variant <- function(baseline_end) {
  d <- st %>%
    group_by(State) %>%
    mutate(t_m = mean(temp_mean[Year >= 1990 & Year <= baseline_end], na.rm = TRUE),
           t_s = sd(temp_mean[Year >= 1990 & Year <= baseline_end], na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(temp_z_v = if_else(!is.na(t_s) & t_s > 0, (temp_mean - t_m) / t_s, NA_real_),
           is_heat_shock = as.integer(!is.na(temp_z_v) & temp_z_v > 1.5),
           is_cold_shock = as.integer(!is.na(temp_z_v) & temp_z_v < -1.5))
  bdd <- d %>% filter(Year >= 1990, Year <= baseline_end)
  cdd_p80 <- quantile(bdd$cdd_sum, 0.80, na.rm = TRUE)
  hdd_p80 <- quantile(bdd$hdd_sum, 0.80, na.rm = TRUE)
  d <- d %>%
    mutate(is_high_cdd = as.integer(!is.na(cdd_sum) & cdd_sum >= cdd_p80),
           is_high_hdd = as.integer(!is.na(hdd_sum) & hdd_sum >= hdd_p80)) %>%
    arrange(State, Year) %>% group_by(State) %>%
    mutate(across(c(is_heat_shock, is_cold_shock, is_high_cdd, is_high_hdd),
                  list(lag1 = ~lag(.x, 1), lag2 = ~lag(.x, 2)),
                  .names = "{.col}_{.fn}")) %>%
    ungroup()

  climate_vars <- c(
    "is_extreme_drought", "is_extreme_drought_lag1", "is_extreme_drought_lag2",
    "is_severe_drought", "is_severe_drought_lag1", "is_severe_drought_lag2",
    "is_extreme_drought_peak", "is_extreme_drought_peak_lag1", "is_extreme_drought_peak_lag2",
    "is_heat_shock", "is_heat_shock_lag1", "is_heat_shock_lag2",
    "is_cold_shock", "is_cold_shock_lag1", "is_cold_shock_lag2",
    "is_high_cdd", "is_high_cdd_lag1", "is_high_cdd_lag2",
    "is_high_hdd", "is_high_hdd_lag1", "is_high_hdd_lag2")
  aqi_base <- c("AQI_Median_Wtd", "AQI_Max_State",
                "Pct_PM25_State", "Pct_PM10_State", "Pct_Ozone_State",
                "Pct_CO_State", "Pct_NO2_State", "Pct_Unhealthy_State")
  aqi_vars <- unlist(lapply(intersect(aqi_base, names(d)), function(v)
    c(v, paste0(v, "_lag1"), paste0(v, "_lag2"))))
  aqi_vars <- aqi_vars[aqi_vars %in% names(d)]
  rhs <- paste(c(climate_vars, aqi_vars,
                 "Unemployment_Rate", "Personal_Income_Per_Capita_Real"), collapse = " + ")
  f <- as.formula(paste("Medical_Debt_Share ~", rhs, "| State + Year"))
  m <- tryCatch(feols(f, data = d[!is.na(d$Medical_Debt_Share), ], cluster = ~State),
                error = function(e) NULL)
  if (is.null(m)) return(NULL)
  ct <- as.data.frame(coeftable(m)); ct$term <- rownames(ct)
  keep <- c("is_cold_shock", "is_cold_shock_lag1", "is_cold_shock_lag2",
            "is_heat_shock", "is_heat_shock_lag1",
            "is_high_hdd_lag1", "is_high_cdd_lag1")
  ct <- ct[ct$term %in% keep, ]
  data.frame(Baseline = paste0("1990-", baseline_end), Outcome = "Medical_Debt_Share",
             Spec = "state_primary", Term = ct$term,
             Estimate = ct[, 1], Std_Error = ct[, 2], p_value = ct[, 4],
             N = nobs(m), row.names = NULL)
}

res_state <- bind_rows(lapply(c(2000L, 2005L, 2010L), state_variant))
cat("\nSTATE cold->debt across baselines (validation row: 1990-2000 should show is_cold_shock_lag1 ~ 0.0135, p~0.012):\n")
print(as.data.frame(res_state %>%
  filter(Term %in% c("is_cold_shock_lag1", "is_cold_shock", "is_cold_shock_lag2")) %>%
  mutate(across(c(Estimate, Std_Error), ~signif(.x, 4)), p_value = round(p_value, 4)) %>%
  arrange(Term, Baseline)))

res <- bind_rows(res, res_state)
dir.create("Analysis/advisor_robustness", showWarnings = FALSE, recursive = TRUE)
write.csv(res, "Analysis/advisor_robustness/baseline_horizon_sensitivity.csv", row.names = FALSE)

cat("\nHeadline terms across baselines:\n")
show <- res %>%
  filter((Outcome == "Mdcr_Std_Payment_PC" & Term %in% c("High_CDD", "High_CDD_Lag1")) |
         (Outcome == "ER_Visits_per1000" & Term %in% c("High_CDD", "High_CDD_Lag1")) |
         (Outcome == "Medical_Debt_Share" & Term %in% c("High_HDD_Lag1", "Z_Temp_Lag1")) |
         (Outcome == "Civilian_Employed" & Term %in% c("High_HDD_Lag1", "High_HDD_Lag2"))) %>%
  mutate(across(c(Estimate, Std_Error), ~signif(.x, 4)), p_value = round(p_value, 4)) %>%
  arrange(Outcome, Spec, Term, Baseline)
print(as.data.frame(show))
cat("\nWrote Analysis/advisor_robustness/baseline_horizon_sensitivity.csv\n")
