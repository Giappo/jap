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
  git_folder <- dirname(current_folder)
  if (!grepl(x = substr_right(git_folder, 8), pattern = "Githubs")) {
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
