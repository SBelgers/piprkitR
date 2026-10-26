#' Metric results
#'
#' A metric, such as `measurement$metrics$pipr_6s()` or
#' `model$metrics$plateau_pipr()`, returns a `piprkit_metric`: a number that also
#' keeps the Python `MetricResult`, with the name of the metric, the baseline
#' correction of the data, the flags of a fitted phase, and where on the trace it
#' was measured.
#'
#' It works as a number in R, e.g. in `sprintf()`, `round()` or `data.frame()`.
#' As in Python, arithmetic gives a plain number. Printing shows the metric as
#' Python prints it. The methods of the `MetricResult` are available with `$`,
#' e.g. `result$get_name()`, `result$get_flags()` or `result$plot(ax = ax)`.
#'
#' Results can be passed back to Python, e.g. to `piprkit$metric_rows()` or
#' `piprkit$net_pipr()`. Collect them with [list()]: [c()] makes plain numbers.
#'
#' @name piprkit_metric
#' @seealso [piprkit], [metric_table()]
NULL

#' @exportS3Method reticulate::py_to_r
py_to_r.piprkit.analysis.pupil_metrics.MetricResult <- function(x) {
  py <- reticulate::r_to_py(x, convert = TRUE)
  structure(reticulate::import_builtins()$float(py), py = py, class = c("piprkit_metric", "numeric"))
}

#' @exportS3Method reticulate::r_to_py
r_to_py.piprkit_metric <- function(x, convert = FALSE) {
  attr(x, "py")
}

#' @method $ piprkit_metric
#' @export
`$.piprkit_metric` <- function(x, name) {
  value <- reticulate::py_get_attr(attr(x, "py"), name)
  if (is.function(value)) value else reticulate::py_to_r(value)
}

#' @export
print.piprkit_metric <- function(x, ...) {
  py <- attr(x, "py")
  # the Python object is gone after restoring a saved workspace
  if (reticulate::py_is_null_xptr(py)) {
    print(as.vector(x), ...)
  } else {
    cat(reticulate::py_str(py), "\n", sep = "")
  }
  invisible(x)
}

#' @export
Ops.piprkit_metric <- function(e1, e2) {
  if (missing(e2)) {
    return(get(.Generic)(as_plain(e1)))
  }
  get(.Generic)(as_plain(e1), as_plain(e2))
}

#' @export
Math.piprkit_metric <- function(x, ...) {
  get(.Generic)(as_plain(x), ...)
}

as_plain <- function(x) {
  if (inherits(x, "piprkit_metric")) as.vector(x) else x
}
