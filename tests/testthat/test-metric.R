test_that("metrics are numbers that keep the Python result", {
  skip_if_no_piprkit()
  sim <- piprkit$simulate_pupil_measurement()
  baseline <- sim$metrics$baseline(duration = 5)
  expect_s3_class(baseline, "piprkit_metric")
  expect_true(is.numeric(baseline))
  expect_identical(as.numeric(baseline), 1)
  expect_identical(sprintf("%.2f", baseline), "1.00")
  expect_match(baseline$get_name(), "^Baseline")
  expect_null(baseline$get_flags())
  expect_output(print(baseline), "Baseline")
})

test_that("arithmetic on metrics gives plain numbers, as in Python", {
  skip_if_no_piprkit()
  peak <- piprkit$simulate_pupil_measurement()$metrics$peak_constriction()
  value <- as.numeric(peak)
  expect_identical(peak + 1, value + 1)
  expect_identical(-peak, -value)
  expect_identical(round(peak, 2), round(value, 2))
  expect_true(peak < 1)
  expect_identical(unlist(list(peak, peak)), c(value, value))
})

test_that("metrics follow the simulated response", {
  skip_if_no_piprkit()
  sim <- piprkit$simulate_pupil_measurement(num_samples = 20001)
  # The default response: 0.55 at the peak constriction (-0.75 s), rising by
  # 0.025 per second until light offset (0 s), then S * exp(-0.4 * t) + 1.
  S <- 0.55 + 0.025 * 0.75 - 1
  expect_equal(as.numeric(sim$metrics$peak_constriction()), 0.55, tolerance = 1e-6)
  expect_equal(as.numeric(sim$metrics$pipr_6s()), 1 + S * exp(-0.4 * 6), tolerance = 1e-4)
})

test_that("metrics of a fitted model carry the flags of the phase", {
  skip_if_no_piprkit()
  trial <- piprkit$load_real_series()$split(10, 55)[[1]]
  trial$filters$apply_baseline_correction(duration = 5)
  model <- piprkit$PhaseModel(trial, baseline_duration = 5)
  velocity <- model$metrics$constriction_v()
  expect_s3_class(velocity, "piprkit_metric")
  expect_identical(as.numeric(velocity), model$get_param("constriction", "m"))
  expect_false(velocity$get_flags()$not_defined)
})

test_that("metrics can be passed back to Python", {
  skip_if_no_piprkit()
  blue <- piprkit$load_simulated_pupil("blue")
  red <- piprkit$load_simulated_pupil("red")
  blue$filters$apply_baseline_correction(duration = 5)
  red$filters$apply_baseline_correction(duration = 5)
  a <- blue$metrics$pipr_6s()
  b <- red$metrics$pipr_6s()

  net <- piprkit$net_pipr(a, b)
  expect_s3_class(net, "piprkit_metric")
  expect_identical(as.numeric(net), as.numeric(a) - as.numeric(b))

  rows <- piprkit$metric_rows(list(a, b, net), participant = "P01", trial = 1L)
  expect_length(rows, 3)
  expect_identical(rows[[1]]$metric, a$get_name())
  expect_identical(rows[[3]]$value, as.numeric(net))
  expect_error(piprkit$metric_rows(list(1, 2)), "MetricResult")
})

test_that("metric rows become a data frame", {
  skip_if_no_piprkit()
  trial <- piprkit$load_real_series()$split(10, 55)[[1]]
  trial$filters$apply_baseline_correction(duration = 5)
  model <- piprkit$PhaseModel(trial, baseline_duration = 5, redilation_k_bounds = c(-0.05, 0))
  rows <- piprkit$metric_rows(
    list(trial$metrics$pipr_6s(), suppressWarnings(model$metrics$redilation_v())),
    participant = "P01", trial = 1L
  )
  table <- metric_table(rows)
  expect_identical(nrow(table), 2L)
  expect_identical(names(table)[1:4], c("participant", "trial", "metric", "value"))
  expect_identical(table$at_bounds, c(NA, "k"))
  expect_identical(table$not_defined, c(NA, FALSE))
})
