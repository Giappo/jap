#' Create an empty phylogeny
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @export
create_empty_phylo <- function() {
  tr <- list(edge = matrix(c(2, 1), 1, 2), tip.label = "", Nnode = 0L)
  class(tr) <- "phylo"
  tr$tip.label <- c() # nolint
  tr
}

#' Create an empty phylogeny
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @export
create_singleton_phylo <- function(age) {
  tr <- list(edge = matrix(c(2, 1), 1, 2), tip.label = "t1", Nnode = 1L)
  class(tr) <- "phylo"
  tr$edge.length <- age # nolint
  tr
}
