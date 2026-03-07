# marimekko

marimekko (mosaic) plots for **ggplot2**.

Column widths encode the marginal distribution of one categorical variable
and segment heights encode the conditional distribution of a second
categorical variable. A simpler, lighter alternative to
[ggmosaic](https://github.com/haleyjeppson/ggmosaic).

## Installation

```r
# Install from a local clone
devtools::install()

# Or from GitHub (when published)
# devtools::install_github("<user>/marimekko")
```

## Quick start

```r
library(ggplot2)
library(marimekko)

titanic <- as.data.frame(Titanic)

ggplot(titanic) +
  geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
  scale_x_marimekko() +
  labs(title = "Titanic survival by class", y = "Proportion") +
  theme_marimekko()
```

## Features

| Feature                          | Function                     |
| -------------------------------- | ---------------------------- |
| Core marimekko plot              | `geom_marimekko()`           |
| Text labels on tiles             | `geom_marimekko_text()`      |
| Labels with background box       | `geom_marimekko_label()`     |
| Jittered points in tiles         | `geom_marimekko_jitter()`    |
| 3-variable nested mosaic         | `geom_marimekko_multi()`     |
| Category labels on x-axis        | `scale_x_marimekko()`        |
| Fill labels on y-axis            | `scale_y_marimekko()`        |
| Chi-squared test annotation      | `annotate_chisq()`           |
| Compute tiles without plotting   | `fortify_marimekko()`        |
| Minimal mosaic theme             | `theme_marimekko()`          |
| Equal-width columns (spine plot) | `standardize = TRUE`         |
| Pearson residual shading         | `residuals = TRUE`           |
| Independent x/y gaps             | `gap_x` / `gap_y`            |
| Plotly tooltip support           | `.tooltip` computed variable |

## Examples

### Marginal percentages on x-axis

```r
ggplot(titanic) +
  geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
  scale_x_marimekko(show_percentages = TRUE) +
  theme_marimekko()
```

### Count labels

```r
ggplot(titanic) +
  geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
  geom_marimekko_text(aes(
    x = Class, fill = Survived, weight = Freq,
    label = after_stat(weight)
  )) +
  scale_x_marimekko()
```

### Spine plot (equal-width columns)

```r
ggplot(titanic) +
  geom_marimekko(aes(x = Class, fill = Survived, weight = Freq),
                 standardize = TRUE) +
  scale_x_marimekko() +
  labs(title = "Spine plot")
```

### Residual shading

```r
ggplot(titanic) +
  geom_marimekko(aes(x = Class, fill = Survived, weight = Freq,
                     alpha = after_stat(abs(.resid))),
                 residuals = TRUE) +
  scale_x_marimekko() +
  annotate_chisq(titanic, Class, Survived, weight = Freq)
```

### Jittered observations

```r
ucb <- as.data.frame(UCBAdmissions)
ucb_a <- ucb[ucb$Dept == "A", ]

ggplot(ucb_a) +
  geom_marimekko(aes(x = Gender, fill = Admit, weight = Freq)) +
  geom_marimekko_jitter(aes(x = Gender, fill = Admit, weight = Freq),
                        seed = 42) +
  scale_x_marimekko()
```

### Three-variable nested mosaic

```r
ggplot(titanic) +
  geom_marimekko_multi(aes(
    x = Class, split = Sex, fill = Survived, weight = Freq
  )) +
  scale_x_marimekko()
```

### Faceting

```r
ggplot(as.data.frame(Titanic)) +
  geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
  scale_x_marimekko() +
  facet_wrap(~Sex)
```

### Independent x/y gaps

```r
ggplot(titanic) +
  geom_marimekko(aes(x = Class, fill = Survived, weight = Freq),
                 gap_x = 0.04, gap_y = 0) +
  scale_x_marimekko()
```

### Plotly interactive tooltips

```r
library(plotly)

p <- ggplot(titanic) +
  geom_marimekko(aes(x = Class, fill = Survived, weight = Freq,
                     text = after_stat(.tooltip))) +
  scale_x_marimekko()
ggplotly(p, tooltip = "text")
```

### Data extraction with fortify

```r
tiles <- fortify_marimekko(titanic, Class, Survived,
                           weight = Freq, residuals = TRUE)
head(tiles)
```

## How it works

`marimekko` extends ggplot2 through the ggproto system:

- **`Statmarimekko`** computes tile rectangles (`xmin`, `xmax`, `ymin`,
  `ymax`) from aggregated weighted counts. Column widths are proportional
  to marginal totals; segment heights are proportional to conditional
  totals within each column.
- **`Geommarimekko`** inherits from `GeomRect` with sensible defaults
  (white borders, slight transparency).
- **`scale_x_marimekko()`** reads tile midpoints stored by the stat to
  place category labels on the x-axis.

The `x` aesthetic is internally remapped to `x_var` so ggplot2 treats
the axis as continuous (avoiding discrete/continuous scale conflicts).

## Why not ggmosaic?

`marimekko` was designed to avoid the common pain points of
[ggmosaic](https://github.com/haleyjeppson/ggmosaic):

- **No internal ggplot2 API usage** -- won't break on ggplot2 updates
- **Standard `aes()` mappings** -- no confusing `product()` wrapper
- **Works without `library()`** -- `marimekko::geom_marimekko()` just works
- **No tidyr dependency** -- no deprecation warnings
- **Respects factor levels** -- user-set `levels()` are honored
- **In-aes expressions** -- `fill = factor(cyl)` works as expected
- **Plotly compatible** -- built-in tooltip support via `.tooltip`
- **Independent x/y gaps** -- different spacing for columns vs segments

## Dependencies

- `ggplot2` (>= 3.5.0)
- `rlang`
- Base R only for internals (no dplyr/tidyr)
