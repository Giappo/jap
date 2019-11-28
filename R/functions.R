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
  if (!beastier::is_beast2_installed()) {
    beastier::install_beast2()
  }
  if (!mauricer::is_beast2_pkg_installed("NS")) {
    mauricer::install_beast2_pkg("NS")
  }
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

#' Like file.path, but cooler
#' @param fsep path separator for the OS
#' @param ... additional arguments
#' @export
file_path <- function(..., fsep = .Platform$file.sep) {
  gsub("//", "/", file.path(..., fsep = fsep))
}

#' Open R library
#' @export
open_rlibrary <- function() {
  shell.exec(.libPaths()[1])
}
