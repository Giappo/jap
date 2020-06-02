#' Clone a repo
#' @inheritParams default_params_doc
#' @param ... additional arguments to be passed to \link{find_github_folder}
#' @author Giovanni Laudanno
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
      file.path(github_folder, github_repo)
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
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
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

#' Pull a repo
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
git_pull_request <- function(
  github_name,
  github_repo,
  from,
  to
) {

  cat("it does not work yet")
  return()

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
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @export
find_github_folder <- function(
  github_folder_name = jap::default_github_folder(),
  home_dir = jap::default_home_dir()
) {
  file.path(home_dir, github_folder_name)
}

#' Open github folder
#' @description It opens your github folder.
#' @param ... additional arguments to be passed to \link{find_github_folder}
#' @author Giovanni Laudanno
#' @export
open_github_folder <- function(...) {
  github_folder <- jap::find_github_folder(...)
  jap::open_file(github_folder)
  return()
}

#' Open github project
#' @description It opens a github project from your github folder.
#' To specify your github folder see \link{find_github_folder}.
#' @inheritParams default_params_doc
#' @param ... additional arguments to be passed to \link{find_github_folder}
#' @author Giovanni Laudanno
#' @export
open_github_project <- function(
  github_repo,
  ...
) {
  github_folder <- jap::find_github_folder(...)
  project_folder <- file.path(github_folder, github_repo)
  if (!dir.exists(project_folder)) {
    github_name <- readline("What's the name of the Github profile? ")
    jap::git_clone(github_name = github_name, github_repo = github_repo)
  }
  project_file <- file.path(project_folder, paste0(github_repo,".Rproj"))
  testit::assert(file.exists(project_file))
  jap::open_file(project_file)
  return()
}

#' Open github folder
#' @param ... additional arguments to be passed to \link{find_github_folder}
#' @author Giovanni Laudanno
#' @export
list_githubs <- function(...) {
  github_folder <- jap::find_github_folder(...)
  list.dirs(github_folder, recursive = FALSE)
}

#' List all GitHub projects
#' @author Giovanni Laudanno
#' @return nothing
#' @export
list_projects <- function() {
  github_folder <- jap::find_github_folder()
  list.files(github_folder)
}
