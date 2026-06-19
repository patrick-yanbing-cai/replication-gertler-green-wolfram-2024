*** Purpose: Step 0, define and verify maintained Stata replication globals.

args header_mode
if !inlist("`header_mode'", "", "verify") {
    display as error "Unsupported 00_header.do mode: `header_mode'"
    exit 198
}

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
global lsms_processed "$processed_stata/lsms"
global lsms_asset_prices "$lsms_processed/Asset prices data"
global bsvy_processed "$processed_stata/baseline_survey"
global esvy_processed "$processed_stata/endline_survey"

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
    `"$repo_root/data/processed/stata"' ///
    `"$lsms_processed"' ///
    `"$lsms_asset_prices"' ///
    `"$bsvy_processed"' ///
    `"$esvy_processed"' {
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

capture program drop assert_maintained_generated_path
program define assert_maintained_generated_path
    version 16
    args path label

    if "`path'" == "" {
        display as error "Maintained generated path is empty: `label'"
        exit 198
    }

    local normalized "`path'"
    local normalized = subinstr("`normalized'", char(92), "/", .)
    local normalized = lower("`normalized'")

    local raw_root "$repo_root/data/raw"
    local raw_root = subinstr("`raw_root'", char(92), "/", .)
    local raw_root = lower("`raw_root'")
    local raw_prefix "`raw_root'/"

    if "`normalized'" == "`raw_root'" | substr("`normalized'", 1, length("`raw_prefix'")) == "`raw_prefix'" {
        display as error "Maintained generated path resolves under data/raw: `label' = `path'"
        display as error "Use $processed_stata for generated Stata intermediates, or output/results for final outputs."
        exit 198
    }
end

capture program drop assert_stata_intermediate_path
program define assert_stata_intermediate_path
    version 16
    args path label

    if "`path'" == "" {
        display as error "Maintained Stata intermediate path is empty: `label'"
        exit 198
    }

    local normalized "`path'"
    local normalized = subinstr("`normalized'", char(92), "/", .)
    local normalized = lower("`normalized'")

    local processed_root "$processed_stata"
    local processed_root = subinstr("`processed_root'", char(92), "/", .)
    local processed_root = lower("`processed_root'")
    local processed_prefix "`processed_root'/"

    if !("`normalized'" == "`processed_root'" | substr("`normalized'", 1, length("`processed_prefix'")) == "`processed_prefix'") {
        display as error "Maintained Stata intermediate path must resolve under data/processed/stata: `label' = `path'"
        exit 198
    }
end

if "`header_mode'" == "verify" {
    display as text "initialized global bsvy_raw: $bsvy_raw"
    display as text "initialized global esvy_raw: $esvy_raw"
    display as text "initialized global bsvy_clean: $bsvy_clean"
    display as text "initialized global esvy_clean: $esvy_clean"
    display as text "initialized global temp: $temp"
    display as text "initialized global processed_stata: $processed_stata"
    display as text "initialized global lsms2018: $lsms2018"
    display as text "initialized global lsms_processed: $lsms_processed"
    display as text "initialized global lsms_asset_prices: $lsms_asset_prices"
    display as text "initialized global bsvy_processed: $bsvy_processed"
    display as text "initialized global esvy_processed: $esvy_processed"
    display as text "initialized global merged: $merged"
    display as text "initialized global repay_clean: $repay_clean"
    display as text "initialized global tables: $tables"
    display as text "initialized global figures: $figures"
    display as text "initialized global stata_logs: $stata_logs"

    display as text "checking maintained generated path processed_stata: $processed_stata"
    assert_maintained_generated_path "$processed_stata" "processed_stata"
    assert_stata_intermediate_path "$processed_stata" "processed_stata"
    display as text "checking maintained generated path lsms_processed: $lsms_processed"
    assert_maintained_generated_path "$lsms_processed" "lsms_processed"
    assert_stata_intermediate_path "$lsms_processed" "lsms_processed"
    display as text "checking maintained generated path lsms_asset_prices: $lsms_asset_prices"
    assert_maintained_generated_path "$lsms_asset_prices" "lsms_asset_prices"
    assert_stata_intermediate_path "$lsms_asset_prices" "lsms_asset_prices"
    display as text "checking maintained generated path bsvy_processed: $bsvy_processed"
    assert_maintained_generated_path "$bsvy_processed" "bsvy_processed"
    assert_stata_intermediate_path "$bsvy_processed" "bsvy_processed"
    display as text "checking maintained generated path esvy_processed: $esvy_processed"
    assert_maintained_generated_path "$esvy_processed" "esvy_processed"
    assert_stata_intermediate_path "$esvy_processed" "esvy_processed"
    display as text "checking maintained generated path tables: $tables"
    assert_maintained_generated_path "$tables" "tables"
    display as text "checking maintained generated path figures: $figures"
    assert_maintained_generated_path "$figures" "figures"
    display as text "checking maintained generated path stata_logs: $stata_logs"
    assert_maintained_generated_path "$stata_logs" "stata_logs"
    display as result "Maintained generated path checks completed."

    do "$repo_root/code/replication/support/stata/check_dependencies.do"
}
