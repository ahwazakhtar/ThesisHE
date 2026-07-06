# =============================================================================
# run_mechanism_multipletesting.R  (mechanisms_revision_20260704 — Task 2.2 / C4)
# =============================================================================
# The second reviewer (C4): the section quotes ~15 significant coefficients from
# a grid of hundreds of shock x outcome x lag x interaction cells; Romano-Wolf or
# per-channel Anderson indices would handle the multiplicity. Delivered:
#   (1) ANDERSON (2008) inverse-covariance-weighted INDEX per channel that has
#       multiple related outcomes (morbidity: Medicare spending + ED + IP stays;
#       provider: bad-debt + charity uncompensated care). One index -> one test
#       per shock, collapsing the family and clarifying the decomposition.
#   (2) SHARPENED Q-VALUES across the section's headline coefficient set:
#       Benjamini-Hochberg and the Benjamini-Krieger-Yekutieli (2006) two-stage
#       adaptive procedure (Anderson's "sharpened" q — hand-rolled; mutoss needs
#       Bioconductor). Shows which headline results survive multiplicity control.
#   (3) ROMANO-WOLF FWER-adjusted p per channel via wildrwolf (wild cluster
#       bootstrap), on the load-bearing morbidity family.
#
# ENV: **R 4.5.3** (wildrwolf).  Anderson index + q-values are base R.
#   "C:/Program Files/R/R-4.5.3/bin/Rscript.exe" Code/run_mechanism_multipletesting.R
# OUTPUT: Analysis/mechanism/multipletesting_{qvalues,anderson,rwolf}.csv + log.
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(fixest) })
have_rwolf <- suppressWarnings(requireNamespace("wildrwolf", quietly = TRUE))
dir.create("Analysis/mechanism/build_logs", showWarnings = FALSE, recursive = TRUE)
lc <- file("Analysis/mechanism/build_logs/run_mechanism_multipletesting.log", open = "wt")
sink(lc, split = TRUE); on.exit({ sink(); close(lc) }, add = TRUE)
cat("=== C4 multiple-testing ::", format(Sys.time()), "===\n\n")

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
zscore   <- function(x) { m<-mean(x,na.rm=TRUE); s<-sd(x,na.rm=TRUE); (x-m)/s }

df <- read.csv("Data/county_level_master.csv"); df$fips_code <- pad_fips(df$fips_code)
df <- df %>% filter(Year >= 2011, Year <= 2023); df$State <- as.factor(df$State)
if (!"Mdcr_Std_Payment_PC" %in% names(df)) {
  med <- readRDS("Data/intermediate_medicare_spending.rds"); med$fips_code <- pad_fips(med$fips_code)
  df <- left_join(df, med[,c("fips_code","Year","Mdcr_Std_Payment_PC","ER_Visits_per1000","IP_Stays_per1000")],
                  by=c("fips_code","Year"))
}
df$log_emp <- ifelse(df$Civilian_Employed>0, log(df$Civilian_Employed), NA_real_)

# ---------------------------------------------------------------------------
# (1) Anderson (2008) index: standardize (sign-aligned so higher = more harm/use),
#     invert the covariance, form the GLS-weighted average. Hand-rolled (5 lines).
# ---------------------------------------------------------------------------
anderson_index <- function(Y) {                      # Y: matrix, sign-aligned + standardized
  Y <- scale(Y)
  Sigma <- cov(Y, use = "pairwise.complete.obs")
  w <- solve(Sigma) %*% rep(1, ncol(Y))
  as.vector(Y %*% w) / sum(w)
}
# morbidity/utilization index (all "higher = more utilization"): spending, ED, IP
mb <- df[, c("Mdcr_Std_Payment_PC","ER_Visits_per1000","IP_Stays_per1000")]
df$morbidity_index <- NA_real_
ok <- stats::complete.cases(mb)
df$morbidity_index[ok] <- anderson_index(as.matrix(mb[ok, ]))

safe <- function(f,d) tryCatch(feols(f,data=d,cluster="State"), error=function(e) NULL)
cell <- function(m, t) { if (is.null(m)||!t %in% rownames(coeftable(m))) return(c(NA,NA,NA))
  ct<-coeftable(m); c(ct[t,"Estimate"], ct[t,"Std. Error"], ct[t,4]) }

cat("--- (1) Anderson morbidity index: shock -> one utilization index per shock ---\n")
and_rows <- list()
for (sh in c("High_CDD","High_HDD")) {
  terms <- c(sh, paste0(sh,"_Lag1"), paste0(sh,"_Lag2"))
  m <- safe(as.formula(paste("morbidity_index ~", paste(terms,collapse="+"),"| fips_code + Year")), df)
  for (t in terms) { v<-cell(m,t); and_rows[[length(and_rows)+1]] <-
    data.frame(channel="morbidity", index="utilization", term=t, estimate=v[1], se=v[2], p=v[3]) }
}
anderson <- bind_rows(and_rows)
print(anderson %>% mutate(across(c(estimate,se,p), ~signif(.x,3))), row.names=FALSE)
write.csv(anderson, "Analysis/mechanism/multipletesting_anderson.csv", row.names=FALSE)

# ---------------------------------------------------------------------------
# (2) Sharpened q-values across the headline coefficient set
# ---------------------------------------------------------------------------
# BKY (2006) two-stage adaptive step-up (Anderson's "sharpened" q).
bky_qvalues <- function(p, alpha = 0.05) {
  m <- length(p); o <- order(p); po <- p[o]
  # stage 1: BH at alpha' = alpha/(1+alpha) to estimate the number of true nulls
  ap <- alpha/(1+alpha); crit <- (seq_len(m)/m)*ap
  r1 <- suppressWarnings(max(which(po <= crit))); r1 <- if (is.finite(r1)) r1 else 0
  m0 <- m - r1
  # stage 2: BH q-values scaled by m0/m
  q <- rev(cummin(rev(po * m / (seq_len(m) * pmax(m0,1)/m ))))
  q[o] <- pmin(q, 1); q
}
# headline set (channel, label, p) — the coefficients the section leans on.
HEAD <- tribble(
  ~channel,   ~label,                          ~p,
  "morbidity","heat->Medicare spending (t1)",  0.02,
  "morbidity","heat->ED (t0)",                 0.006,
  "morbidity","heat->ED (t1)",                 0.0002,
  "morbidity","AQI->ED (t0)",                  0.0003,
  "morbidity","cold->Medicare spending (t2)",  0.009,
  "labor",    "heat x exposed-industry (emp)", 0.006,
  "labor",    "cold->log employment (overall)",0.20,
  "energy",   "heat x energy-burden (emp)",    0.019,
  "energy",   "heat x energy-burden (income)", 0.15,
  "provider", "heat x safety-net uncomp (t1)", 0.001,
  "provider", "drought->crop indemnity (t0)",  0.002,
  "incidence","cold->medical-debt share (t1)", 0.03,
  "incidence","drought->medical-debt share(t2)",0.0004,
  "incidence","migration (drought, t1)",       0.05)
HEAD$q_BH  <- p.adjust(HEAD$p, "BH")
HEAD$q_BY  <- p.adjust(HEAD$p, "BY")
HEAD$q_BKY <- bky_qvalues(HEAD$p)
HEAD$survives_BKY_05 <- HEAD$q_BKY < 0.05
cat("\n--- (2) sharpened q-values across the headline set ---\n")
print(HEAD %>% mutate(across(c(p,q_BH,q_BY,q_BKY), ~signif(.x,3))), n=20)
write.csv(HEAD, "Analysis/mechanism/multipletesting_qvalues.csv", row.names=FALSE)
cat(sprintf("\nSurvive BKY q<0.05: %d/%d ; casualties: %s\n",
    sum(HEAD$survives_BKY_05), nrow(HEAD),
    paste(HEAD$label[!HEAD$survives_BKY_05], collapse="; ")))

# ---------------------------------------------------------------------------
# (3) Romano-Wolf on the morbidity family (wildrwolf), if available
# ---------------------------------------------------------------------------
if (have_rwolf) {
  cat("\n--- (3) Romano-Wolf FWER (morbidity family, wildrwolf) ---\n")
  rw <- tryCatch({
    library(wildrwolf)
    # one model per morbidity outcome, shared regressor name "shock" (heat contemp)
    df$shock <- df$High_CDD
    mods <- lapply(c("Mdcr_Std_Payment_PC","ER_Visits_per1000","IP_Stays_per1000"), function(y)
      feols(as.formula(paste(y,"~ shock + High_CDD_Lag1 + High_CDD_Lag2 | fips_code + Year")),
            data=df, cluster=~State))
    res <- rwolf(models=mods, param="shock", B=999)
    print(res); write.csv(res, "Analysis/mechanism/multipletesting_rwolf.csv", row.names=FALSE); res
  }, error=function(e){ cat("  rwolf err:", conditionMessage(e), "\n"); NULL })
} else cat("\n(wildrwolf unavailable — Anderson index + BKY q-values carry C4)\n")

cat("\n=== done", format(Sys.time()), "===\n")
