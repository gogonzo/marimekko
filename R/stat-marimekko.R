#' @include marimekko-package.R
#' @keywords internal
StatmarimekkoBase <- ggproto("StatmarimekkoBase", Stat,
  required_aes = c("x_var", "fill"),
  default_aes = aes(weight = 1),
  dropped_aes = c("weight", "x_var"),
  setup_params = function(data, params) {
    params$gap <- params$gap %||% 0.01
    params$gap_x <- params$gap_x %||% params$gap
    params$gap_y <- params$gap_y %||% params$gap
    params$standardize <- params$standardize %||% FALSE
    params$residuals <- params$residuals %||% FALSE
    # Clear label caches at the start of each plot build
    .marimekko_env$labels <- NULL
    .marimekko_env$y_labels <- NULL
    params
  },
  compute_panel = function(data, scales, gap = 0.01, gap_x = NULL,
                           gap_y = NULL, standardize = FALSE,
                           residuals = FALSE) {
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

    # Aggregate weighted counts per (x_var, fill) combination
    counts <- aggregate(
      weight ~ x_var + fill,
      data = data,
      FUN = sum,
      drop = FALSE
    )
    counts$weight[is.na(counts$weight)] <- 0

    # Marginal totals per x_var
    x_totals <- aggregate(weight ~ x_var, data = counts, FUN = sum)
    grand_total <- sum(x_totals$weight)
    x_totals$prop <- x_totals$weight / grand_total

    # Horizontal layout with gaps
    total_h_gap <- gap_x * max(n_x - 1, 0)
    usable_width <- 1 - total_h_gap

    if (standardize) {
      # Equal-width columns (spine plot)
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
    x_totals$x_mid <- (x_totals$xmin + x_totals$xmax) / 2

    # Compute Pearson residuals if requested
    pearson_resid <- NULL
    if (residuals) {
      # Build contingency table
      ct <- matrix(0,
        nrow = n_x, ncol = length(fill_levels),
        dimnames = list(x_levels, fill_levels)
      )
      for (r in seq_len(nrow(counts))) {
        ct[as.character(counts$x_var[r]), as.character(counts$fill[r])] <-
          counts$weight[r]
      }
      # Expected values under independence
      row_sums <- rowSums(ct)
      col_sums <- colSums(ct)
      expected <- outer(row_sums, col_sums) / grand_total
      # Pearson residuals: (observed - expected) / sqrt(expected)
      pearson_resid <- (ct - expected) / sqrt(pmax(expected, .Machine$double.eps))
    }

    # Build rectangles: for each x_var level, stack fill segments vertically
    result_list <- lapply(x_levels, function(lev) {
      sub <- counts[counts$x_var == lev, , drop = FALSE]
      sub <- sub[sub$weight > 0, , drop = FALSE]
      if (nrow(sub) == 0) {
        return(NULL)
      }

      n_fill <- nrow(sub)
      col_total <- sum(sub$weight)
      sub$cond_prop <- sub$weight / col_total

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
      sub$xmin <- x_info$xmin
      sub$xmax <- x_info$xmax

      # Add Pearson residuals
      if (!is.null(pearson_resid)) {
        sub$.resid <- vapply(seq_len(nrow(sub)), function(k) {
          pearson_resid[as.character(sub$x_var[k]), as.character(sub$fill[k])]
        }, numeric(1))
      }

      sub
    })

    result <- do.call(rbind, result_list)

    # Add residual column (0 if not requested)
    if (is.null(result$.resid)) {
      result$.resid <- 0
    }

    # Store label info for scale_x_marimekko
    new_labels <- data.frame(
      x_mid = x_totals$x_mid,
      label = as.character(x_totals$x_var),
      pct = x_totals$prop,
      stringsAsFactors = FALSE
    )
    existing <- .marimekko_env$labels
    if (is.null(existing)) {
      .marimekko_env$labels <- new_labels
    } else {
      combined <- rbind(existing, new_labels)
      .marimekko_env$labels <- combined[!duplicated(combined$label), ]
    }

    # Store y-axis label info for scale_y_marimekko
    # Use midpoints from the first x column (representative)
    first_col <- result[result$xmin == min(result$xmin), , drop = FALSE]
    new_y_labels <- data.frame(
      y_mid = (first_col$ymin + first_col$ymax) / 2,
      label = as.character(first_col$fill),
      stringsAsFactors = FALSE
    )
    existing_y <- .marimekko_env$y_labels
    if (is.null(existing_y)) {
      .marimekko_env$y_labels <- new_y_labels
    } else {
      combined_y <- rbind(existing_y, new_y_labels)
      .marimekko_env$y_labels <- combined_y[!duplicated(combined_y$label), ]
    }

    # Tile center coordinates for geom_text compatibility
    result$x <- (result$xmin + result$xmax) / 2
    result$y <- (result$ymin + result$ymax) / 2

    # Preserve original category names for after_stat() labels
    result$x_label <- as.character(result$x_var)
    result$fill_label <- as.character(result$fill)

    # Tooltip text for plotly compatibility
    result$.tooltip <- paste0(
      result$x_label, " / ", result$fill_label, "\n",
      "Count: ", result$weight, "\n",
      "Proportion: ", round(result$cond_prop * 100, 1), "%"
    )

    result$group <- as.integer(result$fill)

    if ("PANEL" %in% names(data)) {
      result$PANEL <- data$PANEL[1]
    }

    # Drop x_var from output
    result$x_var <- NULL

    result
  }
)
