*** Purpose: Reproduce SAC regression final table.

version 16
set more off

foreach required_file in ///
    `"$esvy_clean/2_educ_indiv.dta"' ///
    `"$merged/key_rep.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for g10_sac_regression: `required_file'"
        exit 601
    }
}

display as text "Writing maintained table output under: $tables"

clear
clear matrix
clear mata
set maxvar 10000

tempfile num_520e_info

use "$esvy_clean/2_educ_indiv.dta", clear
generate num_520e = 1
collapse (sum) num_520e, by(hhid)
save `num_520e_info'

use "$merged/key_rep.dta", clear

keep if k_complete_may == 1 ///
    & k_rolling_list == 1 ///
    & k_interacted_success == 1 ///
    & k_surveyed == 1 ///
    & k_surveyed_end == 1

merge 1:1 hhid using `num_520e_info', keepusing(num_520e)
replace num_520e = 0 if num_520e == .
keep if _merge == 3 | _merge == 1
drop _merge

drop if treatmenttype_sh == "R T3"

generate yesSACe = (num_520e > 0)

generate anytreat = !(treatmenttype_sh == "R C")
generate secured = (treatmenttype_sh == "R T1-L")
generate surprise = (treatmenttype_sh == "R T1-U")
generate unsecured = (treatmenttype_sh == "R T2-U")

summarize yesSACe if anytreat == 0

regress yesSACe secured surprise unsecured
test secured = surprise = unsecured
test secured = unsecured

eststo clear

eststo: regress yesSACe anytreat
eststo: regress yesSACe secured surprise unsecured

esttab using "$tables/sacreg.tex", ///
    b(3) se(3) se replace booktabs star(* .10 ** .05 *** .01) title(Probability of Having Any School-Aged Children On Treatment Assignment\label{sacreg}) ///
    label nodepvars mtitles("Any SAC" "Any SAC") nonotes ///
    varlabels(anytreat_assigned "Pooled" _cons "Constant" locked_assigned "Secured" surprise_assigned "Surprise Unsecured" unlocked_assigned "Unsecured", ///
    elist(anytreat_assigned \addlinespace locked_assigned \addlinespace surprise_assigned \addlinespace unlocked_assigned \addlinespace))

eststo clear
