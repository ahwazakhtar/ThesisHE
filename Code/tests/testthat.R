# =============================================================================
# testthat.R — TRUTHFUL aggregate test runner for repository script tests
# =============================================================================
# PURPOSE
#   Run every `Code/tests/test_*.R` file and report an HONEST pass/fail verdict.
#   This replaces a false-green predecessor (audit item A1) that looped
#   `testthat::test_file()` inside a SINGLE R process: after the first
#   `test_file()` the working directory drifted, so later files could no longer
#   `source()` repo-relative paths (e.g. `Code/cumulative_dose.R`). Those source
#   errors were swallowed and the process still `quit(status = 0)` — 36 error
#   lines, exit code 0. Verified false-green on 2026-07-13.
#
# HOW THIS RUNNER IS TRUTHFUL
#   Each test file is executed in its OWN clean `Rscript` child process launched
#   from the repository root. Two facts make the per-file EXIT CODE a trustworthy
#   signal (both verified empirically on R 4.2.2 / testthat 4.2.3):
#     * A failed `test_that()` expectation in a standalone `Rscript file.R` run
#       aborts via testthat's stop-reporter -> child exits 1 (NOT just a printed
#       "Failure" that leaks past). So real FAILURES are caught, not only errors.
#     * A top-level `source()` / runtime error -> child exits 1.
#   Because every file gets a fresh process with cwd == repo root, there is no
#   working-directory drift between files: the bug that made the old runner lie
#   is structurally impossible here.
#
# INPUTS
#   * `Code/tests/test_*.R`            — the test suite (each self-contained).
#   * env `TESTTHAT_SELFTEST` in {1,TRUE,true,yes} — also sweep the deliberate-
#       failure fixtures under `Code/tests/selftest_fixtures/` (used ONLY by the
#       runner's own regression test; see below).
#   * CLI `--files=<glob[,glob...]>`   — run exactly these paths/globs (relative
#       to repo root) instead of the full sweep. Lets the self-test run just a
#       couple of quick tests + the fixture instead of the whole suite.
#
# OUTPUTS
#   * console per-file PASS/FAIL table + error tails for any FAIL.
#   * `Analysis/test_reports/test_report.csv`  (full default sweep)
#       columns: file, exit_code, status, seconds, timestamp, r_version.
#   * `Analysis/test_reports/test_report.md`   companion build-log-style stamp
#       (run metadata, totals, per-file table, failure tails).
#     Non-default runs (--files or selftest) write the `_partial` variants so a
#     subset run never clobbers the authoritative full-sweep report.
#
# EXCLUSIONS FROM THE DEFAULT SWEEP (documented, deliberate)
#   * `test_runner_selftest.R` — that file *invokes this runner*; sweeping it
#     inside the runner would recurse. It is always dropped from the file set.
#   * `selftest_fixtures/` — contains a test that ALWAYS fails on purpose. It is
#     included ONLY when `TESTTHAT_SELFTEST=1`, so a normal run stays green when
#     the real suite is healthy.
#
# EXIT STATUS
#   quit(status = 1) if ANY file fails/errors; quit(status = 0) only if all pass.
#
# R VERSION
#   Version-AGNOSTIC. It never hard-codes an R path: the child Rscript is derived
#   from the interpreter running this script via `file.path(R.home("bin"),
#   "Rscript")` (+ ".exe" on Windows). So `Rscript.exe testthat.R` reports the
#   truth on BOTH the 4.2.2 main pipeline and the 4.5.3 frontier install; each
#   test runs under whatever R launched the runner.
#
# KNOWN CONTEXT (report, do not patch)
#   Some tests are R-4.2.2-only; the suite is normally run on 4.2.2. If a file
#   that has passed individually starts FAILING under this runner, that is a REAL
#   pre-existing failure the old runner was hiding — its error tail is printed
#   and recorded. This runner NEVER edits, skips, or fixes an individual test.
#
# USAGE
#   Full sweep:   & "C:/Program Files/R/R-4.2.2/bin/Rscript.exe" Code/tests/testthat.R
#   Subset:       Rscript Code/tests/testthat.R --files=Code/tests/test_cumulative_dose.R
#   Self-test:    Rscript Code/tests/test_runner_selftest.R
# =============================================================================

# ---- Locate repo root from this script's own path, then anchor there --------
args_full <- commandArgs(trailingOnly = FALSE)
file_arg  <- grep("^--file=", args_full, value = TRUE)
if (length(file_arg) > 0) {
  this_script <- normalizePath(sub("^--file=", "", file_arg[[1]]),
                               winslash = "/", mustWork = FALSE)
  repo_root <- normalizePath(file.path(dirname(this_script), "..", ".."),
                             winslash = "/", mustWork = FALSE)
  if (dir.exists(repo_root)) setwd(repo_root)
}
if (!dir.exists("Code/tests")) {
  stop("Test directory not found: Code/tests (cwd = ", getwd(), ")")
}

# ---- Parse CLI / environment ------------------------------------------------
cli <- commandArgs(trailingOnly = TRUE)

is_selftest <- tolower(Sys.getenv("TESTTHAT_SELFTEST", "")) %in%
  c("1", "true", "yes", "t")

files_arg <- grep("^--files=", cli, value = TRUE)
files_glob <- if (length(files_arg) > 0) {
  trimws(strsplit(sub("^--files=", "", files_arg[[1]]), ",", fixed = TRUE)[[1]])
} else {
  character(0)
}

# A "default sweep" is the authoritative run: no explicit file list and not the
# selftest fixture mode. Only that writes the canonical report filenames.
is_default_sweep <- length(files_glob) == 0 && !is_selftest

# ---- Build the ordered, de-duplicated file set ------------------------------
if (length(files_glob) > 0) {
  test_files <- unlist(lapply(files_glob, Sys.glob), use.names = FALSE)
} else {
  test_files <- list.files("Code/tests", pattern = "^test_.*\\.[rR]$",
                            full.names = TRUE)  # non-recursive: skips subdirs
}
if (is_selftest) {
  test_files <- c(test_files,
                  Sys.glob("Code/tests/selftest_fixtures/test_*.[rR]"))
}
# Always drop the runner's own regression test (would recurse into this runner).
test_files <- test_files[basename(test_files) != "test_runner_selftest.R"]
test_files <- unique(normalizePath(test_files, winslash = "/", mustWork = FALSE))
# Express as repo-root-relative for clean reporting.
rel <- function(p) sub(paste0("^", gsub("([.\\^$])", "\\\\\\1", getwd()), "/?"),
                       "", p)
test_rel <- vapply(test_files, rel, character(1), USE.NAMES = FALSE)

if (length(test_files) == 0) {
  stop("No test files matched (files=", paste(files_glob, collapse = ","),
       "; selftest=", is_selftest, ")")
}

# ---- Derive the child Rscript binary (version-agnostic) ---------------------
rscript_bin <- file.path(R.home("bin"), "Rscript")
if (.Platform$OS.type == "windows" && !file.exists(rscript_bin)) {
  rscript_bin <- paste0(rscript_bin, ".exe")
}

cat(sprintf("Aggregate test runner\n  R:        %s\n  Rscript:  %s\n  Repo:     %s\n  Files:    %d%s\n\n",
            R.version.string, rscript_bin, getwd(), length(test_files),
            if (is_selftest) "  (selftest mode: fixtures included)" else ""))

# ---- Run each file in its own clean process ---------------------------------
run_one <- function(path) {
  t0 <- Sys.time()
  out <- tryCatch(
    suppressWarnings(system2(rscript_bin, args = shQuote(path),
                             stdout = TRUE, stderr = TRUE)),
    error = function(e) {
      structure(paste("runner could not launch child process:",
                      conditionMessage(e)), status = 127L)
    }
  )
  status <- attr(out, "status")
  if (is.null(status)) status <- 0L
  list(output   = as.character(out),
       exit_code = as.integer(status),
       seconds  = as.numeric(difftime(Sys.time(), t0, units = "secs")))
}

results <- vector("list", length(test_files))
for (i in seq_along(test_files)) {
  cat(sprintf("[%2d/%2d] %-55s ", i, length(test_files), test_rel[i]))
  flush.console()
  r <- run_one(test_files[i])
  r$file <- test_rel[i]
  r$status <- if (r$exit_code == 0L) "PASS" else "FAIL"
  r$timestamp <- format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
  results[[i]] <- r
  cat(sprintf("%-4s  (%5.1fs, exit %d)\n", r$status, r$seconds, r$exit_code))
}

# ---- Summary table ----------------------------------------------------------
n_fail <- sum(vapply(results, function(r) r$status == "FAIL", logical(1)))
n_pass <- length(results) - n_fail

cat("\n================================ SUMMARY ================================\n")
cat(sprintf("%-4s  %7s  %5s  %s\n", "STAT", "seconds", "exit", "file"))
cat(strrep("-", 72), "\n", sep = "")
for (r in results) {
  cat(sprintf("%-4s  %7.1f  %5d  %s\n", r$status, r$seconds, r$exit_code, r$file))
}
cat(strrep("-", 72), "\n", sep = "")
cat(sprintf("TOTAL: %d files | PASS %d | FAIL %d\n", length(results), n_pass, n_fail))

# ---- Failure tails (the evidence the old runner hid) ------------------------
if (n_fail > 0) {
  cat("\n============================ FAILURE DETAILS ===========================\n")
  for (r in results) {
    if (r$status == "FAIL") {
      cat(sprintf("\n--- FAIL: %s (exit %d) ---\n", r$file, r$exit_code))
      tail_lines <- tail(r$output, 25)
      cat(if (length(tail_lines)) paste(tail_lines, collapse = "\n") else
          "(no output captured)", "\n")
    }
  }
}

# ---- Write machine-readable report + build-log stamp ------------------------
report_dir <- "Analysis/test_reports"
if (!dir.exists(report_dir)) dir.create(report_dir, recursive = TRUE)
suffix <- if (is_default_sweep) "" else "_partial"
csv_path <- file.path(report_dir, paste0("test_report", suffix, ".csv"))
md_path  <- file.path(report_dir, paste0("test_report", suffix, ".md"))

report_df <- data.frame(
  file      = vapply(results, function(r) r$file, character(1)),
  exit_code = vapply(results, function(r) r$exit_code, integer(1)),
  status    = vapply(results, function(r) r$status, character(1)),
  seconds   = round(vapply(results, function(r) r$seconds, numeric(1)), 2),
  timestamp = vapply(results, function(r) r$timestamp, character(1)),
  r_version = R.version.string,
  stringsAsFactors = FALSE
)
write.csv(report_df, csv_path, row.names = FALSE)

md <- c(
  "# Aggregate test report",
  "",
  sprintf("- Generated: %s", format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")),
  sprintf("- R version: %s", R.version.string),
  sprintf("- Rscript:   %s", rscript_bin),
  sprintf("- Repo root: %s", getwd()),
  sprintf("- Mode:      %s", if (is_default_sweep) "full default sweep" else
          if (is_selftest) "selftest (fixtures included)" else "subset (--files)"),
  sprintf("- Result:    %s  (PASS %d | FAIL %d of %d)",
          if (n_fail > 0) "FAIL" else "PASS", n_pass, n_fail, length(results)),
  "",
  "| status | seconds | exit | file |",
  "|---|---:|---:|---|",
  vapply(results, function(r)
    sprintf("| %s | %.1f | %d | %s |", r$status, r$seconds, r$exit_code, r$file),
    character(1))
)
if (n_fail > 0) {
  md <- c(md, "", "## Failure tails", "")
  for (r in results) if (r$status == "FAIL") {
    md <- c(md, sprintf("### %s (exit %d)", r$file, r$exit_code), "",
            "```", tail(r$output, 25), "```", "")
  }
}
writeLines(md, md_path)

cat(sprintf("\nReport written: %s\n           and: %s\n", csv_path, md_path))
cat(sprintf("\nRUNNER RESULT: %s\n", if (n_fail > 0)
    sprintf("FAIL (%d/%d files failed)", n_fail, length(results)) else
    sprintf("PASS (%d/%d files passed)", n_pass, length(results))))

quit(status = if (n_fail > 0) 1L else 0L)
