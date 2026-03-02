# Descriptive Statistics and Visualizations for County-Level Panel
#
# Produces:
#   Analysis/descriptive_stats_summary.csv  -- summary stats table (all key vars)
#   Analysis/plots/ts_climate_shocks.png    -- % counties shocked by year
#   Analysis/plots/ts_outcomes.png          -- health/economic outcome trends
#   Analysis/plots/ts_income.png            -- income trends
#   Analysis/descriptive_stats_report.md    -- written summary of findings

library(dplyr)
library(tidyr)
library(ggplot2)

dir.create("Analysis/plots", showWarnings = FALSE, recursive = TRUE)

cat("Loading county master...\n")
df <- read.csv("Data/county_level_master.csv", stringsAsFactors = FALSE)
cat("  Rows:", nrow(df), "| Counties:", n_distinct(df$fips_code),
    "| Years:", min(df$Year), "-", max(df$Year), "\n\n")

# ---------------------------------------------------------------------------
# 1. Summary Statistics
# ---------------------------------------------------------------------------
cat("Computing summary statistics...\n")

key_vars <- list(
  # Climate shocks
  Z_Temp             = "Temp Z-score (1990-2000 baseline)",
  Z_Precip           = "Precip Z-score (1990-2000 baseline)",
  High_CDD           = "Extreme Heat (top quintile CDD)",
  High_HDD           = "Extreme Cold (top quintile HDD)",
  pdsi_val           = "PDSI (drought index, annual mean)",
  Is_Extreme_Drought = "Extreme Drought (PDSI <= -4)",
  AQI_Shock          = "AQI Shock (>= Moderate days flag)",
  # Health outcomes
  Medical_Debt_Share     = "Medical Debt Share (%)",
  Medical_Debt_Median_2023 = "Median Medical Debt ($2023)",
  Benchmark_Silver_Real  = "Benchmark Silver Premium ($2023)",
  Lowest_Bronze_Real     = "Lowest Bronze Premium ($2023)",
  Hosp_BadDebt_Total_Real = "Hospital Bad Debt ($2023)",
  Hosp_Charity_Total_Real = "Hospital Charity Care ($2023)",
  Uninsured_Rate         = "Uninsured Rate (%)",
  # Socioeconomic outcomes
  PCPI_Real          = "Per Capita Personal Income ($2023)",
  Med_HH_Income_Real = "Median HH Income ($2023)",
  Civilian_Employed  = "Civilian Employed (count)",
  Household_Income_2023 = "Household Income from Debt Data ($2023)"
)

summarize_var <- function(x, label) {
  data.frame(
    Variable    = label,
    N           = sum(!is.na(x)),
    Mean        = mean(x, na.rm = TRUE),
    SD          = sd(x, na.rm = TRUE),
    Min         = min(x, na.rm = TRUE),
    P25         = quantile(x, 0.25, na.rm = TRUE),
    Median      = median(x, na.rm = TRUE),
    P75         = quantile(x, 0.75, na.rm = TRUE),
    Max         = max(x, na.rm = TRUE),
    NA_pct      = round(mean(is.na(x)) * 100, 1),
    stringsAsFactors = FALSE
  )
}

stats_list <- lapply(names(key_vars), function(v) {
  if (v %in% names(df)) summarize_var(df[[v]], key_vars[[v]])
  else NULL
})
stats_df <- do.call(rbind, Filter(Negate(is.null), stats_list))
stats_df[, 3:9] <- round(stats_df[, 3:9], 2)

write.csv(stats_df, "Analysis/descriptive_stats_summary.csv", row.names = FALSE)
cat("  Saved: Analysis/descriptive_stats_summary.csv\n")

# ---------------------------------------------------------------------------
# 2. Time-series: Climate Shock Prevalence (% counties per year)
# ---------------------------------------------------------------------------
cat("Generating climate shock prevalence plot...\n")

ts_climate <- df %>%
  group_by(Year) %>%
  summarize(
    `Extreme Heat (High CDD)`    = mean(High_CDD,           na.rm = TRUE) * 100,
    `Extreme Cold (High HDD)`    = mean(High_HDD,           na.rm = TRUE) * 100,
    `Extreme Drought (PDSI<=-4)` = mean(Is_Extreme_Drought, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  pivot_longer(-Year, names_to = "Shock", values_to = "Pct_Counties")

p_climate <- ggplot(ts_climate, aes(x = Year, y = Pct_Counties, color = Shock, group = Shock)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.8) +
  scale_y_continuous(limits = c(0, NA), labels = function(x) paste0(x, "%")) +
  scale_x_continuous(breaks = seq(2011, 2023, 2)) +
  scale_color_manual(values = c(
    "Extreme Heat (High CDD)"    = "#d62728",
    "Extreme Cold (High HDD)"    = "#1f77b4",
    "Extreme Drought (PDSI<=-4)" = "#8c564b"
  )) +
  labs(
    title    = "Prevalence of Climate Shocks Across U.S. Counties",
    subtitle = "Percentage of counties experiencing each shock type per year",
    x        = NULL, y = "% of Counties", color = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom", plot.title = element_text(face = "bold"))

ggsave("Analysis/plots/ts_climate_shocks.png", p_climate, width = 9, height = 5, dpi = 150)
cat("  Saved: Analysis/plots/ts_climate_shocks.png\n")

# ---------------------------------------------------------------------------
# 3. Time-series: Health & Debt Outcomes
# ---------------------------------------------------------------------------
cat("Generating outcomes trend plot...\n")

ts_outcomes <- df %>%
  group_by(Year) %>%
  summarize(
    `Medical Debt Share (%)`           = mean(Medical_Debt_Share,    na.rm = TRUE),
    `Uninsured Rate (%)`               = mean(Uninsured_Rate,        na.rm = TRUE),
    `Silver Premium ($2023, /100)`     = mean(Benchmark_Silver_Real, na.rm = TRUE) / 100,
    .groups = "drop"
  ) %>%
  pivot_longer(-Year, names_to = "Metric", values_to = "Value")

p_outcomes <- ggplot(ts_outcomes, aes(x = Year, y = Value, color = Metric, group = Metric)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.8) +
  scale_x_continuous(breaks = seq(2011, 2023, 2)) +
  scale_color_manual(values = c(
    "Medical Debt Share (%)"       = "#e377c2",
    "Uninsured Rate (%)"           = "#ff7f0e",
    "Silver Premium ($2023, /100)" = "#2ca02c"
  )) +
  labs(
    title    = "Health & Financial Outcome Trends",
    subtitle = "County annual means — premium divided by 100 for scale",
    x        = NULL, y = "Value", color = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom", plot.title = element_text(face = "bold"))

ggsave("Analysis/plots/ts_outcomes.png", p_outcomes, width = 9, height = 5, dpi = 150)
cat("  Saved: Analysis/plots/ts_outcomes.png\n")

# ---------------------------------------------------------------------------
# 4. Time-series: Income Trends
# ---------------------------------------------------------------------------
cat("Generating income trend plot...\n")

ts_income <- df %>%
  group_by(Year) %>%
  summarize(
    `Per Capita Personal Income` = mean(PCPI_Real,          na.rm = TRUE),
    `Median HH Income (ACS)`     = mean(Med_HH_Income_Real, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(-Year, names_to = "Metric", values_to = "Value")

p_income <- ggplot(ts_income, aes(x = Year, y = Value / 1000, color = Metric, group = Metric)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.8) +
  scale_y_continuous(labels = function(x) paste0("$", x, "k")) +
  scale_x_continuous(breaks = seq(2011, 2023, 2)) +
  scale_color_manual(values = c(
    "Per Capita Personal Income" = "#9467bd",
    "Median HH Income (ACS)"     = "#17becf"
  )) +
  labs(
    title    = "County Income Trends (2023 Dollars)",
    subtitle = "Annual county means — BEA per capita income and ACS median HH income",
    x        = NULL, y = "Thousands ($2023)", color = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom", plot.title = element_text(face = "bold"))

ggsave("Analysis/plots/ts_income.png", p_income, width = 9, height = 5, dpi = 150)
cat("  Saved: Analysis/plots/ts_income.png\n")

# ---------------------------------------------------------------------------
# 5. Print summary to console for report writing
# ---------------------------------------------------------------------------
cat("\n--- Key Aggregate Statistics (study period 2011-2023) ---\n")
study <- df[df$Year >= 2011 & df$Year <= 2023, ]
cat(sprintf("Counties:              %d\n", n_distinct(study$fips_code)))
cat(sprintf("County-year obs:       %d\n", nrow(study)))
cat(sprintf("Extreme heat pct:      %.1f%%\n", mean(study$High_CDD, na.rm=TRUE)*100))
cat(sprintf("Extreme cold pct:      %.1f%%\n", mean(study$High_HDD, na.rm=TRUE)*100))
cat(sprintf("Extreme drought pct:   %.1f%%\n", mean(study$Is_Extreme_Drought, na.rm=TRUE)*100))
cat(sprintf("Mean medical debt %%:   %.2f%%\n", mean(study$Medical_Debt_Share, na.rm=TRUE)))
cat(sprintf("Mean silver premium:   $%.0f (2023 dollars)\n", mean(study$Benchmark_Silver_Real, na.rm=TRUE)))
cat(sprintf("Mean PCPI:             $%.0f (2023 dollars)\n", mean(study$PCPI_Real, na.rm=TRUE)))
cat(sprintf("Mean med HH income:    $%.0f (2023 dollars)\n", mean(study$Med_HH_Income_Real, na.rm=TRUE)))

cat("\nDone! Outputs in Analysis/ and Analysis/plots/\n")
