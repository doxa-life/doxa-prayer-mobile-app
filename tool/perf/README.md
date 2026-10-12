# Performance walkthrough

Drives the real app on a connected iPhone through every screen and records frame
timings, time-to-content and memory per scenario, then compares against a saved baseline.

## Run

    tool/perf/run_perf.sh                       # one run, compare to baseline
    tool/perf/run_perf.sh --runs 3              # median of 3 (recommended for baselines)
    tool/perf/run_perf.sh --label "cheaper shadow"
    tool/perf/run_perf.sh --save-baseline       # make this run the baseline

Phone: unlocked, plugged in, Developer Mode on, same Wi-Fi each time, other apps closed.
Profile mode only; the script refuses Simulators unless `--allow-nonphysical`.
Uses the `staging` flavor (`FLAVOR=production` to override).

## What is measured (see integration_test/perf_test.dart)

startup (main → wizard → home) · home · each tab · the search page (idle, slow/fast scroll,
deep scroll, finger-drag, typing, filtered scroll, filter panel, sort) · details · map ·
settings screens · warm tab cycle.

Per scenario: wall time, named time-to-content marks, build/raster/total frame time
(avg, p50, p90, p99, max), dropped frames (over the refresh-rate budget), severe hitches
(over 2×), RSS and image-cache memory.

## Output

`build/perf/<time>_<label>/` → `run*.json` (raw), `report.json`, `report.md`.
`tool/perf/baseline.json` is the committed baseline. A change is only called a regression
or improvement if it exceeds 10% **and** a per-metric noise floor (see report.dart).

## Adding a scenario

Add `await run('group', 'unique_name', (s) async { ... })` in perf_test.dart. Keep names
stable — they key the baseline. Not covered yet: wizard steps (only boot → home), prayer
sessions (`/people-groups/:slug/pray`).
