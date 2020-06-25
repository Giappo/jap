#' Create an empty phylogeny
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

#' Extrapolate tidy branching times from phylogeny
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @export
branching_times <- function(phylogeny) {
  brts <- sort(abs(ape::branching.times(phylogeny)), decreasing = TRUE)
  brts
}

#' Open tree file
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @export
read_phylo <- function(
  tree_file
) {
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
  out_read <- my_try_catch(ape::read.tree(tree_file))
  if (!(is.null(out_read$error) && is.null(out_read$warning))) {
    tree <- ape::read.nexus(tree_file)
  } else {
    tree <- out_read$value
  }
  tree
}

#' Ltt plot for a tree
#' @inheritParams default_params_doc
#' @param present_is_zero Set to TRUE if you want the present time to be zero
#' @author Giovanni Laudanno
#' @export
plot_ltt <- function(
  tree,
  present_is_zero = FALSE
) {
  age <- max(jap::branching_times(tree))
  ts <- seq(from = 0, to = age, length.out = 1001)
  y = ape::ltt.plot.coords(tree)
  y[, 1] <- y[, 1] + max(abs(y[, 1]))
  ltt <- rep(max(y[, 2]), length(ts))
  for (j in nrow(y):1) {
    ltt[ts <= y[j, 1]] <- y[j, 2]
  }
  df <- data.frame(
    ts = ts,
    ltt = ltt
  )

  if (present_is_zero) {
    df$ts <- df$ts - age
  }

  plot <- ggplot2::ggplot(df, ggplot2::aes(x = ts)) +
    ggplot2::geom_line(ggplot2::aes(y = ltt), color = "blue") +
    ggplot2::ylab("LTT") +
    ggplot2::xlab("Time") +
    ggplot2::scale_y_log10(
      breaks = unname(quantile(df$ltt, c(0, 0.25, 0.5, 0.75, 1)))
    ) +
    ggplot2::theme_bw()
  plot
}

#' Open tree file to retrieve node bars info
#' @inheritParams default_params_doc
#' @author Giovanni Laudanno
#' @export
read_phylo_node_bars <- function(
  tree_file
) {
  a = utils::read.csv(tree_file)
  grepl(x = a, pattern = "height_95%_HPD")
  b = apply(a, MARGIN = 1, FUN = function(x) grepl(x = x, pattern = "height_95%_HPD=\\{"))
  c1 = gsub(x = a[which(b), ], pattern = "height_95%_HPD=\\{", replacement = "")
  c2 = gsub(x = a[which(b) + 1, ], pattern = "\\}", replacement = "")
  node_bars = data.frame(
    min = as.numeric(c1),
    max = as.numeric(c2)
  )
  node_bars
}
