# Replication: Gertler, Green, and Wolfram (2024)

## "Digital Collateral"

Paul Gertler, Brett Green, and Catherine Wolfram  
*Quarterly Journal of Economics*, 139(3): 1713-1766

---

## What This Repo Does

This repository is a cleaned, maintainable replication project for Gertler,
Green, and Wolfram (2024), "Digital Collateral."

The original Dataverse package contains Stata, R, Matlab, and notebook code,
with path conventions tied to the authors' local folder layout. This repo
keeps the original package separate and builds a maintained replication layer
using Stata and Python.

The maintained output target is the full final-output inventory copied from the
Dataverse package:

- 42 LaTeX table files
- 9 figure files

Current release readiness is tracked in `PROJECT_STATUS.md`. The repository is
not release-ready until the M6 public handoff work is complete.

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
|       |-- run_replication.do          # maintained Stata entrypoint
|       |-- run_python_outputs.py       # maintained Python final-output entrypoint
|       |-- 00_header.do                # Step 0: globals, paths, guards, dependency checks
|       |-- 01_lsms_support.do          # Step 1: maintained LSMS support outputs
|       |-- 02_baseline_support.do      # Step 2: maintained baseline survey support outputs
|       |-- 03_endline_support.do       # Step 3: maintained endline survey support outputs
|       |-- 04_final_outputs.do         # Step 4: maintained Stata final outputs
|       |-- final_outputs/              # maintained Stata final-output modules
|       |-- python_outputs/
|       |   |-- loan_irr_figures.py
|       |   |-- loan_irr_table.py
|       |   `-- repayment_rate_figures.py
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
|   |-- output_map.md
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
4. Copies the original package's final tables and figures into
   `data/raw/reference_outputs/` for manual verification.
5. Writes a preparation marker file.

The maintained replication pipeline reads from `data/raw/`, not directly from
`dataverse_files/`.

---

## Stata Replication Entrypoint

Install and verify required user-written Stata dependencies once by opening
this file in Stata's do-file editor and clicking Run:

```text
code/setup/install_stata_dependencies.do
```

Then run maintained Stata code through the top-level replication entrypoint.
The entrypoint can be opened directly in Stata's do-file editor and run without
first changing Stata's working directory. Opening this file and clicking Run
starts the ordered replication workflow:

```text
code/replication/run_replication.do
```

The ordered workflow runs:

1. `00_header.do`: header, path, guard, and dependency checks.
2. `01_lsms_support.do`: LSMS support intermediates.
3. `02_baseline_support.do`: baseline survey support intermediates.
4. `03_endline_support.do`: endline survey and education-index support
   intermediates.
5. `04_final_outputs.do`: maintained Stata final-output modules.

The replication log is written to:

```text
output/logs/stata/run_replication.smcl
```

Maintained LSMS support outputs are written under `data/processed/stata/lsms`,
including asset price lookups and LSMS income, individual, and household
support datasets.

Maintained baseline survey support outputs are written under
`data/processed/stata/baseline_survey`, including `hhvars_baseline.dta` for
later Stata final-output modules.

Maintained endline survey support outputs are written under
`data/processed/stata/endline_survey`, including endline household support
files, locked-occurrence support, and female/male education-index files for
later Stata final-output modules.

The maintained Stata pipeline writes 41 table files to `output/results/tables`
and `takeupbywtp_dif.png` to `output/results/figures`. Author-provided staged
intermediates remain under `data/raw/interim`, while maintained Stata
intermediates are written under `data/processed/stata`.

---

## Python Final Outputs

Maintained non-Stata final outputs are generated through the Python entrypoint:

```bash
python code/replication/run_python_outputs.py
```

The Python final-output entrypoint generates:

- Four repayment and completion rate PDF figures from staged repayment data
  under `data/raw/repayment`.
- Four loan IRR PNG/EPS figure files from staged IRR inputs under
  `data/raw/interim`.
- `r_treatment_irr_withCI.tex` from staged cash-flow data under
  `data/raw/interim`.

Outputs are written under `output/results/figures` and
`output/results/tables`.

---

## Requirements

The maintained replication code uses:

- Stata
- Python 3.11+

Install the Python package requirements with:

```bash
python -m pip install -r requirements.txt
```

Stata dependency setup is maintained as clickable executable Stata code in
`code/setup/install_stata_dependencies.do`. The replication workflow checks
dependencies in one preflight run and reports failures in
`output/logs/stata/run_replication.smcl`; the replication entrypoint does not
auto-install Stata packages.

R, Matlab, and Jupyter notebooks may exist in the original Dataverse package,
but they are source-provenance material, not maintained execution entrypoints
for this repo.

---

## Verification

Verification is tracked manually in `docs/verification_checklist.md`.
Output provenance and source-to-module mapping are tracked in
`docs/output_map.md`.

Each final output should be checked against the staged reference output under:

```text
data/raw/reference_outputs/
```

Newly generated outputs should be written to:

```text
output/results/
```

The current verification target is exactly 42 table rows and 9 figure rows.
Every output should be checked against the corresponding required output, with
any formatting, software-version, or stochastic differences documented
explicitly in `docs/verification_checklist.md`.

---

## Citation

Gertler, Paul, Brett Green, and Catherine Wolfram. 2024. "Digital Collateral." *Quarterly Journal of Economics* 139(3): 1713-1766. https://doi.org/10.1093/qje/qjae003
