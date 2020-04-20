#' Run an experiment on cluster
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return nothing
#' @export
pocket_experiment <- function(
  account = jap::your_account(),
  projects_folder_name = "Projects",
  github_name = "Giappo",
  project_name = "sls",
  function_name = "sls_main",
  params,
  drive = FALSE
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
      "drive"
    )
  )

  filename <- "pocket_script.R"
  url <- paste0(
    "https://raw.githubusercontent.com/Giappo/jap/master/job_scripts/",
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
