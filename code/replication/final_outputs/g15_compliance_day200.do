*** Purpose: Reproduce day-200 compliance final table.

version 16
set more off

foreach required_file in ///
    `"$merged/key_rep.dta"' ///
    `"$bsvy_processed/hhvars_baseline.dta"' ///
    `"$repay_clean/fenix_repay_extend_07172020_rep.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for g15_compliance_day200: `required_file'"
        exit 601
    }
}

display as text "Writing maintained table output under: $tables"

clear
clear matrix
clear mata
set maxvar 10000

use "$merged/key_rep.dta", clear

merge m:1 hhid using "$bsvy_processed/hhvars_baseline.dta"
assert _merge != 2
drop _merge

generate tag = 1 if ///
    k_complete_may == 1 ///
    & k_rolling_list == 1 ///
    & k_interacted_success == 1 ///
    & k_surveyed == 1 ///
    & k_tookloan_repay == 1

generate tag_nocont = 1 if ///
    k_complete_may == 1 ///
    & k_rolling_list == 1 ///
    & k_interacted_success == 1 ///
    & k_surveyed == 1 ///
    & k_tookloan_repay == 1 ///
    & treatmenttype_sh != "R C"

generate maintreat = 1 if ///
    treatmenttype_sh == "R T1-L" ///
    | treatmenttype_sh == "R T1-U" ///
    | treatmenttype_sh == "R T2-U"
generate locked = (treatmenttype_sh == "R T1-L")
generate su = (treatmenttype_sh == "R T1-U")
generate unlocked = (treatmenttype_sh == "R T2-U")
generate control = (treatmenttype_sh == "R C")

drop if treatmenttype_sh == "R T3"

foreach var of varlist light_spend_year hhincome_other value_hh_assets total_loans {
    replace `var' = `var' / 3704
}

foreach var of varlist accountpercentlocked_may headage headsex headmarried headworks_fam headworks_self headworks_out num_hh n_hhenrolled light_spend_year hhincome_other value_hh_assets any_loans total_loans ever_refused microfloan {
    generate II`var' = `var'
}

foreach var of varlist II* {
    generate `var'_dum = (`var' == .)
    egen `var'_mean = mean(`var') if tag == 1
    replace `var' = `var'_mean if `var' == .
    drop `var'_mean
}

preserve
    use "$repay_clean/fenix_repay_extend_07172020_rep.dta", clear
    keep if loandayselapsed == 200
    tempfile complierinfo
    save `complierinfo'
restore

merge 1:1 accountid using `complierinfo', keepusing(complier_share_wupg)
rename complier_share_wupg compliance
keep if _merge == 3 | _merge == 1

summarize compliance if tag_nocont == 1

eststo clear

eststo: regress compliance locked su if tag_nocont == 1
regress compliance locked unlocked su if tag_nocont == 1, noconstant
test locked == su == unlocked

tabstat compliance if tag_nocont == 1, by(treatmenttype_sh)

eststo: regress compliance ///
    IIaccountpercentlocked_may ///
    IIheadage ///
    IIheadsex ///
    IIheadmarried ///
    IIheadworks_fam ///
    IIheadworks_self ///
    IIheadworks_out ///
    IInum_hh ///
    IIn_hhenrolled ///
    IIlight_spend_year ///
    IIhhincome_other ///
    IIvalue_hh_assets ///
    IIany_loans ///
    IItotal_loans ///
    IIever_refused ///
    IImicrofloan ///
    if tag_nocont == 1

esttab using "$tables/compliance_tab.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Share of Days in Compliance at Day 200\label{compliance_tab}) ///
    label nodepvars mtitles("Compliance" "Compliance") stats(N, fmt(%9.0f)) nonotes ///
    order(locked su) ///
    varlabels(locked "Secured" su "Surprise Unlocked" _cons "Constant", ///
    elist(locked \addlinespace su \addlinespace _cons \addlinespace))

eststo clear
