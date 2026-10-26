# piprkitR

[![R-CMD-check](https://github.com/SBelgers/piprkitR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/SBelgers/piprkitR/actions/workflows/R-CMD-check.yaml)

R interface to [piprkit](https://github.com/SBelgers/piprkit), a Python package for processing pupil
data with a focus on the post-illumination pupil response (PIPR): filtering, blink removal, baseline
correction, PIPR metrics, and fitting a model of the pupil light response.

piprkitR gives access to the complete piprkit API from R through
[reticulate](https://rstudio.github.io/reticulate/). All computations run in the Python package, so the
results in R are identical to those in Python. The
[piprkit documentation](https://sbelgers.github.io/piprkit/) applies to R as well: use `$` where Python
uses `.`.

## Installation

```r
# install.packages("pak")
pak::pak("SBelgers/piprkitR")
```

Python and piprkit are installed automatically the first time piprkit is used: reticulate sets up its
own Python environment with piprkit. This needs an internet connection once and takes about a minute.

To use your own Python environment instead, install piprkit there (`pip install piprkit`, Python 3.12
or newer) and select it before piprkit is first used, e.g. with `reticulate::use_virtualenv()`. Note
that reticulate also uses an activated virtual environment (`VIRTUAL_ENV`) or the Python in
`RETICULATE_PYTHON`. Either install piprkit there, or run `Sys.setenv(RETICULATE_PYTHON = "managed")`
before `library(piprkitR)` to use the automatic environment.

## Example

<table>
<tr>
<th>Python</th>
<th>R</th>
</tr>
<tr>
<td>

```python
import tempfile
from pathlib import Path

import matplotlib.pyplot as plt

import piprkit
```

</td>
<td>

```r
library(piprkitR)
plt <- reticulate::import("matplotlib.pyplot")
```

</td>
</tr>
<tr>
<td>

```python
ps = piprkit.load_real_series()
ps.filters.rolling_mean(0.1)
ps.filters.limit_rate_of_change()
ps.drop_nan()
ps.add_blinks([(153.5, 156.5)])
ps.filters.remove_blinks()
ps.trim_size()

trials = ps.split(pre_stimulus_duration=10.0, post_stimulus_duration=55.0)
```

</td>
<td>

```r
ps <- piprkit$load_real_series()
ps$filters$rolling_mean(0.1)
ps$filters$limit_rate_of_change()
ps$drop_nan()
ps$add_blinks(list(c(153.5, 156.5)))
ps$filters$remove_blinks()
ps$trim_size()

trials <- ps$split(pre_stimulus_duration = 10.0, post_stimulus_duration = 55.0)
```

</td>
</tr>
<tr>
<td>

```python
rows = []
fig, axes = plt.subplots(len(trials), 1, figsize=(8, 2.5 * len(trials)), sharex=True, sharey=True)
for number, (trial, ax) in enumerate(zip(trials, axes), start=1):
    baseline = trial.metrics.baseline(duration=5.0)
    trial.filters.apply_baseline_correction(duration=5.0)
    model = piprkit.PhaseModel(trial, baseline_duration=5.0)

    results = [
        baseline,
        trial.metrics.peak_constriction(),
        trial.metrics.time_to_peak(),
        trial.metrics.pipr_6s(),
        trial.metrics.auc_early(baseline_duration=5.0),
        model.metrics.constriction_v(),
        model.metrics.redilation_v(),
        model.metrics.plateau_pipr(),
    ]
    rows += piprkit.metric_rows(results, participant="example", trial=number)

    model.plot(ax=ax, scatter=True, s=2, color="grey", label=f"Trial {number}")
    model.plot_phases(ax=ax)
    model.plot_light_stimulus(ax=ax)
    ax.legend(fontsize=7, loc="lower right")
axes[-1].set_xlabel("Time (s)")
plt.show()
```

</td>
<td>

```r
rows <- list()
axes <- plt$subplots(length(trials), 1L, figsize = c(8, 2.5 * length(trials)), sharex = TRUE, sharey = TRUE)[[2]]
for (number in seq_along(trials)) {
  trial <- trials[[number]]
  ax <- axes[[number]]
  baseline <- trial$metrics$baseline(duration = 5.0)
  trial$filters$apply_baseline_correction(duration = 5.0)
  model <- piprkit$PhaseModel(trial, baseline_duration = 5.0)

  results <- list(
    baseline,
    trial$metrics$peak_constriction(),
    trial$metrics$time_to_peak(),
    trial$metrics$pipr_6s(),
    trial$metrics$auc_early(baseline_duration = 5.0),
    model$metrics$constriction_v(),
    model$metrics$redilation_v(),
    model$metrics$plateau_pipr()
  )
  rows <- c(rows, piprkit$metric_rows(results, participant = "example", trial = number))

  model$plot(ax = ax, scatter = TRUE, s = 2, color = "grey", label = sprintf("Trial %d", number))
  model$plot_phases(ax = ax)
  model$plot_light_stimulus(ax = ax)
  ax$legend(fontsize = 7, loc = "lower right")
}
axes[[length(trials)]]$set_xlabel("Time (s)")
plt$savefig("full_example.png")
```

</td>
</tr>
<tr>
<td>

```python
with tempfile.TemporaryDirectory() as folder:
    path = Path(folder) / "metrics.csv"
    piprkit.save_metric_rows(rows, path)
    print(path.read_text())
```

</td>
<td>

```r
path <- file.path(tempdir(), "metrics.csv")
piprkit$save_metric_rows(rows, path)
writeLines(readLines(path))
```

</td>
</tr>
</table>

The tests of this package run this example in R and in Python and check that the metrics and the CSV
files are identical.

On Windows, a separate Python process can give results that differ in about the tenth significant
digit for the nonlinear redilation fit (`redilation_v()`, `plateau_pipr()`). Python on Windows sets the
x87 floating-point unit to double precision, while R keeps it at extended precision. All other metrics
are bit-identical, and on Linux and macOS there is no such difference.

## From Python to R

| Python | R |
|---|---|
| `import piprkit` | `library(piprkitR)` |
| `piprkit.load_real_series()` | `piprkit$load_real_series()` |
| `ps.filters.rolling_mean(0.1)` | `ps$filters$rolling_mean(0.1)` |
| `[(153.5, 156.5)]` | `list(c(153.5, 156.5))` |
| `phases=("baseline", "redilation")` | `phases = c("baseline", "redilation")` |
| `None`, `True`, `False` | `NULL`, `TRUE`, `FALSE` |
| `trials[0]` | `trials[[1]]` |
| `for number, trial in enumerate(trials, start=1):` | `for (number in seq_along(trials)) { trial <- trials[[number]]; ... }` |
| `rows += piprkit.metric_rows(results, trial=number)` | `rows <- c(rows, piprkit$metric_rows(results, trial = number))` |
| `f"{result:.2f}"` | `sprintf("%.2f", result)` |

Metric results, such as `trial$metrics$pipr_6s()`, are numbers in R that keep the Python result:
`result$get_name()` gives the name of the metric and `result$get_flags()` the flags of a fitted phase.
Collect them with `list()` to pass them to `piprkit$metric_rows()` or `piprkit$net_pipr()`; `c()` turns
them into plain numbers.

## Good to know

- piprkit objects are Python objects. Methods such as `filters$rolling_mean()` change the object in
  place, and `y <- x` does not copy it; use `y <- x$copy()`.
- Indices in R start at 1, but column indices that go to Python, such as `time_col` in
  `piprkit$load_csv()`, start at 0. Column names, such as `time_col = "time"`, avoid the confusion.
- Arguments that Python needs as integers, such as `num_samples` or `rng`, can be given as whole
  numbers like `1000`.
- Python objects do not survive saving and restoring the R workspace; run the analysis again instead.
- Warnings of piprkit are printed by Python, as text in the console.

## Plots

`plot()` draws a measurement, a series or a fitted `PhaseModel` with base R graphics. The matplotlib
plots of piprkit work as well; save them to a file:

```r
ax <- model$plot(scatter = TRUE, s = 2, color = "grey")
model$plot_phases(ax = ax)
ax$figure$savefig("model.png")
```

R cannot reliably show matplotlib windows, so piprkitR uses matplotlib's non-interactive agg backend,
as reticulate does in R Markdown. Set the environment variable `MPLBACKEND` to use another backend.

## Versions

Report the versions used with:

```r
packageVersion("piprkitR")
piprkit$`__version__`
reticulate::py_config()
```

A specific version of piprkit can be requested with `reticulate::py_require("piprkit==0.1.0")` before
piprkit is first used.

## License

MIT, see [LICENSE.md](LICENSE.md).
