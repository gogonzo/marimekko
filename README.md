# marimekko

[![R-CMD-check](https://github.com/gogonzo/marimekko/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gogonzo/marimekko/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/gogonzo/marimekko/graph/badge.svg)](https://codecov.io/gh/gogonzo/marimekko)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/marimekko)](https://cran.r-project.org/package=marimekko)

marimekko (mosaic) plots for **ggplot2**.

A one-sided formula controls the variable hierarchy and split directions.
Column widths and segment heights encode marginal and conditional
proportions of categorical variables. A simpler, lighter alternative to
[ggmosaic](https://github.com/haleyjeppson/ggmosaic).

## Installation

```r
# Install from GitHub
devtools::install_github("gogonzo/marimekko")
```

## Quick start

```r
library(ggplot2)
library(marimekko)

titanic <- as.data.frame(Titanic)

ggplot(titanic) +
  geom_marimekko(
    aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived
  ) +
  labs(title = "Titanic survival by class", y = "Proportion") +
  theme_marimekko()
```

## Formula syntax

The formula encodes both variable order and split direction:

| Formula             | Splits                           | Pattern           |
| ------------------- | -------------------------------- | ----------------- |
| `~ a \| b`          | h(a), v(b)                       | Standard mosaic   |
| `~ a \| b \| c`     | h(a), v(b), h(c)                 | Alternating       |
| `~ a + b \| c`      | h(a), h(b), v(c)                 | Double decker     |
| `~ a \| b + c`      | h(a), v(b), v(c)                 | Multiple vertical |

- `|` alternates split direction (h → v → h → ...)
- `+` groups variables at the same level (same direction)
- Arbitrary expressions work: `~ factor(cyl) | cut(mpg, breaks = 3)`

## Features

| Feature                          | Function / Parameter           |
| -------------------------------- | ------------------------------ |
| Core marimekko plot              | `geom_marimekko()`             |
| Text labels on tiles             | `geom_marimekko_text()`        |
| Labels with background box       | `geom_marimekko_label()`       |
| Jittered points in tiles         | `geom_marimekko_jitter()`      |
| Marginal percentages on x-axis   | `show_percentages = TRUE`      |
| Compute tiles without plotting   | `fortify_marimekko()`          |
| Minimal mosaic theme             | `theme_marimekko()`            |
| Pearson residual shading         | `after_stat(.resid)`           |
| Conditional proportion shading   | `after_stat(.proportion)`      |
| Independent x/y gaps             | `gap_x` / `gap_y`             |
| Plotly interactivity             | `plotly::ggplotly()`           |

## Examples

### Marginal percentages on x-axis

```r
ggplot(titanic) +
  geom_marimekko(
    aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived
    show_percentages = TRUE
  ) +
  theme_marimekko()
```

### Count labels

```r
ggplot(titanic) +
  geom_marimekko(
    aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived
  ) +
  geom_marimekko_text(aes(
    x = Class, fill = Survived, weight = Freq,
    label = after_stat(weight)
  ))
```

### Residual shading

```r
ggplot(titanic) +
  geom_marimekko(
    aes(
      fill = Survived, weight = Freq,
      alpha = after_stat(abs(.resid))
    ),
    formula = ~ Class | Survived
  ) +
  scale_alpha_continuous(range = c(0.3, 1), guide = "none")
```

### Jittered observations

```r
ucb <- as.data.frame(UCBAdmissions)
ucb_a <- ucb[ucb$Dept == "A", ]

ggplot(ucb_a) +
  geom_marimekko(
    aes(fill = Admit, weight = Freq),
    formula = ~ Gender | Admit, alpha = 0.3
  ) +
  geom_marimekko_jitter(seed = 42)
```

### Three-variable nested mosaic

```r
ggplot(titanic) +
  geom_marimekko(
    aes(fill = Survived, weight = Freq),
    formula = ~ Class | Sex | Survived
  )
```

### Faceting

```r
ggplot(as.data.frame(Titanic)) +
  geom_marimekko(
    aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived
  ) +
  facet_wrap(~Sex)
```

### Independent x/y gaps

```r
ggplot(titanic) +
  geom_marimekko(
    aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived, gap_x = 0.04, gap_y = 0
  )
```

### Plotly interactivity

```r
library(plotly)

p <- ggplot(titanic) +
  geom_marimekko(
    aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived
  )
ggplotly(p)
```

### Data extraction with fortify

```r
tiles <- fortify_marimekko(titanic,
  formula = ~ Class | Survived, weight = Freq
)
head(tiles)
```

## How it works

`marimekko` extends ggplot2 through the ggproto system:

- **`Statmarimekko`** parses the formula, recursively partitions the
  unit square, and returns tile rectangles (`xmin`, `xmax`, `ymin`,
  `ymax`) with computed variables (`.resid`, `.proportion`, `.marginal`).
- Tiles are rendered via **`GeomRect`** with sensible defaults
  (white borders, slight transparency).
- Axis labels are automatically placed by the geom at tile midpoints.

## Why not ggmosaic?

`marimekko` was designed to avoid the common pain points of
[ggmosaic](https://github.com/haleyjeppson/ggmosaic):

- **No internal ggplot2 API usage** -- won't break on ggplot2 updates
- **Formula-based API** -- `~ a | b | c` encodes both variables and directions
- **Works without `library()`** -- `marimekko::geom_marimekko()` just works
- **No tidyr dependency** -- no deprecation warnings
- **Respects factor levels** -- user-set `levels()` are honored
- **In-formula expressions** -- `~ factor(cyl) | cut(mpg, breaks = 3)` works
- **Plotly compatible** -- `ggplotly()` works out of the box
- **Independent x/y gaps** -- different spacing for columns vs segments

## Dependencies

- `ggplot2` (>= 3.5.0)
- `rlang`
- Base R only for internals (no dplyr/tidyr)
