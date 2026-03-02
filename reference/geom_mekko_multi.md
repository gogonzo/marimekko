# Multi-variable Marimekko plot with nested splits

Multi-variable Marimekko plot with nested splits

## Usage

``` r
geom_mekko_multi(
  mapping = NULL,
  data = NULL,
  position = "identity",
  ...,
  gap = 0.01,
  gap_x = NULL,
  gap_y = NULL,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

StatMarimekkoMulti
```

## Format

An object of class `StatMarimekkoMulti` (inherits from `Stat`,
`ggproto`, `gg`) of length 6.

## Arguments

- mapping:

  Requires `x`, `fill`, and `split` (all categorical). Optionally
  accepts `weight`.

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

titanic <- as.data.frame(Titanic)
ggplot(titanic) +
  geom_mekko_multi(aes(
    x = Class, split = Sex, fill = Survived, weight = Freq
  )) +
  scale_x_mekko()

```
