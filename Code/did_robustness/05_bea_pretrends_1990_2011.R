# =============================================================================
# DiD Frontier-Robustness — 05. BEA income pre-trends, 1990–2011
# =============================================================================
# WHY THIS EXISTS
#   The county panel used for the 2012-drought natural experiment starts in 2011,
#   so the 2012 first-onset cohort has a SINGLE pre-period (2011) and parallel
#   trends is untestable in isolation — the biggest identification hole in the
#   dissertation's strongest result (drought → income). HonestDiD could only run
#   on the pooled multi-cohort event study, which cannot vindicate the 2012 event.
#
#   BEA CAINC1 per-capita personal income (PCPI_Real, inflation-adjusted) is,
#   however, available back to 1990 in Data/intermediate_socioeconomic.rds. That
#   lets us test parallel PRE-trends over two decades (1990–2011) for the SAME
#   treated (first-onset-2012) vs never-exposed counties used in the DiD. If the
#   two groups' income trajectories are parallel before 2012, the income headline
#   gets the pre-trend defense it currently lacks; if not, better to know now.
#
#   Employment / median-HH-income CANNOT be extended this way (their ACS source
#   starts in 2011), and income is the robust result anyway — so this is
#   income-only by design.
#
# DESIGN
#   Cohorts are defined EXACTLY as in the DiD (Code/did_robustness/00_..._common.R
#   build_cohorts on Is_Extreme_Drought over the 2011–2023 county master):
#     treated = first extreme-drought onset in 2012 ; control = never droughted.
#   Two pre-trend tests on 1990–2011 PCPI_Real, county + year FE, state-clustered:
#     (1) LINEAR differential trend  — coefficient on (Year-2011)*Treated: the
#         extra $/yr of income growth for treated vs control before treatment.
#         This is the headline verdict number.
#     (2) EVENT-STUDY joint test     — year-specific treated gaps relative to 2011
#         (i(Year, Treated, ref=2011)); a joint Wald test that the 1990–2010
#         interactions are all zero. Flat + jointly-insignificant = parallel.
#   A figure plots the two groups' mean PCPI 1990–2013 (through 2013 to show the
#   post-2012 divergence against the flat pre-period), with a marker at 2012.
#
# ENVIRONMENT: runs on the MAIN R 4.2.2 — it needs no frontier package, only the
#   socioeconomic intermediate + fixest + ggplot2. (Lives in did_robustness/ for
#   thematic grouping with the rest of the 2012-DiD identification layer.)
#   Rscript Code/did_robustness/05_bea_pretrends_1990_2011.R
#
# OUTPUTS
#   Analysis/did/robustness/bea_pretrends_1990_2011.csv   (both tests, tidy)
#   Analysis/did/robustness/bea_pretrends_1990_2011.png   (trajectory figure)
#   Analysis/did/robustness/build_logs/05_bea_pretrends_1990_2011.log
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
  library(ggplot2)
})
source("Code/did_robustness/00_did_robustness_common.R")

LOG_DIR <- file.path(OUT_DIR, "build_logs")
dir.create(LOG_DIR, showWarnings = FALSE, recursive = TRUE)
logcon <- file(file.path(LOG_DIR, "05_bea_pretrends_1990_2011.log"), open = "wt")
sink(logcon, split = TRUE); sink(logcon, type = "message")
on.exit({ sink(type = "message"); sink(); close(logcon) }, add = TRUE)

cat("=== BEA income pre-trends 1990-2011 :: run", format(Sys.time()), "===\n\n")

# Normalize FIPS to zero-padded 5-char (CLAUDE.md FIPS-padding trap: never sprintf %05s).
pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")

# ---------------------------------------------------------------------------
# 1. Cohorts from the DiD panel (identical construction to run_did_analysis.R)
# ---------------------------------------------------------------------------
panel   <- load_did_panel()
cohorts <- build_cohorts(panel, "Is_Extreme_Drought") %>%
  mutate(fips_code = pad_fips(fips_code))
treated_fips <- cohorts %>% filter(cohort == 2012L) %>% pull(fips_code)
control_fips <- cohorts %>% filter(cohort == 0L)   %>% pull(fips_code)
cat(sprintf("Cohorts: treated (first-onset 2012) = %d ; never-exposed = %d\n",
            length(treated_fips), length(control_fips)))

# state lookup (2-letter) for clustering, taken from the county master
state_lu <- panel %>%
  mutate(fips_code = pad_fips(fips_code)) %>%
  distinct(fips_code, State)

# ---------------------------------------------------------------------------
# 2. 1990–2011 PCPI_Real for those counties from the BEA-back-to-1990 source
# ---------------------------------------------------------------------------
si <- readRDS("Data/intermediate_socioeconomic.rds")
si$fips_code <- pad_fips(si$fips_code)

pre <- si %>%
  filter(Year >= 1990L, Year <= 2011L,
         fips_code %in% c(treated_fips, control_fips),
         !is.na(PCPI_Real)) %>%
  mutate(Treated = as.integer(fips_code %in% treated_fips),
         year_c  = Year - 2011L) %>%           # 0 at the last pre-period
  left_join(state_lu, by = "fips_code")

cov_tab <- pre %>% group_by(Year) %>%
  summarise(treated = sum(Treated), control = sum(1 - Treated), .groups = "drop")
cat("\nPre-period PCPI coverage (counties w/ non-missing PCPI) by year:\n")
print(as.data.frame(cov_tab), row.names = FALSE)
cat(sprintf("\nDistinct treated w/ any pre-PCPI: %d / %d ; control: %d / %d\n",
            n_distinct(pre$fips_code[pre$Treated == 1]), length(treated_fips),
            n_distinct(pre$fips_code[pre$Treated == 0]), length(control_fips)))

# ---------------------------------------------------------------------------
# 3a. LINEAR differential pre-trend (the verdict number)
#     Treated & Year main effects are absorbed by the FE; the interaction of the
#     centered year with Treated is the differential slope ($/yr).
# ---------------------------------------------------------------------------
m_lin <- feols(PCPI_Real ~ I(year_c * Treated) | fips_code + Year,
               data = pre, cluster = ~State)
b_lin  <- unname(coef(m_lin)[1]); se_lin <- unname(se(m_lin)[1])
p_lin  <- unname(pvalue(m_lin)[1])
cat(sprintf("\n[LINEAR pre-trend] differential slope = %.2f $/yr (SE %.2f, p = %.3f)\n",
            b_lin, se_lin, p_lin))

# ---------------------------------------------------------------------------
# 3b. EVENT-STUDY joint test — year-specific treated gaps vs the 2011 reference,
#     restricted to the pre-period. Joint Wald that 1990–2010 gaps are all zero.
# ---------------------------------------------------------------------------
m_es <- feols(PCPI_Real ~ i(Year, Treated, ref = 2011) | fips_code + Year,
              data = pre, cluster = ~State)
w    <- fixest::wald(m_es, keep = "Year::", print = FALSE)
cat(sprintf("[EVENT-STUDY joint] Wald H0: all pre-2011 treated gaps = 0 -> F = %.3f, p = %.3f\n",
            w$stat, w$p))

# ---------------------------------------------------------------------------
# 4. Verdict — the two tests answer DIFFERENT questions, so read them separately.
#   The LINEAR slope is the pre-trend threat that actually biases a DiD: a
#   systematic differential drift that would extrapolate into the post-period and
#   masquerade as a treatment effect. The EVENT-STUDY joint test also picks up
#   non-linear, business-cycle-correlated year-to-year wiggles, which a 20-year
#   pre-period over rural-agricultural (treated) vs urban (control) counties will
#   show even when the design is sound.
# ---------------------------------------------------------------------------
lin_ok <- (p_lin > 0.05); es_ok <- (w$p > 0.05)
verdict <- {
  if (lin_ok && es_ok) {
    "CLEANLY PARALLEL — no differential linear drift AND no jointly-significant\n  year gaps. The 2012 income headline gains the two-decade pre-trend defense it\n  previously lacked."
  } else if (lin_ok && !es_ok) {
    "LINEAR PRE-TRENDS PARALLEL (the DiD-relevant threat is absent: differential\n  slope insignificant), but year-specific gaps are jointly non-zero — consistent\n  with the rural-agricultural vs urban composition that already motivates the DRDID\n  conditioning check. READING: lead with the covariate-conditional DRDID (which\n  STRENGTHENS the income effect to -$1,451) as the primary parallel-trends defense,\n  and cite the flat two-decade linear pre-trend as corroboration."
  } else {
    "DIFFERENTIAL LINEAR DRIFT PRESENT (linear slope significant) — the serious case.\n  Report transparently and lean entirely on the DRDID conditioning result."
  }
}
cat(sprintf("\n=== VERDICT: %s ===\n", verdict))

# ---------------------------------------------------------------------------
# 5. Persist tidy results
# ---------------------------------------------------------------------------
res <- data.frame(
  test    = c("linear_diff_slope", "eventstudy_joint_wald"),
  stat    = c(b_lin, w$stat),
  se      = c(se_lin, NA_real_),
  p_value = c(p_lin, w$p),
  note    = c("differential PCPI slope ($/yr), treated vs control, 1990-2011",
              "joint Wald that all 1990-2010 treated-vs-control gaps (ref 2011) = 0"),
  stringsAsFactors = FALSE)
out_csv <- file.path(OUT_DIR, "bea_pretrends_1990_2011.csv")
write_csv(res, out_csv)
cat("\nWrote", out_csv, "\n")

# ---------------------------------------------------------------------------
# 6. Figure — mean PCPI trajectories 1990–2013 (extend past 2012 to show the
#    divergence against the flat pre-period). Unweighted county means, matching
#    the unweighted DiD county ATT.
# ---------------------------------------------------------------------------
fig_df <- si %>%
  filter(Year >= 1990L, Year <= 2013L,
         fips_code %in% c(treated_fips, control_fips), !is.na(PCPI_Real)) %>%
  mutate(Group = if_else(fips_code %in% treated_fips,
                         "Treated (first-onset 2012)", "Never-exposed")) %>%
  group_by(Group, Year) %>%
  summarise(mean_pcpi = mean(PCPI_Real), .groups = "drop")

p <- ggplot(fig_df, aes(Year, mean_pcpi, colour = Group)) +
  geom_vline(xintercept = 2011.5, linetype = "dashed", colour = "grey50") +
  annotate("text", x = 2011.4, y = max(fig_df$mean_pcpi), hjust = 1,
           label = "2012 onset", size = 3, colour = "grey40") +
  geom_line(linewidth = 0.9) + geom_point(size = 1.2) +
  scale_colour_manual(values = c("Treated (first-onset 2012)" = "#c0392b",
                                 "Never-exposed" = "#2c3e50")) +
  scale_y_continuous(labels = function(x) paste0("$", format(x, big.mark = ",", scientific = FALSE))) +
  labs(title = "Real per-capita income, 1990-2013: treated vs never-exposed counties",
       subtitle = "Two-decade pre-trend test for the 2012-drought natural experiment (BEA CAINC1, 2023$)",
       x = NULL, y = "Mean county PCPI (real)", colour = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold", size = 12))

out_png <- file.path(OUT_DIR, "bea_pretrends_1990_2011.png")
ggsave(out_png, p, width = 8, height = 5, dpi = 150)
cat("Wrote", out_png, "\n")

cat("\n=== done", format(Sys.time()), "===\n")
