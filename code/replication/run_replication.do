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
    local env_repo_root : env GGW_REPO_ROOT
    local env_repo_root = subinstr("`env_repo_root'", char(92), "/", .)
    if "`env_repo_root'" != "" {
        local repo_root "`env_repo_root'"
        capture confirm file "`repo_root'/README.md"
        local repo_root_ok = (_rc == 0)
        if `repo_root_ok' {
            capture confirm file "`repo_root'/docs/staged_input_coverage.md"
            local repo_root_ok = (_rc == 0)
        }
    }
}

if !`repo_root_ok' {
    display as error "Could not find repository root."
    display as error "Current Stata working directory: " c(pwd)
    display as error "Run Stata from the repository root or set GGW_REPO_ROOT to the cloned repository path."
    exit 601
}

cd "`repo_root'"
global repo_root "`repo_root'"

do "$repo_root/code/replication/00_header.do"

capture log close _all
log using "$stata_logs/run_replication.smcl", replace name(replication)

display as text "repo root: $repo_root"
display as text "Stata version: " c(stata_version)
display as text "started: " c(current_date) " " c(current_time)

local pipeline_rc = 0

display as text "Step 0: header, paths, and dependency checks"
capture noisily do "$repo_root/code/replication/00_header.do" verify
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

if `pipeline_rc' == 0 {
    display as text "Step 2: baseline survey support construction"
    capture noisily do "$repo_root/code/replication/02_baseline_support.do"
    if _rc {
        local pipeline_rc = _rc
    }
}

if `pipeline_rc' == 0 {
    display as text "Step 3: endline survey support construction"
    capture noisily do "$repo_root/code/replication/03_endline_support.do"
    if _rc {
        local pipeline_rc = _rc
    }
}

if `pipeline_rc' == 0 {
    display as text "Step 4: Stata final-output construction"
    capture noisily do "$repo_root/code/replication/04_final_outputs.do"
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
