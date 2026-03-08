#' Earthy Nordic colour palette
#'
#' A character vector of 8 earthy, Nordic-inspired colours for use with
#' marimekko plots. Muted natural tones that work well for categorical
#' data visualisation.
#'
#' @export
marimekko_pal <- c(
  "#5B7553",
  "#C46E4E",
  "#4A6A8A",
  "#C9A84C",
  "#B07A8F",
  "#2E6E6E",
  "#D4A574",
  "#4A4A4A"
)

#' Marimekko fill colour scale
#'
#' A discrete fill scale using earthy Nordic-inspired colours.
#'
#' @param ... Arguments passed to [ggplot2::scale_fill_manual()].
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
#'   scale_fill_marimekko()
#'
#' @export
scale_fill_marimekko <- function(...) {
  scale_fill_manual(values = marimekko_pal, ...)
}

#' Marimekko colour scale
#'
#' A discrete colour scale using earthy Nordic-inspired colours.
#'
#' @param ... Arguments passed to [ggplot2::scale_colour_manual()].
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
#'   scale_colour_marimekko()
#'
#' @export
scale_colour_marimekko <- function(...) {
  scale_colour_manual(values = marimekko_pal, ...)
}

#' Minimal theme for marimekko plots
#'
#' Removes x-axis gridlines and adjusts spacing for mosaic plots.
#' Pair with [scale_fill_marimekko()] and [scale_colour_marimekko()]
#' for a complete marimekko look.
#'
#' @param base_size Base font size. Default `12`.
#' @param ... Arguments passed to [ggplot2::theme_minimal()].
#'
#' @return A ggplot2 theme.
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
#'   scale_fill_marimekko() +
#'   theme_marimekko()
#'
#' @export
theme_marimekko <- function(base_size = 12, ...) {
  theme_minimal(base_size = base_size, ...) %+replace%
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      axis.ticks.x = element_blank()
    )
}
