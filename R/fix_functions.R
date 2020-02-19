#' @title Fix End of Line documentation problem
#' @author Giovanni Laudanno
#' @description Fix End of Line documentation problem. Don't forget to refresh
#' your Git tab in Rstudio afterwards.
#' @inheritParams default_params_doc
#' @return nothing
#' @export
fix_documentation <- function() {
  system("git add .")
}

#' @title Fix Java (NOT WORKING YET)
#' @author Giovanni Laudanno
#' @description Fix Java
#' @inheritParams default_params_doc
#' @return nothing
#' @export
fix_java <- function() {
  disks <- jap::find_disks()

  # browseURL(
  # "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=241533_1f5b5a70bf22433b84d0e960903adac8"
  # )
  i <- 1
  done <- FALSE
  while (i <= length(disks) & done == FALSE) {
    disk <- disks[i]
    suppressWarnings(
      pre <- fs::dir_ls(
        path = paste0(disk, ":/"),
        recurse = TRUE,
        regexp = "jre1.8.0_241",
        fail = FALSE
      )
    )
    stringr::str_length("jre1.8.0_241")
    pre <- pre[endsWith(pre, "jre1.8.0_241")]
    if (length(pre) > 0) {
      j <- 1
      while (j <= length(pre) & done == FALSE) {
        Sys.setenv(JAVA_HOME = pre[j])
        done <- require("rJava")
        j <- j + 1
      }
    }
    i <- i + 1
  }
  if (!require("rJava")) {
    stop("FAILED")
  }
}
