# ---------------------------------------------------------------------------
# exposure_index.R  (Climate–Health Exposure Index — Phase 2)
#
# Sourceable helpers for the exposure-index components.
#
# person_years_exposure(): Lancet-Countdown-style population-weighted exposure —
#   the number of people exposed to an extreme-temperature year. For a binary
#   hazard indicator this is Population x indicator (person-years of exposure);
#   for a continuous intensity it is Population x intensity.
#
# build_chei(): composite Climate-Health Exposure Index under the
#   hazard x vulnerability (x exposure) risk framing:
#     relative  : CHEI = hazard_z * SVI
#     absolute  : CHEI = hazard_z * SVI * Population   (when pop supplied)
#   SVI is a [0,1] vulnerability percentile, so SVI = 0 (least vulnerable) yields
#   a zero index and the index rises with both hazard and vulnerability. Optional
#   z-score standardisation for use as a regressor.
# ---------------------------------------------------------------------------

# Population-weighted exposure. NA in either input propagates to NA unless
# na_indicator_zero = TRUE, in which case a missing hazard indicator counts as
# "not exposed" (0) and exposure is 0 wherever population is known.
person_years_exposure <- function(pop, hazard_indicator, na_indicator_zero = FALSE) {
  pop <- as.numeric(pop)
  h   <- as.numeric(hazard_indicator)
  if (na_indicator_zero) h[is.na(h)] <- 0
  pop * h
}

# Composite exposure index. hazard_z: (standardised) hazard intensity. svi: [0,1]
# vulnerability percentile. pop: optional population for the absolute-burden
# variant. standardize: z-score the returned index (mean 0, sd 1) over non-NA.
build_chei <- function(hazard_z, svi, pop = NULL, standardize = FALSE) {
  hz <- as.numeric(hazard_z)
  v  <- as.numeric(svi)
  idx <- hz * v
  if (!is.null(pop)) idx <- idx * as.numeric(pop)
  if (standardize) {
    mu <- mean(idx, na.rm = TRUE); sdv <- stats::sd(idx, na.rm = TRUE)
    idx <- if (is.finite(sdv) && sdv > 0) (idx - mu) / sdv else idx - mu
  }
  idx
}
