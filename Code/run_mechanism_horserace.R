# =============================================================================
# run_mechanism_horserace.R  (mechanisms_revision_20260704 — Task 2.1 / A3)
# =============================================================================
# The second reviewer (A3): agricultural dependence, energy burden, and
# exposed-industry share all correlate with rurality, poverty, and baseline
# climate, so a Shock x EnergyBurden interaction "may just be Shock x hot-place"
# (curvature in the damage function). Test: enter ALL moderator interactions
# JOINTLY and see which survive — read sign/significance survival, not magnitudes
# (six correlated interactions under state clustering are underpowered).
#
# FOCUS: the HEAT (High_CDD) x moderator interactions on LOG employment and
# per-capita income (the energy-burden claim from §6.5 was CDD x EnergyBurden).
# Moderators (all time-invariant, standardized): EnergyBurden_z, Ag_z, Labor_z,
# SVI_z (poverty/vulnerability), and baseline_CDD_z (the county's normal heat =
# the hot-place curvature confounder the reviewer names). SVI theme-1 is
# socioeconomic status, so SVI_z carries the "poverty" control; Ag_z carries
# "rurality"; baseline_CDD_z carries "baseline climate."
#
# ENV: main R 4.2.2.  Rscript Code/run_mechanism_horserace.R
# OUTPUT: Analysis/mechanism/horserace_coefs.csv, horserace_modcorr.csv + log.
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(fixest) })
dir.create("Analysis/mechanism/build_logs", showWarnings = FALSE, recursive = TRUE)
lc <- file("Analysis/mechanism/build_logs/run_mechanism_horserace.log", open = "wt")
sink(lc, split = TRUE); on.exit({ sink(); close(lc) }, add = TRUE)
cat("=== A3 interaction horse-race ::", format(Sys.time()), "===\n\n")

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
zscore   <- function(x) { m <- mean(x, na.rm=TRUE); s <- sd(x, na.rm=TRUE); (x-m)/s }

df <- read.csv("Data/county_level_master.csv")
df$fips_code <- pad_fips(df$fips_code)
df <- df %>% filter(Year >= 2011, Year <= 2023)
df$State <- as.factor(df$State)

ag  <- readRDS("Data/intermediate_ag_dependence.rds") %>% mutate(fips_code=pad_fips(fips_code)) %>%
  distinct(fips_code, Farm_Earnings_Share)
ind <- readRDS("Data/intermediate_industry_composition.rds") %>% mutate(fips_code=pad_fips(fips_code)) %>%
  distinct(fips_code, ClimateExposed_NonFarm_Share_baseline)
en  <- readRDS("Data/intermediate_energy_burden.rds") %>% mutate(fips_code=pad_fips(fips_code)) %>%
  distinct(fips_code, Energy_Burden_Pct)
svi <- readRDS("Data/intermediate_svi.rds") %>% mutate(fips_code=pad_fips(fips_code)) %>%
  distinct(fips_code, SVI_static)
df <- df %>% left_join(ag,by="fips_code") %>% left_join(ind,by="fips_code") %>%
  left_join(en,by="fips_code") %>% left_join(svi,by="fips_code")

# baseline "how hot is this place": county mean cooling-degree-days (time-invariant curvature control)
base_cdd <- df %>% group_by(fips_code) %>% summarise(baseline_CDD = mean(cdd_val, na.rm=TRUE), .groups="drop")
df <- left_join(df, base_cdd, by="fips_code")

df$EnergyBurden_z <- zscore(df$Energy_Burden_Pct)
df$Ag_z          <- zscore(df$Farm_Earnings_Share)
df$Labor_z       <- zscore(df$ClimateExposed_NonFarm_Share_baseline)
df$SVI_z         <- zscore(df$SVI_static)
df$baseline_CDD_z <- zscore(df$baseline_CDD)
df$log_emp       <- ifelse(df$Civilian_Employed > 0, log(df$Civilian_Employed), NA_real_)

mods <- c("EnergyBurden_z","Ag_z","Labor_z","SVI_z","baseline_CDD_z")
ctl  <- intersect(c("Household_Income_2023","Uninsured_Rate"), names(df))
cdd_terms <- c("High_CDD","High_CDD_Lag1","High_CDD_Lag2")

# moderator correlation matrix (county-level, one row per county) -----------
cty <- df %>% distinct(fips_code, .keep_all=TRUE) %>% select(all_of(mods))
cormat <- round(cor(cty, use="pairwise.complete.obs"), 3)
cat("Moderator correlation matrix (county-level):\n"); print(cormat)
write.csv(as.data.frame(cormat), "Analysis/mechanism/horserace_modcorr.csv")

tidy <- function(m, outcome, spec) {
  if (is.null(m)) return(NULL)
  ct <- as.data.frame(coeftable(m)); ct$term <- rownames(ct); rownames(ct)<-NULL
  names(ct)[1:4] <- c("estimate","se","t","p")
  ct <- ct[grepl(":.*_z$|:baseline_CDD_z$", ct$term), c("term","estimate","se","p")]
  if (nrow(ct)==0) return(NULL)
  data.frame(outcome, spec, ct, n=m$nobs, row.names=NULL)
}
safe <- function(f,d) tryCatch(feols(f,data=d,cluster="State"), error=function(e){cat(" err:",conditionMessage(e),"\n");NULL})

res <- list()
for (oc in c("log_emp","PCPI_Real")) {
  # (a) FULL joint horse-race: contemporaneous heat x all 5 moderators
  inter_all <- paste0("High_CDD:", mods)
  f_full <- as.formula(paste(oc,"~",paste(c(cdd_terms, inter_all, ctl),collapse="+"),"| fips_code + Year"))
  res[[length(res)+1]] <- tidy(safe(f_full, df), oc, "full_joint")
  # (b) MINIMAL: energy burden controlling for the two named confounders (SVI + baseline climate)
  inter_min <- paste0("High_CDD:", c("EnergyBurden_z","SVI_z","baseline_CDD_z"))
  f_min <- as.formula(paste(oc,"~",paste(c(cdd_terms, inter_min, ctl),collapse="+"),"| fips_code + Year"))
  res[[length(res)+1]] <- tidy(safe(f_min, df), oc, "minimal_EB_vs_SVI_climate")
  # (c) BASELINE (energy burden alone, for reference)
  f_base <- as.formula(paste(oc,"~",paste(c(cdd_terms, "High_CDD:EnergyBurden_z", ctl),collapse="+"),"| fips_code + Year"))
  res[[length(res)+1]] <- tidy(safe(f_base, df), oc, "eb_alone")
}
coefs <- bind_rows(res)
write.csv(coefs, "Analysis/mechanism/horserace_coefs.csv", row.names=FALSE)

cat("\n--- HORSE-RACE: High_CDD x moderator interactions (survival test) ---\n")
print(coefs %>% mutate(across(c(estimate,se,p), ~signif(.x,3))) %>%
        arrange(outcome, spec, term), row.names=FALSE)
cat("\nEnergyBurden interaction across specs (does it survive the joint race?):\n")
print(coefs %>% filter(grepl("EnergyBurden", term)) %>%
        mutate(across(c(estimate,se,p), ~signif(.x,3))) %>%
        select(outcome, spec, estimate, se, p), row.names=FALSE)
cat("\n=== done", format(Sys.time()), "===\n")
