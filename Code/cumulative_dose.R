# ---------------------------------------------------------------------------
# cumulative_dose.R  (Persistence Extensions — Phase 3)
#
# Helpers for the cumulative-shock-years dose-response analysis.
#
# add_cumulative_shock_years(): running count of shock-positive years per county
#   up to and including year t. PRIMARY SPEC IS MONOTONIC NON-DECREASING — the
#   dose never resets when a county exits and re-enters shock (it measures total
#   accumulated exposure, the "wear and tear" interpretation). NA shock-years
#   contribute 0 (no increment) and the running total carries forward.
#
# lincom(): estimate + SE + p for an arbitrary linear combination of a fitted
#   model's coefficients, from its (clustered) vcov. Used to test, e.g., whether
#   the 10+ cumulative-years bin differs from the 1-3 bin, and to evaluate the
#   quadratic marginal effect b1 + 2*b2*x at chosen dose levels.
# ---------------------------------------------------------------------------

add_cumulative_shock_years <- function(df, shock_col, out_col,
                                       fips_col = "fips_code", year_col = "Year") {
  stopifnot(all(c(shock_col, fips_col, year_col) %in% names(df)))
  ord <- order(df[[fips_col]], df[[year_col]])
  df  <- df[ord, , drop = FALSE]
  s   <- as.integer(df[[shock_col]])
  s[is.na(s)] <- 0L
  df[[out_col]] <- stats::ave(s, df[[fips_col]], FUN = cumsum)
  df
}

lincom <- function(model, weights) {
  if (is.null(model)) return(NULL)
  b <- coef(model); V <- vcov(model)
  terms <- names(weights)
  if (is.null(terms) || !all(terms %in% names(b)) || !all(terms %in% rownames(V))) return(NULL)
  w  <- as.numeric(weights)
  L  <- sum(w * b[terms])
  vL <- as.numeric(t(w) %*% V[terms, terms, drop = FALSE] %*% w)
  se <- if (is.finite(vL) && vL > 0) sqrt(vL) else NA_real_
  z  <- if (!is.na(se)) L / se else NA_real_
  p  <- if (!is.na(z)) 2 * stats::pnorm(-abs(z)) else NA_real_
  data.frame(estimate = L, std.error = se, z.value = z, p.value = p,
             stringsAsFactors = FALSE)
}
