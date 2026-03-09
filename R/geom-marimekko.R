#' Generalized mosaic plot with formula-based variable nesting
#'
#' @include marimekko-package.R
#'
#' `geom_marimekko()` creates mosaic plots with arbitrary nesting
#' depth. A one-sided formula controls both the **order** in which
#' variables partition the plot area and the **direction** (horizontal
#' or vertical) of each split. The first split is always horizontal;
#' use `coord_flip()` if you need vertical-first orientation.
#'
#' @section How the formula works:
#'
#' The formula uses two operators to encode the full partitioning
#' hierarchy in a single expression:
#'
#' \describe{
#'   \item{`|` (pipe)}{Separates nesting levels. Each `|` switches the
#'     splitting direction, alternating horizontal, vertical, horizontal,
#'     vertical, and so on. The first variable (or group) listed is the
#'     **outermost** split — it partitions the entire plot area. Each
#'     subsequent level partitions the tiles created by the previous
#'     level.}
#'   \item{`+` (plus)}{Groups variables at the **same** nesting level.
#'     All variables joined by `+` share the same splitting direction
#'     and are applied sequentially within that level. The first `+`
#'     variable partitions the current tiles, then the second `+`
#'     variable further subdivides those tiles, still in the same
#'     direction.}
#' }
#'
#' @section Reading order — outermost to innermost:
#'
#' The formula is read left to right, from the coarsest (outermost)
#' partition to the finest (innermost):
#'
#' \describe{
#'   \item{`~ a | b`}{First split the plot horizontally by `a`
#'     (columns whose widths reflect marginal proportions of `a`).
#'     Then, within each column, split vertically by `b` (rows whose
#'     heights reflect conditional proportions of `b` given `a`).
#'     This is the classic two-variable marimekko / mosaic plot.}
#'   \item{`~ a | b | c`}{Horizontal by `a`, then vertical by `b`,
#'     then horizontal again by `c`. Three levels of nesting with
#'     alternating directions (h \eqn{\to} v \eqn{\to} h).}
#'   \item{`~ a + b | c`}{Horizontal by `a`, then horizontal again
#'     by `b` (same direction because `+` groups them), then vertical
#'     by `c`. This is the **double decker** pattern — all horizontal
#'     splits first, with a single vertical split at the end.}
#'   \item{`~ a | b + c`}{Horizontal by `a`, then vertical by `b`,
#'     then vertical again by `c`. Two vertical variables nested
#'     within each column.}
#' }
#'
#' @section Comparison with other packages:
#'
#' Unlike `vcd::mosaic()` which uses a formula for variables and a
#' separate `direction` vector for split directions, or
#' `ggmosaic::geom_mosaic()` which uses `product()` with a `divider`
#' parameter, `geom_marimekko()` encodes both variable order
#' and direction in a single formula. The `|` operator makes the
#' alternating pattern explicit and readable.
#'
#' @param mapping Aesthetic mapping. Optionally accepts `fill` and
#'   `weight` for pre-aggregated data. If `fill` is not specified,
#'   it defaults to the last variable in the formula. The `fill`
#'   variable controls tile colour and does not need to appear in
#'   the formula.
#' @param data A data frame.
#' @param formula A one-sided formula specifying the mosaic hierarchy.
#'   See the sections above for a detailed explanation.
#'
#'   Quick reference:
#'   - `~ a | b` — h(a), v(b). Standard mosaic.
#'   - `~ a | b | c` — h(a), v(b), h(c). Alternating mosaic.
#'   - `~ a + b | c` — h(a), h(b), v(c). Double decker.
#'   - `~ a | b + c` — h(a), v(b), v(c). Multiple vertical variables.
#' @param gap Numeric. Gap between tiles as fraction of plot area.
#'   Default `0.01`.
#' @param gap_x Numeric. Horizontal gap override. Default `NULL` (uses
#'   `gap`).
#' @param gap_y Numeric. Vertical gap override. Default `NULL` (uses
#'   `gap`).
#' @param colour Tile border colour. Default `NULL` (no border).
#'   Can also be mapped via `aes(colour = variable)`.
#' @param alpha Tile transparency. Default `0.9`.
#' @param show_percentages Logical. If `TRUE`, appends marginal
#'   percentage to each x-axis label. Default `FALSE`.
#' @param na.rm Logical. Remove missing values. Default `FALSE`.
#' @param show.legend Logical. Show legend. Default `NA`.
#' @param inherit.aes Logical. Inherit aesthetics from `ggplot()`.
#'   Default `TRUE`.
#' @param ... Additional arguments passed to the layer.
#'
#' @section Computed variables:
#'
#' The stat computes the following variables that can be accessed with
#' [ggplot2::after_stat()]:
#'
#' \describe{
#'   \item{`.proportion`}{Conditional proportion of the tile within its
#'     immediate parent. For a formula `~ a | b`, this is the proportion
#'     of `b` within each level of `a`, i.e. \eqn{P(b \mid a)}.
#'     Values sum to 1 within each parent tile. Useful for mapping to
#'     `alpha` to fade tiles by their local share:
#'     `aes(alpha = after_stat(.proportion))`.}
#'   \item{`.marginal`}{Joint (marginal) proportion of the tile relative to
#'     the whole dataset, i.e. \eqn{n_\text{cell} / N}. Values sum to 1
#'     across all tiles. Used internally for x-axis percentage labels when
#'     `show_percentages = TRUE`, and can be mapped to aesthetics to
#'     emphasise cells by overall frequency.}
#'   \item{`.residuals`}{Pearson residual measuring departure from statistical
#'     independence between the horizontal and vertical variable groups.
#'     Computed as \eqn{(O - E) / \sqrt{E}}, where \eqn{O} is the observed
#'     cell count and \eqn{E} is the count expected under independence.
#'     Positive values indicate the cell is **more** frequent than expected;
#'     negative values indicate **less** frequent. When only one direction
#'     (all horizontal or all vertical) is present, `.residuals` is set to 0.
#'     Map to `alpha` or `fill` to highlight deviations:
#'     `aes(alpha = after_stat(abs(.residuals)))`.}
#' }
#'
#' @return A list of ggplot2 layers (geom + axis scales).
#'
#' @examples
#' library(ggplot2)
#'
#' titanic <- as.data.frame(Titanic)
#'
#' # 2-variable mosaic
#' ggplot(titanic) +
#'   geom_marimekko(
#'     aes(fill = Survived, weight = Freq),
#'     formula = ~ Class | Survived
#'   )
#'
#' # 3-variable mosaic (h -> v -> h)
#' ggplot(titanic) +
#'   geom_marimekko(
#'     aes(fill = Survived, weight = Freq),
#'     formula = ~ Class | Survived | Sex
#'   )
#'
#' # Multi-variable fill with interaction()
#' ggplot(titanic) +
#'   geom_marimekko(
#'     aes(fill = interaction(Sex, Survived), weight = Freq),
#'     formula = ~ Class | Sex + Survived
#'   )
#'
#' # Fade tiles by conditional proportion
#' ggplot(titanic) +
#'   geom_marimekko(
#'     aes(fill = Survived, alpha = after_stat(.proportion), weight = Freq),
#'     formula = ~ Class | Survived
#'   ) +
#'   guides(alpha = "none")
#'
#' # Highlight cells that deviate from independence
#' ggplot(titanic) +
#'   geom_marimekko(
#'     aes(fill = Survived, alpha = after_stat(abs(.residuals)), weight = Freq),
#'     formula = ~ Class | Survived
#'   ) +
#'   guides(alpha = "none")
#'
#' @export
geom_marimekko <- function(mapping = NULL, data = NULL,
                           formula = NULL,
                           gap = 0.01,
                           gap_x = NULL,
                           gap_y = NULL,
                           colour = NULL,
                           alpha = 0.9,
                           show_percentages = FALSE,
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE,
                           ...) {
  if (is.null(formula)) {
    stop("`formula` is required. Example: formula = ~ Class | Survived")
  }

  # Parse formula into variable groups and assign directions
  formula_groups <- .parse_mosaic_formula(formula)
  variable_specs <- .assign_mosaic_directions(formula_groups)
  variable_names <- vapply(variable_specs, function(spec) spec$var, character(1))
  variable_directions <- vapply(variable_specs, function(spec) spec$dir, character(1))
  variable_exprs <- lapply(variable_specs, function(spec) spec$expr)

  # Add formula variables to mapping as hidden aesthetics
  if (is.null(mapping)) mapping <- aes()

  # Default fill to last formula variable if not specified
  if (!"fill" %in% names(mapping)) {
    mapping[["fill"]] <- variable_exprs[[length(variable_exprs)]]
  }

  for (i in seq_along(variable_exprs)) {
    mapping[[paste0("mvar_", i)]] <- variable_exprs[[i]]
  }

  params <- list(
    mosaic_vars = variable_names,
    mosaic_dirs = variable_directions,
    gap = gap,
    gap_x = gap_x,
    gap_y = gap_y,
    na.rm = na.rm,
    ...
  )
  # colour: if explicitly provided, use as fixed param;

  # if not provided and not mapped via aes(), default to NA (no border)
  if (!is.null(colour)) {
    params$colour <- colour
  } else if (!"colour" %in% names(mapping)) {
    params$colour <- NA
  }
  # Only set alpha as a fixed param when not mapped as an aesthetic
  if (!"alpha" %in% names(mapping)) {
    params$alpha <- alpha
  }

  .x_breaks_fn <- function(limits) {
    info <- .marimekko_env$labels
    if (is.null(info)) {
      return(waiver())
    }
    info$x_mid
  }

  .x_labels_fn <- function(breaks) {
    info <- .marimekko_env$labels
    if (is.null(info)) {
      return(waiver())
    }
    if (show_percentages) {
      paste0(info$label, "\n(", round(info$pct * 100, 1), "%)")
    } else {
      info$label
    }
  }

  .y_breaks_fn <- function(limits) {
    info <- .marimekko_env$y_labels
    if (is.null(info)) {
      return(waiver())
    }
    info$y_mid
  }

  .y_labels_fn <- function(breaks) {
    info <- .marimekko_env$y_labels
    if (is.null(info)) {
      return(waiver())
    }
    info$label
  }

  # Build automatic axis labels from formula variables
  h_vars <- variable_names[variable_directions == "h"]
  v_vars <- variable_names[variable_directions == "v"]
  x_lab <- if (length(h_vars) > 0) paste(h_vars, collapse = " : ") else waiver()
  y_lab <- if (length(v_vars) > 0) paste(v_vars, collapse = " : ") else waiver()

  result <- list(
    layer(
      data = data,
      mapping = mapping,
      stat = StatMarimekko,
      geom = GeomRect,
      position = "identity",
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = params
    ),
    scale_x_continuous(
      breaks = .x_breaks_fn,
      labels = .x_labels_fn,
      expand = expansion(mult = 0.01)
    ),
    labs(x = x_lab, y = y_lab)
  )

  if (length(v_vars) > 0) {
    result <- c(result, list(
      scale_y_continuous(
        breaks = .y_breaks_fn,
        labels = .y_labels_fn,
        expand = expansion(mult = 0.01)
      )
    ))
  }

  result
}

# --- Formula parsing ---

# Walks the | tree to find groups, then extracts + variables within groups
.parse_mosaic_formula <- function(formula) {
  if (!inherits(formula, "formula")) {
    stop("`formula` must be a formula. Example: ~ Class | Survived")
  }
  if (length(formula) == 3L) {
    stop(
      "Formula must be one-sided (right-hand side only). ",
      "Use `~ a | b`, not `a ~ b`."
    )
  }
  if (length(formula) < 2L || length(all.vars(formula)) == 0L) {
    stop("Formula must contain at least one variable. Example: ~ Class | Survived")
  }
  right_hand_side <- formula[[2]]
  groups <- list()

  .walk_pipe_operator <- function(expression) {
    if (is.call(expression) && identical(expression[[1]], as.symbol("|"))) {
      .walk_pipe_operator(expression[[2]])
      .walk_pipe_operator(expression[[3]])
    } else {
      groups[[length(groups) + 1]] <<- .extract_plus_variables(expression)
    }
  }

  .extract_plus_variables <- function(expression) {
    if (is.call(expression) && identical(expression[[1]], as.symbol("+"))) {
      c(.extract_plus_variables(expression[[2]]), .extract_plus_variables(expression[[3]]))
    } else {
      list(expression)
    }
  }

  .walk_pipe_operator(right_hand_side)
  groups
}

# Assign h/v directions: groups alternate, variables within a group share direction
.assign_mosaic_directions <- function(groups) {
  direction_cycle <- c("h", "v")
  result <- list()
  for (group_index in seq_along(groups)) {
    direction <- direction_cycle[((group_index - 1) %% 2) + 1]
    for (expr in groups[[group_index]]) {
      result[[length(result) + 1]] <- list(
        var = deparse(expr),
        dir = direction,
        expr = expr
      )
    }
  }
  result
}

# --- Recursive partitioning ---

.recursive_mosaic <- function(data, variable_specs, variable_names,
                              xmin, xmax, ymin, ymax,
                              gap_x, gap_y, level = 1L,
                              parent_weight = NA_real_,
                              root_weight = NA_real_) {
  if (level > length(variable_specs)) {
    # Leaf tile — no more variables to partition by
    total_weight <- sum(data$weight)
    tile <- data.frame(
      xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
      weight = total_weight,
      fill = data$fill[1],
      colour = if ("colour" %in% names(data)) data$colour[1] else NA,
      .proportion = if (is.na(parent_weight) || parent_weight == 0) {
        NA_real_
      } else {
        total_weight / parent_weight
      },
      .marginal = if (is.na(root_weight) || root_weight == 0) {
        NA_real_
      } else {
        total_weight / root_weight
      },
      stringsAsFactors = FALSE
    )
    # Store each variable's value at this leaf
    for (name in variable_names) {
      tile[[name]] <- as.character(data[[name]][1])
    }
    return(tile)
  }

  current_spec <- variable_specs[[level]]
  current_variable <- current_spec$var
  current_direction <- current_spec$dir

  factor_levels <- levels(data[[current_variable]])
  weight_per_level <- tapply(data$weight, data[[current_variable]], sum)
  weight_per_level[is.na(weight_per_level)] <- 0
  total_weight <- sum(weight_per_level)
  if (total_weight == 0) {
    return(NULL)
  }
  proportions <- weight_per_level / total_weight

  non_empty_levels <- factor_levels[weight_per_level > 0]
  num_non_empty <- length(non_empty_levels)

  current_gap <- if (current_direction == "h") gap_x else gap_y
  total_gap_space <- current_gap * max(num_non_empty - 1, 0)

  is_horizontal <- current_direction == "h"
  usable_span <- (if (is_horizontal) xmax - xmin else ymax - ymin) - total_gap_space
  origin <- if (is_horizontal) xmin else ymin

  tile_spans <- proportions[non_empty_levels] * usable_span
  tile_starts <- origin + cumsum(c(0, tile_spans[-length(tile_spans)])) +
    current_gap * seq(0, num_non_empty - 1)

  tiles <- Map(function(level_value, start, span) {
    subset_data <- data[data[[current_variable]] == level_value, , drop = FALSE]
    if (is_horizontal) {
      tile_bounds <- list(start, start + span, ymin, ymax)
    } else {
      tile_bounds <- list(xmin, xmax, start, start + span)
    }
    .recursive_mosaic(
      subset_data, variable_specs, variable_names,
      tile_bounds[[1]], tile_bounds[[2]], tile_bounds[[3]], tile_bounds[[4]],
      gap_x, gap_y, level + 1L,
      parent_weight = total_weight,
      root_weight = root_weight
    )
  }, non_empty_levels, tile_starts, tile_spans)

  do.call(rbind, tiles)
}

# --- Stat ---

StatMarimekko <- ggproto("StatMarimekko", Stat,
  required_aes = "fill",
  default_aes = aes(weight = 1),
  optional_aes = paste0("mvar_", 1:10),
  dropped_aes = c("weight", paste0("mvar_", 1:10)),
  setup_params = function(data, params) {
    params$gap <- params$gap %||% 0.01
    params$gap_x <- params$gap_x %||% params$gap
    params$gap_y <- params$gap_y %||% params$gap
    .marimekko_env$labels <- NULL
    .marimekko_env$y_labels <- NULL
    .marimekko_env$tiles <- NULL
    params
  },
  compute_panel = function(data, scales,
                           mosaic_vars = character(0),
                           mosaic_dirs = character(0),
                           gap = 0.01, gap_x = NULL, gap_y = NULL) {
    gap_x <- gap_x %||% gap
    gap_y <- gap_y %||% gap

    num_variables <- length(mosaic_vars)
    variable_specs <- mapply(
      function(variable, direction) list(var = variable, dir = direction),
      mosaic_vars, mosaic_dirs,
      SIMPLIFY = FALSE, USE.NAMES = FALSE
    )
    variable_names <- mosaic_vars

    # Map hidden aes columns to variable names and factorise
    for (i in seq_len(num_variables)) {
      data[[variable_names[i]]] <- as.factor(data[[paste0("mvar_", i)]])
    }
    data$fill <- as.factor(data$fill)
    if ("colour" %in% names(data)) {
      data$colour <- as.factor(data$colour)
    }

    if (is.null(data$weight) || all(is.na(data$weight))) {
      data$weight <- 1
    }

    # Recursive partition
    total_weight <- sum(data$weight)
    tiles <- .recursive_mosaic(
      data, variable_specs, variable_names,
      xmin = 0, xmax = 1, ymin = 0, ymax = 1,
      gap_x = gap_x, gap_y = gap_y,
      parent_weight = total_weight,
      root_weight = total_weight
    )

    if (is.null(tiles) || nrow(tiles) == 0) {
      return(data.frame())
    }

    # Tile centres
    tiles$x <- (tiles$xmin + tiles$xmax) / 2
    tiles$y <- (tiles$ymin + tiles$ymax) / 2
    tiles$group <- as.integer(as.factor(tiles$fill))

    # Pearson residuals: cross-tabulate h-vars x v-vars
    h_vars <- variable_names[mosaic_dirs == "h"]
    v_vars <- variable_names[mosaic_dirs == "v"]
    if (length(h_vars) > 0 && length(v_vars) > 0) {
      h_key <- do.call(paste, c(lapply(h_vars, function(v) tiles[[v]]), list(sep = ":")))
      v_key <- do.call(paste, c(lapply(v_vars, function(v) tiles[[v]]), list(sep = ":")))
      h_levels <- unique(h_key)
      v_levels <- unique(v_key)
      ct <- matrix(0,
        nrow = length(h_levels), ncol = length(v_levels),
        dimnames = list(h_levels, v_levels)
      )
      for (k in seq_len(nrow(tiles))) {
        ct[h_key[k], v_key[k]] <- ct[h_key[k], v_key[k]] + tiles$weight[k]
      }
      row_sums <- rowSums(ct)
      col_sums <- colSums(ct)
      grand <- sum(ct)
      expected <- outer(row_sums, col_sums) / grand
      pr <- (ct - expected) / sqrt(pmax(expected, .Machine$double.eps))
      tiles$.residuals <- vapply(seq_len(nrow(tiles)), function(k) {
        pr[h_key[k], v_key[k]]
      }, numeric(1))
    } else {
      tiles$.residuals <- 0
    }

    # --- x-axis labels: composite of all h-variable values ---
    horizontal_vars <- variable_names[mosaic_dirs == "h"]
    if (length(horizontal_vars) > 0) {
      horizontal_label <- do.call(paste, c(
        lapply(horizontal_vars, function(variable) tiles[[variable]]),
        list(sep = ":")
      ))
      x_label_data <- data.frame(
        x_mid = tiles$x,
        label = horizontal_label,
        stringsAsFactors = FALSE
      )
      x_label_data$pct <- tiles$.marginal
      x_label_data <- do.call(rbind, lapply(split(x_label_data, x_label_data$label), function(d) {
        data.frame(
          x_mid = d$x_mid[1],
          label = d$label[1],
          pct = sum(d$pct),
          stringsAsFactors = FALSE
        )
      }))
      rownames(x_label_data) <- NULL
      .marimekko_env$labels <- x_label_data
    }

    # --- y-axis labels: composite of all v-variable values ---
    vertical_vars <- variable_names[mosaic_dirs == "v"]
    if (length(vertical_vars) > 0) {
      vertical_label <- do.call(paste, c(
        lapply(vertical_vars, function(variable) tiles[[variable]]),
        list(sep = ":")
      ))
      y_label_data <- data.frame(
        y_mid = tiles$y,
        label = vertical_label,
        stringsAsFactors = FALSE
      )
      y_label_data <- y_label_data[!duplicated(y_label_data$label), , drop = FALSE]
      .marimekko_env$y_labels <- y_label_data
    }

    # Add PANEL
    if ("PANEL" %in% names(data)) {
      tiles$PANEL <- data$PANEL[1]
    }

    # Clean up: drop mvar_ columns
    for (i in seq_len(num_variables)) {
      tiles[[paste0("mvar_", i)]] <- NULL
    }

    # Cache tiles for companion layers (text, label, and more)
    panel_id <- if ("PANEL" %in% names(tiles)) as.character(tiles$PANEL[1]) else "1"
    if (is.null(.marimekko_env$tiles)) {
      .marimekko_env$tiles <- list()
    }
    .marimekko_env$tiles[[panel_id]] <- tiles

    tiles
  }
)
