*** Purpose: Reproduce take-up by WTP final figure.

version 16
set more off

foreach required_file in ///
    `"$merged/key_rep.dta"' ///
    `"$bsvy_processed/hhvars_baseline.dta"' ///
    `"$esvy_processed/9_lockedoccurences_hh.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for rl2_takeupbywtp: `required_file'"
        exit 601
    }
}

if "$figures" == "" {
    display as error "figures global is not defined. Run code/replication/00_header.do before final outputs."
    exit 198
}

local current_scheme "`c(scheme)'"
capture set scheme plottig
if _rc {
    display as error "Missing required graph scheme for rl2_takeupbywtp: plottig"
    display as error "Install manually in Stata before running the takeup-by-WTP figure module: ssc install blindschemes"
    exit 111
}

display as text "Writing maintained figure outputs under: $figures"

clear
clear matrix
clear mata
set maxvar 10000

use "$merged/key_rep.dta", clear

generate takeup_end = .
replace takeup_end = 0 if ///
    k_complete_may == 1 ///
    & k_rolling_list == 1 ///
    & k_interacted_success == 1 ///
    & k_surveyed == 1 ///
    & k_surveyed_end == 1
replace takeup_end = 1 if ///
    k_complete_may == 1 ///
    & k_rolling_list == 1 ///
    & k_interacted_success == 1 ///
    & k_tookloan_repay == 1 ///
    & k_surveyed == 1 ///
    & k_surveyed_end == 1

keep if treatmenttype_sh == "R T1-L" ///
    | treatmenttype_sh == "R T1-U" ///
    | treatmenttype_sh == "R T2-U"

merge 1:1 hhid using "$bsvy_processed/hhvars_baseline.dta"
drop if _merge == 2
drop _merge

merge 1:1 hhid using "$esvy_processed/9_lockedoccurences_hh.dta"
drop if _merge == 2
drop _merge

keep if treatmenttype_sh == "R T1-L" | treatmenttype_sh == "R T2-U"
keep if takeup_end != .

generate wtpday_group = .
replace wtpday_group = 100 if wtpday == 0 | wtpday == 1000
replace wtpday_group = 200 if wtpday == 2000 | wtpday == 3000
replace wtpday_group = 300 if wtpday == 4000 | wtpday == 5000

generate wtpday_scaled = wtpday_group / 100 * 4 + 2

preserve
count if wtpday != .
local size = r(N)

count if wtpday_group == 100
local size_100 = r(N)
summarize takeup_end if treatmenttype_sh == "R T1-L" & wtpday_group == 100
local mean_T1L_100 = r(mean)
summarize takeup_end if treatmenttype_sh == "R T2-U" & wtpday_group == 100
local mean_T2U_100 = r(mean)
local diff_100 = `mean_T1L_100' - `mean_T2U_100'
ttest takeup_end if wtpday_group == 100, by(treatmenttype_sh)
local se_100 = r(se)
local hitakeup_100 = `diff_100' + invttail(`size_100' - 2, 0.025) * `se_100'
local lotakeup_100 = `diff_100' - invttail(`size_100' - 2, 0.025) * `se_100'

count if wtpday_group == 200
local size_200 = r(N)
summarize takeup_end if treatmenttype_sh == "R T1-L" & wtpday_group == 200
local mean_T1L_200 = r(mean)
summarize takeup_end if treatmenttype_sh == "R T2-U" & wtpday_group == 200
local mean_T2U_200 = r(mean)
local diff_200 = `mean_T1L_200' - `mean_T2U_200'
ttest takeup_end if wtpday_group == 200, by(treatmenttype_sh)
local se_200 = r(se)
local hitakeup_200 = `diff_200' + invttail(`size_200' - 2, 0.025) * `se_200'
local lotakeup_200 = `diff_200' - invttail(`size_200' - 2, 0.025) * `se_200'

count if wtpday_group == 300
local size_300 = r(N)
summarize takeup_end if treatmenttype_sh == "R T1-L" & wtpday_group == 300
local mean_T1L_300 = r(mean)
summarize takeup_end if treatmenttype_sh == "R T2-U" & wtpday_group == 300
local mean_T2U_300 = r(mean)
local diff_300 = `mean_T1L_300' - `mean_T2U_300'
display `mean_T1L_300'
display `mean_T2U_300'
display `diff_300'
ttest takeup_end if wtpday_group == 300, by(treatmenttype_sh)
local se_300 = r(se)
local hitakeup_300 = `diff_300' + invttail(`size_300' - 2, 0.025) * `se_300'
local lotakeup_300 = `diff_300' - invttail(`size_300' - 2, 0.025) * `se_300'
display `size_200'

clear
set obs 3
generate takeup = .
replace takeup = `diff_100' if _n == 1
replace takeup = `diff_200' if _n == 2
replace takeup = `diff_300' if _n == 3
generate wtpday_scaled = .
replace wtpday_scaled = 6 if _n == 1
replace wtpday_scaled = 10 if _n == 2
replace wtpday_scaled = 14 if _n == 3
generate hitakeup = .
replace hitakeup = `hitakeup_100' if _n == 1
replace hitakeup = `hitakeup_200' if _n == 2
replace hitakeup = `hitakeup_300' if _n == 3
generate lotakeup = .
replace lotakeup = `lotakeup_100' if _n == 1
replace lotakeup = `lotakeup_200' if _n == 2
replace lotakeup = `lotakeup_300' if _n == 3

graph twoway ///
    (bar takeup wtpday_scaled, color(blue)) ///
    (rcap hitakeup lotakeup wtpday_scaled), ///
    by() ///
    xlabel(6 "0 - 1" 10 "2 - 3" 14 "4 - 5") ///
    xtitle("WTP to unlock next day (UGX, thousands)", size(smedium)) ///
    ytitle("Difference in Loan Take-up" "Secured over Unsecured", size(smedium)) ///
    legend(off,) ///
    xsize(10) ///
    ysize(10) ///
    note("N = `size'", size(smedium) pos(6))
graph export "$figures/takeupbywtp_dif.png", replace

capture set scheme `current_scheme'

restore
