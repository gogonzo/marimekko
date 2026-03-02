# Y-axis scale for Marimekko plots

Y-axis scale for Marimekko plots

## Usage

``` r
scale_y_mekko(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ggplot2::scale_y_continuous()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html).

## Value

A ggplot2 scale.

## Examples

``` r
library(ggplot2)

titanic <- as.data.frame(Titanic)
ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq)) +
  scale_x_mekko() +
  scale_y_mekko()

```
