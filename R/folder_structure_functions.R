#' Specify subfolder structure
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
folder_structure <- function() {
  folder_names <- c(
    "results",
    "logs",
    "cluster_scripts",
    "data"
  )
}

#' Create folder structure
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
create_folder_structure <- function(
  account = jap::your_account(),
  projects_folder_name = "Projects",
  disk = "D",
  project_name = "sls",
  session = NA,
  drive = FALSE
) {

  local_projects_folder <- file.path(paste0(disk, ":"), projects_folder_name)
  remote_projects_folder <- file.path("", "home", account, projects_folder_name)

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  folder_names <- jap::folder_structure()

  # PROJECTS FOLDER
  ## local
  if (!(dir.exists(local_projects_folder))) {
    dir.create(local_projects_folder)
  }

  # peregrine
  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "chmod +x ", dirname(remote_projects_folder)
    )
  )
  if (!remote_dir.exists(remote_projects_folder, session = session)) {
    remote_dir.create(remote_projects_folder, session = session)
  }
  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "chmod +x ", remote_projects_folder
    )
  )

  ## drive
  if (drive == TRUE) {
    drive_projects_folder <- basename(local_projects_folder)
    drive_dir.create(dir = drive_projects_folder)
  }

  # SPECIFIC PROJECT FOLDER
  ## local
  local_project_folder <- file.path(local_projects_folder, project_name)
  if (!(dir.exists(local_project_folder))) {
    dir.create(local_project_folder)
  }

  ## peregrine
  remote_project_folder <- file.path(remote_projects_folder, project_name)
  if (!remote_dir.exists(remote_project_folder, session = session)) {
    remote_dir.create(remote_project_folder, session = session)
  }

  ## drive
  if (drive == TRUE) {
    drive_project_folder <- file.path(drive_projects_folder, project_name)
    drive_dir.create(dir = drive_project_folder)
  }

  for (folder_name in folder_names) {
    folder <- file.path(local_project_folder, folder_name)
    if (!(dir.exists(folder))) {
      dir.create(folder)
    }
    folder <- file.path(remote_project_folder, folder_name)
    if (!remote_dir.exists(folder, session = session)) {
      remote_dir.create(folder, session = session)
    }
    if (drive == TRUE) {
      folder <- file.path(drive_project_folder, folder_name)
      drive_dir.create(dir = folder)
    }
  }

  # close session
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
}

#' Delete folder structure
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
delete_folder_structure <- function(
  account = jap::your_account(),
  projects_folder_name = "Projects",
  disk = "D",
  session = NA,
  drive = FALSE
) {

  local_projects_folder <- file.path(paste0(disk, ":"), projects_folder_name)
  remote_projects_folder <- file.path("", "home", account, projects_folder_name)
  drive_projects_folder <- basename(local_projects_folder)

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  folder_names <- jap::folder_structure()

  # PROJECTS FOLDER
  ## local
  unlink(local_projects_folder, recursive = TRUE)

  # peregrine
  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "rm -r ", remote_projects_folder
    )
  )

  ## drive
  if (drive == TRUE) {
    googledrive::drive_rm(drive_projects_folder)
  }

  # close session
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
}
