#' @title Transform parameters
#' @description Transform parameters according to y = x / (1 + x)
#' @param pars parameters
#' @details This is not to be called by the user.
#' @return transformed parameters
#' @export
pars_transform_forward <- function(pars) {
  pars <- as.numeric(unlist(pars))
  pars_transformed <- pars / (1 + pars)
  pars_transformed[which(pars == Inf)] <- 1
  pars_transformed
}

#' @title Transform parameters back
#' @description Transform parameters back according to x = y / (1 + y)
#' @param pars_transformed parameters already transformed
#' @details This is not to be called by the user.
#' @return the original parameters
#' @export
pars_transform_back <- function(pars_transformed) {
  pars_transformed <- as.numeric(unlist(pars_transformed))
  pars <- pars_transformed / (1 - pars_transformed)
  pars
}
