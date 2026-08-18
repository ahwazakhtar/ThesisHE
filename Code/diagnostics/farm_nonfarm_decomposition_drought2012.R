# Farm vs nonfarm decomposition of the 2012-drought 2x2 income result, plus
# baseline (pre-period) sensitivity of the pooled ATT. Run 2026-08-17 after the
# full-window event study (eventstudy_full_window_drought2012.R) showed the
# 2008-2010 leads at ~-$1,500 relative to the 2011 reference year.
#
# Findings this script documents:
#   1. Treated-county real farm earnings per capita spiked in 2011 ($4,339 vs
#      ~$1,900-2,440 in 2007-2010; controls rose far less) — the record
#      commodity-price year. ~85% of the adverse 2008-2010 PCPI leads is the
#      farm component.
#   2. The pooled 2x2 income ATT is baseline-dependent: -$1,311 (p=0.028) with
#      the single 2011 pre-year; -$285 (p=0.64) with pooled 2009-2011.
#   3. Decomposed vs 2011: farm ATT -$907 (p=0.13) collapses to -$14 (p=0.95)
#      with the pooled baseline (pure mean reversion); nonfarm ATT is
#      sign-stable but small and insignificant (-$394 / -$261).
#
# Farm earnings: BEA CAINC5N LineCode 81 (thousands, nominal, 2001-2024),
# downloaded by the mechanism track (Data/County_Agriculture/). Deflated to
# 2023 dollars with the county-master CPI series. Nonfarm per-capita income is
# the residual PCPI_Real - Farm_PC_Real (place-of-work earnings subtracted
# from place-of-residence income — an approximation, adequate for a
# within-county event-study diagnostic).
#
# Outputs:
#   Analysis/did/did_farm_nonfarm_eventstudy_drought2012.csv
#   Analysis/did/did_2x2_baseline_sensitivity_drought2012.csv
#   Analysis/plots/did/decomposition_Drought_2012_farm_nonfarm.png

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(readr); library(fixest); library(ggplot2)
})

# --- county master: outcomes, cohort variable, population -------------------
master <- read_csv("Data/county_level_master.csv",
                   show_col_types = FALSE, progress = FALSE) %>%
  distinct(fips_code, Year, State, Is_Extreme_Drought, PCPI_Real, Population) %>%
  mutate(fips_code = formatC(as.integer(fips_code), width = 5, flag = "0"))

# --- BEA farm / total earnings (thousands, nominal) ------------------------
bea <- read_csv("Data/County_Agriculture/bea_cainc5n_earnings_raw.csv",
                col_types = cols(fips_code = col_character(),
                                 Year = col_integer(),
                                 value = col_character(),
                                 .default = col_guess())) %>%
  mutate(fips_code = formatC(as.integer(fips_code), width = 5, flag = "0"),
         value = suppressWarnings(as.numeric(gsub(",", "", value)))) %>%
  select(fips_code, Year, series, value) %>%
  pivot_wider(names_from = series, values_from = value)

cpi <- read.csv("Data/State_Policy_Data/us_cpi_annual.csv")
cpi_2023 <- cpi$CPI_Value[cpi$Year == 2023]
cpi <- cpi %>% mutate(CPI_Factor = cpi_2023 / CPI_Value) %>% select(Year, CPI_Factor)

d <- master %>%
  filter(Year >= 2001, Year <= 2023) %>%
  inner_join(bea, by = c("fips_code", "Year")) %>%
  left_join(cpi, by = "Year") %>%
  mutate(Farm_PC_Real = farm_earnings * 1000 / Population * CPI_Factor,
         NonFarm_PCPI_Real = PCPI_Real - Farm_PC_Real)

# --- cohorts: identical construction to Code/run_did_analysis.R ------------
cohorts <- master %>%
  filter(Year >= 2011, Year <= 2023, !is.na(Is_Extreme_Drought)) %>%
  group_by(fips_code) %>%
  summarise(first_event = suppressWarnings(min(Year[Is_Extreme_Drought == 1], na.rm = TRUE)),
            .groups = "drop") %>%
  mutate(first_event = if_else(is.finite(first_event), first_event, NA_real_),
         cohort = if_else(is.na(first_event), 0L, as.integer(first_event)))

treated_fips <- cohorts$fips_code[cohorts$cohort == 2012L]
control_fips <- cohorts$fips_code[cohorts$cohort == 0L]

d <- d %>%
  filter(fips_code %in% c(treated_fips, control_fips)) %>%
  mutate(Treated = as.integer(fips_code %in% treated_fips))
cat(sprintf("Sample: %d treated, %d control counties matched to BEA farm data\n",
            n_distinct(d$fips_code[d$Treated == 1]),
            n_distinct(d$fips_code[d$Treated == 0])))

# --- event studies, ref = 2011, sample 2001-2023 ---------------------------
outcome_labels <- c(PCPI_Real = "Total (PCPI_Real)",
                    Farm_PC_Real = "Farm earnings per capita",
                    NonFarm_PCPI_Real = "Nonfarm income per capita")

run_es <- function(outcome) {
  dd <- d %>% filter(!is.na(.data[[outcome]]), is.finite(.data[[outcome]]))
  m <- feols(as.formula(paste0(outcome, " ~ i(Year, Treated, ref = 2011) | fips_code + Year")),
             data = dd, cluster = "State")
  ct <- as.data.frame(coeftable(m))
  data.frame(Event = "Drought_2012", Outcome = outcome,
             Year = as.integer(gsub("Year::(\\d+):Treated", "\\1", rownames(ct))),
             Estimate = ct[, 1], Std_Error = ct[, 2], p_value = ct[, 4],
             N = nobs(m), Reference_Year = 2011L, Cluster = "State",
             row.names = NULL) %>%
    bind_rows(data.frame(Event = "Drought_2012", Outcome = outcome, Year = 2011L,
                         Estimate = 0, Std_Error = 0, p_value = NA_real_,
                         N = nobs(m), Reference_Year = 2011L, Cluster = "State")) %>%
    arrange(Year)
}

es <- bind_rows(lapply(names(outcome_labels), run_es))
write_csv(es, "Analysis/did/did_farm_nonfarm_eventstudy_drought2012.csv")

# --- 2x2 baseline sensitivity by outcome -----------------------------------
sens <- list()
for (y in names(outcome_labels)) {
  for (start in c(2011L, 2010L, 2009L, 2007L, 2002L)) {
    dd <- d %>%
      filter(Year >= start, !is.na(.data[[y]]), is.finite(.data[[y]])) %>%
      mutate(Treated_x_Post = Treated * as.integer(Year >= 2012L))
    m <- feols(as.formula(paste0(y, " ~ Treated_x_Post | fips_code + Year")),
               data = dd, cluster = "State")
    ct <- coeftable(m)
    sens[[paste(y, start)]] <- data.frame(
      Event = "Drought_2012", Outcome = y, Pre_Period_Start = start,
      ATT = ct[1, 1], Std_Error = ct[1, 2], p_value = ct[1, 4], N = nobs(m))
  }
}
sens <- bind_rows(sens)
write_csv(sens, "Analysis/did/did_2x2_baseline_sensitivity_drought2012.csv")
cat("\nBaseline sensitivity (post = 2012-2023):\n")
print(as.data.frame(sens %>% mutate(across(c(ATT, Std_Error), ~round(.x, 1)),
                                    p_value = round(p_value, 4))))

# --- figure: small multiples, shared scale ---------------------------------
es_plot <- es %>%
  mutate(Component = factor(outcome_labels[Outcome], levels = unname(outcome_labels)))
p <- ggplot(es_plot, aes(x = Year, y = Estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = 2011.5, linetype = "dotted", color = "grey60") +
  geom_pointrange(aes(ymin = Estimate - 1.96 * Std_Error,
                      ymax = Estimate + 1.96 * Std_Error),
                  color = "#B2182B", linewidth = 0.4, size = 0.25) +
  facet_wrap(~Component, ncol = 1) +
  scale_x_continuous(breaks = seq(2001, 2023, 2)) +
  labs(title = "Decomposing the 2012-drought income gap: farm vs nonfarm",
       subtitle = "Treated-control gap by year vs 2011 reference (2023 USD); dotted line = 2012 onset; cluster = State",
       x = "Year", y = "Coefficient (2023 USD)") +
  theme_minimal(base_size = 11)
ggsave("Analysis/plots/did/decomposition_Drought_2012_farm_nonfarm.png",
       p, width = 8, height = 7.5, dpi = 120)
cat("\nWrote Analysis/plots/did/decomposition_Drought_2012_farm_nonfarm.png\n")
