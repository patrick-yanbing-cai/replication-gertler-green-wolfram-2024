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
|-- code/
|   |-- setup/
|   |   |-- prepare_raw_files.py
|   |   `-- install_stata_dependencies.do
|   `-- replication/
|       |-- run_replication.do          # single clickable Stata entrypoint
|       |-- 00_header.do                # Step 0: globals, paths, guards, dependency checks
|       |-- 01_lsms_support.do          # Step 1: maintained LSMS support outputs
|       |-- 02_baseline_support.do      # Step 2: maintained baseline survey support outputs
|       |-- 03_endline_support.do       # Step 3: maintained endline survey support outputs
|       `-- support/
|           |-- stata/
|           |   `-- check_dependencies.do
|           |-- lsms/
|           |   |-- c2_build_asset_prices.do
|           |   |-- c3_build_busasset_prices.do
|           |   |-- c4_build_lsms_chars.do
|           |   `-- d11_lsms_vars_build.do
|           |-- baseline/
|           |   |-- d9_construct_bsvysec_2.do
|           |   `-- e1_build_bsvysec.do
|           `-- endline/
|               |-- d10_construct_esvysec_2.do
|               |-- f1_educ_index_prep_female.do
|               `-- f2_educ_index_prep_male.do
|-- data/
|   |-- raw/                            # generated from dataverse_files/, not tracked
|   `-- processed/                      # generated intermediate data, not tracked
|-- docs/
|   `-- verification_checklist.md
|-- output/
|   `-- results/
|       |-- figures/                    # final reproduced figures, tracked
|       `-- tables/                     # final reproduced tables, tracked
|-- dataverse_files/                    # original package, not tracked
|-- README.md
`-- replication_notes.md
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

Install and verify required user-written Stata dependencies once by opening
this file in Stata's do-file editor and clicking Run:

```text
code/setup/install_stata_dependencies.do
```

Then run maintained Stata code through the single top-level replication
entrypoint. The entrypoint can be opened directly in Stata's do-file editor and
run without first changing Stata's working directory. Opening this file and
clicking Run starts the ordered replication workflow:

```text
code/replication/run_replication.do
```

The ordered workflow uses `00_header.do` for Step 0 header, path, and
dependency checks, then runs numbered research steps. The current maintained
research steps are `01_lsms_support.do`, which builds LSMS support
intermediates, `02_baseline_support.do`, which builds baseline survey support
intermediates, and `03_endline_support.do`, which builds endline survey and
education-index support intermediates.

The replication log is written to:

```text
output/logs/stata/run_replication.smcl
```

Maintained LSMS support outputs are written under `data/processed/stata/lsms`,
including asset price lookups and LSMS income, individual, and household support
datasets.

Maintained baseline survey support outputs are written under
`data/processed/stata/baseline_survey`, including `hhvars_baseline.dta` for
later Stata final-output modules.

Maintained endline survey support outputs are written under
`data/processed/stata/endline_survey`, including endline household support files
and female/male education-index files for later Stata final-output modules.

Maintained table and figure outputs are written under `output/results/`.
Author-provided staged intermediates remain under `data/raw/interim`, while
maintained Stata intermediates should be written under `data/processed/stata`.

---

## Requirements

The maintained replication code uses:

- Stata
- Python 3.11+

Stata dependency setup is maintained as clickable executable Stata code in
`code/setup/install_stata_dependencies.do`. The replication workflow checks
dependencies in one preflight run and reports failures in
`output/logs/stata/run_replication.smcl`; the replication entrypoint does not
auto-install Stata packages.

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
