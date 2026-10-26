#' Metric rows as a data frame
#'
#' Turns rows from `piprkit$metric_rows()` into a data frame with one row per
#' metric result, ready for statistics in R. The columns are those of the rows,
#' in the order they first appear. A missing cell is `NA`, and the parameters in
#' `at_bounds` are separated by spaces, as in the CSV file written by
#' `piprkit$save_metric_rows()`.
#'
#' @param rows A list of rows from `piprkit$metric_rows()`, e.g. the rows of all
#'   trials combined with [c()].
#' @return A data frame with one row per metric result.
#' @seealso [piprkit], [piprkit_metric]
#' @examplesIf interactive()
#' trials <- piprkit$load_real_series()$split(10, 55)
#' rows <- list()
#' for (number in seq_along(trials)) {
#'   trial <- trials[[number]]
#'   trial$filters$apply_baseline_correction(duration = 5)
#'   results <- list(trial$metrics$pipr_6s(), trial$metrics$auc_early(baseline_duration = 5))
#'   rows <- c(rows, piprkit$metric_rows(results, participant = "P01", trial = number))
#' }
#' metric_table(rows)
#' @export
metric_table <- function(rows) {
  columns <- unique(unlist(lapply(rows, names)))
  cells <- lapply(columns, function(column) unlist(lapply(rows, function(row) cell(row[[column]]))))
  names(cells) <- columns
  as.data.frame(cells, check.names = FALSE, stringsAsFactors = FALSE)
}

# None is NA; a tuple (such as at_bounds) comes back to R as a list and is
# joined with spaces, as save_metric_rows() does
cell <- function(value) {
  if (is.null(value)) NA else if (is.list(value)) paste(unlist(value), collapse = " ") else value
}

# save_metric_rows() only joins tuples, so the rows get their tuples back
tuple_cells <- function(row) {
  lapply(row, function(value) if (is.list(value)) do.call(reticulate::tuple, value) else value)
}
