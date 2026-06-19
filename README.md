# Replication: Gertler, Green, and Wolfram (2024)

## "Digital Collateral"

Paul Gertler, Brett Green, and Catherine Wolfram  
*Quarterly Journal of Economics*, 139(3): 1713-1766

---

## What This Repo Does

This repository is a cleaned, maintainable replication project for Gertler, Green, and Wolfram (2024), "Digital Collateral."

The original Dataverse package contains Stata, R, Matlab, and notebook code, with path conventions tied to the authors' local folder layout. This repo keeps the original package separate and builds a new replication layer using only Stata and Python.

The target for the first version is strict reproduction of all final outputs included in the Dataverse package:

- 42 LaTeX table files
- 9 figure files

---

## Data

Download the original replication package from Harvard Dataverse:

- Dataset title: "Replication Data for: Digital Collateral"
- DOI: https://doi.org/10.7910/DVN/WWES0L

After downloading, extract the package so the repository contains this path:

```text
dataverse_files/Gertler. Green. and Wolfram/
```

Do not rename the downloaded folder. The setup script expects the original extracted Dataverse layout.

The original package is not tracked by git.

---

## Repository Structure

```text
.
├── code/
│   ├── setup/
│   │   └── prepare_raw_files.py
│   └── replication/
├── data/
│   ├── raw/              # generated from dataverse_files/, not tracked
│   └── processed/        # generated intermediate data, not tracked
├── docs/
│   └── verification_checklist.md
├── output/
│   └── results/
│       ├── figures/      # final reproduced figures, tracked
│       └── tables/       # final reproduced tables, tracked
├── dataverse_files/      # original package, not tracked
├── README.md
└── replication_notes.md
```

---

## How to Prepare Raw Inputs

Run the staging script from the repository root:

```bash
python code/setup/prepare_raw_files.py
```

This script:

1. Checks that the original Dataverse package exists.
2. Clears and rebuilds `data/raw/`.
3. Copies source data into a standardized folder structure.
4. Copies the original package's final tables and figures into `data/raw/reference_outputs/` for manual verification.
5. Writes a preparation marker file.

The formal replication pipeline will read from `data/raw/`, not directly from `dataverse_files/`.

---

## Stata Replication Entrypoint

Run maintained Stata code through the single top-level entrypoint. The
entrypoint can be opened directly in Stata's do-file editor and run without
first changing Stata's working directory. The foundation selector initializes
repo-relative globals, creates output and log directories, checks required
staged source directories, writes a deterministic Stata log, and exits without
running final-output modules:

```stata
do "<repo-root>/code/replication/run_replication.do" foundation
```

From a shell in the repository root with Stata on `PATH`, the equivalent batch
command is:

```bash
stata-mp -b do code/replication/run_replication.do foundation
```

The foundation log is written to:

```text
output/logs/stata/run_foundation.smcl
```

Maintained table and figure outputs are written under `output/results/`.
Author-provided staged intermediates remain under `data/raw/interim`, while
maintained Stata intermediates should be written under `data/processed/stata`.

---

## Requirements

The maintained replication code will use:

- Stata
- Python 3.11+

R, Matlab, and Jupyter notebooks may exist in the original Dataverse package, but they are not part of this repo's maintained pipeline.

---

## Verification

Verification is tracked manually in `docs/verification_checklist.md`.

Each final output should be checked against the staged reference output under:

```text
data/raw/reference_outputs/
```

Newly generated outputs should be written to:

```text
output/results/
```

The goal is not approximate replication. Every table and figure included in the replication target should match the corresponding required output, with any formatting or software-version differences documented explicitly.

---

## Citation

Gertler, Paul, Brett Green, and Catherine Wolfram. 2024. "Digital Collateral." *Quarterly Journal of Economics* 139(3): 1713-1766. https://doi.org/10.1093/qje/qjae003
