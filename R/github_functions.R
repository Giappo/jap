#' Clone a repo
#' @export
git_clone <- function(
  github_name,
  github_repo
) {

  substr_right <- function(x, n){
    substr(x, nchar(x) - n + 1, nchar(x))
  }

  current_folder <- getwd()
  github_folder <- jap::find_github_folder()
  if (!grepl(x = substr_right(github_folder, 8), pattern = "Githubs")) {
    stop("Github folder has not been correctly identified!")
  }
  setwd(git_folder)
  command <- paste0(
    "git clone https://github.com/",
    github_name,
    "/",
    github_repo,
    ".git"
  )
  system(command)
  setwd(current_folder)
  return()
}

#' Find github folder
#' @export
find_github_folder <- function(
  folder_name = "Githubs",
  disk = "D"
) {
  suppressWarnings(
    pre <- fs::dir_ls(
      path = paste0(disk, ":/"), #c("D:/"), # c("C:/", "E:/"),
      type = "directory",
      # glob = "*Githubs",
      recursive = TRUE, regexp = folder_name, fail = FALSE
    )
  )
  while (length(pre) == 0) {
    disks <- LETTERS[3:12]
    disks <- disks[disks != disk]
    for (disk in disks) {
      suppressWarnings(
        pre <- fs::dir_ls(
          path = paste0(disk, ":/"), #c("D:/"), # c("C:/", "E:/"),
          type = "directory",
          recursive = TRUE, regexp = folder_name, fail = FALSE
        )
      )
    }
    if (length(pre) == 0) {
      stop("Folder not found")
    }
  }
  y <- stringr::str_length(folder_name) + 1
  x <- pre[which(grepl(x = substr_right(pre, y), pattern = folder_name))]
  x <- x[which(stringr::str_length(x) == min(stringr::str_length(x)))]
  x
}
