#' Open R library
#' @export
open_rlibrary <- function() {
  jap::open_file(.libPaths()[1])
  # .rs.restartR()
  rstudioapi::restartSession()
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
    if (!is.na(github_name)) {
      devtools::install_github(
        paste0(github_name, "/", package_name)
      )
    } else {
      out <- jap::my_try_catch(
        utils::install.packages(package_name, repos = 'https://lib.ugent.be/CRAN/')
      )
      if (!is.null(out$warning) || !is.null(out$error)) {
        github_name <- readline(paste0(
          "What's the name of the Github profile for the package ",
          package_name,
          "?"
        ))
        # out <- jap::my_try_catch(
        devtools::install_github(
          paste0(github_name, "/", package_name)
        )
        # )
        # if (!is.null(out$warning) || !is.null(out$error)) {
        #   stop(paste0("wrong Github profile for package ", package_name))
        # }
      }
    }
    rep <- rep + 1
  }
  library(package_name, character.only = TRUE)
}

#' Remove a package (and lock file)
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
remove_package <- function(
  package_name
) {
  utils::remove.packages(package_name)
  x <- list.files(.libPaths()[1])
  y <- x[
    # x == package_name |
    x == paste0("00LOCK-", package_name)
    ]
  z <- file.path(.libPaths()[1], y)
  unlink(z, recursive = TRUE, force = TRUE)
  utils::remove.packages(package_name)
}
