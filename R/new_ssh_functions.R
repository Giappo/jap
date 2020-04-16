#' Create folder structure
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
create_folder_structure <- function(
  account = "p274829",
  local_projects_folder = "D:/Projects",
  remote_projects_folder = file.path("/home", account),
  project_name = "sls",
  session = NA
) {
  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  folder_names <- c(
    "results",
    "logs",
    "cluster_scripts",
    "data"
  )

  local_project_folder <- file.path(local_projects_folder, project_name)
  if (!(dir.exists(local_project_folder))) {
    dir.create(local_project_folder)
  }

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

  remote_project_folder <- file.path(remote_projects_folder, project_name)
  if (!remote_dir.exists(remote_project_folder, session = session)) {
    remote_dir.create(remote_project_folder, session = session)
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
  }

  # close session
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
}

#' @title Check if folder exist on cluster
#' @description Check if folder exist on cluster
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
remote_dir.exists <- function(
  dir,
  account = "p274829",
  session = NA
) {
  jap::remote_file.exists(
    file = dir,
    account = "p274829",
    session = session
  )
}

#' @title Check if file exist on cluster
#' @description Check if file exist on cluster
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
remote_file.exists <- function(
  file,
  account = "p274829",
  session = NA
) {
  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  files <- capture.output(ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "ls ", dirname(file)
    )
  ))
  file_exist <- basename(file) %in% files

  # close session
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }

  file_exist
}

#' @title Create a directory on cluster
#' @description Create a directory on cluster
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
remote_dir.create <- function(
  dir,
  account = "p274829",
  session = NA
) {
  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "mkdir ", dir
    )
  )

  # close session
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
}

#' Remove a directory
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
remote_dir.remove <- function(
  dir,
  account = "p274829",
  session = NA
) {
  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "rm -r ", dir
    )
  )

  # close session
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
}

#' List remote files
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return List of files
#' @export
remote_list.files <- function(
  dir,
  account = "p274829",
  session = NA
) {
  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  # list files
  files <- capture.output(ssh::ssh_exec_wait(
    session = session,
    command = paste0("ls ", dir)
  ))
  files <- files[-length(files)]

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }

  files
}

#' @title Download the results to the results folder of the project
#' @author Giovanni Laudanno
#' @description Download the results to the results folder of the project
#' @inheritParams default_params_doc
#' @return nothing
#' @export
download_results <- function(
  local_projects_folder = "D:/Projects",
  remote_projects_folder = file.path("/home", account),
  project_name = "sls",
  delete_on_cluster = FALSE,
  account = "p274829",
  session = NA
) {

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  jap::create_folder_structure(
    local_projects_folder = local_projects_folder,
    remote_projects_folder = remote_projects_folder,
    project_name = project_name,
    account = account,
    session = session
  )

  # download files
  ssh::scp_download(
    session = session,
    files = file.path(remote_project_folder, "results", "*"),
    to = file.path(local_project_folder, "results"),
    verbose = TRUE
  )

  if (delete_on_cluster) {
    ssh::ssh_exec_wait(
      session = session,
      command = paste0(
        "rm -rfv ", file.path(remote_results_folder, "*")
      )
    )
  }

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  return()
}

#' @title Download the log files to the logs folder of the project
#' @author Giovanni Laudanno
#' @description Download the log files to the logs folder of the project
#' @inheritParams default_params_doc
#' @return nothing
#' @export
download_logs <- function(
  local_projects_folder = "D:/Projects",
  remote_projects_folder = file.path("/home", account),
  project_name = "sls",
  delete_on_cluster = FALSE,
  account = "p274829",
  session = NA
) {

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  jap::create_folder_structure(
    local_projects_folder = local_projects_folder,
    remote_projects_folder = remote_projects_folder,
    project_name = project_name,
    account = account,
    session = session
  )

  # download files
  ssh::scp_download(
    session = session,
    files = file.path(remote_project_folder, "logs", "*"),
    to = file.path(local_project_folder, "logs"),
    verbose = TRUE
  )

  if (delete_on_cluster) {
    ssh::ssh_exec_wait(
      session = session,
      command = paste0(
        "rm -rfv ", file.path(remote_logs_folder, "*")
      )
    )
  }

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  return()
}

#' @title Export cluster scripts
#' @author Giovanni Laudanno
#' @description Export cluster scripts
#' @inheritParams default_params_doc
#' @return nothing
#' @export
upload_cluster_scripts <- function(
  project_name = "sls",
  account = "p274829",
  session = NA
) {

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  # folder structure
  project_folder <- get_project_folder(project_name)
  remote_project_folder <- file.path(project_name)
  local_cluster_folder <- file.path(project_folder, "cluster_scripts")
  testit::assert(dir.exists(local_cluster_folder))

  ssh::ssh_exec_wait(session, command = paste0("mkdir -p ", project_name))

  system.time(
    ssh::scp_upload(
      session = session,
      files = paste0(
        local_cluster_folder,
        "/",
        list.files(local_cluster_folder, pattern = ".bash")
      ),
      to = remote_project_folder
    )
  )
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  return()
}

#' @title Install packages for a given project
#' @description Install packages for a given project
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return nothing
#' @export
remote_install.packages <- function(
  github_name = NA,
  package_name,
  must_sleep = TRUE,
  account = "p274829",
  session = NA
) {

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  jap::upload_jap_scripts(
    account = account,
    session = session
  )

  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
    "chmod +x ", file.path("jap_scripts", "install_packages.bash")
  ))

  if (is.na(github_name)) {
    pkg <- package_name
  } else {
    pkg <- paste0(github_name, "/", package_name)
  }
  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "./",
      file.path("jap_scripts", "install_packages.bash"),
      " ",
      "'",
      pkg,
      "'"
    )
  )
  if (must_sleep == TRUE) {
    ssh::ssh_exec_wait(session = session, command = "sleep 10")
  }

  jap::remote_dir.remove(dir = "jap_scripts", session = session)
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  return()
}

#' Convert list to string
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return A fun_argument string
#' @export
args_2_string <- function(
  args
) {
  varname <- function(v1) {
    deparse(substitute(v1))
  }
  i <- 1
  string <- NULL
  for (i in seq_along(args)) {
    name <- names(args)[i]
    value <- unlist(args[i])
    if (is.character(value)) {
      if (grepl(x = value, pattern = "/")) {
        out <- jap::path_2_file.path(value)

      }
    } else if (length(value) > 1) {
      out <- paste0(
        name,
        " = ",
        "c(",
        paste0(value, collapse = ", "),
        ")"
      )
    } else {
      out <- paste0(
        name,
        " = ",
        value
      )
    }
    if (i > 1) {
      string <- paste0(string, ", ", out)
    } else {
      string <- paste0(string, out)
    }
  }
  string
}
