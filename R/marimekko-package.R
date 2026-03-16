#' @keywords internal
"_PACKAGE"

#' @import ggplot2
#' @importFrom stats aggregate chisq.test
NULL

# Null-default operator
`%||%` <- function(x, y) if (is.null(x)) y else x

# Package-level environment for passing label info from stat to scale
.marimekko_env <- new.env(parent = emptyenv())
