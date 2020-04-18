# rm(list = ls())
# Basic Settings
library(ssh); library(googledrive)
drive <- TRUE
account <- "p274829" # account <- "p282067"
github_name <- "Neves-P"
project_name <- "DAISIErobustness"
projects_folder_name <- "Projects"
remote_projects_folder <- file.path("", "home", account, projects_folder_name)
remote_project_folder <- file.path(remote_projects_folder, project_name)

# Project Settings
jap::install_package(package_name = project_name, github_name = github_name)
library(project_name, character.only = TRUE)
function_name <- "DAISIErobustness::oceanic_sim"

# Open Session
session <- jap::open_session(account = account)

# Delete?
#jap::delete_folder_structure(account = account, projects_folder_name = projects_folder_name, session = session, drive = TRUE)

# Create remote folder structure for the project
jap::create_folder_structure(
  projects_folder_name = projects_folder_name,
  project_name = project_name,
  account = account,
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

# Create params for the experiment
max_sims <- 4
params <- expand.grid(
  timeval = 3,
  lac = c(0.3, 0.6),
  mu = c(0.1, 0.2),
  K = 10,
  gam = 0.001,
  laa = 1,
  seed = 1
)

i <- 1
while (i <= nrow(params)) {

  # Select the i-th parsetting
  pars <- params[
    i,
    DAISIErobustness::load_param_space(param_space_name = "oceanic_ontogeny")
    ]

  check <- jap::check_jobs(session = session)
  n_jobs <- length(check$job_ids)
  cat("Pars are", unlist(pars), "\nThere are", n_jobs, "jobs left\n")

  if (n_jobs < (100)) { #send new jobs only if max 100 jobs are already running

    # Download partial results
    jap::download_subfolder(
      subfolder = "results",
      projects_folder_name = projects_folder_name,
      project_name = project_name,
      account = account,
      session = session,
      drive = drive
    )

    # Create the argument string
    fun_arguments <- paste0(
      "seed = ",
      seed,
      ", ",
      "sim_pars = ",
      "c(",
      paste0(pars, collapse = ", "),
      ")",
      ", ",
      ", ",
      "totaltime = ",
      ", ",
      "loglik_functions = ",
      "DAISIErobustness::oceanic_sim()",
      ", ",
      "project_folder = ",
      jap::path_2_file.path(remote_project_folder)
    )

    # Run the main function
    jap::run_on_cluster(
      github_name = github_name,
      package_name = project_name,
      function_name = function_name,
      account = account,
      session = session,
      fun_arguments = fun_arguments
    )
    i <- i + 1
  } else {
    Sys.sleep(60) # wait 1 min then retry
  }
}

# Close session
jap::close_session(session = session)

