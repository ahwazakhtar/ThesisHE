# Phase 2 (Task 2c): morbidity / healthcare-utilization channel regressions.
# Track: mechanism_channels_20260625.  Run: Rscript Code/run_mechanism_medicare.R
#
# QUESTION: do climate/pollution shocks raise DIRECTLY-MEASURED medical costs and
# utilization (a channel with no farm-income intermediary)? If so, and if the effect
# SURVIVES in low-agriculture counties, that is a non-agricultural morbidity channel
# reproducing Deryugina et al. (2019) / IJPH (2025) in-panel.
#
# DESIGN: Y_med ~ Shock(+lag1+lag2) + controls | County + Year, cluster State, for
#   outcomes {Mdcr_Std_Payment_PC (preferred: price-standardized -> utilization intensity),
#   ER_Visits_per1000, IP_Stays_per1000, IP_Days_per1000, Readmission_Rate}.
#   Shocks: Drought / HDD (cold) / CDD (heat), and AQI (High_AQI_Max = Max_AQI>100, the
#   pollution arm) with constructed lags. Controls: MA_Rate, Dual_Pct, log(beneficiaries).
#   Separability: re-estimate in the BOTTOM ag-dependence tercile.
#
# CAVEATS (logged): (1) Medicare = 65+/disabled population -- the temperature/pollution-
#   sensitive group, consistent with the canonical literature (a feature, not a bug).
#   (2) The Medicare PUF starts 2014, so this channel runs on 2014-2023 only.
#
# OUTPUT: Analysis/mechanism/medicare_channel_coefs.csv (long: outcome, shock, spec, term,
#   estimate, se, p, n, n_counties).

log_con <- file("Analysis/mechanism/build_logs/run_mechanism_medicare.log", open = "wt")
sink(log_con, split = TRUE); sink(log_con, type = "message")
on.exit({ sink(type = "message"); sink(); close(log_con) }, add = TRUE)
cat("=== run_mechanism_medicare.R run ===\n")

suppressPackageStartupMessages({ library(dplyr); library(fixest) })
pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")

# ---- 1. Load & merge ------------------------------------------------------
df <- read.csv("Data/county_level_master.csv")
df$fips_code <- pad_fips(df$fips_code)
df$State     <- as.factor(df$State)
df <- df %>% filter(Year >= 2011, Year <= 2023)

med <- readRDS("Data/intermediate_medicare_spending.rds") %>% mutate(fips_code = pad_fips(fips_code))
ag  <- readRDS("Data/intermediate_ag_dependence.rds") %>%
  mutate(fips_code = pad_fips(fips_code)) %>% select(fips_code, Ag_Dependence_Tercile)

df <- df %>% left_join(med, by = c("fips_code", "Year")) %>% left_join(ag, by = "fips_code")

# ---- 2. Construct AQI shock + lags (not pre-built in the master) -----------
# High_AQI_Max = a county-year with Max AQI in the "Unhealthy for Sensitive Groups"+
# range (>100); the binary pollution shock used in the event-study track.
df <- df %>% arrange(fips_code, Year) %>% group_by(fips_code) %>%
  mutate(
    High_AQI_Max      = as.integer(Max_AQI > 100),
    High_AQI_Max_Lag1 = dplyr::lag(High_AQI_Max, 1),
    High_AQI_Max_Lag2 = dplyr::lag(High_AQI_Max, 2)
  ) %>% ungroup()

df$log_benes <- ifelse(!is.na(df$Benes_Total) & df$Benes_Total > 0, log(df$Benes_Total), NA_real_)

cat("Panel merged:", nrow(df), "rows;",
    "Medicare non-missing (Mdcr_Std_Payment_PC):", sum(!is.na(df$Mdcr_Std_Payment_PC)),
    "over", paste(range(df$Year[!is.na(df$Mdcr_Std_Payment_PC)]), collapse = "-"), "\n\n")

# ---- 3. Config ------------------------------------------------------------
outcomes <- c("Mdcr_Std_Payment_PC", "ER_Visits_per1000", "IP_Stays_per1000",
              "IP_Days_per1000", "Readmission_Rate")
shocks <- list(
  Drought = c("Is_Extreme_Drought", "Is_Extreme_Drought_Lag1", "Is_Extreme_Drought_Lag2"),
  HDD     = c("High_HDD", "High_HDD_Lag1", "High_HDD_Lag2"),
  CDD     = c("High_CDD", "High_CDD_Lag1", "High_CDD_Lag2"),
  AQI     = c("High_AQI_Max", "High_AQI_Max_Lag1", "High_AQI_Max_Lag2")
)
controls <- intersect(c("MA_Rate", "Dual_Pct", "log_benes"), names(df))

safe_feols <- function(f, data) tryCatch(feols(f, data = data, cluster = "State"),
                                         error = function(e) { cat("    fit error:", conditionMessage(e), "\n"); NULL })
tidy_rows <- function(model, outcome, shock, spec, keep_terms) {
  if (is.null(model)) return(NULL)
  ct <- as.data.frame(coeftable(model)); ct$term <- rownames(ct); rownames(ct) <- NULL
  names(ct)[1:4] <- c("estimate", "se", "t", "p")
  ct <- ct[ct$term %in% keep_terms, c("term","estimate","se","p")]
  if (nrow(ct) == 0) return(NULL)
  data.frame(outcome, shock, spec, ct, n = model$nobs,
             n_counties = model$fixef_sizes[["fips_code"]], row.names = NULL)
}

# ---- 4. Estimation --------------------------------------------------------
results <- list()
for (oc in outcomes) {
  if (!oc %in% names(df)) { cat("[skip missing outcome]", oc, "\n"); next }
  for (sh in names(shocks)) {
    terms <- shocks[[sh]]
    if (!all(terms %in% names(df))) { cat("[skip shock]", sh, "\n"); next }
    f <- as.formula(paste(oc, "~", paste(c(terms, controls), collapse = "+"), "| fips_code + Year"))
    # OVERALL
    results[[length(results)+1]] <- tidy_rows(safe_feols(f, df), oc, sh, "overall", terms)
    # SUBSAMPLE: bottom ag tercile (separability)
    sub <- df[!is.na(df$Ag_Dependence_Tercile) & df$Ag_Dependence_Tercile == 1, ]
    results[[length(results)+1]] <- tidy_rows(safe_feols(f, sub), oc, sh, "subsample_low_ag", terms)
  }
}
coefs <- bind_rows(results)
write.csv(coefs, "Analysis/mechanism/medicare_channel_coefs.csv", row.names = FALSE)
cat("\nWrote Analysis/mechanism/medicare_channel_coefs.csv (", nrow(coefs), "rows )\n")

# ---- 5. Headline scan: heat/cold/AQI -> std spending & ED visits -----------
cat("\n--- morbidity scan: std spending & ER visits (overall) ---\n")
scan <- coefs %>%
  filter(outcome %in% c("Mdcr_Std_Payment_PC","ER_Visits_per1000"), spec == "overall") %>%
  arrange(outcome, shock, term)
print(scan, digits = 3)
cat("\nDone.\n")
