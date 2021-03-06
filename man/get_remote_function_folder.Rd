% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/folder_structure_functions.R
\name{get_remote_function_folder}
\alias{get_remote_function_folder}
\title{Find remote function folder}
\usage{
get_remote_function_folder(
  function_name,
  project_name,
  projects_folder_name = jap::default_projects_folder(),
  account = jap::your_account(),
  cluster_folder = jap::default_cluster_folder()
)
}
\arguments{
\item{function_name}{the name of the function}

\item{project_name}{the name of the project}

\item{projects_folder_name}{the name you want to give to the folder
containing all your projects}

\item{account}{a peregrine account}

\item{cluster_folder}{main folder on the cluster. It can be either 'home'
or 'data'}
}
\description{
Find remote function folder
}
