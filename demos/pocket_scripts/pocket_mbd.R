# rm(list = ls())
# Basic Settings
library(ssh); library(googledrive)
drive <- TRUE
account <- "p274829"
github_name <- "Giappo"
project_name <- "mbd"
projects_folder_name <- "Projects"
remote_projects_folder <- file.path("", "home", account, projects_folder_name)
remote_project_folder <- file.path(remote_projects_folder, project_name)

# Project Settings
jap::install_package(package_name = project_name, github_name = github_name)
library(project_name, character.only = TRUE)
function_name <- "mbd_main"

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
max_sims <- 2
params <- expand.grid(
  lambda = c(0.2, 0.4),
  mu = c(0.05, 0.1),
  nu = c(0.5, 1),
  q = 0.1,
  age = 8,
  cond = 1,
  seed = 1:max_sims
)
loglik_functions <- mbd::mbd_experiment_logliks()
verbose <- TRUE

i <- 1
while (i <= nrow(params)) {

  # Select the i-th parsetting
  seed <- params[i, "seed"]
  sim_pars <- unlist(params[i, mbd::get_param_names()])
  cond <- params[i, "cond"]
  age <- params[i, "age"]

  args <- list(
    seed = seed,
    sim_pars = unlist(sim_pars),
    cond = cond,
    age = age,
    loglik_functions = loglik_functions,
    project_folder = remote_project_folder,
    verbose = verbose
  )

  check <- jap::check_jobs(session = session)
  n_jobs <- length(check$job_ids)
  cat("Pars are", unlist(sim_pars), "\nThere are", n_jobs, "jobs left\n")

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
