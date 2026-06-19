*** Purpose: Install user-written Stata dependencies for the maintained pipeline.

version 16
set more off

display as text "Installing user-written Stata dependencies..."

local install_error 0

foreach package in estout ivregress2 ranktest ivreg2 blindschemes {
    display as text "Installing or updating `package' from SSC..."
    capture noisily ssc install `package', replace
    if _rc {
        local install_error 1
        display as error "Could not install required Stata package: `package'"
    }
}

if `install_error' {
    display as error "One or more required Stata packages could not be installed."
    display as error "Review all package install errors above, resolve them, then rerun this setup script."
    exit 111
}

display as result "Stata dependency installation completed."

local repo_root = subinstr(c(pwd), "\", "/", .)
capture confirm file "`repo_root'/code/replication/check_stata_dependencies.do"
local repo_root_ok = (_rc == 0)

if !`repo_root_ok' {
    local userprofile : env USERPROFILE
    local userprofile = subinstr("`userprofile'", char(92), "/", .)
    local repo_root "`userprofile'/Desktop/Lifthrasir/Gertler_Green_Wolfram_2024_replication"
    capture confirm file "`repo_root'/code/replication/check_stata_dependencies.do"
    local repo_root_ok = (_rc == 0)
}

if `repo_root_ok' {
    global repo_root "`repo_root'"
    display as text "Verifying installed Stata dependencies..."
    do "`repo_root'/code/replication/check_stata_dependencies.do"
}
else {
    display as text "Could not locate repository root for automatic dependency verification."
    display as text "Next open code/replication/run_replication.do in Stata and click Run."
}
