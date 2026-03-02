# Create a Marimekko (mosaic) plot

Create a Marimekko (mosaic) plot

## Usage

``` r
StatMarimekko

geom_mekko(
  mapping = NULL,
  data = NULL,
  stat = "mekko",
  position = "identity",
  ...,
  gap = 0.01,
  gap_x = NULL,
  gap_y = NULL,
  standardize = FALSE,
  residuals = FALSE,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

GeomMarimekko
```

## Format

An object of class `StatMarimekko` (inherits from `Stat`, `ggproto`,
`gg`) of length 6.

An object of class `GeomMarimekko` (inherits from `GeomRect`, `Geom`,
`ggproto`, `gg`) of length 3.

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).
  Requires `x` (categorical) and `fill` (categorical). Optionally
  accepts `weight` for weighted counts.

- data:

  The data to be displayed in this layer.

- stat:

  The statistical transformation to use. Defaults to `"mekko"`.

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

- residuals:

  Logical. If `TRUE`, compute Pearson residuals and expose them as the
  `.resid` computed variable. Default `FALSE`.

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

# Titanic survival by class
titanic <- as.data.frame(Titanic)
ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq)) +
  scale_x_mekko() +
  labs(y = "Proportion")


# Hair and Eye color (males)
haireye <- as.data.frame(HairEyeColor[, , 1])
ggplot(haireye) +
  geom_mekko(aes(x = Hair, fill = Eye, weight = Freq), gap = 0.02) +
  scale_x_mekko() +
  scale_fill_brewer(palette = "Set2")

```
