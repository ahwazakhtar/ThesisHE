# =============================================================================
# create_fig_conceptual_model.R  (thesis_completion_20260704 — Essay 1 §2)
# =============================================================================
# Builds E1-F0, the conceptual-model schematic for Essay 1 §2 ¶1.
#
# SOURCE: the author's slide "How Climate Shocks Reach Your Wallet"
# (Text/presentations/seminar_presentation_20260406.tex) — the three-column
# transmission chain: climate shock -> health utilisation -> financial outcome.
#
# EXTENDED 2026-08-18 (author request) with the DIRECT channel, which is the
# claim Essay 1 actually leads with:
#   - a Medicare ledger box, the outcome measured in administrative records
#   - a direct path from the health hazards straight to that ledger, bypassing
#     the mechanism column, because the essay observes the cost without
#     observing (or needing) an intervening mechanism
#   - the mediated paths kept and visually distinguished, so the figure shows
#     both regimes rather than replacing one with the other
#
# Column 1 is ordered so the three hazards with a direct channel (cold, heat,
# air quality) are contiguous and can share one bracket; drought sits below
# because its route to the ledgers runs through farm income. Column 2 is
# reordered to match, which keeps the mediated arrows from crossing.
#
# The slide is TikZ; this TinyTeX has no pgf/tikz and tlmgr will not install
# without a self-update, so the figure is drawn in R and emitted as a PNG.
#
# ENV: R 4.5.2.  Rscript Code/create_fig_conceptual_model.R
# OUTPUT: Analysis/descriptive/fig_conceptual_model.png
# =============================================================================

suppressPackageStartupMessages({ library(ggplot2) })

OUT <- "Analysis/descriptive/fig_conceptual_model.png"

NAVY <- "#1F3A5F"; GREY <- "#6B7280"; DIRECT <- "#1B5E88"

# --- geometry -----------------------------------------------------------
CX <- c(1.45, 5.60, 10.10)
HW <- c(1.30, 1.65, 1.75)
BH <- 0.44
stopifnot(CX[2] - HW[2] - (CX[1] + HW[1]) > 0.7,
          CX[3] - HW[3] - (CX[2] + HW[2]) > 0.7)

boxes <- rbind(
  # column 1 — climate shocks. Direct-channel hazards first and contiguous.
  data.frame(col = 1, id = "cold",    y =  1.80, bold = "Cold / HDD",
             detail = "extreme cold year", fill = "#DCEAE8", border = "#2E7D77"),
  data.frame(col = 1, id = "heat",    y =  0.60, bold = "Heat / CDD",
             detail = "extreme hot year", fill = "#FBF0D9", border = "#B8862B"),
  data.frame(col = 1, id = "aqi",     y = -0.60, bold = "Poor air quality",
             detail = "max AQI above 100", fill = "#E7E1F0", border = "#6B5B95"),
  data.frame(col = 1, id = "drought", y = -1.80, bold = "Drought",
             detail = "PDSI at or below -4", fill = "#F7DEDA", border = "#B4553F"),
  # column 2 — mechanisms, ordered to match column 1
  data.frame(col = 2, id = "util1",   y =  1.20, bold = "Emergency visits rise",
             detail = "respiratory, cardiac", fill = "#EEF0F2", border = GREY),
  data.frame(col = 2, id = "util3",   y = -0.60, bold = "Respiratory admissions",
             detail = "hospital inpatient", fill = "#EEF0F2", border = GREY),
  data.frame(col = 2, id = "util2",   y = -1.80, bold = "Income and crops fall",
             detail = "stress illness rises", fill = "#EEF0F2", border = GREY),
  # column 3 — ledgers. Medicare added on top as the directly-measured one.
  data.frame(col = 3, id = "mcare",   y =  3.05, bold = "Medicare cost, ED visits",
             detail = "CMS administrative records", fill = "#DCEAE8", border = DIRECT),
  data.frame(col = 3, id = "prem",    y =  1.80, bold = "Insurance premiums rise",
             detail = "ACA rating areas", fill = "#F6EBD6", border = "#B8862B"),
  data.frame(col = 3, id = "debt",    y =  0.60, bold = "Medical debt accumulates",
             detail = "credit bureaus", fill = "#F6EBD6", border = "#B8862B"),
  data.frame(col = 3, id = "bad",     y = -0.60, bold = "Hospital bad debt",
             detail = "uncompensated care", fill = "#F6EBD6", border = "#B8862B"),
  data.frame(col = 3, id = "inc",     y = -1.80, bold = "Household income falls",
             detail = "BEA county accounts", fill = "#F6EBD6", border = "#B8862B"),
  stringsAsFactors = FALSE)
boxes$x <- CX[boxes$col]; boxes$hw <- HW[boxes$col]
pos <- function(id) boxes[boxes$id == id, ][1, ]

# --- mediated arrows (as on the slide) ----------------------------------
LINKS <- list(c("cold","util1"), c("heat","util1"), c("aqi","util3"),
              c("drought","util2"),
              c("util1","prem"), c("util1","debt"), c("util1","bad"),
              c("util3","bad"), c("util3","prem"), c("util2","inc"))
arr <- do.call(rbind, lapply(LINKS, function(l) {
  a <- pos(l[1]); b <- pos(l[2])
  data.frame(x = a$x + a$hw + 0.06, y = a$y,
             xend = b$x - b$hw - 0.06, yend = b$y)
}))

# --- direct channel ------------------------------------------------------
# One bracket gathers the three hazards that reach Medicare without an
# intervening mechanism; a single arc then carries them over the mechanism
# column. Three separate arrows would have to cross the middle boxes.
XB <- CX[1] + HW[1] + 0.52
# Stubs leave the UPPER part of each box edge (offset DY) so they do not run
# along the mediated arrows, which leave from the box centre.
DY <- 0.22
ytop <- pos("cold")$y + DY; ybot <- pos("aqi")$y + DY
bracket <- data.frame(x = XB, xend = XB, y = ybot, yend = ytop)
stubs <- do.call(rbind, lapply(c("cold","heat","aqi"), function(id) {
  a <- pos(id)
  data.frame(x = a$x + a$hw + 0.06, y = a$y + DY, xend = XB, yend = a$y + DY)
}))
mc <- pos("mcare")
direct <- data.frame(x = XB, y = mean(c(ytop, ybot)),
                     xend = mc$x - mc$hw - 0.08, yend = mc$y)

HEAD <- data.frame(x = CX, y = 4.15,
                   lab = c("Climate shock", "Health utilisation", "Financial ledger"))

p <- ggplot() +
  # mediated paths first, so the direct arc sits on top
  geom_segment(data = arr, aes(x = x, y = y, xend = xend, yend = yend),
               arrow = arrow(length = unit(0.13, "cm"), type = "closed"),
               linewidth = 0.42, colour = GREY) +
  geom_segment(data = stubs, aes(x = x, y = y, xend = xend, yend = yend),
               linewidth = 0.5, colour = DIRECT) +
  geom_segment(data = bracket, aes(x = x, y = y, xend = xend, yend = yend),
               linewidth = 0.5, colour = DIRECT) +
  geom_curve(data = direct, aes(x = x, y = y, xend = xend, yend = yend),
             curvature = -0.30, linewidth = 0.85, colour = DIRECT,
             arrow = arrow(length = unit(0.17, "cm"), type = "closed")) +
  geom_rect(data = boxes,
            aes(xmin = x - hw, xmax = x + hw, ymin = y - BH, ymax = y + BH),
            fill = boxes$fill, colour = boxes$border, linewidth = 0.6) +
  geom_text(data = boxes, aes(x = x, y = y + 0.13, label = bold),
            fontface = "bold", size = 2.75, colour = NAVY) +
  geom_text(data = boxes, aes(x = x, y = y - 0.17, label = detail),
            size = 2.4, colour = "#3A3A3A") +
  geom_text(data = HEAD, aes(x = x, y = y, label = lab),
            fontface = "italic", size = 2.9, colour = GREY) +
  # legend, written directly onto the panel
  annotate("text", x = 5.15, y = 3.32, label = "direct effect: cost observed without an intervening mechanism",
           size = 2.45, fontface = "italic", colour = DIRECT, hjust = 0.5) +
  annotate("segment", x = 2.35, xend = 3.05, y = -2.62, yend = -2.62,
           linewidth = 0.42, colour = GREY,
           arrow = arrow(length = unit(0.11, "cm"), type = "closed")) +
  annotate("text", x = 3.20, y = -2.62, label = "mediated", size = 2.5,
           colour = GREY, hjust = 0) +
  annotate("segment", x = 5.30, xend = 6.00, y = -2.62, yend = -2.62,
           linewidth = 0.85, colour = DIRECT,
           arrow = arrow(length = unit(0.13, "cm"), type = "closed")) +
  annotate("text", x = 6.15, y = -2.62, label = "direct", size = 2.5,
           colour = DIRECT, hjust = 0) +
  coord_cartesian(xlim = c(0.0, 11.95), ylim = c(-2.95, 4.45), expand = FALSE) +
  theme_void() +
  theme(plot.margin = margin(4, 4, 4, 4))

ggsave(OUT, p, width = 9.0, height = 5.4, dpi = 300, bg = "white")
cat("wrote", OUT, "\n")
