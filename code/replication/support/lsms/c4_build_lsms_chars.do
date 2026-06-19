********************************************************************************
** Do file: c4_build_lsms_chars.do
** First started: December 14, 2020
** Last edited: September 8, 2023

/* Purpose: this do file develops demographic information from the Uganda LSMS dataset */

********************************************************************************

clear
clear matrix
clear mata
set maxvar 10000

************
** Part I **
************

* Load roster dataset and create variables for a table
use "$lsms2018/GSEC2.dta", clear
g age = h2q8
g female = (h2q3==2) if h2q3!=.
g married = (h2q10==1 | h2q10==2) if h2q10!=.
g for_numberofchildren = (age <= 20) if age!=.
bys hhid: egen numberofchildren = total(for_numberofchildren)
* Merge in labor information (NOTE - USE WHAT COMES FROM SECTION 8
merge 1:1 hhid PID using "$lsms2018/GSEC8.dta", keepusing(s8q04 s8q06 s8q08 s8q10 s8q12 s8q15 s8q19a h8q19b_oneDigit h8q19b_twoDigit h8q19b_threeDigit h8q19b_fourDigit h8q19b_superConfirm s8q20a h8q20b_oneDigit h8q20b_twoDigit h8q20b_threeDigit h8q20b_fourDigit h8q20b_superConfirm)
drop _merge

* Generate employed (or will be employed) variable
g employed = (s8q04==1 | s8q06==1 | s8q08==1 | s8q10==1 | s8q12==1) if s8q04!=.
replace employed = 1 if s8q15==1

* Recall - occ_cat1 should be Ag + Nonemployed, occ_cat2 is Non-professional, 3 is other, 4 is Professional
* Note: must be strict here
g occ_cat1 = (employed==0 | (h8q19b_fourDigit>=6111 & h8q19b_fourDigit<=6340) | (h8q19b_fourDigit>=9211 & h8q19b_fourDigit<=9216)) // Agriculture or Non-employed
g occ_cat2 = (h8q19b_fourDigit==110 | h8q19b_fourDigit==310 | (h8q19b_fourDigit>=5111 & h8q19b_fourDigit<=5419) | (h8q19b_fourDigit>=7111 & h8q19b_fourDigit<=7133) | (h8q19b_fourDigit>=7511 & h8q19b_fourDigit<=7535) | (h8q19b_fourDigit>=8311 & h8q19b_fourDigit<=8332) | (h8q19b_fourDigit>=9311 & h8q19b_fourDigit<=9334)) // Non-professional
g occ_cat3 = ((h8q19b_fourDigit>=7311 & h8q19b_fourDigit<=7323)| (h8q19b_fourDigit>=7541 & h8q19b_fourDigit<=7549) | (h8q19b_fourDigit>=8111 & h8q19b_fourDigit<=8219) | (h8q19b_fourDigit>=8341 & h8q19b_fourDigit<=8350) | (h8q19b_fourDigit>=9111 & h8q19b_fourDigit<=9129) | (h8q19b_fourDigit>=9411 & h8q19b_fourDigit<=9629)) // Other
g occ_cat4 = (h8q19b_fourDigit==210 | (h8q19b_fourDigit >= 1111 & h8q19b_fourDigit <= 1439) | (h8q19b_fourDigit >= 2111 & h8q19b_fourDigit<=2659) | (h8q19b_fourDigit>=3111 & h8q19b_fourDigit<=3522) | (h8q19b_fourDigit>=4110 & h8q19b_fourDigit<=4419) | (h8q19b_fourDigit>=7211 & h8q19b_fourDigit<=7234) | (h8q19b_fourDigit>=7411 & h8q19b_fourDigit<=7422)) // Professional

* Keep information only for the household head and check uniqueness
keep if h2q4==1
isid hhid

	* Replace missing with mode
	sum occ_cat* // occ_cat1 is mode
	replace occ_cat1=1 if occ_cat1!=. & occ_cat4!=1 & occ_cat3!=1 & occ_cat2!=1 & occ_cat1!=1
	sum occ_cat*

* Keep certain variables
keep hhid age female married numberofchildren occ_cat1 occ_cat2 occ_cat3 occ_cat4

* Merge in region and weights
merge 1:1 hhid using "$lsms2018/GSEC1.dta", keepusing(region wgt)
keep if _merge==3
drop _merge

* Drop northern, make region dummies
drop if region==3
g reg1 = (region==1) // Central
g reg2 = (region==2) // Eastern
g reg3 = (region==4) // Western

* Label variables
la var age "Head age"
la var female "Head female"
la var married "Head married"
la var numberofchildren "Head number of children"
la var reg1 "Lives in Central"
la var reg2 "Lives in Eastern"
la var reg3 "Lives in Western"
la var occ_cat1 "Head works agriculture or is unemployed"
la var occ_cat2 "Head works non-professional"
la var occ_cat3 "Head works other job"
la var occ_cat4 "Head works professional job"

la def yesno 0 "No" 1 "Yes"
foreach var of varlist female married reg1 reg2 reg3 occ_cat1 occ_cat2 occ_cat3 occ_cat4 {
	la val `var' yesno
}

order wgt, after(reg3)

* Save dataset
save "$lsms_processed/lsms2018_vars.dta", replace
