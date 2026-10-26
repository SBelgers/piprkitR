# Python needs an int for these arguments, but 1000 is a double in R, so whole
# numbers are passed as integers. Other numbers are left alone: an integer where
# Python expects a float could give an integer array.
int_args <- c("num_samples", "rng", "n_back", "min_samples", "redilation_k_count", "time_col", "size_col")

with_int_args <- function(f) {
  force(f)
  function(...) {
    args <- list(...)
    for (name in intersect(names(args), int_args)) {
      if (is_whole_number(args[[name]])) {
        args[[name]] <- as.integer(args[[name]])
      }
    }
    do.call(f, args)
  }
}

is_whole_number <- function(x) {
  is.double(x) && length(x) == 1 && !is.na(x) && x == round(x) && abs(x) <= .Machine$integer.max
}

# The filters are the only methods with an int argument (n_back)
#' @method $ piprkit.preprocessing.filtering.PupilFilters
#' @export
`$.piprkit.preprocessing.filtering.PupilFilters` <- function(x, name) {
  value <- NextMethod()
  if (is.function(value)) with_int_args(value) else value
}
