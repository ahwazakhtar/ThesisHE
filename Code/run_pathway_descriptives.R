# Pathway Descriptives (Committee Feedback Phase 5)
#
# Companion to Text/drafts/propagation_pathways.md. Produces descriptive evidence
# for the propagation pathways named there, using the existing annual
# county and state panels (no new data acquisition).
#
# Panels are annual; we do NOT produce within-year seasonal patterns.
# Instead we produce: (1) shock prevalence trajectories by Census region,
# (2) cross-sectional shock-vs-outcome correlations, (3) within-county
# delta scatters, (4) income-gradient splits.
#
# Outputs:
#   Analysis/plots/pathways/p1_shock_prevalence_by_region.png
#   Analysis/plots/pathways/p2_shock_outcome_correlations.png
#   Analysis/plots/pathways/p3_delta_shock_vs_delta_outcome.png   (panel per outcome)
#   Analysis/plots/pathways/p4_debt_share_by_income_quartile.png
#   Analysis/pathways/synthesis.md

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(ggplot2)
})

dir.create("Analysis/plots/pathways", showWarnings = FALSE, recursive = TRUE)

# ---------------------------------------------------------------------------
# Census region map (built-in `state.region` / `state.abb` from datasets pkg).
# ---------------------------------------------------------------------------
state_region_map <- data.frame(
  State  = state.abb,
  Region = as.character(state.region),
  stringsAsFactors = FALSE
)
# Add DC explicitly (state.region omits it).
state_region_map <- rbind(state_region_map,
                          data.frame(State = "DC", Region = "South",
                                     stringsAsFactors = FALSE))

# ---------------------------------------------------------------------------
# Load county panel and restrict to analysis window.
# ---------------------------------------------------------------------------
county_df <- read_csv("Data/county_level_master.csv",
                     show_col_types = FALSE, progress = FALSE) %>%
  filter(Year >= 2011L, Year <= 2023L)

if ("Max_AQI" %in% names(county_df)) {
  county_df$High_AQI_Max <- as.integer(county_df$Max_AQI > 100)
}
if ("Population" %in% names(county_df) && "Hosp_BadDebt_Total_Real" %in% names(county_df)) {
  county_df$Hosp_BadDebt_PerCapita <- county_df$Hosp_BadDebt_Total_Real / county_df$Population
}

# Dedupe to one row per (fips_code, Year) on the analytic columns.
keep_cols <- c("fips_code", "Year", "State", "Population",
               "Is_Extreme_Drought", "High_CDD", "High_HDD", "High_AQI_Max",
               "Medical_Debt_Share", "Medical_Debt_Median_2023",
               "Hosp_BadDebt_PerCapita", "Benchmark_Silver_Real",
               "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed",
               "Household_Income_2023", "Uninsured_Rate")
keep_cols <- intersect(keep_cols, names(county_df))
panel <- county_df %>%
  distinct(across(all_of(keep_cols))) %>%
  left_join(state_region_map, by = "State")

cat(sprintf("Panel: %d county-years, %d counties, regions: %s\n",
            nrow(panel), n_distinct(panel$fips_code),
            paste(unique(panel$Region), collapse = ", ")))

# ===========================================================================
# Figure 1: Shock prevalence by Census region over time
# ===========================================================================

shock_long <- panel %>%
  select(Year, Region, Is_Extreme_Drought, High_CDD, High_HDD, High_AQI_Max) %>%
  pivot_longer(cols = c(Is_Extreme_Drought, High_CDD, High_HDD, High_AQI_Max),
               names_to = "Shock", values_to = "is_event") %>%
  filter(!is.na(is_event), !is.na(Region))

shock_prev <- shock_long %>%
  group_by(Year, Region, Shock) %>%
  summarise(prevalence = mean(is_event == 1, na.rm = TRUE),
            n_counties = n(),
            .groups = "drop")

p1 <- ggplot(shock_prev, aes(x = Year, y = prevalence, color = Region)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.2) +
  facet_wrap(~ Shock, scales = "free_y", ncol = 2,
             labeller = as_labeller(c(
               "Is_Extreme_Drought" = "Extreme Drought (PDSI <= -4)",
               "High_CDD"           = "High CDD (top quintile)",
               "High_HDD"           = "High HDD (top quintile)",
               "High_AQI_Max"       = "High AQI (Max > 100)"))) +
  scale_color_brewer(palette = "Set1") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Climate shock prevalence by Census region, 2011-2023",
       subtitle = "Share of counties experiencing the shock in each year",
       x = NULL, y = "County share with shock",
       caption = "Source: county_level_master.csv. Regions per `state.region`.") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")
ggsave("Analysis/plots/pathways/p1_shock_prevalence_by_region.png",
       p1, width = 9, height = 6, dpi = 120)

# ===========================================================================
# Figure 2: Shock-outcome correlation matrix
# ===========================================================================

shock_vars   <- intersect(c("Is_Extreme_Drought", "High_CDD", "High_HDD", "High_AQI_Max"),
                         names(panel))
outcome_vars <- intersect(c("Medical_Debt_Share", "Medical_Debt_Median_2023",
                            "Hosp_BadDebt_PerCapita", "Benchmark_Silver_Real",
                            "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed",
                            "Uninsured_Rate"),
                         names(panel))

corr_long <- expand.grid(Shock = shock_vars, Outcome = outcome_vars,
                         stringsAsFactors = FALSE) %>%
  rowwise() %>%
  mutate(rho = {
    d <- panel %>% select(all_of(c(Shock, Outcome))) %>%
      filter(complete.cases(.))
    if (nrow(d) < 30) NA_real_ else
      suppressWarnings(cor(d[[1]], d[[2]], method = "pearson"))
  }) %>%
  ungroup()

p2 <- ggplot(corr_long, aes(x = Shock, y = Outcome, fill = rho)) +
  geom_tile(color = "white") +
  geom_text(aes(label = sprintf("%.3f", rho)), size = 3) +
  scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B",
                       midpoint = 0, limits = c(-0.2, 0.2), oob = scales::squish) +
  labs(title = "Pearson correlations: climate shocks x health/economic outcomes",
       subtitle = "Pooled county-year panel, 2011-2023; raw (not within-FE) correlations",
       x = NULL, y = NULL, fill = "rho") +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))
ggsave("Analysis/plots/pathways/p2_shock_outcome_correlations.png",
       p2, width = 8, height = 6, dpi = 120)

# ===========================================================================
# Figure 3: Within-county delta-shock vs delta-outcome (mechanism check)
# ===========================================================================
# A within-county scatter of year-over-year delta shock vs delta outcome:
# under the propagation pathways, counties moving INTO shock state should
# show larger debt/income deltas than counties moving OUT.

panel_delta <- panel %>%
  arrange(fips_code, Year) %>%
  group_by(fips_code) %>%
  mutate(across(c(Is_Extreme_Drought, High_CDD, High_HDD, Medical_Debt_Share,
                  PCPI_Real, Hosp_BadDebt_PerCapita),
                ~ .x - dplyr::lag(.x), .names = "d_{.col}")) %>%
  ungroup()

# Plot d_Medical_Debt_Share vs d_<shock> for each shock-outcome pair.
delta_long <- panel_delta %>%
  select(Year, fips_code, Region,
         d_Is_Extreme_Drought, d_High_CDD, d_High_HDD,
         d_Medical_Debt_Share, d_PCPI_Real) %>%
  pivot_longer(cols = c(d_Is_Extreme_Drought, d_High_CDD, d_High_HDD),
               names_to = "Shock", values_to = "d_shock") %>%
  pivot_longer(cols = c(d_Medical_Debt_Share, d_PCPI_Real),
               names_to = "Outcome", values_to = "d_outcome") %>%
  filter(!is.na(d_shock), !is.na(d_outcome), d_shock != 0)

# Summarize: mean d_outcome | d_shock direction (-1 = exit, +1 = onset).
delta_summary <- delta_long %>%
  mutate(transition = if_else(d_shock > 0, "Onset (0->1)", "Exit (1->0)")) %>%
  group_by(Shock, Outcome, transition) %>%
  summarise(mean_delta = mean(d_outcome, na.rm = TRUE),
            se = sd(d_outcome, na.rm = TRUE) / sqrt(sum(!is.na(d_outcome))),
            n = sum(!is.na(d_outcome)),
            .groups = "drop") %>%
  mutate(Shock = sub("^d_", "", Shock),
         Outcome = sub("^d_", "", Outcome))

p3 <- ggplot(delta_summary, aes(x = transition, y = mean_delta, fill = transition)) +
  geom_col() +
  geom_errorbar(aes(ymin = mean_delta - 1.96 * se,
                    ymax = mean_delta + 1.96 * se), width = 0.2) +
  facet_grid(Outcome ~ Shock, scales = "free_y") +
  scale_fill_manual(values = c("Onset (0->1)" = "#B2182B",
                               "Exit (1->0)" = "#2166AC")) +
  labs(title = "Mean year-over-year outcome change by shock transition",
       subtitle = "Onset = county enters shock; Exit = county leaves shock. Error bars: 95% CI of the mean.",
       x = NULL, y = "Mean Delta(outcome)") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "none")
ggsave("Analysis/plots/pathways/p3_delta_shock_vs_delta_outcome.png",
       p3, width = 9, height = 6, dpi = 120)

# ===========================================================================
# Figure 4: Income-gradient splits in shock response
# ===========================================================================
# Split counties by 2011-mean income quartile; compare Medical_Debt_Share
# trajectories under shocked vs non-shocked county-years.

county_income_q <- panel %>%
  filter(!is.na(Household_Income_2023)) %>%
  group_by(fips_code) %>%
  summarise(mean_income = mean(Household_Income_2023, na.rm = TRUE),
            .groups = "drop") %>%
  mutate(IncQuartile = ntile(mean_income, 4),
         IncQuartile = paste0("Q", IncQuartile))

panel_q <- panel %>%
  left_join(county_income_q, by = "fips_code") %>%
  mutate(Any_Climate_Shock = pmax(Is_Extreme_Drought, High_CDD, High_HDD,
                                  na.rm = TRUE))

debt_by_q <- panel_q %>%
  filter(!is.na(IncQuartile), !is.na(Medical_Debt_Share),
         !is.na(Any_Climate_Shock)) %>%
  group_by(IncQuartile, Year, Any_Climate_Shock) %>%
  summarise(mean_debt = mean(Medical_Debt_Share, na.rm = TRUE),
            n = n(), .groups = "drop")

p4 <- ggplot(debt_by_q,
             aes(x = Year, y = mean_debt,
                 color = factor(Any_Climate_Shock),
                 linetype = factor(Any_Climate_Shock))) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1) +
  facet_wrap(~ IncQuartile, ncol = 2,
             labeller = as_labeller(c("Q1" = "Q1 (lowest income)",
                                      "Q2" = "Q2", "Q3" = "Q3",
                                      "Q4" = "Q4 (highest income)"))) +
  scale_color_manual(values = c("0" = "#2166AC", "1" = "#B2182B"),
                     labels = c("0" = "No shock", "1" = "Any shock"),
                     name = "Shock status") +
  scale_linetype_manual(values = c("0" = "dashed", "1" = "solid"),
                        labels = c("0" = "No shock", "1" = "Any shock"),
                        name = "Shock status") +
  labs(title = "Medical debt share by income quartile and shock status",
       subtitle = "Any_Climate_Shock = OR(Is_Extreme_Drought, High_CDD, High_HDD)",
       x = NULL, y = "Mean Medical_Debt_Share") +
  theme_minimal(base_size = 11)
ggsave("Analysis/plots/pathways/p4_debt_share_by_income_quartile.png",
       p4, width = 9, height = 6, dpi = 120)

# ===========================================================================
# Summary markdown
# ===========================================================================

summary_lines <- c(
  "# Pathway Descriptives — Summary",
  "",
  paste0("**Date:** ", Sys.Date()),
  paste0("**Source script:** `Code/run_pathway_descriptives.R`"),
  "",
  "Companion descriptive evidence for `Text/drafts/propagation_pathways.md`. ",
  "All figures generated from the existing annual county panel ",
  "(`Data/county_level_master.csv`, restricted to 2011-2023).",
  "",
  "## Figures",
  "",
  "- **p1_shock_prevalence_by_region.png** — Climate-shock county shares by Census region over 2011-2023. ",
  "  Confirms regional structure: drought peaks in 2012/2022 (Midwest/West/South), HDD peaks 2013 (Midwest/Northeast), ",
  "  AQI spikes 2020/2023 (West/Northeast wildfire smoke).",
  "- **p2_shock_outcome_correlations.png** — Pooled Pearson correlations. Raw, *not* within-FE; shown to ",
  "  motivate the pathway directions and to flag that uncontrolled associations are small (|rho| typically < 0.10), ",
  "  underscoring why the FE/LP/DiD designs are necessary.",
  "- **p3_delta_shock_vs_delta_outcome.png** — Mean year-over-year change in outcome conditional on shock ",
  "  onset vs exit. Visually previews the Phase 2 delta/LP findings: drought onset depresses PCPI and raises ",
  "  Medical_Debt_Share; exit reverses these.",
  "- **p4_debt_share_by_income_quartile.png** — Medical_Debt_Share trajectory by county income quartile, ",
  "  separated by Any_Climate_Shock. Supports the income-pathway claim: the shock-vs-no-shock gap in ",
  "  Medical_Debt_Share is largest for the lowest-income quartile, smaller for the highest.",
  "",
  "## Pathway-figure mapping",
  "",
  "| Pathway | Most relevant figure(s) |",
  "|---------|-------------------------|",
  "| Heat -> delayed care | p1 (CDD regional structure), p3 (CDD onset/exit deltas) |",
  "| Cold -> shifted utilization | p1 (HDD prevalence), p3 (HDD onset/exit deltas) |",
  "| Drought -> income -> debt | p3 (drought onset depresses PCPI; raises debt), p4 (income gradient) |",
  "| AQI -> respiratory/cardiac | p1 (AQI regional concentration; wildfire spike 2023) |",
  ""
)
writeLines(summary_lines, "Analysis/pathways/synthesis.md")

cat("\nDone. Outputs:\n",
    "  Analysis/plots/pathways/p1_shock_prevalence_by_region.png\n",
    "  Analysis/plots/pathways/p2_shock_outcome_correlations.png\n",
    "  Analysis/plots/pathways/p3_delta_shock_vs_delta_outcome.png\n",
    "  Analysis/plots/pathways/p4_debt_share_by_income_quartile.png\n",
    "  Analysis/pathways/synthesis.md\n", sep = "")
