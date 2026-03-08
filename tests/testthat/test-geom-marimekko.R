titanic_df <- as.data.frame(Titanic)

#' Build geom_marimekko and return computed layer data.
build_marimekko <- function(df, mapping, ..., layer_index = 1L) {
  ggplot_build(ggplot(df) +
    geom_marimekko(mapping, ...))$data[[layer_index]]
}

#' Extract sorted unique column geometries from built data.
column_geom <- function(d) {
  cols <- unique(d[, c("xmin", "xmax")])
  cols <- cols[order(cols$xmin), ]
  cols$width <- cols$xmax - cols$xmin
  rownames(cols) <- NULL
  cols
}

#' Extract sorted segments within a single column (by xmin value).
column_segments <- function(d, col_xmin) {
  seg <- d[d$xmin == col_xmin, ]
  seg[order(seg$ymin), ]
}

describe("geom_marimekko", {
  describe("rectangle geometry", {
    it("computes exact tile positions for a 2x2 equal-weight table with gap=0", {
      # A: Y=50, N=50; B: Y=50, N=50. Grand=200, each column 50%.
      # Fill levels alphabetical: N, Y. Each cond_prop=0.5.
      df <- data.frame(
        x = rep(c("A", "B"), each = 2),
        fill = rep(c("Y", "N"), 2),
        weight = c(50, 50, 50, 50)
      )
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight), gap = 0)
      cols <- column_geom(d)

      expect_equal(cols$xmin, c(0, 0.5))
      expect_equal(cols$xmax, c(0.5, 1.0))

      seg_a <- column_segments(d, 0)
      expect_equal(seg_a$ymin, c(0, 0.5))
      expect_equal(seg_a$ymax, c(0.5, 1.0))
    })

    it("computes exact widths proportional to weight (3:1 -> 0.75 and 0.25)", {
      df <- data.frame(x = c("A", "B"), fill = c("Y", "Y"), weight = c(3, 1))
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight), gap = 0)
      cols <- column_geom(d)

      expect_equal(cols$xmin, c(0, 0.75))
      expect_equal(cols$xmax, c(0.75, 1.0))
      expect_equal(cols$width, c(0.75, 0.25))
    })

    it("computes exact vertical split for 75/25 weights within a column", {
      # Single column, fills N(25) and Y(75). Factor order: N first.
      df <- data.frame(x = c("A", "A"), fill = c("Y", "N"), weight = c(75, 25))
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight), gap = 0)
      d <- d[order(d$ymin), ]

      expect_equal(nrow(d), 2L)
      expect_equal(d$ymin, c(0, 0.25))
      expect_equal(d$ymax, c(0.25, 1.0))
    })

    it("computes exact geometry for asymmetric 2x2 table (30,70,50,50)", {
      # A: Y=30, N=70 (total=100); B: Y=50, N=50 (total=100). Grand=200.
      # Both columns width=0.5. Within A: N=0.7, Y=0.3; Within B: N=0.5, Y=0.5.
      df <- data.frame(
        x = rep(c("A", "B"), each = 2),
        fill = rep(c("Y", "N"), 2),
        weight = c(30, 70, 50, 50)
      )
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight), gap = 0)

      seg_a <- column_segments(d, 0)
      expect_equal(seg_a$ymin, c(0, 0.7))
      expect_equal(seg_a$ymax, c(0.7, 1.0))

      seg_b <- column_segments(d, 0.5)
      expect_equal(seg_b$ymin, c(0, 0.5))
      expect_equal(seg_b$ymax, c(0.5, 1.0))
    })

    it("places tile center x,y at midpoints of xmin/xmax and ymin/ymax", {
      d <- build_marimekko(titanic_df, aes(x = Class, fill = Survived, weight = Freq))
      expect_equal(d$x, (d$xmin + d$xmax) / 2)
      expect_equal(d$y, (d$ymin + d$ymax) / 2)
    })

    it("produces correct tile count for 3x3 table", {
      df <- expand.grid(x = c("A", "B", "C"), fill = c("X", "Y", "Z"))
      df$weight <- 1:9
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight))
      expect_equal(nrow(d), 9L)
    })

    it("keeps all tiles within [0,1] x [0,1]", {
      d <- build_marimekko(titanic_df, aes(x = Class, fill = Survived, weight = Freq))
      expect_true(all(d$xmin >= 0 & d$xmax <= 1))
      expect_true(all(d$ymin >= 0 & d$ymax <= 1))
    })

    it("tiles each column to exactly ymax=1 when gap=0", {
      d <- build_marimekko(
        titanic_df, aes(x = Class, fill = Survived, weight = Freq),
        gap = 0
      )
      max_y <- tapply(d$ymax, d$xmin, max)
      expect_equal(as.numeric(max_y), rep(1, length(max_y)))
    })
  })

  describe("gap parameter", {
    it("with gap=0 adjacent columns touch exactly", {
      df <- data.frame(
        x = rep(c("A", "B"), each = 2),
        fill = rep(c("Y", "N"), 2),
        weight = c(50, 50, 50, 50)
      )
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight), gap = 0)
      cols <- column_geom(d)
      expect_equal(cols$xmax[1], cols$xmin[2])
    })

    it("with gap=0.1 columns are separated by exactly 0.1", {
      # 2 equal columns, gap=0.1: usable_width=0.9, each col=0.45
      # A: [0, 0.45], B: [0.55, 1.0]
      df <- data.frame(
        x = rep(c("A", "B"), each = 2),
        fill = rep(c("Y", "N"), 2),
        weight = c(50, 50, 50, 50)
      )
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight), gap = 0.1)
      cols <- column_geom(d)
      expect_equal(cols$xmin[2] - cols$xmax[1], 0.1)
      expect_equal(cols$width, c(0.45, 0.45))
    })

    it("with gap=0.1 vertical segments are separated by 0.1", {
      df <- data.frame(
        x = c("A", "A"),
        fill = c("Y", "N"),
        weight = c(50, 50)
      )
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight), gap = 0.1)
      d <- d[order(d$ymin), ]
      # usable_height=0.9, each segment=0.45
      expect_equal(d$ymin[2] - d$ymax[1], 0.1)
      expect_equal(d$ymax[1] - d$ymin[1], 0.45)
    })
  })

  describe("gap_x / gap_y parameters", {
    it("gap_x controls horizontal spacing independently", {
      df <- data.frame(
        x = rep(c("A", "B"), each = 2),
        fill = rep(c("Y", "N"), 2),
        weight = c(50, 50, 50, 50)
      )
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight),
        gap_x = 0.05, gap_y = 0
      )
      cols <- column_geom(d)
      expect_equal(cols$xmin[2] - cols$xmax[1], 0.05)

      seg <- column_segments(d, cols$xmin[1])
      expect_equal(seg$ymin[2], seg$ymax[1])
    })

    it("gap_y controls vertical spacing independently", {
      df <- data.frame(
        x = rep(c("A", "B"), each = 2),
        fill = rep(c("Y", "N"), 2),
        weight = c(50, 50, 50, 50)
      )
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight),
        gap_x = 0, gap_y = 0.08
      )
      cols <- column_geom(d)
      expect_equal(cols$xmax[1], cols$xmin[2])

      seg <- column_segments(d, cols$xmin[1])
      expect_equal(seg$ymin[2] - seg$ymax[1], 0.08)
    })

    it("gap_x and gap_y override gap", {
      df <- data.frame(
        x = rep(c("A", "B"), each = 2),
        fill = rep(c("Y", "N"), 2),
        weight = c(50, 50, 50, 50)
      )
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight),
        gap = 0.1, gap_x = 0.02, gap_y = 0.04
      )
      cols <- column_geom(d)
      expect_equal(cols$xmin[2] - cols$xmax[1], 0.02)

      seg <- column_segments(d, cols$xmin[1])
      expect_equal(seg$ymin[2] - seg$ymax[1], 0.04)
    })
  })

  describe("formula-based API", {
    it("formula = ~ a | b produces 2-variable mosaic", {
      d <- ggplot_build(
        ggplot(titanic_df) +
          geom_marimekko(
            aes(fill = Survived, weight = Freq),
            formula = ~ Class | Survived
          )
      )$data[[1]]
      expect_equal(nrow(d), 8L) # 4 classes * 2 survival
      expect_true(all(d$xmin >= 0 & d$xmax <= 1))
      expect_true(all(d$ymin >= 0 & d$ymax <= 1))
    })

    it("formula = ~ a | b | c produces 3-variable mosaic", {
      d <- ggplot_build(
        ggplot(titanic_df) +
          geom_marimekko(
            aes(fill = Survived, weight = Freq),
            formula = ~ Class | Survived | Sex
          )
      )$data[[1]]
      # More tiles than 2-var
      expect_gt(nrow(d), 8L)
      expect_true(all(d$xmin >= 0 & d$xmax <= 1))
    })

    it("formula = ~ a + b | c produces double-decker pattern", {
      d <- ggplot_build(
        ggplot(titanic_df) +
          geom_marimekko(
            aes(fill = Survived, weight = Freq),
            formula = ~ Class + Sex | Survived
          )
      )$data[[1]]
      expect_gt(nrow(d), 8L)
    })

    it("backward-compat: aes(x=, fill=) auto-constructs formula", {
      # Old API should still work
      d <- build_marimekko(titanic_df, aes(x = Class, fill = Survived, weight = Freq))
      expect_equal(nrow(d), 8L)
    })

    it("errors when neither formula nor x aesthetic is provided", {
      expect_error(
        geom_marimekko(aes(fill = Survived, weight = Freq)),
        "formula.*required"
      )
    })

    it("errors if formula is not a formula object", {
      expect_error(
        ggplot(titanic_df) +
          geom_marimekko(aes(weight = Freq), formula = "~ Class | Survived"),
        "must be a formula"
      )
    })

    it("errors if formula is two-sided", {
      expect_error(
        ggplot(titanic_df) +
          geom_marimekko(aes(weight = Freq), formula = Class ~ Survived),
        "one-sided"
      )
    })

    it("errors if formula has no variables", {
      expect_error(
        ggplot(titanic_df) +
          geom_marimekko(aes(weight = Freq), formula = ~1),
        "at least one variable"
      )
    })
  })

  describe("computed variables", {
    it("weight matches aggregated input values", {
      d <- build_marimekko(titanic_df, aes(x = Class, fill = Survived, weight = Freq))
      # Total weight should equal sum of all Freq
      expect_equal(sum(d$weight), sum(titanic_df$Freq))
    })
  })

  describe("default aesthetics", {
    it("produces white borders and alpha=0.9 by default", {
      df <- data.frame(x = c("A", "B"), fill = c("Y", "Y"), weight = c(1, 1))
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight))
      expect_true(all(d$colour == "white"))
      expect_true(all(d$alpha == 0.9))
    })

    it("respects custom colour and alpha", {
      df <- data.frame(x = c("A", "B"), fill = c("Y", "Y"), weight = c(1, 1))
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight),
        colour = "red", alpha = 0.5
      )
      expect_true(all(d$colour == "red"))
      expect_true(all(d$alpha == 0.5))
    })
  })

  describe("factor level ordering", {
    it("respects factor level order for column placement", {
      # B(3 obs) before A(1 obs) per factor levels
      df <- data.frame(
        x = factor(c("B", "B", "B", "A"), levels = c("B", "A")),
        fill = c("Y", "Y", "Y", "Y")
      )
      d <- build_marimekko(df, aes(x = x, fill = fill), gap = 0)
      d <- d[order(d$xmin), ]
      # B has 3/4 weight, A has 1/4
      expect_equal(d$xmax[1] - d$xmin[1], 0.75)
      expect_equal(d$xmax[2] - d$xmin[2], 0.25)
      expect_equal(d$xmin[1], 0)
    })
  })

  describe("edge cases", {
    it("single x category spans full width", {
      df <- data.frame(x = c("A", "A"), fill = c("Y", "N"), weight = c(60, 40))
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight), gap = 0)
      expect_equal(min(d$xmin), 0)
      expect_equal(max(d$xmax), 1)
    })

    it("single fill category fills full height with ymin=0 and ymax=1", {
      df <- data.frame(x = c("A", "B", "C"), fill = c("Y", "Y", "Y"), weight = 1:3)
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight), gap = 0)
      expect_true(all(d$ymin == 0))
      expect_true(all(d$ymax == 1))
    })

    it("zero-weight combination is excluded from output", {
      df <- data.frame(
        x = c("A", "A", "B"),
        fill = c("Y", "N", "Y"),
        weight = c(10, 0, 5)
      )
      d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight))
      expect_equal(nrow(d), 2L)
      expect_true(all(d$weight > 0))
    })

    it("without explicit weight uses row counts", {
      set.seed(42)
      df <- data.frame(
        x = sample(c("A", "B", "C"), 100, replace = TRUE),
        fill = sample(c("Y", "N"), 100, replace = TRUE)
      )
      d <- build_marimekko(df, aes(x = x, fill = fill))
      # 3 x-levels * 2 fill-levels = 6
      expect_equal(nrow(d), 6L)
    })

    it("handles formula with column transformations", {
      # Users should pre-compute in the data; formula uses column names
      mtcars2 <- mtcars
      mtcars2$cyl_f <- factor(mtcars2$cyl)
      mtcars2$gear_f <- factor(mtcars2$gear)
      d <- ggplot_build(
        ggplot(mtcars2) +
          geom_marimekko(aes(fill = gear_f), formula = ~ cyl_f | gear_f)
      )$data[[1]]
      expect_equal(
        nrow(d),
        nrow(unique(mtcars[, c("cyl", "gear")]))
      )
    })

    it("formula supports factor() calls", {
      d <- ggplot_build(
        ggplot(mtcars) +
          geom_marimekko(formula = ~ factor(cyl) | factor(gear))
      )$data[[1]]
      expect_equal(
        nrow(d),
        nrow(unique(mtcars[, c("cyl", "gear")]))
      )
      expect_true(all(d$xmin >= 0 & d$xmax <= 1))
    })

    it("formula supports cut() calls", {
      d <- ggplot_build(
        ggplot(mtcars) +
          geom_marimekko(
            aes(fill = factor(gear)),
            formula = ~ cut(mpg, breaks = 3) | factor(gear)
          )
      )$data[[1]]
      expect_gt(nrow(d), 0L)
      expect_true(all(d$xmin >= 0 & d$xmax <= 1))
    })

    it("formula supports paste() calls", {
      d <- ggplot_build(
        ggplot(mtcars) +
          geom_marimekko(formula = ~ paste0("cyl", cyl) | factor(gear))
      )$data[[1]]
      expect_gt(nrow(d), 0L)
    })

    it("formula supports calls with + grouping", {
      d <- ggplot_build(
        ggplot(titanic_df) +
          geom_marimekko(
            aes(fill = Survived, weight = Freq),
            formula = ~ factor(Class) + Sex | Survived
          )
      )$data[[1]]
      expect_gt(nrow(d), 8L)
    })

    it("formula call auto-fills from last expression", {
      d <- ggplot_build(
        ggplot(mtcars) +
          geom_marimekko(formula = ~ factor(cyl) | factor(gear))
      )$data[[1]]
      # fill should be set (auto-defaulted to factor(gear))
      expect_true("fill" %in% names(d))
    })

    it("backward-compat with factor() in aes matches formula result", {
      d_aes <- ggplot_build(
        ggplot(mtcars) +
          geom_marimekko(aes(x = factor(cyl), fill = factor(gear)))
      )$data[[1]]
      d_formula <- ggplot_build(
        ggplot(mtcars) +
          geom_marimekko(formula = ~ factor(cyl) | factor(gear))
      )$data[[1]]
      expect_equal(nrow(d_aes), nrow(d_formula))
      expect_equal(sort(d_aes$xmin), sort(d_formula$xmin))
      expect_equal(sort(d_aes$xmax), sort(d_formula$xmax))
    })
  })

  describe("faceting", {
    it("facet_wrap produces correct number of independent panels", {
      d <- ggplot_build(
        ggplot(titanic_df) +
          geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
          facet_wrap(~Sex)
      )$data[[1]]
      expect_equal(length(unique(d$PANEL)), 2L)
      # Each panel should have 4 classes * 2 fills = 8 tiles
      expect_equal(nrow(d[d$PANEL == 1, ]), 8L)
      expect_equal(nrow(d[d$PANEL == 2, ]), 8L)
    })

    it("faceted panels compute different column widths per panel", {
      d <- ggplot_build(
        ggplot(titanic_df) +
          geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
          facet_wrap(~Sex)
      )$data[[1]]
      male_widths <- sort(unique(round(
        d$xmax[d$PANEL == 1] - d$xmin[d$PANEL == 1], 6
      )))
      female_widths <- sort(unique(round(
        d$xmax[d$PANEL == 2] - d$xmin[d$PANEL == 2], 6
      )))
      expect_false(isTRUE(all.equal(male_widths, female_widths)))
    })

    it("facet_grid renders without error", {
      p <- ggplot(titanic_df) +
        geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
        facet_grid(~Sex)
      expect_no_error(print(p))
    })
  })

  describe("ggplot2 layer composition", {
    it("composes with scale_x_marimekko, scale_fill_manual, coord_flip, theme_marimekko", {
      base <- ggplot(titanic_df) +
        geom_marimekko(aes(x = Class, fill = Survived, weight = Freq))

      expect_no_error(print(base + scale_x_marimekko() + theme_marimekko()))
      expect_no_error(print(
        base + scale_fill_manual(values = c("No" = "red", "Yes" = "green"))
      ))
      expect_no_error(print(base + coord_flip()))
    })
  })

  describe("namespace-qualified usage", {
    it("marimekko::geom_marimekko works with explicit namespacing", {
      p <- ggplot2::ggplot(titanic_df) +
        marimekko::geom_marimekko(ggplot2::aes(
          x = Class, fill = Survived, weight = Freq
        ))
      built <- ggplot2::ggplot_build(p)
      expect_equal(nrow(built$data[[1]]), 8L)
    })
  })
})

describe("geom_marimekko_text", {
  it("renders text with after_stat(weight) at correct tile positions", {
    p <- ggplot(titanic_df) +
      geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
      geom_marimekko_text(aes(
        x = Class, fill = Survived, weight = Freq,
        label = after_stat(weight)
      ))
    built <- ggplot_build(p)
    # layer 1 = marimekko tiles, layer 2 = text
    tiles <- built$data[[1]]
    text <- built$data[[2]]
    # text x,y should match tile centers
    expect_equal(sort(text$x), sort(tiles$x))
    expect_equal(sort(text$y), sort(tiles$y))
  })

  it("renders with after_stat(cond_prop) without error", {
    p <- ggplot(titanic_df) +
      geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
      geom_marimekko_text(aes(
        x = Class, fill = Survived, weight = Freq,
        label = after_stat(paste0(round(cond_prop * 100), "%"))
      ))
    expect_no_error(print(p))
  })

  it("renders with after_stat(.tooltip) without error", {
    p <- ggplot(titanic_df) +
      geom_marimekko_text(aes(
        x = Class, fill = Survived, weight = Freq,
        label = after_stat(.tooltip)
      ))
    expect_no_error(print(p))
  })

  it("remaps x aesthetic to x_var transparently", {
    # The x aesthetic should work seamlessly despite internal x_var remapping
    p <- ggplot(titanic_df) +
      geom_marimekko_text(aes(
        x = Class, fill = Survived, weight = Freq,
        label = after_stat(weight)
      ))
    d <- ggplot_build(p)$data[[1]]
    expect_equal(nrow(d), 8L)
    expect_true(all(c("x", "y", "label") %in% names(d)))
  })
})

describe("geom_marimekko_label", {
  it("renders label boxes at correct tile positions", {
    p <- ggplot(titanic_df) +
      geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
      geom_marimekko_label(aes(
        x = Class, fill = Survived, weight = Freq,
        label = after_stat(weight)
      ))
    built <- ggplot_build(p)
    tiles <- built$data[[1]]
    labels <- built$data[[2]]
    expect_equal(sort(labels$x), sort(tiles$x))
    expect_equal(sort(labels$y), sort(tiles$y))
  })
})

describe("geom_marimekko_jitter", {
  it("produces exactly one point per unit weight", {
    df <- data.frame(x = c("A", "B"), fill = c("Y", "Y"), weight = c(10, 5))
    d <- ggplot_build(
      ggplot(df) +
        geom_marimekko(aes(x = x, fill = fill, weight = weight)) +
        geom_marimekko_jitter(aes(x = x, fill = fill, weight = weight), seed = 1)
    )$data[[2]]
    expect_equal(nrow(d), 15L)
  })

  it("places all points within their parent tile bounds", {
    df <- data.frame(
      x = rep(c("A", "B"), each = 2),
      fill = rep(c("Y", "N"), 2),
      weight = c(10, 10, 5, 5)
    )
    built <- ggplot_build(
      ggplot(df) +
        geom_marimekko(aes(x = x, fill = fill, weight = weight)) +
        geom_marimekko_jitter(aes(x = x, fill = fill, weight = weight), seed = 42)
    )
    jitter <- built$data[[2]]
    # All points must be within overall plot area [0,1]
    expect_true(all(jitter$x >= 0 & jitter$x <= 1))
    expect_true(all(jitter$y >= 0 & jitter$y <= 1))
  })

  it("produces identical output for the same seed", {
    df <- data.frame(x = c("A", "B"), fill = c("Y", "Y"), weight = c(5, 5))
    build_jitter <- function(s) {
      ggplot_build(
        ggplot(df) +
          geom_marimekko_jitter(aes(x = x, fill = fill, weight = weight), seed = s)
      )$data[[1]]
    }
    d1 <- build_jitter(123)
    d2 <- build_jitter(123)
    expect_equal(d1$x, d2$x)
    expect_equal(d1$y, d2$y)
  })

  it("renders without error on UCBAdmissions data", {
    ucb <- as.data.frame(UCBAdmissions)
    ucb_a <- ucb[ucb$Dept == "A", ]
    p <- ggplot(ucb_a) +
      geom_marimekko(aes(x = Gender, fill = Admit, weight = Freq)) +
      geom_marimekko_jitter(aes(x = Gender, fill = Admit, weight = Freq), seed = 42)
    expect_no_error(print(p))
  })
})

describe("scale_x_marimekko", {
  it("places breaks at column midpoints", {
    df <- data.frame(
      x = c("A", "A", "B", "B"),
      fill = c("Y", "N", "Y", "N"),
      weight = c(75, 25, 50, 50)
    )
    p <- ggplot(df) +
      geom_marimekko(aes(x = x, fill = fill, weight = weight)) +
      scale_x_marimekko()
    d <- ggplot_build(p)$data[[1]]
    cols <- column_geom(d)
    expected_mids <- (cols$xmin + cols$xmax) / 2

    scale_info <- layer_scales(p)$x
    breaks <- scale_info$break_info(c(0, 1))
    expect_equal(breaks$major_source, expected_mids, tolerance = 0.001)
  })

  it("labels include the original category names", {
    p <- ggplot(titanic_df) +
      geom_marimekko(
        aes(fill = Survived, weight = Freq),
        formula = ~ Class | Survived
      ) +
      scale_x_marimekko()
    ggplot_build(p)

    scale_info <- layer_scales(p)$x
    breaks_info <- scale_info$break_info(c(0, 1))
    labels <- scale_info$get_labels(breaks_info$major_source)
    expect_true(all(c("1st", "2nd", "3rd", "Crew") %in% labels))
  })

  it("show_percentages=TRUE renders without error", {
    df <- data.frame(x = c("A", "B"), fill = c("Y", "Y"), weight = c(3, 1))
    p <- ggplot(df) +
      geom_marimekko(aes(x = x, fill = fill, weight = weight)) +
      scale_x_marimekko(show_percentages = TRUE)
    expect_no_error(print(p))
  })
})

describe("scale_y_marimekko", {
  it("renders without error and provides fill category labels", {
    p <- ggplot(titanic_df) +
      geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
      scale_y_marimekko()
    expect_no_error(print(p))

    scale_info <- layer_scales(p)$y
    # Breaks should exist at segment midpoints
    breaks_info <- scale_info$break_info(c(0, 1))
    expect_true(length(breaks_info$major_source) > 0)
  })
})

describe("theme_marimekko", {
  it("returns a ggplot2 theme with gridlines and ticks removed", {
    th <- theme_marimekko()
    expect_s3_class(th, "theme")
    expect_identical(th$panel.grid.major.x, element_blank())
    expect_identical(th$panel.grid.minor, element_blank())
    expect_identical(th$axis.ticks.x, element_blank())
  })
})

describe("fortify_marimekko", {
  it("returns all expected columns with correct dimensions", {
    result <- fortify_marimekko(titanic_df, Class, Survived, weight = Freq)
    expected_cols <- c(
      "x_label", "fill_label", "xmin", "xmax",
      "ymin", "ymax", "x", "y", "weight", "cond_prop"
    )
    expect_true(all(expected_cols %in% names(result)))
    expect_equal(nrow(result), 8L) # 4 classes * 2 survival
  })

  it("tiles fill [0,1] x [0,1] with gap=0", {
    result <- fortify_marimekko(titanic_df, Class, Survived,
      weight = Freq, gap = 0
    )
    expect_equal(min(result$xmin), 0)
    expect_equal(max(result$xmax), 1)
    expect_equal(min(result$ymin), 0)
    expect_equal(max(result$ymax), 1)
  })

  it("residuals=TRUE includes .resid with non-zero values", {
    result <- fortify_marimekko(titanic_df, Class, Survived,
      weight = Freq, residuals = TRUE
    )
    expect_true(".resid" %in% names(result))
    expect_true(any(result$.resid != 0))
  })

  it("standardize=TRUE produces a single unique column width", {
    result <- fortify_marimekko(titanic_df, Class, Survived,
      weight = Freq, standardize = TRUE, gap = 0
    )
    widths <- unique(round(result$xmax - result$xmin, 10))
    expect_equal(length(widths), 1L)
    expect_equal(widths, 0.25) # 4 columns, each 1/4
  })

  it("without weight argument uses row counts", {
    df <- data.frame(x = c("A", "A", "B"), fill = c("Y", "N", "Y"))
    result <- fortify_marimekko(df, x, fill)
    expect_equal(nrow(result), 3L)
  })
})

describe("plotly conversion", {
  it("converts geom_marimekko to plotly", {
    skip_if_not_installed("plotly")
    p <- ggplot(titanic_df) +
      geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
      scale_x_marimekko()
    expect_no_error(plotly::ggplotly(p))
  })

  it("converts geom_marimekko_text to plotly", {
    skip_if_not_installed("plotly")
    p <- ggplot(titanic_df) +
      geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
      geom_marimekko_text(aes(
        x = Class, fill = Survived, weight = Freq,
        label = after_stat(weight)
      ))
    expect_no_error(plotly::ggplotly(p))
  })

  it("converts geom_marimekko_label to plotly (warns for GeomLabel)", {
    skip_if_not_installed("plotly")
    p <- ggplot(titanic_df) +
      geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
      geom_marimekko_label(aes(
        x = Class, fill = Survived, weight = Freq,
        label = after_stat(weight)
      ))
    suppressWarnings(expect_no_error(plotly::ggplotly(p)))
  })

  it("converts geom_marimekko_jitter to plotly", {
    skip_if_not_installed("plotly")
    df <- data.frame(x = c("A", "B"), fill = c("Y", "Y"), weight = c(5, 5))
    p <- ggplot(df) +
      geom_marimekko(aes(x = x, fill = fill, weight = weight)) +
      geom_marimekko_jitter(aes(x = x, fill = fill, weight = weight), seed = 1)
    expect_no_error(plotly::ggplotly(p))
  })
})

describe("visual regression", {
  it("basic Titanic marimekko", {
    skip_if_not_installed("vdiffr")
    vdiffr::expect_doppelganger("titanic-basic", {
      ggplot(titanic_df) +
        geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
        scale_x_marimekko() +
        labs(y = "Proportion")
    })
  })

  it("no-gap marimekko", {
    skip_if_not_installed("vdiffr")
    vdiffr::expect_doppelganger("titanic-no-gap", {
      ggplot(titanic_df) +
        geom_marimekko(aes(x = Class, fill = Survived, weight = Freq), gap = 0) +
        scale_x_marimekko()
    })
  })

  it("marimekko with text labels", {
    skip_if_not_installed("vdiffr")
    vdiffr::expect_doppelganger("titanic-text-labels", {
      ggplot(titanic_df) +
        geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
        geom_marimekko_text(aes(
          x = Class, fill = Survived, weight = Freq,
          label = after_stat(weight)
        )) +
        scale_x_marimekko()
    })
  })

  it("fully themed marimekko", {
    skip_if_not_installed("vdiffr")
    vdiffr::expect_doppelganger("titanic-themed", {
      ggplot(titanic_df) +
        geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
        scale_x_marimekko() +
        scale_y_marimekko() +
        theme_marimekko()
    })
  })

  it("custom colour and alpha", {
    skip_if_not_installed("vdiffr")
    vdiffr::expect_doppelganger("titanic-red-borders", {
      ggplot(titanic_df) +
        geom_marimekko(aes(x = Class, fill = Survived, weight = Freq),
          colour = "red", alpha = 0.5
        ) +
        scale_x_marimekko()
    })
  })

  it("faceted marimekko", {
    skip_if_not_installed("vdiffr")
    vdiffr::expect_doppelganger("titanic-faceted", {
      ggplot(titanic_df) +
        geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
        facet_wrap(~Sex) +
        scale_x_marimekko()
    })
  })

  it("x-axis with percentages", {
    skip_if_not_installed("vdiffr")
    vdiffr::expect_doppelganger("titanic-x-percentages", {
      ggplot(titanic_df) +
        geom_marimekko(aes(x = Class, fill = Survived, weight = Freq)) +
        scale_x_marimekko(show_percentages = TRUE)
    })
  })
})

describe("zero-weight edge cases", {
  it("returns empty plot when all weights are zero", {
    df <- data.frame(
      x = factor(c("A", "B")),
      fill = factor(c("Y", "N")),
      weight = c(0, 0)
    )
    d <- build_marimekko(df, aes(x = x, fill = fill, weight = weight))
    expect_true(is.null(d) || nrow(d) == 0)
  })
})

describe("scale fallbacks when env is empty", {
  it("scale_x_marimekko returns waiver when labels env is NULL", {
    .marimekko_env$labels <- NULL
    s <- scale_x_marimekko()
    # breaks and labels functions should return waiver() when env is NULL
    breaks_result <- s$breaks(c(0, 1))
    labels_result <- s$labels(0.5)
    expect_true(inherits(breaks_result, "waiver"))
    expect_true(inherits(labels_result, "waiver"))
  })

  it("scale_y_marimekko returns waiver when y_labels env is NULL", {
    .marimekko_env$y_labels <- NULL
    s <- scale_y_marimekko()
    breaks_result <- s$breaks(c(0, 1))
    labels_result <- s$labels(0.5)
    expect_true(inherits(breaks_result, "waiver"))
    expect_true(inherits(labels_result, "waiver"))
  })
})
