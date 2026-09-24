# Status

Remote telemetry support is under review in
<https://github.com/archer-clawbot/omarchy-hermes-harness/pull/1>.

The adapter validates the entire input record before using it and derives node
counters from the final map. Local launch requires a valid completed status
refresh with a successful command exit. Shell regressions and Qt status-state
tests cover malformed records, duplicate aliases, counter mismatches and launch
readiness; CI runs both suites. The Qt tests run offscreen and do not exercise
the installed desktop plugin.

Open work: `gh pr view 1 --repo archer-clawbot/omarchy-hermes-harness`.
