#' Specify subfolder structure
#' @author Giovanni Laudanno
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
  projects_folder_name = jap::default_projects_folder(),
  home_dir = jap::default_home_dir(),
  cluster_folder = jap::default_cluster_folder(),
  project_name = NA,
  drive = jap::default_drive_choice(),
  session = NA
) {

  local_projects_folder <- file.path(home_dir, projects_folder_name)
  remote_projects_folder <- file.path(
    "",
    cluster_folder,
    account,
    projects_folder_name
  )

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
  if (!is.na(project_name)) {

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
  projects_folder_name = jap::default_projects_folder(),
  home_dir = jap::default_home_dir(),
  cluster_folder = jap::default_cluster_folder(),
  drive = jap::default_drive_choice(),
  session = NA
) {

  ans <- readline(
    prompt = "Are you sure you want to delete the entire folder structure on local/remote/drive? y/n"
  )
  if (ans != "y") {
    return()
  }

  local_projects_folder <- file.path(paste0(home_dir, ":"), projects_folder_name)
  remote_projects_folder <- file.path(
    "",
    cluster_folder,
    account,
    projects_folder_name
  )
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

#' Find local project folder
#' @inheritParams default_params_doc
#' @export
get_local_project_folder <- function(
  project_name,
  projects_folder_name = jap::default_projects_folder(),
  home_dir = jap::default_home_dir()
) {
  file.path(
    home_dir,
    projects_folder_name,
    project_name
  )
}

#' Find remote project folder
#' @inheritParams default_params_doc
#' @export
get_remote_project_folder <- function(
  project_name,
  projects_folder_name = jap::default_projects_folder(),
  account = jap::your_account(),
  cluster_folder = jap::default_cluster_folder()
) {
  file.path(
    "",
    cluster_folder,
    account,
    projects_folder_name,
    project_name
  )
}
