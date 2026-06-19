*** Purpose: Researcher-facing ordered Stata replication pipeline.

version 16
set more off

args requested_workflow
if "`requested_workflow'" != "" {
    display as error "code/replication/run_replication.do is an ordered pipeline and does not accept arguments."
    display as error "Open code/replication/run_replication.do in Stata and click Run."
    exit 198
}

local repo_root = subinstr(c(pwd), "\", "/", .)
capture confirm file "`repo_root'/README.md"
local repo_root_ok = (_rc == 0)
if `repo_root_ok' {
    capture confirm file "`repo_root'/docs/staged_input_coverage.md"
    local repo_root_ok = (_rc == 0)
}

if !`repo_root_ok' {
    local userprofile : env USERPROFILE
    local userprofile = subinstr("`userprofile'", char(92), "/", .)
    local repo_root "`userprofile'/Desktop/Lifthrasir/Gertler_Green_Wolfram_2024_replication"
    capture confirm file "`repo_root'/README.md"
    local repo_root_ok = (_rc == 0)
    if `repo_root_ok' {
        capture confirm file "`repo_root'/docs/staged_input_coverage.md"
        local repo_root_ok = (_rc == 0)
    }
    if !`repo_root_ok' {
        display as error "Could not find repository root from Stata working directory: " c(pwd)
        display as error "Open code/replication/run_replication.do from this repository or run Stata from the repository root."
        exit 601
    }
}

cd "`repo_root'"
global repo_root "`repo_root'"

do "$repo_root/code/replication/setup_globals.do"

capture log close _all
log using "$stata_logs/run_replication.smcl", replace name(replication)

display as text "repo root: $repo_root"
display as text "Stata version: " c(stata_version)
display as text "started: " c(current_date) " " c(current_time)

local pipeline_rc = 0

display as text "Step 0: foundation setup and dependency checks"
display as text "initialized global bsvy_raw: $bsvy_raw"
display as text "initialized global esvy_raw: $esvy_raw"
display as text "initialized global bsvy_clean: $bsvy_clean"
display as text "initialized global esvy_clean: $esvy_clean"
display as text "initialized global temp: $temp"
display as text "initialized global processed_stata: $processed_stata"
display as text "initialized global lsms2018: $lsms2018"
display as text "initialized global lsms_processed: $lsms_processed"
display as text "initialized global lsms_asset_prices: $lsms_asset_prices"
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
display as text "checking maintained generated path tables: $tables"
assert_maintained_generated_path "$tables" "tables"
display as text "checking maintained generated path figures: $figures"
assert_maintained_generated_path "$figures" "figures"
display as text "checking maintained generated path stata_logs: $stata_logs"
assert_maintained_generated_path "$stata_logs" "stata_logs"
display as result "Maintained generated path checks completed."

capture noisily do "$repo_root/code/replication/check_stata_dependencies.do"
if _rc {
    local pipeline_rc = _rc
}

if `pipeline_rc' == 0 {
    display as text "Step 1: LSMS support construction"
    capture noisily do "$repo_root/code/replication/01_lsms_support.do"
    if _rc {
        local pipeline_rc = _rc
    }
}

if `pipeline_rc' {
    display as error "completion status: failed"
    display as error "failed: " c(current_date) " " c(current_time)
    log close replication
    exit `pipeline_rc'
}

display as text "completion status: completed"
display as text "completed: " c(current_date) " " c(current_time)

log close replication
