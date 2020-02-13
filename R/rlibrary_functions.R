#' #' Receive the word of our lord JC directly on your PC
#' #' @inheritParams default_params_doc
#' #' @author Giovanni Laudanno, Richel Bilderbeek
#' #' @return nothing
#' #' @export
#' install_richel <- function() {
#'   devtools::install_github("richelbilderbeek/nLTT")
#'   devtools::install_github("ropensci/beautier")
#'   devtools::install_github("ropensci/tracerer")
#'   devtools::install_github("ropensci/beastier")
#'   devtools::install_github("ropensci/mauricer")
#'   devtools::install_github("ropensci/babette")
#'   devtools::install_github("richelbilderbeek/mcbette")
#'   devtools::install_github("thijsjanzen/nodeSub")
#'   devtools::install_github("richelbilderbeek/pirouette", ref = "richel")
#'   devtools::install_github("Giappo/mbd")
#'   devtools::install_github("Giappo/mbd.SimTrees")
#'   devtools::install_github("richelbilderbeek/becosys")
#'   devtools::install_github("richelbilderbeek/peregrine", ref = "richel")
#'   devtools::install_github("richelbilderbeek/razzo", ref = "richel")
#'   if (!beastier::is_beast2_installed()) {
#'     beastier::install_beast2()
#'   }
#'   if (!mauricer::is_beast2_pkg_installed("NS")) {
#'     mauricer::install_beast2_pkg("NS")
#'   }
#' }

#' Open R library
#' @export
open_rlibrary <- function() {
  shell.exec(.libPaths()[1])
}

#' Install and load a package
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
install_package <- function(
  package_name,
  github_name = NA
) {
  max_rep <- 2
  rep <- 1
  while (
    suppressWarnings(!require(package_name, character.only = TRUE)) &&
    rep <= max_rep
  ) {
    if (is.na(github_name)) {
      install.packages(package_name, repos = 'https://lib.ugent.be/CRAN/')
    } else {
      devtools::install_github(
        paste0(github_name, "/", package_name)
      )
    }
    rep <- rep + 1
  }
  # library(package_name, character.only = TRUE)
}

#' Remove a package (and lock file)
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
remove_package <- function(
  package_name
) {
  remove.packages(package_name)
  x <- list.files(.libPaths()[1])
  y <- x[
    # x == package_name |
    x == paste0("00LOCK-", package_name)
    ]
  z <- file.path(.libPaths()[1], y)
  unlink(z, recursive = TRUE, force = TRUE)
  remove.packages(package_name)
}
