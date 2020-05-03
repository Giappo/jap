#' Initialize Jap
#' @author Giovanni Laudanno
#' @return nothing
#' @export
initialize_jap <- function() {

  remotes::install_github("tidyverse/googledrive", quiet = TRUE)
  rprof_path <- usethis:::scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")
  # requireNamespace("usethis"); rprof_path <- scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")

  cat("This function will initialize the 'jap' package.\n")
  account <- jap::your_account()
  cat("'jap' will create two folders: one for your Github repos and one for your projects.\n")

  disk <- jap::default_home_dir()
  github_folder <- jap::default_github_folder()
  projects_folder_name <- jap::default_projects_folder()
  cluster_folder <- jap::default_cluster_folder()
  drive <- jap::default_drive_choice()

  jap::create_folder_structure(
    projects_folder_name = projects_folder_name,
    account = account,
    home_dir = disk,
    cluster_folder = cluster_folder,
    project_name = NA,
    drive = drive
  )

  cat("To change your profile information run 'jap::edit_profile()'\n")

  return()
}

#' Fetch the os-dependent default home directory
#' @export
default_home_dir <- function(){
  os <- rappdirs::app_dir()$os
  if (os %in% c("win", "windows")) {

    rprof_path <- usethis:::scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")
    name <- "JAP_DEFAULT_DISK="
    out <- ""
    y <- jap::my_try_catch(unlist(utils::read.table(rprof_path)))
    if (is.null(y$warning) & is.null(y$error)) {
      y1 <- as.character(y$value)
      y2 <- y1[stringr::str_detect(y1, name)]
      if (length(y2) == 1) {
        testit::assert(length(y2) == 1)
        out <- gsub(y2, pattern = name, replacement = "")
        out <- gsub(out, pattern = "\"", replacement = "")
        if (out != "") {return(paste0(out, ":"))}
      }
    }

    while (!(out %in% jap::find_disks())) {
      out <- readline(
        prompt = "What disk do you want to use to host the 'jap' folder structure?\n"
      )
      if (!(out %in% jap::find_disks())) {
        cat("Please select a valid disk.\n")
      }
    }

    write(
      paste0(name, "\"", out, "\""),
      file = rprof_path,
      append = TRUE
    )
    return(paste0(out, ":"))

  } else if (os %in% c("mac", "unix")) {
    return("~")
  } else {
    stop("Sorry, jap is not supported on your OS :/")
  }
}

#' Set the default github folder
#' @export
default_github_folder <- function() {
  disk <- jap::default_home_dir()
  rprof_path <- usethis:::scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")
  name <- "JAP_GITHUB_FOLDER="
  y <- jap::my_try_catch(unlist(utils::read.table(rprof_path)))
  out <- ""
  if (is.null(y$warning) & is.null(y$error)) {
    y1 <- as.character(y$value)
    y2 <- y1[stringr::str_detect(y1, name)]
    if (length(y2) == 1) {
      testit::assert(length(y2) == 1)
      out <- gsub(y2, pattern = name, replacement = "")
      out <- gsub(out, pattern = "\"", replacement = "")
    }
  }
  if (out == "") {
    out <- readline(
      prompt = "How do you want to name the folder for your Github repos?\n"
    )
    write(
      paste0(name, "\"", out, "\""),
      file = rprof_path,
      append = TRUE
    )
  }

  return(out)
}

#' Set the default projects folder
#' @export
default_projects_folder <- function() {
  disk <- jap::default_home_dir()
  rprof_path <- usethis:::scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")
  name <- "JAP_PROJECTS_FOLDER="
  y <- jap::my_try_catch(unlist(utils::read.table(rprof_path)))
  out <- ""
  if (is.null(y$warning) & is.null(y$error)) {
    y1 <- as.character(y$value)
    y2 <- y1[stringr::str_detect(y1, name)]
    if (length(y2) == 1) {
      testit::assert(length(y2) == 1)
      out <- gsub(y2, pattern = name, replacement = "")
      out <- gsub(out, pattern = "\"", replacement = "")
    }
  }
  if (out == "") {
    out <- readline(
      prompt = "How do you want to name the folder for your projects?\n"
    )
    write(
      paste0(name, "\"", out, "\""),
      file = rprof_path,
      append = TRUE
    )
  }

  return(out)
}

#' Set the default cluster folder
#' @export
default_cluster_folder <- function() {
  rprof_path <- usethis:::scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")
  name <- "JAP_CLUSTER_FOLDER="
  y <- jap::my_try_catch(unlist(utils::read.table(rprof_path)))
  out <- ""
  if (is.null(y$warning) & is.null(y$error)) {
    y1 <- as.character(y$value)
    y2 <- y1[stringr::str_detect(y1, name)]
    if (length(y2) == 1) {
      testit::assert(length(y2) == 1)
      out <- gsub(y2, pattern = name, replacement = "")
      out <- gsub(out, pattern = "\"", replacement = "")
    }
  }
  if (out == "") {
    cluster_folder <- "pippo"
    while (cluster_folder != "home" && cluster_folder != "data") {
      cluster_folder <- readline(
        "What folder do you want to use as a default on cluster: 'home' or 'data'?\n"
      )
      if (cluster_folder != "home" && cluster_folder != "data") {
        cat("Please choose between 'home' and 'data'\n")
      }
    }
    out <- cluster_folder
    write(
      paste0(name, "\"", out, "\""),
      file = rprof_path,
      append = TRUE
    )
  }

  return(out)
}

#' Set the default drive choice
#' @export
default_drive_choice <- function() {
  rprof_path <- usethis:::scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")
  name <- "JAP_DRIVE_CHOICE="
  y <- jap::my_try_catch(unlist(utils::read.table(rprof_path)))
  out <- ""
  if (is.null(y$warning) & is.null(y$error)) {
    y1 <- as.character(y$value)
    y2 <- y1[stringr::str_detect(y1, name)]
    if (length(y2) == 1) {
      testit::assert(length(y2) == 1)
      out <- gsub(y2, pattern = name, replacement = "")
      out <- gsub(out, pattern = "\"", replacement = "")
    }
    drive <- out
  }
  if (out == "") {
    drive_ans <- readline(
      "Do you want to create a folder structure on your google drive (y/n)?\n"
    )
    if (drive_ans == "y") {
      drive <- TRUE
    } else {
      drive <- FALSE
    }
    out <- drive
    write(
      paste0(name, "\"", out, "\""),
      file = rprof_path,
      append = TRUE
    )
  }

  if (drive) {
    name <- "JAP_DRIVE_EMAIL="
    y <- jap::my_try_catch(unlist(utils::read.table(rprof_path)))
    out <- ""
    if (is.null(y$warning) & is.null(y$error)) {
      y1 <- as.character(y$value)
      y2 <- y1[stringr::str_detect(y1, name)]
      if (length(y2) == 1) {
        testit::assert(length(y2) == 1)
        out <- gsub(y2, pattern = name, replacement = "")
        out <- gsub(out, pattern = "\"", replacement = "")
      }
      drive_email <- out
    }
    if (out == "") {
      drive_email <- "pippo@baudo@capellone"
      while (!(stringr::str_count(string = drive_email, pattern = "@") == 1)) {
        drive_email <- readline(
          "What's the email connected to your google drive account?\n"
        )
        if (!(stringr::str_count(string = drive_email, pattern = "@") == 1)) {
          cat("Please provide a valid email address\n")
        }
      }
      googledrive::drive_auth(
        email = drive_email,
        cache = TRUE,
        use_oob = TRUE
      )
      out <- drive_email
      write(
        paste0(name, "\"", out, "\""),
        file = rprof_path,
        append = TRUE
      )
    }
  }

  return(drive)
}

#' Edit your profile function
#' @export
edit_profile <- function() {
  rprof_path <- usethis:::scoped_path_r(c("user", "project"), ".Rprofile", envvar = "R_PROFILE_USER")
  jap::open_file(rprof_path)
}
