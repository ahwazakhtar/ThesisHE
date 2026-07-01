# Diagnostic: print the schema of intermediate_svi.rds so run_mechanism_secondary.R
# can pick the right SVI column for the energy-burden cross-check. Logged to build_logs/.
log_con <- file("Analysis/mechanism/build_logs/inspect_svi.log", open = "wt")
sink(log_con, split = TRUE); on.exit({ sink(); close(log_con) }, add = TRUE)
d <- readRDS("Data/intermediate_svi.rds")
cat("class:", class(d)[1], "| dim:", paste(dim(d), collapse = " x "), "\n")
cat("columns:\n"); print(names(d))
cat("head:\n"); print(utils::head(d, 3))
