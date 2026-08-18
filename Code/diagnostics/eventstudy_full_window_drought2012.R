# Full-window event study for the 2012 drought 2x2 cohort (income).
#
# The main 2x2 (Code/run_did_analysis.R) runs on 2011-2023, so its saved event
# study (did_pretrends_event_study.csv) has a single pre-year and lags only to
# e=+3. This diagnostic re-estimates the year-by-year treated-control gaps on
# the SAME cohorts (first extreme-drought onset 2012 vs never-exposed over
# 2011-2023) with pre-treatment leads. PCPI_Real is the only 2x2 outcome
# observed before 2011 (BEA); Civilian_Employed (ACS) starts in 2011 and
# cannot be extended.
#
# Reference year: 2011 (the last pre-onset year, matching the 2x2's pre-period).
# On the 2011-2023 sample the simple average of the 12 post-year gaps
# reproduces the pooled 2x2 ATT exactly (balanced panel) — printed as a
# consistency check.
#
# The manuscript exhibit uses a shorter 2009-2023 estimation window (two
# pre-treatment leads, per author choice 2026-08-17); the 1990-2023 run is kept
# as the numeric record behind the "leads all insignificant" claim.
#
# Outputs:
#   Analysis/did/did_eventstudy_full_window_drought2012_pcpi.csv   (1990-2023)
#   Analysis/plots/did/eventstudy_fullwindow_Drought_2012_PCPI_Real.png (1990-2023)
#   Analysis/did/did_eventstudy_leads2_drought2012_pcpi.csv        (2009-2023)
#   Analysis/plots/did/eventstudy_leads2_Drought_2012_PCPI_Real.png (2009-2023, exhibit)

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(fixest)
  library(ggplot2)
})

county_df <- read_csv("Data/county_level_master.csv",
                      show_col_types = FALSE, progress = FALSE)

keep_cols <- intersect(
  c("fips_code", "Year", "State", "Is_Extreme_Drought", "PCPI_Real"),
  names(county_df))

panel_full <- county_df %>%
  distinct(across(all_of(keep_cols))) %>%
  filter(Year >= 1990L, Year <= 2023L)

# Cohorts are defined over the 2011-2023 design window, exactly as in
# Code/run_did_analysis.R: treated = first onset 2012, control = never exposed
# 2011-2023. Pre-2011 exposure history plays no role in the definition.
cohorts <- panel_full %>%
  filter(Year >= 2011L, !is.na(Is_Extreme_Drought)) %>%
  group_by(fips_code) %>%
  summarise(first_event = suppressWarnings(min(Year[Is_Extreme_Drought == 1], na.rm = TRUE)),
            .groups = "drop") %>%
  mutate(first_event = if_else(is.finite(first_event), first_event, NA_real_),
         cohort = if_else(is.na(first_event), 0L, as.integer(first_event)))

treated_fips <- cohorts$fips_code[cohorts$cohort == 2012L]
control_fips <- cohorts$fips_code[cohorts$cohort == 0L]
cat(sprintf("Treated: %d, never-exposed controls: %d\n",
            length(treated_fips), length(control_fips)))

base <- panel_full %>%
  filter(fips_code %in% c(treated_fips, control_fips), !is.na(PCPI_Real)) %>%
  mutate(Treated = as.integer(fips_code %in% treated_fips))

run_window <- function(start_year, csv_path, png_path, title_tag) {
  d <- base %>% filter(Year >= start_year)
  m <- feols(PCPI_Real ~ i(Year, Treated, ref = 2011) | fips_code + Year,
             data = d, cluster = "State")
  ct <- as.data.frame(coeftable(m))
  res <- data.frame(
    Event = "Drought_2012",
    Outcome = "PCPI_Real",
    Year = as.integer(gsub("Year::(\\d+):Treated", "\\1", rownames(ct))),
    Estimate = ct[, 1],
    Std_Error = ct[, 2],
    p_value = ct[, 4],
    row.names = NULL
  ) %>%
    bind_rows(data.frame(Event = "Drought_2012", Outcome = "PCPI_Real",
                         Year = 2011L, Estimate = 0, Std_Error = 0,
                         p_value = NA_real_)) %>%
    arrange(Year) %>%
    mutate(Event_Time = Year - 2012L,
           Window_Start = start_year,
           N = nobs(m),
           Reference_Year = 2011L,
           Cluster = "State")
  write_csv(res, csv_path)

  cat(sprintf("\n[%d-2023] leads:\n", start_year))
  print(res %>% filter(Year < 2011) %>%
          select(Year, Estimate, Std_Error, p_value), digits = 4)

  x_breaks <- if (start_year <= 2000) seq(1990, 2023, 4) else seq(start_year, 2023, 2)
  p <- ggplot(res, aes(x = Year, y = Estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = 2011.5, linetype = "dotted", color = "grey60") +
    geom_pointrange(aes(ymin = Estimate - 1.96 * Std_Error,
                        ymax = Estimate + 1.96 * Std_Error),
                    color = "#B2182B", linewidth = 0.4, size = 0.3) +
    annotate("text", x = 2011.4, y = max(res$Estimate + 1.96 * res$Std_Error),
             label = "2012 onset", hjust = 1, size = 3, color = "grey40") +
    scale_x_continuous(breaks = x_breaks) +
    labs(title = paste0("Event Study (DiD), ", title_tag, ": Drought_2012 -> PCPI_Real"),
         subtitle = sprintf("Treated-control gap by year, ref = 2011; %d-2010 = pre-treatment leads; cluster = State",
                            start_year),
         x = "Year", y = "Coefficient (2023 USD)") +
    theme_minimal(base_size = 11)
  ggsave(png_path, p, width = if (start_year <= 2000) 9 else 7, height = 4, dpi = 120)
  cat(sprintf("Wrote %s\n", png_path))
  invisible(res)
}

res_full <- run_window(1990L,
                       "Analysis/did/did_eventstudy_full_window_drought2012_pcpi.csv",
                       "Analysis/plots/did/eventstudy_fullwindow_Drought_2012_PCPI_Real.png",
                       "full window 1990-2023")
res_short <- run_window(2009L,
                        "Analysis/did/did_eventstudy_leads2_drought2012_pcpi.csv",
                        "Analysis/plots/did/eventstudy_leads2_Drought_2012_PCPI_Real.png",
                        "2009-2023 window")

# Consistency check against the pooled 2x2 on the same cohorts, 2011-2023.
m_2x2 <- feols(PCPI_Real ~ Treated_x_Post | fips_code + Year,
               data = base %>% filter(Year >= 2011L) %>%
                 mutate(Treated_x_Post = Treated * as.integer(Year >= 2012L)),
               cluster = "State")
post_avg <- mean(res_full$Estimate[res_full$Year >= 2012L])
cat(sprintf("\nPooled 2x2 ATT (2011-2023): %.1f | mean of 12 post-year gaps (full window): %.1f\n",
            coef(m_2x2)[1], post_avg))
