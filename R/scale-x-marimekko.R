#' X-axis scale for marimekko plots
#'
#' @include mekko-package.R
#'
#' Replaces the default continuous x scale with one that shows
#' category labels at column midpoints. Optionally displays
#' marginal percentages.
#'
#' @param show_percentages Logical. If `TRUE`, appends marginal
#'   percentage to each x-axis label. Default `FALSE`.
#' @param ... Arguments passed to [ggplot2::scale_x_continuous()].
#'
#' @return A ggplot2 scale.
#'
#' @examples
#' library(ggplot2)
#'
#' titanic <- as.data.frame(Titanic)
#' ggplot(titanic) +
#'   geom_marimekko(
#'     aes(fill = Survived, weight = Freq),
#'     formula = ~ Class | Survived
#'   ) +
#'   scale_x_marimekko(show_percentages = TRUE)
#'
#' @export
scale_x_marimekko <- function(show_percentages = FALSE, ...) {
  breaks_fn <- function(limits) {
    info <- .marimekko_env$labels
    if (is.null(info)) {
      return(waiver())
    }
    info$x_mid
  }

  labels_fn <- function(breaks) {
    info <- .marimekko_env$labels
    if (is.null(info)) {
      return(waiver())
    }
    if (show_percentages) {
      paste0(info$label, "\n(", round(info$pct * 100, 1), "%)")
    } else {
      info$label
    }
  }

  scale_x_continuous(
    breaks = breaks_fn,
    labels = labels_fn,
    expand = expansion(mult = 0.01),
    ...
  )
}
