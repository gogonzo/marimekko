#' Annotate a marimekko plot with a chi-squared test
#'
#' @include marimekko-package.R
#'
#' `annotate_chisq()` runs a chi-squared test of independence on the
#' contingency table defined by `x` and `fill` (weighted by `weight`)
#' and adds the test statistic and p-value as a text annotation.
#'
#' @param data A data frame.
#' @param x Name of the categorical x variable (unquoted or string).
#' @param fill Name of the categorical fill variable (unquoted or string).
#' @param weight Name of the weight variable (unquoted or string), or
#'   `NULL` for unweighted counts. Default `NULL`.
#' @param pos_x Numeric x position for annotation. Default `0.95`.
#' @param pos_y Numeric y position for annotation. Default `0.05`.
#' @param size Text size. Default `3`.
#' @param hjust Horizontal justification. Default `1`.
#' @param ... Additional arguments passed to [ggplot2::annotate()].
#'
#' @return A ggplot2 annotation layer.
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
#'   annotate_chisq(titanic, Class, Survived, weight = Freq)
#'
#' @export
annotate_chisq <- function(data, x, fill, weight = NULL,
                           pos_x = 0.95, pos_y = 0.05,
                           size = 3, hjust = 1, ...) {
  x_col <- as.character(substitute(x))
  fill_col <- as.character(substitute(fill))
  weight_expr <- substitute(weight)

  x_vals <- as.factor(data[[x_col]])
  fill_vals <- as.factor(data[[fill_col]])

  if (!is.null(weight_expr) && !identical(weight_expr, quote(NULL))) {
    weight_col <- as.character(weight_expr)
    w <- data[[weight_col]]
  } else {
    w <- rep(1, nrow(data))
  }

  # Build contingency table
  x_levels <- levels(x_vals)
  fill_levels <- levels(fill_vals)
  ct <- matrix(0,
    nrow = length(x_levels), ncol = length(fill_levels),
    dimnames = list(x_levels, fill_levels)
  )
  for (i in seq_len(nrow(data))) {
    ct[as.character(x_vals[i]), as.character(fill_vals[i])] <-
      ct[as.character(x_vals[i]), as.character(fill_vals[i])] + w[i]
  }

  test <- chisq.test(ct)

  label <- paste0(
    "X2 = ", round(test$statistic, 2),
    ", df = ", test$parameter,
    ", p ", if (test$p.value < 0.001) {
      "< 0.001"
    } else {
      paste0("= ", format(round(test$p.value, 4), nsmall = 4))
    }
  )

  annotate(
    "text",
    x = pos_x, y = pos_y,
    label = label,
    size = size,
    hjust = hjust,
    ...
  )
}
