# Replication Notes

## Maintained Boundary

This repo maintains a Stata/Python replication layer for Gertler, Green, and
Wolfram (2024), "Digital Collateral." The original Dataverse package remains
separate under:

```text
dataverse_files/Gertler. Green. and Wolfram/
```

That package is treated as read-only source material and is not tracked by git.
Researchers should download and extract it locally, then run:

```bash
python code/setup/prepare_raw_files.py
```

The setup script stages the required raw inputs under `data/raw/` and copies
the original final tables and figures into `data/raw/reference_outputs/` for
manual verification. Maintained code should read from staged inputs under
`data/raw/`, not directly from `dataverse_files/`.

## Execution Boundary

The maintained Stata workflow is:

```text
code/replication/run_replication.do
```

That entrypoint runs Step 0 through Step 4: path and dependency checks, LSMS
support construction, baseline survey support construction, endline survey
support construction, and maintained Stata final-output construction. It writes
maintained Stata intermediates under `data/processed/stata`, Stata logs under
`output/logs/stata`, and Stata final outputs under `output/results`.

The maintained Python workflow is:

```bash
python code/replication/run_python_outputs.py
```

That entrypoint writes the maintained Python replacement outputs under
`output/results/figures` and `output/results/tables`.

R, Matlab, and Jupyter notebooks from the original Dataverse package are source
provenance, not maintained execution entrypoints for this repo.

## Output And Verification Boundary

The maintained final-output target is:

- 42 LaTeX table files
- 9 figure files

The split is 41 Stata table files plus one Stata figure, and one Python table
plus eight Python figure files. Final reproduced outputs are tracked under:

```text
output/results/
```

Reference outputs are staged locally under:

```text
data/raw/reference_outputs/
```

Manual verification is recorded in `docs/verification_checklist.md`. Source
provenance and maintained module mapping are recorded in `docs/output_map.md`.
Current milestone and release readiness status are recorded in
`PROJECT_STATUS.md`; do not treat the repository as release-ready until M6 is
complete.
