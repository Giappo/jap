load("pocket_data.RData")

remote_project_folder <- jap::get_remote_project_folder(
  project_name = project_name,
  projects_folder_name = projects_folder_name,
  account = account,
  cluster_folder = cluster_folder
)

# Project Settings
jap::install_package(package_name = project_name, github_name = github_name)
library(project_name, character.only = TRUE)

# Open Session
session <- jap::open_session(account = account)

# Install on cluster
jap::remote_install.packages(
  github_name = github_name,
  package_name = project_name,
  cluster_folder = cluster_folder,
  account = account,
  session = session
)

i <- 1
while (i <= length(params)) {

  # Select the i-th parsetting
  args <- params[[i]]

  check <- jap::check_jobs(session = session)
  n_jobs <- length(check$job_ids)
  x <- utils::capture.output(print(Sys.time()))
  cat(x)
  cat("\nThere are", n_jobs, "jobs left\n")

  if (n_jobs < (max_n_jobs)) { #send new jobs only if max jobs are already running

    cat(
      "Function arguments are:\n",
      jap::args_2_string(args),
      "\n"
    )

    # Download partial results
    # jap::download_subfolder(
    #   subfolder = "results",
    #   function_name = function_name,
    #   projects_folder_name = projects_folder_name,
    #   project_name = project_name,
    #   cluster_folder = cluster_folder,
    #   account = account,
    #   session = session,
    #   drive = drive,
    #   delete_on_cluster = delete_on_cluster
    # )

    # Run the main function
    jap::run_on_cluster(
      github_name = github_name,
      package_name = project_name,
      function_name = function_name,
      fun_arguments = args,
      cluster_folder = cluster_folder,
      cluster_partition = cluster_partition,
      account = account,
      session = session,
      jap_branch = jap_branch
    )
    i <- i + 1
  } else {
    Sys.sleep(60) # wait 1 min then retry
  }
}

# Download results
# while (n_jobs > 0) {
#   check <- jap::check_jobs(session = session)
#   n_jobs <- length(check$job_ids)
#   x <- utils::capture.output(print(Sys.time()))
#   cat(x)
#   cat("\nThere are", n_jobs, "jobs left\n")
#
#   if (n_jobs > 0) { # download when they are all completed
#     Sys.sleep(60) # wait 1 min then retry
#   } else {
#     jap::download_subfolder(
#       subfolder = "results",
#       projects_folder_name = projects_folder_name,
#       project_name = project_name,
#       account = account,
#       session = session,
#       drive = drive,
#       delete_on_cluster = delete_on_cluster
#     )
#   }
# }

# Close session
jap::close_session(session = session)

unlink("pocket_data.RData")
