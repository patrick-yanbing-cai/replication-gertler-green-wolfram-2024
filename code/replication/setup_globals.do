*** Purpose: Define maintained repo-relative globals for Stata replication code.

if "$repo_root" == "" {
    display as error "repo_root global is not defined. Run code/replication/run_replication.do from the repository root."
    exit 198
}

capture confirm file "$repo_root/README.md"
if _rc {
    display as error "README.md was not found under repo_root: $repo_root"
    display as error "Run from the repository root, or set repo_root to the repository root before loading globals."
    exit 601
}

capture confirm file "$repo_root/docs/staged_input_coverage.md"
if _rc {
    display as error "docs/staged_input_coverage.md was not found under repo_root: $repo_root"
    exit 601
}

***********************
** Survey data paths **
***********************

global bsvy_raw "$repo_root/data/raw/baseline_survey/raw"
global esvy_raw "$repo_root/data/raw/endline_survey/raw"
global bsvy_clean "$repo_root/data/raw/baseline_survey/clean"
global esvy_clean "$repo_root/data/raw/endline_survey/clean"

* Staged author-provided/reference intermediates. Maintained generated
* Stata intermediates should use $processed_stata instead.
global temp "$repo_root/data/raw/interim"
global processed_stata "$repo_root/data/processed/stata"

* Uganda LSMS data, 2018
global lsms2018 "$repo_root/data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12"

***********************
** Merged data paths **
***********************

global merged "$repo_root/data/raw/merged"

*****************************************
** Fenix customer repayment data paths **
*****************************************

global repay_clean "$repo_root/data/raw/repayment"

******************
** Output paths **
******************

global tables "$repo_root/output/results/tables"
global figures "$repo_root/output/results/figures"
global stata_logs "$repo_root/output/logs/stata"

foreach dir in ///
    `"$repo_root/output"' ///
    `"$repo_root/output/results"' ///
    `"$repo_root/output/results/tables"' ///
    `"$repo_root/output/results/figures"' ///
    `"$repo_root/output/logs"' ///
    `"$repo_root/output/logs/stata"' ///
    `"$repo_root/data"' ///
    `"$repo_root/data/processed"' ///
    `"$repo_root/data/processed/stata"' {
    capture mkdir "`dir'"
    mata: st_numscalar("dir_exists", direxists("`dir'"))
    if scalar(dir_exists) == 0 {
        display as error "Could not create required maintained output directory: `dir'"
        exit 603
    }
}

foreach required_source in ///
    `"$bsvy_raw"' ///
    `"$esvy_raw"' ///
    `"$bsvy_clean"' ///
    `"$esvy_clean"' ///
    `"$temp"' ///
    `"$lsms2018"' ///
    `"$merged"' ///
    `"$repay_clean"' {
    mata: st_numscalar("dir_exists", direxists("`required_source'"))
    if scalar(dir_exists) == 0 {
        display as error "Missing required source directory: `required_source'"
        display as error "Run python code/setup/prepare_raw_files.py before running maintained Stata modules."
        exit 601
    }
}
