# Phase 2 (Task 2f, plots): forest plots summarizing the mechanism regressions.
# Track: mechanism_channels_20260625.  Run: Rscript Code/run_mechanism_synthesis.R
#
# Reads the four Phase-2 coefficient CSVs and renders base-R forest plots (no ggplot
# dependency) to Analysis/mechanism/plots/. The written verdict lives in
# Analysis/mechanism/mechanism_verdict.md (authored alongside).
#
#   fig_medicare_morbidity.png  : heat/cold/AQI -> Medicare std spending & ED visits (overall)
#   fig_labor_vs_ag.png         : income/employment -- overall vs bottom-ag-tercile (drought/HDD/CDD)
#   fig_moderator_interactions.png: shock x moderator (Ag_z / Labor_z / EnergyBurden_z) interactions

log_con <- file("Analysis/mechanism/build_logs/run_mechanism_synthesis.log", open = "wt")
sink(log_con, split = TRUE); on.exit({ sink(); close(log_con) }, add = TRUE)
cat("=== run_mechanism_synthesis.R run ===\n")

plotdir <- "Analysis/mechanism/plots"
dir.create(plotdir, showWarnings = FALSE, recursive = TRUE)

rd <- function(p) if (file.exists(p)) read.csv(p, stringsAsFactors = FALSE) else NULL
ag  <- rd("Analysis/mechanism/ag_channel_coefs.csv")
med <- rd("Analysis/mechanism/medicare_channel_coefs.csv")
en  <- rd("Analysis/mechanism/energy_channel_coefs.csv")

# generic horizontal forest plot: estimate +/- 1.96 se, colored by significance
forest <- function(d, labels, title, xlab) {
  d$lo <- d$estimate - 1.96 * d$se; d$hi <- d$estimate + 1.96 * d$se
  n <- nrow(d); y <- n:1
  xlim <- range(c(d$lo, d$hi, 0), na.rm = TRUE)
  col <- ifelse(d$p < 0.05, "firebrick", "grey55")
  par(mar = c(4.5, 16, 3, 1))
  plot(NA, xlim = xlim, ylim = c(0.5, n + 0.5), yaxt = "n", ylab = "",
       xlab = xlab, main = title, cex.main = 0.95)
  abline(v = 0, lty = 2, col = "grey40")
  segments(d$lo, y, d$hi, y, col = col, lwd = 2)
  points(d$estimate, y, pch = 19, col = col, cex = 1.1)
  axis(2, at = y, labels = labels, las = 1, cex.axis = 0.7)
}

# ---- Fig 1: Medicare morbidity (overall) ----------------------------------
if (!is.null(med)) {
  d <- med[med$spec == "overall" &
           med$outcome %in% c("Mdcr_Std_Payment_PC","ER_Visits_per1000"), ]
  d <- d[order(d$outcome, d$shock, d$term), ]
  png(file.path(plotdir, "fig_medicare_morbidity.png"), width = 1100, height = 1300, res = 130)
  forest(d, paste(d$outcome, d$shock, d$term, sep = " | "),
         "Morbidity channel: climate/AQI -> Medicare spending & ED visits (county+year FE)",
         "coefficient (95% CI); red = p<0.05")
  dev.off(); cat("wrote fig_medicare_morbidity.png\n")
}

# ---- Fig 2: labor vs ag (employment & income; overall vs bottom-ag) --------
if (!is.null(ag)) {
  d <- ag[ag$outcome %in% c("Civilian_Employed","PCPI_Real") &
          ((ag$spec == "overall") | (ag$spec == "subsample_bottom" & ag$moderator == "Ag")), ]
  d <- d[order(d$outcome, d$shock, d$term, d$spec), ]
  png(file.path(plotdir, "fig_labor_vs_ag.png"), width = 1150, height = 1600, res = 125)
  forest(d, paste(substr(d$outcome,1,10), d$shock, d$term, d$spec, sep="|"),
         "Income/employment: overall vs bottom-ag-tercile subsample",
         "coefficient (95% CI); red = p<0.05")
  dev.off(); cat("wrote fig_labor_vs_ag.png\n")
}

# ---- Fig 3: moderator interactions (Ag_z / Labor_z / EnergyBurden_z) -------
inter <- list()
if (!is.null(ag)) {
  a <- ag[ag$spec == "interaction" &
          ag$outcome %in% c("Civilian_Employed","PCPI_Real","Medical_Debt_Share"), ]
  if (nrow(a)) inter[[1]] <- data.frame(lab = paste(substr(a$outcome,1,8), a$shock, a$moderator, a$term, sep="|"),
                                        estimate = a$estimate, se = a$se, p = a$p)
}
if (!is.null(en)) {
  e <- en[grepl(":EnergyBurden_z", en$term) &
          en$outcome %in% c("Civilian_Employed","PCPI_Real"), ]
  if (nrow(e)) inter[[length(inter)+1]] <- data.frame(lab = paste(substr(e$outcome,1,8), e$shock, "Energy", e$term, sep="|"),
                                                      estimate = e$estimate, se = e$se, p = e$p)
}
if (length(inter)) {
  d <- do.call(rbind, inter)
  # keep the significant ones to stay legible
  d <- d[d$p < 0.10, ]
  d <- d[order(d$estimate), ]
  png(file.path(plotdir, "fig_moderator_interactions.png"), width = 1150, height = 1400, res = 125)
  names(d)[1] <- "term"
  forest(d, d$term,
         "Shock x moderator interactions (|p|<0.10): does the effect load on Ag / Labor / Energy?",
         "interaction coefficient (95% CI); red = p<0.05")
  dev.off(); cat("wrote fig_moderator_interactions.png\n")
}
cat("Done.\n")
