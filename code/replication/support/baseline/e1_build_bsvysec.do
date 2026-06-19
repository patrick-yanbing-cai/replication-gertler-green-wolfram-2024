********************************************************************************
** Do file: e1_build_svysec.do
** First started: March 9, 2020
** Last edited: September 8, 2023

/* Purpose: this do file merges together baseline survey data that was cleaned and
managed previously.
*/

********************************************************************************

/* Note: 6 hhid - no roster info, but there is other info
hhid: 1596, 1859, 2235, 2600, 3062, 4207
*/

clear
clear matrix
clear mata
set maxvar 10000

************
** Part I **
************

* Load clean cover dataset from baseline.
use "$bsvy_clean/1_cover_hh.dta", clear
* Merge in household-level roster information.
merge 1:1 hhid using "$bsvy_clean/2_roster_hh.dta" // A few households skipped over in roster
drop _merge
	* Mean imputation for num_520.
	foreach var of varlist num_520 {
		sum num_520
		replace num_520 = `r(mean)' if num_520==.
	}
	* Note: for hhid==2600 num_520 should be zero
	replace num_520 = 0 if hhid==2600

* Merge in other datasets.
merge 1:1 hhid using "$bsvy_clean/3A_school_dist_hh"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_clean/3B_educ1_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_clean/3C_educ2_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_clean/3D_educ_attitudes_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_processed/4_energy_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_processed/5_shs_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_processed/6_solarlantern_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_processed/7_landhome_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_processed/8_assets_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_clean/9_hhincome_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_processed/10A_coop_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_processed/10B_loans_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_processed/10C_savings_hh.dta"
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using "$bsvy_processed/10D_lending_hh.dta"
keep if _merge==1 | _merge==3
drop _merge

* Save dataset
save "$bsvy_processed/hhvars_baseline.dta", replace
