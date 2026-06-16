# ===========================================================================
# run_hospital_heterogeneity.R  (Hospital Supply-Side Integration — Phase 4)
#   PRIMARY analysis for this track.
#
# Provider heterogeneity (Paper 3, supply side): does climate-driven hospital
# strain CONCENTRATE in vulnerable providers? The supply-side analogue of the
# demand-side SVI amplification. For each moderator M, fit
#
#   Y_{it} ~ Shock_{c(i)t} * M_{it} | CCN + Year     (cluster State)
#
# and read off the MARGINAL shock effect at each level of M. Moderators:
#   - SafetyNet           (top-quartile Medicaid + uncompensated payer mix)
#   - Ownership           (Non-Profit ref / For-Profit / Government)
#   - MedicaidExpansion   (state-year ACA expansion; vulnerable = NON-expansion)
#   - HighConcentration   (county HHI >= 0.25; built here from NPR shares)
#
# Outcomes (the two Ch.2 headlines): Hosp_UncompCare_PctNPR, Hosp_OperatingMargin.
#
# Verdict is OUTCOME-AWARE: for uncompensated care %NPR a MORE POSITIVE shock
# effect = more strain; for operating margin a MORE NEGATIVE effect = more strain.
# ===========================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
  library(ggplot2)
})
source("Code/cumulative_dose.R")  # lincom()

PANEL_RDS <- "Data/intermediate_hospital_panel.rds"
OUT_COEFS <- "Analysis/hospital_heterogeneity_coefs.csv"
OUT_RES   <- "Analysis/hospital_heterogeneity_results.txt"
PLOT_DIR  <- "Analysis/plots/hospital"

SHOCKS   <- c("Is_Extreme_Drought", "High_CDD", "High_HDD")
OUTCOMES <- c("Hosp_UncompCare_PctNPR", "Hosp_OperatingMargin")

# ---------------------------------------------------------------------------
# County-year market concentration (Herfindahl-Hirschman Index).
# Firm = Health System where affiliated (SystemID), else the standalone hospital
# (CCN). Share = firm Net Patient Revenue / total county-year NPR. HHI in [0,1]
# (1 = monopoly). A county-year needs >=1 firm with positive NPR.
# ---------------------------------------------------------------------------
compute_hhi <- function(df) {
  d <- df %>%
    mutate(firm = ifelse(!is.na(SystemAffiliated) & SystemAffiliated == 1 &
                           !is.na(SystemID) & SystemID != "", paste0("SYS_", SystemID),
                         paste0("CCN_", CCN)),
           npr = Hosp_NetPatientRevenue) %>%
    filter(!is.na(fips_code), !is.na(npr), npr > 0)
  firm_rev <- d %>%
    group_by(fips_code, Year, firm) %>%
    summarise(firm_npr = sum(npr), .groups = "drop")
  firm_rev %>%
    group_by(fips_code, Year) %>%
    summarise(MarketConcentration = sum((firm_npr / sum(firm_npr))^2),
              n_firms = dplyr::n(), .groups = "drop")
}

# Marginal shock effect at each level of a BINARY moderator (0/1) from a fitted
# Shock*M interaction model: level 0 = b[shock]; level 1 = b[shock] + b[shock:M].
marginal_binary <- function(model, shock, inter, mod_name) {
  if (is.null(model)) return(NULL)
  b <- coef(model)
  if (!shock %in% names(b)) return(NULL)
  out <- list()
  # level 0
  lc0 <- lincom(model, setNames(1, shock))
  out[[1]] <- data.frame(moderator = mod_name, level = "0", estimate = lc0$estimate,
                         std.error = lc0$std.error, p.value = lc0$p.value,
                         stringsAsFactors = FALSE)
  # level 1
  if (inter %in% names(b)) {
    lc1 <- lincom(model, setNames(c(1, 1), c(shock, inter)))
    out[[2]] <- data.frame(moderator = mod_name, level = "1", estimate = lc1$estimate,
                           std.error = lc1$std.error, p.value = lc1$p.value,
                           stringsAsFactors = FALSE)
    # interaction (difference, level1 - level0)
    bi <- as.data.frame(coeftable(model)); bi$t <- rownames(bi)
    ir <- bi[bi$t == inter, ]
    attr(out, "interaction") <- data.frame(estimate = ir[["Estimate"]],
                                            std.error = ir[["Std. Error"]],
                                            p.value = ir[["Pr(>|t|)"]])
  }
  res <- do.call(rbind, out)
  attr(res, "interaction") <- attr(out, "interaction")
  res
}

# Outcome-aware verdict: is the shock effect WORSE (more strain) in the
# "vulnerable" level of the moderator?
strain_verdict <- function(outcome, est_vuln, est_other) {
  if (any(is.na(c(est_vuln, est_other)))) return(NA_character_)
  worse_if_higher <- grepl("UncompCare", outcome)  # higher uncompensated = worse
  more_strain <- if (worse_if_higher) est_vuln > est_other else est_vuln < est_other
  if (more_strain) "strain concentrates in vulnerable" else "no concentration / reversed"
}

# ---------------------------------------------------------------------------
if (sys.nframe() == 0L) {
  dir.create("Analysis", showWarnings = FALSE)
  dir.create(PLOT_DIR, showWarnings = FALSE, recursive = TRUE)

  cat("Loading hospital panel...\n")
  df <- readRDS(PANEL_RDS)

  # --- Market concentration ------------------------------------------------
  cat("Building county-year market concentration (HHI)...\n")
  hhi <- compute_hhi(df)
  df <- df %>% left_join(hhi, by = c("fips_code", "Year"))
  df$HighConcentration <- as.integer(df$MarketConcentration >= 0.25)  # DOJ "concentrated"
  cat(sprintf("  HHI: median=%.3f, %% county-years concentrated (>=0.25)=%.1f%%\n",
              median(df$MarketConcentration, na.rm = TRUE),
              100 * mean(df$HighConcentration, na.rm = TRUE)))

  df$State <- as.factor(df$State); df$CCN <- as.factor(df$CCN)

  shocks   <- SHOCKS[SHOCKS %in% names(df)]
  outcomes <- OUTCOMES[OUTCOMES %in% names(df)]
  binary_mods <- c("SafetyNet", "MedicaidExpansion", "HighConcentration")
  binary_mods <- binary_mods[binary_mods %in% names(df)]

  rows <- list(); inter_rows <- list()
  sink(OUT_RES)
  cat("=== Hospital Heterogeneity: Shock x Moderator (hospital + year FE) ===\n")

  # --- Binary moderators ---------------------------------------------------
  for (s in shocks) {
    for (o in outcomes) {
      for (M in binary_mods) {
        inter <- paste0(s, ":", M)
        f <- stats::as.formula(paste0(o, " ~ ", s, " * ", M, " | CCN + Year"))
        m <- tryCatch(feols(f, data = df, cluster = ~State), error = function(e) NULL)
        if (is.null(m)) next
        mb <- marginal_binary(m, s, inter, M)
        if (is.null(mb)) next
        ir <- attr(mb, "interaction")
        # vulnerable level: for MedicaidExpansion the vulnerable group is 0
        vuln_level <- if (M == "MedicaidExpansion") "0" else "1"
        other_level <- if (vuln_level == "1") "0" else "1"
        est_v <- mb$estimate[mb$level == vuln_level]
        est_o <- mb$estimate[mb$level == other_level]
        verdict <- strain_verdict(o, est_v, est_o)
        cat(sprintf("\n-- %s x %s -> %s --\n", s, M, o))
        print(mb[, c("level", "estimate", "p.value")], row.names = FALSE)
        cat(sprintf("   interaction p=%.4f | verdict: %s\n",
                    if (!is.null(ir)) ir$p.value else NA, verdict))
        mb$shock <- s; mb$outcome <- o
        mb$interaction_est <- if (!is.null(ir)) ir$estimate else NA
        mb$interaction_p   <- if (!is.null(ir)) ir$p.value else NA
        mb$verdict <- verdict
        rows[[length(rows) + 1]] <- mb
      }
    }
  }

  # --- Ownership (3-level factor) -----------------------------------------
  if ("Ownership" %in% names(df)) {
    for (s in shocks) {
      for (o in outcomes) {
        f <- stats::as.formula(paste0(o, " ~ ", s, " * Ownership | CCN + Year"))
        m <- tryCatch(feols(f, data = df, cluster = ~State), error = function(e) NULL)
        if (is.null(m)) next
        b <- coef(m)
        levs <- c("Non-Profit", "For-Profit", "Government")
        cat(sprintf("\n-- %s x Ownership -> %s --\n", s, o))
        for (lev in levs) {
          if (lev == "Non-Profit") {
            lc <- lincom(m, setNames(1, s))
          } else {
            it <- paste0(s, ":Ownership", lev)
            if (!it %in% names(b)) next
            lc <- lincom(m, setNames(c(1, 1), c(s, it)))
          }
          if (is.null(lc)) next
          rows[[length(rows) + 1]] <- data.frame(
            moderator = "Ownership", level = lev, estimate = lc$estimate,
            std.error = lc$std.error, p.value = lc$p.value, shock = s, outcome = o,
            interaction_est = NA, interaction_p = NA, verdict = NA_character_,
            stringsAsFactors = FALSE)
          cat(sprintf("   %-11s marginal=%.5f (p=%.4f)\n", lev, lc$estimate, lc$p.value))
        }
      }
    }
  }
  sink()

  coefs <- dplyr::bind_rows(rows)
  write.csv(coefs, OUT_COEFS, row.names = FALSE)
  cat("Saved coefficients to:", OUT_COEFS, "(", nrow(coefs), "rows )\n")

  # --- Plots: marginal shock effect by moderator level --------------------
  cat("Generating heterogeneity plots...\n")
  for (M in unique(coefs$moderator)) {
    for (o in outcomes) {
      sub <- coefs %>% filter(moderator == M, outcome == o)
      if (nrow(sub) == 0) next
      sub$ci_low <- sub$estimate - 1.96 * sub$std.error
      sub$ci_high <- sub$estimate + 1.96 * sub$std.error
      p <- ggplot(sub, aes(x = level, y = estimate, color = shock)) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
        geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                        position = position_dodge(width = 0.4), size = 0.5) +
        labs(title = paste("Marginal shock effect by", M),
             subtitle = paste("Outcome:", o, "(hospital + year FE)"),
             x = M, y = "Marginal shock effect", color = "Shock") +
        theme_minimal(base_size = 12) +
        theme(plot.background = element_rect(fill = "white", color = NA),
              panel.background = element_rect(fill = "white", color = NA))
      ggsave(file.path(PLOT_DIR, paste0("heterogeneity_", M, "_", o, ".png")),
             p, width = 8, height = 5, dpi = 150, bg = "white")
    }
  }

  cat("\n=== Heterogeneity verdicts (binary moderators) ===\n")
  vt <- coefs %>% filter(!is.na(verdict)) %>%
    distinct(shock, outcome, moderator, interaction_p, verdict)
  print(as.data.frame(vt), row.names = FALSE)
  cat("\nDone.\n")
}
