********************************************************************************
** Do file: h2_iv_ols_riskintcat.do
** First started: September 19, 2020
** Last edited: December 31, 2023

/* Purpose: this do file runs IV and OLS, interaction models with risk

Part I: Loan repayment with risk and risk interaction, IV and OLS
Part II: Loan completion with risk and risk interaction, IV and OLS

* ITEM MADE: TABLE 2
* ITEM MADE: TABLE A.10
*/

********************************************************************************

version 16
set more off

foreach required_file in ///
    `"$repay_clean/fenix_repay_extend_07172020_rep.dta"' ///
    `"$merged/key_rep.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for h2_iv_ols_riskintcat: `required_file'"
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
merge m:1 accountid using "$merged/key_rep.dta", keepusing(k_complete_may k_rolling_list k_interacted_success k_tookloan_repay accountpercentlocked_may)
keep if _merge==1 | _merge==3
drop _merge

* Generate tag to subset to customer of interest
g tag = 1 if k_complete_may==1 & k_rolling_list==1 & k_interacted_success==1 & k_tookloan_repay==1

    * Find the median of risk variable
    preserve
        duplicates drop accountid, force
        tab accountpercentlocked_may if tag==1 & (treatmenttype_sh=="R T1-L" | ///
                                                treatmenttype_sh=="R T1-U" | ///
                                                treatmenttype_sh=="R T2-U")
        sum accountpercentlocked_may if tag==1 & (treatmenttype_sh=="R T1-L" | ///
                                                treatmenttype_sh=="R T1-U" | ///
                                                treatmenttype_sh=="R T2-U"), det
    restore

    * Add risk groups
    g riskabove = (accountpercentlocked_may >= 11)

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

***** TABLE 2 *****

* IV
* 150 - Lockout
use `data150_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_riskabove = treatment * riskabove
    g lockshar_riskabove = locked_share_wupg * riskabove
eststo: ivregress2 2sls frac_lpp_maxip riskabove (locked_share_wupg lockshar_riskabove = treatment treat_riskabove) if tag==1, first
* 150 - Adverse Selection
use `data150_strict', clear
keep if (treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T2-U")
replace locked_share_wupg=locked_share_wupg_AS
    * Generate interactions
    g treat_riskabove = treatment * riskabove
    g lockshar_riskabove = locked_share_wupg * riskabove
eststo: ivregress2 2sls frac_lpp_maxip riskabove (locked_share_wupg lockshar_riskabove = treatment treat_riskabove), first
* 150 - Moral Hazard
use `data150_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_riskabove = treatment * riskabove
    g lockshar_riskabove = locked_share_wupg * riskabove
eststo: ivregress2 2sls frac_lpp_maxip riskabove (locked_share_wupg lockshar_riskabove = treatment treat_riskabove), first

* Generate table
esttab using "$tables/LASMH_repay_riskinteract_LATE.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Risk Level\label{LASMH_repay_riskinteract_LATE}) ///
    label nodepvars mtitles("Secured" "Selection" "Moral Hazard") stats(N, fmt(%9.0f)) nonotes ///
    order(locked_share_wupg lockshar_riskabove riskabove _cons) ///
    varlabels(locked_share_wupg "Treatment" lockshar_riskabove "Treatment $\times$ Median risk or above" riskabove "Median risk or above" _cons "Constant", ///
    elist(locked_share_wupg \addlinespace lockshar_riskabove \addlinespace riskabove \addlinespace _cons \addlinespace))
eststo clear


***** TABLE A.10 *****

* OLS
* 150 - Lockout
use `data150_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_riskabove = treatment * riskabove
eststo: regress frac_lpp_maxip treatment riskabove treat_riskabove
* 150 - Adverse Selection
use `data150_strict', clear
keep if (treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T1-U")
    * Generate interactions
    g treat_riskabove = treatment * riskabove
eststo: regress frac_lpp_maxip treatment riskabove treat_riskabove
* 150 - Moral Hazard
use `data150_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_riskabove = treatment * riskabove
eststo: regress frac_lpp_maxip treatment riskabove treat_riskabove

esttab using "$tables/LASMH_repay_riskinteract_ITT.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Risk Level\label{LASMH_repay_riskinteract_ITT}) ///
    label nodepvars mtitles("Secured" "Selection" "Moral Hazard") stats(N, fmt(%9.0f)) nonotes ///
    order(treatment treat_riskabove riskabove _cons) ///
    varlabels(treatment "Treatment" treat_riskabove "Treatment $\times$ Median risk or above" riskabove "Median risk or above" _cons "Constant", ///
    elist(treatment \addlinespace treat_riskabove \addlinespace riskabove \addlinespace _cons \addlinespace))
eststo clear



*************
** PART II **
*************

***** TABLE 2 *****

* IV
* 200 - Lockout
use `data200_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_riskabove = treatment * riskabove
    g lockshar_riskabove = locked_share_wupg * riskabove
eststo: ivregress2 2sls completeloan riskabove (locked_share_wupg lockshar_riskabove = treatment treat_riskabove), first
* 200 - Adverse Selection
use `data200_strict', clear
keep if (treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T2-U")
replace locked_share_wupg=locked_share_wupg_AS
    * Generate interactions
    g treat_riskabove = treatment * riskabove
    g lockshar_riskabove = locked_share_wupg * riskabove
eststo: ivregress2 2sls completeloan riskabove (locked_share_wupg lockshar_riskabove = treatment treat_riskabove), first
* 200 - Moral Hazard
use `data200_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_riskabove = treatment * riskabove
    g lockshar_riskabove = locked_share_wupg * riskabove
eststo: ivregress2 2sls completeloan riskabove (locked_share_wupg lockshar_riskabove = treatment treat_riskabove), first

* Generate table
esttab using "$tables/LASMH_complete_riskinteract_LATE.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Risk Level\label{LASMH_complete_riskinteract_LATE}) ///
    label nodepvars mtitles("Secured" "Selection" "Moral Hazard") stats(N, fmt(%9.0f)) nonotes ///
    order(locked_share_wupg lockshar_riskabove riskabove _cons) ///
    varlabels(locked_share_wupg "Treatment" lockshar_riskabove "Treatment $\times$ Median risk or above" riskabove "Median risk or above" _cons "Constant", ///
    elist(locked_share_wupg \addlinespace lockshar_riskabove \addlinespace riskabove \addlinespace _cons \addlinespace))
eststo clear


***** TABLE A.10 *****

* OLS
* 200 - Lockout
use `data200_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_riskabove = treatment * riskabove
eststo: regress completeloan treatment riskabove treat_riskabove
* 200 - Adverse Selection
use `data200_strict', clear
keep if (treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U")
g treatment = (treatmenttype_sh=="R T1-U")
    * Generate interactions
    g treat_riskabove = treatment * riskabove
eststo: regress completeloan treatment riskabove treat_riskabove
* 200 - Moral Hazard
use `data200_strict', clear
keep if (treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U")
g treatment = (treatmenttype_sh=="R T1-L")
    * Generate interactions
    g treat_riskabove = treatment * riskabove
eststo: regress completeloan treatment riskabove treat_riskabove

* Generate table
esttab using "$tables/LASMH_complete_riskinteract_ITT.tex", ///
    b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Risk Level\label{LASMH_complete_riskinteract_ITT}) ///
    label nodepvars mtitles("Secured" "Selection" "Moral Hazard") stats(N, fmt(%9.0f)) nonotes ///
    order(treatment treat_riskabove riskabove _cons) ///
    varlabels(treatment "Treatment" treat_riskabove "Treatment $\times$ Median risk or above" riskabove "Median risk or above" _cons "Constant", ///
    elist(treatment \addlinespace treat_riskabove \addlinespace riskabove \addlinespace _cons \addlinespace))
eststo clear
