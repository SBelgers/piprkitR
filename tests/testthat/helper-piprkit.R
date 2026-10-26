skip_if_no_piprkit <- function() {
  skip_on_cran()
  if (reticulate::py_module_available("piprkit")) {
    return(invisible())
  }
  # on CI the tests have to run, so there a missing piprkit is an error
  if (nzchar(Sys.getenv("CI"))) {
    stop("The Python package piprkit is not available.")
  }
  skip("The Python package piprkit is not available.")
}

# The full example of the piprkit documentation in R, as in the README, without
# the plots. full_example.py is the same example in Python.
full_example <- function() {
  ps <- piprkit$load_real_series()
  ps$filters$rolling_mean(0.1)
  ps$filters$limit_rate_of_change()
  ps$drop_nan()
  ps$add_blinks(list(c(153.5, 156.5)))
  ps$filters$remove_blinks()
  ps$trim_size()

  trials <- ps$split(pre_stimulus_duration = 10, post_stimulus_duration = 55)

  rows <- list()
  for (number in seq_along(trials)) {
    trial <- trials[[number]]
    baseline <- trial$metrics$baseline(duration = 5)
    trial$filters$apply_baseline_correction(duration = 5)
    model <- piprkit$PhaseModel(trial, baseline_duration = 5)

    results <- list(
      baseline,
      trial$metrics$peak_constriction(),
      trial$metrics$time_to_peak(),
      trial$metrics$pipr_6s(),
      trial$metrics$auc_early(baseline_duration = 5),
      model$metrics$constriction_v(),
      model$metrics$redilation_v(),
      model$metrics$plateau_pipr()
    )
    rows <- c(rows, piprkit$metric_rows(results, participant = "example", trial = number))
  }
  rows
}
