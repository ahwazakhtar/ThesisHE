# Renders exhibit E1-F4: Medicare morbidity responses by hazard.
# Reads Analysis/mechanism/medicare_channel_coefs.csv (run_mechanism_medicare.R)
# and draws a hazard x outcome panel grid — one row per exposure, one column per
# outcome, free x-scale per outcome column (spending and ED visits differ by two
# orders of magnitude, so a shared axis makes the ED responses unreadable).
#
# Rewritten 2026-08-17 (was an uncommitted base-R one-column plot with a
# truncated title and raw variable-name labels; registry E1-F4 updated to
# point here). Run: Rscript Code/create_fig_medicare_morbidity.R
#
# Output: Analysis/mechanism/plots/fig_medicare_morbidity.png

suppressPackageStartupMessages({ library(dplyr); library(ggplot2) })

coefs <- read.csv("Analysis/mechanism/medicare_channel_coefs.csv")

# Panel labels are read by someone meeting this figure with no prior exposure
# to the pipeline, so they spell the hazard definitions out; the degree-day and
# Palmer acronyms stay in the data appendix.
hazard_labels <- c(CDD = "Extreme heat: cooling degree days above the national 80th percentile",
                   HDD = "Extreme cold: heating degree days above the national 80th percentile",
                   AQI = "Poor air quality: peak air-quality index above 100",
                   Drought = "Extreme drought: Palmer index at or below −4")
outcome_labels <- c(Mdcr_Std_Payment_PC = "Standardized spending, $ per beneficiary",
                    ER_Visits_per1000 = "Emergency department visits per 1,000 beneficiaries")

d <- coefs %>%
  filter(spec == "overall",
         outcome %in% names(outcome_labels)) %>%
  mutate(
    lag = dplyr::case_when(grepl("_Lag2$", term) ~ 2L,
                           grepl("_Lag1$", term) ~ 1L,
                           TRUE ~ 0L),
    lag_label = factor(c("Shock year", "+1 year", "+2 years")[lag + 1],
                       levels = rev(c("Shock year", "+1 year", "+2 years"))),
    hazard = factor(hazard_labels[shock], levels = unname(hazard_labels)),
    outcome_f = factor(outcome_labels[outcome], levels = unname(outcome_labels)),
    sig = p < 0.05,
    lo = estimate - 1.96 * se,
    hi = estimate + 1.96 * se
  )

p <- ggplot(d, aes(x = estimate, y = lag_label, color = sig)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey55", linewidth = 0.35) +
  geom_pointrange(aes(xmin = lo, xmax = hi), linewidth = 0.55, size = 0.35,
                  show.legend = FALSE) +
  scale_color_manual(values = c(`TRUE` = "#B2182B", `FALSE` = "grey55")) +
  facet_grid(hazard ~ outcome_f, scales = "free_x",
             labeller = labeller(hazard = label_wrap_gen(32))) +
  labs(title = "Medicare morbidity responses to climate and air-quality shocks",
       subtitle = paste0("Change in the outcome by years since the shock, with 95% confidence intervals; ",
                         "estimates are drawn in red where they are
distinguishable from zero at the 5% level. ",
                         "Medicare beneficiaries aged 65 and over and disabled beneficiaries, 2014–2023, with
",
                         "county and year fixed effects and standard errors clustered by state."),
       x = "Change in the outcome (95% confidence interval)", y = NULL) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 12),
        plot.subtitle = element_text(color = "grey30", size = 9),
        plot.title.position = "plot",
        strip.text.y = element_text(angle = 0, hjust = 0, size = 9),
        strip.text.x = element_text(face = "bold", size = 9.5),
        panel.spacing.x = grid::unit(1.4, "lines"),
        panel.spacing.y = grid::unit(0.8, "lines"),
        panel.grid.minor = element_blank(),
        axis.text.y = element_text(size = 9))

dir.create("Analysis/mechanism/plots", showWarnings = FALSE, recursive = TRUE)
ggsave("Analysis/mechanism/plots/fig_medicare_morbidity.png", p,
       # Wider than before: the panel strips now carry full-sentence hazard
       # definitions rather than four-letter codes.
       width = 11, height = 6.6, dpi = 200)
cat("Wrote Analysis/mechanism/plots/fig_medicare_morbidity.png\n")
