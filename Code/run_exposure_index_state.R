# ---------------------------------------------------------------------------
# run_exposure_index_state.R  (Cross-Level Symmetry — SVI exposure at state level)
#
# State mirror of run_exposure_index.R. County CDC-SVI is population-weighted to a
# STATE vulnerability index (SVI_state, time-invariant) and the EJ-amplification
# interactions are run in the state pipeline:
#   Y ~ Shock + Shock x SVI_state + controls | State + Year
#
# CAVEAT: vulnerability is inherently local; aggregating to 51 states is coarse
# and the interaction is identified off only 51 SVI values, so this is a
# robustness mirror of the county EJ result, not a replacement.
#
# Output: Analysis/exposure_interaction_state_coefs.csv
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(dplyr); library(readr); library(fixest) })
source("Code/cumulative_dose.R")   # lincom()
if (!exists("%||%")) `%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x

s   <- read_csv("Data/analysis_ready_dataset.csv", show_col_types = FALSE, progress = FALSE)
svi <- readRDS("Data/intermediate_svi.rds")
cty <- read_csv("Data/county_level_master.csv", show_col_types = FALSE, progress = FALSE)
cty$fips_code <- formatC(as.integer(cty$fips_code), width = 5, flag = "0")
svi$fips_code <- formatC(as.integer(svi$fips_code), width = 5, flag = "0")

# County master stores State as a 2-letter abbreviation; map to the full names
# used by the state pipeline so the population-weighted aggregation joins.
state_abb_to_name <- c(
  AL="Alabama", AK="Alaska", AZ="Arizona", AR="Arkansas", CA="California", CO="Colorado",
  CT="Connecticut", DE="Delaware", DC="District of Columbia", FL="Florida", GA="Georgia",
  HI="Hawaii", ID="Idaho", IL="Illinois", IN="Indiana", IA="Iowa", KS="Kansas", KY="Kentucky",
  LA="Louisiana", ME="Maine", MD="Maryland", MA="Massachusetts", MI="Michigan", MN="Minnesota",
  MS="Mississippi", MO="Missouri", MT="Montana", NE="Nebraska", NV="Nevada", NH="New Hampshire",
  NJ="New Jersey", NM="New Mexico", NY="New York", NC="North Carolina", ND="North Dakota",
  OH="Ohio", OK="Oklahoma", OR="Oregon", PA="Pennsylvania", RI="Rhode Island", SC="South Carolina",
  SD="South Dakota", TN="Tennessee", TX="Texas", UT="Utah", VT="Vermont", VA="Virginia",
  WA="Washington", WV="West Virginia", WI="Wisconsin", WY="Wyoming")
if (all(nchar(stats::na.omit(unique(cty$State))) <= 3))
  cty$State <- unname(state_abb_to_name[cty$State])

# County -> State population weights (mean county population over the panel).
cty_ps <- cty %>% group_by(fips_code, State) %>%
  summarise(pop = mean(Population, na.rm = TRUE), .groups = "drop")
svi_static <- svi %>% distinct(fips_code, SVI_static)

svi_state <- cty_ps %>% inner_join(svi_static, by = "fips_code") %>%
  filter(!is.na(SVI_static), !is.na(pop)) %>%
  group_by(State) %>%
  summarise(SVI_state = weighted.mean(SVI_static, pop), .groups = "drop")
cat(sprintf("State SVI built for %d states (range %.2f-%.2f)\n",
            nrow(svi_state), min(svi_state$SVI_state), max(svi_state$SVI_state)))

s <- s %>% left_join(svi_state, by = "State")

shock_specs <- Filter(function(t) t %in% names(s), c(
  "is_extreme_drought", "is_extreme_drought_lag2", "is_cold_shock",
  "is_high_cdd", "is_high_hdd"))
outcomes <- intersect(c("Emp_Contrib_Single_Real","Medical_Debt_Share",
  "Medical_Debt_Median_Real","Total_Per_Capita_Health_Exp_Real",
  "Personal_Income_Per_Capita_Real"), names(s))
controls <- intersect(c("Unemployment_Rate","Personal_Income_Per_Capita_Real"), names(s))
adverse_sign <- c(Emp_Contrib_Single_Real = 1, Medical_Debt_Share = 1,
                  Medical_Debt_Median_Real = 1, Total_Per_Capita_Health_Exp_Real = 1,
                  Personal_Income_Per_Capita_Real = -1)

svi_q <- quantile(svi_state$SVI_state, c(0.25, 0.75), na.rm = TRUE)
get_cell <- function(ct, term, col) { v <- ct[ct$Term == term, col]; if (length(v) == 0) NA_real_ else as.numeric(v) }
rows <- list()

for (sh in shock_specs) {
  int <- paste0(sh, ":SVI_state")
  for (o in outcomes) {
    if (o == sh) next
    ctl <- setdiff(controls, c(sh, o))   # never control for the outcome itself
    rhs <- paste(c(sh, int, ctl), collapse = " + ")
    sub <- s %>% filter(!is.na(.data[[o]]), !is.na(SVI_state), !is.na(.data[[sh]]))
    if (nrow(sub) < 50) next
    m <- tryCatch(feols(as.formula(paste(o, "~", rhs, "| State + Year")),
                        data = sub, cluster = ~State), error = function(e) NULL)
    if (is.null(m)) next
    ct <- as.data.frame(coeftable(m)); ct$Term <- rownames(ct)
    b_int <- get_cell(ct, int, "Estimate"); p_int <- get_cell(ct, int, "Pr(>|t|)")
    me_lo <- lincom(m, setNames(c(1, svi_q[1]), c(sh, int)))
    me_hi <- lincom(m, setNames(c(1, svi_q[2]), c(sh, int)))
    adv <- adverse_sign[[o]] %||% NA_real_
    verdict <- if (is.na(p_int) || p_int >= 0.10 || is.na(b_int)) "ns"
               else if (!is.na(adv) && sign(b_int) == adv) "amplifies_harm_in_vulnerable"
               else "concentrated_in_less_vulnerable"
    rows[[length(rows)+1]] <- data.frame(
      level = "State", shock = sh, outcome = o, N = nobs(m),
      beta_shock = get_cell(ct, sh, "Estimate"),
      beta_interaction = b_int, p_interaction = p_int,
      me_lowSVI = if (!is.null(me_lo)) me_lo$estimate else NA_real_,
      me_highSVI = if (!is.null(me_hi)) me_hi$estimate else NA_real_,
      ej_verdict = verdict, stringsAsFactors = FALSE)
  }
}

res <- bind_rows(rows)
write_csv(res, "Analysis/exposure_interaction_state_coefs.csv")
cat(sprintf("\nSaved %d state interaction rows.\n", nrow(res)))
cat("\nVerdict counts:\n"); print(table(res$ej_verdict))
cat("\n=== Significant state Shock x SVI interactions (p<0.10) ===\n")
print(as.data.frame(res %>% filter(ej_verdict != "ns") %>%
  mutate(across(c(beta_interaction, p_interaction, me_lowSVI, me_highSVI), ~signif(.x,3))) %>%
  select(shock, outcome, beta_interaction, p_interaction, me_lowSVI, me_highSVI, ej_verdict)),
  row.names = FALSE)
