# fixtures

This directory contains `pkgreviewtest/`, a small R data package with seventeen deliberately planted defects. It serves as a test harness for the openwashdata package review workflow: running the full review (metadata, data, docs, tests) against it must surface every planted defect. The expected findings, the checklist items that must catch them, and the acceptance gate for checklist changes are documented in [SCORECARD.md](SCORECARD.md).

Do not fix the defects in the fixture package; they are the whole point. If the planted defects must change, regenerate the data files with `Rscript fixtures/make_pkgreviewtest.R` (deterministic, base R plus an optional xlsx writer), adjust the static files by hand, and update SCORECARD.md in the same change.

The mechanical gate (`bash fixtures/run_gate.sh`) and the case suite (`bash fixtures/run_cases.sh`) run the check script, which takes its metadata, docs, and tests lines from `washr::check_publication_readiness()`. Both therefore need washr installed at or above the version in `skills/pkgreview-core/WASHR_FLOOR`.
