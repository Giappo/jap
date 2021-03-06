% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ssh_functions.R
\name{run_function}
\alias{run_function}
\title{run a function}
\usage{
run_function(github_name = NA, package_name, function_name, fun_arguments)
}
\arguments{
\item{github_name}{the github account name where the repo is}

\item{package_name}{the name of the package}

\item{function_name}{the name of the function}

\item{fun_arguments}{the arguments of the function passed either as
list or as string (in the format 'arg1 = x, arg2 = y')}
}
\value{
nothing
}
\description{
run a function
}
\author{
Giovanni Laudanno
}
