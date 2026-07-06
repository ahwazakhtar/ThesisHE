# ---------------------------------------------------------------------------
# run_county_humidity_sensitivity.R  (Cross-Level Symmetry — county humidity)
#
# County mirror of the state humidity-sensitivity block (run_analysis.R). Joins
# the county tdmean panel and, for each headline county outcome, compares the
# primary county Spec 2 climate coefficients WITH vs WITHOUT humidity controls
# (tdmean_F + lag1 + lag2) on the IDENTICAL humidity-available sample — isolating
# the effect of controlling for humidity from the sample change.
#
# Output: Analysis/county/county_humidity_sensitivity.csv
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(dplyr); library(readr); library(fixest) })

df  <- read_csv("Data/county_level_master.csv", show_col_types = FALSE, progress = FALSE)
hum <- readRDS("Data/intermediate_humidity_county.rds")
df$fips_code  <- formatC(as.integer(df$fips_code), width = 5, flag = "0")
hum$fips_code <- formatC(as.integer(hum$fips_code), width = 5, flag = "0")
if (all(c("Hosp_BadDebt_Total_Real","Population") %in% names(df)))
  df$Hosp_BadDebt_PerCapita <- df$Hosp_BadDebt_Total_Real / df$Population

df <- df %>% filter(Year >= 2011, Year <= 2023) %>%
  left_join(hum %>% select(fips_code, Year, tdmean_F), by = c("fips_code", "Year")) %>%
  arrange(fips_code, Year) %>%
  group_by(fips_code) %>%
  mutate(tdmean_F_lag1 = dplyr::lag(tdmean_F, 1),
         tdmean_F_lag2 = dplyr::lag(tdmean_F, 2)) %>% ungroup()

# Debt exclusion CO 2023
mask <- toupper(trimws(as.character(df$State))) == "CO" & as.integer(df$Year) == 2023
for (v in intersect(c("Medical_Debt_Share","Medical_Debt_Median_2023"), names(df)))
  df[[v]] <- ifelse(mask, NA_real_, as.numeric(df[[v]]))

spec2 <- intersect(c("pdsi_val","PDSI_Lag1","PDSI_Lag2",
  "High_CDD","High_CDD_Lag1","High_CDD_Lag2",
  "High_HDD","High_HDD_Lag1","High_HDD_Lag2"), names(df))
hum_terms <- c("tdmean_F","tdmean_F_lag1","tdmean_F_lag2")
controls  <- intersect(c("Household_Income_2023","Uninsured_Rate"), names(df))
outcomes  <- intersect(c("Medical_Debt_Share","PCPI_Real","Hosp_BadDebt_PerCapita",
  "Benchmark_Silver_Real","Civilian_Employed","Med_HH_Income_Real"), names(df))
# Headline climate terms to track + humidity's own terms.
track <- c("High_CDD","High_HDD","pdsi_val", hum_terms)
get_cell <- function(ct, term, col) { v <- ct[ct$Term == term, col]; if (length(v) == 0) NA_real_ else as.numeric(v) }

rhs_base <- paste(c(spec2, controls), collapse = " + ")
rhs_hum  <- paste(c(spec2, hum_terms, controls), collapse = " + ")
rows <- list()
for (o in outcomes) {
  sub <- df %>% filter(!is.na(.data[[o]]), stats::complete.cases(df[, hum_terms]))
  if (nrow(sub) < 100) next
  mb <- tryCatch(feols(as.formula(paste(o,"~",rhs_base,"| fips_code + Year")), data=sub, cluster=~State), error=function(e) NULL)
  mh <- tryCatch(feols(as.formula(paste(o,"~",rhs_hum, "| fips_code + Year")), data=sub, cluster=~State), error=function(e) NULL)
  if (is.null(mb) || is.null(mh)) next
  cb <- as.data.frame(coeftable(mb)); cb$Term <- rownames(cb)
  ch <- as.data.frame(coeftable(mh)); ch$Term <- rownames(ch)
  for (trm in track) rows[[length(rows)+1]] <- data.frame(
    outcome = o, term = trm, N = nobs(mh),
    est_noHumidity   = get_cell(cb, trm, "Estimate"), p_noHumidity   = get_cell(cb, trm, "Pr(>|t|)"),
    est_withHumidity = get_cell(ch, trm, "Estimate"), p_withHumidity = get_cell(ch, trm, "Pr(>|t|)"),
    stringsAsFactors = FALSE)
}
res <- bind_rows(rows)
write_csv(res, "Analysis/county/county_humidity_sensitivity.csv")
cat(sprintf("Saved %d rows (humidity-available N varies by outcome).\n", nrow(res)))

cat("\n=== County climate coefficients: with vs without humidity (High_CDD / High_HDD) ===\n")
print(as.data.frame(res %>% filter(term %in% c("High_CDD","High_HDD")) %>%
  mutate(across(c(est_noHumidity,est_withHumidity,p_withHumidity), ~signif(.x,3))) %>%
  select(outcome, term, est_noHumidity, est_withHumidity, p_withHumidity)), row.names = FALSE)
cat("\n=== Humidity's own effect (tdmean_F) ===\n")
print(as.data.frame(res %>% filter(term == "tdmean_F") %>%
  mutate(across(c(est_withHumidity,p_withHumidity), ~signif(.x,3))) %>%
  select(outcome, est_withHumidity, p_withHumidity)), row.names = FALSE)
