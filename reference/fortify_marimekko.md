# Compute marimekko tile rectangles as a data frame

Compute marimekko tile rectangles as a data frame

## Usage

``` r
fortify_marimekko(
  data,
  formula,
  weight = NULL,
  gap = 0.01,
  gap_x = NULL,
  gap_y = NULL,
  standardize = FALSE
)
```

## Arguments

- data:

  A data frame.

- formula:

  A one-sided formula specifying the mosaic hierarchy, using the same
  syntax as [`geom_marimekko()`](geom_marimekko.md). Example:
  `~ Class | Survived`.

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

## Value

A data frame with columns for each formula variable, plus `fill`,
`colour`, `xmin`, `xmax`, `ymin`, `ymax`, `x`, `y`, `weight`,
`.proportion`, `.marginal`, and `.residuals`.

## Examples

``` r
titanic <- as.data.frame(Titanic)
fortify_marimekko(titanic, formula = ~ Class | Survived, weight = Freq)
#>               xmin      xmax      ymin      ymax weight fill colour .proportion
#> 1st.No   0.0000000 0.1432303 0.0000000 0.3716308    122   No     No   0.3753846
#> 1st.Yes  0.0000000 0.1432303 0.3816308 1.0000000    203  Yes    Yes   0.6246154
#> 2nd.No   0.1532303 0.2788323 0.0000000 0.5801053    167   No     No   0.5859649
#> 2nd.Yes  0.1532303 0.2788323 0.5901053 1.0000000    118  Yes    Yes   0.4140351
#> 3rd.No   0.2888323 0.5999727 0.0000000 0.7403966    528   No     No   0.7478754
#> 3rd.Yes  0.2888323 0.5999727 0.7503966 1.0000000    178  Yes    Yes   0.2521246
#> Crew.No  0.6099727 1.0000000 0.0000000 0.7528475    673   No     No   0.7604520
#> Crew.Yes 0.6099727 1.0000000 0.7628475 1.0000000    212  Yes    Yes   0.2395480
#>           .marginal Class Survived          x         y .residuals
#> 1st.No   0.05542935   1st       No 0.07161517 0.1858154  -6.607873
#> 1st.Yes  0.09223080   1st      Yes 0.07161517 0.6908154   9.565772
#> 2nd.No   0.07587460   2nd       No 0.21603135 0.2900526  -1.867159
#> 2nd.Yes  0.05361199   2nd      Yes 0.21603135 0.7950526   2.702959
#> 3rd.No   0.23989096   3rd       No 0.44440254 0.3701983   2.289965
#> 3rd.Yes  0.08087233   3rd      Yes 0.44440254 0.8751983  -3.315027
#> Crew.No  0.30577010  Crew       No 0.80498637 0.3764237   3.018611
#> Crew.Yes 0.09631985  Crew      Yes 0.80498637 0.8814237  -4.369840

# 3-variable formula
fortify_marimekko(titanic, formula = ~ Class | Survived | Sex, weight = Freq)
#>                       xmin       xmax      ymin      ymax weight   fill colour
#> 1st.No.Male     0.00000000 0.12886214 0.0000000 0.3716308    118   Male   Male
#> 1st.No.Female   0.13886214 0.14323035 0.0000000 0.3716308      4 Female Female
#> 1st.Yes.Male    0.00000000 0.04069104 0.3816308 1.0000000     62   Male   Male
#> 1st.Yes.Female  0.05069104 0.14323035 0.3816308 1.0000000    141 Female Female
#> 2nd.No.Male     0.15323035 0.25983339 0.0000000 0.5801053    154   Male   Male
#> 2nd.No.Female   0.26983339 0.27883235 0.0000000 0.5801053     13 Female Female
#> 2nd.Yes.Male    0.15323035 0.17772230 0.5901053 1.0000000     25   Male   Male
#> 2nd.Yes.Female  0.18772230 0.27883235 0.5901053 1.0000000     93 Female Female
#> 3rd.No.Male     0.28883235 0.52951652 0.0000000 0.7403966    422   Male   Male
#> 3rd.No.Female   0.53951652 0.59997274 0.0000000 0.7403966    106 Female Female
#> 3rd.Yes.Male    0.28883235 0.43771074 0.7503966 1.0000000     88   Male   Male
#> 3rd.Yes.Female  0.44771074 0.59997274 0.7503966 1.0000000     90 Female Female
#> Crew.No.Male    0.60997274 0.98830597 0.0000000 0.7528475    670   Male   Male
#> Crew.No.Female  0.99830597 1.00000000 0.0000000 0.7528475      3 Female Female
#> Crew.Yes.Male   0.60997274 0.95414837 0.7628475 1.0000000    192   Male   Male
#> Crew.Yes.Female 0.96414837 1.00000000 0.7628475 1.0000000     20 Female Female
#>                 .proportion   .marginal Class Survived    Sex          x
#> 1st.No.Male     0.967213115 0.053611995   1st       No   Male 0.06443107
#> 1st.No.Female   0.032786885 0.001817356   1st       No Female 0.14104625
#> 1st.Yes.Male    0.305418719 0.028169014   1st      Yes   Male 0.02034552
#> 1st.Yes.Female  0.694581281 0.064061790   1st      Yes Female 0.09696070
#> 2nd.No.Male     0.922155689 0.069968196   2nd       No   Male 0.20653187
#> 2nd.No.Female   0.077844311 0.005906406   2nd       No Female 0.27433287
#> 2nd.Yes.Male    0.211864407 0.011358473   2nd      Yes   Male 0.16547632
#> 2nd.Yes.Female  0.788135593 0.042253521   2nd      Yes Female 0.23327732
#> 3rd.No.Male     0.799242424 0.191731031   3rd       No   Male 0.40917444
#> 3rd.No.Female   0.200757576 0.048159927   3rd       No Female 0.56974463
#> 3rd.Yes.Male    0.494382022 0.039981826   3rd      Yes   Male 0.36327155
#> 3rd.Yes.Female  0.505617978 0.040890504   3rd      Yes Female 0.52384174
#> Crew.No.Male    0.995542348 0.304407088  Crew       No   Male 0.79913936
#> Crew.No.Female  0.004457652 0.001363017  Crew       No Female 0.99915299
#> Crew.Yes.Male   0.905660377 0.087233076  Crew      Yes   Male 0.78206056
#> Crew.Yes.Female 0.094339623 0.009086779  Crew      Yes Female 0.98207419
#>                         y .residuals
#> 1st.No.Male     0.1858154 -0.3491072
#> 1st.No.Female   0.1858154 -9.5038375
#> 1st.Yes.Male    0.6908154  0.5053790
#> 1st.Yes.Female  0.6908154 13.7580643
#> 2nd.No.Male     0.2900526  2.9817561
#> 2nd.No.Female   0.2900526 -6.9363838
#> 2nd.Yes.Male    0.7950526 -4.3164871
#> 2nd.Yes.Female  0.7950526 10.0413348
#> 3rd.No.Male     0.3701983  4.1304557
#> 3rd.No.Female   0.3701983 -2.3166391
#> 3rd.Yes.Male    0.8751983 -5.9793821
#> 3rd.Yes.Female  0.8751983  3.3536422
#> Crew.No.Male    0.3764237  3.5789792
#> Crew.No.Female  0.3764237 -3.1856275
#> Crew.Yes.Male   0.8814237 -5.1810468
#> Crew.Yes.Female 0.8814237  4.6116181
```
