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

#' Just plot a matrix without rotating it
#' @param logs do you want to plot in log scale?
#' @param low_triangular do you want to plot only the low triangular?
#' @export
plot_matrix <- function(
  mat,
  logs = TRUE,
  low_triangular = FALSE
) {
  if (low_triangular == TRUE) {
    mat[col(mat) >= row(mat)] <- 0
  }
  rotate <- function(x) t(apply(x, 2, rev))
  col_palette <- colorRampPalette(
    c('blue', 'white', 'red')
  )(30)
  if (logs == TRUE) {
    mat2 <- log(mat)
  } else {
    mat2 <- mat
  }
  levelplot(
    rotate(mat2),
    col.regions = col_palette
  )
}
