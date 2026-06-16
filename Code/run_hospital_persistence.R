# ===========================================================================
# run_hospital_persistence.R  (Hospital Supply-Side Integration — Phase 3)
#
# Persistence (Paper 2, supply side): do climate-driven hospital-finance hits
# SCAR (persist after the shock clears) or COMPOUND (accumulate with repeated
# exposure)?  Two complementary lenses on {Hosp_UncompCare_PctNPR,
# Hosp_OperatingMargin}, hospital + year FE, state-clustered:
#
#   (A) Onset / Persist / Exit symmetry (reuse transition_symmetry.R).
#       lead(Y,h) ~ Onset + Persist + Exit | CCN + Year, then test
#       H0: beta_Onset + beta_Exit = 0. Rejection => hysteresis/scarring.
#
#   (B) Cumulative dose (reuse cumulative_dose.R). Running count of climate
#       shock-years per hospital -> linear + quadratic dose-response and a
#       high-vs-low contrast (10+ vs 1-3 cumulative years) via lincom().
# ===========================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
})
source("Code/transition_symmetry.R")  # transition_symmetry_test()
source("Code/cumulative_dose.R")      # add_cumulative_shock_years(), lincom()

PANEL_RDS   <- "Data/intermediate_hospital_panel.rds"
OUT_COEFS   <- "Analysis/hospital_persistence_coefs.csv"
OUT_RESULTS <- "Analysis/hospital_persistence_results.txt"

OUTCOMES <- c("Hosp_UncompCare_PctNPR", "Hosp_OperatingMargin")
SHOCKS   <- c("Is_Extreme_Drought", "High_CDD", "High_HDD")
HORIZONS <- 0:2

# Build Onset / Persist / Exit transition dummies from a binary shock and its
# 1-year lag (the county shock the hospital inherits). 0->1 onset, 1->1 persist,
# 1->0 exit; the omitted reference is 0->0 (never in shock this/last year).
make_transitions <- function(df, shock, ccn_col = "CCN", year_col = "Year") {
  lag1 <- paste0(shock, "_Lag1")
  stopifnot(all(c(shock, lag1, ccn_col, year_col) %in% names(df)))
  s  <- as.integer(df[[shock]]); l <- as.integer(df[[lag1]])
  na_mask <- is.na(s) | is.na(l)  # transition undefined when this/last year unknown
  onset   <- as.integer(s == 1 & l == 0); onset[na_mask]   <- NA_integer_
  persist <- as.integer(s == 1 & l == 1); persist[na_mask] <- NA_integer_
  exit    <- as.integer(s == 0 & l == 1); exit[na_mask]    <- NA_integer_
  df[[paste0(shock, "_Onset")]]   <- onset
  df[[paste0(shock, "_Persist")]] <- persist
  df[[paste0(shock, "_Exit")]]    <- exit
  df
}

# ---------------------------------------------------------------------------
if (sys.nframe() == 0L) {
  dir.create("Analysis", showWarnings = FALSE)
  cat("Loading hospital panel...\n")
  df <- readRDS(PANEL_RDS)
  df <- df %>% arrange(CCN, Year)
  df$State <- as.factor(df$State); df$CCN <- as.factor(df$CCN)

  shocks   <- SHOCKS[SHOCKS %in% names(df)]
  outcomes <- OUTCOMES[OUTCOMES %in% names(df)]

  # Outcome leads for horizon h
  for (o in outcomes) {
    for (h in HORIZONS) {
      df <- df %>% group_by(CCN) %>% arrange(Year) %>%
        mutate(!!paste0(o, "_fwd", h) := dplyr::lead(.data[[o]], h)) %>% ungroup()
    }
  }
  # Transition dummies
  for (s in shocks) df <- make_transitions(df, s)

  clu <- ~State
  rows <- list()
  sink(OUT_RESULTS)
  cat("=== Hospital Persistence ===\n")

  # (A) Onset/Persist/Exit symmetry --------------------------------------
  cat("\n## (A) Onset / Persist / Exit symmetry\n")
  for (s in shocks) {
    onset <- paste0(s, "_Onset"); persist <- paste0(s, "_Persist"); exit <- paste0(s, "_Exit")
    for (o in outcomes) {
      for (h in HORIZONS) {
        dep <- paste0(o, "_fwd", h)
        f <- stats::as.formula(paste0(dep, " ~ ", onset, " + ", persist, " + ", exit,
                                      " | CCN + Year"))
        m <- tryCatch(feols(f, data = df, cluster = clu), error = function(e) NULL)
        if (is.null(m)) next
        b <- coef(m)
        sym <- transition_symmetry_test(m, onset, exit)
        cat(sprintf("\n-- %s -> %s (h=%d) --\n", s, o, h))
        print(round(b, 5))
        if (!is.null(sym)) {
          cat(sprintf("   onset+exit asymmetry = %.5f (p=%.4f) %s\n",
                      sym$asymmetry, sym$p.value,
                      ifelse(sym$reject_symmetry, "[ASYMMETRIC -> scarring]", "")))
          rows[[length(rows) + 1]] <- data.frame(
            analysis = "symmetry", shock = s, outcome = o, horizon = h,
            beta_onset = sym$beta_onset, beta_exit = sym$beta_exit,
            beta_persist = unname(b[persist]),
            asymmetry = sym$asymmetry, std.error = sym$std.error,
            p.value = sym$p.value, reject_symmetry = sym$reject_symmetry,
            N = nobs(m), stringsAsFactors = FALSE)
        }
      }
    }
  }

  # (B) Cumulative dose ----------------------------------------------------
  cat("\n## (B) Cumulative climate-shock-years dose-response\n")
  df$Any_Climate_Shock <- as.integer(
    (df$Is_Extreme_Drought == 1) %in% TRUE |
    (df$High_CDD == 1) %in% TRUE |
    (df$High_HDD == 1) %in% TRUE)
  df <- add_cumulative_shock_years(df, "Any_Climate_Shock", "Cum_Shock_Years",
                                   fips_col = "CCN", year_col = "Year")
  # Dose bins (reference = 0 cumulative shock-years)
  df$Dose_Bin <- cut(df$Cum_Shock_Years, breaks = c(-Inf, 0, 3, 6, 9, Inf),
                     labels = c("0", "1-3", "4-6", "7-9", "10+"))
  df$Dose_Bin <- relevel(factor(df$Dose_Bin), ref = "0")

  for (o in outcomes) {
    # Linear + quadratic
    fq <- stats::as.formula(paste0(o, " ~ Cum_Shock_Years + I(Cum_Shock_Years^2) | CCN + Year"))
    mq <- tryCatch(feols(fq, data = df, cluster = clu), error = function(e) NULL)
    # Binned
    fb <- stats::as.formula(paste0(o, " ~ Dose_Bin | CCN + Year"))
    mb <- tryCatch(feols(fb, data = df, cluster = clu), error = function(e) NULL)

    cat(sprintf("\n-- Dose-response: %s --\n", o))
    if (!is.null(mq)) {
      print(round(coef(mq), 6))
      # Marginal effect at dose = 5 and 10:  b1 + 2 b2 x
      for (x in c(5, 10)) {
        lc <- lincom(mq, c(Cum_Shock_Years = 1, `I(Cum_Shock_Years^2)` = 2 * x))
        if (!is.null(lc)) {
          rows[[length(rows) + 1]] <- data.frame(
            analysis = "dose_marginal", shock = "Any_Climate", outcome = o,
            horizon = x, beta_onset = NA, beta_exit = NA, beta_persist = NA,
            asymmetry = lc$estimate, std.error = lc$std.error, p.value = lc$p.value,
            reject_symmetry = NA, N = nobs(mq), stringsAsFactors = FALSE)
          cat(sprintf("   marginal effect at dose=%d: %.6f (p=%.4f)\n", x, lc$estimate, lc$p.value))
        }
      }
    }
    if (!is.null(mb)) {
      bb <- coef(mb)
      cat("   binned (vs 0 yrs):\n"); print(round(bb, 6))
      # High-vs-low contrast: 10+ minus 1-3
      if (all(c("Dose_Bin10+", "Dose_Bin1-3") %in% names(bb))) {
        lc <- lincom(mb, setNames(c(1, -1), c("Dose_Bin10+", "Dose_Bin1-3")))
        if (!is.null(lc)) {
          rows[[length(rows) + 1]] <- data.frame(
            analysis = "dose_high_vs_low", shock = "Any_Climate", outcome = o,
            horizon = NA, beta_onset = NA, beta_exit = NA, beta_persist = NA,
            asymmetry = lc$estimate, std.error = lc$std.error, p.value = lc$p.value,
            reject_symmetry = NA, N = nobs(mb), stringsAsFactors = FALSE)
          cat(sprintf("   10+ vs 1-3 contrast: %.6f (p=%.4f)\n", lc$estimate, lc$p.value))
        }
      }
    }
  }
  sink()

  coefs <- dplyr::bind_rows(rows)
  write.csv(coefs, OUT_COEFS, row.names = FALSE)
  cat("Saved coefficients to:", OUT_COEFS, "(", nrow(coefs), "rows )\n")
  cat("Results written to:", OUT_RESULTS, "\n")

  cat("\n=== Symmetry verdict (h=0) ===\n")
  v <- coefs %>% filter(analysis == "symmetry", horizon == 0) %>%
    mutate(verdict = ifelse(reject_symmetry, "ASYMMETRIC (scar)", "symmetric")) %>%
    select(shock, outcome, beta_onset, beta_exit, asymmetry, p.value, verdict)
  print(as.data.frame(v), row.names = FALSE)
}
