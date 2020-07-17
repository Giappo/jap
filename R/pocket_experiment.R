#' Run an experiment on cluster
#' @inheritParams default_params_doc
#' @param params parameters for the function in the list format
#' @author Giovanni Laudanno
#' @return nothing
#' @export
pocket_experiment <- function(
  account = jap::your_account(),
  projects_folder_name = jap::default_projects_folder(),
  github_name = "Giappo",
  project_name = "sls",
  function_name = "sls_main",
  params,
  cluster_folder = jap::default_cluster_folder(),
  home_dir = jap::default_home_dir(),
  my_email = jap::default_my_email(),
  cluster_partition = "gelifes",
  jap_branch = "master",
  drive = jap::default_drive_choice(),
  delete_on_cluster = TRUE,
  max_n_jobs = 100
) {

  tempfolder <- tempdir()

  save(
    file = file.path(tempfolder, "pocket_data.RData"),
    list = c(
      "account",
      "projects_folder_name",
      "github_name",
      "project_name",
      "function_name",
      "params",
      "cluster_folder",
      "cluster_partition",
      "home_dir",
      "my_email",
      "jap_branch",
      "drive",
      "delete_on_cluster",
      "max_n_jobs"
    )
  )

  filename <- "pocket_script.R"
  url <- paste0(
    "https://raw.githubusercontent.com/Giappo/jap/stable-robustness/job_scripts/",
    filename
  )
  utils::download.file(url, destfile = file.path(tempfolder, filename))
  # list.files(tempfolder)

  rstudioapi::jobRunScript(
    path = file.path(tempfolder, filename),
    name = paste0("pocket_", project_name),
    importEnv = FALSE
  )

  return()
}
