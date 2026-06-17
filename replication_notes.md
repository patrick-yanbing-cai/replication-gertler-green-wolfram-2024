# Replication Notes

## Project Goal

This repo builds a cleaned Stata/Python replication layer for Gertler, Green, and Wolfram (2024), "Digital Collateral."

The original Dataverse package remains separate under:

```text
dataverse_files/Gertler. Green. and Wolfram/
```

It is treated as read-only source material and is not tracked by git.

## Initial Decisions

- Maintain only Stata and Python code in this repo's formal replication layer.
- Do not require R, Matlab, or Jupyter notebooks for the maintained pipeline.
- Do not modify the original Dataverse package.
- Stage raw inputs into `data/raw/` before running replication code.
- Track final reproduced outputs under `output/results/`.
- Use manual verification records rather than a complex automated comparison tool.

## Current Raw Package Observations

The original package includes:

- 42 table files under `tables/`
- 9 figure files under `figures/`
- Stata, R, Matlab, and notebook scripts under `scripts/`
- A hardcoded local path in `scripts/a1_globals.do`
- Hardcoded local paths in the original R figure scripts

## Output Target

First-version replication target:

- all 42 original `.tex` table files
- all 9 original figure files

Each output should be reproduced from the maintained pipeline and checked in `docs/verification_checklist.md`.

## Change Log

### 2026-06-17

- Created initial repository skeleton.
- Added `code/setup/prepare_raw_files.py` to stage the original Dataverse package into `data/raw/`.
- Added initial README and verification checklist.
