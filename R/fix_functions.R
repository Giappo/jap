#' @title Fix End of Line documentation problem
#' @author Giovanni Laudanno
#' @description Fix End of Line documentation problem. Don't forget to refresh
#' your Git tab in Rstudio afterwards.
#' @return nothing
#' @export
fix_documentation <- function() {
  system("git add .")
}

#' @title Fix Java (NOT WORKING YET)
#' @author Giovanni Laudanno
#' @description Fix Java
#' @return nothing
#' @export
fix_java <- function() {

  jap_folder <- system.file(package = "jap")
  extdata_folder <- file.path(jap_folder, "extdata")
  if (!("extdata" %in% list.files(jap_folder))) {
    dir.create(extdata_folder)
  }
  path_file <- file.path(extdata_folder, "java_path.txt")
  if (file.exists(path_file)) {
    x <- levels(unname(utils::read.csv(path_file)[[1]]))
    Sys.setenv(JAVA_HOME = x)
    done <- requireNamespace("rJava", quietly = TRUE)
    if (isTRUE(done)) {
      return(x)
    }
  }

  disks <- jap::find_disks()

  # browseURL(
  # "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=241533_1f5b5a70bf22433b84d0e960903adac8"
  # )

  i <- 1
  done <- FALSE
  while (i <= length(disks) & done == FALSE) {
    disk <- disks[i]

    priority <- file.path(
      paste0(disk, ":"),
      list.files(path = paste0(disk, ":/"))[
      grepl(x = list.files(path = paste0(disk, ":/")), pattern = "Program") |
        grepl(x = list.files(path = paste0(disk, ":/")), pattern = "Users")
      ]
    )

    suppressWarnings(
      pre <- fs::dir_ls(
        path = priority,
        recurse = TRUE,
        regexp = "jre1.8.0_241",
        fail = FALSE
      )
    )

    pre <- pre[endsWith(pre, "jre1.8.0_241")]
    if (length(pre) > 0) {
      j <- 1
      while (j <= length(pre) & done == FALSE) {
        Sys.setenv(JAVA_HOME = pre[j])
        done <- requireNamespace("rJava", quietly = TRUE)
        if (isTRUE(done)) {
          invisible(suppressWarnings(file.remove(path_file)))
          utils::write.csv2(
            pre[j],
            file = path_file,
            row.names = FALSE
          )
          return(pre[j])
        }
        j <- j + 1
      }
    }

    suppressWarnings(
      pre <- fs::dir_ls(
        path = paste0(disk, ":/"),
        recurse = TRUE,
        regexp = "jre1.8.0_241",
        fail = FALSE
      )
    )

    pre <- pre[endsWith(pre, "jre1.8.0_241")]
    if (length(pre) > 0) {
      j <- 1
      while (j <= length(pre) & done == FALSE) {
        Sys.setenv(JAVA_HOME = pre[j])
        done <- requireNamespace("rJava", quietly = TRUE)
        if (isTRUE(done)) {
          invisible(suppressWarnings(file.remove(path_file)))
          utils::write.csv2(
            pre[j],
            file = path_file,
            row.names = FALSE
          )
          return(pre[j])
        }
        j <- j + 1
      }
    }
    i <- i + 1
  }
  if (!requireNamespace("rJava", quietly = TRUE)) {
    stop("FAILED")
  }
}
