#' This function does nothing. It is intended to inherit is parameters'
#' documentation.
#' @param account a peregrine account
#' @param age the age of the phylogeny
#' @param cluster_folder main folder on the cluster. It can be either 'home'
#'  or 'data'
#' @param delete_on_cluster do you want to delete the files from the cluster
#'  after the download?
#' @param dir a directory
#' @param drive do you want to use google drive to store the data of your
#'  prokects? It can be either TRUE or FALSE
#' @param file a file
#' @param github_name the github account name where the repo is
#' @param github_repo a github repository
#' @param home_dir path to the home directory. On windows usually is
#'  a disk like C or D. On mac is always ~.
#' @param lambda speciation rate
#' @param mu extinction rate
#' @param message a message to be print
#' @param projects_folder_name the name you want to give to the folder
#'  containing all your projects
#' @param project_name the name of the project
#' @param session a ssh session
#' @param subfolder a subfolder of the project folder
#' @param t time
#' @param verbose choose if you want to print the output or not
#' @author Documentation by Giovanni Laudanno,
#' @note This is an internal function, so it should be marked with
#'   \code{@noRd}. This is not done, as this will disallow all
#'   functions to find the documentation parameters
default_params_doc <- function(
  account,
  age,
  session,
  lambda,
  mu,
  projects_folder_name,
  project_name,
  t,
  message,
  verbose
) {
  # Nothing
}
