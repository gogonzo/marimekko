# Minimal theme for marimekko plots

Removes x-axis gridlines and adjusts spacing for mosaic plots. Also
applies the [marimekko_pal](marimekko_pal.md) fill scale.

## Usage

``` r
theme_marimekko(base_size = 12, ...)
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
  geom_marimekko(
    aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived
  ) +
  theme_marimekko()

```
