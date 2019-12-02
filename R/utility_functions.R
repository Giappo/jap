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
#' A better try catch
#' @param expr an expression
#' @export
my_try_catch <- function(expr) {
  warn <- err <- NULL
  value <- withCallingHandlers(
    tryCatch(
      expr, error = function(e) {
        err <<- e
        NULL
      }
    ), warning = function(w) {
      warn <<- w
      invokeRestart("muffleWarning")
    })
  list(
    value = value,
    warning = warn,
    error = err
  )
}
