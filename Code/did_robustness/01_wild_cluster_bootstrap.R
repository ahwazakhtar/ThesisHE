# =============================================================================
# DiD Frontier-Robustness — 01. Wild Cluster Bootstrap + Randomization Inference
# =============================================================================
# Addresses the FEW-TREATED-CLUSTERS problem. The Drought_2012 cohort's 139
# counties are concentrated in a handful of states (GA 45, CO 21, NE 17, NM 10
# = 67% in 4 states). Analytic state-clustered SEs over-reject when treatment
# variation lives in few clusters. Two corrections:
#
#   (A) Wild cluster bootstrap-t (Cameron-Gelbach-Miller 2008), Webb 6-point
#       weights, null imposed (WCR). fwildclusterboot::boottest.
#   (B) Randomization inference (Fisher): re-draw the 139 "treated" labels at
#       random from the 2,673-county pool many times; p = share of placebo
#       |ATT| >= observed |ATT|.
#
# SPEED: boottest with 3,155 county FE is prohibitively slow, so we partial out
# the county + year FE via Frisch-Waugh-Lovell and bootstrap the residualized
# 1-regressor model. Point estimate is identical; the bootstrap clusters on
# state regardless of how the FE were absorbed.
#
# Run (R 4.5.3):
#   "C:/Program Files/R/R-4.5.3/bin/Rscript.exe" Code/did_robustness/01_wild_cluster_bootstrap.R
#
# Output: Analysis/did/robustness/wild_bootstrap_2x2.csv
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
  library(fwildclusterboot)
})
source("Code/did_robustness/00_did_robustness_common.R")
set.seed(DID_ROB_SEED)

B_BOOT  <- 9999L     # bootstrap draws
N_PERM  <- 2000L     # randomization-inference permutations
EVENT   <- 2012L

panel   <- load_did_panel()
cohorts <- build_cohorts(panel, "Is_Extreme_Drought")
frame   <- did_2x2_frame(panel, cohorts, EVENT)

cat(sprintf("Drought_%d 2x2: treated=%d, control=%d counties\n",
            EVENT, attr(frame, "n_treated"), attr(frame, "n_control")))

# ---------------------------------------------------------------------------
# Per-outcome: analytic ATT, wild cluster bootstrap, randomization inference
# ---------------------------------------------------------------------------
one_outcome <- function(y) {
  d <- frame %>% filter(!is.na(.data[[y]]))
  d$State <- factor(d$State)

  # --- Analytic two-way FE, state-clustered ---
  m <- feols(as.formula(paste(y, "~ TxP | fips_code + Year")),
             data = d, cluster = ~State)
  att <- unname(coef(m)["TxP"]); se <- unname(se(m)["TxP"])
  p_analytic <- unname(pvalue(m)["TxP"])
  n_tr_states <- n_distinct(d$State[d$Treated == 1])
  n_states    <- n_distinct(d$State)

  # --- (A) Wild cluster bootstrap via FWL-residualized model (fast) ---
  # Partial out county + year FE from y and TxP, then bootstrap y~TxP.
  dm <- demean(cbind(yv = d[[y]], TxP = d$TxP),
               f = d[, c("fips_code", "Year")])
  d$.yv <- dm[, "yv"]; d$.TxP <- dm[, "TxP"]
  m_fwl <- feols(.yv ~ .TxP, data = d, cluster = ~State)
  bt <- boottest(m_fwl, param = ".TxP", clustid = "State",
                 B = B_BOOT, type = "webb", impose_null = TRUE)
  p_wcb <- bt$p_val
  ci_wcb <- bt$conf_int

  # --- (B) Randomization inference (Fisher sharp null) ---
  # Reassign Treated to a random 139-county subset; recompute ATT on the
  # FWL-residualized outcome (FE held fixed under the sharp null of no effect).
  fips_all <- unique(d$fips_code)
  n_tr     <- attr(frame, "n_treated")
  # placebo ATT = coefficient of placebo Post-interaction on residualized y.
  obs_abs <- abs(att)
  # Build a county-level lookup of residualized y by (fips, Post).
  perm_stat <- function() {
    pl_treat <- sample(fips_all, n_tr)
    d$.plTxP <- as.integer(d$fips_code %in% pl_treat) * d$Post
    # demean placebo interaction within FE, regress residual y on it
    plr <- demean(cbind(p = d$.plTxP), f = d[, c("fips_code", "Year")])[, "p"]
    cf  <- coef(.lm.fit(cbind(1, plr), d$.yv))[2]
    abs(cf)
  }
  perms <- replicate(N_PERM, perm_stat())
  p_ri  <- (1 + sum(perms >= obs_abs)) / (1 + N_PERM)

  data.frame(
    Event = sprintf("Drought_%d", EVENT), Outcome = y,
    ATT = att, SE_analytic = se, p_analytic = p_analytic,
    p_wcb_webb = p_wcb, wcb_ci_lo = ci_wcb[1], wcb_ci_hi = ci_wcb[2],
    p_randinf = p_ri,
    n_states = n_states, n_treated_states = n_tr_states,
    N = nobs(m), B = B_BOOT, N_perm = N_PERM,
    stringsAsFactors = FALSE)
}

results <- lapply(DID_ROB_OUTCOMES, function(y) {
  cat("  -> ", y, "\n"); tryCatch(one_outcome(y),
    error = function(e) { cat("     FAILED:", conditionMessage(e), "\n"); NULL })
})
results <- do.call(rbind, Filter(Negate(is.null), results))

out <- file.path(OUT_DIR, "wild_bootstrap_2x2.csv")
write_csv(results, out)
cat("\n=== Wild cluster bootstrap + RI ===\n")
print(results, row.names = FALSE, digits = 4)
cat(sprintf("\nWrote %s\n", out))
