#' This function does nothing. It is intended to inherit is parameters'
#' documentation.
#' @param account a peregrine account
#' @param age the age of the phylogeny
#' @param session a ssh session
#' @param lambda speciation rate
#' @param mu extinction rate
#' @param message a message to be print
#' @param t time
#' @param verbose choose if you want to print the output or not
#' @author Documentation by Giovanni Laudanno,
#' @note This is an internal function, so it should be marked with
#'   \code{@noRd}. This is not done, as this will disallow all
#'   functions to find the documentation parameters
default_params_doc <- function(
  account,
  age,
  session,
  lambda,
  mu,
  t,
  message,
  verbose
) {
  # Nothing
}
