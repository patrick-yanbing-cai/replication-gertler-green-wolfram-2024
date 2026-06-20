*** Purpose: Reproduce endline household education final table.

version 16
set more off

foreach required_file in ///
    `"$esvy_clean/2_educ_indiv.dta"' ///
    `"$merged/key_rep.dta"' ///
    `"$esvy_clean/2_educ_hh.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required staged input for g4_endline_educ_hh: `required_file'"
        exit 601
    }
}

display as text "Writing maintained table output under: $tables"

clear
clear matrix
clear mata
set maxvar 10000

tempfile num_520e_info mei_std_h1

use "$esvy_clean/2_educ_indiv.dta", clear
generate num_520e = 1
collapse (sum) num_520e, by(hhid)
save `num_520e_info'

use "$merged/key_rep.dta", clear
keep if hhid != .

keep if k_complete_may == 1 ///
    & k_rolling_list == 1 ///
    & k_interacted_success == 1 ///
    & k_surveyed == 1 ///
    & k_surveyed_end == 1

merge 1:1 hhid using "$esvy_clean/2_educ_hh.dta"
keep if _merge == 3 | _merge == 1
drop _merge

replace schoolexpend_t2_fin = schoolexpend_t2_fin / 3704
generate ln_schoolexpend_t2_fin = ln(schoolexpend_t2_fin + 1)

drop if treatmenttype_sh == "R T3"

generate anytreat_assigned = ///
    (treatmenttype_sh == "R T1-L" ///
    | treatmenttype_sh == "R T1-U" ///
    | treatmenttype_sh == "R T2-U")
generate locked_assigned = (treatmenttype_sh == "R T1-L")
generate surprise_assigned = (treatmenttype_sh == "R T1-U")
generate unlocked_assigned = (treatmenttype_sh == "R T2-U")

merge 1:1 hhid using `num_520e_info', keepusing(num_520e)
keep if _merge == 3 | _merge == 1
drop _merge

replace missed_month_t2_fin = 30 if ///
    anytreat_assigned != . ///
    & missed_month_t2_fin == . ///
    & enroll_t2_fin != .
replace schoolexpend_t2_fin = 0 if ///
    anytreat_assigned != . ///
    & ln_schoolexpend_t2_fin == . ///
    & enroll_t2_fin != .
replace ln_schoolexpend_t2_fin = 0 if ///
    anytreat_assigned != . ///
    & ln_schoolexpend_t2_fin == . ///
    & enroll_t2_fin != .

generate missed_month_t2_fin2 = -missed_month_t2_fin

local p_me_corevars_1 "enroll_t2_fin missed_month_t2_fin2 ln_schoolexpend_t2_fin"

keep if enroll_t2_fin != .

foreach num of numlist 1 {
    local i = `num'
    local l = 0
    local matrix_string_`i' ""

    foreach var of varlist `p_me_corevars_`i'' {
        local l = `l' + 1
        quietly summarize `var' if anytreat_assigned == 0
        quietly generate `var'_mean = r(mean)
        quietly generate `var'_sd = r(sd)
        quietly generate std_`i'_`l' = (`var' - `var'_mean) / `var'_sd
        quietly egen mean_std_`i'_`l'_t = mean(std_`i'_`l') if anytreat_assigned == 1
        quietly replace std_`i'_`l' = mean_std_`i'_`l'_t if ///
            anytreat_assigned == 1 & std_`i'_`l' == .
        quietly replace std_`i'_`l' = 0 if anytreat_assigned == 0 & std_`i'_`l' == .
        local matrix_string_`i' "`matrix_string_`i'' std_`i'_`l'"
    }

    local k = `l'
    save `mei_std_h1', replace

    drop if anytreat_assigned == 1

    forvalues x = 1/`k' {
        generate weight`x'_`i' = 0
    }

    matrix accum R = `matrix_string_`i'', nocons dev
    matrix R = R / r(N)
    matrix R = invsym(R)
    local counter1 = 1
    matrix J = J(colsof(R), 1, 1)
    while `counter1' <= colsof(R) {
        matrix T = R[`counter1', 1..colsof(R)]
        matrix A = T * J
        quietly replace weight`counter1'_`i' = A[1,1]
        quietly replace weight`counter1'_`i' = 0 if weight`counter1'_`i' < 0
        local counter1 = `counter1' + 1
    }

    generate sample_h`i' = 0
    forvalues x = 1/`k' {
        quietly replace sample_h`i' = sample_h`i' + weight`x'_`i'
    }
    keep sample_h`i' weight*
    collapse _all

    cross using `mei_std_h1'

    quietly generate outcome_h`i' = 0
    forvalues x = 1/`k' {
        quietly replace outcome_h`i' = std_`i'_`x' * weight`x'_`i' + outcome_h`i'
    }
    quietly replace outcome_h`i' = outcome_h`i' / sample_h`i'
    drop *_mean *_sd mean_std_*
}

generate atreatnum_520e = anytreat_assigned * num_520e

eststo clear

eststo: regress enroll_t2_fin anytreat_assigned atreatnum_520e num_520e
eststo: regress enroll_t2_fin locked_assigned surprise_assigned unlocked_assigned atreatnum_520e num_520e

eststo: regress missed_month_t2_fin anytreat_assigned atreatnum_520e num_520e
eststo: regress missed_month_t2_fin locked_assigned surprise_assigned unlocked_assigned atreatnum_520e num_520e

eststo: regress ln_schoolexpend_t2_fin anytreat_assigned atreatnum_520e num_520e
eststo: regress ln_schoolexpend_t2_fin locked_assigned surprise_assigned unlocked_assigned atreatnum_520e num_520e

eststo: regress outcome_h1 anytreat_assigned atreatnum_520e num_520e
eststo: regress outcome_h1 locked_assigned surprise_assigned unlocked_assigned atreatnum_520e num_520e

esttab using "$tables/endline_educ_hh.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Education Outcomes, Household-level\label{endline_educ_hh}) ///
    label nodepvars mtitles("Enrollment" "Enrollment" "Days absent" "Days absent" "Log school expenditures" "Log school expenditures" "Education index" "Education index") nonotes ///
    order(anytreat_assigned locked_assigned surprise_assigned unlocked_assigned atreatnum_520e num_520e _cons) ///
    varlabels(anytreat_assigned "Pooled" locked_assigned "Secured" surprise_assigned "Surprise Unsecured" unlocked_assigned "Unsecured" _cons "Constant" num_520e "N SAC at endline" atreatnum_520e "Pooled $\times$ Number of School-Aged Children", ///
    elist(anytreat_assigned \addlinespace locked_assigned \addlinespace surprise_assigned \addlinespace unlocked_assigned \addlinespace atreatnum_520e \addlinespace num_520e \addlinespace))

eststo clear
