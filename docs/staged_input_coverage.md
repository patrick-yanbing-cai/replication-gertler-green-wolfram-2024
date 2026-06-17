# Staged Input Coverage

This audit maps the original path assumptions in
`dataverse_files/Gertler. Green. and Wolfram/scripts/a1_globals.do` to the
staged repository layout under `data/raw/`.

The original `home` local points to the authors' local replication root:

```stata
local home "/Users/rpickmans/Library/CloudStorage/Dropbox/Fenix Solar/02-schoolFeeLoans/Replication"
```

In this repository, the comparable source root is the downloaded package at
`dataverse_files/Gertler. Green. and Wolfram/`. Maintained code should read the
standardized staged copy under `data/raw/` instead of using `home`.

## Path Globals

| Original global | Original path under `home` | Staged repo path | Coverage | Notes |
|---|---|---|---|---|
| `bsvy_raw` | `data/baseline survey/raw` | `data/raw/baseline_survey/raw` | raw input | Contains the baseline survey source file staged from the Dataverse package. |
| `esvy_raw` | `data/endline survey/raw` | `data/raw/endline_survey/raw` | raw input | Contains the endline survey source file staged from the Dataverse package. |
| `bsvy_clean` | `data/baseline survey/clean` | `data/raw/baseline_survey/clean` | cleaned source data | The original scripts both read and overwrite files in this directory. In this repo, the staged files are treated as source inputs copied from Dataverse. Maintained generated replacements should go outside `data/raw/`. |
| `esvy_clean` | `data/endline survey/clean` | `data/raw/endline_survey/clean` | cleaned source data | The original scripts both read and overwrite files in this directory. In this repo, the staged files are treated as source inputs copied from Dataverse. Maintained generated replacements should go outside `data/raw/`. |
| `temp` | `data/interim` | `data/raw/interim` | generated/intermediate reference data | Contains author-supplied intermediate files, including IRR CSV/MAT files and `mei_std_h1.dta`. Original scripts also write temporary education-index files here. Maintained intermediate outputs should go outside `data/raw/`. |
| `lsms2018` | `data/lsms/UGA_2018_UNPS_v01_M_STATA12` | `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12` | mixed raw and generated/reference data | Contains LSMS source section files plus author-generated files such as `income.dta`, `lsms2018_vars.dta`, `lsms_vars_hh.dta`, `lsms_vars_indiv.dta`, and files under `Asset prices data/`. |
| `merged` | `data/merged` | `data/raw/merged` | merged source/reference data | Contains `key_rep.dta`, an author-provided merged dataset used by final-output scripts. It is staged as an input even though it is not raw survey source data. |
| `repay_clean` | `data/repayment` | `data/raw/repayment` | cleaned source data | Contains Fenix repayment datasets and `commissions.dta` copied from Dataverse. |
| `tables` | `Tables` | `data/raw/reference_outputs/tables`; maintained outputs should use `output/results/tables` | reference output and maintained output | The original package directory is `tables`; the Stata global uses `Tables`, which works on case-insensitive filesystems. Staged original tables are reference outputs, not maintained pipeline inputs. |

## Other Staged Inputs

`prepare_raw_files.py` stages several package components that are not declared
as globals in `a1_globals.do`:

| Staged path | Coverage | Notes |
|---|---|---|
| `data/raw/reference_outputs/figures` | reference output | Original final figure files copied from `dataverse_files/Gertler. Green. and Wolfram/figures`. |
| `data/raw/reference_outputs/tables` | reference output | Original final table files copied from `dataverse_files/Gertler. Green. and Wolfram/tables`. |
| `data/raw/metadata/data_information_availability.xlsx` | metadata | Package documentation copied from the Dataverse root. |
| `data/raw/metadata/project_file_description.docx` | metadata | Package documentation copied from the Dataverse root. |
| `data/raw/questionnaires` | metadata/reference input | Survey questionnaires copied from `survey questionnaires/` when present. |

## Unresolved Or Missing Staged Inputs

No `a1_globals.do` path global is missing a staged equivalent in the current
`data/raw/` layout.

Two path categories need care in later output-map rows:

- `data/raw/interim` and parts of `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12`
  contain author-generated intermediate files, not only raw external inputs.
- The original `tables` global maps to final-output locations. Use
  `data/raw/reference_outputs/tables` for original reference outputs and
  `output/results/tables` for maintained outputs.
