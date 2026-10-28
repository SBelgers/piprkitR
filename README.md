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



## Example

<table>
<tr>
<th>Python</th>
<th>R</th>
</tr>
<tr>
<td>

```python
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
measurements = ps.split(
    pre_stimulus_duration=12.0, 
    post_stimulus_duration=55.0
)
```

</td>
<td>

```r
ps <- piprkit$load_real_series()
measurements <- ps$split(
  pre_stimulus_duration = 12.0, 
  post_stimulus_duration = 55.0
)
```

</td>
</tr>
<tr>
<td>

```python
fig, axes = plt.subplots(
    1, 2, sharey=True, 
    figsize=(10, 4.5), 
    layout="constrained"
)

for i, pm in enumerate(measurements[4:6]):
    # Minor amount of processing
    pm.filters.rolling_median(1)
    pm.filters.apply_baseline_correction()
    # Get the 6s-PIPR from the measurement
    pipr_6s = pm.metrics.pipr_6s()
    # Fit the phase model to the measurement 
    # and get the 6s-PIPR
    model = piprkit.PhaseModel(pm)
    pm_model = model.to_measurement()
    pipr_6s_model = pm_model.metrics.pipr_6s()
    # Display the results
    pm.plot(ax=axes[i])
    model.plot_phases(ax=axes[i])
    pm.plot_light_stimulus(ax=axes[i])
    pipr_6s.plot(ax=axes[i])
    pipr_6s_model.plot(ax=axes[i])
plt.show()
```

</td>
<td>

```r
axes <- plt$subplots(
  1L, 2L, sharey = TRUE, 
  figsize = c(10, 4.5), 
  layout = "constrained"
)[[2]]

for (i in 1:2) {
  pm <- measurements[[4 + i]]
  # Minor amount of processing
  pm$filters$rolling_median(1)
  pm$filters$apply_baseline_correction()
  # Get the 6s-PIPR from the measurement
  pipr_6s <- pm$metrics$pipr_6s()
  # Fit the phase model to the measurement 
  # and get the 6s-PIPR
  model <- piprkit$PhaseModel(pm)
  pm_model <- model$to_measurement()
  pipr_6s_model <- pm_model$metrics$pipr_6s()
  # Display the results
  pm$plot(ax = axes[[i]])
  model$plot_phases(ax = axes[[i]])
  pm$plot_light_stimulus(ax = axes[[i]])
  pipr_6s$plot(ax = axes[[i]])
  pipr_6s_model$plot(ax = axes[[i]])
}
plt$savefig("example.png")
```

</td>
</tr>
</table>

The tests of this package run a longer example, with more metrics, in R and in Python and check that
the metrics and the CSV files are identical.



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

## License

MIT, see [LICENSE.md](LICENSE.md).
