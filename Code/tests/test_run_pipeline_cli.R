library(testthat)

utils_path <- if (file.exists("Code/pipeline_utils.R")) {
  "Code/pipeline_utils.R"
} else {
  "../pipeline_utils.R"
}
source(utils_path)

test_that("parse_cli_args handles pipeline and phase flags", {
  opts <- parse_cli_args(c(
    "--pipeline", "state",
    "--phases", "process,merge",
    "--skip-download",
    "--strict", "FALSE",
    "--dry-run"
  ))

  expect_equal(opts$pipeline, "state")
  expect_equal(opts$phases, c("process", "merge"))
  expect_true(opts$skip_download)
  expect_false(opts$strict)
  expect_true(opts$dry_run)
})

test_that("resolve_selected_phases respects from/to and skip-download", {
  opts <- list(
    phases = NULL,
    skip_download = TRUE,
    from = "download",
    to = "analysis"
  )

  phases <- resolve_selected_phases(opts)
  expect_equal(phases, c("process", "merge", "analysis"))
})

test_that("filter_steps applies pipeline and phase filters", {
  steps <- list(
    list(id = "a", pipeline = "state", phase = "download", script = "x"),
    list(id = "b", pipeline = "state", phase = "process", script = "x"),
    list(id = "c", pipeline = "county", phase = "process", script = "x")
  )

  selected <- filter_steps(steps, pipeline = "state", phases = c("process"))
  expect_equal(length(selected), 1)
  expect_equal(selected[[1]]$id, "b")
})
