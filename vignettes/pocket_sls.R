# Basic Setting
library(ssh)
account <- "p274829"
project_name <- "sls"
local_projects_folder <- "D:/Projects"
remote_projects_folder <- file.path("/home", account, "Projects")
remote_project_folder <- file.path(remote_projects_folder, project_name)
partition <- "gelifes"
library(project_name, character.only = TRUE)

# Open Session
session <- jap::open_session(account = account)

# Create remote folder structure for the project
jap::create_folder_structure(
  local_projects_folder = local_projects_folder,
  remote_projects_folder = remote_projects_folder,
  project_name = project_name,
  account = account,
  session = session
)

# Create params for the experiment
max_sims <- 20
params <- expand.grid(
  lambda_m = c(0.3, 0.6),
  mu_m = c(0.1, 0.2),
  lambda_s = 0.8,
  mu_s = 0.1,
  t_0_1 = 8,
  t_0_2 = 5,
  cond = 1,
  seed = 1:max_sims
)

i <- 1
while (i <= nrow(params)) {

  # Select the i-th parsetting
  pars <- params[i, sls::get_param_names()]
  cond <- params[i, "cond"]
  seed <- params[i, "seed"]
  t_0_1 <- params[i, "t_0_1"]
  t_0_2 <- params[i, "t_0_2"]

  check <- jap::check_jobs(session = session)
  n_jobs <- length(check$job_ids)
  cat("Pars are", unlist(pars), "\nThere are", n_jobs, "jobs left\n")

  if (n_jobs < (max_sims * 0.1)) { #send new jobs only if max 100 jobs are already running

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
      "cond = ",
      cond,
      ", ",
      "crown_age = ",
      t_0_1,
      ", ",
      "shift_time = ",
      t_0_2,
      ", ",
      "loglik_functions = ",
      "sls::sls_logliks_experiment()",
      ", ",
      "project_folder = ",
      jap::path_2_file.path(remote_project_folder)
    )

    # Run the main function
    jap::run_on_cluster(
      github_name = "Giappo",
      package_name = project_name,
      function_name = "sls_main",
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
