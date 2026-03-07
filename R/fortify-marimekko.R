#' Compute marimekko tile rectangles as a data frame
#'
#' @include mekko-package.R
#'
#' `fortify_marimekko()` returns the computed tile positions without
#' plotting. Useful for custom downstream analysis or manual layer
#' construction.
#'
#' @param data A data frame.
#' @param x Name of the categorical x variable (unquoted or string).
#' @param fill Name of the categorical fill variable (unquoted or string).
#' @param weight Name of the weight variable (unquoted or string), or
#'   `NULL` for unweighted counts. Default `NULL`.
#' @param gap Numeric. Size of gap between tiles. Default `0.01`.
#' @param gap_x Numeric. Horizontal gap. Overrides `gap` for x. Default `NULL`.
#' @param gap_y Numeric. Vertical gap. Overrides `gap` for y. Default `NULL`.
#' @param standardize Logical. Equal-width columns. Default `FALSE`.
#' @param residuals Logical. Include Pearson residuals. Default `FALSE`.
#'
#' @return A data frame with columns: `x_label`, `fill_label`, `xmin`,
#'   `xmax`, `ymin`, `ymax`, `x`, `y`, `weight`, `cond_prop`, and
#'   optionally `.resid`.
#'
#' @examples
#' titanic <- as.data.frame(Titanic)
#' fortify_marimekko(titanic, Class, Survived, weight = Freq)
#' fortify_marimekko(titanic, Class, Survived, weight = Freq, residuals = TRUE)
#'
#' @export
fortify_marimekko <- function(data, x, fill, weight = NULL,
                              gap = 0.01, gap_x = NULL, gap_y = NULL,
                              standardize = FALSE,
                              residuals = FALSE) {
  x_col <- as.character(substitute(x))
  fill_col <- as.character(substitute(fill))
  weight_expr <- substitute(weight)

  df <- data.frame(
    x_var = as.factor(data[[x_col]]),
    fill = as.factor(data[[fill_col]]),
    stringsAsFactors = FALSE
  )

  if (!is.null(weight_expr) && !identical(weight_expr, quote(NULL))) {
    weight_col <- as.character(weight_expr)
    df$weight <- data[[weight_col]]
  } else {
    df$weight <- 1
  }

  df$PANEL <- 1L

  result <- StatmarimekkoBase$compute_panel(
    data = df,
    scales = NULL,
    gap = gap,
    gap_x = gap_x,
    gap_y = gap_y,
    standardize = standardize,
    residuals = residuals
  )

  keep <- c(
    "x_label", "fill_label", "xmin", "xmax", "ymin", "ymax",
    "x", "y", "weight", "cond_prop"
  )
  if (residuals) keep <- c(keep, ".resid")

  result[, intersect(keep, names(result)), drop = FALSE]
}
