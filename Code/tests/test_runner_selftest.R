# =============================================================================
# test_runner_selftest.R — REGRESSION TEST for the aggregate runner (audit A1)
# =============================================================================
# PURPOSE
#   Prove that `Code/tests/testthat.R` is TRUTHFUL, i.e. that its process exit
#   status actually reflects test outcomes. The predecessor runner exited 0 even
#   with 36 error lines; this file makes that class of regression fail loudly.
#
# WHAT IT ASSERTS
#   1. FAILURE MODE: when the runner is told to include the deliberate-failure
#      fixture (env TESTTHAT_SELFTEST=1) alongside a couple of quick real tests,
#      the runner MUST exit NONZERO.
#   2. PASS MODE: when the runner is pointed at a small subset of passing tests
#      only (no fixture), it MUST exit ZERO.
#
# HOW IT DRIVES THE RUNNER
#   It launches the runner in a fresh child `Rscript` process (same interpreter,
#   derived from `R.home("bin")` so it is version-agnostic). The fixture is
#   selected via the TESTTHAT_SELFTEST environment variable. Because `system2`'s
#   `env=` argument is unreliable on Windows, the variable is set in THIS process
#   with `Sys.setenv()` before the launch and cleared afterwards — the child
#   inherits it portably.
#
#   To stay fast it runs only 2 quick, self-contained tests
#   (`test_cumulative_dose.R`, `test_run_pipeline_cli.R` — synthetic data, no I/O)
#   plus, in failure mode, the fixture. Full-suite coverage is the job of a plain
#   `Rscript Code/tests/testthat.R` run, not of this self-test.
#
# INPUTS  : Code/tests/testthat.R, the two quick tests, the fixture.
# OUTPUTS : testthat pass/fail; a failed assertion here exits this file nonzero.
# R       : version-agnostic. Run standalone:  Rscript Code/tests/test_runner_selftest.R
# =============================================================================

library(testthat)

# ---- Anchor at repo root (mirror the runner's own logic) --------------------
args_full <- commandArgs(trailingOnly = FALSE)
file_arg  <- grep("^--file=", args_full, value = TRUE)
if (length(file_arg) > 0) {
  this_script <- normalizePath(sub("^--file=", "", file_arg[[1]]),
                               winslash = "/", mustWork = FALSE)
  repo_root <- normalizePath(file.path(dirname(this_script), "..", ".."),
                             winslash = "/", mustWork = FALSE)
  if (dir.exists(repo_root)) setwd(repo_root)
}
stopifnot(file.exists("Code/tests/testthat.R"))

# ---- Derive the child Rscript binary (same interpreter, any version) --------
rscript_bin <- file.path(R.home("bin"), "Rscript")
if (.Platform$OS.type == "windows" && !file.exists(rscript_bin)) {
  rscript_bin <- paste0(rscript_bin, ".exe")
}

RUNNER <- "Code/tests/testthat.R"
QUICK  <- paste(
  "Code/tests/test_cumulative_dose.R",
  "Code/tests/test_run_pipeline_cli.R",
  sep = ","
)

# Launch the runner; return its integer exit code. `selftest=TRUE` sets the env
# var (inherited by the child) so the runner also sweeps selftest_fixtures/.
invoke_runner <- function(files, selftest) {
  if (selftest) Sys.setenv(TESTTHAT_SELFTEST = "1") else Sys.unsetenv("TESTTHAT_SELFTEST")
  on.exit(Sys.unsetenv("TESTTHAT_SELFTEST"), add = TRUE)
  out <- suppressWarnings(system2(
    rscript_bin,
    args   = c(shQuote(RUNNER), paste0("--files=", files)),
    stdout = TRUE, stderr = TRUE
  ))
  status <- attr(out, "status")
  if (is.null(status)) 0L else as.integer(status)
}

# ---- 1. FAILURE MODE: fixture included -> runner must exit nonzero ----------
test_that("runner exits NONZERO when the deliberate-failure fixture is swept", {
  code <- invoke_runner(QUICK, selftest = TRUE)
  expect_true(code != 0L,
              info = sprintf("expected nonzero exit with fixture included; got %d", code))
})

# ---- 2. PASS MODE: passing subset only -> runner must exit zero -------------
test_that("runner exits ZERO on a passing subset (no fixture)", {
  code <- invoke_runner(QUICK, selftest = FALSE)
  expect_equal(code, 0L,
               info = sprintf("expected exit 0 on passing subset; got %d", code))
})

cat("\nRunner self-test completed.\n")
