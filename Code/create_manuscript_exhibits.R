# create_manuscript_exhibits.R — drafting-time exhibits for the essay manuscripts
#
# R 4.5.2. Builds the "TBD at drafting" exhibits from Plans/exhibit_registry.md that
# need no new estimation — every number is read from certified outputs or the
# certified county master (Data/county_level_master.csv, 118,732 x 82, post-dedup).
#
# Outputs:
#   1. Analysis/delta/transition_episode_counts.csv        (E2-T1 support: episode counts)
#   2. Analysis/policy/concentration_topshares.csv         (E3-T6: burden shares by vuln)
#   3. Analysis/policy/fig_concentration_lorenz.png        (E3-F6 / policy Fig P1)
#   4. Analysis/persistent_exposure/fig_heat_saturation.png (E2-F4: level gap, no widening)
#   5. Analysis/plots/essay_diagrams/fig_adjustment_regimes.png (E2-F1: concept diagram)
#   6. Analysis/did/fig_treated_map.png                    (E1-F1; only if usmap available)
#
# Test: Code/tests/test_manuscript_exhibits.R

suppressMessages({ library(dplyr); library(ggplot2) })

master_path <- "Data/county_level_master.csv"
stopifnot(file.exists(master_path))

log_lines <- c(sprintf("create_manuscript_exhibits.R run %s | R %s",
                       format(Sys.time(), "%Y-%m-%d %H:%M"), getRversion()))

# ---------------------------------------------------------------------------
# 1. Transition episode counts (E2-T1)
# Onset = 0->1, Exit = 1->0, Persist = 1->1 within county, 2011-2023 window
# (matching the delta family's within-county transition semantics).
# ---------------------------------------------------------------------------
m <- read.csv(master_path, stringsAsFactors = FALSE) %>%
  filter(Year >= 2011, Year <= 2023)

hazards <- c(Drought = "Is_Extreme_Drought", Heat = "High_CDD",
             Cold = "High_HDD")
hazards <- hazards[unname(hazards) %in% names(m)]

count_transitions <- function(d, var) {
  d %>%
    select(fips_code, Year, val = all_of(var)) %>%
    filter(!is.na(val)) %>%
    arrange(fips_code, Year) %>%
    group_by(fips_code) %>%
    mutate(lag_val = lag(val), gap_ok = (Year - lag(Year)) == 1) %>%
    ungroup() %>%
    filter(!is.na(lag_val), gap_ok) %>%
    summarise(
      onset   = sum(lag_val == 0 & val == 1),
      exit    = sum(lag_val == 1 & val == 0),
      persist = sum(lag_val == 1 & val == 1),
      calm    = sum(lag_val == 0 & val == 0),
      county_years = n(),
      counties_ever = n_distinct(fips_code[val == 1 | lag_val == 1])
    )
}

trans <- bind_rows(lapply(names(hazards), function(h) {
  count_transitions(m, hazards[[h]]) %>% mutate(hazard = h, variable = hazards[[h]])
})) %>% select(hazard, variable, everything())

write.csv(trans, "Analysis/delta/transition_episode_counts.csv", row.names = FALSE)
log_lines <- c(log_lines, sprintf("transition_episode_counts: %d hazards, window 2011-2023", nrow(trans)))

# ---------------------------------------------------------------------------
# 2 + 3. Burden concentration: top shares + Lorenz figure (E3-T6 / E3-F6 / Fig P1)
# Reads the policy family's concentration_curve.csv (run_policy_sufficient_stats.R).
# Counties are ranked most-vulnerable-first; cum_burden_share at cum_pop_share = q
# is the share of measured burden borne by the most vulnerable q of population.
# ---------------------------------------------------------------------------
cc <- read.csv("Analysis/policy/concentration_curve.csv", stringsAsFactors = FALSE)

share_at <- function(d, q) {
  d <- d[order(d$cum_pop_share), ]
  approx(x = c(0, d$cum_pop_share), y = c(0, d$cum_burden_share), xout = q,
         ties = "ordered")$y
}
topshares <- cc %>%
  group_by(band) %>%
  group_modify(~ tibble::tibble(
    top10_pop_burden_share = share_at(.x, 0.10),
    top20_pop_burden_share = share_at(.x, 0.20),
    top50_pop_burden_share = share_at(.x, 0.50),
    n_counties = nrow(.x),
    # Bands built from a uniform per-capita coefficient have burden share ==
    # population share BY CONSTRUCTION; their curve is the diagonal and carries
    # no information about vulnerability concentration. Flag them.
    uniform_per_capita = max(abs(.x$cum_burden_share - .x$cum_pop_share)) < 1e-9
  )) %>% ungroup()

write.csv(topshares, "Analysis/policy/concentration_topshares.csv", row.names = FALSE)
log_lines <- c(log_lines, paste("concentration_topshares:",
  paste(sprintf("%s top10=%.2f%s", topshares$band, topshares$top10_pop_burden_share,
                ifelse(topshares$uniform_per_capita, " (uniform-by-construction)", "")),
        collapse = "; ")))

uniform_bands <- topshares$band[topshares$uniform_per_capita]
cc_plot <- cc %>% filter(!band %in% uniform_bands)

band_labels <- c(cold_cumulative_employment = "Recurring-cold employment",
                 cold_medicare_annual = "Cold Medicare cost",
                 heat_medicare_annual = "Heat Medicare cost",
                 heat_exposure_personyears_descriptive = "Heat exposure (person-years)")
cc_plot$band_lab <- ifelse(cc_plot$band %in% names(band_labels),
                           band_labels[cc_plot$band], cc_plot$band)

p_lorenz <- ggplot(cc_plot, aes(cum_pop_share, cum_burden_share, colour = band_lab)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey60") +
  geom_line(linewidth = 0.9) +
  scale_x_continuous(labels = scales::percent) +
  scale_y_continuous(labels = scales::percent) +
  labs(x = "Cumulative population share (most vulnerable first)",
       y = "Cumulative share of measured burden",
       colour = NULL,
       title = "Concentration of measured climate burden by county vulnerability",
       subtitle = "Descriptive accounting (coefficients x exposure x population), not causal welfare weights.\nUniform-per-capita bands (2012 income event, drought debt scar) are diagonal by construction and omitted.") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", plot.title.position = "plot")
ggsave("Analysis/policy/fig_concentration_lorenz.png", p_lorenz,
       width = 7.5, height = 5.5, dpi = 200, bg = "white")
log_lines <- c(log_lines, "fig_concentration_lorenz.png written")

# ---------------------------------------------------------------------------
# 4. Heat saturation panel (E2-F4): cumulative-dose contrast, HDD vs CDD
# The defensible saturation evidence is the DOSE contrast (certified
# cumulative_dose_marginal.csv): cold's binned 10+ vs 1-3 employment contrast is
# large and significant (compounding) while heat's is small and insignificant
# (no growth in dose). NOTE: the county chronic-heat debt-gap dynamic series
# (persistent_exposure_dynamic.csv) is negative and WIDENS - the region-confounded
# CDD pattern did_results.md demotes to suggestive - and must NOT be used as the
# saturation exhibit (finding logged in Text/final_writing/TK_resolutions.md).
# ---------------------------------------------------------------------------
dose <- read.csv("Analysis/cumulative_dose/cumulative_dose_marginal.csv",
                 stringsAsFactors = FALSE)
emp <- dose %>%
  filter(outcome == "Civilian_Employed", weighting == "Unweighted",
         shock %in% c("HDD", "CDD"),
         quantity %in% c("ME_quadratic_at_1", "ME_quadratic_at_5", "ME_quadratic_at_10",
                         "binned_10plus_minus_1to3")) %>%
  mutate(se = std.error,
         hazard = ifelse(shock == "HDD", "Cold (HDD)", "Heat (CDD)"),
         kind = ifelse(quantity == "binned_10plus_minus_1to3",
                       "Binned contrast: 10+ vs 1-3 years", "Smooth quadratic marginal effect"),
         at = dplyr::recode(quantity, ME_quadratic_at_1 = 1, ME_quadratic_at_5 = 5,
                            ME_quadratic_at_10 = 10, binned_10plus_minus_1to3 = 10))
stopifnot(nrow(emp) == 8)

# Subtitle numbers computed from the data (no manual transcription).
b_cold <- emp %>% filter(shock == "HDD", quantity == "binned_10plus_minus_1to3")
b_heat <- emp %>% filter(shock == "CDD", quantity == "binned_10plus_minus_1to3")
sat_sub <- sprintf(
  "Within-county exposure-history contrasts (county+year FE). Binned 10+ vs 1-3 years:\ncold %s jobs (p=%.1e); heat %s jobs (p=%.2f) - no negative dose gradient. Smooth-quadratic MEs flat for both.",
  format(round(b_cold$estimate), big.mark = ","), b_cold$p.value,
  format(round(b_heat$estimate), big.mark = ","), b_heat$p.value)

p_sat <- ggplot(emp, aes(at, estimate, colour = hazard, shape = kind)) +
  geom_hline(yintercept = 0, colour = "grey60") +
  geom_pointrange(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
                  position = position_dodge(width = 0.8), linewidth = 0.6) +
  scale_x_continuous(breaks = c(1, 5, 10), labels = c("1", "5", "10")) +
  scale_colour_manual(values = c("Cold (HDD)" = "#2c5f7c", "Heat (CDD)" = "#c96f4a")) +
  labs(x = "Cumulative shock-years", y = "Employment effect (jobs, unweighted)",
       colour = NULL, shape = NULL,
       title = "Cold compounds with cumulative exposure; heat does not",
       subtitle = sat_sub) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", plot.title.position = "plot",
        plot.subtitle = element_text(size = 8.5))
ggsave("Analysis/persistent_exposure/fig_heat_saturation.png", p_sat,
       width = 8, height = 5.5, dpi = 200, bg = "white")
log_lines <- c(log_lines, "fig_heat_saturation.png written (dose-contrast spec, HDD vs CDD employment)")

# ---------------------------------------------------------------------------
# 5. Adjustment-regimes concept diagram (E2-F1)
# Pure schematic - stylized paths, no data.
# ---------------------------------------------------------------------------
t <- 0:10
shock_on <- t >= 2 & t <= 4
regimes <- bind_rows(
  tibble::tibble(regime = "Reversal",   t = t, y = ifelse(shock_on, -1, 0)),
  tibble::tibble(regime = "Scarring",   t = t, y = ifelse(t < 2, 0, ifelse(shock_on, -1, -0.6))),
  tibble::tibble(regime = "Saturation", t = t, y = ifelse(t < 2, 0, pmax(-1, -0.5 * (pmin(t, 4) - 1)))),
  tibble::tibble(regime = "Compounding", t = t, y = ifelse(t < 2, 0, -0.12 * (t - 1)^1.6))
) %>% mutate(regime = factor(regime, levels = c("Reversal", "Scarring", "Saturation", "Compounding")))

p_reg <- ggplot(regimes, aes(t, y)) +
  annotate("rect", xmin = 2, xmax = 4, ymin = -Inf, ymax = Inf, fill = "grey85", alpha = 0.6) +
  geom_hline(yintercept = 0, colour = "grey60", linetype = "dashed") +
  geom_line(colour = "#2c5f7c", linewidth = 1) +
  facet_wrap(~regime, nrow = 1) +
  labs(x = "Time (shaded = shock episode(s))", y = "Outcome relative to no-shock path",
       title = "Four adjustment regimes",
       subtitle = "Reversal: exit offsets onset. Scarring: exit fails to offset. Saturation: level gap, no growth in dose.\nCompounding: marginal harm grows with exposure.") +
  theme_minimal(base_size = 11) +
  theme(axis.text.y = element_blank(), plot.title.position = "plot")
dir.create("Analysis/plots/essay_diagrams", showWarnings = FALSE, recursive = TRUE)
ggsave("Analysis/plots/essay_diagrams/fig_adjustment_regimes.png", p_reg,
       width = 10, height = 3.2, dpi = 200, bg = "white")
log_lines <- c(log_lines, "fig_adjustment_regimes.png written")

# ---------------------------------------------------------------------------
# 6. Treated / never-exposed county map (E1-F1) - only if usmap is installed.
# Cohort logic mirrors run_did_analysis.R: 2011-2023 window, first
# Is_Extreme_Drought onset in 2012 vs zero onsets in the window.
# ---------------------------------------------------------------------------
if (requireNamespace("usmap", quietly = TRUE)) {
  fe <- m %>% filter(!is.na(Is_Extreme_Drought)) %>%
    group_by(fips_code) %>%
    summarise(first_event = ifelse(any(Is_Extreme_Drought == 1),
                                   min(Year[Is_Extreme_Drought == 1]), NA_integer_),
              .groups = "drop")
  map_df <- fe %>%
    mutate(fips = formatC(as.integer(fips_code), width = 5, flag = "0"),
           group = case_when(first_event == 2012 ~ "Treated (first onset 2012)",
                             is.na(first_event)  ~ "Never exposed (2011-2023)",
                             TRUE                ~ "Other onset year")) %>%
    select(fips, group)
  n_treated <- sum(map_df$group == "Treated (first onset 2012)")
  p_map <- usmap::plot_usmap(regions = "counties", data = map_df, values = "group",
                             linewidth = 0.05) +
    scale_fill_manual(values = c("Treated (first onset 2012)" = "#b3452c",
                                 "Never exposed (2011-2023)" = "#c9d7e0",
                                 "Other onset year" = "grey88"),
                      na.value = "white", name = NULL) +
    labs(title = "2012 drought natural experiment: treated and never-exposed counties",
         subtitle = sprintf("%d first-onset-2012 counties (Georgia, Mountain West, Plains) vs never-exposed controls", n_treated)) +
    theme(legend.position = "bottom")
  ggsave("Analysis/did/fig_treated_map.png", p_map, width = 8.5, height = 6, dpi = 200,
         bg = "white")
  log_lines <- c(log_lines, sprintf("fig_treated_map.png written (%d treated)", n_treated))
} else {
  log_lines <- c(log_lines, "usmap not installed - map skipped")
}

writeLines(log_lines, "Analysis/policy/build_logs/create_manuscript_exhibits_log.txt")
cat(paste(log_lines, collapse = "\n"), "\n")
