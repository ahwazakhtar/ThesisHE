# run_farm_nonfarm_distributed_lag.R — farm vs nonfarm decomposition of the
# window-stable drought->income distributed-lag result (advisor_feedback_20260807
# Task 1.3 / window_extension_note.md found PDSI_Lag1 stable at -$99 to -$132 across
# the 1990/2000/2011 window starts on TOTAL PCPI_Real; that decomposition was never
# split into farm vs nonfarm — the only farm/nonfarm split on record was for the
# fragile 2012 single-event 2x2, where ~85% of the raw ATT turned out to be farm-price
# mean reversion off the 2011 baseline (Code/diagnostics/farm_nonfarm_decomposition_
# drought2012.R). This script asks the same farm/nonfarm question of the CONTINUOUS
# distributed-lag spec instead of the single-event one.
#
# DESIGN: identical outcome construction to farm_nonfarm_decomposition_drought2012.R
# (Farm_PC_Real from BEA CAINC5N LineCode 81, deflated to 2023 USD via the county-
# master CPI series; NonFarm_PCPI_Real = PCPI_Real - Farm_PC_Real), but re-estimates
# the run_window_extension.R distributed-lag formula (PDSI + 2 lags, High_CDD/HDD +
# 2 lags each, county+Year FE, state-clustered) on each of the three outcomes
# (PCPI_Real / Farm_PC_Real / NonFarm_PCPI_Real) across windows.
#
# WINDOW CAVEAT: BEA CAINC5N farm earnings (Data/County_Agriculture/
# bea_cainc5n_earnings_raw.csv) only covers 2001-2024, so the 1990-2023 full-window
# check from the original window-extension note is NOT reproducible for the farm
# split. Windows here: 2011-2023 (anchor, matches the headline), 2001-2023 (furthest
# back the farm series allows), 2011-2024 (forward, BEA 2024 populated).
#
# RESULT CAVEATS (read the note before reusing these numbers — full detail in
# Analysis/advisor_robustness/farm_nonfarm_distributed_lag_note.md):
#   - The 2011-2024 farm/nonfarm rows are numerically IDENTICAL to 2011-2023 (not a
#     forward-robustness confirmation): `Population` is 100% NA for 2024 in
#     county_level_master.csv, so Farm_PC_Real (divides by Population) is NA for
#     every 2024 row and those rows drop via complete.cases.
#   - The 2001-2023 window is NOT a clean extension of window_extension_note.md's
#     2000-2023 window: dropping just the single year 2000 (independent of the farm
#     restriction — verified by re-running the full master with/without the
#     farm-fips restriction on identical years) swings total-income PDSI_Lag1 from
#     -99.2 (p=.0002) to -48.4 (p=.140). At 2001-2023 the nonfarm component
#     (-0.78, p=.98) looks like it vanishes, but that is confounded with this
#     year-2000 sensitivity, not a clean "more data, nonfarm fades" result.
#
# INPUTS : Data/county_level_master.csv; Data/County_Agriculture/bea_cainc5n_earnings_raw.csv;
#          Data/State_Policy_Data/us_cpi_annual.csv
# OUTPUTS: Analysis/advisor_robustness/farm_nonfarm_distributed_lag_results.csv
#          Analysis/advisor_robustness/farm_nonfarm_distributed_lag_note.md
#          Analysis/advisor_robustness/build_logs/run_farm_nonfarm_distributed_lag.log
# R 4.5.3 (current install; window_extension_results.csv was run under 4.5.2, since
# superseded — see conductor/knowledge/environment.md for the version note).

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(fixest)
})
source("Code/pipeline_utils.R")

close_log <- open_build_log("advisor_robustness", "run_farm_nonfarm_distributed_lag")
on.exit(close_log(), add = TRUE)

master <- read_csv("Data/county_level_master.csv", show_col_types = FALSE, progress = FALSE) %>%
  mutate(fips_code = pad_fips(fips_code), State = as.factor(State))

shock_vars <- c("pdsi_val", "PDSI_Lag1", "PDSI_Lag2",
                "High_CDD", "High_CDD_Lag1", "High_CDD_Lag2",
                "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2")
stopifnot(all(shock_vars %in% names(master)), "PCPI_Real" %in% names(master))

# --- BEA farm / total earnings (thousands, nominal), same construction as
# Code/diagnostics/farm_nonfarm_decomposition_drought2012.R -----------------
bea <- read_csv("Data/County_Agriculture/bea_cainc5n_earnings_raw.csv",
                col_types = cols(fips_code = col_character(),
                                 Year = col_integer(),
                                 value = col_character(),
                                 .default = col_guess())) %>%
  mutate(fips_code = pad_fips(fips_code),
         value = suppressWarnings(as.numeric(gsub(",", "", value)))) %>%
  select(fips_code, Year, series, value) %>%
  pivot_wider(names_from = series, values_from = value)

cpi <- read.csv("Data/State_Policy_Data/us_cpi_annual.csv")
cpi_2023 <- cpi$CPI_Value[cpi$Year == 2023]
cpi <- cpi %>% mutate(CPI_Factor = cpi_2023 / CPI_Value) %>% select(Year, CPI_Factor)

df <- master %>%
  inner_join(bea, by = c("fips_code", "Year")) %>%
  left_join(cpi, by = "Year") %>%
  mutate(Farm_PC_Real = farm_earnings * 1000 / Population * CPI_Factor,
         NonFarm_PCPI_Real = PCPI_Real - Farm_PC_Real)

cat(sprintf("Matched sample: %d counties, years %d-%d, %d county-years\n",
            n_distinct(df$fips_code), min(df$Year), max(df$Year), nrow(df)))

windows <- list(c(2011, 2023), c(2001, 2023), c(2011, 2024))
outcomes <- c("PCPI_Real", "Farm_PC_Real", "NonFarm_PCPI_Real")

f <- function(outcome) as.formula(paste(outcome, "~", paste(shock_vars, collapse = "+"),
                                         "| fips_code + Year"))

rows <- list()
for (w in windows) {
  lab <- paste0(w[1], "-", w[2])
  for (outcome in outcomes) {
    d <- df %>% filter(Year >= w[1], Year <= w[2])
    d <- d[complete.cases(d[, c(outcome, shock_vars, "fips_code", "Year", "State")]), ]
    m <- feols(f(outcome), data = d, cluster = "State")
    cat("\n=== Window", lab, " Outcome", outcome, " N =", nobs(m),
        " counties =", m$fixef_sizes[["fips_code"]],
        " years =", length(unique(d$Year)), "===\n")
    print(summary(m, n = 12))
    ct <- coeftable(m)
    key <- paste(lab, outcome)
    rows[[key]] <- data.frame(
      Window = lab, Outcome = outcome, Term = rownames(ct),
      Estimate = ct[, 1], SE = ct[, 2], p = ct[, 4],
      N = nobs(m), Counties = m$fixef_sizes[["fips_code"]],
      Years = length(unique(d$Year)),
      stringsAsFactors = FALSE
    )
  }
}

out <- dplyr::bind_rows(rows)
write_csv(out, "Analysis/advisor_robustness/farm_nonfarm_distributed_lag_results.csv")

cat("\n\n============ DROUGHT TERMS, FARM VS NONFARM (2011-2023 anchor) ============\n")
key_terms <- c("pdsi_val", "PDSI_Lag1", "PDSI_Lag2")
print(out %>%
        filter(Window == "2011-2023", Term %in% key_terms) %>%
        mutate(across(c(Estimate, SE, p), ~signif(.x, 3))) %>%
        select(Outcome, Term, Estimate, SE, p, N),
      row.names = FALSE)

cat("\n\n============ PDSI_Lag1 ACROSS WINDOWS, BY OUTCOME ============\n")
print(out %>%
        filter(Term == "PDSI_Lag1") %>%
        mutate(across(c(Estimate, SE, p), ~signif(.x, 3))) %>%
        select(Window, Outcome, Estimate, SE, p, N),
      row.names = FALSE)

cat("\nWrote Analysis/advisor_robustness/farm_nonfarm_distributed_lag_results.csv (", nrow(out), "rows )\n")
