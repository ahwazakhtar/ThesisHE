# =============================================================================
# run_mechanism_rma_buffer.R  (mechanisms_revision_20260704 — Task 2.3 / C2)
# =============================================================================
# The second reviewer (C2): the provider-finance null (drought -> lower/flat
# uncompensated care) currently rests on five untested stories. The federal-buffer
# story is directly testable — RMA county crop-insurance indemnities are public.
# Two steps:
#   (1) FIRST STAGE (mechanical): drought raises county crop indemnities — the
#       buffer activates on the same shock. If indemnities spike where hospital
#       uncompensated care does not, the buffer story tightens.
#   (2) BUFFER TEST: interact drought with a county's STRUCTURAL crop-insurance
#       intensity on uncompensated care. If federal buffers sever the farm-income
#       -> uninsurance -> uncompensated-care chain, drought's effect on
#       uncompensated care should be more muted/negative where insurance intensity
#       is HIGH (well-buffered ag counties).
#
# County uncompensated care = hospital bad debt + charity care (NASHP, aggregated
# to county in the master), as a share of net patient revenue and per capita;
# winsorized (one negative charity outlier, ~23% missing — CLAUDE.md).
# Indemnity intensity = county mean total-indemnity-per-capita over the panel
# (structural, time-invariant), standardized. NA indemnity (non-loss cty-yrs) = 0.
#
# ENV: main R 4.2.2.  Rscript Code/run_mechanism_rma_buffer.R
# OUTPUT: Analysis/mechanism/rma_buffer_coefs.csv + log.
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(fixest) })
dir.create("Analysis/mechanism/build_logs", showWarnings = FALSE, recursive = TRUE)
lc <- file("Analysis/mechanism/build_logs/run_mechanism_rma_buffer.log", open = "wt")
sink(lc, split = TRUE); on.exit({ sink(); close(lc) }, add = TRUE)
cat("=== C2 RMA crop-insurance buffer test ::", format(Sys.time()), "===\n\n")

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
zscore   <- function(x) { m <- mean(x, na.rm=TRUE); s <- sd(x, na.rm=TRUE); (x-m)/s }
winz     <- function(x, p = 0.01) { q <- quantile(x, c(p, 1-p), na.rm=TRUE); pmin(pmax(x, q[1]), q[2]) }

df <- read.csv("Data/county_level_master.csv")
df$fips_code <- pad_fips(df$fips_code)
df <- df %>% filter(Year >= 2011, Year <= 2023)
df$State <- as.factor(df$State)

rma <- readRDS("Data/intermediate_rma_indemnity.rds") %>% mutate(fips_code = pad_fips(fips_code))
df <- df %>% left_join(rma, by = c("fips_code","Year"))
# non-loss county-years legitimately have no RMA row -> 0 indemnity
for (v in c("Total_Indemnity","Drought_Indemnity")) df[[v]][is.na(df[[v]])] <- 0

# --- county uncompensated care (bad debt + charity), winsorized ------------
ch <- ifelse(is.na(df$Hosp_Charity_Total_Real), 0, df$Hosp_Charity_Total_Real)
bd <- ifelse(is.na(df$Hosp_BadDebt_Total_Real), 0, df$Hosp_BadDebt_Total_Real)
df$Uncomp_Real <- winz(bd + ch)
df$Uncomp_PctRev <- ifelse(!is.na(df$Hosp_Revenue_Total) & df$Hosp_Revenue_Total > 0,
                           df$Uncomp_Real / df$Hosp_Revenue_Total, NA_real_)
df$Uncomp_PctRev <- winz(df$Uncomp_PctRev)
df$Indem_PerCap  <- df$Total_Indemnity / df$Population

# structural (time-invariant) crop-insurance intensity: county mean indemnity/capita
intensity <- df %>% group_by(fips_code) %>%
  summarise(Indem_Intensity = mean(Indem_PerCap, na.rm=TRUE), .groups="drop")
df <- left_join(df, intensity, by="fips_code")
df$Indem_Intensity_z <- zscore(df$Indem_Intensity)

drought <- c("Is_Extreme_Drought","Is_Extreme_Drought_Lag1","Is_Extreme_Drought_Lag2")
safe <- function(f,d) tryCatch(feols(f,data=d,cluster="State"), error=function(e){cat(" err:",conditionMessage(e),"\n");NULL})
tidy <- function(m, label, keep) {
  if (is.null(m)) return(NULL)
  ct <- as.data.frame(coeftable(m)); ct$term <- rownames(ct); rownames(ct)<-NULL
  names(ct)[1:4] <- c("estimate","se","t","p")
  ct <- ct[ct$term %in% keep, c("term","estimate","se","p")]
  data.frame(label, ct, n=m$nobs, row.names=NULL)
}

res <- list()
# (1) FIRST STAGE: drought -> indemnities (log(1+indem) and per-capita)
df$log_indem <- log1p(df$Total_Indemnity)
res[[1]] <- tidy(safe(as.formula(paste("log_indem ~", paste(drought,collapse="+"),"| fips_code + Year")), df),
                 "firststage_log_indemnity", drought)
res[[2]] <- tidy(safe(as.formula(paste("Indem_PerCap ~", paste(drought,collapse="+"),"| fips_code + Year")), df),
                 "firststage_indem_percap", drought)

# (2) BUFFER TEST: drought x indemnity-intensity on uncompensated care
inter <- paste0(drought, ":Indem_Intensity_z")
for (oc in c("Uncomp_PctRev","Uncomp_Real")) {
  f <- as.formula(paste(oc, "~", paste(c(drought, inter),collapse="+"), "| fips_code + Year"))
  res[[length(res)+1]] <- tidy(safe(f, df), paste0("buffer_", oc), c(drought, inter))
}
coefs <- bind_rows(res)
write.csv(coefs, "Analysis/mechanism/rma_buffer_coefs.csv", row.names=FALSE)

cat("--- (1) FIRST STAGE: does drought raise county crop indemnities? ---\n")
print(coefs %>% filter(grepl("firststage", label)) %>%
        mutate(across(c(estimate,se,p), ~signif(.x,3))), row.names=FALSE)
cat("\n--- (2) BUFFER TEST: drought x indemnity-intensity on uncompensated care ---\n")
print(coefs %>% filter(grepl("buffer", label)) %>%
        mutate(across(c(estimate,se,p), ~signif(.x,3))), row.names=FALSE)
cat(sprintf("\nCoverage: Uncomp_PctRev non-missing %d ; mean drought indemnity share of county-yrs w/ loss: reported in intermediate.\n",
            sum(!is.na(df$Uncomp_PctRev))))
cat("\n=== done", format(Sys.time()), "===\n")
