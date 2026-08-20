# =============================================================================
# create_falsification_table.R  (thesis_completion_20260704 — Essay 1 Appendix A)
# =============================================================================
# Builds exhibit E1-T4's printed table:
#
#   Analysis/did/robustness/falsification_table.{csv,tex}
#
# One row per inference or falsification test applied to the 2012 drought 2x2,
# so Appendix A.3 can carry the whole robustness suite in a single table instead
# of six paragraphs of "we did X, p = Y" (Appendix A shortening, 2026-08-18).
#
# Every statistic is READ from the committed robustness outputs — nothing here is
# typed from a write-up:
#   bea_pretrends_1990_2011.csv          parallel-trends slope + joint Wald
#   wild_bootstrap_2x2.csv               WCB (Webb) and randomization inference
#   dr_2x2_drought_2012.csv              doubly-robust ATT
#   falsification_loo_state.csv          leave-one-treated-state-out envelope
#   falsification_placebo_onsets.csv     placebo-onset distribution
#   ../did_2x2_baseline_sensitivity_drought2012.csv   pre-window sensitivity
#
# Tests whose statistics live only in narrative documents (humidity, ACS
# demographics, threshold grids, Conley kernels) are DELIBERATELY EXCLUDED rather
# than transcribed: the essay cites those in prose with a pointer. Adding them
# here would reintroduce hand-typed coefficients the registry rule forbids.
#
# ENV: R 4.5.2.  Rscript Code/create_falsification_table.R
# =============================================================================

suppressPackageStartupMessages({ library(dplyr) })

ROB_DIR <- "Analysis/did/robustness"
OUT_CSV <- file.path(ROB_DIR, "falsification_table.csv")
OUT_TEX <- file.path(ROB_DIR, "falsification_table.tex")

# Reuse the table writer from the data-source exhibit so both manuscript tables
# share one LaTeX style (booktabs + tabularx sized to \textwidth).
source("Code/create_data_source_tables.R", local = TRUE)

usd <- function(x) paste0(ifelse(x < 0, "-$", "$"),
                          formatC(abs(x), format = "f", digits = 0, big.mark = ","))
# Plain "<": write_tex_table()'s escaper renders it as a text-mode less-than.
# Emitting math delimiters here got the dollars escaped, printing a literal
# "$<$0.001" -- the same defect already fixed in the other two table builders.
pv <- function(p) if (is.na(p)) "--" else if (p < 0.001) "<0.001" else
  formatC(p, format = "f", digits = 3)

if (sys.nframe() == 0L) {
  dir.create(file.path(ROB_DIR, "build_logs"), showWarnings = FALSE, recursive = TRUE)
  lc <- file(file.path(ROB_DIR, "build_logs", "create_falsification_table.log"), open = "wt")
  sink(lc, split = TRUE); sink(lc, type = "message")
  on.exit({ sink(type = "message"); sink(); close(lc) }, add = TRUE)
  cat("=== Essay 1 falsification table (E1-T4) ::", format(Sys.time()), "===\n\n")

  need <- function(p) { if (!file.exists(p)) stop("missing input: ", p); p }

  pre  <- read.csv(need(file.path(ROB_DIR, "bea_pretrends_1990_2011.csv")))
  wcb  <- read.csv(need(file.path(ROB_DIR, "wild_bootstrap_2x2.csv")))
  dr   <- read.csv(need(file.path(ROB_DIR, "dr_2x2_drought_2012.csv")))
  loo  <- read.csv(need(file.path(ROB_DIR, "falsification_loo_state.csv")))
  plac <- read.csv(need(file.path(ROB_DIR, "falsification_placebo_onsets.csv")))
  base <- read.csv(need("Analysis/did/did_2x2_baseline_sensitivity_drought2012.csv"))

  w <- wcb %>% filter(Outcome == "PCPI_Real") %>% slice(1)
  d <- dr  %>% filter(Outcome == "PCPI_Real") %>% slice(1)
  slope <- pre %>% filter(test == "linear_diff_slope") %>% slice(1)
  wald  <- pre %>% filter(test == "eventstudy_joint_wald") %>% slice(1)

  # LOO envelope excludes the no-drop baseline row.
  loo_d <- loo %>% filter(state_dropped != "(none)")
  loo_lo <- min(loo_d$pcpi_att); loo_hi <- max(loo_d$pcpi_att)
  n_drop <- nrow(loo_d)
  n_flip <- sum(loo_d$pcpi_p > 0.05)
  flip_states <- paste(loo_d$state_dropped[loo_d$pcpi_p > 0.05], collapse = ", ")

  # Placebo column name varies by vintage; take the first numeric ATT-like field.
  pcol <- grep("att", names(plac), ignore.case = TRUE, value = TRUE)[1]
  if (is.na(pcol)) stop("no ATT column found in falsification_placebo_onsets.csv")
  pa <- plac[[pcol]]
  real_att <- w$ATT
  p_plac <- mean(abs(pa) >= abs(real_att))
  B <- length(pa)

  b <- base %>% filter(Outcome == "PCPI_Real")
  b11 <- b %>% filter(Pre_Period_Start == 2011) %>% slice(1)
  b09 <- b %>% filter(Pre_Period_Start == 2009) %>% slice(1)

  cat("benchmark ATT (PCPI):", round(real_att, 1), "\n")
  cat("LOO drops:", n_drop, "| envelope [", round(loo_lo), ",", round(loo_hi), "]\n")
  cat("placebo draws:", B, "| two-sided p:", p_plac, "\n\n")

  tbl <- data.frame(
    Test = c(
      "Parallel pre-trends (BEA, 1990--2011)",
      "Wild-cluster bootstrap (Webb)",
      "Randomization inference",
      "Doubly-robust estimator",
      "Leave-one-treated-state-out",
      "Placebo onset years",
      "Pre-window sensitivity"),
    `What it addresses` = c(
      "Treated and control counties on different trajectories before 2012",
      "Only 17 treated states; analytic clustering overstates precision",
      "Same, without asymptotic approximation",
      "Treated counties differ in observable composition",
      "One influential treated state drives the result",
      "The contrast would arise at any onset year",
      "The estimate depends on the single 2011 pre-year"),
    Statistic = c(
      paste0(usd(slope$stat), "/yr (SE ", formatC(slope$se, format = "f", digits = 0),
             "), p = ", pv(slope$p_value), "; joint Wald F = ",
             formatC(wald$stat, format = "f", digits = 1), ", p ", pv(wald$p_value)),
      paste0("p = ", pv(w$p_wcb_webb), "; CI [", usd(w$wcb_ci_lo), ", ", usd(w$wcb_ci_hi), "]"),
      paste0("p = ", pv(w$p_randinf)),
      paste0(usd(d$ATT), " (SE ", formatC(d$SE, format = "f", digits = 0), "); CI [",
             usd(d$ci_lo), ", ", usd(d$ci_hi), "]"),
      paste0("ATT envelope [", usd(loo_lo), ", ", usd(loo_hi), "] over ", n_drop, " drops"),
      paste0("two-sided p = ", pv(p_plac), " (B = ", format(B, big.mark = ","), ")"),
      paste0("pre = 2011: ", usd(b11$ATT), " (p = ", pv(b11$p_value), "); pre = 2009--2011: ",
             usd(b09$ATT), " (p = ", pv(b09$p_value), ")")),
    Verdict = c(
      paste0("Slope does not reject; joint test does. Drift is located in the farm ",
             "component (A.2), not treated as settled by this test."),
      "Survives; the bootstrap interval is the one cited in the text.",
      "Survives.",
      "Survives; conditioning on observables does not erode the contrast.",
      paste0("Envelope stays inside the bootstrap interval; analytic significance ",
             "flips on ", n_flip, " drops (", flip_states, ")."),
      "Estimate sits in the far tail of the placebo distribution.",
      "Not robust: the contrast is a function of the baseline year (see A.2)."),
    check.names = FALSE, stringsAsFactors = FALSE)

  write.csv(tbl, OUT_CSV, row.names = FALSE)
  write_tex_table(
    tbl, OUT_TEX,
    align = paste0(P(3.1), " ", RX, " ", P(4.2), " ", P(3.4)),
    caption = "Inference and falsification tests, 2012 drought event contrast (per-capita income)",
    label = "tab:e1t4",
    note = paste0(
      "All statistics are drawn from the ",
      "robustness suite. The estimand throughout is the ",
      "intention-to-treat effect of first extreme-drought onset in 2012 for the 139 ",
      "treated counties, against 2,534 never-exposed counties, with county and year ",
      "fixed effects and state-clustered standard errors. Further checks are ",
      "reported in the text and appendices -- humidity, ACS demographic controls, threshold ",
      "grids, and Conley spatial kernels. ",
      ""))

  cat("wrote falsification_table.{csv,tex} —", nrow(tbl), "tests\n")
  cat("\n=== done ===\n")
}
