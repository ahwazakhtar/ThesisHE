# ===========================================================================
# run_hospital_incidence.R  (Hospital Supply-Side Integration — Phase 2)
#
# Incidence (Paper 1, supply side): do county climate shocks raise hospital
# uncompensated care and compress operating margins?
#
#   Y_{it} ~ Shock_{c(i)t} + Shock_{c(i),t-1} + Shock_{c(i),t-2} | CCN + Year
#   cluster: State
#
# A hospital-fixed-effect distributed-lag impulse response. Shocks are the
# county-level indicators attached in process_hospital_panel.R (a hospital
# inherits its county shock), so this is the supply-side analogue of the
# county event study. Cumulative (contemporaneous + 2 lags) effect reported via
# lincom() from Code/cumulative_dose.R.
# ===========================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
  library(ggplot2)
})
source("Code/cumulative_dose.R")  # lincom()

PANEL_RDS    <- "Data/intermediate_hospital_panel.rds"
OUT_COEFS    <- "Analysis/hospital_incidence_coefs.csv"
OUT_RESULTS  <- "Analysis/hospital_incidence_results.txt"
PLOT_DIR     <- "Analysis/plots/hospital"

SHOCKS   <- c("Is_Extreme_Drought", "High_CDD", "High_HDD", "High_AQI_Max")
OUTCOMES <- c("Hosp_UncompCare_PctNPR", "Hosp_OperatingMargin",
              "Hosp_UncompCare_Real", "Hosp_NetMargin")

# ---------------------------------------------------------------------------
# Fit one distributed-lag model and return tidy per-horizon + cumulative rows.
# ---------------------------------------------------------------------------
fit_incidence_dl <- function(df, outcome, shock, cluster_var = "State") {
  lags  <- c(paste0(shock, "_Lag1"), paste0(shock, "_Lag2"))
  terms <- c(shock, lags[lags %in% names(df)])
  rhs   <- paste(terms, collapse = " + ")
  f     <- stats::as.formula(paste0(outcome, " ~ ", rhs, " | CCN + Year"))

  m <- tryCatch(
    fixest::feols(f, data = df, cluster = stats::as.formula(paste0("~", cluster_var))),
    error = function(e) { cat("    Error:", conditionMessage(e), "\n"); NULL }
  )
  if (is.null(m)) return(NULL)

  ct <- as.data.frame(fixest::coeftable(m))
  ct$term <- rownames(ct)
  horizon_of <- function(t) if (t == shock) 0L else as.integer(sub(".*_Lag", "", t))
  rows <- lapply(terms, function(t) {
    r <- ct[ct$term == t, , drop = FALSE]
    if (nrow(r) == 0) return(NULL)
    data.frame(shock = shock, outcome = outcome, term = t, horizon = horizon_of(t),
               estimate = r[["Estimate"]], std.error = r[["Std. Error"]],
               p.value = r[["Pr(>|t|)"]],
               ci_low = r[["Estimate"]] - 1.96 * r[["Std. Error"]],
               ci_high = r[["Estimate"]] + 1.96 * r[["Std. Error"]],
               N = nobs(m), n_hosp = m$fixef_sizes[["CCN"]],
               stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)

  # Cumulative effect = sum of contemporaneous + lag coefficients
  w <- setNames(rep(1, length(terms)), terms)
  lc <- lincom(m, w)
  if (!is.null(lc)) {
    out <- rbind(out, data.frame(
      shock = shock, outcome = outcome, term = "Cumulative", horizon = 99L,
      estimate = lc$estimate, std.error = lc$std.error, p.value = lc$p.value,
      ci_low = lc$estimate - 1.96 * lc$std.error,
      ci_high = lc$estimate + 1.96 * lc$std.error,
      N = nobs(m), n_hosp = m$fixef_sizes[["CCN"]], stringsAsFactors = FALSE))
  }
  out
}

# ---------------------------------------------------------------------------
if (sys.nframe() == 0L) {
  dir.create("Analysis", showWarnings = FALSE)
  dir.create(PLOT_DIR, showWarnings = FALSE, recursive = TRUE)

  cat("Loading hospital panel...\n")
  df <- readRDS(PANEL_RDS)
  df$State <- as.factor(df$State)
  df$CCN   <- as.factor(df$CCN)

  shocks   <- SHOCKS[SHOCKS %in% names(df)]
  outcomes <- OUTCOMES[OUTCOMES %in% names(df)]
  cat("Shocks:", paste(shocks, collapse = ", "), "\n")
  cat("Outcomes:", paste(outcomes, collapse = ", "), "\n")

  all_rows <- list()
  sink(OUT_RESULTS)
  cat("=== Hospital Incidence: distributed-lag IRF (hospital + year FE) ===\n\n")
  for (s in shocks) {
    for (o in outcomes) {
      res <- fit_incidence_dl(df, o, s)
      if (!is.null(res)) {
        all_rows[[length(all_rows) + 1]] <- res
        cat(sprintf("\n--- %s -> %s ---\n", s, o))
        print(res[, c("term", "horizon", "estimate", "std.error", "p.value")], row.names = FALSE)
      }
    }
  }
  sink()

  coefs <- dplyr::bind_rows(all_rows)
  write.csv(coefs, OUT_COEFS, row.names = FALSE)
  cat("Saved coefficients to:", OUT_COEFS, "(", nrow(coefs), "rows )\n")

  # IRF plots (per-horizon, excluding the cumulative summary row)
  cat("Generating plots...\n")
  irf <- coefs %>% filter(horizon < 90)
  for (s in shocks) {
    for (o in outcomes) {
      sub <- irf %>% filter(shock == s, outcome == o)
      if (nrow(sub) == 0) next
      p <- ggplot(sub, aes(x = horizon, y = estimate)) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
        geom_pointrange(aes(ymin = ci_low, ymax = ci_high), size = 0.5) +
        scale_x_continuous(breaks = 0:2) +
        labs(title = paste("Hospital incidence:", s, "->", o),
             subtitle = "Distributed-lag effect (hospital + year FE, state-clustered)",
             x = "Years since shock (lag)", y = "Estimate") +
        theme_minimal(base_size = 12) +
        theme(plot.background = element_rect(fill = "white", color = NA),
              panel.background = element_rect(fill = "white", color = NA))
      ggsave(file.path(PLOT_DIR, paste0("incidence_", s, "_", o, ".png")),
             p, width = 7, height = 5, dpi = 150, bg = "white")
    }
  }

  # Headline summary
  cat("\n=== Headline cumulative effects (sum of h=0,1,2) ===\n")
  head_tbl <- coefs %>%
    filter(term == "Cumulative") %>%
    mutate(sig = ifelse(p.value < 0.05, "*", "")) %>%
    select(shock, outcome, estimate, std.error, p.value, sig)
  print(as.data.frame(head_tbl), row.names = FALSE)
  cat("\nDone.\n")
}
