# =============================================================================
# run_mechanism_employment_rescaled.R  (mechanisms_revision_20260704 — Task 1.1)
# =============================================================================
# THE ONE GRID that discharges three second-reviewer points at once, on the
# EMPLOYMENT specs (the only scale-contaminated outcome; income/debt are already
# scale-free):
#   A2  — re-estimate in LOG(Civilian_Employed) (+ asinh + per-1,000-residents),
#         so the bottom-ag-tercile vs overall comparison is proportional rather
#         than a county-size artifact (bottom-ag counties are urban & larger, so
#         −2,011 jobs vs −721 overall in LEVELS is uninterpretable).
#   B1  — add an F1 LEAD of each shock as a placebo (a future shock should not
#         move current employment; a non-null lead flags trend contamination).
#   B2  — add a DIVISION×YEAR-FE column alongside the county+Year baseline, to
#         absorb differential regional warming (the frozen-baseline heat-trend
#         threat; matters for the CDD/heat coefficients).
#
# Mirrors run_mechanism_agriculture.R (Ag_z, Labor_z, terciles, controls, shocks,
# overall/interaction/subsample specs, state clustering) and adds EnergyBurden_z
# from run_mechanism_secondary.R, so the ONLY things that change are the outcome
# scale, the lead placebo, and the FE structure.
#
# ENV: main R 4.2.2.  Rscript Code/run_mechanism_employment_rescaled.R
# OUTPUT: Analysis/mechanism/employment_rescaled_coefs.csv (long grid) + log.
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(fixest) })

# --- helper (pure; unit-tested by test_employment_rescaled.R) ---------------
# add_shock_leads(): per-`group` F1..Fn LEADS of each column, by Year. Lead1 of a
# shock at t+1 lands in row t (the placebo regressor). Mirror of add_shock_lags.
add_shock_leads <- function(df, cols, n_lead = 1L, group = "fips_code") {
  df <- df[order(df[[group]], df$Year), , drop = FALSE]
  df <- dplyr::group_by(df, dplyr::across(dplyr::all_of(group)))
  for (s in cols) for (k in seq_len(n_lead)) {
    df <- dplyr::mutate(df, !!paste0(s, "_Lead", k) := dplyr::lead(.data[[s]], k))
  }
  as.data.frame(dplyr::ungroup(df))
}

# 2-letter state -> Census division (county master `State` is a 2-letter abbrev).
CENSUS_DIVISION <- c(
  CT="NewEng", ME="NewEng", MA="NewEng", NH="NewEng", RI="NewEng", VT="NewEng",
  NJ="MidAtl", NY="MidAtl", PA="MidAtl",
  IL="ENC", IN="ENC", MI="ENC", OH="ENC", WI="ENC",
  IA="WNC", KS="WNC", MN="WNC", MO="WNC", NE="WNC", ND="WNC", SD="WNC",
  DE="SAtl", FL="SAtl", GA="SAtl", MD="SAtl", NC="SAtl", SC="SAtl", VA="SAtl",
  DC="SAtl", WV="SAtl",
  AL="ESC", KY="ESC", MS="ESC", TN="ESC",
  AR="WSC", LA="WSC", OK="WSC", TX="WSC",
  AZ="Mtn", CO="Mtn", ID="Mtn", MT="Mtn", NV="Mtn", NM="Mtn", UT="Mtn", WY="Mtn",
  AK="Pac", CA="Pac", HI="Pac", OR="Pac", WA="Pac")

if (sys.nframe() == 0L) {
  dir.create("Analysis/mechanism/build_logs", showWarnings = FALSE, recursive = TRUE)
  lc <- file("Analysis/mechanism/build_logs/run_mechanism_employment_rescaled.log", open = "wt")
  sink(lc, split = TRUE); sink(lc, type = "message")
  on.exit({ sink(type = "message"); sink(); close(lc) }, add = TRUE)
  cat("=== employment rescaling campaign (A2+B1+B2) ::", format(Sys.time()), "===\n\n")

  pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
  zscore   <- function(x) { m <- mean(x, na.rm=TRUE); s <- sd(x, na.rm=TRUE); (x-m)/s }

  # ---- load & merge (mirror run_mechanism_agriculture.R + energy) -----------
  df <- read.csv("Data/county_level_master.csv")
  df$fips_code <- pad_fips(df$fips_code)
  df <- df %>% filter(Year >= 2011, Year <= 2023)
  df$Division <- unname(CENSUS_DIVISION[as.character(df$State)])
  df$State <- as.factor(df$State)

  ag  <- readRDS("Data/intermediate_ag_dependence.rds") %>% mutate(fips_code=pad_fips(fips_code)) %>%
    select(fips_code, Farm_Earnings_Share, Ag_Dependence_Tercile)
  ind <- readRDS("Data/intermediate_industry_composition.rds") %>% mutate(fips_code=pad_fips(fips_code)) %>%
    distinct(fips_code, ClimateExposed_NonFarm_Share_baseline, ClimateExposed_Tercile)
  en  <- readRDS("Data/intermediate_energy_burden.rds") %>% mutate(fips_code=pad_fips(fips_code)) %>%
    distinct(fips_code, Energy_Burden_Pct, Energy_Burden_Tercile)
  df <- df %>% left_join(ag, by="fips_code") %>% left_join(ind, by="fips_code") %>%
    left_join(en, by="fips_code")

  df$Ag_z          <- zscore(df$Farm_Earnings_Share)
  df$Labor_z       <- zscore(df$ClimateExposed_NonFarm_Share_baseline)
  df$EnergyBurden_z <- zscore(df$Energy_Burden_Pct)

  # ---- rescaled employment outcomes + shock leads --------------------------
  df$log_emp      <- ifelse(df$Civilian_Employed > 0, log(df$Civilian_Employed), NA_real_)
  df$asinh_emp    <- asinh(df$Civilian_Employed)
  df$emp_per1000  <- ifelse(df$Population > 0, df$Civilian_Employed / df$Population * 1000, NA_real_)

  shock_bases <- c("Is_Extreme_Drought", "High_HDD", "High_CDD")
  df <- add_shock_leads(df, shock_bases, n_lead = 1L)   # *_Lead1 placebos

  cat("Panel:", nrow(df), "county-years,", n_distinct(df$fips_code), "counties.  Moderator n:",
      "Ag", sum(!is.na(df$Ag_z)), "Labor", sum(!is.na(df$Labor_z)),
      "Energy", sum(!is.na(df$EnergyBurden_z)), "\n\n")

  # ---- config --------------------------------------------------------------
  scales   <- c("log_emp", "asinh_emp", "emp_per1000")
  shocks <- list(
    Drought = c("Is_Extreme_Drought","Is_Extreme_Drought_Lag1","Is_Extreme_Drought_Lag2"),
    HDD     = c("High_HDD","High_HDD_Lag1","High_HDD_Lag2"),
    CDD     = c("High_CDD","High_CDD_Lag1","High_CDD_Lag2"))
  lead_of  <- c(Drought="Is_Extreme_Drought_Lead1", HDD="High_HDD_Lead1", CDD="High_CDD_Lead1")
  moderators <- list(Ag=list(z="Ag_z", tc="Ag_Dependence_Tercile"),
                     Labor=list(z="Labor_z", tc="ClimateExposed_Tercile"),
                     Energy=list(z="EnergyBurden_z", tc="Energy_Burden_Tercile"))
  fe_specs <- list(baseline="fips_code + Year", divyear="fips_code + Division^Year")
  ctl <- intersect(c("Household_Income_2023","Uninsured_Rate"), names(df))  # employment: keep both

  safe_feols <- function(f, data) tryCatch(feols(f, data=data, cluster="State"),
                                           error=function(e){ cat("  fit err:",conditionMessage(e),"\n"); NULL })
  tidy_rows <- function(m, scale, shock, moderator, spec, fe, keep) {
    if (is.null(m)) return(NULL)
    ct <- as.data.frame(coeftable(m)); ct$term <- rownames(ct); rownames(ct) <- NULL
    names(ct)[1:4] <- c("estimate","se","t","p")
    ct <- ct[ct$term %in% keep, c("term","estimate","se","p")]
    if (nrow(ct)==0) return(NULL)
    data.frame(scale, shock, moderator, spec, fe, ct, n=m$nobs,
               n_counties=m$fixef_sizes[["fips_code"]], row.names=NULL, stringsAsFactors=FALSE)
  }

  # ---- estimation loop -----------------------------------------------------
  res <- list()
  for (sc in scales) for (sh in names(shocks)) {
    terms <- shocks[[sh]]; ld <- lead_of[[sh]]
    for (fe_name in names(fe_specs)) {
      fe <- fe_specs[[fe_name]]
      # OVERALL + F1 lead placebo (lead reported, not part of the headline lag terms)
      f_over <- as.formula(paste(sc, "~", paste(c(terms, ld, ctl), collapse="+"), "|", fe))
      m_over <- safe_feols(f_over, df)
      res[[length(res)+1]] <- tidy_rows(m_over, sc, sh, "-", "overall", fe_name, c(terms, ld))
      for (md in names(moderators)) {
        zc <- moderators[[md]]$z; tc <- moderators[[md]]$tc
        inter <- paste0(terms, ":", zc)
        f_int <- as.formula(paste(sc, "~", paste(c(terms, inter, ctl), collapse="+"), "|", fe))
        res[[length(res)+1]] <- tidy_rows(safe_feols(f_int, df), sc, sh, md, "interaction", fe_name, inter)
        sub <- df[!is.na(df[[tc]]) & df[[tc]]==1, ]
        res[[length(res)+1]] <- tidy_rows(safe_feols(f_over, sub), sc, sh, md, "subsample_bottom", fe_name, c(terms, ld))
      }
    }
  }
  coefs <- bind_rows(res)
  write.csv(coefs, "Analysis/mechanism/employment_rescaled_coefs.csv", row.names=FALSE)
  cat("Wrote Analysis/mechanism/employment_rescaled_coefs.csv (", nrow(coefs), "rows)\n\n")

  # ---- headline scans ------------------------------------------------------
  sig <- function(x) formatC(x, format="g", digits=3)
  cat("--- A2 HEADLINE: cold(HDD) -> LOG employment, overall vs bottom-ag-tercile (baseline FE) ---\n")
  h <- coefs %>% filter(scale=="log_emp", shock=="HDD", fe=="baseline",
                        (spec=="overall" & moderator=="-") | (spec=="subsample_bottom" & moderator=="Ag"),
                        term %in% c("High_HDD","High_HDD_Lag1","High_HDD_Lag2")) %>%
    mutate(across(c(estimate,se,p), ~signif(.x,3))) %>% arrange(term, spec)
  print(h, row.names=FALSE)

  cat("\n--- A2/B2: heat(CDD) interactions in LOG employment (baseline vs division×year FE) ---\n")
  hi <- coefs %>% filter(scale=="log_emp", shock=="CDD", spec=="interaction",
                         moderator %in% c("Labor","Energy"),
                         term %in% c("High_CDD:Labor_z","High_CDD:EnergyBurden_z")) %>%
    mutate(across(c(estimate,se,p), ~signif(.x,3))) %>% arrange(moderator, fe)
  print(hi, row.names=FALSE)

  cat("\n--- B1: F1 lead placebos in LOG employment, overall (should be ~null) ---\n")
  lp <- coefs %>% filter(scale=="log_emp", spec=="overall", grepl("_Lead1$", term), fe=="baseline") %>%
    mutate(across(c(estimate,se,p), ~signif(.x,3)))
  print(lp[, c("shock","term","estimate","se","p")], row.names=FALSE)
  cat("\n=== done", format(Sys.time()), "===\n")
}
