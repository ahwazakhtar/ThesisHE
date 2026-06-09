# ---------------------------------------------------------------------------
# transition_symmetry.R  (Persistence Extensions — Phase 1)
#
# Wald test for the symmetry of shock ONSET vs EXIT dynamics.
#
#   H0:  beta_Onset + beta_Exit = 0
#
# Both coefficients come from the SAME joint local-projection regression
#   lead(Y, h) ~ Onset + Persist + Exit + controls | fips_code + Year
# so they are measured relative to the same never-transitioned (0 -> 0) reference
# category and share a covariance, which lets us test the linear combination
# directly from the model's (clustered) vcov — no stacking or bootstrap needed.
#
# Interpretation:
#   - beta_Onset  = effect of just ENTERING the shock state (0 -> 1), vs staying out.
#   - beta_Exit   = effect of just LEAVING the shock state (1 -> 0), vs staying out.
#   - asymmetry = beta_Onset + beta_Exit. If shocks are fully reversible (the cost
#     of entering is exactly undone on leaving), onset and exit are mirror images
#     and the sum is 0. A positive sum is hysteresis / scarring (entering costs
#     more than leaving relieves); a negative sum is over-relief.
#
# Returns a one-row data.frame, or NULL if the model lacks the named terms.
# ---------------------------------------------------------------------------

transition_symmetry_test <- function(model, onset_term, exit_term, alpha = 0.05) {
  if (is.null(model)) return(NULL)
  b <- coef(model)
  V <- vcov(model)
  if (!all(c(onset_term, exit_term) %in% names(b))) return(NULL)
  if (!all(c(onset_term, exit_term) %in% rownames(V))) return(NULL)

  L     <- unname(b[[onset_term]] + b[[exit_term]])
  var_L <- V[onset_term, onset_term] + V[exit_term, exit_term] +
           2 * V[onset_term, exit_term]
  se_L  <- if (is.finite(var_L) && var_L > 0) sqrt(var_L) else NA_real_
  z     <- if (!is.na(se_L)) L / se_L else NA_real_
  p     <- if (!is.na(z)) 2 * stats::pnorm(-abs(z)) else NA_real_

  data.frame(
    beta_onset      = unname(b[[onset_term]]),
    beta_exit       = unname(b[[exit_term]]),
    asymmetry       = L,                       # beta_Onset + beta_Exit
    std.error       = se_L,
    z.value         = z,
    p.value         = p,
    reject_symmetry = isTRUE(p < alpha),       # TRUE => asymmetric (hysteresis)
    stringsAsFactors = FALSE
  )
}
