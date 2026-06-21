# Replication Notes

## Overview

This repository provides a maintained replication layer for Gertler, Green, and
Wolfram (2024), "Digital Collateral." The maintained code reproduces the final
output inventory from the original Dataverse replication package using Stata
and Python.

The maintained output target is:

- 42 LaTeX table files
- 9 figure files

The original Dataverse package contains Stata, R, Matlab, and notebook code
with author-local path conventions. This repository keeps that package
separate and uses repo-relative maintained entrypoints for reproduction.

## Data Availability And Provenance

The original replication package is available from Harvard Dataverse:

- Dataset title: "Replication Data for: Digital Collateral"
- DOI: https://doi.org/10.7910/DVN/WWES0L

Download and extract the original package so this repository contains:

```text
dataverse_files/Gertler. Green. and Wolfram/
```

The original Dataverse package is not tracked by git and is not relicensed by
this repository. The maintained code stages the required inputs from that local
download into `data/raw/`.

The staging script also copies the original final tables and figures into:

```text
data/raw/reference_outputs/
```

Those reference outputs are used for manual verification of the reproduced
files.

## Software Requirements

The maintained replication workflow uses:

- Stata
- Python 3.11+

Install Python requirements from the repository root:

```bash
python -m pip install -r requirements.txt
```

Install and verify required Stata user-written dependencies by opening this
file in Stata and clicking Run:

```text
code/setup/install_stata_dependencies.do
```

The Stata replication entrypoint checks dependencies before running the
analysis. It reports dependency failures in the Stata log rather than installing
packages during replication execution.

## Instructions For Replicators

Run the following steps from a fresh clone after downloading the original
Dataverse package.

1. Place the extracted Dataverse package at:

   ```text
   dataverse_files/Gertler. Green. and Wolfram/
   ```

2. Stage raw inputs and reference outputs from the repository root:

   ```bash
   python code/setup/prepare_raw_files.py
   ```

3. Install Python requirements:

   ```bash
   python -m pip install -r requirements.txt
   ```

4. In Stata, open and run:

   ```text
   code/setup/install_stata_dependencies.do
   ```

5. In Stata, open and run the maintained Stata entrypoint:

   ```text
   code/replication/run_replication.do
   ```

   After cloning this repository, open the repository folder in File Explorer,
   double-click this do-file, and click Run in Stata. If Stata cannot find the
   repository root, start Stata from the repository root or set the
   `GGW_REPO_ROOT` environment variable to the cloned repository path before
   opening Stata.

6. From the repository root, run the maintained Python final-output entrypoint:

   ```bash
   python code/replication/run_python_outputs.py
   ```

7. Compare reproduced outputs under `output/results/` with the staged
   reference outputs under `data/raw/reference_outputs/`. Record verification
   status in:

   ```text
   docs/verification_checklist.md
   ```

## Code Description

The maintained Stata workflow is:

```text
code/replication/run_replication.do
```

It runs the ordered Stata pipeline:

1. `00_header.do`: path setup, directory checks, guards, and dependency checks
2. `01_lsms_support.do`: LSMS support intermediates
3. `02_baseline_support.do`: baseline survey support intermediates
4. `03_endline_support.do`: endline survey and education-index support
   intermediates
5. `04_final_outputs.do`: maintained Stata final-output modules

Maintained Stata intermediates are written under:

```text
data/processed/stata/
```

Maintained Stata logs are written under:

```text
output/logs/stata/
```

The maintained Python workflow is:

```text
code/replication/run_python_outputs.py
```

It reproduces the non-Stata final outputs that were originally generated from
R, Matlab, and notebook code.

R, Matlab, and Jupyter notebooks in the original Dataverse package are treated
as source-provenance material, not maintained execution entrypoints for this
repository.

## Output Inventory

Reproduced final outputs are tracked under:

```text
output/results/
```

The maintained Stata pipeline writes 41 table files to:

```text
output/results/tables/
```

and one Stata figure to:

```text
output/results/figures/
```

The maintained Python pipeline writes one table file to:

```text
output/results/tables/
```

and eight figure files to:

```text
output/results/figures/
```

The output map for maintained modules and source provenance is:

```text
docs/output_map.md
```

## Verification Notes

The verification checklist is the public record of output comparison:

```text
docs/verification_checklist.md
```

The checklist should record whether each reproduced output matches the staged
reference output, with any formatting, software-version, or stochastic
differences documented explicitly.

Stata runtime behavior should be validated in the local Stata environment used
for reproduction. File inspection and output comparison can support the
verification record, but the Stata log from the local run is the evidence that
the Stata workflow executed successfully.

## Repository Boundaries

The maintained pipeline reads staged inputs from:

```text
data/raw/
```

Maintained generated intermediates are written outside `data/raw`, primarily
under:

```text
data/processed/stata/
```

Final reproduced outputs are written under:

```text
output/results/
```

The original Dataverse package, staged raw inputs, processed intermediates,
logs, and private working notes are not part of the tracked maintained source
release.

## Current Status

Current milestone and release-readiness status are recorded in:

```text
PROJECT_STATUS.md
```

As of 21 Jun 2026, M6 public handoff is complete and the repository is marked
release-ready in `PROJECT_STATUS.md`.
