# rm(list = ls())
# Basic Settings
library(ssh); library(googledrive)
drive <- TRUE
account <- "p282067" # account <- "p282067"
github_name <- "Neves-P"
project_name <- "DAISIErobustness"
projects_folder_name <- "Projects"
remote_projects_folder <- file.path("", "home", account, projects_folder_name)
remote_project_folder <- file.path(remote_projects_folder, project_name)

# Project Settings
jap::install_package(package_name = project_name, github_name = github_name)
library(project_name, character.only = TRUE)
function_name <- "run_robustness"

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
param_space <- DAISIErobustness::load_param_space(
  param_space_name = "oceanic_ontogeny"
)
while (i <= nrow(param_space)) {

  # Select the i-th parsetting
  args <- list(
    param_space_name = "oceanic_ontogeny",
    param_set = i,
    replicates = 1000,
    save_output = TRUE
  )

  check <- jap::check_jobs(session = session)
  n_jobs <- length(check$job_ids)
  message(
    "Pars are ",
    paste0(names(args), " = ", unlist(args), " | "),
    "\n There are ", n_jobs, " jobs left"
  )

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


    # Run the main function
    jap::run_on_cluster(
      github_name = github_name,
      package_name = project_name,
      function_name = function_name,
      account = account,
      session = session,
      fun_arguments = jap::args_2_string(args = args)
    )
    i <- i + 1
  } else {
    Sys.sleep(60) # wait 1 min then retry
  }
}

# Close session
jap::close_session(session = session)

