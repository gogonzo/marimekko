# Add text labels to a Marimekko plot

Add text labels to a Marimekko plot

## Usage

``` r
geom_mekko_text(
  mapping = NULL,
  data = NULL,
  position = "identity",
  ...,
  gap = 0.01,
  gap_x = NULL,
  gap_y = NULL,
  standardize = FALSE,
  residuals = FALSE,
  size = 3.5,
  colour = "black",
  na.rm = FALSE,
  show.legend = FALSE,
  inherit.aes = FALSE
)
```

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

- residuals:

  Logical. If `TRUE`, compute Pearson residuals and expose them as the
  `.resid` computed variable. Default `FALSE`.

- size:

  Text size. Default `3.5`.

- colour:

  Text colour. Default `"black"`.

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
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq)) +
  geom_mekko_text(aes(
    x = Class, fill = Survived, weight = Freq,
    label = after_stat(weight)
  )) +
  scale_x_mekko()

```
