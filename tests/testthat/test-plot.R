test_that("measurements, series and models can be plotted", {
  skip_if_no_piprkit()
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())

  pm <- piprkit$load_simulated_pupil()
  pm$set_blinks(list(c(-4, -3.8)))
  expect_invisible(plot(pm))
  expect_invisible(plot(piprkit$load_real_series()))
  expect_invisible(plot(piprkit$PhaseModel(pm, baseline_duration = 5)))
})

test_that("matplotlib figures of piprkit can be saved", {
  skip_if_no_piprkit()
  model <- piprkit$PhaseModel(piprkit$load_simulated_pupil(), baseline_duration = 5)
  ax <- model$plot(scatter = TRUE, s = 2, color = "grey")
  model$plot_phases(ax = ax)
  path <- tempfile(fileext = ".png")
  ax$figure$savefig(path)
  expect_gt(file.size(path), 0)
})
