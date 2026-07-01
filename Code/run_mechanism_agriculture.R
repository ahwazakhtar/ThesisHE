# Phase 2 (Tasks 2a + 2b): bound the agricultural channel and test whether the
# surviving effect loads on climate-exposed NON-FARM employment (the labor channel).
# Track: mechanism_channels_20260625.  Run: Rscript Code/run_mechanism_agriculture.R
#
# QUESTION (reviewer): "How much of the reduced-form climate->income/employment effect
# CANNOT be explained by agriculture?" We answer with two complementary readings per
# (outcome, shock):
#   Spec OVERALL     : Y ~ shock(+lag1+lag2) + controls | County + Year, cluster State.
#   Spec INTERACTION : add shock-term x z(moderator). Does the effect LOAD on the
#                      moderator? (moderator main effect is absorbed by county FE since
#                      it is time-invariant.)
#   Spec SUBSAMPLE   : re-estimate OVERALL within the BOTTOM tercile of the moderator.
#                      For ag, the surviving effect there is, by construction, NOT the
#                      agricultural channel. Ratio effect_bottom/effect_overall is logged.
#
# MODERATORS (time-invariant, standardized z across counties):
#   Ag_z    = z(Farm_Earnings_Share)               (agricultural dependence; Task 2a)
#   Labor_z = z(ClimateExposed_NonFarm_Share_baseline) (non-farm climate-exposed labor; 2b)
#   Bottom-tercile subsample uses Ag_Dependence_Tercile==1 (ag) / ClimateExposed_Tercile==1 (labor).
#
# SEPARABILITY LOGIC: if an income/employment effect (a) attenuates toward zero in the
#   bottom AG tercile AND loads positively on Ag_z -> agricultural. If it (b) SURVIVES in
#   the bottom ag tercile AND loads on Labor_z -> broad labor exposure, NOT agriculture.
#
# CONTROLS: county+year FE plus Uninsured_Rate. Household_Income_2023 is DROPPED for the
#   income outcomes (bad control: near-identical to the dependent variable); kept otherwise.
#   Reduced-form by design -- we do NOT control for contemporaneous farm income (that would
#   be a bad control on the causal path; the whole point is the structural baseline moderator).
#
# OUTPUT: Analysis/mechanism/ag_channel_coefs.csv (long: outcome, shock, moderator, spec,
#   term, estimate, se, p, n, n_counties) + Analysis/mechanism/plots/.

log_con <- file("Analysis/mechanism/build_logs/run_mechanism_agriculture.log", open = "wt")
sink(log_con, split = TRUE); sink(log_con, type = "message")
on.exit({ sink(type = "message"); sink(); close(log_con) }, add = TRUE)
cat("=== run_mechanism_agriculture.R run ===\n")

suppressPackageStartupMessages({ library(dplyr); library(fixest) })

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
zscore   <- function(x) { m <- mean(x, na.rm = TRUE); s <- sd(x, na.rm = TRUE); (x - m) / s }

# ---- 1. Load & merge ------------------------------------------------------
df <- read.csv("Data/county_level_master.csv")
df$fips_code <- pad_fips(df$fips_code)
df$State     <- as.factor(df$State)
df <- df %>% filter(Year >= 2011, Year <= 2023)   # study window

ag  <- readRDS("Data/intermediate_ag_dependence.rds") %>%
  mutate(fips_code = pad_fips(fips_code)) %>%
  select(fips_code, Ag_Dependent, Farm_Earnings_Share, Ag_Dependence_Tercile)

ind <- readRDS("Data/intermediate_industry_composition.rds") %>%
  mutate(fips_code = pad_fips(fips_code)) %>%
  distinct(fips_code, ClimateExposed_NonFarm_Share_baseline, ClimateExposed_Tercile)

df <- df %>% left_join(ag, by = "fips_code") %>% left_join(ind, by = "fips_code")

# standardized (county-level) moderators; z computed on the merged panel is fine since
# the moderator is constant within county
df$Ag_z    <- zscore(df$Farm_Earnings_Share)
df$Labor_z <- zscore(df$ClimateExposed_NonFarm_Share_baseline)

cat("Panel:", nrow(df), "county-years,", dplyr::n_distinct(df$fips_code), "counties,",
    paste(range(df$Year), collapse = "-"), "\n")
cat("Ag_z non-missing:", sum(!is.na(df$Ag_z)),
    "| Labor_z non-missing:", sum(!is.na(df$Labor_z)), "\n\n")

# ---- 2. Config ------------------------------------------------------------
outcomes <- c("PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed",
              "Benchmark_Silver_Real", "Lowest_Bronze_Real", "Medical_Debt_Share")
income_like <- c("PCPI_Real", "Med_HH_Income_Real")   # drop Household_Income_2023 control

shocks <- list(
  Drought = c("Is_Extreme_Drought", "Is_Extreme_Drought_Lag1", "Is_Extreme_Drought_Lag2"),
  HDD     = c("High_HDD", "High_HDD_Lag1", "High_HDD_Lag2"),
  CDD     = c("High_CDD", "High_CDD_Lag1", "High_CDD_Lag2")
)
moderators <- list(
  Ag    = list(z = "Ag_z",    tercile = "Ag_Dependence_Tercile"),
  Labor = list(z = "Labor_z", tercile = "ClimateExposed_Tercile")
)

controls_for <- function(outcome) {
  ctl <- intersect(c("Household_Income_2023", "Uninsured_Rate"), names(df))
  if (outcome %in% income_like) ctl <- setdiff(ctl, "Household_Income_2023")
  ctl
}

safe_feols <- function(f, data) tryCatch(feols(f, data = data, cluster = "State"),
                                         error = function(e) { cat("    fit error:", conditionMessage(e), "\n"); NULL })

tidy_rows <- function(model, outcome, shock, moderator, spec, keep_terms) {
  if (is.null(model)) return(NULL)
  ct <- as.data.frame(coeftable(model))
  ct$term <- rownames(ct); rownames(ct) <- NULL
  names(ct)[1:4] <- c("estimate", "se", "t", "p")
  ct <- ct[ct$term %in% keep_terms, c("term","estimate","se","p")]
  if (nrow(ct) == 0) return(NULL)
  data.frame(outcome, shock, moderator, spec, ct,
             n = model$nobs, n_counties = model$fixef_sizes[["fips_code"]],
             row.names = NULL, stringsAsFactors = FALSE)
}

# ---- 3. Estimation loop ---------------------------------------------------
results <- list()
for (oc in outcomes) {
  if (!oc %in% names(df)) { cat("[skip missing outcome]", oc, "\n"); next }
  ctl <- controls_for(oc)
  for (sh_name in names(shocks)) {
    terms <- shocks[[sh_name]]
    if (!all(terms %in% names(df))) { cat("[skip missing shock]", sh_name, "\n"); next }

    # OVERALL
    f_over <- as.formula(paste(oc, "~", paste(c(terms, ctl), collapse = "+"), "| fips_code + Year"))
    m_over <- safe_feols(f_over, df)
    results[[length(results)+1]] <- tidy_rows(m_over, oc, sh_name, "-", "overall", terms)
    overall_est <- if (!is.null(m_over)) coef(m_over)[terms] else NULL

    for (md_name in names(moderators)) {
      zc <- moderators[[md_name]]$z; tc <- moderators[[md_name]]$tercile

      # INTERACTION: shock terms x z(moderator); moderator main effect absorbed by county FE
      inter_terms <- paste0(terms, ":", zc)
      f_int <- as.formula(paste(oc, "~",
                                paste(c(terms, inter_terms, ctl), collapse = "+"),
                                "| fips_code + Year"))
      m_int <- safe_feols(f_int, df)
      results[[length(results)+1]] <- tidy_rows(m_int, oc, sh_name, md_name, "interaction", inter_terms)

      # SUBSAMPLE: bottom tercile of this moderator
      sub <- df[!is.na(df[[tc]]) & df[[tc]] == 1, ]
      m_sub <- safe_feols(f_over, sub)
      rows_sub <- tidy_rows(m_sub, oc, sh_name, md_name, "subsample_bottom", terms)
      # attach effect ratio bottom/overall per term
      if (!is.null(rows_sub) && !is.null(overall_est)) {
        rows_sub$ratio_bottom_over_overall <-
          rows_sub$estimate / overall_est[rows_sub$term]
      }
      results[[length(results)+1]] <- rows_sub
    }
  }
}

coefs <- bind_rows(results)
# align columns (ratio only exists on subsample rows)
if (!"ratio_bottom_over_overall" %in% names(coefs)) coefs$ratio_bottom_over_overall <- NA_real_
dir.create("Analysis/mechanism/plots", showWarnings = FALSE, recursive = TRUE)
write.csv(coefs, "Analysis/mechanism/ag_channel_coefs.csv", row.names = FALSE)
cat("\nWrote Analysis/mechanism/ag_channel_coefs.csv (", nrow(coefs), "rows )\n")

# ---- 4. Quick verdict scan (contemporaneous + key lag) --------------------
cat("\n--- headline scan: overall vs bottom-ag-tercile (income/employment) ---\n")
scan <- coefs %>%
  filter(outcome %in% c("PCPI_Real","Civilian_Employed"),
         moderator %in% c("-","Ag"),
         spec %in% c("overall","subsample_bottom")) %>%
  arrange(outcome, shock, term, spec)
print(scan, digits = 3)
cat("\nDone.\n")
