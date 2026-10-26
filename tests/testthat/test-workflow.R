# Both examples run in this R process. A standalone Python on Windows sets the x87
# FPU to double precision (R keeps extended precision), which changes the last
# digits of the redilation fit, so it can't be compared byte for byte.
test_that("the full example gives the same metrics in R as in Python", {
  skip_if_no_piprkit()
  reticulate::py_run_file(test_path("full_example.py"))
  python_rows <- reticulate::py_eval("rows")
  r_rows <- full_example()

  expect_length(r_rows, 6 * 8)
  expect_identical(metric_table(r_rows), metric_table(python_rows))

  python_csv <- tempfile(fileext = ".csv")
  r_csv <- tempfile(fileext = ".csv")
  python <- reticulate::import("piprkit", convert = FALSE)
  python$save_metric_rows(reticulate::py_eval("rows", convert = FALSE), python_csv)
  piprkit$save_metric_rows(r_rows, r_csv)
  expect_identical(readLines(r_csv), readLines(python_csv))
})
