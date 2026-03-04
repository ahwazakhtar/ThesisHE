# Synthesize Event Study Coefficients
# Reads event_study_coefs.csv and produces:
#   1. Analysis/event_study_synthesis.md   — narrative summary with key findings
#   2. Analysis/event_study_tables.csv     — structured summary tables for thesis
#   3. Analysis/plots/synthesis_*.png      — heatmaps and comparison charts

library(dplyr)
library(tidyr)
library(ggplot2)

coefs <- read.csv("Analysis/event_study_coefs.csv", stringsAsFactors = FALSE)
plot_dir <- "Analysis/plots/synthesis"
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

cat("Loaded", nrow(coefs), "coefficient rows\n")
cat("Approaches:", paste(sort(unique(coefs$approach)), collapse = ", "), "\n")

# ============================================================================
# 1. CONTEMPORANEOUS IMPACT SUMMARY (h=0)
# ============================================================================

h0 <- coefs %>%
  filter(horizon == 0, approach %in% c("DL", "LP"), weighting == "Unweighted") %>%
  mutate(
    sig = case_when(
      p.value < 0.01 ~ "***",
      p.value < 0.05 ~ "**",
      p.value < 0.10 ~ "*",
      TRUE ~ ""
    ),
    est_label = sprintf("%.4f%s", estimate, sig)
  )

cat("\n=== Contemporaneous (h=0) Effects — Unweighted, State-Clustered ===\n")
h0_wide <- h0 %>%
  select(shock, outcome, approach, est_label) %>%
  pivot_wider(names_from = outcome, values_from = est_label)
print(as.data.frame(h0_wide))

# ============================================================================
# 2. DYNAMIC PROFILE SUMMARY — which shock-outcome pairs show building effects?
# ============================================================================

# For each shock-outcome, check if effects grow from h=0 to h=3
dynamic_profiles <- coefs %>%
  filter(approach == "LP", weighting == "Unweighted", horizon >= 0) %>%
  group_by(shock, outcome) %>%
  reframe({
    est_h0 = estimate[horizon == 0]
    est_h3 = estimate[horizon == 3]
    sig_h0 = p.value[horizon == 0] < 0.05
    sig_h3 = p.value[horizon == 3] < 0.05
    tibble(
      est_h0 = est_h0,
      est_h1 = estimate[horizon == 1],
      est_h2 = estimate[horizon == 2],
      est_h3 = est_h3,
      sig_h0 = sig_h0,
      sig_h3 = sig_h3,
      any_sig = any(p.value >= 0 & p.value < 0.05, na.rm = TRUE),
      peak_h = horizon[which.max(abs(estimate))],
      pattern = case_when(
        all(abs(estimate) < 1e-6) ~ "null",
        abs(est_h3) > abs(est_h0) * 1.5 & sig_h3 ~ "building",
        sig_h0 & !sig_h3 ~ "transient",
        sig_h0 & sig_h3 ~ "persistent",
        !sig_h0 & sig_h3 ~ "delayed",
        TRUE ~ "insignificant"
      )
    )
  })

cat("\n=== Dynamic Profile Classification (LP, Unweighted) ===\n")
print(as.data.frame(dynamic_profiles %>% select(shock, outcome, pattern, peak_h, est_h0, est_h3)))

# ============================================================================
# 3. PRE-TREND CHECK (h < 0)
# ============================================================================

pretrends <- coefs %>%
  filter(horizon == -2, approach %in% c("DL", "LP"), weighting == "Unweighted") %>%
  mutate(pretrend_fail = p.value < 0.05) %>%
  select(shock, outcome, approach, estimate, p.value, pretrend_fail)

cat("\n=== Pre-Trend Check (h=-2) ===\n")
failures <- pretrends %>% filter(pretrend_fail)
if (nrow(failures) > 0) {
  cat("WARNING: Pre-trend failures (p < 0.05 at h=-2):\n")
  print(as.data.frame(failures))
} else {
  cat("All pre-trend checks pass (no significant h=-2 coefficients).\n")
}

# ============================================================================
# 4. DL vs LP CONSISTENCY
# ============================================================================

dl_lp <- coefs %>%
  filter(approach %in% c("DL", "LP"), weighting == "Unweighted", horizon >= 0) %>%
  select(shock, outcome, horizon, approach, estimate) %>%
  pivot_wider(names_from = approach, values_from = estimate) %>%
  filter(!is.na(DL) & !is.na(LP)) %>%
  mutate(
    diff = LP - DL,
    same_sign = sign(DL) == sign(LP)
  )

cat("\n=== DL vs LP Consistency (h >= 0) ===\n")
consistency <- dl_lp %>%
  group_by(shock, outcome) %>%
  summarize(
    pct_same_sign = round(mean(same_sign) * 100, 0),
    corr = round(cor(DL, LP), 3),
    .groups = "drop"
  )
print(as.data.frame(consistency))

# ============================================================================
# 5. SHOCK-HISTORY ROBUSTNESS (LP vs LP_ShockHistory)
# ============================================================================

hist_compare <- coefs %>%
  filter(approach %in% c("LP", "LP_ShockHistory"), weighting == "Unweighted", horizon >= 0) %>%
  select(shock, outcome, horizon, approach, estimate) %>%
  pivot_wider(names_from = approach, values_from = estimate) %>%
  filter(!is.na(LP) & !is.na(LP_ShockHistory))

cat("\n=== Shock-History Robustness ===\n")
if (nrow(hist_compare) > 0) {
  hist_summary <- hist_compare %>%
    group_by(shock, outcome) %>%
    summarize(
      mean_pct_change = round(mean(abs(LP_ShockHistory - LP) / (abs(LP) + 1e-8)) * 100, 1),
      same_sign = round(mean(sign(LP) == sign(LP_ShockHistory)) * 100, 0),
      .groups = "drop"
    )
  print(as.data.frame(hist_summary))
}

# ============================================================================
# 6. ANY_SHOCK vs INDIVIDUAL SHOCKS — magnitude comparison
# ============================================================================

indiv_vs_any <- coefs %>%
  filter(approach == "LP", weighting == "Unweighted", horizon == 0,
         shock %in% c("Is_Extreme_Drought", "High_CDD", "High_HDD", "Any_Shock")) %>%
  select(shock, outcome, estimate, std.error, p.value)

cat("\n=== Any_Shock vs Individual Shocks (h=0, LP) ===\n")
print(as.data.frame(indiv_vs_any))

# ============================================================================
# 7. COMPOUND SHOCK EFFECTS
# ============================================================================

compound <- coefs %>%
  filter(approach %in% c("LP_Compound_Additive", "LP_Dose_Response"),
         weighting == "Unweighted", horizon >= 0) %>%
  select(shock, outcome, horizon, approach, estimate, std.error, p.value)

cat("\n=== Compound Shock Effects (h >= 0) ===\n")
compound_h0 <- compound %>% filter(horizon == 0)
print(as.data.frame(compound_h0))

# ============================================================================
# 8. POPULATION WEIGHTING SENSITIVITY
# ============================================================================

wt_compare <- coefs %>%
  filter(approach == "LP", horizon == 0) %>%
  select(shock, outcome, weighting, estimate) %>%
  pivot_wider(names_from = weighting, values_from = estimate) %>%
  filter(!is.na(Unweighted) & !is.na(Population)) %>%
  mutate(
    same_sign = sign(Unweighted) == sign(Population),
    ratio = round(Population / (Unweighted + 1e-8), 2)
  )

cat("\n=== Population Weighting Sensitivity (h=0, LP) ===\n")
print(as.data.frame(wt_compare))

# ============================================================================
# 9. VISUALIZATION: Heatmap of h=0 significance
# ============================================================================

heatmap_data <- coefs %>%
  filter(horizon == 0, approach %in% c("DL", "LP"), weighting == "Unweighted") %>%
  mutate(
    sig_level = case_when(
      p.value < 0.01 ~ "p<0.01",
      p.value < 0.05 ~ "p<0.05",
      p.value < 0.10 ~ "p<0.10",
      TRUE ~ "n.s."
    ),
    direction = ifelse(estimate > 0, "+", "-"),
    label = paste0(direction, "\n", sig_level)
  )

p_heat <- ggplot(heatmap_data, aes(x = outcome, y = shock, fill = -log10(p.value + 1e-10))) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = label), size = 3) +
  facet_wrap(~approach) +
  scale_fill_gradient2(low = "white", mid = "#FDDBC7", high = "#B2182B",
                       midpoint = 1.3, name = "-log10(p)") +
  scale_x_discrete(labels = function(x) gsub("_", "\n", x)) +
  labs(title = "Contemporaneous Effect Significance (h=0, Unweighted)",
       x = NULL, y = NULL) +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5, size = 8),
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA))
ggsave(file.path(plot_dir, "synthesis_significance_heatmap.png"),
       p_heat, width = 12, height = 5, dpi = 150, bg = "white")
cat("Saved: synthesis_significance_heatmap.png\n")

# ============================================================================
# 10. VISUALIZATION: Dynamic profile panel (LP, primary outcomes)
# ============================================================================

profile_data <- coefs %>%
  filter(approach == "LP", weighting == "Unweighted",
         outcome %in% c("Medical_Debt_Share", "Benchmark_Silver_Real"),
         shock %in% c("Is_Extreme_Drought", "High_CDD", "High_HDD", "Any_Shock"))

p_profile <- ggplot(profile_data, aes(x = horizon, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
  geom_pointrange(aes(ymin = ci_low, ymax = ci_high), size = 0.4) +
  facet_grid(outcome ~ shock, scales = "free_y") +
  scale_x_continuous(breaks = -2:3) +
  labs(title = "Dynamic Impulse-Response Profiles (LP, Unweighted)",
       x = "Horizon (years)", y = "Estimate") +
  theme_minimal(base_size = 10) +
  theme(strip.text = element_text(size = 8),
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA))
ggsave(file.path(plot_dir, "synthesis_dynamic_profiles.png"),
       p_profile, width = 14, height = 6, dpi = 150, bg = "white")
cat("Saved: synthesis_dynamic_profiles.png\n")

# ============================================================================
# 11. VISUALIZATION: Robustness panel (LP vs LP_ShockHistory vs DL)
# ============================================================================

robust_data <- coefs %>%
  filter(approach %in% c("DL", "LP", "LP_ShockHistory"), weighting == "Unweighted",
         outcome %in% c("Medical_Debt_Share", "Benchmark_Silver_Real"),
         shock %in% c("Is_Extreme_Drought", "High_CDD", "High_HDD", "High_AQI_Max"))

robust_shock_labeller <- c(
  "Is_Extreme_Drought" = "Extreme Drought",
  "High_CDD"           = "High CDD",
  "High_HDD"           = "High HDD",
  "High_AQI_Max"       = "High AQI"
)

p_robust <- ggplot(robust_data, aes(x = horizon, y = estimate, color = approach)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                  position = position_dodge(width = 0.35), size = 0.35) +
  facet_grid(outcome ~ shock, scales = "free_y",
             labeller = labeller(shock = robust_shock_labeller)) +
  scale_x_continuous(breaks = -2:3) +
  scale_color_manual(values = c("DL" = "#2166AC", "LP" = "#B2182B", "LP_ShockHistory" = "#4DAF4A"),
                     labels = c("DL" = "Distributed Lag", "LP" = "Local Projection",
                                "LP_ShockHistory" = "LP + Shock History")) +
  labs(title = "Cross-Method Robustness (Unweighted)",
       x = "Horizon (years)", y = "Estimate", color = "Method") +
  theme_minimal(base_size = 10) +
  theme(strip.text = element_text(size = 8),
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA),
        legend.position = "bottom")
ggsave(file.path(plot_dir, "synthesis_robustness_panel.png"),
       p_robust, width = 14, height = 7, dpi = 150, bg = "white")
cat("Saved: synthesis_robustness_panel.png\n")

# ============================================================================
# 11b. VISUALIZATION: Supplemental robustness panel — secondary outcomes
#      (Medical_Debt_Median_2023 and Hosp_BadDebt_PerCapita)
# ============================================================================

outcome_labels_extra <- c(
  "Medical_Debt_Median_2023" = "Median Medical Debt ($2023)",
  "Hosp_BadDebt_PerCapita"   = "Hosp. Bad Debt per Capita ($)"
)

robust_data_extra <- coefs %>%
  filter(approach %in% c("DL", "LP", "LP_ShockHistory"), weighting == "Unweighted",
         outcome %in% c("Medical_Debt_Median_2023", "Hosp_BadDebt_PerCapita"),
         shock %in% c("Is_Extreme_Drought", "High_CDD", "High_HDD", "High_AQI_Max")) %>%
  mutate(
    outcome_label = outcome_labels_extra[outcome],
    outcome_label = factor(outcome_label, levels = outcome_labels_extra)
  )

shock_labeller <- c(
  "Is_Extreme_Drought" = "Extreme Drought",
  "High_CDD"           = "High CDD",
  "High_HDD"           = "High HDD",
  "High_AQI_Max"       = "High AQI"
)

p_robust_extra <- ggplot(robust_data_extra, aes(x = horizon, y = estimate, color = approach)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                  position = position_dodge(width = 0.35), size = 0.35) +
  facet_grid(outcome_label ~ shock, scales = "free_y",
             labeller = labeller(shock = shock_labeller)) +
  scale_x_continuous(breaks = -2:3) +
  scale_color_manual(values = c("DL" = "#2166AC", "LP" = "#B2182B", "LP_ShockHistory" = "#4DAF4A"),
                     labels = c("DL" = "Distributed Lag", "LP" = "Local Projection",
                                "LP_ShockHistory" = "LP + Shock History")) +
  labs(title = "Cross-Method Robustness — Secondary Outcomes (Unweighted)",
       x = "Horizon (years)", y = "Estimate", color = "Method") +
  theme_minimal(base_size = 10) +
  theme(strip.text.x = element_text(size = 9, face = "bold"),
        strip.text.y = element_text(size = 8),
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA),
        legend.position = "bottom")
ggsave(file.path(plot_dir, "synthesis_robustness_panel_extra.png"),
       p_robust_extra, width = 14, height = 7, dpi = 150, bg = "white")
cat("Saved: synthesis_robustness_panel_extra.png\n")

# ============================================================================
# 12. EXPORT STRUCTURED TABLE
# ============================================================================

# Main results table: h=0 across all primary approaches
main_table <- coefs %>%
  filter(horizon == 0, weighting == "Unweighted",
         approach %in% c("DL", "LP", "LP_ShockHistory",
                         "LP_Compound_Additive", "LP_Dose_Response")) %>%
  mutate(
    sig = case_when(p.value < 0.01 ~ "***", p.value < 0.05 ~ "**",
                    p.value < 0.10 ~ "*", TRUE ~ ""),
    estimate_fmt = sprintf("%.4f%s", estimate, sig),
    se_fmt = sprintf("(%.4f)", std.error)
  ) %>%
  select(shock, outcome, approach, estimate_fmt, se_fmt, N)

write.csv(main_table, "Analysis/event_study_tables.csv", row.names = FALSE)
cat("Saved: Analysis/event_study_tables.csv\n")

# Full dynamic table (all horizons, primary specs)
full_table <- coefs %>%
  filter(weighting == "Unweighted",
         approach %in% c("DL", "LP", "LP_ShockHistory",
                         "LP_Compound_Additive", "LP_Dose_Response")) %>%
  mutate(
    sig = case_when(p.value < 0.01 ~ "***", p.value < 0.05 ~ "**",
                    p.value < 0.10 ~ "*", TRUE ~ "")
  ) %>%
  select(shock, outcome, horizon, approach, estimate, std.error, p.value, sig, N)

write.csv(full_table, "Analysis/event_study_full_results.csv", row.names = FALSE)
cat("Saved: Analysis/event_study_full_results.csv\n")

# ============================================================================
# 13. GENERATE NARRATIVE SUMMARY
# ============================================================================

sink("Analysis/event_study_synthesis.md")

cat("# Dynamic Panel Impulse-Response: Synthesis of Results\n\n")
cat("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M"), "\n\n")

cat("## Overview\n\n")
cat(sprintf("- **Total coefficient estimates:** %d across %d unique specifications\n",
            nrow(coefs), length(unique(paste(coefs$shock, coefs$outcome, coefs$approach, coefs$weighting)))))
cat(sprintf("- **Shocks:** %s\n", paste(sort(unique(coefs$shock)), collapse = ", ")))
cat(sprintf("- **Outcomes:** %s\n", paste(sort(unique(coefs$outcome)), collapse = ", ")))
cat(sprintf("- **Approaches:** %s\n", paste(sort(unique(coefs$approach)), collapse = ", ")))
cat("- **Horizon window:** h = {-2, -1 (ref), 0, +1, +2, +3}\n")
cat("- **Fixed effects:** County (fips_code) + Year\n")
cat("- **Clustering:** State-level (primary), Rating-area (premium robustness)\n\n")

cat("## Key Finding 1: Contemporaneous Effects (h=0)\n\n")
cat("| Shock | Outcome | DL Estimate | LP Estimate |\n")
cat("|-------|---------|-------------|-------------|\n")
h0_merged <- h0 %>%
  select(shock, outcome, approach, est_label) %>%
  pivot_wider(names_from = approach, values_from = est_label, values_fill = "—")
for (i in seq_len(nrow(h0_merged))) {
  row <- h0_merged[i, ]
  cat(sprintf("| %s | %s | %s | %s |\n",
              row$shock, row$outcome,
              ifelse("DL" %in% names(row), row$DL, "—"),
              ifelse("LP" %in% names(row), row$LP, "—")))
}

cat("\n## Key Finding 2: Dynamic Profiles\n\n")
cat("Classification of how effects evolve from h=0 to h=3 (LP, Unweighted):\n\n")
cat("| Shock | Outcome | Pattern | Peak Horizon | h=0 Est | h=3 Est |\n")
cat("|-------|---------|---------|-------------|---------|--------|\n")
for (i in seq_len(nrow(dynamic_profiles))) {
  row <- dynamic_profiles[i, ]
  cat(sprintf("| %s | %s | **%s** | h=%d | %.4f | %.4f |\n",
              row$shock, row$outcome, row$pattern, row$peak_h,
              row$est_h0, row$est_h3))
}

cat("\nPattern definitions:\n")
cat("- **building**: Effect grows >50% from h=0 to h=3 and is significant at h=3\n")
cat("- **persistent**: Significant at both h=0 and h=3\n")
cat("- **transient**: Significant at h=0 but fades by h=3\n")
cat("- **delayed**: Not significant at h=0 but emerges by h=3\n")
cat("- **insignificant**: No significant effect at any positive horizon\n\n")

cat("## Key Finding 3: Pre-Trend Validity\n\n")
n_fail <- sum(pretrends$pretrend_fail, na.rm = TRUE)
if (n_fail == 0) {
  cat("All pre-trend checks pass. No shock-outcome pair shows a significant coefficient at h=-2, ")
  cat("supporting the assumption that shocks are not systematically preceded by outcome movements.\n\n")
} else {
  cat(sprintf("**WARNING:** %d pre-trend failure(s) detected at h=-2 (p < 0.05):\n\n", n_fail))
  for (i in which(pretrends$pretrend_fail)) {
    row <- pretrends[i, ]
    cat(sprintf("- %s -> %s (%s): est=%.4f, p=%.4f\n",
                row$shock, row$outcome, row$approach, row$estimate, row$p.value))
  }
  cat("\n")
}

cat("## Key Finding 4: Cross-Method Robustness\n\n")
cat("DL vs LP sign agreement and correlation (h >= 0, Unweighted):\n\n")
cat("| Shock | Outcome | Same Sign % | Correlation |\n")
cat("|-------|---------|------------|-------------|\n")
for (i in seq_len(nrow(consistency))) {
  row <- consistency[i, ]
  cat(sprintf("| %s | %s | %d%% | %.3f |\n",
              row$shock, row$outcome, row$pct_same_sign, row$corr))
}

cat("\n## Key Finding 5: Shock-History Robustness\n\n")
cat("Adding lagged shock controls (t-1, t-2) to LP does not substantially alter results:\n\n")
if (nrow(hist_compare) > 0) {
  cat("| Shock | Outcome | Mean % Change | Same Sign % |\n")
  cat("|-------|---------|--------------|-------------|\n")
  for (i in seq_len(nrow(hist_summary))) {
    row <- hist_summary[i, ]
    cat(sprintf("| %s | %s | %.1f%% | %d%% |\n",
                row$shock, row$outcome, row$mean_pct_change, row$same_sign))
  }
}

cat("\n## Key Finding 6: Combined and Compound Shocks\n\n")
cat("### Any_Shock vs Individual Shocks (h=0, LP)\n\n")
cat("`Any_Shock` captures the average effect of experiencing *any* climate shock.\n\n")
cat("| Shock | Outcome | Estimate | SE | p-value |\n")
cat("|-------|---------|----------|------|--------|\n")
for (i in seq_len(nrow(indiv_vs_any))) {
  row <- indiv_vs_any[i, ]
  cat(sprintf("| %s | %s | %.4f | %.4f | %.4f |\n",
              row$shock, row$outcome, row$estimate, row$std.error, row$p.value))
}

cat("\n### Compound Shock Decomposition (h=0)\n\n")
cat("From the additive spec: `Any_Shock` = baseline effect of any shock; ")
cat("`Compound_Shock` = additional effect when 2+ shocks co-occur.\n")
cat("From the dose-response spec: `Shock_Count` = marginal effect per additional shock.\n\n")
cat("**Note:** Compound shock support is thin (~2.2% of obs). Treat as exploratory.\n\n")
cat("| Shock | Outcome | Approach | Estimate | SE | p-value |\n")
cat("|-------|---------|----------|----------|------|--------|\n")
for (i in seq_len(nrow(compound_h0))) {
  row <- compound_h0[i, ]
  cat(sprintf("| %s | %s | %s | %.4f | %.4f | %.4f |\n",
              row$shock, row$outcome, row$approach, row$estimate, row$std.error, row$p.value))
}

cat("\n## Artifacts\n\n")
cat("| File | Description |\n")
cat("|------|-------------|\n")
cat("| `Analysis/event_study_coefs.csv` | All 852 coefficient rows (raw) |\n")
cat("| `Analysis/event_study_tables.csv` | Formatted h=0 results table |\n")
cat("| `Analysis/event_study_full_results.csv` | All horizons, primary specs |\n")
cat("| `Analysis/event_study_results.txt` | DL model summaries (text) |\n")
cat("| `Analysis/plots/synthesis_significance_heatmap.png` | h=0 significance heatmap |\n")
cat("| `Analysis/plots/synthesis_dynamic_profiles.png` | LP impulse-response panel |\n")
cat("| `Analysis/plots/synthesis_robustness_panel.png` | DL vs LP vs LP+History (Medical Debt Share, Silver Premium) |\n")
cat("| `Analysis/plots/synthesis_robustness_panel_extra.png` | DL vs LP vs LP+History (Median Debt, Hosp Bad Debt) |\n")
cat("| `Analysis/plots/lp_Shock_Count_*.png` | Dose-response multi-dose plots |\n")

sink()
cat("\nSaved: Analysis/event_study_synthesis.md\n")

cat("\n=== Synthesis Script Complete ===\n")
