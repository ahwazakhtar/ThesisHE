# =============================================================================
# run_mechanism_conley.R  (mechanisms_revision_20260704 — Task 3.2 / B2)
# =============================================================================
# The second reviewer (B2): report Conley spatial-HAC standard errors alongside
# state clustering (weather is spatially correlated), and push the heat results
# through harder time fixed effects (the frozen-baseline heat-trend threat). For
# the HEAT headlines — heat -> Medicare spending (morbidity), and the heat x
# exposed-industry / heat x energy-burden interactions on log employment — report:
#   - state-clustered SE (baseline);
#   - Conley SE at 200 km (primary) + 100/300 km robustness (spatial HAC);
#   - a State x Year FE re-estimate (harsher than the division x year FE already
#     shown in 1.1; note premiums would die mechanically here — not run).
#
# County centroids from the Census cartographic boundary file (Data/Geo, via
# terra). Conley via fixest::vcov_conley (triangular kernel).
#
# ENV: main R 4.2.2.  Rscript Code/run_mechanism_conley.R
# OUTPUT: Analysis/mechanism/conley_robustness.csv + log.
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(fixest); library(terra) })
dir.create("Analysis/mechanism/build_logs", showWarnings = FALSE, recursive = TRUE)
lc <- file("Analysis/mechanism/build_logs/run_mechanism_conley.log", open = "wt")
sink(lc, split = TRUE); on.exit({ sink(); close(lc) }, add = TRUE)
cat("=== B2 Conley SEs + State x Year FE (heat headlines) ::", format(Sys.time()), "===\n\n")

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")
zscore   <- function(x) { m<-mean(x,na.rm=TRUE); s<-sd(x,na.rm=TRUE); (x-m)/s }

# ---- county centroids (lat/lon) from the cartographic boundary file -------
shp <- terra::vect("Data/Geo/cb_2018_us_county_20m")
ctr <- terra::crds(terra::centroids(shp))
cen <- data.frame(fips_code = pad_fips(shp$GEOID), lon = ctr[,1], lat = ctr[,2])
cat("centroids:", nrow(cen), "counties\n")

df <- read.csv("Data/county_level_master.csv"); df$fips_code <- pad_fips(df$fips_code)
df <- df %>% filter(Year >= 2011, Year <= 2023); df$State <- as.factor(df$State)
if (!"Mdcr_Std_Payment_PC" %in% names(df)) {
  med <- readRDS("Data/intermediate_medicare_spending.rds"); med$fips_code <- pad_fips(med$fips_code)
  df <- left_join(df, med[,c("fips_code","Year","Mdcr_Std_Payment_PC")], by=c("fips_code","Year"))
}
ind <- readRDS("Data/intermediate_industry_composition.rds") %>% mutate(fips_code=pad_fips(fips_code)) %>%
  distinct(fips_code, ClimateExposed_NonFarm_Share_baseline)
en  <- readRDS("Data/intermediate_energy_burden.rds") %>% mutate(fips_code=pad_fips(fips_code)) %>%
  distinct(fips_code, Energy_Burden_Pct)
df <- df %>% left_join(ind,by="fips_code") %>% left_join(en,by="fips_code") %>% left_join(cen,by="fips_code")
df$Labor_z <- zscore(df$ClimateExposed_NonFarm_Share_baseline)
df$EnergyBurden_z <- zscore(df$Energy_Burden_Pct)
df$log_emp <- ifelse(df$Civilian_Employed>0, log(df$Civilian_Employed), NA_real_)

cdd <- c("High_CDD","High_CDD_Lag1","High_CDD_Lag2")
# heat headlines: (outcome formula-rhs, key term to report, label)
specs <- list(
  list(rhs = paste(cdd, collapse="+"), oc="Mdcr_Std_Payment_PC", key="High_CDD_Lag1", lab="heat_medicare_lag1"),
  list(rhs = paste(c(cdd, paste0(cdd,":Labor_z")), collapse="+"), oc="log_emp", key="High_CDD:Labor_z", lab="heat_x_labor_emp"),
  list(rhs = paste(c(cdd, paste0(cdd,":EnergyBurden_z")), collapse="+"), oc="log_emp", key="High_CDD:EnergyBurden_z", lab="heat_x_energy_emp"))

getse <- function(m, key, vc) { s <- summary(m, vcov = vc); ct <- coeftable(s)
  if (key %in% rownames(ct)) c(est=ct[key,1], se=ct[key,2], p=ct[key,4]) else c(NA,NA,NA) }

rows <- list()
for (sp in specs) {
  d <- df[!is.na(df[[sp$oc]]) & !is.na(df$lat), ]
  m  <- feols(as.formula(paste(sp$oc,"~",sp$rhs,"| fips_code + Year")), data=d, cluster=~State)
  # harsher time FE: State x Year
  mSY <- tryCatch(feols(as.formula(paste(sp$oc,"~",sp$rhs,"| fips_code + State^Year")), data=d, cluster=~State),
                  error=function(e) NULL)
  base <- getse(m, sp$key, ~State)
  c200 <- getse(m, sp$key, vcov_conley(m, lat="lat", lon="lon", cutoff=200))
  c100 <- getse(m, sp$key, vcov_conley(m, lat="lat", lon="lon", cutoff=100))
  c300 <- getse(m, sp$key, vcov_conley(m, lat="lat", lon="lon", cutoff=300))
  sy   <- if (!is.null(mSY)) getse(mSY, sp$key, ~State) else c(NA,NA,NA)
  rows[[length(rows)+1]] <- data.frame(headline=sp$lab, key=sp$key, estimate=unname(base["est"]),
    se_state=unname(base["se"]), p_state=unname(base["p"]),
    se_conley200=unname(c200["se"]), p_conley200=unname(c200["p"]),
    se_conley100=unname(c100["se"]), se_conley300=unname(c300["se"]),
    est_stateXyear=unname(sy["est"]), se_stateXyear=unname(sy["se"]), p_stateXyear=unname(sy["p"]))
}
out <- bind_rows(rows)
write.csv(out, "Analysis/mechanism/conley_robustness.csv", row.names=FALSE)
cat("\n--- heat headlines: state-clustered vs Conley spatial-HAC vs State x Year FE ---\n")
print(out %>% mutate(across(where(is.numeric), ~signif(.x,3))), row.names=FALSE, width=200)
cat("\n=== done", format(Sys.time()), "===\n")
