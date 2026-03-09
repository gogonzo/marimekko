#' Retrieve computed tile positions from a marimekko layer
#'
#' @name StatMarimekkoTiles
#' @include geom-marimekko.R
#'
#' `StatMarimekkoTiles` is a ggplot2 [ggplot2::Stat] that exposes the
#' tile data computed by a preceding [geom_marimekko()] layer.
#' It can be paired with **any** geom to build custom companion layers
#' on top of a marimekko plot.
#'
#' The returned data frame contains at least the following columns:
#'
#' \describe{
#'   \item{`xmin`, `xmax`, `ymin`, `ymax`}{Tile boundaries.}
#'   \item{`x`, `y`}{Tile centre (midpoint of boundaries).}
#'   \item{`weight`}{Tile count / frequency.}
#'   \item{`fill`}{Fill variable value for the tile.}
#'   \item{`.proportion`}{Conditional proportion within the parent tile.}
#'   \item{`cond_prop`}{Alias for `.proportion`.}
#'   \item{`.residuals`}{Pearson residual measuring deviation from
#'     independence.}
#'   \item{`.tooltip`}{Auto-generated tooltip string with count and
#'     percentage.}
#' }
#'
#' @section Usage with custom geoms:
#'
#' Use `StatMarimekkoTiles` as the `stat` argument in [ggplot2::layer()]
#' to pair the tile data with any geom. The only requirement is that
#' [geom_marimekko()] must appear **before** the custom layer so that
#' tile positions are computed first.
#'
#' @examples
#' library(ggplot2)
#'
#' titanic <- as.data.frame(Titanic)
#'
#' # Bubble overlay — point size encodes tile count
#' ggplot(titanic) +
#'   geom_marimekko(
#'     aes(fill = Survived, weight = Freq),
#'     formula = ~ Class | Survived, alpha = 0.4
#'   ) +
#'   layer(
#'     stat = StatMarimekkoTiles,
#'     geom = GeomPoint,
#'     mapping = aes(size = after_stat(weight)),
#'     data = titanic,
#'     position = "identity",
#'     show.legend = FALSE,
#'     inherit.aes = FALSE,
#'     params = list(colour = "white", alpha = 0.7)
#'   ) +
#'   scale_size_area(max_size = 12)
#'
#' # Residual markers — colour and size show deviation from independence
#' ggplot(titanic) +
#'   geom_marimekko(
#'     aes(fill = Survived, weight = Freq),
#'     formula = ~ Class | Survived
#'   ) +
#'   layer(
#'     stat = StatMarimekkoTiles,
#'     geom = GeomPoint,
#'     mapping = aes(
#'       size = after_stat(abs(.residuals)),
#'       colour = after_stat(ifelse(.residuals > 0, "over", "under"))
#'     ),
#'     data = titanic,
#'     position = "identity",
#'     show.legend = TRUE,
#'     inherit.aes = FALSE,
#'     params = list(alpha = 0.8)
#'   ) +
#'   scale_colour_manual(
#'     values = c(over = "tomato", under = "steelblue"),
#'     name = "Deviation"
#'   ) +
#'   scale_size_continuous(range = c(1, 8), name = "|Residual|")
#'
#' @seealso [geom_marimekko()], [geom_marimekko_text()],
#'   [geom_marimekko_label()], [fortify_marimekko()]
#'
#' @export
StatMarimekkoTiles <- ggproto("StatMarimekkoTiles", Stat,
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
#' `.residuals` (Pearson residual).
#'
#' @param mapping Set of aesthetic mappings. Only `label` is required.
#'   Use [ggplot2::after_stat()] for computed variables.
#' @param data A data frame. Default `NULL` (uses plot data; tile
#'   positions come from [geom_marimekko()]).
#' @param position Position adjustment. Default `"identity"`.
#' @param size Text size. Default `3.5`.
#' @param colour Text colour. Default `"white"` for text, `"black"` for labels.
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
                                colour = "white",
                                na.rm = FALSE,
                                show.legend = FALSE,
                                inherit.aes = FALSE) {
  layer(
    data = data,
    mapping = mapping,
    stat = StatMarimekkoTiles,
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
#' @param fill Label background colour. Default `alpha("white", 0.7)`.
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
                                 fill = alpha("white", 0.7),
                                 label.padding = unit(0.15, "lines"),
                                 na.rm = FALSE,
                                 show.legend = FALSE,
                                 inherit.aes = FALSE) {
  layer(
    data = data,
    mapping = mapping,
    stat = StatMarimekkoTiles,
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
