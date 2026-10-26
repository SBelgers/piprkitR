#' @method plot piprkit.core.pupil_base.PupilBase
#' @export
plot.piprkit.core.pupil_base.PupilBase <- function(x, y, ..., col = "black", xlab = "Time (s)",
                                                   ylab = "Pupil size") {
  time <- as.vector(x$get_time())
  size <- as.vector(x$get_size())
  graphics::plot(time, size, type = "n", xlab = xlab, ylab = ylab, ...)
  shade(light_stimuli(x), "#FFD70066")
  shade(x$get_blinks(), "#80808066")
  graphics::lines(time, size, col = col)
  invisible(x)
}

#' @method plot piprkit.analysis.fitting.phase_model.PhaseModel
#' @export
plot.piprkit.analysis.fitting.phase_model.PhaseModel <- function(x, y, ..., col = "grey50", fit_col = "red",
                                                                 xlab = "Time (s)", ylab = "Pupil size") {
  time <- as.vector(x$get_time())
  size <- as.vector(x$get_size())
  graphics::plot(time, size, type = "n", xlab = xlab, ylab = ylab, ...)
  shade(list(x$get_light_stimulus()$get_timing()), "#FFD70066")
  graphics::points(time, size, pch = 16, cex = 0.3, col = col)
  graphics::lines(time, as.vector(x$get_predicted()), col = fit_col, lwd = 2)
  invisible(x)
}

# The (start, end) of each light stimulus: one for a measurement, several for a series
light_stimuli <- function(x) {
  if (inherits(x, "piprkit.core.pupil_series.PupilSeries")) {
    return(x$get_light_stimuli_series()$get_timings())
  }
  stimulus <- x$get_light_stimulus()
  if (is.null(stimulus)) list() else list(stimulus$get_timing())
}

shade <- function(periods, col) {
  limits <- graphics::par("usr")
  for (period in periods) {
    graphics::rect(period[[1]], limits[3], period[[2]], limits[4], col = col, border = NA)
  }
}
