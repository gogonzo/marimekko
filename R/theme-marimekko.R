#' Unikko-inspired colour palette
#'
#' A character vector of 8 bold colours inspired by Marimekko's iconic
#' Unikko poppy pattern. Vibrant, high-contrast tones suited for
#' categorical data visualisation.
#'
#' @export
marimekko_pal <- c(
  "#E03C31",
  "#1D3557",
  "#E9C46A",
  "#2A6041",
  "#D4668E",
  "#F4A261",
  "#264653",
  "#4A4A4A"
)

#' Minimal theme for marimekko plots
#'
#' Removes x-axis gridlines and adjusts spacing for mosaic plots.
#' Also applies the [marimekko_pal] fill scale.
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
#'   theme_marimekko()
#'
#' @export
theme_marimekko <- function(base_size = 12, ...) {
  list(
    theme_minimal(base_size = base_size, ...) %+replace%
      theme(
        plot.background = element_rect(fill = "#FAF9F6", colour = NA),
        panel.background = element_rect(fill = "#FAF9F6", colour = NA),
        panel.grid = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_text(face = "bold", size = rel(1.1)),
        plot.title = element_text(face = "bold", size = rel(1.3)),
        plot.subtitle = element_text(size = rel(1.0))
      ),
    scale_fill_manual(values = marimekko_pal)
  )
}
