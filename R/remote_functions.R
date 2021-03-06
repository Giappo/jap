#' Returns your peregrine account
#' @author Giovanni Laudanno
#' @return nothing
#' @export
your_account <- function() {
  rprof_path <- usethis:::scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")
  name <- "JAP_PEREGRINE_ACCOUNT="
  y <- jap::my_try_catch(unlist(utils::read.table(rprof_path)))
  if (is.null(y$warning) & is.null(y$error)) {
    y1 <- as.character(y$value)
    y2 <- y1[stringr::str_detect(y1, name)]
    if (length(y2) == 1) {
      testit::assert(length(y2) == 1)
      out <- gsub(y2, pattern = name, replacement = "")
      out <- gsub(out, pattern = "\"", replacement = "")
      if (out != "") {return(out)}
    }
    if (length(y2) > 1) {
      write(
        y1[!(y1 %in% y2)],
        file = rprof_path,
        append = FALSE
      )
    }
  }

  valid_account <- FALSE
  while (!valid_account) {
    out <- readline(
      prompt = "What's your peregrine account (p-number or s-number)?\n"
    )
    first <- substr(out, start = 1, stop = 1)
    numbers <- as.numeric(substr(out, start = 2, stop = 1e3))
    n_digits <- floor(log10(abs(numbers))) + 1
    if (
      (first != "p" && first != "s") ||
      (numbers %% 1 != 0) ||
      n_digits != 6
    ) {
      cat("Please select a valid peregrine account.\n")
    } else {
      valid_account <- TRUE
    }
  }

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

  files <- utils::capture.output(ssh::ssh_exec_wait(
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
  full.names = TRUE,
  session = NA
) {
  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  # list files
  files <- utils::capture.output(ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "ls ",
      dir
    )
  ))
  files <- files[-length(files)]

  if (full.names) {
    files <- file.path(dir, files)
  }

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }

  files
}

#' @title Install packages for a given project
#' @description Install packages for a given project
#' @inheritParams default_params_doc
#' @param must_sleep force the function to wait after instaling
#'  the package
#' @author Giovanni Laudanno
#' @return nothing
#' @export
remote_install.packages <- function(
  github_name = NA,
  package_name,
  must_sleep = TRUE,
  cluster_folder = jap::default_cluster_folder(),
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
    cluster_folder = cluster_folder,
    account = account,
    session = session
  )
  jap_folder <- file.path(
    "",
    cluster_folder,
    account,
    "jap_scripts"
  )

  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "chmod +rwx ", jap_folder
    )
  )
  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "chmod +rwx ", file.path(jap_folder, "install_packages.bash")
    )
  )

  if (is.na(github_name)) {
    pkg <- package_name
  } else {
    pkg <- paste0(github_name, "/", package_name)
  }
  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      # ".",
      file.path(jap_folder, "install_packages.bash"),
      " ",
      "'",
      pkg,
      "'"
    )
  )
  if (must_sleep == TRUE) {
    ssh::ssh_exec_wait(session = session, command = "sleep 10")
  }

  jap::remote_dir.remove(dir = jap_folder, session = session) # does not work
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  return()
}

#' @title Upload cluster scripts
#'
#' Upload `.sh` and `.bash` files from local `project_name/cluster_scripts/` to
#' the corresponding folder on the cluster. If `drive = TRUE`, the scripts also
#' be uploaded to the correspoonding drive folder.
#'
#' @author Giovanni Laudanno
#' @description Export cluster scripts
#' @inheritParams default_params_doc
#' @return nothing
#' @export
upload_cluster_scripts <- function(
  project_name,
  account = jap::your_account(),
  projects_folder_name = jap::default_projects_folder(),
  cluster_folder = jap::default_cluster_folder(),
  home_dir = jap::default_home_dir(),
  drive = jap::default_drive_choice(),
  session = NA
) {

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  # folder structure
  local_project_folder <- jap::get_local_project_folder(project_name)
  remote_project_folder <- jap::get_remote_project_folder(account = account, project_name = project_name)
  local_cluster_folder <- file.path(local_project_folder, "cluster_scripts")
  remote_cluster_folder <- file.path(remote_project_folder, "cluster_scripts")
  if (
    !dir.exists(local_cluster_folder) ||
    !jap::remote_dir.exists(
      dir = remote_project_folder,
      account = account,
      session = session
    )
  ) {
    jap::create_folder_structure(
      account = account,
      projects_folder_name = projects_folder_name,
      home_dir = home_dir,
      cluster_folder = cluster_folder,
      project_name = project_name,
      drive = drive,
      session = session
    )
  }

  ssh::ssh_exec_wait(session, command = paste0("mkdir -p ", project_name))

  files <- unique(c(
    list.files(local_cluster_folder, pattern = ".bash"),
    list.files(local_cluster_folder, pattern = ".sh")
  ))

  if (length(files) > 0) {
    ssh::scp_upload(
      session = session,
      files = paste0(
        local_cluster_folder,
        "/",
        files
      ),
      to = remote_cluster_folder
    )
    if (drive == TRUE) {
      googledrive::drive_upload(
        media = paste0(
          local_cluster_folder,
          "/",
          files
        ),
        path = paste0(
          projects_folder_name, "/",
          project_name, "/",
          "cluster_scripts/"
        ),
        overwrite = TRUE
      )
    }
  }


  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  return()
}

#' Convert list to string
#' @param args a list of function arguments
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
  function_name = NA,
  project_name = NA,
  projects_folder_name = jap::default_projects_folder(),
  account = jap::your_account(),
  cluster_folder = jap::default_cluster_folder(),
  home_dir = jap::default_home_dir(),
  delete_on_cluster = FALSE,
  drive = jap::default_drive_choice(),
  session = NA
) {

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  jap::create_folder_structure(
    function_name = function_name,
    project_name = project_name,
    account = account,
    projects_folder_name = projects_folder_name,
    cluster_folder = cluster_folder,
    home_dir = home_dir,
    session = session,
    drive = drive
  )

  # download files
  ## local
  local_projects_folder <- file.path(home_dir, projects_folder_name)
  local_project_folder <- file.path(local_projects_folder, project_name)
  local_function_folder <- file.path(local_project_folder, function_name)
  local_subfolder <- file.path(local_function_folder, subfolder)

  ## peregrine
  remote_projects_folder <- file.path(
    "",
    cluster_folder,
    account,
    projects_folder_name
  )
  remote_project_folder <- file.path(remote_projects_folder, project_name)
  remote_function_folder <- file.path(remote_project_folder, function_name)
  remote_subfolder <- file.path(remote_function_folder, subfolder)

  ssh::scp_download(
    session = session,
    files = file.path(remote_subfolder, "*"),
    to = local_subfolder,
    verbose = TRUE
  )

  if (delete_on_cluster) {
    ssh::ssh_exec_wait(
      session = session,
      command = paste0(
        "rm -rfv ", file.path(remote_subfolder, "*")
      )
    )
  }

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }

  if (drive == TRUE) {
    drive_projects_folder <- basename(local_projects_folder)
    drive_project_folder <- file.path(drive_projects_folder, project_name)
    drive_function_folder <- file.path(drive_project_folder, function_name)
    drive_subfolder <- file.path(drive_function_folder, subfolder)
    files <- list.files(local_subfolder)

    already_present <- jap::drive_list.files(
      dir = drive_subfolder
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
  function_name = NA,
  project_name = NA,
  projects_folder_name = jap::default_projects_folder(),
  account = jap::your_account(),
  cluster_folder = jap::default_cluster_folder(),
  home_dir = jap::default_home_dir(),
  delete_on_cluster = FALSE,
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
  remote_project_folder <- jap::get_remote_project_folder(
      project_name = project_name,
      projects_folder_name = projects_folder_name,
      account = account,
      cluster_folder = cluster_folder
    )
  function_names <- remote_list.files(dir = remote_project_folder, full.names = FALSE)
  function_names <- function_names[function_names != "cluster_scripts"]

  subfolders <- jap::folder_structure()
  for (function_name in function_names) {
    for (subfolder in subfolders) {
      jap::download_subfolder(
        subfolder = subfolder,
        function_name = function_name,
        project_name = project_name,
        projects_folder_name = projects_folder_name,
        account = account,
        cluster_folder = cluster_folder,
        home_dir = home_dir,
        delete_on_cluster = delete_on_cluster,
        session = session,
        drive = drive
      )
    }
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
