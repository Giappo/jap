#' Initialize Jap
#' @author Giovanni Laudanno
#' @return nothing
#' @export
initialize_jap <- function() {

  remotes::install_github("tidyverse/googledrive", quiet = TRUE)
  rprof_path <- usethis:::scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")

  cat("This function will initialize the 'jap' package.\n")
  account <- jap::your_account()
  cat("'jap' will create two folders: one for your Github repos and one for your projects.\n")

  disk <- jap::default_home_dir()
  github_folder <- jap::default_github_folder()
  projects_folder_name <- jap::default_projects_folder()
  cluster_folder <- jap::default_cluster_folder()

  drive_ans <- readline(
    "Do you want to create a folder structure on your google drive (y/n)?\n"
  )
  if (drive_ans == "y") {
    drive <- TRUE
  }
  if (drive) {
    drive_email <- readline(
      "What's the email connected to your google drive account?\n"
    )
    googledrive::drive_auth(
      email = drive_email,
      cache = TRUE,
      use_oob = TRUE
    )
  }
  jap::create_folder_structure(
    projects_folder_name = projects_folder_name,
    account = account,
    home_dir = disk,
    cluster_folder = cluster_folder,
    project_name = NA,
    drive = drive
  )

  return()
}
