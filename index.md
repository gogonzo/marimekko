# mekko

Marimekko (mosaic) plots for **ggplot2**.

Column widths encode the marginal distribution of one categorical
variable and segment heights encode the conditional distribution of a
second categorical variable. A simpler, lighter alternative to
[ggmosaic](https://github.com/haleyjeppson/ggmosaic).

## Installation

``` r
# Install from a local clone
devtools::install()

# Or from GitHub (when published)
# devtools::install_github("<user>/mekko")
```

## Quick start

``` r
library(ggplot2)
library(mekko)

titanic <- as.data.frame(Titanic)

ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq)) +
  scale_x_mekko() +
  labs(title = "Titanic survival by class", y = "Proportion") +
  theme_mekko()
```

## Features

| Feature                          | Function                                                |
|----------------------------------|---------------------------------------------------------|
| Core Marimekko plot              | [`geom_mekko()`](reference/geom_mekko.md)               |
| Text labels on tiles             | [`geom_mekko_text()`](reference/geom_mekko_text.md)     |
| Labels with background box       | [`geom_mekko_label()`](reference/geom_mekko_label.md)   |
| Jittered points in tiles         | [`geom_mekko_jitter()`](reference/geom_mekko_jitter.md) |
| 3-variable nested mosaic         | [`geom_mekko_multi()`](reference/geom_mekko_multi.md)   |
| Category labels on x-axis        | [`scale_x_mekko()`](reference/scale_x_mekko.md)         |
| Fill labels on y-axis            | [`scale_y_mekko()`](reference/scale_y_mekko.md)         |
| Chi-squared test annotation      | [`annotate_chisq()`](reference/annotate_chisq.md)       |
| Compute tiles without plotting   | [`fortify_mekko()`](reference/fortify_mekko.md)         |
| Minimal mosaic theme             | [`theme_mekko()`](reference/theme_mekko.md)             |
| Equal-width columns (spine plot) | `standardize = TRUE`                                    |
| Pearson residual shading         | `residuals = TRUE`                                      |
| Independent x/y gaps             | `gap_x` / `gap_y`                                       |
| Plotly tooltip support           | `.tooltip` computed variable                            |

## Examples

### Marginal percentages on x-axis

``` r
ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq)) +
  scale_x_mekko(show_percentages = TRUE) +
  theme_mekko()
```

### Count labels

``` r
ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq)) +
  geom_mekko_text(aes(
    x = Class, fill = Survived, weight = Freq,
    label = after_stat(weight)
  )) +
  scale_x_mekko()
```

### Spine plot (equal-width columns)

``` r
ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq),
                 standardize = TRUE) +
  scale_x_mekko() +
  labs(title = "Spine plot")
```

### Residual shading

``` r
ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq,
                     alpha = after_stat(abs(.resid))),
                 residuals = TRUE) +
  scale_x_mekko() +
  annotate_chisq(titanic, Class, Survived, weight = Freq)
```

### Jittered observations

``` r
ucb <- as.data.frame(UCBAdmissions)
ucb_a <- ucb[ucb$Dept == "A", ]

ggplot(ucb_a) +
  geom_mekko(aes(x = Gender, fill = Admit, weight = Freq)) +
  geom_mekko_jitter(aes(x = Gender, fill = Admit, weight = Freq),
                        seed = 42) +
  scale_x_mekko()
```

### Three-variable nested mosaic

``` r
ggplot(titanic) +
  geom_mekko_multi(aes(
    x = Class, split = Sex, fill = Survived, weight = Freq
  )) +
  scale_x_mekko()
```

### Faceting

``` r
ggplot(as.data.frame(Titanic)) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq)) +
  scale_x_mekko() +
  facet_wrap(~Sex)
```

### Independent x/y gaps

``` r
ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq),
                 gap_x = 0.04, gap_y = 0) +
  scale_x_mekko()
```

### Plotly interactive tooltips

``` r
library(plotly)

p <- ggplot(titanic) +
  geom_mekko(aes(x = Class, fill = Survived, weight = Freq,
                     text = after_stat(.tooltip))) +
  scale_x_mekko()
ggplotly(p, tooltip = "text")
```

### Data extraction with fortify

``` r
tiles <- fortify_mekko(titanic, Class, Survived,
                           weight = Freq, residuals = TRUE)
head(tiles)
```

## How it works

`mekko` extends ggplot2 through the ggproto system:

- **`StatMarimekko`** computes tile rectangles (`xmin`, `xmax`, `ymin`,
  `ymax`) from aggregated weighted counts. Column widths are
  proportional to marginal totals; segment heights are proportional to
  conditional totals within each column.
- **`GeomMarimekko`** inherits from `GeomRect` with sensible defaults
  (white borders, slight transparency).
- **[`scale_x_mekko()`](reference/scale_x_mekko.md)** reads tile
  midpoints stored by the stat to place category labels on the x-axis.

The `x` aesthetic is internally remapped to `x_var` so ggplot2 treats
the axis as continuous (avoiding discrete/continuous scale conflicts).

## Why not ggmosaic?

`mekko` was designed to avoid the common pain points of
[ggmosaic](https://github.com/haleyjeppson/ggmosaic):

- **No internal ggplot2 API usage** – won’t break on ggplot2 updates
- **Standard [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html)
  mappings** – no confusing `product()` wrapper
- **Works without [`library()`](https://rdrr.io/r/base/library.html)** –
  [`mekko::geom_mekko()`](reference/geom_mekko.md) just works
- **No tidyr dependency** – no deprecation warnings
- **Respects factor levels** – user-set
  [`levels()`](https://rdrr.io/r/base/levels.html) are honored
- **In-aes expressions** – `fill = factor(cyl)` works as expected
- **Plotly compatible** – built-in tooltip support via `.tooltip`
- **Independent x/y gaps** – different spacing for columns vs segments

## Dependencies

- `ggplot2` (\>= 3.5.0)
- `rlang`
- Base R only for internals (no dplyr/tidyr)
