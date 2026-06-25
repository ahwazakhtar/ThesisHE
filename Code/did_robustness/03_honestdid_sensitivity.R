# =============================================================================
# DiD Frontier-Robustness — 03. HonestDiD Parallel-Trends Sensitivity
# =============================================================================
# STATUS: WRITTEN, NOT YET RUN (deferred — see track plan.md, Phase 3).
#
# The Drought_2012 cohort has a single pre-period (2011), so its parallel-trends
# assumption is untestable in isolation. But the pooled CS event-study includes
# later drought cohorts (2021, 2022) with MANY pre-periods. Rambachan & Roth
# (2023) HonestDiD turns "are pre-trends exactly flat?" into a sensitivity
# question: how large would a post-treatment deviation from parallel trends have
# to be (relative to the largest pre-treatment violation, M-bar) before the
# estimated effect loses significance? We report the "breakdown" M-bar.
#
# Depends on the event-study object from 02 (did::att_gt -> aggte dynamic). To
# keep this script standalone it re-estimates the dynamic aggregation for the
# headline outcomes.
#
# Run (R 4.5.3):
#   "C:/Program Files/R/R-4.5.3/bin/Rscript.exe" Code/did_robustness/03_honestdid_sensitivity.R
#
# Output: Analysis/did/robustness/honestdid_sensitivity.csv
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(did)
  library(HonestDiD)
})
source("Code/did_robustness/00_did_robustness_common.R")
set.seed(DID_ROB_SEED)

HEADLINE_OUTCOMES <- c("PCPI_Real", "Civilian_Employed")
MBARVEC <- c(0.5, 1, 1.5, 2)   # post deviation as multiples of max pre violation

panel   <- load_did_panel()
cohorts <- build_cohorts(panel, "Is_Extreme_Drought")
base    <- baseline_covariates(panel)

cs_panel <- panel %>%
  inner_join(cohorts %>% select(fips_code, cohort), by = "fips_code") %>%
  left_join(base, by = "fips_code") %>%
  mutate(id = as.integer(factor(fips_code)),
         State_num = as.integer(factor(State)),
         medinc_z = as.numeric(scale(medinc_2011)),
         logpop_z = as.numeric(scale(log_pop_2011)))

# ---------------------------------------------------------------------------
# honest_did helper for a did dynamic-aggregation object (per HonestDiD vignette
# "Honest DiD with did package"). Extracts the event-study betahat/vcov, drops
# the reference period, and runs relative-magnitudes sensitivity.
# ---------------------------------------------------------------------------
honest_did_aggte <- function(es, e = 0, Mbarvec = MBARVEC) {
  # es: output of did::aggte(type="dynamic"). Build the event-study vcov from
  # the influence function. The asymptotic vcov of the (un-scaled) estimates is
  # (1/n^2) * t(inf) %*% inf  (mean-of-a-mean -> divide by n twice; matches the
  # HonestDiD "Honest DiD with did" vignette honest_did.AGGTEobj helper).
  V0 <- es$inf.function$dynamic.inf.func.e
  n  <- nrow(V0)
  Sigma <- (t(V0) %*% V0) / (n^2)
  keep <- es$egt != -1                       # drop the reference period (e = -1)
  betahat <- es$att.egt[keep]
  Sigma   <- Sigma[keep, keep, drop = FALSE]
  npre  <- sum(es$egt < -1)
  npost <- sum(es$egt > -1)
  sens <- HonestDiD::createSensitivityResults_relativeMagnitudes(
    betahat = betahat, sigma = Sigma,
    numPrePeriods = npre, numPostPeriods = npost,
    Mbarvec = Mbarvec, l_vec = HonestDiD::basisVector(index = e + 1, size = npost))
  attr(sens, "npre")  <- npre
  attr(sens, "npost") <- npost
  sens
}

rows <- list()
for (y in HEADLINE_OUTCOMES) {
  cat("HonestDiD ->", y, "\n")
  d <- cs_panel %>% filter(!is.na(.data[[y]]), !is.na(medinc_z), !is.na(logpop_z))
  out <- tryCatch(
    did::att_gt(yname = y, tname = "Year", idname = "id", gname = "cohort",
                xformla = ~ logpop_z + medinc_z, data = as.data.frame(d),
                control_group = "nevertreated", est_method = "dr",
                clustervars = "State_num", bstrap = TRUE, base_period = "universal",
                allow_unbalanced_panel = TRUE),
    error = function(e) { cat("  att_gt failed:", conditionMessage(e), "\n"); NULL })
  if (is.null(out)) next
  # Restrict to informative horizons: long leads/lags come from tiny recent
  # cohorts and are pure noise. e in [-5, 5] -> 4 pre + 6 post periods.
  es <- did::aggte(out, type = "dynamic", na.rm = TRUE, min_e = -5, max_e = 5)
  sens <- tryCatch(honest_did_aggte(es, e = 0),
                   error = function(e) { cat("  HonestDiD failed:", conditionMessage(e), "\n"); NULL })
  if (is.null(sens)) next
  r <- as.data.frame(sens)
  r$Outcome <- y
  # CI excludes 0 only if lb and ub are on the same side of 0.
  r$excludes_0 <- (r$lb > 0) | (r$ub < 0)
  rows[[y]] <- r
}

res <- do.call(rbind, rows)
write_csv(res, file.path(OUT_DIR, "honestdid_sensitivity.csv"))
cat("\n=== HonestDiD relative-magnitudes robust CIs (e=0) ===\n")
print(res, row.names = FALSE, digits = 4)
cat("\nInterpretation: the breakdown M-bar is the largest value at which the\n",
    "robust CI still excludes 0. M-bar>1 means the effect survives a post-period\n",
    "parallel-trends violation LARGER than the worst pre-period violation.\n", sep = "")
