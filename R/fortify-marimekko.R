#' Compute marimekko tile rectangles as a data frame
#'
#' @include geom-marimekko.R
#'
#' `fortify_marimekko()` returns the computed tile positions without
#' plotting. Useful for custom downstream analysis or manual layer
#' construction with arbitrary ggplot2 geoms.
#'
#' @param data A data frame.
#' @param formula A one-sided formula specifying the mosaic hierarchy,
#'   using the same syntax as [geom_marimekko()].
#'   Example: `~ Class | Survived`.
#' @param weight Name of the weight variable (unquoted or string), or
#'   `NULL` for unweighted counts. Default `NULL`.
#' @param gap Numeric. Size of gap between tiles. Default `0.01`.
#' @param gap_x Numeric. Horizontal gap. Overrides `gap` for x. Default `NULL`.
#' @param gap_y Numeric. Vertical gap. Overrides `gap` for y. Default `NULL`.
#' @param standardize Logical. Equal-width columns. Default `FALSE`.
#'
#' @return A data frame with columns for each formula variable, plus
#'   `fill`, `colour`, `xmin`, `xmax`, `ymin`, `ymax`, `x`, `y`,
#'   `weight`, `.proportion`, `.marginal`, and `.residuals`.
#'
#' @examples
#' titanic <- as.data.frame(Titanic)
#' fortify_marimekko(titanic, formula = ~ Class | Survived, weight = Freq)
#'
#' # 3-variable formula
#' fortify_marimekko(titanic, formula = ~ Class | Survived | Sex, weight = Freq)
#'
#' @export
fortify_marimekko <- function(data, formula,
                              weight = NULL,
                              gap = 0.01, gap_x = NULL, gap_y = NULL,
                              standardize = FALSE) {
  weight_expr <- substitute(weight)

  # Resolve weight column
  if (!is.null(weight_expr) && !identical(weight_expr, quote(NULL))) {
    weight_col <- as.character(weight_expr)
    weight_values <- data[[weight_col]]
  } else {
    weight_values <- rep(1, nrow(data))
  }

  # Parse formula (reuse geom_marimekko internals)
  formula_groups <- .parse_mosaic_formula(formula)
  variable_specs <- .assign_mosaic_directions(formula_groups)
  variable_names <- vapply(variable_specs, function(s) s$var, character(1))
  variable_dirs <- vapply(variable_specs, function(s) s$dir, character(1))

  # Build data frame with mvar_ columns (same structure as StatMarimekko expects)
  df <- data.frame(PANEL = rep(1L, nrow(data)), weight = weight_values)
  for (i in seq_along(variable_specs)) {
    df[[paste0("mvar_", i)]] <- eval(variable_specs[[i]]$expr, envir = data)
  }

  # Default fill and colour to last variable
  last_expr <- variable_specs[[length(variable_specs)]]$expr
  df$fill <- eval(last_expr, envir = data)
  df$colour <- df$fill

  result <- StatMarimekko$compute_panel(
    data = df,
    scales = NULL,
    mosaic_vars = variable_names,
    mosaic_dirs = variable_dirs,
    gap = gap,
    gap_x = gap_x,
    gap_y = gap_y
  )

  # Drop internal columns
  drop <- c("group", "PANEL")
  result[, setdiff(names(result), drop), drop = FALSE]
}
