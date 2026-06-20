*** Purpose: Reproduce endline adult-income final table.

version 16
set more off

foreach required_file in ///
    `"$merged/key_rep.dta"' ///
    `"$esvy_clean/adult_labor_supply_hh.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for g14_endline_income: `required_file'"
        exit 601
    }
}

display as text "Writing maintained table output under: $tables"

clear
clear matrix
clear mata
set maxvar 10000

use "$merged/key_rep.dta", clear
keep if hhid != .

keep if k_complete_may == 1 ///
    & k_rolling_list == 1 ///
    & k_interacted_success == 1 ///
    & k_surveyed == 1 ///
    & k_surveyed_end == 1

merge 1:1 hhid using "$esvy_clean/adult_labor_supply_hh.dta", ///
    keepusing(e_adt_lb_inct)
keep if _merge == 3 | _merge == 1
drop _merge

drop if treatmenttype_sh == "R T3"

generate anytreat_assigned = ///
    (treatmenttype_sh == "R T1-L" ///
    | treatmenttype_sh == "R T1-U" ///
    | treatmenttype_sh == "R T2-U")
generate locked_assigned = (treatmenttype_sh == "R T1-L")
generate surprise_assigned = (treatmenttype_sh == "R T1-U")
generate unlocked_assigned = (treatmenttype_sh == "R T2-U")

replace e_adt_lb_inct = e_adt_lb_inct / 3704

summarize e_adt_lb_inct if anytreat_assigned != . & anytreat_assigned == 0

regress e_adt_lb_inct locked_assigned surprise_assigned unlocked_assigned
test locked_assigned = unlocked_assigned

eststo clear

eststo: regress e_adt_lb_inct anytreat_assigned
eststo: regress e_adt_lb_inct locked_assigned surprise_assigned unlocked_assigned

esttab using "$tables/income99_lvl_ITT.tex", ///
    b(0) se(0) se replace booktabs star(* .10 ** .05 *** .01) title(Total Household Adult Income\label{income99_lvl_ITT}) ///
    label nodepvars mtitles("Total household adult income" "Total household adult income") nonotes ///
    varlabels(anytreat_assigned "Pooled" locked_assigned "Secured" surprise_assigned "Surprise Unsecured" unlocked_assigned "Unsecured" _cons "Constant", ///
    elist(anytreat_assigned \addlinespace locked_assigned \addlinespace surprise_assigned \addlinespace unlocked_assigned \addlinespace))

eststo clear
