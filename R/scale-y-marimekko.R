#' Y-axis scale for marimekko plots
#'
#' @include marimekko-package.R
#'
#' Replaces the default continuous y scale with one that shows
#' fill category labels at segment midpoints.
#'
#' @param ... Arguments passed to [ggplot2::scale_y_continuous()].
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
#'   scale_x_marimekko() +
#'   scale_y_marimekko()
#'
#' @export
scale_y_marimekko <- function(...) {
  .breaks_fn <- function(limits) {
    info <- .marimekko_env$y_labels
    if (is.null(info)) {
      return(waiver())
    }
    info$y_mid
  }

  .labels_fn <- function(breaks) {
    info <- .marimekko_env$y_labels
    if (is.null(info)) {
      return(waiver())
    }
    info$label
  }

  scale_y_continuous(
    breaks = .breaks_fn,
    labels = .labels_fn,
    expand = expansion(mult = 0.01),
    ...
  )
}
