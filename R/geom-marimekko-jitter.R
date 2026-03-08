#' Jitter individual observations within marimekko tiles
#'
#' @include geom-marimekko-text.R
#'
#' `geom_marimekko_jitter()` scatters individual data points inside
#' their corresponding mosaic tile. It reads tile positions automatically
#' from a preceding [geom_marimekko()] layer. Useful for small-to-medium
#' datasets to show the raw data behind the proportions.
#'
#' @param mapping Set of aesthetic mappings. No required aesthetics;
#'   tile positions come from [geom_marimekko()].
#' @param data A data frame. Default `NULL` (uses plot data; tile
#'   positions come from [geom_marimekko()]).
#' @param position Position adjustment. Default `"identity"`.
#' @param na.rm Logical. Remove missing values. Default `FALSE`.
#' @param show.legend Logical. Show legend. Default `FALSE`.
#' @param inherit.aes Logical. Inherit aesthetics. Default `FALSE`.
#' @param ... Additional arguments passed to the layer.
#' @param size Point size. Default `1`.
#' @param alpha Point transparency. Default `0.5`.
#' @param shape Point shape. Default `16` (filled circle).
#' @param colour Point colour. Default `"black"`.
#' @param seed Random seed for reproducible jitter. Default `NA`
#'   (different each time).
#'
#' @return A ggplot2 layer.
#'
#' @examples
#' library(ggplot2)
#'
#' # Small dataset: UCBAdmissions Dept A
#' ucb <- as.data.frame(UCBAdmissions)
#' ucb_a <- ucb[ucb$Dept == "A", ]
#' ggplot(ucb_a) +
#'   geom_marimekko(
#'     aes(fill = Admit, weight = Freq),
#'     formula = ~ Gender | Admit
#'   ) +
#'   geom_marimekko_jitter(seed = 42)
#'
#' @export
geom_marimekko_jitter <- function(mapping = NULL, data = NULL,
                                  position = "identity",
                                  ...,
                                  size = 1,
                                  alpha = 0.5,
                                  shape = 16,
                                  colour = "black",
                                  seed = NA,
                                  na.rm = FALSE,
                                  show.legend = FALSE,
                                  inherit.aes = FALSE) {
  layer(
    data = data,
    mapping = mapping,
    stat = StatmarimekkoJitter,
    geom = GeomPoint,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      size = size,
      alpha = alpha,
      shape = shape,
      colour = colour,
      seed = seed,
      na.rm = na.rm,
      ...
    )
  )
}

StatmarimekkoJitter <- ggproto("StatmarimekkoJitter", Stat,
  compute_panel = function(data, scales, seed = NA) {
    panel_id <- if ("PANEL" %in% names(data)) as.character(data$PANEL[1]) else "1"
    tiles <- .marimekko_env$tiles[[panel_id]]
    if (is.null(tiles)) {
      stop("geom_marimekko_jitter requires a geom_marimekko() layer", call. = FALSE)
    }

    if (!is.na(seed)) set.seed(seed)

    # Expand each tile by its weight and jitter points within bounds
    result_list <- lapply(seq_len(nrow(tiles)), function(i) {
      w <- as.integer(round(tiles$weight[i]))
      if (w < 1) return(NULL)

      pad <- 0.05
      dx <- tiles$xmax[i] - tiles$xmin[i]
      dy <- tiles$ymax[i] - tiles$ymin[i]
      xr <- tiles$xmin[i] + pad * dx + runif(w) * (1 - 2 * pad) * dx
      yr <- tiles$ymin[i] + pad * dy + runif(w) * (1 - 2 * pad) * dy
      data.frame(
        x = xr, y = yr,
        fill = rep(tiles$fill[i], w),
        stringsAsFactors = FALSE
      )
    })

    result <- do.call(rbind, result_list)
    if (is.null(result) || nrow(result) == 0) {
      return(data.frame(x = numeric(0), y = numeric(0), fill = character(0)))
    }

    result$group <- as.integer(as.factor(result$fill))

    if ("PANEL" %in% names(data)) {
      result$PANEL <- data$PANEL[1]
    }

    result
  }
)
