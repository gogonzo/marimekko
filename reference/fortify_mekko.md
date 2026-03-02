# Compute Marimekko tile rectangles as a data frame

Compute Marimekko tile rectangles as a data frame

## Usage

``` r
fortify_mekko(
  data,
  x,
  fill,
  weight = NULL,
  gap = 0.01,
  gap_x = NULL,
  gap_y = NULL,
  standardize = FALSE,
  residuals = FALSE
)
```

## Arguments

- data:

  A data frame.

- x:

  Name of the categorical x variable (unquoted or string).

- fill:

  Name of the categorical fill variable (unquoted or string).

- weight:

  Name of the weight variable (unquoted or string), or `NULL` for
  unweighted counts. Default `NULL`.

- gap:

  Numeric. Size of gap between tiles. Default `0.01`.

- gap_x:

  Numeric. Horizontal gap. Overrides `gap` for x. Default `NULL`.

- gap_y:

  Numeric. Vertical gap. Overrides `gap` for y. Default `NULL`.

- standardize:

  Logical. Equal-width columns. Default `FALSE`.

- residuals:

  Logical. Include Pearson residuals. Default `FALSE`.

## Value

A data frame with columns: `x_label`, `fill_label`, `xmin`, `xmax`,
`ymin`, `ymax`, `x`, `y`, `weight`, `cond_prop`, and optionally
`.resid`.

## Examples

``` r
titanic <- as.data.frame(Titanic)
fortify_mekko(titanic, Class, Survived, weight = Freq)
#>   x_label fill_label      xmin      xmax      ymin      ymax          x
#> 1     1st         No 0.0000000 0.1432303 0.0000000 0.3716308 0.07161517
#> 5     1st        Yes 0.0000000 0.1432303 0.3816308 1.0000000 0.07161517
#> 2     2nd         No 0.1532303 0.2788323 0.0000000 0.5801053 0.21603135
#> 6     2nd        Yes 0.1532303 0.2788323 0.5901053 1.0000000 0.21603135
#> 3     3rd         No 0.2888323 0.5999727 0.0000000 0.7403966 0.44440254
#> 7     3rd        Yes 0.2888323 0.5999727 0.7503966 1.0000000 0.44440254
#> 4    Crew         No 0.6099727 1.0000000 0.0000000 0.7528475 0.80498637
#> 8    Crew        Yes 0.6099727 1.0000000 0.7628475 1.0000000 0.80498637
#>           y weight cond_prop
#> 1 0.1858154    122 0.3753846
#> 5 0.6908154    203 0.6246154
#> 2 0.2900526    167 0.5859649
#> 6 0.7950526    118 0.4140351
#> 3 0.3701983    528 0.7478754
#> 7 0.8751983    178 0.2521246
#> 4 0.3764237    673 0.7604520
#> 8 0.8814237    212 0.2395480
fortify_mekko(titanic, Class, Survived, weight = Freq, residuals = TRUE)
#>   x_label fill_label      xmin      xmax      ymin      ymax          x
#> 1     1st         No 0.0000000 0.1432303 0.0000000 0.3716308 0.07161517
#> 5     1st        Yes 0.0000000 0.1432303 0.3816308 1.0000000 0.07161517
#> 2     2nd         No 0.1532303 0.2788323 0.0000000 0.5801053 0.21603135
#> 6     2nd        Yes 0.1532303 0.2788323 0.5901053 1.0000000 0.21603135
#> 3     3rd         No 0.2888323 0.5999727 0.0000000 0.7403966 0.44440254
#> 7     3rd        Yes 0.2888323 0.5999727 0.7503966 1.0000000 0.44440254
#> 4    Crew         No 0.6099727 1.0000000 0.0000000 0.7528475 0.80498637
#> 8    Crew        Yes 0.6099727 1.0000000 0.7628475 1.0000000 0.80498637
#>           y weight cond_prop    .resid
#> 1 0.1858154    122 0.3753846 -6.607873
#> 5 0.6908154    203 0.6246154  9.565772
#> 2 0.2900526    167 0.5859649 -1.867159
#> 6 0.7950526    118 0.4140351  2.702959
#> 3 0.3701983    528 0.7478754  2.289965
#> 7 0.8751983    178 0.2521246 -3.315027
#> 4 0.3764237    673 0.7604520  3.018611
#> 8 0.8814237    212 0.2395480 -4.369840
```
