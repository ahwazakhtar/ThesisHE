# run_mad_scaling.R — mean-absolute-deviation scaling of the impulse responses
# (advisor_feedback_20260807, Task 1.5; spec O4).
#
# PURPOSE -------------------------------------------------------------------
# Advisor: report the mean absolute deviation (MAD) in the impulse-response context so
# impulse magnitudes can be read against typical outcome deviations ("to get an idea").
# Two constructions, both reported (spec O4 open question):
#   MAD_diff — mean |y_t - y_{t-1}| within county, pooled over the analysis window
#              (the simple "typical year-to-year move"; PRIMARY / lead).
#   MAD_fe   — mean |residual| from y ~ 1 | fips_code + Year (the within-variation
#              the FE impulse models actually operate on; SECONDARY).
# Each LP impulse coefficient (Task 1.4 grid, h=0..5) is re-expressed as a share of
# both MADs. Descriptive; no hypothesis. If the two scalings tell different stories,
# flag for advisor confirmation.
#
# INPUTS : Data/county_level_master.csv,
#          Analysis/advisor_robustness/horizon_sensitivity.csv  (LP rows)
# OUTPUTS: Analysis/advisor_robustness/mad_scaling_table.csv
#          Analysis/advisor_robustness/build_logs/run_mad_scaling.log
# R 4.5.2.

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
})
source("Code/pipeline_utils.R")

close_log <- open_build_log("advisor_robustness", "run_mad_scaling")
on.exit(close_log(), add = TRUE)

df <- read.csv("Data/county_level_master.csv")
df$fips_code <- pad_fips(df$fips_code)
df$Medical_Debt_Share[toupper(trimws(df$State)) == "CO" & df$Year == 2023] <- NA_real_
df <- df %>% filter(Year >= 2011, Year <= 2023) %>% arrange(fips_code, Year)

outcomes <- c("Medical_Debt_Share", "PCPI_Real", "Civilian_Employed")

# 1. MADs -------------------------------------------------------------------
mads <- list()
for (o in outcomes) {
  d1 <- df %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(.chg = .data[[o]] - dplyr::lag(.data[[o]], 1)) %>%
    ungroup()
  mad_diff <- mean(abs(d1$.chg), na.rm = TRUE)

  m_fe <- feols(as.formula(paste(o, "~ 1 | fips_code + Year")), data = df)
  mad_fe <- mean(abs(resid(m_fe)), na.rm = TRUE)

  mads[[o]] <- data.frame(Outcome = o, MAD_diff = mad_diff, MAD_fe = mad_fe,
                          N_chg = sum(!is.na(d1$.chg)), N_fe = nobs(m_fe),
                          stringsAsFactors = FALSE)
  cat(sprintf("%-20s MAD_diff = %.6g   MAD_fe = %.6g   (ratio %.2f)\n",
              o, mad_diff, mad_fe, mad_diff / mad_fe))
}
mads <- dplyr::bind_rows(mads)

# 2. Scale the LP impulses ---------------------------------------------------
hs <- read.csv("Analysis/advisor_robustness/horizon_sensitivity.csv") %>%
  filter(Approach == "LP") %>%
  select(Shock, Outcome, Horizon, Estimate, SE, p, N)
stopifnot(nrow(hs) > 0, all(hs$Outcome %in% c(outcomes, "PCPI_Real")))

out <- hs %>%
  inner_join(mads, by = "Outcome") %>%
  mutate(
    Share_of_MAD_diff = Estimate / MAD_diff,
    Share_of_MAD_fe   = Estimate / MAD_fe
  ) %>%
  arrange(Shock, Outcome, Horizon)

write.csv(out, "Analysis/advisor_robustness/mad_scaling_table.csv", row.names = FALSE)

cat("\n========= IMPULSES AS SHARES OF TYPICAL DEVIATION (LP, unweighted) =========\n")
print(out %>%
        filter(Horizon <= 3) %>%
        mutate(across(c(Estimate, Share_of_MAD_diff, Share_of_MAD_fe), ~signif(.x, 3))) %>%
        select(Shock, Outcome, Horizon, Estimate, p, Share_of_MAD_diff, Share_of_MAD_fe),
      row.names = FALSE)

# Divergence flag (spec O4): do the two scalings disagree materially?
div <- out %>%
  filter(p < 0.10) %>%
  mutate(ratio = abs(Share_of_MAD_diff / Share_of_MAD_fe)) %>%
  summarise(min_r = min(ratio), max_r = max(ratio))
cat(sprintf("\nScaling-divergence check (significant cells): share ratios %.2f-%.2f %s\n",
            div$min_r, div$max_r,
            if (div$max_r / div$min_r < 2) "- consistent story, no advisor flag needed"
            else "- DIVERGENT, flag for advisor"))
cat("\nWrote Analysis/advisor_robustness/mad_scaling_table.csv (", nrow(out), "rows )\n")
