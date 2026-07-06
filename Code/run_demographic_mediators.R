# ---------------------------------------------------------------------------
# run_demographic_mediators.R  (Persistence Extensions — Phase 4)
#
# Two questions:
#  (1) FIRST STAGE — do climate shocks shift county demographics? Treat the ACS
#      mediators (In_Migration_Rate, Pct_Age_65plus, Pct_Owner_Occupied) as
#      OUTCOMES of contemporaneous + lagged shocks.
#  (2) MEDIATOR DECOMPOSITION — re-fit the headline county outcomes on shocks
#      with and without the demographic controls, on the IDENTICAL demographics-
#      available sample, and report the fraction of each shock effect that
#      survives demographic adjustment.
#
# The demographic mediators are joined at analysis time from
# Data/intermediate_demographics.rds (built by process_county_demographics.R) so
# the county master does not need rebuilding. ACS 5-year estimates are smoothed,
# so demographics are slow-moving compositional controls, not annual shocks.
#
# Outputs:
#   Analysis/demographic_mediators/demographic_response_coefs.csv          (first stage)
#   Analysis/demographic_mediators/demographic_mediator_decomposition.csv  (base vs +demographics)
#   Analysis/plots/demographic_mediators/*.png
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr); library(readr); library(fixest); library(ggplot2)
})

master_path <- "Data/county_level_master.csv"
demo_path   <- "Data/intermediate_demographics.rds"
plot_dir    <- "Analysis/plots/demographic_mediators"
dir.create("Analysis", showWarnings = FALSE)
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

stopifnot(file.exists(master_path), file.exists(demo_path))
df   <- read_csv(master_path, show_col_types = FALSE, progress = FALSE)
demo <- readRDS(demo_path)

if (all(c("Hosp_BadDebt_Total_Real", "Population") %in% names(df))) {
  df$Hosp_BadDebt_PerCapita <- df$Hosp_BadDebt_Total_Real / df$Population
}
df$fips_code <- trimws(sprintf("%05s", df$fips_code))
demo$fips_code <- trimws(sprintf("%05s", demo$fips_code))

df <- df %>%
  filter(Year >= 2011, Year <= 2023) %>%
  left_join(demo, by = c("fips_code", "Year")) %>%
  arrange(fips_code, Year)

shocks      <- c("Is_Extreme_Drought", "High_CDD", "High_HDD")
shocks      <- shocks[shocks %in% names(df)]
mediators   <- c("In_Migration_Rate", "Pct_Age_65plus", "Pct_Owner_Occupied")
outcomes    <- c("Medical_Debt_Share", "PCPI_Real", "Hosp_BadDebt_PerCapita")
outcomes    <- outcomes[outcomes %in% names(df)]

# Build 1- and 2-year shock lags for the first stage.
df <- df %>%
  group_by(fips_code) %>% arrange(Year) %>%
  mutate(across(all_of(shocks), list(lag1 = ~dplyr::lag(.x, 1), lag2 = ~dplyr::lag(.x, 2)),
                .names = "{.col}_L{.fn}")) %>%
  ungroup()
lag_terms <- unlist(lapply(shocks, function(s) c(paste0(s, "_Llag1"), paste0(s, "_Llag2"))))

safe_feols <- function(f, data) {
  tryCatch(feols(f, data = data, cluster = ~State),
           error = function(e) { cat("    err:", conditionMessage(e), "\n"); NULL })
}
get_cell <- function(ct, term, col) { v <- ct[ct$Term == term, col]; if (length(v) == 0) NA_real_ else as.numeric(v) }

# ---- 1. First stage: shocks -> demographics ------------------------------
cat("=== First stage: do shocks shift demographics? ===\n")
fs_rows <- list()
rhs_fs  <- paste(c(shocks, lag_terms), collapse = " + ")
for (d in mediators) {
  if (!d %in% names(df)) next
  f <- as.formula(paste(d, "~", rhs_fs, "| fips_code + Year"))
  m <- safe_feols(f, df)
  if (is.null(m)) next
  ct <- as.data.frame(coeftable(m)); ct$Term <- rownames(ct)
  for (trm in c(shocks, lag_terms)) {
    if (!trm %in% ct$Term) next
    fs_rows[[length(fs_rows) + 1]] <- data.frame(
      mediator = d, shock_term = trm,
      estimate = get_cell(ct, trm, "Estimate"),
      std.error = get_cell(ct, trm, "Std. Error"),
      p.value = get_cell(ct, trm, "Pr(>|t|)"), N = nobs(m),
      stringsAsFactors = FALSE)
  }
}
fs_df <- bind_rows(fs_rows)
write_csv(fs_df, "Analysis/demographic_mediators/demographic_response_coefs.csv")
cat("First-stage coefs saved (", nrow(fs_df), " rows)\n", sep = "")
cat("  Significant shock->demographic links (p<0.05):\n")
print(as.data.frame(fs_df %>% filter(p.value < 0.05) %>%
                      mutate(across(c(estimate, std.error, p.value), ~signif(.x, 3))) %>%
                      select(mediator, shock_term, estimate, p.value)))

# ---- 2. Mediator decomposition -------------------------------------------
# Base: Y ~ shocks | fips + Year. With: + mediators. Same (complete) sample.
cat("\n=== Mediator decomposition (base vs +demographics, constant sample) ===\n")
dec_rows <- list()
rhs_base <- paste(shocks, collapse = " + ")
rhs_med  <- paste(c(shocks, mediators), collapse = " + ")
for (o in outcomes) {
  sub <- df %>% filter(!is.na(.data[[o]]), stats::complete.cases(df[, mediators]))
  if (nrow(sub) < 50) next
  m_base <- safe_feols(as.formula(paste(o, "~", rhs_base, "| fips_code + Year")), sub)
  m_med  <- safe_feols(as.formula(paste(o, "~", rhs_med,  "| fips_code + Year")), sub)
  if (is.null(m_base) || is.null(m_med)) next
  cb <- as.data.frame(coeftable(m_base)); cb$Term <- rownames(cb)
  cm <- as.data.frame(coeftable(m_med));  cm$Term <- rownames(cm)
  for (s in shocks) {
    b0 <- get_cell(cb, s, "Estimate"); b1 <- get_cell(cm, s, "Estimate")
    dec_rows[[length(dec_rows) + 1]] <- data.frame(
      outcome = o, shock = s, N = nobs(m_base),
      est_base = b0, p_base = get_cell(cb, s, "Pr(>|t|)"),
      est_with_demog = b1, p_with_demog = get_cell(cm, s, "Pr(>|t|)"),
      fraction_surviving = ifelse(!is.na(b0) & b0 != 0, b1 / b0, NA_real_),
      stringsAsFactors = FALSE)
  }
}
dec_df <- bind_rows(dec_rows)
write_csv(dec_df, "Analysis/demographic_mediators/demographic_mediator_decomposition.csv")
cat("Decomposition saved (", nrow(dec_df), " rows)\n", sep = "")
print(as.data.frame(dec_df %>%
                      mutate(across(c(est_base, est_with_demog, fraction_surviving), ~signif(.x, 3))) %>%
                      select(outcome, shock, est_base, est_with_demog, fraction_surviving)))

# ---- 3. Plot: fraction surviving -----------------------------------------
if (nrow(dec_df) > 0) {
  pd <- dec_df %>% filter(!is.na(fraction_surviving)) %>%
    mutate(frac_clip = pmax(pmin(fraction_surviving, 1.5), -0.5))
  p <- ggplot(pd, aes(x = shock, y = frac_clip, fill = outcome)) +
    geom_col(position = position_dodge(width = 0.8), width = 0.7) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "gray40") +
    labs(title = "Fraction of shock effect surviving demographic adjustment",
         subtitle = "1.0 = unchanged by controls; <1 = partially mediated; dashed = no mediation",
         x = "Shock", y = "Coef(with demog) / Coef(base)", fill = "Outcome") +
    theme_minimal(base_size = 11) +
    theme(plot.background = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA))
  ggsave(file.path(plot_dir, "fraction_surviving.png"), p, width = 8, height = 5, dpi = 150, bg = "white")
}

cat("\n=== Demographic Mediator Analysis Complete ===\n")
