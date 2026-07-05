# =============================================================================
# plot_did_eventstudy.R  (mechanisms_revision_20260704 — Task 1.3 / B1)
# =============================================================================
# The second reviewer (B1) asked for an event-study plot for the 2012-drought
# DiD. The 2012 first-onset cohort has NO testable pre-period (the panel starts
# in 2011 = its e=−1), so a 2012-only plot cannot show leads. We therefore plot
# the POOLED Callaway–Sant'Anna dynamic event-study across ALL drought cohorts
# (the cohorts first droughted in 2013/2021/2022 supply the pre-periods), which
# is the honest object that carries the disclosed employment pre-trends. The
# caption states the 2012-cohort limitation explicitly.
#
# SOURCE: Analysis/did/robustness/dr_csdid_eventtime.csv (Estimator, Outcome,
#   Event_Time, ATT, SE) — produced by Code/did_robustness/02_doubly_robust_did.R.
# ENV: main R 4.2.2.  Rscript Code/plot_did_eventstudy.R
# OUTPUT: Analysis/mechanism/plots/did_eventstudy_pooled.png
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(ggplot2) })

WIN <- 6L   # readable event window; leads beyond -6 are ultra-noisy (few cohorts)
es <- read.csv("Analysis/did/robustness/dr_csdid_eventtime.csv") %>%
  filter(Outcome %in% c("PCPI_Real", "Civilian_Employed"),
         Event_Time >= -WIN, Event_Time <= WIN) %>%
  mutate(lo = ATT - 1.96 * SE, hi = ATT + 1.96 * SE,
         Outcome = recode(Outcome,
                          PCPI_Real = "Per-capita income ($)",
                          Civilian_Employed = "Civilian employed (persons)"))

p <- ggplot(es, aes(Event_Time, ATT)) +
  geom_hline(yintercept = 0, colour = "grey55") +
  geom_vline(xintercept = -0.5, linetype = "dashed", colour = "grey55") +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = "#c0392b", alpha = 0.15) +
  geom_line(colour = "#c0392b", linewidth = 0.8) +
  geom_point(colour = "#c0392b", size = 1.4) +
  facet_wrap(~ Outcome, scales = "free_y", ncol = 1) +
  scale_x_continuous(breaks = seq(-WIN, WIN, 2)) +
  labs(title = "Pooled drought event study (Callaway–Sant'Anna, doubly-robust)",
       subtitle = paste0("All first-onset drought cohorts vs never-exposed controls; 95% CI. ",
                         "Dashed line = treatment onset.\nThe 2012 cohort alone has no testable ",
                         "pre-period (panel starts at its e = -1), so leads come from the\n",
                         "2013/2021/2022 cohorts; the employment pre-trend (e < 0) is the ",
                         "disclosed reason the pooled\nemployment effect is read as fragile."),
       x = "Event time (years since first drought onset)", y = "ATT (2023 $ / persons)") +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 12),
        plot.subtitle = element_text(size = 8.5, colour = "grey30"),
        strip.text = element_text(face = "bold"),
        plot.background = element_rect(fill = "white", colour = NA),
        panel.background = element_rect(fill = "white", colour = NA))

dir.create("Analysis/mechanism/plots", showWarnings = FALSE, recursive = TRUE)
out <- "Analysis/mechanism/plots/did_eventstudy_pooled.png"
ggsave(out, p, width = 7.5, height = 6.5, dpi = 150, bg = "white")
cat("Wrote", out, "\n")
# quick pre-trend readout for the caption/write-up
pre <- es %>% filter(Event_Time < 0) %>% group_by(Outcome) %>%
  summarise(n_pre = n(), mean_pre_ATT = round(mean(ATT), 1),
            any_sig_pre = any(abs(ATT) > 1.96 * SE), .groups = "drop")
print(as.data.frame(pre), row.names = FALSE)
