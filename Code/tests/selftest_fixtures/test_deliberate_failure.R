# =============================================================================
# test_deliberate_failure.R — DELIBERATE-FAILURE FIXTURE (do NOT "fix")
# =============================================================================
# PURPOSE
#   A test that ALWAYS fails, on purpose. It is the regression sentinel for the
#   aggregate runner (`Code/tests/testthat.R`, audit item A1): a truthful runner
#   MUST surface this as a FAIL and exit nonzero. If someone ever "greens" the
#   runner by mistake, `Code/tests/test_runner_selftest.R` — which sweeps this
#   fixture — will start passing when it should fail, exposing the regression.
#
# WHY IT LIVES HERE
#   It sits under `Code/tests/selftest_fixtures/` (a subdirectory) so the
#   runner's DEFAULT, non-recursive sweep of `Code/tests/test_*.R` never picks
#   it up. It is included ONLY when the runner is invoked with the environment
#   variable TESTTHAT_SELFTEST=1 (set by the self-test). Thus a normal suite run
#   stays green when the real tests are healthy.
#
# INPUTS  : none.
# OUTPUTS : a guaranteed testthat failure -> nonzero exit when run via Rscript.
# R       : version-agnostic (only `testthat`).
#
# DO NOT edit this to pass, do not delete it, do not move it into the main sweep.
# =============================================================================

library(testthat)

test_that("deliberate-failure fixture always fails (runner regression sentinel)", {
  # Intentional, unconditional failure. This is the whole point of the fixture.
  expect_true(FALSE,
              info = "INTENTIONAL: proves the aggregate runner detects failures")
})
