#' Initialize Jap
#' @author Giovanni Laudanno
#' @return nothing
#' @export
initialize_jap <- function() {
  remotes::install_github("tidyverse/googledrive")
  account <- jap::your_account()
  folder_name <- readline(
    "How do you want to name the folder for your Guthub repos?"
  )
  disk <- readline(
    "On which disk is your Github folder?"
  )
  github_folder <- jap::find_github_folder(
    folder_name = folder_name,
    disk = disk
  )
  cluster_folder <- "pippo"
  while (cluster_folder != "home" && cluster_folder != "data") {
    cluster_folder <- readline(
      "What folder do you want to use on cluster: 'home' or 'data'?"
    )
  }
  projects_folder_name <- readline(
    "How do you want to call your projects folder on the cluster?"
  )
  drive <- readline(
    "Do you want to create a folder structure on your google drive?"
  )
  if (drive) {
    drive_email <- readline(
      "What's the email connected to your google drive account?"
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
    disk = disk,
    cluster_folder = cluster_folder,
    project_name = NA,
    drive = drive
  )

  return()
}
