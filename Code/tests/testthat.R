# testthat entrypoint for repository-level script tests

library(testthat)

args_full <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_full, value = TRUE)

if (length(file_arg) > 0) {
  this_script <- normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = FALSE)
  repo_root <- normalizePath(file.path(dirname(this_script), "..", ".."), winslash = "/", mustWork = FALSE)
  if (dir.exists(repo_root)) {
    setwd(repo_root)
  }
}

if (!dir.exists("Code/tests")) {
  stop("Test directory not found: Code/tests")
}

test_files <- list.files("Code/tests", pattern = "^test_.*\\.[rR]$", full.names = TRUE)
if (length(test_files) == 0) {
  stop("No test files found")
}

for (test_path in test_files) {
  test_file(test_path, reporter = "summary")
}
