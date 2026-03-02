# Minimal theme for Marimekko plots

Removes x-axis gridlines and adjusts spacing for mosaic plots.

## Usage

``` r
theme_mekko(base_size = 12, ...)
```

## Arguments

- base_size:

  Base font size. Default `12`.

- ...:

  Arguments passed to
  [`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).

## Value

A ggplot2 theme.

## Examples

``` r
library(ggplot2)

titanic <- as.data.frame(Titanic)
ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq)) +
  scale_x_mekko() +
  theme_mekko()

```
