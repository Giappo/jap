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
  if (!(add %in% unlist(googledrive::drive_ls(path = base,
                                              n_max = 1000,
                                              type = "folder")[, 1]))) {
    googledrive::drive_mkdir(name = add, path = base)
  }
}

#' List drive files
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return List of files
#' @export
drive_list.files <- function(
  dir = "Projects"
) {

  # list files
  googledrive::drive_ls(path = dir)

}
