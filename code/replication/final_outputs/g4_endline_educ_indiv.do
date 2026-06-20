*** Purpose: Reproduce endline individual education final table.

version 16
set more off

foreach required_file in ///
    `"$merged/key_rep.dta"' ///
    `"$esvy_clean/2_educ_indiv.dta"' ///
    `"$esvy_processed/maleeduc.dta"' ///
    `"$esvy_processed/femaleeduc.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for g4_endline_educ_indiv: `required_file'"
        exit 601
    }
}

display as text "Writing maintained table output under: $tables"

clear
clear matrix
clear mata
set maxvar 10000

tempfile indiv

use "$merged/key_rep.dta", clear
keep if hhid != .

keep if k_complete_may == 1 ///
    & k_rolling_list == 1 ///
    & k_interacted_success == 1 ///
    & k_surveyed == 1 ///
    & k_surveyed_end == 1

merge 1:m hhid using "$esvy_clean/2_educ_indiv.dta"
keep if _merge == 3 | _merge == 1
drop _merge

replace schoolexpend_t2_fin = schoolexpend_t2_fin / 3704
generate ln_schoolexpend_t2_fin = ln(schoolexpend_t2_fin + 1)

drop if treatmenttype_sh == "R T3"

generate locked_assigned = (treatmenttype_sh == "R T1-L")
generate surprise_assigned = (treatmenttype_sh == "R T1-U")
generate unlocked_assigned = (treatmenttype_sh == "R T2-U")
generate anytreat_assigned = ///
    (treatmenttype_sh == "R T1-L" ///
    | treatmenttype_sh == "R T1-U" ///
    | treatmenttype_sh == "R T2-U")

generate counter = 1
bysort hhid: egen num_520e = sum(counter)
drop counter

save `indiv'

use `indiv', clear

replace missed_month_t2_fin = . if ln_schoolexpend_t2_fin == .

generate male_d = (fem_fin == 0)
generate female_d = (fem_fin == 1)
generate male_at = male_d * anytreat_assigned
generate female_at = female_d * anytreat_assigned

generate atreatnum_520e = anytreat_assigned * num_520e

count if missed_month_t2_fin == . ///
    & anytreat_assigned != . ///
    & enroll_t2_fin != .
count if ln_schoolexpend_t2_fin == . ///
    & anytreat_assigned != . ///
    & enroll_t2_fin != .
replace missed_month_t2_fin = 30 if ///
    anytreat_assigned != . ///
    & enroll_t2_fin != . ///
    & missed_month_t2_fin == .
replace schoolexpend_t2_fin = 0 if ///
    anytreat_assigned != . ///
    & enroll_t2_fin != . ///
    & ln_schoolexpend_t2_fin == .
replace ln_schoolexpend_t2_fin = 0 if ///
    anytreat_assigned != . ///
    & enroll_t2_fin != . ///
    & ln_schoolexpend_t2_fin == .

merge 1:1 hhid person using "$esvy_processed/maleeduc.dta", keepusing(outcome_h1)
keep if _merge == 1 | _merge == 3
rename outcome_h1 outcome_h1_fin
drop _merge

merge 1:1 hhid person using "$esvy_processed/femaleeduc.dta", keepusing(outcome_h1)
keep if _merge == 1 | _merge == 3
replace outcome_h1_fin = outcome_h1 if outcome_h1_fin == .

summarize enroll_t2_fin if fem_fin == 0 & anytreat_assigned == 0
summarize enroll_t2_fin if fem_fin == 1 & anytreat_assigned == 0
summarize missed_month_t2_fin if fem_fin == 0 & anytreat_assigned == 0
summarize missed_month_t2_fin if fem_fin == 1 & anytreat_assigned == 0
summarize schoolexpend_t2_fin if fem_fin == 0 & anytreat_assigned == 0
summarize schoolexpend_t2_fin if fem_fin == 1 & anytreat_assigned == 0
summarize outcome_h1_fin if fem_fin == 0 & anytreat_assigned == 0
summarize outcome_h1_fin if fem_fin == 1 & anytreat_assigned == 0

regress ln_schoolexpend_t2_fin anytreat_assigned atreatnum_520e num_520e if fem_fin == 0, cluster(hhid)
nlcom exp(_b[anytreat_assigned] + 3 * _b[atreatnum_520e]) - 1

regress ln_schoolexpend_t2_fin anytreat_assigned atreatnum_520e num_520e if fem_fin == 1, cluster(hhid)
nlcom exp(_b[anytreat_assigned] + 3 * _b[atreatnum_520e]) - 1

eststo clear

eststo: regress enroll_t2_fin anytreat_assigned atreatnum_520e num_520e if fem_fin == 0, cluster(hhid)
eststo: regress enroll_t2_fin anytreat_assigned atreatnum_520e num_520e if fem_fin == 1, cluster(hhid)

eststo: regress missed_month_t2_fin anytreat_assigned atreatnum_520e num_520e if fem_fin == 0, cluster(hhid)
eststo: regress missed_month_t2_fin anytreat_assigned atreatnum_520e num_520e if fem_fin == 1, cluster(hhid)

eststo: regress ln_schoolexpend_t2_fin anytreat_assigned atreatnum_520e num_520e if fem_fin == 0, cluster(hhid)
eststo: regress ln_schoolexpend_t2_fin anytreat_assigned atreatnum_520e num_520e if fem_fin == 1, cluster(hhid)

eststo: regress outcome_h1_fin anytreat_assigned atreatnum_520e num_520e if fem_fin == 0, cluster(hhid)
eststo: regress outcome_h1_fin anytreat_assigned atreatnum_520e num_520e if fem_fin == 1, cluster(hhid)

esttab using "$tables/endline_educ_indiv.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Education Outcomes for School-Aged Children\label{endline_educ_indiv}) ///
    label noconstant nodepvars mtitles("Enrollment" "Enrollment" "Days absent" "Days absent" "Log school expenditures" "Log school expenditures" "Education index" "Education index") stats(N, labels("n")) nonotes ///
    varlabels(locked_assigned "Secured" surprise_assigned "Surprise Unsecured" unlocked_assigned "Unsecured" anytreat_assigned "Pooled" _cons "Constant" num_520e "N SAC at endline" atreatnum_520e "Pooled $\times$ Number of School-Aged Children", ///
    elist(anytreat_assigned \addlinespace locked_assigned \addlinespace surprise_assigned \addlinespace unlocked_assigned \addlinespace atreatnum_520e \addlinespace num_520e \addlinespace))
eststo clear

generate atreatnum_520e_m = atreatnum_520e * male_d
generate atreatnum_520e_f = atreatnum_520e * female_d
generate num_520e_m = num_520e * male_d
generate num_520e_f = num_520e * female_d

regress enroll_t2_fin male_d male_at female_d female_at atreatnum_520e_m atreatnum_520e_f num_520e_m num_520e_f if fem_fin != ., cluster(hhid) noconstant
test _b[male_at] = _b[female_at]

regress missed_month_t2_fin male_d male_at female_d female_at atreatnum_520e_m atreatnum_520e_f num_520e_m num_520e_f if fem_fin != ., cluster(hhid) noconstant
test _b[male_at] = _b[female_at]

regress ln_schoolexpend_t2_fin male_d male_at female_d female_at atreatnum_520e_m atreatnum_520e_f num_520e_m num_520e_f if fem_fin != ., cluster(hhid) noconstant
test _b[male_at] = _b[female_at]

regress outcome_h1_fin male_d male_at female_d female_at atreatnum_520e_m atreatnum_520e_f num_520e_m num_520e_f if fem_fin != ., cluster(hhid) noconstant
test _b[male_at] = _b[female_at]
