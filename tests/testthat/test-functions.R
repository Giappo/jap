context("jappe")

test_that("use", {
  x <- 1
  testthat::expect_silent(
    print_from_global(var = "x")
  )
})
