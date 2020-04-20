#' Returns your peregrine account
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
your_account <- function() {
  rprof_path <- usethis:::scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")
  name <- "YOUR_PEREGRINE_ACCOUNT="
  y <- jap::my_try_catch(unlist(read.table(rprof_path)))
  if (is.null(y$warning) & is.null(y$error)) {
    y1 <- as.character(y$value)
    y2 <- y1[stringr::str_detect(y1, name)]
    if (length(y2) == 1) {
      testit::assert(length(y2) == 1)
      out <- gsub(y2, pattern = name, replacement = "")
      out <- gsub(out, pattern = "\"", replacement = "")
      if (out != "") {return(out)}
    }
  }

  out <- readline(prompt = "What's your peregrine account?")

  write(
    paste0(name, "\"", out, "\""),
    file = rprof_path,
    append = TRUE
  )
  out
}

#' @title Check if folder exist on cluster
#' @description Check if folder exist on cluster
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
remote_dir.exists <- function(
  dir,
  account = jap::your_account(),
  session = NA
) {
  jap::remote_file.exists(
    file = dir,
    account = jap::your_account(),
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
  account = jap::your_account(),
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
  account = jap::your_account(),
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
  account = jap::your_account(),
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
    command = paste0(
      "ls ",
      file.path("", "home", account, dir)
    )
  ))
  files <- files[-length(files)]

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }

  files
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
  account = jap::your_account(),
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

#' @title Export cluster scripts
#' @author Giovanni Laudanno
#' @description Export cluster scripts
#' @inheritParams default_params_doc
#' @return nothing
#' @export
upload_cluster_scripts <- function(
  project_name = "sls",
  account = jap::your_account(),
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
      if (length(value) > 1) {
        out <- paste0(
          name,
          " = ",
          "c(",
          paste(
            lapply(value, FUN = function(x) jap::path_2_file.path(x)),
            collapse = ", "
          ),
          ")"
        )
      }
      if (length(value) == 1) {
        out <- paste0(
          name,
          " = ",
          paste(
            lapply(value, FUN = function(x) jap::path_2_file.path(x)),
            collapse = ", "
          )
        )
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

#' @title Download the results to the results folder of the project
#' @author Giovanni Laudanno
#' @description Download the results to the results folder of the project
#' @inheritParams default_params_doc
#' @return nothing
#' @export
download_subfolder <- function(
  subfolder = "results",
  projects_folder_name = "Projects",
  disk = "D",
  project_name = "sls",
  delete_on_cluster = FALSE,
  account = jap::your_account(),
  session = NA,
  drive = FALSE
) {

  local_projects_folder <- file.path(paste0(disk, ":"), projects_folder_name)
  remote_projects_folder <- file.path("", "home", account, projects_folder_name)
  local_project_folder <- file.path(local_projects_folder, project_name)

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  jap::create_folder_structure(
    projects_folder_name = projects_folder_name,
    disk = disk,
    project_name = project_name,
    account = account,
    session = session,
    drive = drive
  )

  # download files
  remote_project_folder <- file.path(remote_projects_folder, project_name)
  remote_results_folder <- file.path(remote_project_folder, "results")
  ssh::scp_download(
    session = session,
    files = file.path(remote_project_folder, subfolder, "*"),
    to = file.path(local_project_folder, subfolder),
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

  if (drive == TRUE) {
    drive_projects_folder <- basename(local_projects_folder)
    drive_project_folder <- file.path(drive_projects_folder, project_name)
    local_subfolder <- file.path(local_project_folder, subfolder)
    drive_subfolder <- file.path(drive_project_folder, subfolder)
    files <- list.files(local_subfolder)

    already_present <- jap::drive_list.files(
      dir = file.path(
        projects_folder_name,
        project_name,
        subfolder
      )
    )
    already_present <- unlist(already_present[, 1])
    files <- files[!(files %in% already_present)]
    for (file in files) {
      googledrive::drive_upload(
        media = file.path(local_subfolder, file),
        name = file,
        path = drive_subfolder
      )
    }
  }
  return()
}

#' Download the entire project folder
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
download_project_folder <- function(
  projects_folder_name = "Projects",
  disk = "D",
  project_name = "sls",
  delete_on_cluster = FALSE,
  account = jap::your_account(),
  session = NA,
  drive = FALSE
) {

  local_projects_folder <- file.path(paste0(disk, ":"), projects_folder_name)
  remote_projects_folder <- file.path("", "home", account, projects_folder_name)

  subfolders <- jap::folder_structure()
  for (subfolder in subfolders) {
    jap::download_subfolder(
      subfolder = subfolder,
      local_projects_folder = local_projects_folder,
      remote_projects_folder = remote_projects_folder,
      project_name = project_name,
      account = account,
      session = session,
      drive = drive
    )
  }
}

#' @title Get peregrine cluster address
#' @description Get peregrine cluster address
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return peregrine cluster address
#' @export
get_cluster_address <- function(account = jap::your_account()) {
  if (account == "cyrus" || account == "Cyrus" || account == "Cy" || account == "cy") { # nolint
    account <- "p257011"
  }
  if (account == "giovanni" || account == "Giovanni" || account == "Gio" || account == "gio") { # nolint
    account <- "p274829"
  }
  if (account == "pedro" || account == "Pedro") { # nolint
    account <- "p282067"
  }
  cluster_address <- paste0(account, "@peregrine.hpc.rug.nl")
  cluster_address
}

#' @title Open session
#' @description Open a session for a given account
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return the session
#' @export
open_session <- function(account = jap::your_account()) {
  cluster_address <- jap::get_cluster_address(account = account)
  session <- ssh::ssh_connect(cluster_address)
  session
}

#' @title Close session
#' @description Close a session for a given account
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return nothing
#' @export
close_session <- function(session) {
  ssh::ssh_disconnect(session); gc()
}

#' @title Check jobs on cluster
#' @author Giovanni Laudanno, Pedro Neves
#' @description Check jobs on cluster
#' @inheritParams default_params_doc
#' @return list with job ids, job info and sshare
#' @export
check_jobs <- function(
  account = jap::your_account(),
  session = NA
) {

  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  jobs <- utils::capture.output(ssh::ssh_exec_wait(session = session, command = "squeue -u $USER --long"))
  fun1 <- function(x) {
    x1 <- strsplit(x, " ")[[1]]
    x2 <- x1[which(x1 != "")]
    x2
  }
  fun2 <- function(y) {
    y0 <- y[-c(1, length(y))]
    y1 <- lapply(X = y0, FUN = fun1)

    if (length(y1[-1]) == 0) {
      y2 <- data.frame(
        matrix(NA, ncol = length(y1[[1]]), nrow = 0
        )
      )
    } else {
      y2 <- data.frame(
        matrix(unlist(y1[-1]), ncol = length(y1[[1]]), byrow = TRUE),
        stringsAsFactors = FALSE
      )
    }
    colnames(y2) <- y1[[1]]
    y2
  }
  job_info <- fun2(jobs)
  job_ids <- job_info$JOBID
  job_names <- job_info$NAME
  job_states <- table(job_info$STATE)
  job_partitions <- table(job_info$PARTITION)

  sshare_output <- utils::capture.output(ssh::ssh_exec_wait(
    session = session,
    command = "sshare -u $USER"
  ))
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  list(
    job_ids = job_ids,
    job_names = job_names,
    job_states = job_states,
    job_partitions = job_partitions,
    sshare_output = sshare_output,
    jobs = job_info
  )
}

#' @title Close jobs on cluster
#' @description Close jobs on cluster
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return list with job ids, job info and sshare (all empty)
#' @export
close_jobs <- function(account = jap::your_account()) {

  session <- jap::open_session(account = account)

  ssh::ssh_exec_wait(
    session = session,
    command = "scancel --user=$USER --partition=gelifes && scancel --user=$USER --partition=regular" # nolint indeed long command
  )

  jap::close_session(session = session)
  jap::check_jobs(account = account)
}

#' @title Check if session is open or not
#' @description Check if session is open
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return TRUE or FALSE
#' @export
is_session_open <- function(
  session
) {
  out <- jap::my_try_catch(ssh::ssh_session_info(session))
  if (!is.null(out$value)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}
