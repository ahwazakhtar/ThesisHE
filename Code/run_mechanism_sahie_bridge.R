# =============================================================================
# run_mechanism_sahie_bridge.R  (mechanisms_revision_20260704 — Task 3.3 / C1)
# =============================================================================
# The second reviewer (C1): the morbidity channel is measured in Medicare (65+,
# insured), but medical debt lives with the WORKING-AGE un/underinsured. Bridge:
# does the shock -> medical-debt effect LOAD where the working-age (18-64)
# uninsured population is largest? If a climate shock raises debt specifically in
# high-uninsured counties, the channel demonstrably reaches the debt-relevant
# population — the missing link between the (sentinel) Medicare morbidity result
# and the household debt outcome.
#
# MODERATOR: county 18-64 uninsured rate (Census SAHIE, full 2011-2023), and a
# <=138% FPL low-income-uninsured cut. Structural: standardized county mean over
# the panel (time-invariant), so it is a pre-existing county attribute, not a
# contemporaneous mediator. Interact shocks with it on Medical_Debt_Share.
#
# ENV: main R 4.2.2.  Rscript Code/run_mechanism_sahie_bridge.R
# OUTPUT: Analysis/mechanism/sahie_bridge_coefs.csv + log.
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(fixest) })
dir.create("Analysis/mechanism/build_logs", showWarnings = FALSE, recursive = TRUE)
lc <- file("Analysis/mechanism/build_logs/run_mechanism_sahie_bridge.log", open = "wt")
sink(lc, split = TRUE); on.exit({ sink(); close(lc) }, add = TRUE)
cat("=== C1 SAHIE working-age-uninsured bridge ::", format(Sys.time()), "===\n\n")

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
zscore   <- function(x) { m<-mean(x,na.rm=TRUE); s<-sd(x,na.rm=TRUE); (x-m)/s }

df <- read.csv("Data/county_level_master.csv"); df$fips_code <- pad_fips(df$fips_code)
# CO-2023 medical-debt reporting-rule exclusion (CLAUDE.md)
df$Medical_Debt_Share[toupper(trimws(df$State))=="CO" & df$Year==2023] <- NA
df <- df %>% filter(Year >= 2011, Year <= 2023); df$State <- as.factor(df$State)

sahie <- readRDS("Data/intermediate_sahie.rds") %>% mutate(fips_code = pad_fips(fips_code))
# structural (time-invariant) county uninsured level = panel mean
unins <- sahie %>% group_by(fips_code) %>%
  summarise(Uninsured_18_64 = mean(Uninsured_18_64, na.rm=TRUE),
            Uninsured_le138 = mean(Uninsured_18_64_le138FPL, na.rm=TRUE), .groups="drop")
df <- left_join(df, unins, by="fips_code")
df$Uninsured_z  <- zscore(df$Uninsured_18_64)
df$Uninsured_lo_z <- zscore(df$Uninsured_le138)
cat("Uninsured_z non-missing:", sum(!is.na(df$Uninsured_z)),
    "| mean 18-64 uninsured:", round(mean(df$Uninsured_18_64, na.rm=TRUE),1), "%\n\n")

shocks <- list(HDD=c("High_HDD","High_HDD_Lag1","High_HDD_Lag2"),
               Drought=c("Is_Extreme_Drought","Is_Extreme_Drought_Lag1","Is_Extreme_Drought_Lag2"),
               CDD=c("High_CDD","High_CDD_Lag1","High_CDD_Lag2"))
safe <- function(f,d) tryCatch(feols(f,data=d,cluster="State"), error=function(e){cat(" err:",conditionMessage(e),"\n");NULL})
tidy <- function(m, sh, mod, keep) {
  if (is.null(m)) return(NULL)
  ct <- as.data.frame(coeftable(m)); ct$term <- rownames(ct); rownames(ct)<-NULL
  names(ct)[1:4] <- c("estimate","se","t","p")
  ct <- ct[ct$term %in% keep, c("term","estimate","se","p")]
  if (nrow(ct)==0) return(NULL)
  data.frame(shock=sh, moderator=mod, ct, n=m$nobs, row.names=NULL)
}

res <- list()
for (sh in names(shocks)) {
  terms <- shocks[[sh]]
  for (mz in c("Uninsured_z","Uninsured_lo_z")) {
    inter <- paste0(terms, ":", mz)
    f <- as.formula(paste("Medical_Debt_Share ~", paste(c(terms, inter),collapse="+"), "| fips_code + Year"))
    res[[length(res)+1]] <- tidy(safe(f, df), sh, mz, inter)
  }
}
coefs <- bind_rows(res)
write.csv(coefs, "Analysis/mechanism/sahie_bridge_coefs.csv", row.names=FALSE)

cat("--- shock x working-age-uninsured share on MEDICAL DEBT (does the effect load there?) ---\n")
print(coefs %>% filter(moderator=="Uninsured_z") %>%
        mutate(across(c(estimate,se,p), ~signif(.x,3))) %>% arrange(shock, term), row.names=FALSE)
cat("\n--- same, low-income (<=138%FPL) uninsured cut ---\n")
print(coefs %>% filter(moderator=="Uninsured_lo_z") %>%
        mutate(across(c(estimate,se,p), ~signif(.x,3))) %>% arrange(shock, term), row.names=FALSE)
cat("\n=== done", format(Sys.time()), "===\n")
