********************************************************************************
** Do file: h4_iv_ols_earlyadopt.do
** First started: May 01, 2020
** Last edited: December 31, 2023

/* Purpose: this do file runs IV and OLS, focusing on when the survey was taken
relative to when the loan was taken

Part I: Loan repayment, restricting to all those who were informed after taking up loan OR were never surveyed
Part II: Loan completion, restricting to all those who were informed after taking up loan OR were never surveyed

* ITEM MADE: TABLE A.12
*/

********************************************************************************

version 16
set more off

foreach required_file in ///
    `"$repay_clean/fenix_repay_extend_07172020_rep.dta"' ///
    `"$merged/key_rep.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for h4_iv_ols_earlyadopt: `required_file'"
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
merge m:1 accountid using "$merged/key_rep.dta", keepusing(k_complete_may k_rolling_list k_interacted_success k_tookloan_repay k_surveyed svyend_before_loan)
keep if _merge==3
drop _merge

* Generate tag to subset to customer of interest
g tag2a = 1 if k_complete_may==1 & k_rolling_list==1 & k_interacted_success==1 & k_tookloan_repay==1 & ///
	(svyend_before_loan==0 | svyend_before_loan==. | (k_surveyed==0 & svyend_before_loan==1))
	

tempfile all
save `all'

* Generate miniature versions of dataset
	preserve
		keep if tag2a==1
		keep if loandayselapsed == 100
		tempfile data100_bsvy_allrestrict_new
		save `data100_bsvy_allrestrict_new'
	restore
	preserve
		keep if tag2a==1
		keep if loandayselapsed == 110
		tempfile data110_bsvy_allrestrict_new
		save `data110_bsvy_allrestrict_new'
	restore
	preserve
		keep if tag2a==1
		keep if loandayselapsed == 150
		tempfile data150_bsvy_allrestrict_new
		save `data150_bsvy_allrestrict_new'
	restore
	preserve
		keep if tag2a==1
		keep if loandayselapsed == 200
		tempfile data200_bsvy_allrestrict_new
		save `data200_bsvy_allrestrict_new'
	restore

	
	
***** TABLE A.12 *****
	
************
** PART I **
************

* Mean for the reference group at various days
use `all', clear
sum frac_lpp_maxip if treatmenttype_sh=="R T2-U" & loandayselapsed==100 & tag2a==1
sum frac_lpp_maxip if treatmenttype_sh=="R T2-U" & loandayselapsed==150 & tag2a==1
sum frac_lpp_maxip if treatmenttype_sh=="R T2-U" & loandayselapsed==200 & tag2a==1

* IV 
* 100 - Lockout
use `data100_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress2 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 100 - Adverse Selection
use `data100_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 100 - Moral Hazard
use `data100_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_repay_earlyadopt_LATE_100.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_repay_earlyadopt_LATE_100}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance") 
eststo clear

	
* 150 - Lockout
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress2 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 150 - Adverse Selection
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T2-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 150 - Moral Hazard
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_repay_earlyadopt_LATE_150.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_repay_earlyadopt_LATE_150}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance")	
eststo clear


* 200 - Lockout
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress2 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 200 - Adverse Selection
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T2-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 200 - Moral Hazard
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_repay_earlyadopt_LATE_200.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_repay_earlyadopt_LATE_200}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance") 
eststo clear


* OLS
* 100 - Lockout
use `data100_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment
* 100 - Adverse Selection
use `data100_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress frac_lpp_maxip treatment
* 100 - Moral Hazard
use `data100_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment

* Generate table
esttab using "$tables/LASMH_repay_earlyadopt_ITT_100.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_repay_earlyadopt_ITT_100}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(treatment "Subsample treatment")
eststo clear


* 150 - Lockout
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment
* 150 - Adverse Selection
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress frac_lpp_maxip treatment
* 150 - Moral Hazard
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment

* Generate table
esttab using "$tables/LASMH_repay_earlyadopt_ITT_150.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_repay_earlyadopt_ITT_150}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(treatment "Subsample treatment")
eststo clear


* 200 - Lockout
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment
* 200 - Adverse Selection
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress frac_lpp_maxip treatment
* 200 - Moral Hazard
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment

* Generate table
esttab using "$tables/LASMH_repay_earlyadopt_ITT_200.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_repay_earlyadopt_ITT_200}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(treatment "Subsample treatment")	
eststo clear

	* Test the equality of coefficients betweens AS and MH (ITT)
	use `data100_bsvy_allrestrict_new', clear
	g treatment = (treatmenttype_sh=="R T1-U")
	regress frac_lpp_maxip treatment if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
	drop treatment 
	estimates store ASmodel
	g treatment = (treatmenttype_sh=="R T1-L")
	regress frac_lpp_maxip treatment if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
	estimates store MHmodel
	suest ASmodel MHmodel
	test [ASmodel_mean = MHmodel_mean]

	use `data150_bsvy_allrestrict_new', clear
	g treatment = (treatmenttype_sh=="R T1-U")
	regress frac_lpp_maxip treatment if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
	drop treatment 
	estimates store ASmodel
	g treatment = (treatmenttype_sh=="R T1-L")
	regress frac_lpp_maxip treatment if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
	estimates store MHmodel
	suest ASmodel MHmodel
	test [ASmodel_mean = MHmodel_mean]

	use `data200_bsvy_allrestrict_new', clear
	g treatment = (treatmenttype_sh=="R T1-U")
	regress frac_lpp_maxip treatment if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
	drop treatment 
	estimates store ASmodel
	g treatment = (treatmenttype_sh=="R T1-L")
	regress frac_lpp_maxip treatment if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
	estimates store MHmodel
	suest ASmodel MHmodel
	test [ASmodel_mean = MHmodel_mean]
		
	eststo clear

	

*************
** PART II **
*************

* Mean for the reference group at various days
use `all', clear
sum completeloan if treatmenttype_sh=="R T2-U" & loandayselapsed==110 & tag2a==1
sum completeloan if treatmenttype_sh=="R T2-U" & loandayselapsed==150 & tag2a==1
sum completeloan if treatmenttype_sh=="R T2-U" & loandayselapsed==200 & tag2a==1

* IV 
* 110 - Lockout
use `data110_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress2 2sls completeloan (locked_share_wupg = treatment), first
* 110 - Adverse Selection
use `data110_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first
* 110 - Moral Hazard
use `data110_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_complete_earlyadopt_LATE_110.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_complete_earlyadopt_LATE_110}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance") 
eststo clear

	
* 150 - Lockout
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress2 2sls completeloan (locked_share_wupg = treatment), first
* 150 - Adverse Selection
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T2-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first
* 150 - Moral Hazard
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_complete_earlyadopt_LATE_150.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_complete_earlyadopt_LATE_150}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance")	
eststo clear


* 200 - Lockout
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress2 2sls completeloan (locked_share_wupg = treatment), first
* 200 - Adverse Selection
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T2-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first
* 200 - Moral Hazard
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_complete_earlyadopt_LATE_200.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_complete_earlyadopt_LATE_200}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance") 
eststo clear


* OLS
* 110 - Lockout
use `data110_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment
* 110 - Adverse Selection
use `data110_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress completeloan treatment
* 110 - Moral Hazard
use `data110_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment

* Generate table
esttab using "$tables/LASMH_complete_earlyadopt_ITT_110.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_complete_earlyadopt_ITT_110}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(treatment "Subsample treatment")
eststo clear


* 150 - Lockout
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment
* 150 - Adverse Selection
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress completeloan treatment
* 150 - Moral Hazard
use `data150_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment

* Generate table
esttab using "$tables/LASMH_complete_earlyadopt_ITT_150.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_complete_earlyadopt_ITT_150}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(treatment "Subsample treatment")
eststo clear


* 200 - Lockout
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment
* 200 - Adverse Selection
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress completeloan treatment
* 200 - Moral Hazard
use `data200_bsvy_allrestrict_new', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment

* Generate table
esttab using "$tables/LASMH_complete_earlyadopt_ITT_200.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion, by Early Adopters\label{LASMH_complete_earlyadopt_ITT_200}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection" "Moral Hazard") nonotes ///
	varlabels(treatment "Subsample treatment")	
eststo clear

	* Test the equality of coefficients betweens AS and MH (ITT)
	use `data110_bsvy_allrestrict_new', clear
	g treatment = (treatmenttype_sh=="R T1-U")
	regress completeloan treatment if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
	drop treatment 
	estimates store ASmodel
	g treatment = (treatmenttype_sh=="R T1-L")
	regress completeloan treatment if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
	estimates store MHmodel
	suest ASmodel MHmodel
	test [ASmodel_mean = MHmodel_mean]

	use `data150_bsvy_allrestrict_new', clear
	g treatment = (treatmenttype_sh=="R T1-U")
	regress completeloan treatment if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
	drop treatment 
	estimates store ASmodel
	g treatment = (treatmenttype_sh=="R T1-L")
	regress completeloan treatment if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
	estimates store MHmodel
	suest ASmodel MHmodel
	test [ASmodel_mean = MHmodel_mean]

	use `data200_bsvy_allrestrict_new', clear
	g treatment = (treatmenttype_sh=="R T1-U")
	regress completeloan treatment if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
	drop treatment 
	estimates store ASmodel
	g treatment = (treatmenttype_sh=="R T1-L")
	regress completeloan treatment if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
	estimates store MHmodel
	suest ASmodel MHmodel
	test [ASmodel_mean = MHmodel_mean]
		
	eststo clear
