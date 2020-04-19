% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/new_ssh_functions.R
\name{download_project_folder}
\alias{download_project_folder}
\title{Download the entire project folder}
\usage{
download_project_folder(
  projects_folder_name = "Projects",
  disk = "D",
  project_name = "sls",
  delete_on_cluster = FALSE,
  account = "p274829",
  session = NA,
  drive = FALSE
)
}
\arguments{
\item{account}{a peregrine account}

\item{session}{a ssh session}
}
\value{
nothing
}
\description{
Download the entire project folder
}
\author{
Giovanni Laudanno
}