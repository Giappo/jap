#' @title cat2
#' @author Giovanni Laudanno
#' @description If verbose == TRUE cats the message, otherwise stays silent
#' @inheritParams default_params_doc
#' @return prints on screen
#' @export
cat2 <- function(
  message,
  verbose
) {
  if (verbose == TRUE) {
    cat(message)
  } else {
    return()
  }
}

#' Like file.path, but cooler
#' @param fsep path separator for the OS
#' @param ... additional arguments
#' @export
file_path <- function(..., fsep = .Platform$file.sep) {
  gsub("//", "/", file.path(..., fsep = fsep))
}
#' A better try catch
#' @param expr an expression
#' @export
my_try_catch <- function(expr) {
  warn <- err <- NULL
  value <- withCallingHandlers(
    tryCatch(
      expr, error = function(e) {
        err <<- e
        NULL
      }
    ), warning = function(w) {
      warn <<- w
      invokeRestart("muffleWarning")
    })
  list(
    value = value,
    warning = warn,
    error = err
  )
}

#' Just plot a matrix without rotating it
#' @param logs do you want to plot in log scale?
#' @param low_triangular do you want to plot only the low triangular?
#' @export
plot_matrix <- function(
  mat,
  logs = TRUE,
  low_triangular = FALSE
) {
  if (low_triangular == TRUE) {
    mat[col(mat) >= row(mat)] <- 0
  }
  rotate <- function(x) t(apply(x, 2, rev))
  col_palette <- grDevices::colorRampPalette(
    c('blue', 'white', 'red')
  )(30)
  if (logs == TRUE) {
    mat2 <- log(mat)
  } else {
    mat2 <- mat
  }
  lattice::levelplot(
    rotate(mat2),
    col.regions = col_palette
  )
}

#' Find name of disks on your machine
#' @author Giovanni Laudanno
#' @export
find_disks <- function() {
  x <- system("wmic logicaldisk get caption", inter = TRUE)
  x <- x[2:(length(x) - 1)]
  gsub(x = x, pattern = ":.*", replacement = "")
}

#' Adds all require dependencies to the DESCRIPTION file
#' @author Giovanni Laudanno
#' @export
build_description_file <- function(project_name, ...) {
  github_repo <- project_name
  github_folder <- jap::find_github_folder(...)
  project_folder <- file.path(github_folder, github_repo)
  if (!dir.exists(project_folder)) {
    github_name <- readline("What's the name of the Github profile? ")
    jap::git_clone(github_name = github_name, github_repo = github_repo)
  }
  description_file <- file.path(project_folder, "DESCRIPTION")
  if (!file.exists(description_file)) {
    stop("DESCRIPTION file not found")
  }
  r_folder <- file.path(project_folder, "R")
  if (!dir.exists(r_folder)) {
    dir.create(r_folder)
  }
  r_files <- list.files(path = r_folder)
  packages <- c()
  for (r in seq_along(r_files)) {
    r_file <- file.path(r_folder, r_files[r])
    x1 <- grep("::", readLines(r_file), value = TRUE)
    x2 <- gsub("::.*$", "", x1)
    x3 <- gsub(" *$.", "", x2); x3
    xx4 <- rep(NA, length(x3))
    for (i in seq_along(x3)) {
      xx3 <- x3[i]
      temp <- utils::tail(strsplit(xx3, split = " ")[[1]], 1)
      xx4[i] <- stringi::stri_extract_last_words(temp)
    }
    packages <- unique(c(packages, xx4))
  }
  packages <- unique(packages[!is.na(packages)])
  packages <- packages[order(packages)]
  packages <- packages[!(project_name == packages)]
  lines <- readLines(description_file)
  import_line <- which(grepl(pattern = "Imports:", x = lines))
  colon_lines <- which(grepl(x = lines, pattern = ":"))
  end_line <- colon_lines[colon_lines > import_line][1]
  good_lines1 <- 1:import_line
  good_lines2 <- end_line:length(lines)
  packages_lines <- (import_line + 1):(end_line - 1)
  new_packages <- packages
  old_packages <- lines[packages_lines]
  old_packages <- stringi::stri_extract_last_words(old_packages)
  all_packages <- unique(c(old_packages, new_packages))
  all_packages <- all_packages[order(all_packages)]
  all_packages <- all_packages[!(project_name == all_packages)]
  import_packages <- all_packages
  worked <- rep(FALSE, length(import_packages))
  for (p in seq_along(import_packages)) {
    pkg <- import_packages[p]
    out <- jap::my_try_catch(
      jap::install_package(pkg)
    )
    if (!is.null(out$warning) || !is.null(out$error)) {
      worked[p] <- FALSE
    } else {
      worked[p] <- TRUE
    }
  }
  import_packages <- import_packages[worked]
  all_packages <- all_packages[worked]
  all_packages <- paste0("  ", all_packages, ",")
  all_packages[length(all_packages)] <- paste0(
    "  ",
    stringi::stri_extract_last_words(all_packages[length(all_packages)])
  )

  new_lines <- c(
    lines[good_lines1],
    all_packages,
    lines[good_lines2]
  )
  file.remove(description_file)
  writeLines(text = new_lines, con = description_file)
  testit::assert(file.exists(description_file))

  test_folder <- file.path(project_folder, "tests", "testthat")
  if (dir.exists(test_folder)) {
    test_files <- list.files(path = test_folder)
    if (length(test_files) > 0 ) {
      packages <- c()
      for (r in seq_along(test_files)) {
        test_file <- file.path(test_folder, test_files[r])
        x1 <- grep("::", readLines(test_file), value = TRUE)
        x2 <- gsub("::.*$", "", x1)
        x3 <- gsub(" *$.", "", x2); x3
        xx4 <- rep(NA, length(x3))
        for (i in seq_along(x3)) {
          xx3 <- x3[i]
          temp <- utils::tail(strsplit(xx3, split = " ")[[1]], 1)
          xx4[i] <- stringi::stri_extract_last_words(temp)
        }
        packages <- unique(c(packages, xx4))
      }
      packages <- unique(packages[!is.na(packages)])
      packages <- packages[order(packages)]
      packages <- packages[!(project_name == packages)]
      lines <- readLines(description_file)
      suggest_line <- which(grepl(pattern = "Suggests:", x = lines))
      colon_lines <- which(grepl(x = lines, pattern = ":"))
      end_line <- colon_lines[colon_lines > suggest_line][1]
      good_lines1 <- 1:suggest_line
      good_lines2 <- end_line:length(lines)
      packages_lines <- (suggest_line + 1):(end_line - 1)
      new_packages <- packages
      old_packages <- lines[packages_lines]
      all_packages <- unique(c(old_packages, new_packages))
      all_packages <- stringi::stri_extract_last_words(all_packages)
      all_packages <- all_packages[
        !all_packages %in% import_packages
        ]
      all_packages <- unique(all_packages)
      suggest_packages <- all_packages
      worked <- rep(FALSE, length(suggest_packages))
      for (p in seq_along(suggest_packages)) {
        pkg <- suggest_packages[p]
        out <- jap::my_try_catch(
          jap::install_package(pkg)
        )
        if (!is.null(out$warning) || !is.null(out$error)) {
          worked[p] <- FALSE
        } else {
          worked[p] <- TRUE
        }
      }
      suggest_packages <- suggest_packages[worked]
      all_packages <- all_packages[worked]
      all_packages <- paste0("  ", all_packages, ",")
      all_packages <- all_packages[order(all_packages)]
      all_packages[length(all_packages)] <- paste0(
        "  ",
        stringi::stri_extract_last_words(all_packages[length(all_packages)])
      )
      new_lines <- c(
        lines[good_lines1],
        all_packages,
        lines[good_lines2]
      )
      file.remove(description_file)
      writeLines(text = new_lines, con = description_file)
      testit::assert(file.exists(description_file))
    }
  }

  description_content <- readLines(description_file)
  for (i in seq_along(description_content)) {
    cat(description_content[i], "\n")
  }

  return(list(
    import = import_packages,
    suggest = suggest_packages
  ))
}

#' Convert a path to the equivalent file.path call
#' @inheritParams default_params_doc
#' @export
path_2_file.path <- function(
  path
) {
  x <- strsplit(path, split = "/")[[1]]
  paste0(
    "file.path(",
    "\"",
    toString(paste0(x, collapse = "\",\"")),
    "\")"
  )
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

#' @export
default_github_folder <- function() {
  disk <- jap::default_home_folder()
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
