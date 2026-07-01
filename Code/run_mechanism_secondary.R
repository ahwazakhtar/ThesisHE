# Phase 2 (Tasks 2d + 2e): energy-burden distributional test and migration selection check.
# Track: mechanism_channels_20260625.  Run: Rscript Code/run_mechanism_secondary.R
#
# 2d ENERGY-BURDEN (Channel 4): does the income/employment/distress effect of TEMPERATURE
#    shocks (cold/heat, which drive heating/cooling bills) concentrate in high-energy-burden
#    counties? Interact shock with z(energy burden), time-invariant 2022 vintage. Cross-check:
#    correlate energy burden with the static SVI used in the EJ results (should align --
#    Barreca/Doremus affordability mechanism underlies the high-SVI amplification).
#
# 2e MIGRATION SELECTION (Channel 7 caveat): do shocked counties LOSE population? Regress
#    net_migration_rate on the shocks (County+Year FE). Bounds how much of the h=2 income/
#    employment "scar" reflects population selection vs. same-population loss. Reported as a
#    caveat, not a headline. (IRS SOI migration 2012-2021.)
#
# All models: fixest::feols, | fips_code + Year, cluster State. Reduced-form (no bad controls).
#
# OUTPUT: Analysis/mechanism/energy_channel_coefs.csv, Analysis/mechanism/migration_selection_coefs.csv

log_con <- file("Analysis/mechanism/build_logs/run_mechanism_secondary.log", open = "wt")
sink(log_con, split = TRUE); sink(log_con, type = "message")
on.exit({ sink(type = "message"); sink(); close(log_con) }, add = TRUE)
cat("=== run_mechanism_secondary.R run ===\n")

suppressPackageStartupMessages({ library(dplyr); library(fixest) })
pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
zscore   <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)

df <- read.csv("Data/county_level_master.csv")
df$fips_code <- pad_fips(df$fips_code)
df$State     <- as.factor(df$State)
df <- df %>% filter(Year >= 2011, Year <= 2023)

energy <- readRDS("Data/intermediate_energy_burden.rds") %>% mutate(fips_code = pad_fips(fips_code)) %>%
  select(fips_code, Energy_Burden_Pct, Energy_Burden_Pct_LowInc, Energy_Burden_Tercile)
mig <- readRDS("Data/intermediate_migration.rds") %>% mutate(fips_code = pad_fips(fips_code))
svi <- readRDS("Data/intermediate_svi.rds") %>% mutate(fips_code = pad_fips(fips_code)) %>%
  distinct(fips_code, SVI_static)

df <- df %>% left_join(energy, by = "fips_code") %>% left_join(svi, by = "fips_code")
df$EnergyBurden_z <- zscore(df$Energy_Burden_Pct)

safe_feols <- function(f, data) tryCatch(feols(f, data = data, cluster = "State"),
                                         error = function(e) { cat("    fit error:", conditionMessage(e), "\n"); NULL })
tidy_rows <- function(model, ..., keep_terms) {
  if (is.null(model)) return(NULL)
  ct <- as.data.frame(coeftable(model)); ct$term <- rownames(ct); rownames(ct) <- NULL
  names(ct)[1:4] <- c("estimate", "se", "t", "p")
  ct <- ct[ct$term %in% keep_terms, c("term","estimate","se","p")]
  if (nrow(ct) == 0) return(NULL)
  data.frame(..., ct, n = model$nobs, n_counties = model$fixef_sizes[["fips_code"]], row.names = NULL)
}

# ===========================================================================
# 2d. ENERGY-BURDEN DISTRIBUTIONAL TEST
# ===========================================================================
cat("\n--- 2d: energy-burden interaction ---\n")
# cross-check: correlation of structural energy burden with static SVI
xc <- df %>% distinct(fips_code, Energy_Burden_Pct, SVI_static)
cat(sprintf("Cross-check corr(Energy_Burden_Pct, SVI_static) = %.3f  (n=%d counties)\n",
            cor(xc$Energy_Burden_Pct, xc$SVI_static, use = "complete.obs"),
            sum(complete.cases(xc[, c("Energy_Burden_Pct","SVI_static")]))))
cat(sprintf("Low-income energy burden mean %.2f%% vs overall %.2f%% (distributional signature)\n",
            mean(df$Energy_Burden_Pct_LowInc, na.rm = TRUE), mean(df$Energy_Burden_Pct, na.rm = TRUE)))

en_outcomes <- c("PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed", "Medical_Debt_Share")
en_shocks   <- list(HDD = c("High_HDD","High_HDD_Lag1","High_HDD_Lag2"),   # cold -> heating bills
                    CDD = c("High_CDD","High_CDD_Lag1","High_CDD_Lag2"))   # heat -> cooling bills
controls_en <- intersect("Uninsured_Rate", names(df))

en_res <- list()
for (oc in en_outcomes) {
  if (!oc %in% names(df)) next
  for (sh in names(en_shocks)) {
    terms <- en_shocks[[sh]]
    inter <- paste0(terms, ":EnergyBurden_z")
    f <- as.formula(paste(oc, "~", paste(c(terms, inter, controls_en), collapse = "+"),
                          "| fips_code + Year"))
    en_res[[length(en_res)+1]] <- tidy_rows(safe_feols(f, df),
                                            outcome = oc, shock = sh, keep_terms = c(terms, inter))
  }
}
energy_coefs <- bind_rows(en_res)
write.csv(energy_coefs, "Analysis/mechanism/energy_channel_coefs.csv", row.names = FALSE)
cat("Wrote Analysis/mechanism/energy_channel_coefs.csv (", nrow(energy_coefs), "rows )\n")
cat("Interaction terms (effect concentrates where interaction is signed with the main effect):\n")
print(energy_coefs %>% filter(grepl(":EnergyBurden_z", term)) %>% arrange(outcome, shock, term),
      digits = 3)

# ===========================================================================
# 2e. MIGRATION SELECTION CHECK
# ===========================================================================
cat("\n--- 2e: migration selection ---\n")
dfm <- df %>% left_join(mig %>% select(fips_code, Year, net_migration_rate,
                                       out_migration_rate, in_migration_rate),
                        by = c("fips_code", "Year"))
mig_shocks <- list(Drought = c("Is_Extreme_Drought","Is_Extreme_Drought_Lag1","Is_Extreme_Drought_Lag2"),
                   HDD     = c("High_HDD","High_HDD_Lag1","High_HDD_Lag2"),
                   CDD     = c("High_CDD","High_CDD_Lag1","High_CDD_Lag2"))
mig_res <- list()
for (yv in c("net_migration_rate", "out_migration_rate")) {
  for (sh in names(mig_shocks)) {
    terms <- mig_shocks[[sh]]
    f <- as.formula(paste(yv, "~", paste(terms, collapse = "+"), "| fips_code + Year"))
    mig_res[[length(mig_res)+1]] <- tidy_rows(safe_feols(f, dfm),
                                              outcome = yv, shock = sh, keep_terms = terms)
  }
}
mig_coefs <- bind_rows(mig_res)
write.csv(mig_coefs, "Analysis/mechanism/migration_selection_coefs.csv", row.names = FALSE)
cat("Wrote Analysis/mechanism/migration_selection_coefs.csv (", nrow(mig_coefs), "rows )\n")
cat("Net-migration-rate response to shocks (negative => shocked counties lose population):\n")
print(mig_coefs %>% filter(outcome == "net_migration_rate") %>% arrange(shock, term), digits = 3)
cat("\nDone.\n")
