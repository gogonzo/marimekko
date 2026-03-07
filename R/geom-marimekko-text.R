#' @include stat-marimekko.R

# Helper to remap x -> x_var in mapping
remap_x_aes <- function(mapping) {
  if (!is.null(mapping) && "x" %in% names(mapping)) {
    mapping[["x_var"]] <- mapping[["x"]]
    mapping[["x"]] <- NULL
  }
  mapping
}

#' Add text labels to a marimekko plot
#'
#' @include stat-marimekko.R
#'
#' `geom_marimekko_text()` places text labels at the center of each tile
#' in a two-variable marimekko plot. It uses the base stat internally,
#' so the `label` aesthetic can reference computed variables via
#' [ggplot2::after_stat()]: `weight` (count), `cond_prop` (conditional
#' proportion), `x_label` (x category name), `fill_label` (fill category
#' name), `.resid` (Pearson residual, when `residuals = TRUE`).
#'
#' @param mapping Set of aesthetic mappings. Requires `x`, `fill`, and
#'   `label`. Use [ggplot2::after_stat()] for computed variables.
#' @param data A data frame.
#' @param position Position adjustment. Default `"identity"`.
#' @param gap Numeric. Gap between tiles. Default `0.01`.
#' @param gap_x Numeric. Horizontal gap override. Default `NULL`.
#' @param gap_y Numeric. Vertical gap override. Default `NULL`.
#' @param standardize Logical. Equal-width columns. Default `FALSE`.
#' @param residuals Logical. Compute Pearson residuals. Default `FALSE`.
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
#'   geom_marimekko_text(aes(
#'     x = Class, fill = Survived, weight = Freq,
#'     label = after_stat(weight)
#'   )) +
#'   scale_x_marimekko()
#'
#' @export
geom_marimekko_text <- function(mapping = NULL, data = NULL,
                                position = "identity",
                                ...,
                                gap = 0.01,
                                gap_x = NULL,
                                gap_y = NULL,
                                standardize = FALSE,
                                residuals = FALSE,
                                size = 3.5,
                                colour = "black",
                                na.rm = FALSE,
                                show.legend = FALSE,
                                inherit.aes = FALSE) {
  mapping <- remap_x_aes(mapping)

  layer(
    data = data,
    mapping = mapping,
    stat = StatmarimekkoBase,
    geom = GeomText,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      gap = gap,
      gap_x = gap_x,
      gap_y = gap_y,
      standardize = standardize,
      residuals = residuals,
      size = size,
      colour = colour,
      na.rm = na.rm,
      ...
    )
  )
}

#' Add labels with background to a marimekko plot
#'
#' @include stat-marimekko.R
#'
#' `geom_marimekko_label()` is identical to [geom_marimekko_text()] but
#' uses [ggplot2::GeomLabel] to draw a filled box behind the text.
#'
#' @inheritParams geom_marimekko_text
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
#'   geom_marimekko_label(aes(
#'     x = Class, fill = Survived, weight = Freq,
#'     label = after_stat(weight)
#'   )) +
#'   scale_x_marimekko()
#'
#' @export
geom_marimekko_label <- function(mapping = NULL, data = NULL,
                                 position = "identity",
                                 ...,
                                 gap = 0.01,
                                 gap_x = NULL,
                                 gap_y = NULL,
                                 standardize = FALSE,
                                 residuals = FALSE,
                                 size = 3.5,
                                 colour = "black",
                                 label.padding = unit(0.15, "lines"),
                                 na.rm = FALSE,
                                 show.legend = FALSE,
                                 inherit.aes = FALSE) {
  mapping <- remap_x_aes(mapping)

  layer(
    data = data,
    mapping = mapping,
    stat = StatmarimekkoBase,
    geom = GeomLabel,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      gap = gap,
      gap_x = gap_x,
      gap_y = gap_y,
      standardize = standardize,
      residuals = residuals,
      size = size,
      colour = colour,
      label.padding = label.padding,
      na.rm = na.rm,
      ...
    )
  )
}
