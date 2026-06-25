# =============================================================================
# DiD Frontier-Robustness — 02. Doubly-Robust DiD with Baseline Covariates
# =============================================================================
# STATUS: WRITTEN, NOT YET RUN (deferred — see track plan.md, Phase 2).
#
# Moves from UNCONDITIONAL parallel trends (treated rural Plains/Mountain/GA ag
# counties vs. a very different never-exposed pool) to CONDITIONAL parallel
# trends, via Sant'Anna & Zhao (2020) doubly-robust DiD. Robust if EITHER the
# outcome-regression OR the propensity model is correct.
#
# Covariates are PRE-TREATMENT baseline (2011) only: log population, baseline
# median HH income, Census division. We deliberately do NOT condition on
# contemporaneous income/unemployment/premiums — those are mediators of the
# climate shock (bad controls / post-treatment bias).
#
# Two estimators:
#   (A) DRDID::drdid  — focused 2x2 for the Drought_2012 cohort, post collapsed
#       to the unit mean over 2012-2023 (matches the sharp-2x2 estimand).
#   (B) did::att_gt (est_method="dr", control_group="nevertreated") — full
#       Callaway-Sant'Anna with covariates across all drought cohorts, with
#       multiplier-bootstrap clustered inference; aggregated to a simple overall
#       ATT and an event-study profile.
#
# Run (R 4.5.3):
#   "C:/Program Files/R/R-4.5.3/bin/Rscript.exe" Code/did_robustness/02_doubly_robust_did.R
#
# Outputs:
#   Analysis/did/robustness/dr_2x2_drought_2012.csv
#   Analysis/did/robustness/dr_csdid_drought.csv          (att_gt simple + dynamic)
#   Analysis/did/robustness/dr_csdid_eventtime.csv
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(DRDID)
  library(did)
})
source("Code/did_robustness/00_did_robustness_common.R")
set.seed(DID_ROB_SEED)

EVENT   <- 2012L
panel   <- load_did_panel()
cohorts <- build_cohorts(panel, "Is_Extreme_Drought")
base    <- baseline_covariates(panel)

# ---------------------------------------------------------------------------
# (A) DRDID 2x2 — collapse post to unit mean, balanced 2-period panel
# ---------------------------------------------------------------------------
dr_2x2_one <- function(y) {
  fr <- did_2x2_frame(panel, cohorts, EVENT, base) %>%
    filter(!is.na(.data[[y]]), !is.na(log_pop_2011), !is.na(medinc_2011),
           !is.na(Division))
  pre <- fr %>% filter(Year == 2011L) %>%
    transmute(fips_code, Treated, log_pop_2011, medinc_2011, Division, y0 = .data[[y]])
  post <- fr %>% filter(Year >= EVENT) %>%
    group_by(fips_code) %>% summarise(y1 = mean(.data[[y]]), .groups = "drop")
  u <- inner_join(pre, post, by = "fips_code") %>%
    mutate(id = as.integer(factor(fips_code)))   # DRDID requires numeric idname

  long <- bind_rows(
    u %>% transmute(id, period = 0L, Y = y0, Treated,
                    log_pop_2011, medinc_2011, Division),
    u %>% transmute(id, period = 1L, Y = y1, Treated,
                    log_pop_2011, medinc_2011, Division)) %>%
    mutate(medinc_z = as.numeric(scale(medinc_2011)),
           logpop_z = as.numeric(scale(log_pop_2011)))

  m <- DRDID::drdid(yname = "Y", tname = "period", idname = "id",
                    dname = "Treated",
                    xformla = ~ logpop_z + medinc_z + factor(Division),
                    data = as.data.frame(long), panel = TRUE, estMethod = "imp")
  data.frame(Estimator = "DRDID_2x2", Outcome = y,
             ATT = m$ATT, SE = m$se,
             ci_lo = m$lci, ci_hi = m$uci,
             N_units = nrow(u), stringsAsFactors = FALSE)
}

dr_2x2 <- do.call(rbind, lapply(DID_ROB_OUTCOMES, function(y)
  tryCatch(dr_2x2_one(y),
           error = function(e) { cat("DRDID", y, "failed:", conditionMessage(e), "\n"); NULL })))
stopifnot(!is.null(dr_2x2) && nrow(dr_2x2) > 0)
write_csv(dr_2x2, file.path(OUT_DIR, "dr_2x2_drought_2012.csv"))
cat("\n=== (A) DRDID 2x2 (covariate-conditional) ===\n"); print(dr_2x2, digits = 4)

# ---------------------------------------------------------------------------
# (B) Callaway-Sant'Anna with covariates (doubly robust)
# ---------------------------------------------------------------------------
# Build att_gt input: drought cohorts + never-treated, baseline covars joined,
# numeric ids. gname = first drought year (0 = never).
cs_panel <- panel %>%
  inner_join(cohorts %>% select(fips_code, cohort), by = "fips_code") %>%
  left_join(base, by = "fips_code") %>%
  mutate(id = as.integer(factor(fips_code)),
         State_num = as.integer(factor(State)),
         medinc_z = as.numeric(scale(medinc_2011)),
         logpop_z = as.numeric(scale(log_pop_2011)))

cs_one <- function(y) {
  d <- cs_panel %>% filter(!is.na(.data[[y]]), !is.na(medinc_z), !is.na(logpop_z))
  out <- did::att_gt(
    yname = y, tname = "Year", idname = "id", gname = "cohort",
    xformla = ~ logpop_z + medinc_z,
    data = as.data.frame(d),
    control_group = "nevertreated", est_method = "dr",
    clustervars = "State_num", bstrap = TRUE, base_period = "universal",
    allow_unbalanced_panel = TRUE)
  simple  <- did::aggte(out, type = "simple", na.rm = TRUE)
  dynamic <- did::aggte(out, type = "dynamic", na.rm = TRUE)
  list(
    simple = data.frame(Estimator = "CS_dr_simple", Outcome = y,
                        ATT = simple$overall.att, SE = simple$overall.se,
                        stringsAsFactors = FALSE),
    event = data.frame(Estimator = "CS_dr_dynamic", Outcome = y,
                       Event_Time = dynamic$egt,
                       ATT = dynamic$att.egt, SE = dynamic$se.egt,
                       stringsAsFactors = FALSE))
}

cs_simple <- list(); cs_event <- list()
for (y in DID_ROB_OUTCOMES) {
  cat("  CS-dr ->", y, "\n")
  r <- tryCatch(cs_one(y),
                error = function(e) { cat("    failed:", conditionMessage(e), "\n"); NULL })
  if (!is.null(r)) { cs_simple[[y]] <- r$simple; cs_event[[y]] <- r$event }
}
cs_simple_df <- if (length(cs_simple)) do.call(rbind, cs_simple) else NULL
cs_event_df  <- if (length(cs_event))  do.call(rbind, cs_event)  else NULL
if (!is.null(cs_simple_df)) write_csv(cs_simple_df, file.path(OUT_DIR, "dr_csdid_drought.csv"))
if (!is.null(cs_event_df))  write_csv(cs_event_df,  file.path(OUT_DIR, "dr_csdid_eventtime.csv"))
cat("\n=== (B) CS doubly-robust simple ATT ===\n")
if (!is.null(cs_simple_df)) print(cs_simple_df, digits = 4) else cat("(no CS results)\n")
cat("\nDone. Outputs in", OUT_DIR, "\n")
