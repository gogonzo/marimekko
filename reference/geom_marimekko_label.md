# Add labels with background to a marimekko plot

Add labels with background to a marimekko plot

## Usage

``` r
geom_marimekko_label(
  mapping = NULL,
  data = NULL,
  position = "identity",
  ...,
  size = 3.5,
  colour = "black",
  fill = alpha("white", 0.7),
  label.padding = unit(0.15, "lines"),
  na.rm = FALSE,
  show.legend = FALSE,
  inherit.aes = FALSE
)
```

## Arguments

- mapping:

  Set of aesthetic mappings. Only `label` is required. Use
  [`ggplot2::after_stat()`](https://ggplot2.tidyverse.org/reference/aes_eval.html)
  for computed variables.

- data:

  A data frame. Default `NULL` (uses plot data; tile positions come from
  [`geom_marimekko()`](geom_marimekko.md)).

- position:

  Position adjustment. Default `"identity"`.

- ...:

  Additional arguments passed to the layer.

- size:

  Text size. Default `3.5`.

- colour:

  Text colour. Default `"white"` for text, `"black"` for labels.

- fill:

  Label background colour. Default `alpha("white", 0.7)`.

- label.padding:

  Amount of padding around label. Default
  `ggplot2::unit(0.15, "lines")`.

- na.rm:

  Logical. Remove missing values. Default `FALSE`.

- show.legend:

  Logical. Show legend. Default `FALSE`.

- inherit.aes:

  Logical. Inherit aesthetics. Default `FALSE`.

## Value

A ggplot2 layer.

## Examples

``` r
library(ggplot2)

titanic <- as.data.frame(Titanic)
ggplot(titanic) +
  geom_marimekko(
    aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived
  ) +
  geom_marimekko_label(aes(label = after_stat(weight)))

```
