# Jitter individual observations within Marimekko tiles

Jitter individual observations within Marimekko tiles

## Usage

``` r
geom_mekko_jitter(
  mapping = NULL,
  data = NULL,
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
  inherit.aes = FALSE
)

StatMarimekkoJitter
```

## Format

An object of class `StatMarimekkoJitter` (inherits from `Stat`,
`ggproto`, `gg`) of length 6.

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).
  Requires `x` (categorical) and `fill` (categorical). Optionally
  accepts `weight` for weighted counts.

- data:

  The data to be displayed in this layer.

- position:

  Position adjustment. Defaults to `"identity"`.

- ...:

  Other arguments passed to
  [`ggplot2::layer()`](https://ggplot2.tidyverse.org/reference/layer.html).

- gap:

  Numeric. Size of gap between tiles as a fraction of total plot area.
  Default `0.01`. Set to `0` for no gaps. Used for both horizontal and
  vertical gaps unless `gap_x` or `gap_y` is specified.

- gap_x:

  Numeric. Horizontal gap between columns. Overrides `gap` for the x
  direction. Default `NULL` (uses `gap`).

- gap_y:

  Numeric. Vertical gap between segments within columns. Overrides `gap`
  for the y direction. Default `NULL` (uses `gap`).

- standardize:

  Logical. If `TRUE`, all columns have equal width (spine plot mode).
  Default `FALSE`.

- size:

  Point size. Default `1`.

- alpha:

  Point transparency. Default `0.5`.

- shape:

  Point shape. Default `16` (filled circle).

- colour:

  Point colour. Default `"black"`.

- seed:

  Random seed for reproducible jitter. Default `NA` (different each
  time).

- na.rm:

  If `FALSE` (default), removes missing values with a warning.

- show.legend:

  Logical. Should this layer be included in legends?

- inherit.aes:

  Logical. If `FALSE`, overrides default aesthetics.

## Value

A ggplot2 layer.

## Examples

``` r
library(ggplot2)

# Small dataset: UCBAdmissions Dept A
ucb <- as.data.frame(UCBAdmissions)
ucb_a <- ucb[ucb$Dept == "A", ]
ggplot(ucb_a) +
  geom_mekko(aes(x = Gender, fill = Admit, weight = Freq)) +
  geom_mekko_jitter(aes(x = Gender, fill = Admit, weight = Freq)) +
  scale_x_mekko()

```
