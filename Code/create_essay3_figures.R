# =============================================================================
# create_essay3_figures.R  (thesis_completion_20260704 — Essay 3)
# =============================================================================
# Manuscript versions of the two Essay-3 figures that until now were shipped as
# the raw diagnostic plots written by the estimation scripts:
#
#   E3-F2  Analysis/plots/essay3/fig_svi_marginal_effects.png
#          replaces Analysis/plots/exposure_index/interaction_Civilian_Employed.png
#   E3-F4  Analysis/plots/essay3/fig_safetynet_uncompensated_care.png
#          replaces Analysis/plots/hospital/heterogeneity_SafetyNet_Hosp_UncompCare_PctNPR.png
#
# The diagnostics were built to be read by the analyst who ran them: their axes
# carried panel column names (Civilian_Employed, Hosp_UncompCare_PctNPR,
# High_CDD, Is_Extreme_Drought), the safety-net axis was an unlabelled 0/1, and
# nothing on the page said what the estimate meant. Nothing here is
# re-estimated: both figures read the same committed coefficient files that
# E3-T2 and E3-T4 read, so a figure and its table can never disagree.
#
# ENV: R 4.5.2.  Rscript Code/create_essay3_figures.R
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(ggplot2)
})

OUT_DIR <- "Analysis/plots/essay3"
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

rd <- function(p) { if (!file.exists(p)) stop("missing input: ", p); read.csv(p, stringsAsFactors = FALSE) }

# Shared plain-language vocabulary. These MUST match the labels used by
# create_essay23_exhibits.R for E3-T2 / E3-T4, or figure and table will name the
# same quantity differently.
EI_SHOCK <- c(Heat_CDD = "Extreme heat",
              Cold_HDD = "Extreme cold",
              Cold_CumYears = "Cumulative cold-years",
              Drought = "Extreme drought",
              Drought_Lag2 = "Extreme drought\n(2-year lag)")
OUT_LAB <- c(Civilian_Employed = "Employment (persons)",
             PCPI_Real = "Per-capita income ($/yr)",
             Med_HH_Income_Real = "Median household income ($/yr)",
             Benchmark_Silver_Real = "Benchmark premium ($/month)",
             Medical_Debt_Share = "Medical debt share (share of adults)")

star <- function(p) ifelse(is.na(p), "", ifelse(p < 0.001, "***",
                    ifelse(p < 0.01, "**", ifelse(p < 0.05, "*",
                    ifelse(p < 0.1, "†", "")))))

# =========================================================================
# E3-F2 — marginal effect of each hazard at low vs high social vulnerability
# =========================================================================
# A dumbbell rather than paired bars: the quantity the essay argues about is
# the MOVEMENT from a less-vulnerable to a more-vulnerable county, and a bar
# chart makes the reader compute that difference by eye.
ei <- rd("Analysis/exposure_index/exposure_interaction_coefs.csv") %>%
  filter(outcome %in% names(OUT_LAB), shock %in% names(EI_SHOCK))
stopifnot(nrow(ei) > 0)

d2 <- ei %>%
  mutate(hazard = factor(EI_SHOCK[shock], levels = rev(unname(EI_SHOCK))),
         outcome_f = factor(OUT_LAB[outcome], levels = unname(OUT_LAB)),
         # Colour marks whether the two ends are statistically distinguishable,
         # NOT whether the movement is "worse". Which direction counts as worse
         # differs across these outcomes -- a fall in employment and a rise in
         # medical debt are both bad -- so encoding it in one colour scale would
         # mislabel half the panels.
         differs = ifelse(p_interaction < 0.05, "Ends differ (p < 0.05)",
                          "Ends not distinguishable"),
         int_lab = paste0("p = ", formatC(p_interaction, format = "f", digits = 3),
                          star(p_interaction)))

f2 <- ggplot(d2, aes(y = hazard)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey55", linewidth = 0.35) +
  geom_segment(aes(x = me_lowSVI, xend = me_highSVI, yend = hazard, colour = differs),
               linewidth = 0.9, lineend = "round",
               arrow = arrow(length = unit(0.10, "cm"), type = "closed")) +
  geom_point(aes(x = me_lowSVI), colour = "grey35", size = 2.1) +
  geom_point(aes(x = me_highSVI, colour = differs), size = 2.6) +
  geom_text(aes(x = pmax(me_lowSVI, me_highSVI), label = int_lab),
            hjust = -0.15, size = 2.5, colour = "grey30") +
  scale_colour_manual(values = c(`Ends differ (p < 0.05)` = "#B2182B",
                                 `Ends not distinguishable` = "grey60"),
                      name = NULL) +
  facet_wrap(~ outcome_f, scales = "free_x", ncol = 2) +
  scale_x_continuous(expand = expansion(mult = c(0.10, 0.28))) +
  labs(
    title = "How the effect of a climate shock changes with county social vulnerability",
    subtitle = paste0(
      "Each arrow runs from the effect of the hazard in a less vulnerable county (grey dot, 25th percentile of the\n",
      "CDC Social Vulnerability Index) to its effect in a more vulnerable county (75th percentile). The\n",
      "p-value tests whether the two ends differ. County and year fixed effects; standard errors clustered by state."),
    x = "Effect of the hazard on the outcome", y = NULL,
    caption = paste0(
      "Medical debt runs against the pattern of the other ledgers. That is read as a statement about what a credit\n",
      "record captures, not about where hardship falls. † p<0.1, * p<0.05, ** p<0.01, *** p<0.001.")) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 12.5),
        plot.subtitle = element_text(colour = "grey30", size = 8.6, lineheight = 1.15),
        plot.caption = element_text(colour = "grey35", size = 7.6, hjust = 0, lineheight = 1.15),
        plot.title.position = "plot", plot.caption.position = "plot",
        strip.text = element_text(face = "bold", size = 9.2),
        panel.grid.minor = element_blank(),
        panel.spacing.x = grid::unit(1.6, "lines"),
        panel.spacing.y = grid::unit(1.0, "lines"),
        legend.position = "bottom", legend.text = element_text(size = 8.6),
        axis.text.y = element_text(size = 8.6))

ggsave(file.path(OUT_DIR, "fig_svi_marginal_effects.png"), f2,
       width = 11, height = 8.2, dpi = 200)
cat("wrote E3-F2", file.path(OUT_DIR, "fig_svi_marginal_effects.png"), "-", nrow(d2), "cells\n")

# =========================================================================
# E3-F4 — uncompensated care and operating margin by safety-net status
# =========================================================================
HOSP_SHOCK <- c(High_CDD = "Extreme heat", High_HDD = "Extreme cold",
                Is_Extreme_Drought = "Extreme drought")
HOSP_OUT <- c(Hosp_UncompCare_PctNPR = "Uncompensated care\n(share of net patient revenue)",
              Hosp_OperatingMargin = "Operating margin")

hh <- rd("Analysis/hospital/hospital_heterogeneity_coefs.csv") %>%
  filter(moderator == "SafetyNet",
         shock %in% names(HOSP_SHOCK), outcome %in% names(HOSP_OUT))
stopifnot(nrow(hh) > 0)

d4 <- hh %>%
  mutate(hazard = factor(HOSP_SHOCK[shock], levels = unname(HOSP_SHOCK)),
         outcome_f = factor(HOSP_OUT[outcome], levels = unname(HOSP_OUT)),
         # The diagnostic printed this axis as a bare 0/1.
         status = factor(ifelse(level == 1, "Safety-net hospitals",
                                "All other hospitals"),
                         levels = c("All other hospitals", "Safety-net hospitals")),
         lo = estimate - 1.96 * std.error,
         hi = estimate + 1.96 * std.error,
         sig = p.value < 0.05)

# One interaction p per hazard x outcome, printed once above the pair.
ann <- d4 %>% group_by(hazard, outcome_f) %>%
  summarise(interaction_p = dplyr::first(interaction_p),
            top = max(hi), .groups = "drop") %>%
  mutate(lab = paste0("difference p = ",
                      formatC(interaction_p, format = "f", digits = 3),
                      star(interaction_p)))

f4 <- ggplot(d4, aes(x = hazard, y = estimate, colour = status, shape = sig)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey55", linewidth = 0.35) +
  geom_pointrange(aes(ymin = lo, ymax = hi), position = position_dodge(width = 0.55),
                  linewidth = 0.6, size = 0.45, fatten = 2.4) +
  geom_text(data = ann, inherit.aes = FALSE,
            aes(x = hazard, y = top, label = lab),
            vjust = -0.9, size = 2.6, colour = "grey30") +
  scale_colour_manual(values = c(`All other hospitals` = "grey45",
                                 `Safety-net hospitals` = "#B2182B"), name = NULL) +
  scale_shape_manual(values = c(`TRUE` = 16, `FALSE` = 1), guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0.08, 0.22))) +
  facet_wrap(~ outcome_f, scales = "free_y") +
  labs(
    title = "Heat raises uncompensated care at safety-net hospitals; cold runs the other way",
    subtitle = paste0(
      "Effect of each hazard on hospital finances, with 95% confidence intervals. Hollow points are not\n",
      "distinguishable from zero at the 5% level. Safety-net hospitals are those in the top quartile of a combined\n",
      "Medicaid and uncompensated-care payer-mix score. 5,119 hospitals, 2011–2023, with hospital and year\n",
      "fixed effects and standard errors clustered by state."),
    x = NULL, y = "Change in the outcome (95% confidence interval)",
    caption = paste0(
      "A hospital's exposure is assigned at the county where it operates, not where its patients live, so exposure is\n",
      "measured with error for hospitals drawing on a wide catchment. † p<0.1, * p<0.05, ** p<0.01, *** p<0.001.")) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 12.5),
        plot.subtitle = element_text(colour = "grey30", size = 8.6, lineheight = 1.15),
        plot.caption = element_text(colour = "grey35", size = 7.6, hjust = 0, lineheight = 1.15),
        plot.title.position = "plot", plot.caption.position = "plot",
        strip.text = element_text(face = "bold", size = 9.2),
        panel.grid.minor = element_blank(),
        panel.spacing.x = grid::unit(1.6, "lines"),
        legend.position = "bottom", legend.text = element_text(size = 8.8))

ggsave(file.path(OUT_DIR, "fig_safetynet_uncompensated_care.png"), f4,
       width = 10, height = 6.6, dpi = 200)
cat("wrote E3-F4", file.path(OUT_DIR, "fig_safetynet_uncompensated_care.png"), "-", nrow(d4), "cells\n")

cat("\n=== done ===\n")
