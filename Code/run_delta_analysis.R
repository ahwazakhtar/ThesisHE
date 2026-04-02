# Phase 3: Year-over-Year Weather Swing Analysis
#
# Estimand: the health/economic cost of weather *volatility* — year-to-year
# swings in climate exposure — distinct from the level effects in the event study.
#
# Primary spec (symmetric delta, controlling for lagged level):
#   Outcome_{it} = b1*Delta_X_{it} + b2*X_{it-1} + controls | fips_code + Year
#
# Distributed lag extension: h = 0, +1, +2, +3 forward horizons via Local Projections.
#
# Robustness specs:
#   - Asymmetric: separate Delta_Pos and Delta_Neg coefficients
#   - Binary onset/exit: Drought_Onset / Drought_Exit indicators
#
# Outputs:
#   Analysis/delta_coefs.csv          — tidy coefficient table
#   Analysis/delta_results.txt        — full model summaries
#   Analysis/plots/delta/             — coefficient plots
#   Analysis/plots/delta_robustness/  — asymmetry and onset/exit plots

# 1. Setup -----------------------------------------------------------------
library(dplyr)
library(tidyr)
library(fixest)
library(ggplot2)

input_path     <- "Data/county_level_master.csv"
output_coefs   <- "Analysis/delta_coefs.csv"
output_results <- "Analysis/delta_results.txt"
plot_dir       <- "Analysis/plots/delta"
plot_dir_rob   <- "Analysis/plots/delta_robustness"

dir.create("Analysis",    showWarnings = FALSE)
dir.create(plot_dir,      showWarnings = FALSE, recursive = TRUE)
dir.create(plot_dir_rob,  showWarnings = FALSE, recursive = TRUE)

cat("Loading data...\n")
df <- read.csv(input_path, stringsAsFactors = FALSE)

# 2. Data Prep -------------------------------------------------------------

if ("Population" %in% names(df) && !all(is.na(df$Population))) {
  df$Hosp_BadDebt_PerCapita <- df$Hosp_BadDebt_Total_Real / df$Population
}

# Debt reporting exclusion: CO 2023 only
debt_outcomes <- c("Medical_Debt_Share", "Medical_Debt_Median_2023")
debt_reporting_policy <- data.frame(State = "CO", Start_Year = 2023L, End_Year = 2023L,
                                    stringsAsFactors = FALSE)
if (length(intersect(debt_outcomes, names(df))) > 0 && "State" %in% names(df)) {
  state_upper <- toupper(trimws(as.character(df$State)))
  year_int    <- as.integer(df$Year)
  for (i in seq_len(nrow(debt_reporting_policy))) {
    mask <- state_upper == debt_reporting_policy$State[i] &
      year_int >= debt_reporting_policy$Start_Year[i] &
      year_int <= debt_reporting_policy$End_Year[i]
    for (v in intersect(debt_outcomes, names(df))) {
      df[[v]] <- ifelse(mask, NA_real_, as.numeric(df[[v]]))
    }
  }
  cat("Applied debt exclusion: CO 2023\n")
}

df$State <- as.factor(df$State)

# Ensure panel is sorted for lead/lag operations
df <- df %>% arrange(fips_code, Year)

# Fill year gaps to avoid stale lags across non-contiguous years
df <- df %>%
  group_by(fips_code) %>%
  complete(Year = min(Year):max(Year)) %>%
  ungroup() %>%
  arrange(fips_code, Year)

# 3. Config ----------------------------------------------------------------

# Delta exposures and their corresponding lagged-level control variables
# Structure: list(delta = "Delta_X", lagged_level = "X_Lag1", label = "readable label")
delta_specs <- list(
  list(delta = "Delta_Z_Temp",     lagged_level = "Z_Temp_Lag1",  label = "Z_Temp"),
  list(delta = "Delta_Z_Precip",   lagged_level = "Z_Precip_Lag1", label = "Z_Precip"),
  list(delta = "Delta_CDD",        lagged_level = "High_CDD_Lag1", label = "CDD"),
  list(delta = "Delta_HDD",        lagged_level = "High_HDD_Lag1", label = "HDD"),
  list(delta = "Delta_PDSI",       lagged_level = "PDSI_Lag1",     label = "PDSI"),
  list(delta = "Delta_Median_AQI", lagged_level = "Median_AQI_Lag1", label = "Median_AQI"),
  list(delta = "Delta_Max_AQI",    lagged_level = "Max_AQI_Lag1",    label = "Max_AQI")
)

# Asymmetric robustness pairs: Pos and Neg columns for each delta
asym_specs <- list(
  list(pos = "Delta_Z_Temp_Pos",     neg = "Delta_Z_Temp_Neg",     lagged_level = "Z_Temp_Lag1",   label = "Z_Temp"),
  list(pos = "Delta_Z_Precip_Pos",   neg = "Delta_Z_Precip_Neg",   lagged_level = "Z_Precip_Lag1", label = "Z_Precip"),
  list(pos = "Delta_CDD_Pos",        neg = "Delta_CDD_Neg",        lagged_level = "High_CDD_Lag1", label = "CDD"),
  list(pos = "Delta_HDD_Pos",        neg = "Delta_HDD_Neg",        lagged_level = "High_HDD_Lag1", label = "HDD"),
  list(pos = "Delta_PDSI_Pos",       neg = "Delta_PDSI_Neg",       lagged_level = "PDSI_Lag1",     label = "PDSI"),
  list(pos = "Delta_Median_AQI_Pos", neg = "Delta_Median_AQI_Neg", lagged_level = "Median_AQI_Lag1", label = "Median_AQI"),
  list(pos = "Delta_Max_AQI_Pos",    neg = "Delta_Max_AQI_Neg",    lagged_level = "Max_AQI_Lag1",    label = "Max_AQI")
)

# Binary onset/exit robustness specs (only for binary-shock-derived indicators)
onset_exit_specs <- list(
  list(onset = "Drought_Onset", exit = "Drought_Exit", persist = "Drought_Persist", label = "Drought"),
  list(onset = "CDD_Onset",     exit = "CDD_Exit",     persist = "CDD_Persist",     label = "CDD"),
  list(onset = "HDD_Onset",     exit = "HDD_Exit",     persist = "HDD_Persist",     label = "HDD")
)

outcomes <- c("Medical_Debt_Share", "Benchmark_Silver_Real",
              "Medical_Debt_Median_2023", "Hosp_BadDebt_PerCapita",
              "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed")
outcomes <- outcomes[outcomes %in% names(df)]

controls <- intersect(c("Household_Income_2023", "Uninsured_Rate"), names(df))

h_max <- 3L  # LP forward horizons 0..h_max

cat("Outcomes:", paste(outcomes, collapse = ", "), "\n")

# Filter delta_specs to variables that are actually present in df
delta_specs    <- Filter(function(s) s$delta %in% names(df), delta_specs)
asym_specs     <- Filter(function(s) s$pos %in% names(df) && s$neg %in% names(df), asym_specs)
onset_exit_specs <- Filter(function(s) s$onset %in% names(df), onset_exit_specs)

cat("Delta exposures available:", paste(sapply(delta_specs, `[[`, "label"), collapse = ", "), "\n")

# 4. Forward-horizon columns for LP ----------------------------------------

cat("Constructing LP forward outcome columns...\n")
for (o in outcomes) {
  df <- df %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      !!paste0(o, "_fwd0") := .data[[o]],
      !!paste0(o, "_fwd1") := dplyr::lead(.data[[o]], 1),
      !!paste0(o, "_fwd2") := dplyr::lead(.data[[o]], 2),
      !!paste0(o, "_fwd3") := dplyr::lead(.data[[o]], 3)
    ) %>%
    ungroup()
}

# 5. Helpers ---------------------------------------------------------------

safe_feols <- function(f, data, cluster_var, weights = NULL) {
  tryCatch({
    clust <- as.formula(paste0("~", cluster_var))
    if (!is.null(weights)) {
      feols(f, data = data, cluster = clust, weights = data[[weights]])
    } else {
      feols(f, data = data, cluster = clust)
    }
  }, error = function(e) {
    cat("    Error:", conditionMessage(e), "\n")
    return(NULL)
  })
}

extract_coef <- function(model, term, exposure, outcome, horizon, approach, weighting, N) {
  if (is.null(model)) return(NULL)
  ct <- as.data.frame(coeftable(model))
  ct$Term <- rownames(ct)
  row <- ct[ct$Term == term, , drop = FALSE]
  if (nrow(row) == 0) return(NULL)
  data.frame(
    exposure = exposure, outcome = outcome, horizon = horizon,
    term = term,
    estimate  = row$Estimate,
    std.error = row$`Std. Error`,
    p.value   = row$`Pr(>|t|)`,
    ci_low    = row$Estimate - 1.96 * row$`Std. Error`,
    ci_high   = row$Estimate + 1.96 * row$`Std. Error`,
    N = N, approach = approach, weighting = weighting,
    stringsAsFactors = FALSE
  )
}

# 6. Primary Spec: Contemporaneous FE (h=0) --------------------------------
# Outcome ~ Delta_X + Lagged_Level_X + controls | fips_code + Year
# Separates the change effect (b1) from the lagged level effect (b2).

cat("\n=== Primary Spec: Contemporaneous Delta FE ===\n")
coefs_primary <- list()

sink(output_results)
cat("=== Delta Analysis: Model Summaries ===\n\n")

for (spec in delta_specs) {
  for (o in outcomes) {
    # Build RHS: delta + lagged level + controls (drop missing columns)
    rhs <- c(spec$delta, spec$lagged_level, controls)
    rhs <- rhs[rhs %in% names(df)]
    f <- as.formula(paste(o, "~", paste(rhs, collapse = " + "), "| fips_code + Year"))

    for (wt in c("Unweighted", "Population")) {
      wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
      if (wt == "Population" && is.null(wt_arg)) next

      m <- safe_feols(f, df, "State", wt_arg)
      if (!is.null(m)) {
        label <- paste(spec$label, o, wt, sep = " | ")
        cat(paste0("\n--- ", label, " ---\n"))
        print(summary(m))
        N <- nobs(m)
        coefs_primary[[length(coefs_primary) + 1]] <- extract_coef(
          m, spec$delta, spec$label, o, 0L, "Delta_FE", wt, N)
        # Also capture lagged level coefficient for comparison
        if (spec$lagged_level %in% names(df)) {
          coefs_primary[[length(coefs_primary) + 1]] <- extract_coef(
            m, spec$lagged_level, paste0(spec$label, "_LaggedLevel"), o, 0L, "Delta_FE", wt, N)
        }

        # RA clustering for premium outcomes
        if (o == "Benchmark_Silver_Real" && "rating_area_id" %in% names(df)) {
          m_ra <- safe_feols(f, df, "rating_area_id", wt_arg)
          if (!is.null(m_ra)) {
            N_ra <- nobs(m_ra)
            coefs_primary[[length(coefs_primary) + 1]] <- extract_coef(
              m_ra, spec$delta, spec$label, o, 0L, "Delta_FE_RA_Cluster", wt, N_ra)
          }
        }
      }
    }
  }
}

# 7. LP Distributed Lag on Delta (h = 0..h_max) ----------------------------
# Outcome_{t+h} ~ Delta_X_t + Lagged_Level_X_t + controls | fips_code + Year
# Shows whether swing effects persist or decay over subsequent years.

cat("\n=== LP Distributed Lag on Delta ===\n")
coefs_lp <- list()

for (spec in delta_specs) {
  for (o in outcomes) {
    for (h in 0L:h_max) {
      dep_col <- paste0(o, "_fwd", h)
      if (!dep_col %in% names(df)) next

      rhs <- c(spec$delta, spec$lagged_level, controls)
      rhs <- rhs[rhs %in% names(df)]
      f <- as.formula(paste(dep_col, "~", paste(rhs, collapse = " + "), "| fips_code + Year"))

      for (wt in c("Unweighted", "Population")) {
        wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
        if (wt == "Population" && is.null(wt_arg)) next

        m <- safe_feols(f, df, "State", wt_arg)
        if (!is.null(m)) {
          coefs_lp[[length(coefs_lp) + 1]] <- extract_coef(
            m, spec$delta, spec$label, o, h, "Delta_LP", wt, nobs(m))
        }
      }
    }
  }
}

# 8. Asymmetric Robustness -------------------------------------------------
# Replace symmetric delta with Delta_Pos and Delta_Neg.
# Significant asymmetry (b_pos != |b_neg|) indicates ratchet / hysteresis.

cat("\n=== Asymmetric Robustness Specs ===\n")
coefs_asym <- list()

for (spec in asym_specs) {
  for (o in outcomes) {
    rhs <- c(spec$pos, spec$neg, spec$lagged_level, controls)
    rhs <- rhs[rhs %in% names(df)]
    f <- as.formula(paste(o, "~", paste(rhs, collapse = " + "), "| fips_code + Year"))

    for (wt in c("Unweighted", "Population")) {
      wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
      if (wt == "Population" && is.null(wt_arg)) next

      m <- safe_feols(f, df, "State", wt_arg)
      if (!is.null(m)) {
        N <- nobs(m)
        label <- paste(spec$label, o, wt, sep = " | ")
        cat(paste0("\n--- Asymmetric: ", label, " ---\n"))
        print(summary(m))
        coefs_asym[[length(coefs_asym) + 1]] <- extract_coef(
          m, spec$pos, paste0(spec$label, "_Pos"), o, 0L, "Delta_Asym", wt, N)
        coefs_asym[[length(coefs_asym) + 1]] <- extract_coef(
          m, spec$neg, paste0(spec$label, "_Neg"), o, 0L, "Delta_Asym", wt, N)
      }
    }
  }
}

# 9. Binary Onset/Exit Robustness ------------------------------------------
# Replaces continuous delta with shock entry (0->1), exit (1->0), persist (1->1).
# Tests whether it is the *transition* itself that drives outcomes.

cat("\n=== Binary Onset/Exit Robustness ===\n")
coefs_onset <- list()

for (spec in onset_exit_specs) {
  for (o in outcomes) {
    indicators <- c(spec$onset, spec$exit, spec$persist)
    indicators <- indicators[indicators %in% names(df)]
    if (length(indicators) == 0) next

    rhs <- c(indicators, controls)
    rhs <- rhs[rhs %in% names(df)]
    f <- as.formula(paste(o, "~", paste(rhs, collapse = " + "), "| fips_code + Year"))

    for (wt in c("Unweighted", "Population")) {
      wt_arg <- if (wt == "Population" && "Population" %in% names(df)) "Population" else NULL
      if (wt == "Population" && is.null(wt_arg)) next

      m <- safe_feols(f, df, "State", wt_arg)
      if (!is.null(m)) {
        N <- nobs(m)
        for (ind in indicators) {
          coefs_onset[[length(coefs_onset) + 1]] <- extract_coef(
            m, ind, paste0(spec$label, "_", sub(".*_", "", ind)), o, 0L, "Delta_OnsetExit", wt, N)
        }
      }
    }
  }
}

sink()
cat("Model summaries saved to:", output_results, "\n")

# 10. VIF Diagnostics ------------------------------------------------------

cat("\n=== VIF Diagnostics (Delta + Lagged Level Block) ===\n")
vif_log <- file("Analysis/delta_vif_diagnostics.txt", "w")

for (spec in delta_specs[1:3]) {  # spot-check first 3 exposures
  for (o in outcomes[1:2]) {
    rhs <- c(spec$delta, spec$lagged_level, controls)
    rhs <- rhs[rhs %in% names(df)]
    if (length(rhs) < 2) next

    # Auxiliary OLS on within-transformed predictors to compute VIF
    tryCatch({
      aux_data <- df %>%
        select(all_of(c("fips_code", "Year", rhs))) %>%
        filter(complete.cases(.)) %>%
        group_by(fips_code) %>%
        mutate(across(all_of(rhs), ~ . - mean(., na.rm = TRUE))) %>%
        ungroup() %>%
        group_by(Year) %>%
        mutate(across(all_of(rhs), ~ . - mean(., na.rm = TRUE))) %>%
        ungroup()

      vif_vals <- sapply(rhs, function(v) {
        others <- setdiff(rhs, v)
        if (length(others) == 0) return(NA_real_)
        f_aux <- as.formula(paste(v, "~", paste(others, collapse = " + ")))
        r2 <- summary(lm(f_aux, data = aux_data))$r.squared
        if (is.na(r2) || r2 >= 1) NA_real_ else 1 / (1 - r2)
      })

      writeLines(paste0("\n[", spec$label, " | ", o, "]"), vif_log)
      writeLines(paste(names(vif_vals), round(vif_vals, 3), sep = ": "), vif_log)
    }, error = function(e) {
      writeLines(paste0("[", spec$label, " | ", o, "] ERROR: ", conditionMessage(e)), vif_log)
    })
  }
}

close(vif_log)
cat("VIF diagnostics saved to Analysis/delta_vif_diagnostics.txt\n")

# 11. Combine & Export Coefficients ----------------------------------------

all_coef_lists <- c(coefs_primary, coefs_lp, coefs_asym, coefs_onset)
all_coef_lists <- Filter(Negate(is.null), all_coef_lists)
coefs_all <- if (length(all_coef_lists) > 0) bind_rows(all_coef_lists) else data.frame()
if (nrow(coefs_all) > 0) {
  write.csv(coefs_all, output_coefs, row.names = FALSE)
  cat("\nCoefficients saved to:", output_coefs, "\n")
  cat("Total rows:", nrow(coefs_all), "\n")
  cat("Breakdown by approach:\n")
  print(table(coefs_all$approach, coefs_all$weighting))
} else {
  cat("WARNING: No coefficients extracted.\n")
}

# 12. Visualization --------------------------------------------------------

cat("\n=== Generating Plots ===\n")

# Helper: standard coefficient plot
make_coef_plot <- function(data, title, filename, dir = plot_dir) {
  if (nrow(data) == 0) return(invisible(NULL))
  p <- ggplot(data, aes(x = horizon, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(ymin = ci_low, ymax = ci_high), size = 0.5) +
    scale_x_continuous(breaks = unique(data$horizon)) +
    labs(title = title, x = "Horizon (years after swing)", y = "Estimate") +
    theme_minimal(base_size = 12) +
    theme(plot.background  = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA))
  ggsave(file.path(dir, filename), p, width = 7, height = 5, dpi = 150, bg = "white")
  invisible(p)
}

# 12a. LP dynamic profiles per exposure x outcome
lp_plot <- coefs_all %>% filter(approach == "Delta_LP", weighting == "Unweighted")

for (exp_label in unique(lp_plot$exposure)) {
  for (o in outcomes) {
    sub <- lp_plot %>% filter(exposure == exp_label, outcome == o)
    if (nrow(sub) == 0) next
    make_coef_plot(sub,
                   paste("Delta LP:", exp_label, "->", o),
                   paste0("lp_delta_", exp_label, "_", o, ".png"))
  }
}

# 12b. Level vs. Delta comparison (contemporaneous h=0, unweighted)
level_cols <- sapply(delta_specs, `[[`, "label")

for (exp_label in level_cols) {
  for (o in outcomes) {
    delta_row <- coefs_all %>%
      filter(approach == "Delta_FE", exposure == exp_label,
             outcome == o, weighting == "Unweighted")
    if (nrow(delta_row) == 0) next

    delta_row$spec <- "Delta"

    combined <- delta_row %>% select(spec, estimate, ci_low, ci_high)

    p <- ggplot(combined, aes(x = spec, y = estimate)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_pointrange(aes(ymin = ci_low, ymax = ci_high), size = 0.6) +
      labs(title = paste("Delta Effect:", exp_label, "->", o),
           x = NULL, y = "Estimate") +
      theme_minimal(base_size = 12) +
      theme(plot.background  = element_rect(fill = "white", color = NA),
            panel.background = element_rect(fill = "white", color = NA))
    ggsave(file.path(plot_dir, paste0("delta_fe_", exp_label, "_", o, ".png")),
           p, width = 5, height = 4, dpi = 150, bg = "white")
  }
}

# 12c. Asymmetry plots: Pos vs Neg per exposure x outcome
asym_plot <- coefs_all %>% filter(approach == "Delta_Asym", weighting == "Unweighted")

for (o in outcomes) {
  sub <- asym_plot %>% filter(outcome == o)
  if (nrow(sub) == 0) next

  # Strip "_Pos"/"_Neg" to get base label; add direction column
  sub <- sub %>%
    mutate(
      direction = ifelse(grepl("_Pos$", exposure), "Escalation (+)", "Relief (-)"),
      base_label = gsub("_Pos$|_Neg$", "", exposure)
    )

  p <- ggplot(sub, aes(x = base_label, y = estimate, color = direction)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                    position = position_dodge(width = 0.4), size = 0.5) +
    scale_color_manual(values = c("Escalation (+)" = "#B2182B", "Relief (-)" = "#2166AC")) +
    labs(title = paste("Asymmetric Delta Effects ->", o),
         subtitle = "Escalation = positive swing; Relief = negative swing",
         x = "Exposure", y = "Estimate", color = NULL) +
    theme_minimal(base_size = 11) +
    theme(axis.text.x = element_text(angle = 30, hjust = 1),
          plot.background  = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA))
  ggsave(file.path(plot_dir_rob, paste0("asym_delta_", o, ".png")),
         p, width = 9, height = 5, dpi = 150, bg = "white")
}

# 12d. Onset/Exit plots per exposure x outcome
onset_plot <- coefs_all %>% filter(approach == "Delta_OnsetExit", weighting == "Unweighted")

for (o in outcomes) {
  sub <- onset_plot %>% filter(outcome == o)
  if (nrow(sub) == 0) next

  sub <- sub %>%
    mutate(transition = gsub(".*_(Onset|Exit|Persist)$", "\\1", exposure),
           base_label = gsub("_(Onset|Exit|Persist)$", "", exposure))

  p <- ggplot(sub, aes(x = base_label, y = estimate, color = transition)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(ymin = ci_low, ymax = ci_high),
                    position = position_dodge(width = 0.4), size = 0.5) +
    scale_color_manual(values = c("Onset" = "#B2182B", "Exit" = "#2166AC", "Persist" = "#4DAF4A")) +
    labs(title = paste("Onset / Exit / Persist Effects ->", o),
         x = "Shock", y = "Estimate", color = "Transition") +
    theme_minimal(base_size = 11) +
    theme(plot.background  = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA))
  ggsave(file.path(plot_dir_rob, paste0("onset_exit_", o, ".png")),
         p, width = 8, height = 5, dpi = 150, bg = "white")
}

# 13. Summary Diagnostics --------------------------------------------------

cat("\n=== Sample Diagnostics (h=0, Unweighted) ===\n")
diag <- coefs_all %>%
  filter(horizon == 0, weighting == "Unweighted") %>%
  group_by(exposure, outcome, approach) %>%
  summarize(N = first(N), .groups = "drop")
print(as.data.frame(diag))

cat("\n=== Delta Analysis Complete ===\n")
