# plot_horizon_sensitivity.R — figure for the horizon-choice robustness
# (advisor_feedback_20260807, Task 1.4). Reads horizon_sensitivity.csv.
#
# Layout: 2 rows x 3 cols (one column per headline shock->outcome pair).
#   Top row   : DL h=0..2 coefficients across lag depth K=2..5 (dodged dots +
#               95% CI whiskers; sequential single-hue ramp, light->dark = deeper K;
#               K=3 = shipped run_event_study.R depth).
#   Bottom row: LP impulse h=0..5 (points + 95% CI whiskers; per-horizon N beneath).
# OUTPUT: Analysis/plots/advisor_robustness/horizon_sensitivity.png
# R 4.5.2.

d <- read.csv("Analysis/advisor_robustness/horizon_sensitivity.csv")
dir.create("Analysis/plots/advisor_robustness", showWarnings = FALSE, recursive = TRUE)

pairs <- list(
  list(s = "Is_Extreme_Drought", o = "Medical_Debt_Share", lab = "Drought → Med. debt share"),
  list(s = "Is_Extreme_Drought", o = "PCPI_Real",          lab = "Drought → Real PCPI"),
  list(s = "High_HDD",           o = "Civilian_Employed",  lab = "Cold (HDD) → Employment")
)
K_grid  <- 2:5
K_cols  <- c("#c6dbef", "#6baed6", "#3182bd", "#08519c")  # single-hue sequential, light->dark
ink     <- "#333333"; muted <- "#888888"; grid_col <- "#e6e6e6"

png("Analysis/plots/advisor_robustness/horizon_sensitivity.png",
    width = 2400, height = 1500, res = 200)
par(mfrow = c(2, 3), mar = c(4.2, 4.5, 3, 1), oma = c(0, 0, 2.5, 0),
    col.axis = ink, col.lab = ink, col.main = ink, fg = ink)

# --- Top row: DL coefficients vs lag depth K ---
for (p in pairs) {
  dd <- d[d$Approach == "DL" & d$Shock == p$s & d$Outcome == p$o & d$Horizon <= 2, ]
  ylim <- range(c(dd$Estimate - 1.96 * dd$SE, dd$Estimate + 1.96 * dd$SE, 0))
  plot(NA, xlim = c(-0.45, 2.45), ylim = ylim, xaxt = "n", bty = "n",
       xlab = "Event horizon h", ylab = "DL coefficient (95% CI)",
       main = p$lab, cex.main = 1.05, font.main = 1)
  grid(nx = NA, ny = NULL, col = grid_col, lty = 1, lwd = 0.7)
  abline(h = 0, col = muted, lwd = 1)
  axis(1, at = 0:2, labels = 0:2)
  for (ki in seq_along(K_grid)) {
    K <- K_grid[ki]
    dk <- dd[dd$K_or_Hmax == K, ]
    dk <- dk[order(dk$Horizon), ]
    x <- dk$Horizon + (ki - 2.5) * 0.13
    segments(x, dk$Estimate - 1.96 * dk$SE, x, dk$Estimate + 1.96 * dk$SE,
             col = K_cols[ki], lwd = 2)
    points(x, dk$Estimate, pch = 19, col = K_cols[ki], cex = 1.05)
  }
  if (p$s == "Is_Extreme_Drought" && p$o == "Medical_Debt_Share") {
    legend("topleft", legend = paste0("K=", K_grid, ifelse(K_grid == 3, " (shipped)", "")),
           col = K_cols, pch = 19, bty = "n", cex = 0.85, text.col = ink,
           title = "DL lag depth", title.col = ink)
  }
}

# --- Bottom row: LP impulse with extended tail ---
for (p in pairs) {
  dl <- d[d$Approach == "LP" & d$Shock == p$s & d$Outcome == p$o, ]
  dl <- dl[order(dl$Horizon), ]
  lo <- dl$Estimate - 1.96 * dl$SE; hi <- dl$Estimate + 1.96 * dl$SE
  ylim <- range(c(lo, hi, 0))
  ylim[1] <- ylim[1] - 0.14 * diff(ylim)   # room for N labels
  plot(NA, xlim = c(-0.3, 5.3), ylim = ylim, xaxt = "n", bty = "n",
       xlab = "LP horizon h", ylab = "LP coefficient (95% CI)",
       main = "", cex.main = 1)
  grid(nx = NA, ny = NULL, col = grid_col, lty = 1, lwd = 0.7)
  abline(h = 0, col = muted, lwd = 1)
  rect(3.5, par("usr")[3], 5.3, par("usr")[4], col = adjustcolor(grid_col, 0.35),
       border = NA)   # extended-tail region beyond shipped h_max=3
  axis(1, at = 0:5, labels = 0:5)
  lines(dl$Horizon, dl$Estimate, col = "#3182bd", lwd = 2)
  segments(dl$Horizon, lo, dl$Horizon, hi, col = "#3182bd", lwd = 2)
  points(dl$Horizon, dl$Estimate, pch = 19, col = "#3182bd", cex = 1.05)
  text(dl$Horizon, par("usr")[3] + 0.05 * diff(par("usr")[3:4]),
       labels = format(dl$N, big.mark = ","), cex = 0.62, col = muted)
  text(4.4, par("usr")[4] - 0.06 * diff(par("usr")[3:4]),
       "beyond shipped h", cex = 0.7, col = muted)
}

mtext("Horizon-choice robustness: DL lag depth (top) and LP extended tail (bottom); N per LP horizon shown",
      outer = TRUE, cex = 0.85, col = ink)
invisible(dev.off())
cat("Wrote Analysis/plots/advisor_robustness/horizon_sensitivity.png\n")
