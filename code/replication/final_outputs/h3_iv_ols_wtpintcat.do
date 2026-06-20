********************************************************************************
** Do file: h3_iv_ols_wtpintcat.do
** First started: December 21, 2020
** Last edited: December 31, 2023

/* Purpose: this do file runs IV and OLS, interacted models with willingness to
pay (wtp) for solar

Part I: Loan repayment with wtp and wtp interaction, IV
Part II: Loan completion with wtp and wtp interaction, IV

* ITEM MADE: TABLE A.11
*/

********************************************************************************

version 16
set more off

foreach required_file in ///
    `"$repay_clean/fenix_repay_extend_07172020_rep.dta"' ///
    `"$merged/key_rep.dta"' ///
    `"$esvy_processed/9_lockedoccurences_hh.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for h3_iv_ols_wtpintcat: `required_file'"
        exit 601
    }
}

display as text "Writing maintained table outputs under: $tables"

clear
clear matrix
clear mata
set maxvar 10000

*** Preamble - make data sets ***

* Note: for the Adverse selection comparison, have to use complier_share* on T1-U and lockout_share* on T2-U

* Load repayment dataset
use "$repay_clean/fenix_repay_extend_07172020_rep.dta", clear

* Generate and label compliance variables
g locked_share_wupg_AS = .
replace locked_share_wupg_AS = complier_share_wupg if treatmenttype_sh=="R T1-U"
replace locked_share_wupg_AS = locked_share_wupg if treatmenttype_sh=="R T2-U"
la var locked_share_wupg_AS "Share of days in compliance for Adverse Selection comparison"

* Merge in filter variables
merge m:1 accountid using "$merged/key_rep.dta", keepusing(k_complete_may k_rolling_list k_interacted_success k_tookloan_repay k_surveyed k_surveyed_end hhid)
keep if _merge==1 | _merge==3
drop _merge

* Generate tag to subset to customer of interest
g tag = 1 if k_complete_may==1 & k_rolling_list==1 & k_interacted_success==1 & k_tookloan_repay==1 & k_surveyed==1 & k_surveyed_end==1

* Merge in wtpday
merge m:1 hhid using "$esvy_processed/9_lockedoccurences_hh.dta", keepusing(wtpday)
keep if _merge==1 | _merge==3
drop _merge

    * Find the median of wtp variable
    preserve
        duplicates drop accountid, force
        tab wtpday if tag==1 & (treatmenttype_sh=="R T1-L" | ///
                                treatmenttype_sh=="R T1-U" | ///
                                treatmenttype_sh=="R T2-U")
        sum wtpday if tag==1 & (treatmenttype_sh=="R T1-L" | ///
                                treatmenttype_sh=="R T1-U" | ///
                                treatmenttype_sh=="R T2-U"), det
    restore

    * Add wtp groups
    g wtpbelow = (wtpday < 3000)
    g wtpabove = (wtpday >= 3000)

tempfile all
save `all'

* Generate miniature versions of dataset
    preserve
        keep if tag==1
        keep if loandayselapsed == 150
        tempfile data150_strict
        save `data150_strict'
    restore
    preserve
        keep if tag==1
        keep if loandayselapsed == 200
        tempfile data200_strict
        save `data200_strict'
    restore



************
** PART I **
************

***** TABLE A.11 *****

* IV
* 150 - Lockout
use `data150_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_wtpabove = treatment * wtpabove
    g lockshar_wtpabove = locked_share_wupg * wtpabove
eststo: ivregress2 2sls frac_lpp_maxip wtpabove (locked_share_wupg lockshar_wtpabove = treatment treat_wtpabove), first
* 150 - Adverse Selection
use `data150_strict', clear
keep if (treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T2-U")
replace locked_share_wupg=locked_share_wupg_AS
    * Generate interactions
    g treat_wtpabove = treatment * wtpabove
    g lockshar_wtpabove = locked_share_wupg * wtpabove
eststo: ivregress2 2sls frac_lpp_maxip wtpabove (locked_share_wupg lockshar_wtpabove = treatment treat_wtpabove), first
* 150 - Moral Hazard
use `data150_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_wtpabove = treatment * wtpabove
    g lockshar_wtpabove = locked_share_wupg * wtpabove
eststo: ivregress2 2sls frac_lpp_maxip wtpabove (locked_share_wupg lockshar_wtpabove = treatment treat_wtpabove), first

* Generate table
esttab using "$tables/LASMH_repay_wtpinteract_LATE.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by WTP Level\label{LASMH_repay_wtpinteract_LATE}) ///
    label nodepvars mtitles("Secured" "Selection" "Moral Hazard") stats(N, fmt(%9.0f)) nonotes ///
    order(locked_share_wupg lockshar_wtpabove wtpabove _cons) ///
    varlabels(locked_share_wupg "Treatment" lockshar_wtpabove "Treatment $\times$ Median WTP or above" wtpabove "Median WTP or above" _cons "Constant", ///
    elist(locked_share_wupg \addlinespace lockshar_wtpabove \addlinespace wtpabove \addlinespace _cons \addlinespace))
eststo clear



*************
** PART II **
*************

***** TABLE A.11 *****

* IV
* 200 - Lockout
use `data200_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_wtpabove = treatment * wtpabove
    g lockshar_wtpabove = locked_share_wupg * wtpabove
eststo: ivregress2 2sls completeloan wtpabove (locked_share_wupg lockshar_wtpabove = treatment treat_wtpabove), first
* 200 - Adverse Selection
use `data200_strict', clear
keep if (treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T2-U")
replace locked_share_wupg=locked_share_wupg_AS
    * Generate interactions
    g treat_wtpabove = treatment * wtpabove
    g lockshar_wtpabove = locked_share_wupg * wtpabove
eststo: ivregress2 2sls completeloan wtpabove (locked_share_wupg lockshar_wtpabove = treatment treat_wtpabove), first
* 200 - Moral Hazard
use `data200_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_wtpabove = treatment * wtpabove
    g lockshar_wtpabove = locked_share_wupg * wtpabove
eststo: ivregress2 2sls completeloan wtpabove (locked_share_wupg lockshar_wtpabove = treatment treat_wtpabove), first

* Generate table
esttab using "$tables/LASMH_complete_wtpinteract_LATE.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by WTP Level\label{LASMH_complete_wtpinteract_LATE}) ///
    label nodepvars mtitles("Secured" "Selection" "Moral Hazard") stats(N, fmt(%9.0f)) nonotes ///
    order(locked_share_wupg lockshar_wtpabove wtpabove _cons) ///
    varlabels(locked_share_wupg "Treatment" lockshar_wtpabove "Treatment $\times$ Median WTP or above" wtpabove "Median WTP or above" _cons "Constant", ///
    elist(locked_share_wupg \addlinespace lockshar_wtpabove \addlinespace wtpabove \addlinespace _cons \addlinespace))
eststo clear
