*** Purpose: Check Stata dependencies required by maintained replication modules.

version 16

local dependency_error 0

display as text "Checking Stata dependencies..."

capture which esttab
if _rc {
    local dependency_error 1
    display as error "Missing required user-written command: esttab"
    display as error "Install manually in Stata before running maintained table modules: ssc install estout"
}
else {
    display as result "Found user-written command: esttab"
}

capture which eststo
if _rc {
    local dependency_error 1
    display as error "Missing required user-written command: eststo"
    display as error "Install manually in Stata before running maintained table modules: ssc install estout"
}
else {
    display as result "Found user-written command: eststo"
}

capture which ivregress
if _rc {
    local dependency_error 1
    display as error "Missing required built-in Stata capability: ivregress"
    display as error "Use a Stata version that provides the built-in ivregress command."
}
else {
    display as result "Found built-in Stata capability: ivregress"
}

capture which ivregress2
if _rc {
    local dependency_error 1
    display as error "Missing required user-written command: ivregress2"
    display as error "Install manually in Stata before running h2, h3, or h4 IV interaction modules: ssc install ivregress2"
}
else {
    display as result "Found user-written command: ivregress2"
}

capture which ivreg2
if _rc {
    local dependency_error 1
    display as error "Missing required user-written command: ivreg2"
    display as error "Install manually in Stata before running paper-facts IV checks: ssc install ivreg2"
}
else {
    display as result "Found user-written command: ivreg2"
}

capture which ranktest
if _rc {
    local dependency_error 1
    display as error "Missing required user-written command: ranktest"
    display as error "Install manually in Stata before running ivreg2-based modules: ssc install ranktest"
}
else {
    display as result "Found user-written command: ranktest"
}

local current_scheme "`c(scheme)'"
capture set scheme plottig
if _rc {
    local dependency_error 1
    display as error "Missing required graph scheme: plottig"
    display as error "Install manually in Stata before running the takeup-by-WTP figure module: ssc install blindschemes"
}
else {
    display as result "Found graph scheme: plottig"
    capture set scheme `current_scheme'
}

if `dependency_error' {
    display as error "Stata dependency check failed."
    display as error "Review all missing commands and schemes reported above."
    display as error `"Open this setup do-file in Stata and click Run: $repo_root/code/setup/install_stata_dependencies.do"'
    display as error "Then reopen code/replication/run_replication.do and click Run."
    exit 111
}

display as result "Stata dependency check completed."
