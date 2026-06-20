*** Purpose: Reproduce endline assets and shocks final tables.

version 16
set more off

foreach required_file in ///
    `"$merged/key_rep.dta"' ///
    `"$bsvy_processed/hhvars_baseline.dta"' ///
    `"$esvy_clean/3A_assets_hh.dta"' ///
    `"$esvy_clean/6_bsl.dta"' ///
    `"$esvy_processed/7_wellbeing_hh.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for g5_endline_analysis: `required_file'"
        exit 601
    }
}

display as text "Writing maintained table outputs under: $tables"

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
    keepusing(buy_assets_val99p sell_assets_val99p)
keep if _merge == 3 | _merge == 1
drop _merge

merge 1:1 hhid using "$esvy_clean/6_bsl.dta", ///
    keepusing(amt_forminform_win net_assets_loans_a)
keep if _merge == 3 | _merge == 1
drop _merge

merge 1:1 hhid using "$esvy_processed/7_wellbeing_hh.dta", ///
    keepusing(shockAindex scaleAindex shockBindex scaleBindex)
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

replace value_hh_assets = value_hh_assets / 3704
replace total_loans_bl = total_loans_bl / 3704

generate assets_val_end = value_hh_assets + buy_assets_val99p - sell_assets_val99p
generate total_loans_end_r = total_loans_bl + amt_forminform_win
generate av_tl_end_r = assets_val_end - total_loans_end_r

generate assets_sample2_r = 1 if ///
    assets_val_end != . ///
    & total_loans_end_r != . ///
    & av_tl_end_r != . ///
    & amt_forminform_win != .

generate assets_sample_full = 1 if assets_sample2_r == 1

sum buy_assets_val99p if ///
    anytreat_assigned != . ///
    & assets_sample_full == 1 ///
    & anytreat_assigned == 0
sum sell_assets_val99p if ///
    anytreat_assigned != . ///
    & assets_sample_full == 1 ///
    & anytreat_assigned == 0
sum amt_forminform_win if ///
    anytreat_assigned != . ///
    & assets_sample_full == 1 ///
    & anytreat_assigned == 0
sum net_assets_loans_a if ///
    anytreat_assigned != . ///
    & assets_sample_full == 1 ///
    & anytreat_assigned == 0

regress buy_assets_val99p locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

regress sell_assets_val99p locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

regress amt_forminform_win locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

regress net_assets_loans_a locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

eststo clear

eststo: regress buy_assets_val99p anytreat_assigned if assets_sample_full == 1
eststo: regress buy_assets_val99p locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

eststo: regress sell_assets_val99p anytreat_assigned if assets_sample_full == 1
eststo: regress sell_assets_val99p locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

eststo: regress amt_forminform_win anytreat_assigned if assets_sample_full == 1
eststo: regress amt_forminform_win locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

eststo: regress net_assets_loans_a anytreat_assigned if assets_sample_full == 1
eststo: regress net_assets_loans_a locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

esttab using "$tables/assets99_lvl_ITT_v2.tex", ///
    b(0) se(0) se replace booktabs star(* .10 ** .05 *** .01) title(Effect on Asset Purchases, Sales, Money, and Money Borrowed in the Last 6 months\label{assets99_lvl_ITT_v2}) ///
    label nodepvars mtitles("Asset purchases" "Asset purchases" "Asset sales" "Asset sales" "Money borrowed" "Money borrowed" "Net difference" "Net difference") nonotes ///
    varlabels(anytreat_assigned "Pooled" locked_assigned "Secured" surprise_assigned "Surprise Unsecured" unlocked_assigned "Unsecured" _cons "Constant", ///
    elist(anytreat_assigned \addlinespace locked_assigned \addlinespace surprise_assigned \addlinespace unlocked_assigned \addlinespace))

eststo clear

regress amt_forminform_win anytreat_assigned if assets_sample_full == 1
display 40 / 81

sum assets_val_end if anytreat_assigned == 0 & assets_sample_full == 1
sum total_loans_end_r if anytreat_assigned == 0 & assets_sample_full == 1
sum av_tl_end_r if anytreat_assigned == 0 & assets_sample_full == 1

regress assets_val_end locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

regress total_loans_end_r locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

regress av_tl_end_r locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1
test locked_assigned = unlocked_assigned

eststo: regress assets_val_end anytreat_assigned if assets_sample_full == 1
eststo: regress assets_val_end locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

eststo: regress total_loans_end_r anytreat_assigned if assets_sample_full == 1
eststo: regress total_loans_end_r locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

eststo: regress av_tl_end_r anytreat_assigned if assets_sample_full == 1
eststo: regress av_tl_end_r locked_assigned surprise_assigned unlocked_assigned if assets_sample_full == 1

esttab using "$tables/assetsbal99_lvl_ITT_v2.tex", ///
    b(0) se(0) se replace booktabs star(* .10 ** .05 *** .01) title(Effect on Household Balance Sheet\label{assetsbal99_lvl_ITT_v2}) ///
    label nodepvars mtitles("Asset value" "Asset value" "Debt" "Debt" "Net difference" "Net difference") nonotes ///
    varlabels(anytreat_assigned "Pooled" locked_assigned "Secured" surprise_assigned "Surprise Unsecured" unlocked_assigned "Unsecured" _cons "Constant", ///
    elist(anytreat_assigned \addlinespace locked_assigned \addlinespace surprise_assigned \addlinespace unlocked_assigned \addlinespace))

eststo clear

sum shockAindex if anytreat_assigned == 0
sum scaleAindex if anytreat_assigned == 0

eststo: regress shockAindex anytreat_assigned
eststo: regress shockAindex locked_assigned surprise_assigned unlocked_assigned

eststo: regress scaleAindex anytreat_assigned
eststo: regress scaleAindex locked_assigned surprise_assigned unlocked_assigned

esttab using "$tables/shock_A.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Liquidity Shocks over the Past 6 Months\label{shock_A}) ///
    label nodepvars mtitles("Proportion shocks experienced" "Proportion shocks experienced" "Are you worried about coping with this shock?" "Are you worried about coping with this shock?") nonotes ///
    varlabels(anytreat_assigned "Pooled" locked_assigned "Secured" surprise_assigned "Surprise Unsecured" unlocked_assigned "Unsecured" _cons "Constant", ///
    elist(anytreat_assigned \addlinespace locked_assigned \addlinespace surprise_assigned \addlinespace unlocked_assigned \addlinespace))

eststo clear

sum shockBindex if anytreat_assigned == 0
sum scaleBindex if anytreat_assigned == 0

eststo: regress shockBindex anytreat_assigned
eststo: regress shockBindex locked_assigned surprise_assigned unlocked_assigned

eststo: regress scaleBindex anytreat_assigned
eststo: regress scaleBindex locked_assigned surprise_assigned unlocked_assigned

esttab using "$tables/shock_B.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Liquidity Shocks over the Past 6 Months\label{shock_B}) ///
    label nodepvars mtitles("Proportion shocks experienced" "Proportion shocks experienced" "Are you worried about coping with this shock?" "Are you worried about coping with this shock?") nonotes ///
    varlabels(anytreat_assigned "Pooled" locked_assigned "Secured" surprise_assigned "Surprise Unsecured" unlocked_assigned "Unsecured" _cons "Constant", ///
    elist(anytreat_assigned \addlinespace locked_assigned \addlinespace surprise_assigned \addlinespace unlocked_assigned \addlinespace))

eststo clear
