# The Python module piprkit; imported when it is first used
.py <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  reticulate::py_require("piprkit>=0.1.0", python_version = ">=3.12")
  .py$piprkit <- reticulate::import("piprkit", delay_load = list(
    on_load = use_matplotlib_backend,
    on_error = stop_missing_piprkit
  ))
}

# R cannot reliably show matplotlib windows (on Windows the Tk backend finds the
# Tcl of R and fails), so figures use the agg backend, as reticulate does in R
# Markdown; save them with savefig(). MPLBACKEND sets another backend.
use_matplotlib_backend <- function() {
  backend <- Sys.getenv("RETICULATE_MPLBACKEND", Sys.getenv("MPLBACKEND"))
  if (!nzchar(backend)) {
    backend <- "agg"
  }
  reticulate::import("matplotlib")$use(backend, force = FALSE)
}

stop_missing_piprkit <- function(error) {
  python <- tryCatch(reticulate::py_config()$python, error = function(e) "the selected Python")
  stop(
    "The Python package piprkit could not be loaded from ", python, ".\n",
    "Install it there with reticulate::py_install(\"piprkit\"), or start a new R session and run\n",
    "Sys.setenv(RETICULATE_PYTHON = \"managed\") before library(piprkitR), so that reticulate\n",
    "sets up its own Python with piprkit.\n\n",
    "Original error: ", conditionMessage(error),
    call. = FALSE
  )
}
