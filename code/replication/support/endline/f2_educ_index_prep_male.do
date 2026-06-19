********************************************************************************
** Do file: f2_educ_index_prep_male.do
** First started: February 19, 2023
** Last edited: September 8, 2023

/* Purpose: this do file develops the education index at the individual level for females

(Modified) code to create indices comes from Casey et al. (2012)

Part I: Development
*/

********************************************************************************

clear
clear matrix
clear mata
set maxvar 10000

** Preamble - data management for both the individual level dataset and household level dataset **

** Individual **

* Load key data first
use "$merged/key_rep.dta", clear
keep if hhid!=.

* Reduce down to strict sample - sampling framework variant
keep if k_complete_may==1 & k_rolling_list==1 & k_interacted_success==1 & k_surveyed==1 & k_surveyed_end==1

* Bring in individual level information on education
merge 1:m hhid using "$esvy_clean/2_educ_indiv.dta"
keep if _merge==3 | _merge==1
drop _merge

/* Change school expenditures value to USD (2019) https://data.worldbank.org/indicator/PA.NUS.FCRF?locations=UG */
replace schoolexpend_t2_fin = schoolexpend_t2_fin/3704

* 1) Take log
g ln_schoolexpend_t2_fin=ln(schoolexpend_t2_fin+1)
g ln_schoolexpend_t2_fin_x=ln(schoolexpend_t2_fin)
* 2) Take IHST transformation
g i_schoolexpend_t2_fin = asinh(schoolexpend_t2_fin)

* Drop the choice group as well
drop if treatmenttype_sh=="R T3"

* Generate treatment variables, as well as whether loan was taken
g anytreat_actual = (k_tookloan_repay==1)
g locked_actual = (k_tookloan_repay==1 & treatmenttype_sh=="R T1-L")
g surprise_actual = (k_tookloan_repay==1 & treatmenttype_sh=="R T1-U")
g unlocked_actual = (k_tookloan_repay==1 & treatmenttype_sh=="R T2-U")

g locked_assigned = (treatmenttype_sh=="R T1-L")
g surprise_assigned = (treatmenttype_sh=="R T1-U")
g unlocked_assigned = (treatmenttype_sh=="R T2-U")
g anytreat_assigned = (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U")

* Temporarily save data
tempfile indiv
save `indiv'


************
** Part I **
************

use `indiv', clear

* Consistency
replace missed_month_t2_fin = . if ln_schoolexpend_t2_fin==.

g male_d = (fem_fin==0)
g female_d = (fem_fin==1)
g male_at = male_d*anytreat_assigned
g female_at = female_d*anytreat_assigned

* Input zeroes if missing for days absent, zeroes anything else
count if missed_month_t2_fin==. & anytreat_assigned!=. & enroll_t2_fin!=. // 545
count if ln_schoolexpend_t2_fin==. & anytreat_assigned!=. & enroll_t2_fin!=. // 545
replace missed_month_t2_fin=30 if anytreat_assigned!=. & enroll_t2_fin!=. & missed_month_t2_fin==.
replace schoolexpend_t2_fin=0 if anytreat_assigned!=. & enroll_t2_fin!=. & ln_schoolexpend_t2_fin==.
replace ln_schoolexpend_t2_fin=0 if anytreat_assigned!=. & enroll_t2_fin!=. & ln_schoolexpend_t2_fin==.

* For index, need to run separately for males and for females
g missed_month_t2_fin2 = -missed_month_t2_fin

local p_me_corevars_1 "enroll_t2_fin missed_month_t2_fin2 ln_schoolexpend_t2_fin"

keep if fem_fin==0

foreach num of numlist 1 {
local i = `num'
	* 1. Convert outcomes to effect sizes
	foreach var of varlist  `p_me_corevars_`i'' {
		local l = `l' + 1
		qui sum `var' if anytreat_assigned==0
		qui gen `var'_mean=r(mean)
		qui gen `var'_sd=r(sd)
		qui gen std_`i'_`l'=(`var'-`var'_mean)/`var'_sd
		qui egen mean_std_`i'_`l'_t=mean( std_`i'_`l') if anytreat_assigned==1
		qui replace std_`i'_`l'=mean_std_`i'_`l'_t if anytreat_assigned==1 & std_`i'_`l'==.
		qui replace std_`i'_`l'=0 if anytreat_assigned==0 & std_`i'_`l'==.
		local matrix_string_`i'="`matrix_string_`i''" + " std_`i'_`l'"
		}
		local k = `l'
		tempfile mei_std_h
		save `mei_std_h', replace

	* 2. Construct matrix and component weights using controls only;
	drop if anytreat_assigned==1

		forvalues x = 1/`k' {
			gen weight`x'_`i'=0
			}

		matrix accum R = `matrix_string_`i'', nocons dev
		matrix R=R/r(N)
		matrix R=invsym(R)
		local counter1=1
		matrix J = J(colsof(R), 1, 1)
		while `counter1'<=colsof(R){
			matrix T = R[`counter1', 1..colsof(R)]
			matrix A = T*J
			qui replace weight`counter1'_`i'=A[1,1]
			qui replace weight`counter1'_`i'=0 if weight`counter1'_`i'<0
			local counter1 = `counter1'+1
			}

		gen sample_h`i'=0
		forvalues x = 1/`k' {
			qui replace sample_h`i'=sample_h`i'+weight`x'_`i'
			}
		keep sample_h`i' weight*
		collapse _all

		cross using `mei_std_h'

	* 3. Apply weights and construct index;
		qui gen outcome_h`i'=0
			forvalues x = 1/`k' {
			qui replace outcome_h`i'=std_`i'_`x'*(weight`x'_`i') + outcome_h`i'
			}
			qui replace outcome_h`i'=outcome_h`i'/sample_h`i'
		local l = 0
		drop *_mean *_sd mean_std_*
}

save "$esvy_processed/maleeduc.dta", replace
