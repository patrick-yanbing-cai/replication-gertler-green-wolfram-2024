*** Purpose: Reproduce endline money-borrowed final table.

version 16
set more off

foreach required_file in ///
    `"$merged/key_rep.dta"' ///
    `"$bsvy_processed/hhvars_baseline.dta"' ///
    `"$esvy_clean/3A_assets_hh.dta"' ///
    `"$esvy_clean/6_bsl.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for g13_endline_moneyborrowed: `required_file'"
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

merge 1:1 hhid using "$bsvy_processed/hhvars_baseline.dta", ///
    keepusing(value_hh_assets total_loans)
keep if _merge == 3 | _merge == 1
drop _merge

rename total_loans total_loans_bl

merge 1:1 hhid using "$esvy_clean/3A_assets_hh.dta", ///
    keepusing(buy_assets_val99p sell_assets_val99p net_assets_val99p)
keep if _merge == 3 | _merge == 1
drop _merge

merge 1:1 hhid using "$esvy_clean/6_bsl.dta", ///
    keepusing(total_loans_r amt_formal_win amt_informal_win amt_forminform_win diff_fi_win)
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

generate assets_sample_r = 1 if net_assets_val99p != .

generate assets_val_end = value_hh_assets + buy_assets_val99p - sell_assets_val99p
generate total_loans_end_r = total_loans_bl + total_loans_r
generate av_tl_end_r = assets_val_end - total_loans_end_r

generate assets_sample2_r = 1 if ///
    assets_val_end != . ///
    & total_loans_end_r != . ///
    & av_tl_end_r != .

generate assets_sample_full = 1 if assets_sample_r == 1 & assets_sample2_r == 1

replace assets_sample_full = . if amt_forminform_win == .

summarize amt_formal_win if ///
    anytreat_assigned != . ///
    & assets_sample_full == 1 ///
    & anytreat_assigned == 0
summarize amt_informal_win if ///
    anytreat_assigned != . ///
    & assets_sample_full == 1 ///
    & anytreat_assigned == 0
summarize amt_forminform_win if ///
    anytreat_assigned != . ///
    & assets_sample_full == 1 ///
    & anytreat_assigned == 0
summarize diff_fi_win if ///
    anytreat_assigned != . ///
    & assets_sample_full == 1 ///
    & anytreat_assigned == 0

regress amt_formal_win locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

regress amt_informal_win locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

regress amt_forminform_win locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

regress diff_fi_win locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

eststo clear
eststo: regress amt_formal_win anytreat_assigned if assets_sample_full == 1
eststo: regress amt_formal_win locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

eststo: regress amt_informal_win anytreat_assigned if assets_sample_full == 1
eststo: regress amt_informal_win locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

eststo: regress amt_forminform_win anytreat_assigned if assets_sample_full == 1
eststo: regress amt_forminform_win locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

eststo: regress diff_fi_win anytreat_assigned if assets_sample_full == 1
eststo: regress diff_fi_win locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

esttab using "$tables/endline_moneyborrowed.tex", ///
    b(0) se(0) se replace booktabs star(* .10 ** .05 *** .01) title(Effect on Formal, Informal, and Total Money Borrowed in the Last 6 Months\label{endline_moneyborrowed}) ///
    label nodepvars mtitles("Formal money borrowed" "Formal money borrowed" "Informal money borrowed" "Informal money borrowed" "Money borrowed" "Money borrowed" "Formal minus informal" "Formal minus informal") nonotes ///
    varlabels(anytreat_assigned "Pooled" locked_assigned "Secured" surprise_assigned "Surprise Unsecured" unlocked_assigned "Unsecured" _cons "Constant", ///
    elist(anytreat_assigned \addlinespace locked_assigned \addlinespace surprise_assigned \addlinespace unlocked_assigned \addlinespace))

eststo clear
