#' @title Get peregrine cluster address
#' @description Get peregrine cluster address
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return peregrine cluster address
#' @export
get_cluster_address <- function(account = "p274829") {
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
open_session <- function(account = "p274829") {
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
  account = "p274829",
  session = NA
) {

  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  jobs <- utils::capture.output(ssh::ssh_exec_wait(session = session, command = "squeue -u $USER --long"))
  if ((length(jobs) - 1) >= 3) {
    job_ids <- job_names <- c()
    for (i in 3:(length(jobs) - 1)) {
      job_id_i <- substr(jobs[i], start = 12, stop = 18)
      job_ids <- c(job_ids, job_id_i)
      job_info <- utils::capture.output(ssh::ssh_exec_wait(
        session = session,
        command = paste("jobinfo", job_id_i)
      ))
      job_name_i <- substr(job_info[1], start = 23, stop = nchar(job_info[1]))
      job_names <- c(job_names, job_name_i)
    }
    job_ids <- as.numeric(job_ids)
  } else {
    job_ids <- job_names <- NULL
  }
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
    sshare_output = sshare_output,
    jobs = jobs
  )
}

#' @title Close jobs on cluster
#' @description Close jobs on cluster
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return list with job ids, job info and sshare (all empty)
#' @export
close_jobs <- function(account = "p274829") {

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

#' @title Export cluster scripts
#' @author Giovanni Laudanno
#' @description Export cluster scripts
#' @inheritParams default_params_doc
#' @return nothing
#' @export
upload_bash_scripts <- function(
  project_name,
  account = "p274829",
  session = NA
) {

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  # test git folder
  substr_right <- function(x, n){
    substr(x, nchar(x) - n + 1, nchar(x))
  }

  current_folder <- getwd()
  github_folder <- dirname(current_folder)
  if (!grepl(x = substr_right(github_folder, 8), pattern = "Githubs")) {
    stop("Github folder has not been correctly identified!")
  }

  # project specific scripts
  project_folder <- file.path(github_folder, project_name)
  scripts_folder <- file.path(project_folder, "scripts")
  if (!dir.exists(scripts_folder)) {
    scripts_folder <- file.path(project_folder, "cluster_scripts")
  }
  remote_folder <- file.path(project_name)
  ssh::ssh_exec_wait(session, command = paste0("mkdir -p ", project_name))

  system.time(
    ssh::scp_upload(
      session = session,
      files = paste0(
        scripts_folder,
        "/",
        list.files(scripts_folder, pattern = ".bash")
      ),
      to = remote_folder
    )
  )

  # jap scripts
  project_folder <- file.path(github_folder, "jap")
  scripts_folder <- file.path(project_folder, "scripts")
  if (!dir.exists(scripts_folder)) {
    scripts_folder <- file.path(project_folder, "cluster_scripts")
  }
  remote_folder <- file.path(project_name)
  ssh::ssh_exec_wait(session, command = paste0("mkdir -p ", project_name))

  system.time(
    ssh::scp_upload(
      session = session,
      files = paste0(
        scripts_folder,
        "/",
        list.files(scripts_folder, pattern = ".bash")
      ),
      to = remote_folder
    )
  )

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
upload_jap_scripts <- function(
  account = "p274829",
  session = NA
) {

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  # jap scripts
  filenames <- c(
    "run_on_cluster.bash",
    "run_pir_example.bash",
    "run_pir_example_gl.bash"
  )
  tempfolder <- tempdir()
  for (filename in filenames) {
    url <- paste0(
      "https://raw.githubusercontent.com/Giappo/jap/master/cluster_scripts/",
      filename
    )
    utils::download.file(url, destfile = file.path(tempfolder, filename))
  }
  scripts_folder <- tempfolder
  remote_folder <- "jap_scripts"
  ssh::ssh_exec_wait(session, command = paste0("mkdir -p ", remote_folder))

  ssh::scp_upload(
    session = session,
    files = paste0(
      scripts_folder,
      "/",
      list.files(scripts_folder, pattern = ".bash")
    ),
    to = remote_folder
  )

  # list files
  x <- capture.output(ssh::ssh_exec_wait(
    session = session,
    command = paste0("ls ", remote_folder)
  ))
  files <- paste0(
    remote_folder, "/",
    x[grepl("*.bash", x) | grepl("*.sh", x)]
  )

  # fix line breaks
  for (file in files) {
    ssh::ssh_exec_wait(
      session = session,
      command = paste0("sed -i 's/\r$//' ", file)
    )
  }

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  unlink(tempfolder, recursive = TRUE)
  return()
}

#' List all GitHub projects
#' @author Giovanni Laudanno
#' @inheritParams default_params_doc
#' @return nothing
#' @export
list_projects <- function() {
  current_folder <- getwd()
  github_folder <- dirname(current_folder)
  if (!grepl(x = substr_right(github_folder, 8), pattern = "Githubs")) {
    stop("Github folder has not been correctly identified!")
  }
  list.files(github_folder)
}

#' Get function list
#' @author Giovanni Laudanno
#' @return function list
#' @export
get_function_list <- function(
  project_name,
  my_github = "Giappo"
) {

  devtools::install_github(
    paste0(my_github, "/", project_name)
  )
  library(project_name, character.only = T)

  fun_list <- ls(paste0("package:", project_name)) # nolint internal function
  err_funs <- fun_list[sapply(
    fun_list, function(x)
      any(grepl("errors", x))
  )]
  err_funs
}

#' @title run pirouette example
#' @author Giovanni Laudanno
#' @description run pirouette example
#' @inheritParams default_params_doc
#' @return nothing
#' @export
run_on_cluster <- function(
  github_name = NA,
  package_name,
  function_name,
  fun_arguments,
  account = "p274829",
  session = NA
) {

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  # escape characters
  fun_arguments <- gsub(x = fun_arguments, pattern = "=", replacement = paste0("\\="))
  fun_arguments <- gsub(x = fun_arguments, pattern = "(", replacement = paste0("\\("))
  fun_arguments <- gsub(x = fun_arguments, pattern = ")", replacement = paste0("\\)"))

  jap::upload_jap_scripts(account = account, session = session)
  jap_folder <- "jap_scripts"

  bash_file <- file.path(
    jap_folder,
    "run_on_cluster.bash"
  )

  x <- utils::capture.output(ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "sbatch ",
      bash_file,
      " ",
      "\"", github_name, "\"",
      " ",
      "\"", package_name, "\"",
      " ",
      "\"", function_name, "\"",
      " ",
      "\"", fun_arguments, "\""
    )
  ))

  # ssh::ssh_exec_wait(session = session, command = "sleep 5")
  # ssh::ssh_exec_wait(session = session, command = paste0(
  #   "rm -r ", jap_folder
  # ))

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }

  return(x)
}

#' @title run pirouette example
#' @author Giovanni Laudanno
#' @description run pirouette example
#' @inheritParams default_params_doc
#' @return nothing
#' @export
run_project_on_cluster <- function(
  project_name,
  function_name,
  account = "p274829",
  session = NA,
  fun_arguments
) {

  if (!(function_name %in% jap::get_function_list(project_name))) {
    stop("This is not a function you can call")
  }

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  jap::upload_bash_scripts(
    project_name = project_name,
    account = account,
    session = session
  )

  bash_file <- file.path(
    project_name,
    "run_project_on_cluster.bash"
  )

  ssh::ssh_exec_wait(session = session, command = paste0(
    "sbatch ",
    bash_file,
    " ",
    function_name,
    " ",
    fun_arguments
  ))

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  return()
}

#' @title run a function
#' @author Giovanni Laudanno
#' @description run a function
#' @inheritParams default_params_doc
#' @return nothing
#' @export
run_function <- function(
  github_name = NA,
  package_name,
  function_name,
  arguments
) {

  call_me_maybe <- function(listOfCharArgs) {
    CharArgs = unlist(listOfCharArgs)
    if(is.null(CharArgs)) return(alist())
    .out = eval(parse(
      text = paste0("alist(", paste(parse(text = CharArgs), collapse = ","),")")
    ))
  }

  myArgs <- call_me_maybe(arguments)
  jap::install_package(
    github_name = github_name,
    package_name = package_name
  )
  do.call(eval(function_name), myArgs)
}
