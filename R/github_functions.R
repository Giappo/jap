#' Clone a repo
#' @export
git_clone <- function(
  github_name,
  github_repo,
  ...
) {

  github_folder <- jap::find_github_folder(...)
  if (!(github_repo %in% list.files(github_folder))) {
    command <- paste0(
      "git clone -q https://github.com/",
      github_name,
      "/",
      github_repo,
      ".git",
      " ",
      github_folder,
      "/",
      github_repo
    )
  }

  jap::git_pull(
    github_name = github_name,
    github_repo = github_repo,
    ...
  )
  return()
}

#' Pull a repo
#' @export
git_pull <- function(
  github_name,
  github_repo
) {

  command <- paste0(
    "git pull --allow-unrelated-histories https://github.com/",
    github_name,
    "/",
    github_repo,
    ".git"
  )
  system(command)
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

  substr_right <- function(x, n){
    substr(x, nchar(x) - n + 1, nchar(x))
  }

  y <- stringr::str_length(folder_name) + 1
  x <- pre[which(grepl(x = substr_right(pre, y), pattern = folder_name))]
  x <- x[which(stringr::str_length(x) == min(stringr::str_length(x)))]
  x
}

#' Open github folder
#' @export
open_github_folder <- function(
  folder_name = "Githubs",
  disk = "D"
) {
  github_folder <- jap::open_github_folder(folder_name = folder_name, disk = disk)
  shell.exec(github_folder)
  return()
}
