#' Jitter individual observations within marimekko tiles
#'
#' @include stat-marimekko.R
#'
#' `geom_marimekko_jitter()` scatters individual data points inside
#' their corresponding mosaic tile. Useful for small-to-medium datasets
#' to show the raw data behind the proportions.
#'
#' @param mapping Set of aesthetic mappings. Requires `x` and `fill`.
#' @param data A data frame.
#' @param position Position adjustment. Default `"identity"`.
#' @param gap Numeric. Gap between tiles. Default `0.01`.
#' @param gap_x Numeric. Horizontal gap override. Default `NULL`.
#' @param gap_y Numeric. Vertical gap override. Default `NULL`.
#' @param standardize Logical. Equal-width columns. Default `FALSE`.
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
#'   geom_marimekko_jitter(aes(x = Gender, fill = Admit, weight = Freq)) +
#'   scale_x_marimekko()
#'
#' @export
geom_marimekko_jitter <- function(mapping = NULL, data = NULL,
                                  position = "identity",
                                  ...,
                                  gap = 0.01,
                                  gap_x = NULL,
                                  gap_y = NULL,
                                  standardize = FALSE,
                                  size = 1,
                                  alpha = 0.5,
                                  shape = 16,
                                  colour = "black",
                                  seed = NA,
                                  na.rm = FALSE,
                                  show.legend = FALSE,
                                  inherit.aes = FALSE) {
  if (!is.null(mapping) && "x" %in% names(mapping)) {
    mapping[["x_var"]] <- mapping[["x"]]
    mapping[["x"]] <- NULL
  }

  layer(
    data = data,
    mapping = mapping,
    stat = StatmarimekkoJitter,
    geom = GeomPoint,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      gap = gap,
      gap_x = gap_x,
      gap_y = gap_y,
      standardize = standardize,
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
  required_aes = c("x_var", "fill"),
  default_aes = aes(weight = 1),
  dropped_aes = c("weight", "x_var"),
  setup_params = function(data, params) {
    params$gap <- params$gap %||% 0.01
    params$gap_x <- params$gap_x %||% params$gap
    params$gap_y <- params$gap_y %||% params$gap
    params$standardize <- params$standardize %||% FALSE
    params
  },
  compute_panel = function(data, scales, gap = 0.01, gap_x = NULL,
                           gap_y = NULL, standardize = FALSE,
                           seed = NA) {
    gap_x <- gap_x %||% gap
    gap_y <- gap_y %||% gap
    data$x_var <- as.factor(data$x_var)
    data$fill <- as.factor(data$fill)

    if (is.null(data$weight) || all(is.na(data$weight))) {
      data$weight <- 1
    }

    x_levels <- levels(data$x_var)
    fill_levels <- levels(data$fill)
    n_x <- length(x_levels)

    # Aggregate to get tile bounds (same logic as Statmarimekko)
    counts <- aggregate(
      weight ~ x_var + fill,
      data = data,
      FUN = sum,
      drop = FALSE
    )
    counts$weight[is.na(counts$weight)] <- 0

    x_totals <- aggregate(weight ~ x_var, data = counts, FUN = sum)
    grand_total <- sum(x_totals$weight)
    x_totals$prop <- x_totals$weight / grand_total

    total_h_gap <- gap_x * max(n_x - 1, 0)
    usable_width <- 1 - total_h_gap

    if (standardize) {
      x_totals$width <- rep(usable_width / n_x, n_x)
    } else {
      x_totals$width <- x_totals$prop * usable_width
    }

    x_pos <- numeric(n_x)
    for (i in seq_len(n_x)) {
      x_pos[i] <- if (i == 1) 0 else x_pos[i - 1] + x_totals$width[i - 1] + gap_x
    }
    x_totals$xmin <- x_pos
    x_totals$xmax <- x_totals$xmin + x_totals$width

    # Build tile lookup
    tiles <- list()
    for (lev in x_levels) {
      sub <- counts[counts$x_var == lev, , drop = FALSE]
      sub <- sub[sub$weight > 0, , drop = FALSE]
      if (nrow(sub) == 0) next

      col_total <- sum(sub$weight)
      sub$cond_prop <- sub$weight / col_total

      n_fill <- nrow(sub)
      total_v_gap <- gap_y * max(n_fill - 1, 0)
      usable_height <- 1 - total_v_gap
      sub$height <- sub$cond_prop * usable_height

      y_pos <- numeric(n_fill)
      for (j in seq_len(n_fill)) {
        y_pos[j] <- if (j == 1) 0 else y_pos[j - 1] + sub$height[j - 1] + gap_y
      }
      sub$ymin <- y_pos
      sub$ymax <- sub$ymin + sub$height

      x_info <- x_totals[x_totals$x_var == lev, ]
      for (k in seq_len(nrow(sub))) {
        key <- paste(lev, sub$fill[k], sep = "\x01")
        tiles[[key]] <- list(
          xmin = x_info$xmin, xmax = x_info$xmax,
          ymin = sub$ymin[k], ymax = sub$ymax[k]
        )
      }
    }

    # Expand rows by weight and jitter within tile
    if (!is.na(seed)) set.seed(seed)

    result_list <- lapply(seq_len(nrow(data)), function(i) {
      w <- as.integer(round(data$weight[i]))
      if (w < 1) {
        return(NULL)
      }
      key <- paste(data$x_var[i], data$fill[i], sep = "\x01")
      tile <- tiles[[key]]
      if (is.null(tile)) {
        return(NULL)
      }
      # Jitter within tile bounds with padding
      pad <- 0.05
      xr <- tile$xmin + pad * (tile$xmax - tile$xmin) +
        runif(w) * (1 - 2 * pad) * (tile$xmax - tile$xmin)
      yr <- tile$ymin + pad * (tile$ymax - tile$ymin) +
        runif(w) * (1 - 2 * pad) * (tile$ymax - tile$ymin)
      data.frame(
        x = xr, y = yr,
        fill = rep(data$fill[i], w),
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
