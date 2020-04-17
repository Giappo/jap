#' Create a directory on drive
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
drive_dir.create <- function(
  dir
) {
  base <- dirname(dir)
  if (base == ".") {base <- NULL}
  add <- basename(dir)
  if (!(add %in% unlist(googledrive::drive_ls(path = base)[, 1]))) {
    googledrive::drive_mkdir(name = add, path = base)
  }
}
