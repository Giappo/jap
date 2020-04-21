load("pocket_data.RData")

remote_projects_folder <- file.path(
  "",
  cluster_folder,
  account,
  projects_folder_name
)
remote_project_folder <- file.path(remote_projects_folder, project_name)

# Project Settings
jap::install_package(package_name = project_name, github_name = github_name)
library(project_name, character.only = TRUE)

# Open Session
session <- jap::open_session(account = account)

# Create remote folder structure for the project
jap::create_folder_structure(
  projects_folder_name = projects_folder_name,
  project_name = project_name,
  account = account,
  cluster_folder = cluster_folder,
  session = session,
  drive = drive
)

# Install on cluster
jap::remote_install.packages(
  github_name = github_name,
  package_name = project_name,
  account = account,
  session = session
)

i <- 1
while (i <= length(params)) {

  # Select the i-th parsetting
  args <- params[[i]]

  check <- jap::check_jobs(session = session)
  n_jobs <- length(check$job_ids)
  x <- capture.output(print(Sys.time()))
  cat(x)
  cat("\nThere are", n_jobs, "jobs left\n")

  if (n_jobs < (100)) { #send new jobs only if max 100 jobs are already running

    cat(
      "Function arguments are:\n",
      jap::args_2_string(args),
      "\n"
    )

    # Download partial results
    jap::download_subfolder(
      subfolder = "results",
      projects_folder_name = projects_folder_name,
      project_name = project_name,
      cluster_folder = cluster_folder,
      account = account,
      session = session,
      drive = drive,
      delete_on_cluster = TRUE
    )

    # Run the main function
    jap::run_on_cluster(
      github_name = github_name,
      package_name = project_name,
      function_name = function_name,
      cluster_folder = cluster_folder,
      account = account,
      session = session,
      fun_arguments = args
    )
    i <- i + 1
  } else {
    Sys.sleep(60) # wait 1 min then retry
  }
}

# Download results
while (n_jobs > 0) {
  check <- jap::check_jobs(session = session)
  n_jobs <- length(check$job_ids)
  x <- capture.output(print(Sys.time()))
  cat(x)
  cat("\nThere are", n_jobs, "jobs left\n")

  if (n_jobs > 0) { # download when they are all completed
    Sys.sleep(60) # wait 1 min then retry
  } else {
    jap::download_subfolder(
      subfolder = "results",
      projects_folder_name = projects_folder_name,
      project_name = project_name,
      account = account,
      session = session,
      drive = drive,
      delete_on_cluster = TRUE
    )
  }
}

# Close session
jap::close_session(session = session)

unlink("pocket_data.RData")
