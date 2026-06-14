# ---------------------------------------------------------------------------
# run_exposure_secondary.R  (Climate–Health Exposure Index — Phase 4, SECONDARY)
#
# Complements the primary Shock x SVI interactions (run_exposure_index.R) with:
#   4a. Composite-index regressions  : Y ~ CHEI + controls | fips + Year.
#   4b. Robustness                   : vulnerability-stratified (high/low SVI)
#                                      headline models + time-varying-SVI interactions.
#   4c. Lancet-style descriptive     : person-years of extreme-temperature exposure,
#                                      national/state trend.
#
# Outputs:
#   Analysis/exposure_chei_coefs.csv
#   Analysis/exposure_robustness.csv
#   Analysis/exposure_personyears_trend.csv
#   Analysis/plots/exposure_index/{chei_*, personyears_trend}.png
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr); library(readr); library(fixest); library(ggplot2)
})
source("Code/exposure_index.R")     # person_years_exposure(), build_chei()
source("Code/cumulative_dose.R")    # add_cumulative_shock_years()

plot_dir <- "Analysis/plots/exposure_index"
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

df  <- read_csv("Data/county_level_master.csv", show_col_types = FALSE, progress = FALSE)
svi <- readRDS("Data/intermediate_svi.rds")
df$fips_code  <- formatC(as.integer(df$fips_code), width = 5, flag = "0")
svi$fips_code <- formatC(as.integer(svi$fips_code), width = 5, flag = "0")
if (all(c("Hosp_BadDebt_Total_Real","Population") %in% names(df)))
  df$Hosp_BadDebt_PerCapita <- df$Hosp_BadDebt_Total_Real / df$Population

df <- df %>% filter(Year >= 2011, Year <= 2023) %>%
  left_join(svi %>% distinct(fips_code, SVI_static), by = "fips_code") %>%
  left_join(svi %>% select(fips_code, Year, SVI_yr), by = c("fips_code", "Year")) %>%
  arrange(fips_code, Year)

# debt exclusion CO 2023
mask <- toupper(trimws(as.character(df$State))) == "CO" & as.integer(df$Year) == 2023
for (v in intersect(c("Medical_Debt_Share","Medical_Debt_Median_2023"), names(df)))
  df[[v]] <- ifelse(mask, NA_real_, as.numeric(df[[v]]))

outcomes <- intersect(c("Medical_Debt_Share","PCPI_Real","Hosp_BadDebt_PerCapita",
                        "Benchmark_Silver_Real","Civilian_Employed","Med_HH_Income_Real"), names(df))
controls <- intersect(c("Household_Income_2023","Uninsured_Rate"), names(df))
get_cell <- function(ct, term, col) { v <- ct[ct$Term == term, col]; if (length(v) == 0) NA_real_ else as.numeric(v) }

# Standardised thermal hazards and composite CHEI scalars (build_chei helper).
z <- function(x) { x <- as.numeric(x); (x - mean(x, na.rm = TRUE)) / stats::sd(x, na.rm = TRUE) }
df$CHEI_heat <- build_chei(z(df$cdd_val), df$SVI_static, standardize = TRUE)
df$CHEI_cold <- build_chei(z(df$hdd_val), df$SVI_static, standardize = TRUE)

# ---- 4a. Composite-index regressions --------------------------------------
cat("=== 4a. Composite CHEI regressions ===\n")
chei_rows <- list()
for (idx in c("CHEI_heat", "CHEI_cold")) {
  rhs <- paste(c(idx, controls), collapse = " + ")
  for (o in outcomes) {
    sub <- df %>% filter(!is.na(.data[[o]]), !is.na(.data[[idx]]))
    if (nrow(sub) < 100) next
    m <- tryCatch(feols(as.formula(paste(o, "~", rhs, "| fips_code + Year")),
                        data = sub, cluster = ~State), error = function(e) NULL)
    if (is.null(m)) next
    ct <- as.data.frame(coeftable(m)); ct$Term <- rownames(ct)
    chei_rows[[length(chei_rows) + 1]] <- data.frame(
      index = idx, outcome = o, estimate = get_cell(ct, idx, "Estimate"),
      std.error = get_cell(ct, idx, "Std. Error"), p.value = get_cell(ct, idx, "Pr(>|t|)"),
      N = nobs(m), stringsAsFactors = FALSE)
  }
}
chei_df <- bind_rows(chei_rows)
write_csv(chei_df, "Analysis/exposure_chei_coefs.csv")
print(as.data.frame(chei_df %>% mutate(across(c(estimate,std.error,p.value), ~signif(.x,3)))), row.names = FALSE)

# ---- 4b. Robustness: stratified + time-varying SVI ------------------------
cat("\n=== 4b. Robustness ===\n")
shocks <- intersect(c("Is_Extreme_Drought","High_CDD","High_HDD"), names(df))
svi_med <- median(df$SVI_static, na.rm = TRUE)
rob_rows <- list()

# (i) Vulnerability-stratified headline shock models (high vs low SVI)
for (grp in c("low","high")) {
  sub_g <- df %>% filter(if (grp=="low") SVI_static <= svi_med else SVI_static > svi_med)
  rhs <- paste(c(shocks, controls), collapse = " + ")
  for (o in outcomes) {
    sub <- sub_g %>% filter(!is.na(.data[[o]]))
    if (nrow(sub) < 100) next
    m <- tryCatch(feols(as.formula(paste(o, "~", rhs, "| fips_code + Year")),
                        data = sub, cluster = ~State), error = function(e) NULL)
    if (is.null(m)) next
    ct <- as.data.frame(coeftable(m)); ct$Term <- rownames(ct)
    for (s in shocks) rob_rows[[length(rob_rows)+1]] <- data.frame(
      spec = "stratified", svi_group = grp, shock = s, outcome = o,
      estimate = get_cell(ct, s, "Estimate"), p.value = get_cell(ct, s, "Pr(>|t|)"),
      N = nobs(m), stringsAsFactors = FALSE)
  }
}

# (ii) Time-varying-SVI interactions (compare to the SVI_static primary)
for (s in shocks) {
  int <- paste0(s, ":SVI_yr")
  rhs <- paste(c(s, int, controls), collapse = " + ")
  for (o in outcomes) {
    sub <- df %>% filter(!is.na(.data[[o]]), !is.na(SVI_yr), !is.na(.data[[s]]))
    if (nrow(sub) < 100) next
    m <- tryCatch(feols(as.formula(paste(o, "~", rhs, "| fips_code + Year")),
                        data = sub, cluster = ~State), error = function(e) NULL)
    if (is.null(m)) next
    ct <- as.data.frame(coeftable(m)); ct$Term <- rownames(ct)
    rob_rows[[length(rob_rows)+1]] <- data.frame(
      spec = "interaction_SVI_yr", svi_group = NA_character_, shock = s, outcome = o,
      estimate = get_cell(ct, int, "Estimate"), p.value = get_cell(ct, int, "Pr(>|t|)"),
      N = nobs(m), stringsAsFactors = FALSE)
  }
}
rob_df <- bind_rows(rob_rows)
write_csv(rob_df, "Analysis/exposure_robustness.csv")
cat(sprintf("Robustness rows: %d (stratified + time-varying-SVI)\n", nrow(rob_df)))

# ---- 4c. Lancet-style person-years of extreme-temperature exposure --------
cat("\n=== 4c. Lancet person-years exposure trend ===\n")
df$PY_heat <- person_years_exposure(df$Population, df$High_CDD, na_indicator_zero = TRUE)
df$PY_cold <- person_years_exposure(df$Population, df$High_HDD, na_indicator_zero = TRUE)
trend <- df %>% group_by(Year) %>%
  summarise(PersonYears_Heat = sum(PY_heat, na.rm = TRUE),
            PersonYears_Cold = sum(PY_cold, na.rm = TRUE), .groups = "drop")
write_csv(trend, "Analysis/exposure_personyears_trend.csv")
print(as.data.frame(trend %>% mutate(across(-Year, ~ round(.x/1e6, 1)))), row.names = FALSE)

tl <- trend %>% tidyr::pivot_longer(-Year, names_to = "type", values_to = "person_years") %>%
  mutate(type = sub("PersonYears_", "", type), person_years_m = person_years / 1e6)
p <- ggplot(tl, aes(x = Year, y = person_years_m, color = type)) +
  geom_line(linewidth = 1) + geom_point() +
  scale_color_manual(values = c("Heat" = "#B2182B", "Cold" = "#2166AC")) +
  scale_x_continuous(breaks = unique(tl$Year)) +
  labs(title = "Lancet-style exposure: person-years of extreme-temperature exposure",
       subtitle = "U.S. counties, population x High_CDD / High_HDD indicator",
       x = "Year", y = "Person-years (millions)", color = NULL) +
  theme_minimal(base_size = 11) +
  theme(plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA))
ggsave(file.path(plot_dir, "personyears_trend.png"), p, width = 8, height = 5, dpi = 150, bg = "white")

cat("\n=== Exposure-Index Secondary Analysis Complete ===\n")
