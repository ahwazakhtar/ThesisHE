# ============================================================================
#  REACH Poster — Publication-quality plot regeneration
#  Reads Analysis/delta_coefs.csv and emits four poster-ready PNGs into
#  Poster/plots/ with human-readable axis labels and large fonts.
#
#  Usage (from project root):
#    Rscript Poster/generate_poster_plots.R
# ============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
})

here <- function(...) file.path("Poster", ...)
if (!dir.exists(here("plots"))) dir.create(here("plots"), recursive = TRUE)

coefs <- read_csv("Analysis/delta_coefs.csv", show_col_types = FALSE)

# ---- Shared poster theme (no title, no subtitle — poster body carries text) -
poster_theme <- theme_minimal(base_size = 24) +
  theme(
    plot.title       = element_blank(),
    plot.subtitle    = element_blank(),
    axis.title.x     = element_text(face = "bold", size = 24,
                                    margin = margin(t = 8)),
    axis.title.y     = element_text(face = "bold", size = 24,
                                    margin = margin(r = 8)),
    axis.text        = element_text(size = 22, color = "grey15"),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey88"),
    legend.title     = element_text(face = "bold", size = 22),
    legend.text      = element_text(size = 20),
    legend.position  = "top",
    plot.margin      = margin(14, 18, 10, 10)
  )

gwblue <- "#033C5A"
gwbuff <- "#AC935E"
red    <- "#B2182B"
blue   <- "#2166AC"
green  <- "#4DAF4A"

# ===========================================================================
#  FINDING 1 — AQI swings compound over time
#  Source: Delta_LP, exposure = Max_AQI, outcome = Hosp_BadDebt_PerCapita
# ===========================================================================
f1 <- coefs %>%
  filter(approach  == "Delta_LP",
         exposure  == "Max_AQI",
         outcome   == "Hosp_BadDebt_PerCapita",
         weighting == "Unweighted",
         horizon   >= 0)

p1 <- ggplot(f1, aes(x = horizon, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                  size = 1.3, fatten = 4, color = gwblue) +
  geom_line(color = gwblue, alpha = 0.35, linewidth = 1) +
  scale_x_continuous(breaks = 0:3) +
  labs(
    x = "Years after air-quality swing",
    y = "Hospital bad debt per capita (USD)"
  ) +
  poster_theme

ggsave(here("plots/F1_aqi_compound.png"), p1,
       width = 9, height = 6.2, dpi = 200, bg = "white")

# ===========================================================================
#  FINDING 2 — AQI-only ratchet asymmetry
#  Source: Delta_Asym, AQI exposures only, outcome = Hosp_BadDebt_PerCapita
# ===========================================================================
aqi_asym <- coefs %>%
  filter(approach  == "Delta_Asym",
         outcome   == "Hosp_BadDebt_PerCapita",
         weighting == "Unweighted",
         horizon   == 0,
         exposure %in% c("Max_AQI_Pos", "Max_AQI_Neg")) %>%
  mutate(
    direction = ifelse(grepl("_Pos$", exposure),
                       "Escalation\n(AQI worsens)",
                       "Relief\n(AQI improves)"),
    direction = factor(direction,
                       levels = c("Escalation\n(AQI worsens)",
                                  "Relief\n(AQI improves)"))
  )

p2 <- ggplot(aqi_asym, aes(x = direction, y = estimate, color = direction)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                  size = 1.4, fatten = 5) +
  scale_color_manual(values = c("Escalation\n(AQI worsens)" = red,
                                "Relief\n(AQI improves)"    = blue)) +
  labs(
    x = NULL,
    y = "Hospital bad debt per capita (USD)"
  ) +
  poster_theme +
  theme(legend.position = "none")

ggsave(here("plots/F2_aqi_ratchet.png"), p2,
       width = 9, height = 6.2, dpi = 200, bg = "white")

# ===========================================================================
#  FINDING 3 — HDD onset/exit/persist effect on Silver premium
#  Source: Delta_OnsetExit, base shock = HDD, outcome = Benchmark_Silver_Real
# ===========================================================================
hdd_trans <- coefs %>%
  filter(approach  == "Delta_OnsetExit",
         outcome   == "Benchmark_Silver_Real",
         weighting == "Unweighted",
         horizon   == 0,
         grepl("^HDD_", exposure)) %>%
  mutate(transition = sub("^HDD_", "", exposure),
         transition = factor(transition, levels = c("Onset", "Persist", "Exit")))

p3 <- ggplot(hdd_trans, aes(x = transition, y = estimate, color = transition)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                  size = 1.4, fatten = 5) +
  scale_color_manual(values = c("Onset" = red, "Persist" = green, "Exit" = blue)) +
  labs(
    x = "HDD regime transition",
    y = "Benchmark Silver premium (USD)"
  ) +
  poster_theme +
  theme(legend.position = "none")

ggsave(here("plots/F3_hdd_onset.png"), p3,
       width = 9, height = 6.2, dpi = 200, bg = "white")

# ===========================================================================
#  FINDING 4 — Drought swings suppress income
#  Source: Delta_LP, exposure = PDSI, outcome = PCPI_Real
# ===========================================================================
f4 <- coefs %>%
  filter(approach  == "Delta_LP",
         exposure  == "PDSI",
         outcome   == "PCPI_Real",
         weighting == "Unweighted",
         horizon   >= 0)

p4 <- ggplot(f4, aes(x = horizon, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                  size = 1.3, fatten = 4, color = gwblue) +
  geom_line(color = gwblue, alpha = 0.35, linewidth = 1) +
  scale_x_continuous(breaks = 0:3) +
  labs(
    x = "Years after drought swing",
    y = "Real per-capita income (USD)"
  ) +
  poster_theme

ggsave(here("plots/F4_pdsi_income.png"), p4,
       width = 9, height = 6.2, dpi = 200, bg = "white")

cat("Generated poster plots:\n")
cat("  Poster/plots/F1_aqi_compound.png\n")
cat("  Poster/plots/F2_aqi_ratchet.png\n")
cat("  Poster/plots/F3_hdd_onset.png\n")
cat("  Poster/plots/F4_pdsi_income.png\n")
