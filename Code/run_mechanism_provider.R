# Phase 2 (provider channel, Channel 5): separability + heterogeneity test on the
# hospital-year panel. Track: mechanism_channels_20260625.
# Run: Rscript Code/run_mechanism_provider.R
#
# PURPOSE -------------------------------------------------------------------
# The `hospital_supply_side_20260615` incidence models found a COUNTERINTUITIVE provider
# result: drought -> LOWER uncompensated care and NULL operating margins. The supply-side
# literature review (2026-07-02) shows this is the EXPECTED result (Audi et al. 2024-25 find
# the same paradoxical sign; federal buffers + revenue-positive demand surges + deferred-care/
# out-migration + capital-structure-driven distress all predict a null/negative). This script
# adds the two tests the incidence models did not run, to complete the provider channel:
#   (i)  SEPARABILITY from agriculture — attach county ag-dependence to each hospital and ask
#        whether any provider effect LOADS on ag counties (interaction) or survives in the
#        bottom ag-dependence tercile.
#   (ii) PROVIDER HETEROGENEITY — interact shocks with the SafetyNet flag: does strain (if any)
#        concentrate in safety-net hospitals, where the literature says margins are >6x lower?
#
# DESIGN: Y_{it} ~ Shock_{c(i)t}(+lag1+lag2) [+ Shock x M] | CCN + Year, cluster State.
#   Moderators are hospital/county attributes constant within CCN, so their main effects are
#   absorbed by the hospital FE; only the interactions are identified (as intended).
#
# INPUT: Data/intermediate_hospital_panel.rds (hospital-year; fips_code, CCN, State, lagged
#   county shocks, Hosp_UncompCare_PctNPR/_Real, Hosp_OperatingMargin, SafetyNet) +
#   Data/intermediate_ag_dependence.rds (Farm_Earnings_Share, Ag_Dependence_Tercile).
#
# OUTPUT: Analysis/mechanism/provider_channel_coefs.csv (long: outcome, shock, moderator, spec,
#   term, estimate, se, p, n, n_hosp).

log_con <- file("Analysis/mechanism/build_logs/run_mechanism_provider.log", open = "wt")
sink(log_con, split = TRUE); sink(log_con, type = "message")
on.exit({ sink(type = "message"); sink(); close(log_con) }, add = TRUE)
cat("=== run_mechanism_provider.R run ===\n")

suppressPackageStartupMessages({ library(dplyr); library(fixest) })
pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
zscore   <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)

hp <- readRDS("Data/intermediate_hospital_panel.rds")
hp$fips_code <- pad_fips(hp$fips_code)
hp$State     <- as.factor(hp$State)

ag <- readRDS("Data/intermediate_ag_dependence.rds") %>%
  mutate(fips_code = pad_fips(fips_code)) %>%
  select(fips_code, Farm_Earnings_Share, Ag_Dependence_Tercile)

hp <- hp %>% left_join(ag, by = "fips_code")
hp$Ag_z <- zscore(hp$Farm_Earnings_Share)
# SafetyNet -> numeric 0/1 for interaction
hp$SafetyNet_num <- suppressWarnings(as.integer(hp$SafetyNet))

cat("Hospital panel:", nrow(hp), "hospital-years,", dplyr::n_distinct(hp$CCN), "hospitals,",
    paste(range(hp$Year, na.rm = TRUE), collapse = "-"), "\n")
cat("Ag_z non-missing:", sum(!is.na(hp$Ag_z)), "| SafetyNet non-missing:",
    sum(!is.na(hp$SafetyNet_num)), "(share SN =",
    round(mean(hp$SafetyNet_num, na.rm = TRUE), 3), ")\n\n")

outcomes <- c("Hosp_UncompCare_PctNPR", "Hosp_UncompCare_Real", "Hosp_OperatingMargin")
shocks <- list(
  Drought = c("Is_Extreme_Drought", "Is_Extreme_Drought_Lag1", "Is_Extreme_Drought_Lag2"),
  HDD     = c("High_HDD", "High_HDD_Lag1", "High_HDD_Lag2"),
  CDD     = c("High_CDD", "High_CDD_Lag1", "High_CDD_Lag2")
)
moderators <- list(Ag = "Ag_z", SafetyNet = "SafetyNet_num")

safe_feols <- function(f, data) tryCatch(feols(f, data = data, cluster = "State"),
                                         error = function(e) { cat("    fit error:", conditionMessage(e), "\n"); NULL })
tidy_rows <- function(model, outcome, shock, moderator, spec, keep_terms) {
  if (is.null(model)) return(NULL)
  ct <- as.data.frame(coeftable(model)); ct$term <- rownames(ct); rownames(ct) <- NULL
  names(ct)[1:4] <- c("estimate", "se", "t", "p")
  ct <- ct[ct$term %in% keep_terms, c("term","estimate","se","p")]
  if (nrow(ct) == 0) return(NULL)
  data.frame(outcome, shock, moderator, spec, ct, n = model$nobs,
             n_hosp = model$fixef_sizes[["CCN"]], row.names = NULL)
}

results <- list()
for (oc in outcomes) {
  if (!oc %in% names(hp)) { cat("[skip outcome]", oc, "\n"); next }
  for (sh in names(shocks)) {
    terms <- shocks[[sh]]
    if (!all(terms %in% names(hp))) { cat("[skip shock]", sh, "\n"); next }

    # OVERALL (reprises the incidence model, for the ratio baseline)
    f_over <- as.formula(paste(oc, "~", paste(terms, collapse = "+"), "| CCN + Year"))
    m_over <- safe_feols(f_over, hp)
    results[[length(results)+1]] <- tidy_rows(m_over, oc, sh, "-", "overall", terms)

    for (md in names(moderators)) {
      zc <- moderators[[md]]
      inter <- paste0(terms, ":", zc)
      f_int <- as.formula(paste(oc, "~", paste(c(terms, inter), collapse = "+"), "| CCN + Year"))
      results[[length(results)+1]] <- tidy_rows(safe_feols(f_int, hp), oc, sh, md, "interaction", inter)
    }
    # SUBSAMPLE: bottom ag-dependence tercile (does provider effect survive in low-ag counties?)
    sub <- hp[!is.na(hp$Ag_Dependence_Tercile) & hp$Ag_Dependence_Tercile == 1, ]
    results[[length(results)+1]] <- tidy_rows(safe_feols(f_over, sub), oc, sh, "Ag", "subsample_low_ag", terms)
  }
}

coefs <- bind_rows(results)
write.csv(coefs, "Analysis/mechanism/provider_channel_coefs.csv", row.names = FALSE)
cat("\nWrote Analysis/mechanism/provider_channel_coefs.csv (", nrow(coefs), "rows )\n")

# ---- headline scan: interactions on uncompensated care -------------------
cat("\n--- provider scan: Shock x moderator on Hosp_UncompCare_PctNPR ---\n")
scan <- coefs %>%
  filter(outcome == "Hosp_UncompCare_PctNPR", spec == "interaction") %>%
  arrange(shock, moderator, term)
print(scan, digits = 3)
cat("\n--- drought: overall vs bottom-ag-tercile (uncompensated care %) ---\n")
print(coefs %>% filter(outcome == "Hosp_UncompCare_PctNPR", shock == "Drought",
                       spec %in% c("overall","subsample_low_ag")) %>% arrange(term, spec), digits = 3)
cat("\nDone.\n")
