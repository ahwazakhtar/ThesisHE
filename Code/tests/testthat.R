# This file is part of the testthat package.
# It is used to automatically run all your tests.

library(testthat)
library(here)

# The here() function will set the root directory to the project root.
# This makes it easier to run tests from different directories.
setwd(here::here())

test_check("Code/tests")
