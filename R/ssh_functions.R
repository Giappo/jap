#' @title Export cluster scripts
#' @author Giovanni Laudanno
#' @description Export cluster scripts
#' @inheritParams default_params_doc
#' @return nothing
#' @export
upload_bash_scripts <- function(
  project_name,
  account = jap::your_account(),
  session = NA
) {

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  github_folder <- jap::find_github_folder()

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

  # list files
  x <- utils::capture.output(ssh::ssh_exec_wait(
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
  return()
}

#' @title Export cluster scripts
#' @author Giovanni Laudanno
#' @description Export cluster scripts
#' @inheritParams default_params_doc
#' @return nothing
#' @export
upload_jap_scripts <- function(
  account = jap::your_account(),
  jap_branch = "master",
  cluster_folder = jap::default_cluster_folder(),
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
    "install_packages.bash"
  )
  tempfolder <- tempdir()
  for (filename in filenames) {
    url <- paste0(
      "https://raw.githubusercontent.com/Giappo/jap/",
      jap_branch,
      "/cluster_scripts/",
      filename
    )
    utils::download.file(url, destfile = file.path(tempfolder, filename))
  }
  scripts_folder <- tempfolder
  remote_folder <- file.path(
    "",
    cluster_folder,
    account,
    "jap_scripts"
  )
  ssh::ssh_exec_wait(
    session,
    command = paste0("mkdir -p ", remote_folder)
  )

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
  x <- utils::capture.output(ssh::ssh_exec_wait(
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
  # unlink(tempfolder, recursive = TRUE)
  return()
}

#' @title run pirouette example
#' @author Giovanni Laudanno
#' @description NOT WORKING YET
#' @inheritParams default_params_doc
#' @return nothing
#' @export
run_project_on_cluster <- function(
  project_name,
  function_name,
  account = jap::your_account(),
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

  ssh::ssh_exec_wait(
    session = session,
    command = paste0(
      "sbatch ",
      bash_file,
      " ",
      function_name,
      " ",
      fun_arguments
    )
  )

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
  fun_arguments
) {
 # !DO NOT ADD jap:: explicit namespace!
  install_package(
    github_name = github_name,
    package_name = package_name
  )

  stringa <- paste0(
    package_name,
    "::",
    function_name,
    "(",
    fun_arguments,
    ")"
  )
  print(stringa)
  eval(str2expression(stringa))
}

#' @title run a function from file
#' @author Giovanni Laudanno
#' @description run a function from file
#' @param args_file the file containing the parameters
#' @return nothing
#' @export
run_function_from_file <- function(
  args_file
) {
  github_name <- NULL; rm(github_name) # R check workaround
  package_name <- NULL; rm(package_name) # R check workaround
  function_name <- NULL; rm(function_name) # R check workaround
  fun_arguments <- NULL; rm(fun_arguments) # R check workaround

  load(args_file)
  # !DO NOT ADD jap:: explicit namespace!
  out <- run_function(
    github_name = github_name,
    package_name = package_name,
    function_name = function_name,
    fun_arguments = fun_arguments
  )
  out
}

#' @title Run a function on cluster
#' @author Giovanni Laudanno
#' @description Run a function on cluster
#' @inheritParams default_params_doc
#' @return nothing
#' @export
run_on_cluster <- function(
  github_name = NA,
  package_name,
  function_name,
  fun_arguments,
  run_name = "default",
  projects_folder_name = jap::default_projects_folder(),
  cluster_folder = jap::default_cluster_folder(),
  cluster_partition = "gelifes",
  home_dir = jap::default_home_dir(),
  account = jap::your_account(),
  my_email = jap::default_my_email(),
  drive = jap::default_drive_choice(),
  jap_branch = "master",
  session = NA
) {
  project_name <- package_name

  if (run_name == "default") {
    run_name <- paste0(
      function_name,
      "-",
      gsub(
        x = toString(unlist(
          fun_arguments
        )),
        pattern = " ",
        replacement = ""
      )
    )
    run_name <- gsub(x = run_name, pattern = "::", replacement = "-")
    run_name <- gsub(x = run_name, pattern = ":", replacement = "")
    run_name <- gsub(x = run_name, pattern = "\"", replacement = "")
    run_name <- gsub(x = run_name, pattern = ",", replacement = "-")
    run_name <- gsub(x = run_name, pattern = "=", replacement = "-")
    run_name <- gsub(x = run_name, pattern = "file.path", replacement = "")
    run_name <- gsub(x = run_name, pattern = "[(]", replacement = "[")
    run_name <- gsub(x = run_name, pattern = "[)]", replacement = "]")
    run_name <- substr(x = run_name, start = 1, stop = 2000)
  }

  if (is.list(fun_arguments)) {
    fun_arguments <- jap::args_2_string(fun_arguments)
  }

  while (grepl(x = fun_arguments, pattern = " ")) {
    fun_arguments <- gsub(x = fun_arguments, pattern = " ", replacement = "")
  }

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  # create folder structure
  if (!jap::remote_dir.exists(
    jap::get_remote_function_folder(
      function_name = function_name,
      project_name = project_name,
      projects_folder_name = projects_folder_name,
      account = account,
      cluster_folder = cluster_folder
    )
  )) {
    jap::create_folder_structure(
      account = account,
      projects_folder_name = projects_folder_name,
      home_dir = home_dir,
      cluster_folder = cluster_folder,
      project_name = project_name,
      function_name = function_name,
      drive = drive,
      session = session
    )
  }

  # upload scripts
  jap::upload_jap_scripts(
    cluster_folder = cluster_folder,
    jap_branch = jap_branch,
    account = account,
    session = session
  )
  jap_folder <- file.path(
    "",
    cluster_folder,
    account,
    "jap_scripts"
  )
  bash_file <- file.path(
    jap_folder,
    "run_on_cluster.bash"
  )

  # mandrakata
  tempfolder <- tempdir()
  args_list <- list(
    github_name = github_name,
    package_name = package_name,
    function_name = function_name,
    fun_arguments = fun_arguments
  )
  fun_list <- list(
    run_function_from_file =
      eval(parse(text = paste0("run_function_from_file <- function(args_file)", c(body(jap::run_function_from_file))))),
    run_function =
      eval(parse(text = paste0("run_function <- function(github_name = NA, package_name, function_name, fun_arguments)", c(body(jap::run_function))))),
    install_package =
      eval(parse(text = paste0("install_package <- function(package_name, github_name = NA)", c(body(jap::install_package)))))
  )

  # give name to run and args file
  if (is.na(run_name)) {
    args_filename <- paste0(stringi::stri_rand_strings(1, 12), ".RData")
  } else {
    args_filename <- paste0(run_name, ".RData")
  }
  args_file <- file.path(tempfolder, args_filename)
  save(args_list, file = args_file)
  ssh::scp_upload(
    session = session,
    files = args_file,
    to = jap_folder
  )
  fun_filename <- paste0(stringi::stri_rand_strings(1, 12), ".RData")
  fun_file <- file.path(tempfolder, fun_filename)
  save(fun_list, file = fun_file)
  ssh::scp_upload(
    session = session,
    files = fun_file,
    to = jap_folder
  )

  # execute
  command <- paste0(
    "sbatch ",
    bash_file,
    " ",
    args_filename, #1
    " ",
    fun_filename, #2
    " ",
    my_email, #3
    " ",
    cluster_partition, #4
    " ",
    cluster_folder, #5
    " ",
    account, #6
    " ",
    projects_folder_name, #7
    " ",
    package_name, #8
    " ",
    function_name #9
  )
  cat(command, "\n")
  x <- utils::capture.output(ssh::ssh_exec_wait(
    session = session,
    command = command
  ))

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }

  return(x)
}
