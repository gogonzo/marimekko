#' Minimal theme for marimekko plots
#'
#' Removes x-axis gridlines and adjusts spacing for mosaic plots.
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
#'   scale_x_marimekko() +
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
