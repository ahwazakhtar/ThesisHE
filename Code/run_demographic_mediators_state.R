# ---------------------------------------------------------------------------
# run_demographic_mediators_state.R  (Cross-Level Symmetry — mediators at state level)
#
# State mirror of run_demographic_mediators.R. County ACS demographics are
# population-weighted to the state level, then we run (1) a first stage
# (state shocks -> state demographics) and (2) a mediator decomposition of the
# state headline outcomes with vs without the demographic controls.
#
# Outputs:
#   Analysis/demographic_mediators/demographic_response_state_coefs.csv
#   Analysis/demographic_mediators/demographic_mediator_state_decomposition.csv
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(dplyr); library(readr); library(fixest) })

s    <- read_csv("Data/analysis_ready_dataset.csv", show_col_types = FALSE, progress = FALSE)
demo <- readRDS("Data/intermediate_demographics.rds")
cty  <- read_csv("Data/county_level_master.csv", show_col_types = FALSE, progress = FALSE)
cty$fips_code  <- formatC(as.integer(cty$fips_code), width = 5, flag = "0")
demo$fips_code <- formatC(as.integer(demo$fips_code), width = 5, flag = "0")

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

# County population weights by (fips, Year), with full state names.
cty_pw <- cty %>%
  mutate(State_full = if (all(nchar(stats::na.omit(unique(cty$State))) <= 3))
                        unname(state_abb_to_name[State]) else State) %>%
  select(fips_code, Year, State_full, Population)

mediators <- c("In_Migration_Rate", "Pct_Age_65plus", "Pct_Owner_Occupied")

# Population-weighted state-year demographics.
demo_state <- demo %>%
  inner_join(cty_pw, by = c("fips_code", "Year")) %>%
  filter(!is.na(Population)) %>%
  group_by(State = State_full, Year) %>%
  summarise(across(all_of(mediators),
                   ~ weighted.mean(.x, Population, na.rm = TRUE)), .groups = "drop")

s <- s %>% left_join(demo_state, by = c("State", "Year"))

shocks   <- intersect(c("is_extreme_drought","is_cold_shock","is_high_cdd","is_high_hdd"), names(s))
outcomes <- intersect(c("Medical_Debt_Share","Personal_Income_Per_Capita_Real",
  "Total_Per_Capita_Health_Exp_Real","Emp_Contrib_Single_Real"), names(s))
get_cell <- function(ct, term, col) { v <- ct[ct$Term == term, col]; if (length(v) == 0) NA_real_ else as.numeric(v) }

# ---- 1. First stage: shocks -> demographics -------------------------------
cat("=== State first stage: shocks -> demographics ===\n")
fs <- list()
for (d in mediators) {
  m <- tryCatch(feols(as.formula(paste(d, "~", paste(shocks, collapse=" + "), "| State + Year")),
                      data = s, cluster = ~State), error = function(e) NULL)
  if (is.null(m)) next
  ct <- as.data.frame(coeftable(m)); ct$Term <- rownames(ct)
  for (sh in shocks) fs[[length(fs)+1]] <- data.frame(
    mediator = d, shock = sh, estimate = get_cell(ct, sh, "Estimate"),
    p.value = get_cell(ct, sh, "Pr(>|t|)"), N = nobs(m), stringsAsFactors = FALSE)
}
fs_df <- bind_rows(fs); write_csv(fs_df, "Analysis/demographic_mediators/demographic_response_state_coefs.csv")
cat("  significant (p<0.05):", sum(fs_df$p.value < 0.05, na.rm=TRUE), "of", nrow(fs_df), "\n")

# ---- 2. Mediator decomposition --------------------------------------------
cat("\n=== State mediator decomposition (base vs +demographics, constant sample) ===\n")
dec <- list()
rhs_base <- paste(shocks, collapse = " + ")
rhs_med  <- paste(c(shocks, mediators), collapse = " + ")
for (o in outcomes) {
  sub <- s %>% filter(!is.na(.data[[o]]), stats::complete.cases(s[, mediators]))
  if (nrow(sub) < 50) next
  mb <- tryCatch(feols(as.formula(paste(o,"~",rhs_base,"| State + Year")), data=sub, cluster=~State), error=function(e) NULL)
  mm <- tryCatch(feols(as.formula(paste(o,"~",rhs_med, "| State + Year")), data=sub, cluster=~State), error=function(e) NULL)
  if (is.null(mb) || is.null(mm)) next
  cb <- as.data.frame(coeftable(mb)); cb$Term <- rownames(cb)
  cm <- as.data.frame(coeftable(mm)); cm$Term <- rownames(cm)
  for (sh in shocks) {
    b0 <- get_cell(cb, sh, "Estimate"); b1 <- get_cell(cm, sh, "Estimate")
    dec[[length(dec)+1]] <- data.frame(outcome=o, shock=sh, N=nobs(mb),
      est_base=b0, p_base=get_cell(cb, sh, "Pr(>|t|)"),
      est_with_demog=b1, p_with_demog=get_cell(cm, sh, "Pr(>|t|)"),
      fraction_surviving = ifelse(!is.na(b0) & b0 != 0, b1/b0, NA_real_),
      stringsAsFactors = FALSE)
  }
}
dec_df <- bind_rows(dec); write_csv(dec_df, "Analysis/demographic_mediators/demographic_mediator_state_decomposition.csv")
print(as.data.frame(dec_df %>% mutate(across(c(est_base,est_with_demog,fraction_surviving), ~signif(.x,3))) %>%
  select(outcome, shock, est_base, est_with_demog, fraction_surviving)), row.names = FALSE)
cat("\n=== State Demographic Mediator Analysis Complete ===\n")
