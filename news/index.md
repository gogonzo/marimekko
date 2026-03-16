# Changelog

## marimekko 0.1.0

CRAN release: 2026-03-16

- Initial CRAN release.

### New features

- [`geom_marimekko()`](../reference/geom_marimekko.md) — formula-based
  mosaic/marimekko plots as a ggplot2 layer. One-sided formulas
  (`~ a | b`) encode both variable hierarchy and split direction. `|`
  alternates between horizontal and vertical splits; `+` groups
  variables in the same direction.
- [`geom_marimekko_text()`](../reference/geom_marimekko_text.md) and
  [`geom_marimekko_label()`](../reference/geom_marimekko_label.md) —
  place text or label annotations at tile centres, with access to
  computed variables via
  [`after_stat()`](https://ggplot2.tidyverse.org/reference/aes_eval.html).
- [`fortify_marimekko()`](../reference/fortify_marimekko.md) — extract
  tile rectangles as a data frame without plotting.
- [`theme_marimekko()`](../reference/theme_marimekko.md) — a minimal
  theme designed for mosaic plots.
- `marimekko_pal` — a categorical colour palette.

### Computed variables

- `.proportion` — conditional proportion within the parent tile.
- `.marginal` — joint proportion relative to the whole dataset.
- `.residuals` — Pearson residuals measuring departure from
  independence.

### Other

- `show_percentages = TRUE` appends marginal percentages to x-axis
  labels.
- Independent gap control via `gap_x` and `gap_y`.
- Formulas support arbitrary R expressions (e.g.,
  `~ factor(cyl) | cut(mpg, 3)`).
- Compatible with
  [`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html),
  [`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html),
  and
  [`plotly::ggplotly()`](https://rdrr.io/pkg/plotly/man/ggplotly.html).
