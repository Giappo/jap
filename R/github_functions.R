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
    system(command)
  }

  # jap::git_pull(
  #   github_name = github_name,
  #   github_repo = github_repo,
  #   ...
  # )
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
  disk = "C"
) {

  jap_folder <- system.file(package = "jap")
  extdata_folder <- file.path(jap_folder, "extdata")
  if (!("extdata" %in% list.files(jap_folder))) {
    dir.create(extdata_folder)
  }
  path_file <- file.path(extdata_folder, "githubs_path")
  if (file.exists(path_file)) {
    x <- levels(unname(read.csv(path_file)[[1]]))
    return(x)
  }

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
  x <- x[dir.exists(file.path(x, "jap"))]
  x <- x[which(stringr::str_length(x) == min(stringr::str_length(x)))]

  write.csv(x, file = path_file)
  x
}

#' Open github folder
#' @export
open_github_folder <- function(...) {
  github_folder <- jap::find_github_folder(...)
  shell.exec(github_folder)
  return()
}

#' Open github folder
#' @export
list_githubs <- function(...) {
  github_folder <- jap::find_github_folder(...)
  list.dirs(github_folder, recursive = FALSE)
}

#' Open github folder
#' @export
open_github_project <- function(
  github_repo,
  ...
) {
  github_folder <- jap::find_github_folder(...)
  project_folder <- file.path(github_folder, github_repo)
  if (!dir.exists(github_repo)) {
    jap::git_clone(github_name = github_name, github_repo = github_repo)
  }
  project_file <- file.path(project_folder, paste0(github_repo,".Rproj"))
  if (rappdirs::app_dir()$os == "win") {
    shell.exec(project_file)
  } else {
    shell(project_file)
  }
  return()
}
