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
