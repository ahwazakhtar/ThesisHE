# Renders the pooled CS-DiD event-time profiles as a hazard x outcome panel
# grid (2026-08-17 redesign, matching E1-F4's layout). Reads the manual
# cohort-size-weighted aggregation in Analysis/did/did_cs_event_time.csv.
#
# IMPORTANT (audit A4): the manual aggregation is DESCRIPTIVE ONLY — its
# independence SEs are invalid because cohort-time cells share never-treated
# controls. Headline inference cites the frontier dr_csdid values. The figure
# says so in the subtitle; keep that language.
#
# Run: Rscript Code/create_fig_csdid_panels.R
# Output: Analysis/plots/did/csdid_panels_income_employment.png

suppressPackageStartupMessages({ library(dplyr); library(ggplot2) })

es <- read.csv("Analysis/did/did_cs_event_time.csv")

shock_labels <- c(Drought = "Extreme drought (first onset)",
                  HDD = "Extreme cold (first onset)",
                  CDD = "Extreme heat (first onset)")
outcome_labels <- c(PCPI_Real = "Per-capita income (2023 USD)",
                    Civilian_Employed = "Civilian employment")

d <- es %>%
  filter(Outcome %in% names(outcome_labels), Shock %in% names(shock_labels)) %>%
  mutate(shock_f = factor(shock_labels[Shock], levels = unname(shock_labels)),
         outcome_f = factor(outcome_labels[Outcome], levels = unname(outcome_labels)),
         lo = ATT_avg - 1.96 * ATT_se_avg,
         hi = ATT_avg + 1.96 * ATT_se_avg)

p <- ggplot(d, aes(x = Event_Time, y = ATT_avg)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey55", linewidth = 0.35) +
  geom_line(color = "grey55", linewidth = 0.35) +
  geom_pointrange(aes(ymin = lo, ymax = hi), color = "grey35",
                  linewidth = 0.45, size = 0.25) +
  facet_grid(shock_f ~ outcome_f, scales = "free_y",
             labeller = labeller(shock_f = label_wrap_gen(18))) +
  scale_x_continuous(breaks = seq(0, 11, 2)) +
  labs(title = "Pooled multi-cohort event-time profiles (descriptive)",
       subtitle = "Cohort-size-weighted ATT(e), all first-onset cohorts vs never-exposed counties\nDESCRIPTIVE ONLY — independence SEs invalid (cohort-time cells share controls); cite the frontier dr_csdid values for inference",
       x = "Years since first onset", y = "ATT(e) (95% CI, descriptive)") +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 12),
        plot.subtitle = element_text(color = "grey30", size = 8.5),
        plot.title.position = "plot",
        strip.text.y = element_text(angle = 0, hjust = 0, size = 9),
        strip.text.x = element_text(face = "bold", size = 9.5),
        panel.spacing.x = grid::unit(1.4, "lines"),
        panel.spacing.y = grid::unit(0.8, "lines"),
        panel.grid.minor = element_blank())

dir.create("Analysis/plots/did", showWarnings = FALSE, recursive = TRUE)
ggsave("Analysis/plots/did/csdid_panels_income_employment.png", p,
       width = 9, height = 6.5, dpi = 150)
cat("Wrote Analysis/plots/did/csdid_panels_income_employment.png\n")
