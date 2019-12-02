#' @title Get peregrine cluster address
#' @description Get peregrine cluster address
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return peregrine cluster address
#' @export
get_cluster_address <- function(account = "p274829") {
  if (account == "cyrus" || account == "Cyrus" || account == "Cy" || account == "cy") { # nolint
    account <- "p257011"
  }
  if (account == "giovanni" || account == "Giovanni" || account == "Gio" || account == "gio") { # nolint
    account <- "p274829"
  }
  if (account == "pedro" || account == "Pedro") { # nolint
    account <- "p282067"
  }
  cluster_address <- paste0(account, "@peregrine.hpc.rug.nl")
  cluster_address
}

#' @title Open session
#' @description Open a session for a given account
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return the session
#' @export
open_session <- function(account = "p274829") {
  cluster_address <- jap::get_cluster_address(account = account)
  session <- ssh::ssh_connect(cluster_address)
  session
}

#' @title Close session
#' @description Close a session for a given account
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return nothing
#' @export
close_session <- function(session) {
  ssh::ssh_disconnect(session); gc()
}

#' @title Check jobs on cluster
#' @author Giovanni Laudanno, Pedro Neves
#' @description Check jobs on cluster
#' @inheritParams default_params_doc
#' @return list with job ids, job info and sshare
#' @export
check_jobs <- function(
  account = "p274829",
  session = NA
) {

  new_session <- FALSE
  if (suppressWarnings(is.na(session))) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  jobs <- utils::capture.output(ssh::ssh_exec_wait(session = session, command = "squeue -u $USER --long"))
  if ((length(jobs) - 1) >= 3) {
    job_ids <- job_names <- c()
    for (i in 3:(length(jobs) - 1)) {
      job_id_i <- substr(jobs[i], start = 12, stop = 18)
      job_ids <- c(job_ids, job_id_i)
      job_info <- utils::capture.output(ssh::ssh_exec_wait(
        session = session,
        command = paste("jobinfo", job_id_i)
      ))
      job_name_i <- substr(job_info[1], start = 23, stop = nchar(job_info[1]))
      job_names <- c(job_names, job_name_i)
    }
    job_ids <- as.numeric(job_ids)
  } else {
    job_ids <- job_names <- NULL
  }
  sshare_output <- utils::capture.output(ssh::ssh_exec_wait(
    session = session,
    command = "sshare -u $USER"
  ))
  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  list(
    job_ids = job_ids,
    job_names = job_names,
    sshare_output = sshare_output,
    jobs = jobs
  )
}

#' @title Close jobs on cluster
#' @description Close jobs on cluster
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @return list with job ids, job info and sshare (all empty)
#' @export
close_jobs <- function(account = "p274829") {

  session <- jap::open_session(account = account)

  ssh::ssh_exec_wait(
    session = session,
    command = "scancel --user=$USER --partition=gelifes && scancel --user=$USER --partition=regular" # nolint indeed long command
  )

  jap::close_session(session = session)
  jap::check_jobs(account = account)
}
