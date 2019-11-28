#' Receive the word of our lord JC directly on your PC
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno, Richel Bilderbeek
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

#' Open R library
#' @export
open_rlibrary <- function() {
  shell.exec(.libPaths()[1])
}
