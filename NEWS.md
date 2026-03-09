# marimekko 0.1.0

* Initial CRAN release.

## New features

* `geom_marimekko()` — formula-based mosaic/marimekko plots as a ggplot2 layer.
  One-sided formulas (`~ a | b`) encode both variable hierarchy and split
  direction. `|` alternates between horizontal and vertical splits; `+` groups
  variables in the same direction.
* `geom_marimekko_text()` and `geom_marimekko_label()` — place text or
  label annotations at tile centres, with access to computed variables via
 `after_stat()`.
* `geom_marimekko_jitter()` — scatter jittered points within each tile,
  scaled to cell counts.
* `fortify_marimekko()` — extract tile rectangles as a data frame without
  plotting.
* `theme_marimekko()` — a minimal theme designed for mosaic plots.
* `marimekko_pal` — a categorical colour palette.

## Computed variables

* `.proportion` — conditional proportion within the parent tile.
* `.marginal` — joint proportion relative to the whole dataset.
* `.residuals` — Pearson residuals measuring departure from independence.

## Other

* `show_percentages = TRUE` appends marginal percentages to x-axis labels.
* Independent gap control via `gap_x` and `gap_y`.
* Formulas support arbitrary R expressions (e.g., `~ factor(cyl) | cut(mpg, 3)`).
* Compatible with `facet_wrap()`, `facet_grid()`, and `plotly::ggplotly()`.
