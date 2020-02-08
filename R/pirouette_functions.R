#' @title run pirouette example
#' @author Giovanni Laudanno
#' @description run pirouette example
#' @inheritParams default_params_doc
#' @return nothing
#' @export
run_pirouette_example <- function(
  example_no,
  account = "p274829",
  session = NA,
  gl = TRUE
) {

  jap::upload_jap_scripts(account = account)

  # open session
  new_session <- FALSE
  if (!jap::is_session_open(session = session)) {
    new_session <- TRUE
    session <- jap::open_session(account = account)
  }

  if (gl == TRUE) {
    bash_file <- file.path(
      "jap_scripts",
      "run_pir_example_gl.bash"
    )
  } else {
    bash_file <- file.path(
      "jap_scripts",
      "run_pir_example.bash"
    )
  }

  ssh::ssh_exec_wait(session = session, command = paste0(
    "sbatch ",
    bash_file,
    " ",
    example_no
  ))

  if (new_session == TRUE) {
    jap::close_session(session = session)
  }
  return()
}
