test_that("the module prints without starting Python", {
  expect_output(print(piprkit), "piprkit")
})

test_that("functions and classes of piprkit can be used", {
  skip_if_no_piprkit()
  expect_match(piprkit$`__version__`, "^[0-9]+\\.[0-9]+")

  pm <- piprkit$load_simulated_pupil("blue")
  expect_s3_class(pm, "piprkit.core.pupil_measurement.PupilMeasurement")
  expect_equal(min(pm$get_time()), -6)
  expect_equal(pm$get_light_stimulus()$get_timing(), list(-1, 0))

  time <- seq(0, 10, length.out = 1000)
  size <- 5 + sin(time)
  own <- piprkit$PupilMeasurement(time_data = time, size_data = size)
  expect_equal(as.vector(own$get_time()), time)
  expect_equal(as.vector(own$get_size()), size)
})

test_that("whole numbers are passed as integers where Python needs them", {
  skip_if_no_piprkit()
  sim <- piprkit$simulate_pupil_measurement(num_samples = 500, noise_std = 0.001, rng = 0)
  expect_identical(sim$get_samples(), 500L)
  same_seed <- piprkit$simulate_pupil_measurement(num_samples = 500, noise_std = 0.001, rng = 0)
  expect_identical(as.vector(same_seed$get_size()), as.vector(sim$get_size()))

  limited <- sim$filters$limit_rate_of_change(n_back = 2, inplace = FALSE)
  expect_s3_class(limited, "piprkit.core.pupil_measurement.PupilMeasurement")

  path <- tempfile(fileext = ".csv")
  piprkit$save_csv(sim, path)
  loaded <- piprkit$load_csv(path, time_col = 0, size_col = 1)
  expect_equal(as.vector(loaded$get_size()), as.vector(sim$get_size()))
})

test_that("methods change the object in place and return invisibly", {
  skip_if_no_piprkit()
  pm <- piprkit$simulate_pupil_measurement(noise_std = 0.01, rng = 1)
  before <- as.vector(pm$get_size())
  expect_invisible(pm$filters$rolling_mean(1))
  expect_false(isTRUE(all.equal(as.vector(pm$get_size()), before)))

  copy <- pm$copy()
  copy$filters$apply_baseline_correction(duration = 5)
  expect_null(pm$get_baseline_correction())
})

test_that("Python errors become R errors", {
  skip_if_no_piprkit()
  ps <- piprkit$load_real_series()
  expect_error(ps$metrics, "split()", fixed = TRUE)
  expect_error(piprkit$load_simulated_pupil("green"))
})
