# ---------------------------------------------------------------------------
# run_cumulative_dose.R  (Persistence Extensions — Phase 3)
#
# Dose-response of CUMULATIVE shock exposure. For each county-year we count the
# running number of shock-positive years to date (Cum_*_Years, monotonic
# non-decreasing; see Code/cumulative_dose.R) and ask whether the marginal cost
# of, say, the 10th year of cold differs from the 1st.
#
#   Y_it = alpha_i + gamma_t + f(CumYears_it) + X_it'd + e_it
#
# Functional forms for f():
#   - Linear     : CumYears
#   - Quadratic  : CumYears + CumYears^2   (marginal effect b1 + 2*b2*x)
#   - Binned     : 1-3 / 4-6 / 7-9 / 10+   (reference = 0 cumulative years)
#
# Outputs:
#   Analysis/cumulative_dose/cumulative_dose_coefs.csv      (all forms, tidy)
#   Analysis/cumulative_dose/cumulative_dose_marginal.csv   (quadratic ME at x=1,5,10; 10+ vs 1-3)
#   Analysis/plots/cumulative_dose/*.png
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr); library(readr); library(fixest); library(ggplot2)
})
source("Code/cumulative_dose.R")

master_path <- "Data/county_level_master.csv"
plot_dir    <- "Analysis/plots/cumulative_dose"
dir.create("Analysis", showWarnings = FALSE)
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

df <- read_csv(master_path, show_col_types = FALSE, progress = FALSE)
if (all(c("Hosp_BadDebt_Total_Real", "Population") %in% names(df))) {
  df$Hosp_BadDebt_PerCapita <- df$Hosp_BadDebt_Total_Real / df$Population
}
df <- df %>% filter(Year >= 2011, Year <= 2023) %>% arrange(fips_code, Year)

dose_specs <- list(
  list(shock = "Is_Extreme_Drought", cum = "Cum_Drought_Years", label = "Drought"),
  list(shock = "High_CDD",           cum = "Cum_CDD_Years",     label = "CDD"),
  list(shock = "High_HDD",           cum = "Cum_HDD_Years",     label = "HDD")
)
dose_specs <- Filter(function(s) s$shock %in% names(df), dose_specs)

# Build cumulative, quadratic, and bin columns for each shock
for (spec in dose_specs) {
  df <- add_cumulative_shock_years(df, spec$shock, spec$cum)
  df[[paste0(spec$cum, "_sq")]]    <- df[[spec$cum]]^2
  df[[paste0(spec$label, "_d1_3")]]  <- as.integer(df[[spec$cum]] >= 1 & df[[spec$cum]] <= 3)
  df[[paste0(spec$label, "_d4_6")]]  <- as.integer(df[[spec$cum]] >= 4 & df[[spec$cum]] <= 6)
  df[[paste0(spec$label, "_d7_9")]]  <- as.integer(df[[spec$cum]] >= 7 & df[[spec$cum]] <= 9)
  df[[paste0(spec$label, "_d10p")]]  <- as.integer(df[[spec$cum]] >= 10)
}

outcomes <- c("Medical_Debt_Share", "PCPI_Real", "Hosp_BadDebt_PerCapita",
              "Med_HH_Income_Real", "Civilian_Employed", "Benchmark_Silver_Real")
outcomes <- outcomes[outcomes %in% names(df)]
controls <- intersect(c("Household_Income_2023", "Uninsured_Rate"), names(df))

cat("Cumulative-year ranges:\n")
for (spec in dose_specs) {
  cat(sprintf("  %-8s max=%d  (counties reaching 10+: %d)\n", spec$label,
              max(df[[spec$cum]], na.rm = TRUE),
              length(unique(df$fips_code[df[[spec$cum]] >= 10]))))
}

safe_feols <- function(f, data, wt_arg = NULL) {
  tryCatch({
    if (!is.null(wt_arg)) feols(f, data = data, cluster = ~State, weights = data[[wt_arg]])
    else feols(f, data = data, cluster = ~State)
  }, error = function(e) { cat("    err:", conditionMessage(e), "\n"); NULL })
}

extract_terms <- function(model, terms, shock, outcome, form, weighting) {
  if (is.null(model)) return(NULL)
  ct <- as.data.frame(coeftable(model)); ct$Term <- rownames(ct)
  ct <- ct[ct$Term %in% terms, , drop = FALSE]
  if (nrow(ct) == 0) return(NULL)
  data.frame(shock = shock, outcome = outcome, form = form, term = ct$Term,
             estimate = ct$Estimate, std.error = ct$`Std. Error`,
             p.value = ct$`Pr(>|t|)`, N = nobs(model), weighting = weighting,
             stringsAsFactors = FALSE)
}

coef_rows <- list()
marg_rows <- list()

for (spec in dose_specs) {
  cum   <- spec$cum
  cumsq <- paste0(cum, "_sq")
  bins  <- paste0(spec$label, c("_d1_3", "_d4_6", "_d7_9", "_d10p"))

  for (o in outcomes) {
    base_rhs <- paste(c(controls), collapse = " + ")
    ctl <- if (nchar(base_rhs) > 0) paste("+", base_rhs) else ""

    f_lin  <- as.formula(paste(o, "~", cum, ctl, "| fips_code + Year"))
    f_quad <- as.formula(paste(o, "~", cum, "+", cumsq, ctl, "| fips_code + Year"))
    f_bin  <- as.formula(paste(o, "~", paste(bins, collapse = " + "), ctl, "| fips_code + Year"))

    for (wt in c("Unweighted", "Population")) {
      wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
      if (wt == "Population" && is.null(wt_arg)) next

      m_lin  <- safe_feols(f_lin,  df, wt_arg)
      m_quad <- safe_feols(f_quad, df, wt_arg)
      m_bin  <- safe_feols(f_bin,  df, wt_arg)

      coef_rows[[length(coef_rows) + 1]] <- extract_terms(m_lin, cum, spec$label, o, "Linear", wt)
      coef_rows[[length(coef_rows) + 1]] <- extract_terms(m_quad, c(cum, cumsq), spec$label, o, "Quadratic", wt)
      coef_rows[[length(coef_rows) + 1]] <- extract_terms(m_bin, bins, spec$label, o, "Binned", wt)

      # Marginal effects from the quadratic: ME(x) = b_cum + 2*b_cumsq*x
      if (!is.null(m_quad) && all(c(cum, cumsq) %in% names(coef(m_quad)))) {
        for (x in c(1, 5, 10)) {
          me <- lincom(m_quad, setNames(c(1, 2 * x), c(cum, cumsq)))
          if (!is.null(me)) {
            me$shock <- spec$label; me$outcome <- o; me$weighting <- wt
            me$quantity <- paste0("ME_quadratic_at_", x); marg_rows[[length(marg_rows) + 1]] <- me
          }
        }
        # ME(10) - ME(1) = 18 * b_cumsq
        d <- lincom(m_quad, setNames(18, cumsq))
        if (!is.null(d)) {
          d$shock <- spec$label; d$outcome <- o; d$weighting <- wt
          d$quantity <- "ME_diff_10_minus_1_quadratic"; marg_rows[[length(marg_rows) + 1]] <- d
        }
      }
      # Binned contrast: 10+ vs 1-3
      if (!is.null(m_bin)) {
        d10 <- paste0(spec$label, "_d10p"); d13 <- paste0(spec$label, "_d1_3")
        cc <- lincom(m_bin, setNames(c(1, -1), c(d10, d13)))
        if (!is.null(cc)) {
          cc$shock <- spec$label; cc$outcome <- o; cc$weighting <- wt
          cc$quantity <- "binned_10plus_minus_1to3"; marg_rows[[length(marg_rows) + 1]] <- cc
        }
      }
    }
  }
}

coefs <- bind_rows(Filter(Negate(is.null), coef_rows))
marg  <- bind_rows(Filter(Negate(is.null), marg_rows))
if (nrow(marg) > 0) marg <- marg[, c("shock", "outcome", "weighting", "quantity",
                                     "estimate", "std.error", "z.value", "p.value")]

write_csv(coefs, "Analysis/cumulative_dose/cumulative_dose_coefs.csv")
write_csv(marg,  "Analysis/cumulative_dose/cumulative_dose_marginal.csv")
cat(sprintf("\nSaved %d coef rows, %d marginal rows.\n", nrow(coefs), nrow(marg)))

cat("\n=== HDD: is year-10 marginal cost different from year-1? (Unweighted) ===\n")
print(as.data.frame(
  marg %>% filter(shock == "HDD", weighting == "Unweighted",
                  quantity %in% c("ME_diff_10_minus_1_quadratic", "binned_10plus_minus_1to3")) %>%
    mutate(across(c(estimate, std.error, p.value), ~ round(.x, 4)))), row.names = FALSE)

# Plots: binned dose-response staircase per (shock x outcome), Unweighted -------
bin_levels <- c("1-3", "4-6", "7-9", "10+")
binned <- coefs %>%
  filter(form == "Binned", weighting == "Unweighted") %>%
  mutate(band = dplyr::recode(sub(".*_d", "", term),
                              "1_3" = "1-3", "4_6" = "4-6", "7_9" = "7-9", "10p" = "10+"),
         band = factor(band, levels = bin_levels),
         ci_low = estimate - 1.96 * std.error, ci_high = estimate + 1.96 * std.error)

for (sh in unique(binned$shock)) {
  for (o in unique(binned$outcome)) {
    sub <- binned %>% filter(shock == sh, outcome == o, !is.na(band))
    if (nrow(sub) == 0) next
    p <- ggplot(sub, aes(x = band, y = estimate, group = 1)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_pointrange(aes(ymin = ci_low, ymax = ci_high), color = "#762A83") +
      geom_line(color = "#762A83", alpha = 0.6) +
      labs(title = paste("Cumulative dose-response:", sh, "->", o),
           subtitle = "Effect vs 0 cumulative shock-years (FE: county + year)",
           x = "Cumulative shock-years", y = "Estimate vs 0 years") +
      theme_minimal(base_size = 11) +
      theme(plot.background = element_rect(fill = "white", color = NA),
            panel.background = element_rect(fill = "white", color = NA))
    ggsave(file.path(plot_dir, paste0("dose_", sh, "_", o, ".png")),
           p, width = 6, height = 5, dpi = 150, bg = "white")
  }
}

cat("\n=== Cumulative Dose Analysis Complete ===\n")
cat("Plots in:", plot_dir, "\n")
