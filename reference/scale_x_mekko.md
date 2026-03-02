# X-axis scale for Marimekko plots

X-axis scale for Marimekko plots

## Usage

``` r
scale_x_mekko(show_percentages = FALSE, ...)
```

## Arguments

- show_percentages:

  Logical. If `TRUE`, appends marginal percentage to each x-axis label.
  Default `FALSE`.

- ...:

  Arguments passed to
  [`ggplot2::scale_x_continuous()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html).

## Value

A ggplot2 scale.

## Examples

``` r
library(ggplot2)

titanic <- as.data.frame(Titanic)
ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq)) +
  scale_x_mekko(show_percentages = TRUE)

```
