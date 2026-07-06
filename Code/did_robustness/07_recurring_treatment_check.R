# =============================================================================
# 07_recurring_treatment_check.R  (mechanisms_revision_20260704 — Task 2.4 / B1)
# =============================================================================
# The second reviewer (B1): the distributed-lag TWFE with RECURRING binary
# treatment (shocks switch on/off) is the setup the modern DiD literature warns
# about (negative weights, lag contamination). Two checks with the tools actually
# built for reversible/recurring treatment (de Chaisemartin–D'Haultfœuille — most
# of the DiD toolkit, e.g. Goodman-Bacon and Borusyak–Jaravel–Spiess, is
# staggered-adoption-only and does NOT apply here):
#   (1) twowayfeweights — the NEGATIVE-WEIGHT SHARE the static TWFE places on its
#       treated 2x2 comparisons (the referee's literal ask).
#   (2) did_multiplegt_dyn — a robust dynamic event-study for recurring treatment,
#       on the two load-bearing headline pairs: HEAT -> Medicare spending
#       (morbidity channel) and COLD -> medical-debt share (financial headline).
#
# NOTE the estimands differ from the linear distributed-lag coefficient, so these
# are ROBUSTNESS COMPANIONS, not drop-in replacements.
#
# ENV: **R 4.5.3** (TwoWayFEWeights, DIDmultiplegtDYN).
#   "C:/Program Files/R/R-4.5.3/bin/Rscript.exe" Code/did_robustness/07_recurring_treatment_check.R
# OUTPUT: Analysis/mechanism/recurring_treatment_check.csv + log.
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(TwoWayFEWeights); library(polars); library(DIDmultiplegtDYN)
})
dir.create("Analysis/mechanism/build_logs", showWarnings = FALSE, recursive = TRUE)
lc <- file("Analysis/mechanism/build_logs/recurring_treatment_check.log", open = "wt")
sink(lc, split = TRUE); on.exit({ sink(); close(lc) }, add = TRUE)
cat("=== B1 recurring-treatment check (R 4.5.3) ::", format(Sys.time()), "===\n\n")

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
df <- read.csv("Data/county_level_master.csv")
df$fips_code <- pad_fips(df$fips_code)
df <- df %>% filter(Year >= 2011, Year <= 2023)
# join Medicare morbidity outcomes if not already on the master
if (!"Mdcr_Std_Payment_PC" %in% names(df)) {
  med <- readRDS("Data/intermediate_medicare_spending.rds")
  med$fips_code <- pad_fips(med$fips_code)
  df <- dplyr::left_join(df, med[, c("fips_code","Year","Mdcr_Std_Payment_PC","ER_Visits_per1000")],
                         by = c("fips_code","Year"))
}
df$gid <- as.integer(factor(df$fips_code))          # numeric group id
df$log_emp <- ifelse(df$Civilian_Employed > 0, log(df$Civilian_Employed), NA_real_)

# pairs: (treatment shock, outcome, label)
pairs <- list(
  list(D = "High_CDD",           Y = "Mdcr_Std_Payment_PC", lab = "heat_medicare_spending"),
  list(D = "High_HDD",           Y = "Medical_Debt_Share",  lab = "cold_medical_debt"),
  list(D = "Is_Extreme_Drought", Y = "PCPI_Real",           lab = "drought_income"))

# ---- (1) negative-weight diagnostic (static TWFE) -------------------------
cat("--- (1) twowayfeweights: negative-weight share of the static TWFE ---\n")
nw_rows <- list()
for (p in pairs) {
  d <- df[!is.na(df[[p$Y]]) & !is.na(df[[p$D]]), ]
  w <- tryCatch(
    twowayfeweights(d, Y = p$Y, G = "gid", T = "Year", D = p$D, type = "feTR"),
    error = function(e) { cat("  err", p$lab, ":", conditionMessage(e), "\n"); NULL })
  if (is.null(w)) next
  cat("\n  ", p$lab, ":\n")
  wl <- capture.output(print(w))
  # log the negative-weight summary lines (contain "negative" / "weights")
  keep <- grep("negative|positive|weights|sum|nr", wl, ignore.case = TRUE)
  cat(paste0("    ", wl[keep]), sep = "\n")
  nw_rows[[length(nw_rows)+1]] <- data.frame(pair = p$lab,
    summary_lines = paste(wl[keep], collapse = " ~ "), stringsAsFactors = FALSE)
}

# ---- (2) robust dynamic estimator on the two load-bearing pairs -----------
cat("\n--- (2) did_multiplegt_dyn: robust dynamic effects (2 effects + 1 placebo) ---\n")
dyn_rows <- list()
for (p in pairs[1:2]) {
  sub <- df[!is.na(df[[p$Y]]) & !is.na(df[[p$D]]), ]
  d <- data.frame(gid = as.numeric(sub$gid), Year = as.numeric(sub$Year),
                  D = as.numeric(sub[[p$D]]), Y = as.numeric(sub[[p$Y]]),
                  cl = as.numeric(as.integer(factor(sub$State))))
  m <- tryCatch(
    did_multiplegt_dyn(df = d, outcome = "Y", group = "gid", time = "Year",
                       treatment = "D", effects = 2, placebo = 1,
                       cluster = "cl", graph_off = TRUE),
    error = function(e) { cat("  err", p$lab, ":", conditionMessage(e), "\n"); NULL })
  if (is.null(m)) next
   es <- as.data.frame(m$results$Effects)
  pl <- tryCatch(as.data.frame(m$results$Placebos), error = function(e) NULL)
  cat("  ", p$lab, "— dynamic effects:\n"); print(round(es[, 1:4], 4))
  if (!is.null(pl)) { cat("   placebo:\n"); print(round(pl[, 1:4], 4)) }
  es$pair <- p$lab; es$kind <- rownames(es)
  dyn_rows[[length(dyn_rows)+1]] <- es
}

out <- bind_rows(lapply(dyn_rows, function(x) x[, intersect(names(x), c("pair","kind","Estimate","SE","LB","UB")), drop=FALSE]))
if (length(nw_rows)) write.csv(bind_rows(nw_rows), "Analysis/mechanism/recurring_negweights.csv", row.names = FALSE)
if (nrow(out)) write.csv(out, "Analysis/mechanism/recurring_treatment_check.csv", row.names = FALSE)
cat("\nWrote Analysis/mechanism/recurring_{negweights,treatment_check}.csv\n")
cat("=== done", format(Sys.time()), "===\n")
