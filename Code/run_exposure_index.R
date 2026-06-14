# ---------------------------------------------------------------------------
# run_exposure_index.R  (Climate–Health Exposure Index — Phase 3, PRIMARY)
#
# Environmental-justice amplification test: do climate-shock -> health-cost
# effects hit harder in structurally vulnerable counties?
#
#   Y_it = beta1 * Shock_it + beta2 * (Shock_it x SVI_i) + X_it'd | fips + Year
#
# SVI_i is the TIME-INVARIANT county vulnerability percentile (SVI_static); its
# main effect is absorbed by county FE, leaving the interaction identified.
#   beta1            = shock effect at SVI = 0 (least vulnerable)
#   beta1 + beta2*q  = shock effect at vulnerability percentile q
# A beta2 with the same sign as beta1 (and significant) = AMPLIFICATION: the
# climate cost is larger where structural vulnerability is higher.
#
# Outputs:
#   Analysis/exposure_interaction_coefs.csv   (Shock, Shock x SVI, marginal effects)
#   Analysis/plots/exposure_index/*.png
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr); library(readr); library(fixest); library(ggplot2)
})
source("Code/cumulative_dose.R")   # lincom(), add_cumulative_shock_years()

if (!exists("%||%")) `%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x

plot_dir <- "Analysis/plots/exposure_index"
dir.create("Analysis", showWarnings = FALSE)
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

df  <- read_csv("Data/county_level_master.csv", show_col_types = FALSE, progress = FALSE)
svi <- readRDS("Data/intermediate_svi.rds")
df$fips_code  <- formatC(as.integer(df$fips_code), width = 5, flag = "0")
svi$fips_code <- formatC(as.integer(svi$fips_code), width = 5, flag = "0")

if (all(c("Hosp_BadDebt_Total_Real","Population") %in% names(df)))
  df$Hosp_BadDebt_PerCapita <- df$Hosp_BadDebt_Total_Real / df$Population

df <- df %>%
  filter(Year >= 2011, Year <= 2023) %>%
  left_join(svi %>% distinct(fips_code, SVI_static),
            by = "fips_code") %>%
  left_join(svi %>% select(fips_code, Year, SVI_yr), by = c("fips_code", "Year")) %>%
  arrange(fips_code, Year)

# Debt reporting exclusion (CO 2023), matching the county stack.
debt_outcomes <- intersect(c("Medical_Debt_Share","Medical_Debt_Median_2023"), names(df))
if (length(debt_outcomes) > 0) {
  mask <- toupper(trimws(as.character(df$State))) == "CO" & as.integer(df$Year) == 2023
  for (v in debt_outcomes) df[[v]] <- ifelse(mask, NA_real_, as.numeric(df[[v]]))
}

# Build the shock set: contemporaneous binaries, drought lag-2 (state headline),
# and cumulative cold-years (the Phase-3 compounding finding).
df <- df %>% group_by(fips_code) %>% arrange(Year) %>%
  mutate(Drought_Lag2 = dplyr::lag(Is_Extreme_Drought, 2)) %>% ungroup()
df <- add_cumulative_shock_years(df, "High_HDD", "Cum_HDD_Years")

shock_specs <- list(
  list(term = "Is_Extreme_Drought", label = "Drought"),
  list(term = "Drought_Lag2",       label = "Drought_Lag2"),
  list(term = "High_CDD",           label = "Heat_CDD"),
  list(term = "High_HDD",           label = "Cold_HDD"),
  list(term = "Cum_HDD_Years",      label = "Cold_CumYears")
)
shock_specs <- Filter(function(s) s$term %in% names(df), shock_specs)

outcomes <- intersect(c("Medical_Debt_Share","PCPI_Real","Hosp_BadDebt_PerCapita",
                        "Benchmark_Silver_Real","Civilian_Employed","Med_HH_Income_Real"), names(df))
controls <- intersect(c("Household_Income_2023","Uninsured_Rate"), names(df))

# Adverse direction per outcome: +1 if higher = worse (debt/premiums/bad-debt),
# -1 if lower = worse (income/employment). EJ amplification = the shock's HARM
# grows with vulnerability, i.e. sign(beta_interaction) == adverse_sign.
adverse_sign <- c(Medical_Debt_Share = 1, Hosp_BadDebt_PerCapita = 1,
                  Benchmark_Silver_Real = 1, PCPI_Real = -1,
                  Med_HH_Income_Real = -1, Civilian_Employed = -1)

# Low/high vulnerability evaluation points (25th / 75th SVI percentiles).
svi_q <- quantile(df$SVI_static, c(0.25, 0.75), na.rm = TRUE)
cat(sprintf("SVI_static p25=%.3f  p75=%.3f\n", svi_q[1], svi_q[2]))

get_cell <- function(ct, term, col) { v <- ct[ct$Term == term, col]; if (length(v) == 0) NA_real_ else as.numeric(v) }
rows <- list()

for (sp in shock_specs) {
  sh  <- sp$term
  int <- paste0(sh, ":SVI_static")
  rhs <- paste(c(sh, paste0(sh, ":SVI_static"), controls), collapse = " + ")
  for (o in outcomes) {
    sub <- df %>% filter(!is.na(.data[[o]]), !is.na(SVI_static), !is.na(.data[[sh]]))
    if (nrow(sub) < 100) next
    m <- tryCatch(feols(as.formula(paste(o, "~", rhs, "| fips_code + Year")),
                        data = sub, cluster = ~State), error = function(e) NULL)
    if (is.null(m)) next
    ct <- as.data.frame(coeftable(m)); ct$Term <- rownames(ct)
    b_main <- get_cell(ct, sh, "Estimate"); p_main <- get_cell(ct, sh, "Pr(>|t|)")
    b_int  <- get_cell(ct, int, "Estimate"); p_int <- get_cell(ct, int, "Pr(>|t|)")
    # Marginal shock effect at low / high SVI via lincom.
    me_lo <- lincom(m, setNames(c(1, svi_q[1]), c(sh, int)))
    me_hi <- lincom(m, setNames(c(1, svi_q[2]), c(sh, int)))
    adv <- adverse_sign[[o]] %||% NA_real_
    sig_int <- !is.na(p_int) && p_int < 0.10
    verdict <- if (!sig_int || is.na(b_int)) "ns"
               else if (!is.na(adv) && sign(b_int) == adv) "amplifies_harm_in_vulnerable"
               else "concentrated_in_less_vulnerable"
    rows[[length(rows) + 1]] <- data.frame(
      shock = sp$label, outcome = o, N = nobs(m),
      beta_shock = b_main, p_shock = p_main,
      beta_interaction = b_int, p_interaction = p_int,
      me_lowSVI = if (!is.null(me_lo)) me_lo$estimate else NA_real_,
      me_lowSVI_p = if (!is.null(me_lo)) me_lo$p.value else NA_real_,
      me_highSVI = if (!is.null(me_hi)) me_hi$estimate else NA_real_,
      me_highSVI_p = if (!is.null(me_hi)) me_hi$p.value else NA_real_,
      ej_verdict = verdict,
      stringsAsFactors = FALSE)
  }
}

res <- bind_rows(rows)
write_csv(res, "Analysis/exposure_interaction_coefs.csv")
cat(sprintf("\nSaved %d interaction rows to Analysis/exposure_interaction_coefs.csv\n", nrow(res)))

cat("\n=== Significant Shock x SVI interactions (p_int<0.10), with EJ verdict ===\n")
print(as.data.frame(res %>% filter(ej_verdict != "ns") %>%
        mutate(across(c(beta_interaction, p_interaction, me_lowSVI, me_highSVI), ~signif(.x, 3))) %>%
        arrange(p_interaction) %>%
        select(shock, outcome, beta_interaction, p_interaction, me_lowSVI, me_highSVI, ej_verdict)),
      row.names = FALSE)
cat("\nVerdict counts:\n"); print(table(res$ej_verdict))

# Plot: marginal shock effect at low vs high SVI per (shock x outcome)
pd <- res %>%
  tidyr::pivot_longer(c(me_lowSVI, me_highSVI), names_to = "svi_level", values_to = "me") %>%
  mutate(svi_level = ifelse(svi_level == "me_lowSVI", "Low SVI (p25)", "High SVI (p75)"),
         svi_level = factor(svi_level, levels = c("Low SVI (p25)", "High SVI (p75)")))
for (o in unique(pd$outcome)) {
  sub <- pd %>% filter(outcome == o)
  if (nrow(sub) == 0) next
  p <- ggplot(sub, aes(x = shock, y = me, fill = svi_level)) +
    geom_col(position = position_dodge(width = 0.8), width = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    scale_fill_manual(values = c("Low SVI (p25)" = "#92C5DE", "High SVI (p75)" = "#B2182B")) +
    labs(title = paste("Shock effect by county vulnerability ->", o),
         subtitle = "Marginal effect of shock at low vs high CDC-SVI percentile",
         x = "Shock", y = "Marginal effect", fill = NULL) +
    theme_minimal(base_size = 11) +
    theme(axis.text.x = element_text(angle = 20, hjust = 1),
          plot.background = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA))
  ggsave(file.path(plot_dir, paste0("interaction_", o, ".png")), p,
         width = 8, height = 5, dpi = 150, bg = "white")
}

cat("\n=== Exposure-Index Interaction Analysis Complete ===\n")
