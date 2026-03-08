#' @include geom-marimekko.R

#' @keywords internal
StatmarimekkoTiles <- ggproto("StatmarimekkoTiles", Stat,
  compute_panel = function(data, scales) {
    panel_id <- if ("PANEL" %in% names(data)) as.character(data$PANEL[1]) else "1"
    tiles <- .marimekko_env$tiles[[panel_id]]
    if (is.null(tiles)) {
      stop("geom_marimekko_text/label requires a geom_marimekko() layer", call. = FALSE)
    }

    # Add compatibility columns for after_stat() expressions
    if (is.null(tiles$cond_prop) && !is.null(tiles$.proportion)) {
      tiles$cond_prop <- tiles$.proportion
    }
    if (is.null(tiles$.tooltip)) {
      tiles$.tooltip <- paste0(
        "Count: ", tiles$weight, "\n",
        "Proportion: ", round((tiles$.proportion %||% 0) * 100, 1), "%"
      )
    }

    tiles
  }
)

#' Add text labels to a marimekko plot
#'
#' @include geom-marimekko.R
#'
#' `geom_marimekko_text()` places text labels at the center of each tile
#' in a marimekko plot. It reads tile positions automatically from a
#' preceding [geom_marimekko()] layer.
#'
#' The `label` aesthetic can reference computed variables via
#' [ggplot2::after_stat()]: `weight` (count), `.proportion` (conditional
#' proportion within parent tile), `cond_prop` (alias for `.proportion`),
#' `.resid` (Pearson residual).
#'
#' @param mapping Set of aesthetic mappings. Only `label` is required.
#'   Use [ggplot2::after_stat()] for computed variables.
#' @param data A data frame. Default `NULL` (uses plot data; tile
#'   positions come from [geom_marimekko()]).
#' @param position Position adjustment. Default `"identity"`.
#' @param size Text size. Default `3.5`.
#' @param colour Text colour. Default `"black"`.
#' @param na.rm Logical. Remove missing values. Default `FALSE`.
#' @param show.legend Logical. Show legend. Default `FALSE`.
#' @param inherit.aes Logical. Inherit aesthetics. Default `FALSE`.
#' @param ... Additional arguments passed to the layer.
#'
#' @return A ggplot2 layer.
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
#'   geom_marimekko_text(aes(label = after_stat(weight)))
#'
#' @export
geom_marimekko_text <- function(mapping = NULL, data = NULL,
                                position = "identity",
                                ...,
                                size = 3.5,
                                colour = "black",
                                na.rm = FALSE,
                                show.legend = FALSE,
                                inherit.aes = FALSE) {
  layer(
    data = data,
    mapping = mapping,
    stat = StatmarimekkoTiles,
    geom = GeomText,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      size = size,
      colour = colour,
      na.rm = na.rm,
      ...
    )
  )
}

#' Add labels with background to a marimekko plot
#'
#' @include geom-marimekko.R
#'
#' `geom_marimekko_label()` is identical to [geom_marimekko_text()] but
#' uses [ggplot2::GeomLabel] to draw a filled box behind the text.
#'
#' @inheritParams geom_marimekko_text
#' @param fill Label background colour. Default `"white"`.
#' @param label.padding Amount of padding around label. Default
#'   `ggplot2::unit(0.15, "lines")`.
#' @return A ggplot2 layer.
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
#'   geom_marimekko_label(aes(label = after_stat(weight)))
#'
#' @export
geom_marimekko_label <- function(mapping = NULL, data = NULL,
                                 position = "identity",
                                 ...,
                                 size = 3.5,
                                 colour = "black",
                                 fill = "white",
                                 label.padding = unit(0.15, "lines"),
                                 na.rm = FALSE,
                                 show.legend = FALSE,
                                 inherit.aes = FALSE) {
  layer(
    data = data,
    mapping = mapping,
    stat = StatmarimekkoTiles,
    geom = GeomLabel,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      size = size,
      colour = colour,
      fill = fill,
      label.padding = label.padding,
      na.rm = na.rm,
      ...
    )
  )
}
