# The full example of the piprkit documentation, without the plots.
# full_example() in helper-piprkit.R is the same example in R.
import piprkit

ps = piprkit.load_real_series()
ps.filters.rolling_mean(0.1)
ps.filters.limit_rate_of_change()
ps.drop_nan()
ps.add_blinks([(153.5, 156.5)])
ps.filters.remove_blinks()
ps.trim_size()

trials = ps.split(pre_stimulus_duration=10.0, post_stimulus_duration=55.0)

rows = []
for number, trial in enumerate(trials, start=1):
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
