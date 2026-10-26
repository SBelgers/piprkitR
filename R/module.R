#' The piprkit Python module
#'
#' `piprkit` gives access to the complete API of the Python package piprkit. Use
#' `$` where Python uses `.`: `piprkit$load_real_series()` in R is
#' `piprkit.load_real_series()` in Python. The
#' [piprkit documentation](https://sbelgers.github.io/piprkit/) describes all
#' functions, classes and arguments, and its examples work in R with small
#' changes, see the README.
#'
#' Python runs the computations, so the results are identical to those in
#' Python. The objects are Python objects: their methods change them in place,
#' and `y <- x` does not copy them (use `y <- x$copy()`).
#'
#' Metric results, such as `measurement$metrics$pipr_6s()`, are numbers of class
#' [piprkit_metric]. Collect them with [list()] and pass them to
#' `piprkit$metric_rows()`; [metric_table()] turns the rows into a data frame.
#'
#' Arguments that Python needs as integers, such as `num_samples`, `rng`,
#' `n_back`, `min_samples`, `redilation_k_count`, `time_col` and `size_col`, can
#' be given as whole numbers like `1000`.
#'
#' `plot()` draws a measurement, a series or a fitted `PhaseModel` with base R
#' graphics. The matplotlib plots of piprkit work as well, e.g.
#' `ax <- model$plot_phases(); ax$figure$savefig("model.png")`.
#'
#' Python and piprkit are installed automatically by reticulate when piprkit is
#' first used. To use your own Python, install piprkit there and select it with,
#' for example, [reticulate::use_virtualenv()] before using piprkit.
#'
#' @format NULL
#' @usage piprkit
#' @examplesIf interactive()
#' ps <- piprkit$load_real_series()
#' ps$filters$rolling_mean(0.1)
#' ps$filters$limit_rate_of_change()
#' ps$drop_nan()
#'
#' trials <- ps$split(pre_stimulus_duration = 10, post_stimulus_duration = 55)
#' trial <- trials[[1]]
#' trial$filters$apply_baseline_correction(duration = 5)
#' trial$metrics$pipr_6s()
#'
#' model <- piprkit$PhaseModel(trial, baseline_duration = 5)
#' model$metrics$plateau_pipr()
#' plot(model)
#' @export
piprkit <- structure(list(), class = "piprkit_module")

#' @method $ piprkit_module
#' @export
`$.piprkit_module` <- function(x, name) {
  value <- reticulate::py_get_attr(.py$piprkit, name)
  if (!is.function(value)) {
    return(reticulate::py_to_r(value))
  }
  if (identical(name, "save_metric_rows")) {
    return(function(rows, ...) value(lapply(rows, tuple_cells), ...))
  }
  with_int_args(value)
}

#' @exportS3Method utils::.DollarNames
.DollarNames.piprkit_module <- function(x, pattern = "") {
  names <- tryCatch(reticulate::py_list_attributes(.py$piprkit), error = function(e) character())
  grep(pattern, names[!startsWith(names, "_")], value = TRUE)
}

#' @export
print.piprkit_module <- function(x, ...) {
  cat(
    "<Python module piprkit, loaded when first used>\n",
    "Use `$` where Python uses `.`, e.g. piprkit$load_real_series().\n",
    "Documentation: https://sbelgers.github.io/piprkit/\n",
    sep = ""
  )
  invisible(x)
}
