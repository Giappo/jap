#' @title Pt
#' @author Giovanni Laudanno
#' @description Nee's function: pt
#' @inheritParams nee_params_doc
#' @return pt
#' @export
pt  <- function(lambda, mu, t) {
  time <- t
  exp_term <- exp(
    (mu - lambda) * time
  )
  out    <- (lambda == mu) * (1 / (1 + lambda * time)) +
    (lambda != mu) * (
      (lambda - mu + (lambda == mu)) /
        (lambda - mu * exp_term * (lambda != mu) + (lambda == mu))
    )
  return(unname(out))
}

#' @title 1 - Pt
#' @author Giovanni Laudanno
#' @description Nee's function: 1 - pt
#' @inheritParams nee_params_doc
#' @return 1 - pt
#' @export
one_minus_pt  <- function(lambda, mu, t) {
  time <- t
  exp_term <- exp(
    (mu - lambda) * time
  )
  out    <- (lambda == mu) * (lambda * time / (1 + lambda * time)) +
    (lambda != mu) * (
      (mu - mu * exp_term + (lambda == mu)) /
        (lambda - mu * exp_term + (lambda == mu))
    )
  return(unname(out))
}

#' @title ut
#' @author Giovanni Laudanno
#' @description Nee's function: ut
#' @inheritParams nee_params_doc
#' @return ut
#' @export
ut  <- function(lambda, mu, t) {
  time <- t
  exp_term <- exp(
    (mu - lambda) * time
  )
  out <- (lambda == mu) * (lambda * time / (1 + lambda * time)) +
    (lambda != mu) * (
      (lambda - lambda * exp_term + (lambda == mu)) /
        (lambda - mu * exp_term * (lambda != mu) + (lambda == mu))
    )
  return(unname(out))
}

#' @title 1 - ut
#' @author Giovanni Laudanno
#' @description Nee's function: 1 - ut
#' @inheritParams nee_params_doc
#' @return 1 - ut
#' @export
one_minus_ut  <- function(lambda, mu, t) {
  time <- t
  exp_term <- exp(
    (mu - lambda) * time
  )
  out    <- (lambda == mu) * (1 / (1 + lambda * time)) +
    (lambda != mu) * (
      (0 + (lambda == mu) + (lambda - mu) * exp_term) /
        (lambda - mu * exp_term + (lambda == mu))
    )
  return(unname(out))
}

#' @title Pn
#' @author Giovanni Laudanno
#' @description Nee's function: pn
#' @inheritParams nee_params_doc
#' @return pn
#' @export
pn <- function(lambda, mu, t, n) {
  out <- (n > 0) * jap::p_t(t = t, lambda = lambda, mu = mu) *
    jap::one_minus_ut(t = t, lambda = lambda, mu = mu) *
    jap::ut(t = t, lambda = lambda, mu = mu) ^ (n - 1 + 2 * (n == 0)) +
    (n == 0) * (jap::one_minus_pt(t = t, lambda = lambda, mu = mu))
  return(out)
}

#' @title Pn accounting for extinctions after the shifts
#' @author Giovanni Laudanno
#' @description Combine pn from Nee et al. and imposes the extinction
#'  before the present of all species not visible in the phylogeny
#' @inheritParams nee_params_doc
#' @return pn times probability of extinction for n-1 species after the shift
#' @export
pn_bar <- function(lambda, mu, t, n, tbar = 0) {
  out <- (n > 0) * jap::p_t(t = t, lambda = lambda, mu = mu) *
    (jap::one_minus_ut(t = t, lambda = lambda, mu = mu)) *
    n *
    jap::ut(t = t, lambda = lambda, mu = mu) ^ (n - 1) *
    jap::one_minus_pt(
      t = tbar,
      lambda = lambda, mu = mu
    ) ^ (n - 1 + (n == 0)) +
    (n == 0) * (jap::one_minus_pt(t = t, lambda = lambda, mu = mu)) * n
  return(out)
}
