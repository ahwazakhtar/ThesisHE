# ---------------------------------------------------------------------------
# exposure_cohorts.R  (Persistence Extensions — Phase 2)
#
# Classifies a county into a chronic-exposure cohort based on how many of the
# 13 panel years (2011-2023) it was shock-positive for a given indicator.
#
#   Always_Exposed     : >= 10 / 13 shock-years
#   Frequently_Exposed : 5 - 9 / 13
#   Rarely_Exposed     : 1 - 4 / 13
#   Never_Exposed      : 0 / 13
#
# Sourced by both Code/run_persistent_exposure.R and the test suite so the
# classification has a single definition with a ground truth to check against.
# ---------------------------------------------------------------------------

# Default cohort cut-points (lower bound of each non-Never band).
EXPOSURE_COHORT_CUTS <- list(always = 10L, frequently = 5L, rarely = 1L)

assign_exposure_cohort <- function(n_events,
                                   always_min     = EXPOSURE_COHORT_CUTS$always,
                                   frequently_min = EXPOSURE_COHORT_CUTS$frequently,
                                   rarely_min     = EXPOSURE_COHORT_CUTS$rarely) {
  stopifnot(rarely_min >= 1, frequently_min > rarely_min, always_min > frequently_min)
  breaks <- c(-Inf, rarely_min - 1, frequently_min - 1, always_min - 1, Inf)
  factor(
    cut(n_events, breaks = breaks,
        labels = c("Never", "Rarely", "Frequently", "Always"),
        right = TRUE),
    levels = c("Never", "Rarely", "Frequently", "Always")
  )
}
