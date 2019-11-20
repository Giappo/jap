#' Receive the word of our lord JC directly on your PC
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return nothing
#' @export
install_richel <- function() {
  devtools::install_github("richelbilderbeek/nLTT")
  devtools::install_github("ropensci/beautier")
  devtools::install_github("ropensci/tracerer")
  devtools::install_github("ropensci/beastier")
  devtools::install_github("ropensci/mauricer")
  devtools::install_github("ropensci/babette")
  devtools::install_github("richelbilderbeek/mcbette")
  devtools::install_github("thijsjanzen/nodeSub")
  devtools::install_github("richelbilderbeek/pirouette", ref = "richel")
  devtools::install_github("Giappo/mbd")
  devtools::install_github("Giappo/mbd.SimTrees")
  devtools::install_github("richelbilderbeek/becosys")
  devtools::install_github("richelbilderbeek/peregrine", ref = "richel")
  devtools::install_github("richelbilderbeek/razzo", ref = "richel")
  if (!beastier::is_beast2_installed()) beastier::install_beast2()
  if (!mauricer::is_beast2_pkg_installed("NS")) mauricer::install_beast2_pkg("NS")
}

#' @title cat2
#' @author Giovanni Laudanno
#' @description If verbose == TRUE cats the message, otherwise stays silent
#' @inheritParams default_params_doc
#' @return prints on screen
#' @export
cat2 <- function(
  message,
  verbose
) {
  if (verbose == TRUE) {
    cat(message)
  } else {
    return()
  }
}

#' @title Transform parameters
#' @description Transform parameters according to y = x / (1 + x)
#' @inheritParams default_params_doc
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
#' @inheritParams default_params_doc
#' @details This is not to be called by the user.
#' @return the original parameters
#' @export
pars_transform_back <- function(pars_transformed) {
  pars_transformed <- as.numeric(unlist(pars_transformed))
  pars <- pars_transformed / (1 - pars_transformed)
  pars
}

#' Create an empty phylogeny
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @export
create_empty_phylo <- function() {
  tr <- list(edge = matrix(c(2, 1), 1, 2), tip.label = "", Nnode = 0L)
  class(tr) <- "phylo"
  tr$tip.label <- c() # nolint
  tr
}

#' Create an empty phylogeny
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @export
create_singleton_phylo <- function(age) {
  tr <- list(edge = matrix(c(2, 1), 1, 2), tip.label = "t1", Nnode = 1L)
  class(tr) <- "phylo"
  tr$edge.length <- age # nolint
  tr
}

#' Like file.path, but cooler
#' @param fsep path separator for the OS
#' @param ... additional arguments
#' @export
file_path <- function(..., fsep = .Platform$file.sep) {
  gsub("//", "/", file.path(..., fsep = fsep))
}
