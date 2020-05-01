testthat::context("nee_functions")

testthat::test_that("pt", {
  lambda <- 0.4
  mu <- 0.1
  t <- 2
  prob <- jap::pt(lambda = lambda, mu = mu, t = t)
  testthat::expect_true(
    prob >= 0 & prob <= 1
  )
  prob <- jap::one_minus_pt(lambda = lambda, mu = mu, t = t)
  testthat::expect_true(
    prob >= 0 & prob <= 1
  )
})

testthat::test_that("pt", {
  lambda <- 0.4
  mu <- 0.1
  t <- 2
  prob <- jap::ut(lambda = lambda, mu = mu, t = t)
  testthat::expect_true(
    prob >= 0 & prob <= 1
  )
  prob <- jap::one_minus_ut(lambda = lambda, mu = mu, t = t)
  testthat::expect_true(
    prob >= 0 & prob <= 1
  )
})
