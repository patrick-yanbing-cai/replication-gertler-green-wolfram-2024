********************************************************************************
** Do file: h1_iv_ols_main.do
** First started: February 22, 2020
** Last edited: December 31, 2023

/* Purpose: this do file runs IV and OLS for the main analysis on loan repayment
and loan completion

Part I: Loan repayment, IV and OLS
Part II: Loan completion, IV and OLS

* ITEM MADE: TABLE 1
* ITEM MADE: TABLE A.9
*/

********************************************************************************

version 16
set more off

foreach required_file in ///
    `"$repay_clean/fenix_repay_extend_07172020_rep.dta"' ///
    `"$merged/key_rep.dta"' {
    capture confirm file "`required_file'"
    if _rc {
        display as error "Missing required input for h1_iv_ols_main: `required_file'"
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

merge m:1 accountid using "$merged/key_rep.dta", keepusing(k_complete_may k_rolling_list k_interacted_success k_tookloan_repay)
keep if _merge==1 | _merge==3
drop _merge

* Generate tag to subset to customer of interest
g tag = 1 if k_complete_may==1 & k_rolling_list==1 & k_interacted_success==1 & k_tookloan_repay==1

tempfile all
save `all'

* Generate miniature versions of dataset
	preserve
		keep if tag==1
		keep if loandayselapsed == 100
		tempfile data100_strict
		save `data100_strict'
	restore
	preserve
		keep if tag==1
		keep if loandayselapsed == 110
		tempfile data110_strict
		save `data110_strict'
	restore
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

***** TABLE 1 *****

* Mean for the reference group at various days
use `all', clear
sum frac_lpp_maxip if treatmenttype_sh=="R T2-U" & loandayselapsed==100 & tag==1
sum frac_lpp_maxip if treatmenttype_sh=="R T2-U" & loandayselapsed==150 & tag==1
sum frac_lpp_maxip if treatmenttype_sh=="R T2-U" & loandayselapsed==200 & tag==1

* IV
* 100 - Lockout
use `data100_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 100 - Adverse Selection
use `data100_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 100 - Moral Hazard
use `data100_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_repay_LATE_100.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_repay_LATE_100}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance")
eststo clear

* 150 - Lockout
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 150 - Adverse Selection
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T2-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 150 - Moral Hazard
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_repay_LATE_150.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_repay_LATE_150}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance")
eststo clear

* 200 - Lockout
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 200 - Adverse Selection
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T2-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first
* 200 - Moral Hazard
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_repay_LATE_200.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_repay_LATE_200}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance")
eststo clear

	* Test the equality of coefficients between AS and MH (2SLS)
	* 100
	use `data100_strict', clear
		preserve
			keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
			g treatment = (treatmenttype_sh=="R T1-U")
			replace locked_share_wupg=locked_share_wupg_AS
			g ASsample = 1
			keep accountid frac_lpp_maxip treatment locked_share_wupg ASsample
			tempfile as_sample
			save `as_sample'
		restore

		preserve
			keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
			g treatment = (treatmenttype_sh=="R T1-L")
			g ASsample = 2
			keep accountid frac_lpp_maxip treatment locked_share_wupg ASsample
			tempfile mh_sample
			save `mh_sample'
		restore

	use `as_sample', clear
	append using `mh_sample'
	ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment) if ASsample==1, first
	ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment) if ASsample==2, first

	g cons = 1
	ivregress 2sls frac_lpp_maxip c.cons#i.ASsample (c.locked_share_wupg#i.ASsample = i.treatment#i.ASsample), nocons
	test 1.ASsample#c.locked_share_wupg=2.ASsample#c.locked_share_wupg

	* 150
	use `data150_strict', clear
		preserve
			keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
			g treatment = (treatmenttype_sh=="R T1-U")
			replace locked_share_wupg=locked_share_wupg_AS
			g ASsample = 1
			keep accountid frac_lpp_maxip treatment locked_share_wupg ASsample
			tempfile as_sample
			save `as_sample'
		restore

		preserve
			keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
			g treatment = (treatmenttype_sh=="R T1-L")
			g ASsample = 2
			keep accountid frac_lpp_maxip treatment locked_share_wupg ASsample
			tempfile mh_sample
			save `mh_sample'
		restore

	use `as_sample', clear
	append using `mh_sample'
	ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment) if ASsample==1, first
	ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment) if ASsample==2, first

	g cons = 1
	ivregress 2sls frac_lpp_maxip c.cons#i.ASsample (c.locked_share_wupg#i.ASsample = i.treatment#i.ASsample), nocons
	test 1.ASsample#c.locked_share_wupg=2.ASsample#c.locked_share_wupg

	* 200
	use `data200_strict', clear
		preserve
			keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
			g treatment = (treatmenttype_sh=="R T1-U")
			replace locked_share_wupg=locked_share_wupg_AS
			g ASsample = 1
			keep accountid frac_lpp_maxip treatment locked_share_wupg ASsample
			tempfile as_sample
			save `as_sample'
		restore

		preserve
			keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
			g treatment = (treatmenttype_sh=="R T1-L")
			g ASsample = 2
			keep accountid frac_lpp_maxip treatment locked_share_wupg ASsample
			tempfile mh_sample
			save `mh_sample'
		restore

	use `as_sample', clear
	append using `mh_sample'
	ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment) if ASsample==1, first
	ivregress 2sls frac_lpp_maxip (locked_share_wupg = treatment) if ASsample==2, first

	g cons = 1
	ivregress 2sls frac_lpp_maxip c.cons#i.ASsample (c.locked_share_wupg#i.ASsample = i.treatment#i.ASsample), nocons
	test 1.ASsample#c.locked_share_wupg=2.ASsample#c.locked_share_wupg

	eststo clear


***** TABLE A.9 *****

* OLS
* 100 - Lockout
use `data100_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment
* 100 - Adverse Selection
use `data100_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress frac_lpp_maxip treatment
* 100 - Moral Hazard
use `data100_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment

* Generate table
esttab using "$tables/LASMH_repay_ITT_100.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_repay_ITT_100}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(treatment "Subsample treatment")
eststo clear

* 150 - Lockout
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment
* 150 - Adverse Selection
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress frac_lpp_maxip treatment
* 150 - Moral Hazard
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment

* Generate table
esttab using "$tables/LASMH_repay_ITT_150.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_repay_ITT_150}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(treatment "Subsample treatment")
eststo clear

* 200 - Lockout
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment
* 200 - Adverse Selection
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress frac_lpp_maxip treatment
* 200 - Moral Hazard
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress frac_lpp_maxip treatment

* Generate table
esttab using "$tables/LASMH_repay_ITT_200.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_repay_ITT_200}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(treatment "Subsample treatment")
eststo clear

	* Test the equality of coefficients betweens AS and MH (ITT)
	* 100
	use `data100_strict', clear
	g treatment = (treatmenttype_sh=="R T1-U")
	regress frac_lpp_maxip treatment if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
	drop treatment
	estimates store ASmodel
	g treatment = (treatmenttype_sh=="R T1-L")
	regress frac_lpp_maxip treatment if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
	estimates store MHmodel
	suest ASmodel MHmodel
	test [ASmodel_mean = MHmodel_mean]

	* 150
	use `data150_strict', clear
	g treatment = (treatmenttype_sh=="R T1-U")
	regress frac_lpp_maxip treatment if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
	drop treatment
	estimates store ASmodel
	g treatment = (treatmenttype_sh=="R T1-L")
	regress frac_lpp_maxip treatment if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
	estimates store MHmodel
	suest ASmodel MHmodel
	test [ASmodel_mean = MHmodel_mean]

	* 200
	use `data200_strict', clear
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

***** TABLE 1 *****

* Mean for the reference group at various days
use `all', clear
sum completeloan if treatmenttype_sh=="R T2-U" & loandayselapsed==110 & tag==1
sum completeloan if treatmenttype_sh=="R T2-U" & loandayselapsed==150 & tag==1
sum completeloan if treatmenttype_sh=="R T2-U" & loandayselapsed==200 & tag==1

* IV
* 110 - Lockout
use `data110_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first
* 110 - Adverse Selection
use `data110_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first
* 110 - Moral Hazard
use `data110_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_complete_LATE_110.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_complete_LATE_110}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance")
eststo clear

* 150 - Lockout
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first
* 150 - Adverse Selection
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first
* 150 - Moral Hazard
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_complete_LATE_150.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_complete_LATE_150}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance")
eststo clear

* 200 - Lockout
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first
* 200 - Adverse Selection
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
replace locked_share_wupg=locked_share_wupg_AS
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first
* 200 - Moral Hazard
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: ivregress 2sls completeloan (locked_share_wupg = treatment), first

* Generate table
esttab using "$tables/LASMH_complete_LATE_200.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_complete_LATE_200}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(locked_share_wupg "Share of days in compliance")
eststo clear

	* Test the equality of coefficients between AS and MH (2SLS)
	* 110
	use `data110_strict', clear
		preserve
			keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
			g treatment = (treatmenttype_sh=="R T1-U")
			replace locked_share_wupg=locked_share_wupg_AS
			g ASsample = 1
			keep accountid completeloan treatment locked_share_wupg ASsample
			tempfile as_sample
			save `as_sample'
		restore

		preserve
			keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
			g treatment = (treatmenttype_sh=="R T1-L")
			g ASsample = 2
			keep accountid completeloan treatment locked_share_wupg ASsample
			tempfile mh_sample
			save `mh_sample'
		restore

	use `as_sample', clear
	append using `mh_sample'
	ivregress 2sls completeloan (locked_share_wupg = treatment) if ASsample==1, first
	ivregress 2sls completeloan (locked_share_wupg = treatment) if ASsample==2, first

	g cons = 1
	ivregress 2sls completeloan c.cons#i.ASsample (c.locked_share_wupg#i.ASsample = i.treatment#i.ASsample), nocons
	test 1.ASsample#c.locked_share_wupg=2.ASsample#c.locked_share_wupg

	* 150
	use `data150_strict', clear
		preserve
			keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
			g treatment = (treatmenttype_sh=="R T1-U")
			replace locked_share_wupg=locked_share_wupg_AS
			g ASsample = 1
			keep accountid completeloan treatment locked_share_wupg ASsample
			tempfile as_sample
			save `as_sample'
		restore

		preserve
			keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
			g treatment = (treatmenttype_sh=="R T1-L")
			g ASsample = 2
			keep accountid completeloan treatment locked_share_wupg ASsample
			tempfile mh_sample
			save `mh_sample'
		restore

	use `as_sample', clear
	append using `mh_sample'
	ivregress 2sls completeloan (locked_share_wupg = treatment) if ASsample==1, first
	ivregress 2sls completeloan (locked_share_wupg = treatment) if ASsample==2, first

	g cons = 1
	ivregress 2sls completeloan c.cons#i.ASsample (c.locked_share_wupg#i.ASsample = i.treatment#i.ASsample), nocons
	test 1.ASsample#c.locked_share_wupg=2.ASsample#c.locked_share_wupg

	* 200
	use `data200_strict', clear
		preserve
			keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
			g treatment = (treatmenttype_sh=="R T1-U")
			replace locked_share_wupg=locked_share_wupg_AS
			g ASsample = 1
			keep accountid completeloan treatment locked_share_wupg ASsample
			tempfile as_sample
			save `as_sample'
		restore

		preserve
			keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
			g treatment = (treatmenttype_sh=="R T1-L")
			g ASsample = 2
			keep accountid completeloan treatment locked_share_wupg ASsample
			tempfile mh_sample
			save `mh_sample'
		restore

	use `as_sample', clear
	append using `mh_sample'
	ivregress 2sls completeloan (locked_share_wupg = treatment) if ASsample==1, first
	ivregress 2sls completeloan (locked_share_wupg = treatment) if ASsample==2, first

	g cons = 1
	ivregress 2sls completeloan c.cons#i.ASsample (c.locked_share_wupg#i.ASsample = i.treatment#i.ASsample), nocons
	test 1.ASsample#c.locked_share_wupg=2.ASsample#c.locked_share_wupg

	eststo clear


***** TABLE A.9 *****

* OLS
* 110 - Lockout
use `data110_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment
* 110 - Adverse Selection
use `data110_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress completeloan treatment
* 110 - Moral Hazard
use `data110_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment

* Generate table
esttab using "$tables/LASMH_complete_ITT_110.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_complete_ITT_110}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(treatment "Subsample treatment")
eststo clear

* 150 - Lockout
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment
* 150 - Adverse Selection
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress completeloan treatment
* 150 - Moral Hazard
use `data150_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment

* Generate table
esttab using "$tables/LASMH_complete_ITT_150.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_complete_ITT_150}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(treatment "Subsample treatment")
eststo clear

* 200 - Lockout
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment
* 200 - Adverse Selection
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
g treatment = (treatmenttype_sh=="R T1-U")
eststo: regress completeloan treatment
* 200 - Moral Hazard
use `data200_strict', clear
keep if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
g treatment = (treatmenttype_sh=="R T1-L")
eststo: regress completeloan treatment

* Generate table
esttab using "$tables/LASMH_complete_ITT_200.tex", ///
	b(2) se(2) se replace booktabs star(* .10 ** .05 *** .01) title(Effect of Securing a Loan with Digital Collateral on Loan Repayment and Loan Completion\label{LASMH_complete_ITT_200}) ///
	label noconstant nodepvars mtitles("Secured Treatment" "Selection Effect" "Moral Hazard Effect") nonotes ///
	varlabels(treatment "Subsample treatment")
eststo clear

	* Test the equality of coefficients betweens AS and MH (ITT)
	* 100
	use `data110_strict', clear
	g treatment = (treatmenttype_sh=="R T1-U")
	regress completeloan treatment if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
	estimates store ASmodel
	drop treatment
	g treatment = (treatmenttype_sh=="R T1-L")
	regress completeloan treatment if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
	estimates store MHmodel
	suest ASmodel MHmodel
	test [ASmodel_mean = MHmodel_mean]

	* 150
	use `data150_strict', clear
	g treatment = (treatmenttype_sh=="R T1-U")
	regress completeloan treatment if treatmenttype_sh=="R T1-U" | treatmenttype_sh=="R T2-U"
	drop treatment
	estimates store ASmodel
	g treatment = (treatmenttype_sh=="R T1-L")
	regress completeloan treatment if treatmenttype_sh=="R T1-L" | treatmenttype_sh=="R T1-U"
	estimates store MHmodel
	suest ASmodel MHmodel
	test [ASmodel_mean = MHmodel_mean]

	* 200
	use `data200_strict', clear
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
