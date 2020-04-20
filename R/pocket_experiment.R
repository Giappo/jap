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
  for (filename in filenames) {
    url <- paste0(
      "https://raw.githubusercontent.com/Giappo/jap/master/cluster_scripts/",
      filename
    )
    utils::download.file(url, destfile = file.path(tempfolder, filename))
  }

  rstudioapi::jobRunScript()
  return()
}
