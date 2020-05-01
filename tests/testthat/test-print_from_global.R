testthat::context("print_from_global")

testthat::test_that("use", {
  x <- 1
  testthat::expect_silent(
    jap::print_from_global(var = "x")
  )
})
