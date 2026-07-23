# fixtures

This directory contains `pkgreviewtest/`, a small R data package with seventeen deliberately planted defects. It serves as a test harness for the openwashdata package review workflow: running the full review (metadata, data, docs, tests) against it must surface every planted defect. The expected findings, the checklist items that must catch them, and the acceptance gate for checklist changes are documented in [SCORECARD.md](SCORECARD.md).

Do not fix the defects in the fixture package; they are the whole point. If the planted defects must change, regenerate the data files with `Rscript fixtures/make_pkgreviewtest.R` (deterministic, base R plus an optional xlsx writer), adjust the static files by hand, and update SCORECARD.md in the same change.
