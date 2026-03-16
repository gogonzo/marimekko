# Getting started with marimekko

## What is a marimekko plot?

A marimekko (or mosaic) plot is a two-dimensional visualization of a
contingency table. Each column represents a category of one variable,
and the segments within each column represent categories of a second
variable: - **Column widths** are proportional to the marginal counts of
the x variable. - **Segment heights** within each column are
proportional to the conditional counts of the fill variable given x.

The `marimekko` package provides this as a native ggplot2 layer, so you
can combine it with any other ggplot2 functionality (facets, themes,
annotations, etc.).

## Installation

``` r
# From CRAN
install.packages("marimekko")

# From GitHub (when published)
devtools::install_github("gogonzo/marimekko")
```

## Your first marimekko plot

The built-in `Titanic` dataset records survival counts by class, sex,
and age. Let’s visualize survival by passenger class.

``` r
library(ggplot2)
library(marimekko)

titanic <- as.data.frame(Titanic)

ggplot(titanic) +
  geom_marimekko(aes(fill = Survived, weight = Freq), formula = ~ Class | Survived) +
  labs(title = "Titanic survival by class")
```

![](getting-started_files/figure-html/basic-1.png)

Two components are at work:

1.  **[`geom_marimekko()`](../reference/geom_marimekko.md)** computes
    tile positions from your data. The `formula` defines the variables
    (columns and segments), `fill` defines the segment colours, and
    `weight` provides the counts. Axis labels are automatically added.
2.  Standard ggplot2 functions
    ([`labs()`](https://ggplot2.tidyverse.org/reference/labs.html),
    [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html),
    etc.) work as usual.

## Aesthetics

[`geom_marimekko()`](../reference/geom_marimekko.md) understands these
aesthetics and parameters:

| Parameter / Aesthetic | Required | Description                                                                  |
|-----------------------|----------|------------------------------------------------------------------------------|
| `formula`             | yes      | Formula specifying variables, e.g. `~ X \| Y`                                |
| `fill`                | no       | Categorical variable for segment colours (defaults to last formula variable) |
| `weight`              | no       | Numeric weight/count (default 1)                                             |

If your data already has one row per observation (no aggregation
needed), omit `weight`:

``` r
ggplot(mtcars) +
  geom_marimekko(aes(fill = factor(gear)),
    formula = ~ cyl | gear
  )
```

![](getting-started_files/figure-html/unweighted-1.png)

## Gap control

The `gap` parameter controls spacing between tiles as a fraction of the
plot area. Default is `0.01`.

``` r
ggplot(titanic) +
  geom_marimekko(aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived, gap = 0.03
  ) +
  labs(title = "Wider gaps (gap = 0.03)")
```

![](getting-started_files/figure-html/gap-1.png)

Set `gap = 0` for a seamless mosaic:

``` r
ggplot(titanic) +
  geom_marimekko(aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived, gap = 0
  ) +
  labs(title = "No gaps")
```

![](getting-started_files/figure-html/no-gap-1.png)

## Marginal percentages

[`geom_marimekko()`](../reference/geom_marimekko.md) can append marginal
percentages to the x-axis labels via the `show_percentages` parameter:

``` r
ggplot(titanic) +
  geom_marimekko(aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived,
    show_percentages = TRUE
  )
```

![](getting-started_files/figure-html/pct-1.png)

## Adding text labels

Use [`geom_marimekko_text()`](../reference/geom_marimekko_text.md) (or
[`geom_marimekko_label()`](../reference/geom_marimekko_label.md) for a
boxed version) to place labels at tile centers. Tile positions are read
automatically from the preceding
[`geom_marimekko()`](../reference/geom_marimekko.md) layer — only the
`label` aesthetic is needed. Reference computed variables via
[`after_stat()`](https://ggplot2.tidyverse.org/reference/aes_eval.html):

- `weight` – the aggregated count for the tile
- `cond_prop` / `.proportion` – the conditional proportion within the
  parent
- `.residuals` – Pearson residual
- Original variable columns (e.g. `Class`, `Survived`)

``` r
ggplot(titanic) +
  geom_marimekko(aes(fill = Survived, weight = Freq), formula = ~ Class | Survived) +
  geom_marimekko_text(aes(label = after_stat(weight)), colour = "white") +
  labs(title = "Counts inside tiles")
```

![](getting-started_files/figure-html/text-labels-1.png)

Percentage labels:

``` r
ggplot(titanic) +
  geom_marimekko(aes(fill = Survived, weight = Freq), formula = ~ Class | Survived) +
  geom_marimekko_text(aes(
    label = after_stat(paste0(round(cond_prop * 100), "%"))
  ), colour = "white", size = 3)
```

![](getting-started_files/figure-html/pct-labels-1.png)

## Theming

[`theme_marimekko()`](../reference/theme_marimekko.md) provides a clean,
minimal theme that removes distracting x-axis gridlines:

``` r
ggplot(titanic) +
  geom_marimekko(aes(fill = Survived, weight = Freq), formula = ~ Class | Survived) +
  theme_marimekko() +
  labs(title = "With theme_marimekko()")
```

![](getting-started_files/figure-html/theme-1.png)

Since it builds on
[`theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
you can override any element:

``` r
ggplot(titanic) +
  geom_marimekko(aes(fill = Survived, weight = Freq), formula = ~ Class | Survived) +
  theme_marimekko() +
  theme(legend.position = "bottom")
```

![](getting-started_files/figure-html/theme-custom-1.png)

## Faceting

[`geom_marimekko()`](../reference/geom_marimekko.md) supports ggplot2
faceting. Each panel gets its own independently proportioned mosaic:

``` r
ggplot(as.data.frame(Titanic)) +
  geom_marimekko(aes(fill = Survived, weight = Freq), formula = ~ Class | Survived) +
  facet_wrap(~Sex) +
  labs(title = "Survival by class, faceted by sex")
```

![](getting-started_files/figure-html/facet-1.png)

## Next steps

See [`vignette("advanced-features")`](../articles/advanced-features.md)
for spine plots, Pearson residuals, three-variable mosaics, and
programmatic data extraction with
[`fortify_marimekko()`](../reference/fortify_marimekko.md).
