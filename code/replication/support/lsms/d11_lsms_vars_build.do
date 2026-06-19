********************************************************************************
** Do file: d11_lsms_vars_build.do
** First started: July 11, 2020
** Last edited: September 8, 2023

/* Purpose: this do file develops variables for the LSMS dataset to then use elsewhere, mostly for
comparison with Fenix sample

* Part I: Develop income variables
* Part II: Develop education variables
* Part III: Develop finance variables
*/

********************************************************************************

clear
clear matrix
clear mata
set maxvar 10000

* For Household Demographics, develop a household size variable and a number of people between ages of 5 and 20 variable in a temporary dataset.
use "$lsms2018/GSEC2.dta", clear
g hhsize = 1
g num520 = 1 if h2q8>=5 & h2q8<=20
collapse (sum) hhsize num520, by(hhid)
tempfile hhdemos
save `hhdemos'


**********************
**  Part I: Income  **
**********************

** Household survey datasets **
* Labor
use "$lsms2018/GSEC8.dta", clear
g job1yrinc = s8q78*12
g job2yrinc = s8q80*12
collapse (sum) job*, by(hhid)
foreach var of varlist job1yrinc job2yrinc {
	sum `var', det
	replace `var' = `r(p99)' if `var' >`r(p99)' & `var'!=. & `var'!=0
}
tempfile labor
save `labor'

* Sources of income
* use "$lsms2018/GSEC7_2.dta", clear
* This dataset seems incomplete (missing the variables that I would actually want) but not a lot of HH received anyway, so ignore

** Non crop farming household enterprises **
use "$lsms2018/GSEC12_2.dta", clear
g busyrinc = h12q09*h12q10
collapse (sum) busyrinc, by(hhid)
foreach var of varlist busyrinc {
	sum `var', det
	replace `var' = `r(p99)' if `var' >`r(p99)' & `var'!=. & `var'!=0
}
tempfile nce
save `nce'

** Agriculture survey datasets **
* Crop sold
* Value of crop sold from first visit
use "$lsms2018/AGSEC5A.dta", clear
g v_cropsold1 = s5aq08_1
collapse (sum) v_cropsold1, by(hhid)
foreach var of varlist v_cropsold1 {
	sum `var', det
	replace `var' = `r(p99)' if `var' >`r(p99)' & `var'!=. & `var'!=0
}
* Value of crop sold from second visit
tempfile cropssold1
save `cropssold1'
use "$lsms2018/AGSEC5B.dta", clear
g v_cropsold2 = s5bq08_1
collapse (sum) v_cropsold2, by(hhid)
foreach var of varlist v_cropsold2 {
	sum `var', det
	replace `var' = `r(p99)' if `var' >`r(p99)' & `var'!=. & `var'!=0
}
tempfile cropssold2
save `cropssold2'

* Livestock products
* Not livestock sold (asset), but livestock slaughtered for meat
use "$lsms2018/AGSEC8A.dta", clear
* Not many selling meat
* Note that value interpretation depends on animal itself, for year
* Leave large ruminants value alone
* Small ruminants, multiply by 2 (including pigs
replace s8aq05 = s8aq05*2 if AGroup_ID==102 | AGroup_ID==104 | AGroup_ID==106 | AGroup_ID==108
* Poultry, multiply by 4
replace s8aq05 = s8aq05*4 if AGroup_ID==103 | AGroup_ID==107
g val_meat = s8aq05
collapse (sum) val_meat, by(hhid)
foreach var of varlist val_meat {
	sum `var', det
	replace `var' = `r(p99)' if `var' >`r(p99)' & `var'!=. & `var'!=0
}
tempfile val_meat
save `val_meat'

* Milk
use "$lsms2018/AGSEC8B.dta", clear
* Values over past 12 months
g val_milk = s8bq09
collapse (sum) val_milk, by(hhid)
foreach var of varlist val_milk {
	sum `var', det
	replace `var' = `r(p99)' if `var' >`r(p99)' & `var'!=. & `var'!=0
}
tempfile val_milk
save `val_milk'

* Eggs
use "$lsms2018/AGSEC8C.dta", clear
* Values over past 3 months, make yearly
g val_eggs = s8cq05*4
collapse (sum) val_eggs, by(hhid)
foreach var of varlist val_eggs {
	sum `var', det
	replace `var' = `r(p99)' if `var' >`r(p99)' & `var'!=. & `var'!=0
}
tempfile val_eggs
save `val_eggs'

* Animal power
use "$lsms2018/AGSEC11.dta", clear
*12 month values
g val_dung = s11q01c
g val_animpw = s11q05a
collapse (sum) val_dung val_animpw, by(hhid)
foreach var of varlist val_dung val_animpw {
	sum `var', det
	replace `var' = `r(p99)' if `var' >`r(p99)' & `var'!=. & `var'!=0
}
tempfile val_animpw
save `val_animpw'

* Bring together to the filter dataset
use "$lsms2018/GSEC1.dta", clear
keep hhid wgt
merge 1:1 hhid using `labor'
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using `nce'
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using `cropssold1'
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using `cropssold2'
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using `val_meat'
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using `val_milk'
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using `val_eggs'
keep if _merge==1 | _merge==3
drop _merge
merge 1:1 hhid using `val_animpw'
keep if _merge==1 | _merge==3
drop _merge
* Generate income from a rowsum
egen hhincome = rsum(job1yrinc job2yrinc busyrinc v_cropsold1 v_cropsold2 val_meat val_milk val_eggs val_dung val_animpw)

*** Statistic
sum hhincome [aw=wgt]

merge 1:1 hhid using `hhdemos', keepusing(hhsize)
keep if _merge==1 | _merge==3
drop _merge
g hhincome_hhsize = hhincome/hhsize
save "$lsms_processed/income.dta", replace


************************
** Part II: Education **
************************

* Start with filter, completed whole interview
use "$lsms2018/GSEC1.dta", clear
keep hhid wgt
merge 1:m hhid using "$lsms2018/GSEC4.dta"
keep if _merge==3
drop _merge

* Individual: hhid PID

* Merge in age
merge 1:1 hhid PID using "$lsms2018/GSEC2.dta"
keep if _merge==1 | _merge==3
drop _merge

/* Sum together only a few of these to be more comparable to Fenix
School fees - h4q15h
Uniforms and school supplies - h4q15b
Books and school supplies - h4q15c
Transport to and from school - h4q15d

Ignoring:
Registration fees
Exam fees
Boarding fees
Expenses in day care facility
Other educational expenses

* Two things:
1) The survey says "if nothing was spent, write 0" but there are no zeros. Make missings zeros conditional
on other filters
2) If respondent doesn't know, they write a 1 in the column. Replace with the non-1, non-zero mean for now.
*/
* How many are 1s, out of total (proportions)
count if h4q15h==1
count if h4q15h!=. // 560/5650 = 0.099
count if h4q15b==1
count if h4q15b!=. // 60/3173 = 0.019
count if h4q15c==1
count if h4q15c!=. // 47/6307 = 0.007
count if h4q15d==1
count if h4q15d!=. // 43/1175 = 0.037
foreach var of varlist h4q15h h4q15i h4q15j h4q15e h4q15b h4q15c h4q15d {
	replace `var' = 0 if !(s4q05==1 | s4q05==2) & `var'==.
	sum `var' if `var'!=1 & `var'!=0, det
	replace `var' = `r(mean)' if `var'==1
}
egen schoolexpend = rsum(h4q15h h4q15i h4q15j h4q15e h4q15b h4q15c h4q15d)
* Should not have spoken about school expenditures if never attended or only attended school in the past
replace schoolexpend=. if s4q05==1 | s4q05==2

	* Generate an alternate measure that just uses total expenditure on anything
	replace h4q15g = 0 if !(s4q05==1 | s4q05==2) & h4q15g==.
	replace h4q15g=. if s4q05==1 | s4q05==2
	g schoolexpend2 = h4q15g

	* Make values missing if not within 5-20 inclusive - do only for schoolexpend2 version
	g schoolexpend3 = schoolexpend2
	replace schoolexpend3 = . if h2q8<5 | h2q8>20

* Generate categories for variables of interest, based on being of primary or secondary school age
g prim_SAC = 1 if (h2q8>=5 & h2q8<=13)
g sec_SAC = 1 if (h2q8>=14 & h2q8<=20)

* Bring in labor status (note, only asked for HH members 10 years older and above)
merge 1:1 hhid PID using "$lsms2018/GSEC8.dta"
keep if _merge==1 | _merge==3
drop _merge

* Need weights
merge m:1 hhid using `hhdemos'
keep if _merge==1 | _merge==3
drop _merge

* Currently enrolled indicator
g enrolled = (s4q05==3) if s4q05!=.

* Generate indicators for primary, secondary, tertiary
g prim_sch = 1 if s4q10>=10 & s4q10<=16
g sec_sch = 1 if s4q10>=30 & s4q10<=35
g tert_sch = 1 if s4q10==40 | s4q10==50 | s4q10==60

************************

** Variable label
la var enrolled "Currently attending school"
la var prim_sch "Currently enrolled in primary school"
la var sec_sch "Currently enrolled in secondary school"
la var tert_sch "Currently enrolled in teritary school"
la var prim_SAC "School aged child in primary"
la var sec_SAC "School aged child in secondary"
la var hhsize "Household size"
la var schoolexpend "School related expenditures (from individual items)"
la var schoolexpend2 "School related expenditures (from total expenditure)"
la var schoolexpend3 "School related expenditures (from total expenditure) for children aged 5-20"
la var num520 "Number of children aged 5-20 in HH (household-level)"

* Keep variables
keep hhid PID enrolled prim_sch sec_sch tert_sch prim_SAC sec_SAC wgt hhsize schoolexpend schoolexpend2 schoolexpend3 num520

* Save data
saveold "$lsms_processed/lsms_vars_indiv.dta", version(12) replace


*********************************************
** Variables below will be household level **


* Generate three versions of household level variables:
* Spending on primary education
egen f_prim_schoolexpend = total(schoolexpend) if prim_sch==1, by(hhid)
egen prim_schoolexpend=max(f_prim_schoolexpend), by(hhid)
egen f_sec_schoolexpend = total(schoolexpend) if sec_sch==1, by(hhid)
egen sec_schoolexpend=max(f_sec_schoolexpend), by(hhid)

* Drop duplicates
duplicates drop hhid, force
keep hhid prim_schoolexpend sec_schoolexpend wgt num520
* Winsorize at 99th percentile, for each HH level measure
foreach var of varlist prim_schoolexpend sec_schoolexpend {
	sum `var', det
	replace `var' = `r(p99)' if `var' >`r(p99)' & `var'!=.
}

* Merge in income
merge 1:1 hhid using "$lsms_processed/income.dta", keepusing(hhincome)
assert _merge==3
* Generate variables: share of income going to expenditures, by prim/sec/tert
g prim_se_inc = prim_schoolexpend/hhincome
g sec_se_inc = sec_schoolexpend/hhincome
drop _merge

tempfile educ_income
save `educ_income'



***********************
** Part III: Finance **
***********************

* Load dataset
use "$lsms2018/GSEC7_4.dta", clear
drop if CB12_1==2 // Did not respond anything
* Generate borrowed variable
g borrowed = (CB12==1) if CB12!=.
* Generate microfinance credit variable. Need to infer true zeros for CB15A - CB15X.
foreach var of varlist CB15A-CB15X {
	replace `var' = 0 if `var'==2
}
egen check = rsum(CB15A-CB15X)


foreach var of varlist CB15A-CB15X {
	assert `var'==. if check==0 & CB12==2 & CB13==2 & CB14a==2 & CB14b==2
	assert `var'!=. if check==0 & !(CB12==2 & CB13==2 & CB14a==2 & CB14b==2)
} // These can be given zeros now
foreach var of varlist CB15A-CB15X {
	replace `var'=0 if check==0 & CB12==2 & CB13==2 & CB14a==2 & CB14b==2
}
foreach var of varlist CB15A-CB15X {
	assert `var'==1 | `var'==0 | `var'==.a // very few .a
}
drop check

* Can infer that missings for CB16* are 0
foreach var of varlist CB16__1-CB16__96 {
	replace `var'=0 if `var'==.
}
g credit_comm = (CB16__1==1) if CB16__1!=. // commericial bank
	g credit_sc = (CB16__2==1) if CB16__2!=. // savings club
g credit_credi = (CB16__3==1) if CB16__3!=. // credit institution
	g credit_rosca = (CB16__4==1) if CB16__4!=. // ROSCAs
	g credit_mdi = (CB16__5==1) if CB16__5!=. // MDI
	g credit_wf = (CB16__6==1) if CB16__6!=. // Welfare fund
	g credit_sacco = (CB16__7==1) if CB16__7!=. // SACCO
	g credit_ic = (CB16__8==1) if CB16__8!=. // Investment club
	g credit_ngo = (CB16__9==1) if CB16__9!=. // NGO
	g credit_bs = (CB16__10==1) if CB16__10!=. // Burial Society
	g credit_asca = (CB16__11==1) if CB16__11!=. // ASCAs
g credit_mfi = (CB16__12==1) if CB16__12!=. // MFIs
	g credit_vsla = (CB16__13==1) if CB16__13!=. // VSLAs
	g credit_mm = (CB16__14==1) if CB16__14!=. // Mobile Money
	g credit_none = (CB16__97==1) if CB16__97!=.
	g credit_other = (CB16__96==1) if CB16__96!=.

g credre_educ = (CB17==8) if CB17!=.

* Collapse to HHID, taking the max
collapse (max) borrowed credit_comm credit_sc credit_credi credit_rosca credit_mdi credit_wf credit_sacco credit_ic credit_ngo credit_bs credit_asca credit_mfi credit_vsla credit_mm credit_none credit_other credre_educ, by(hhid)

tempfile progress
save `progress'

* Start with cover
use `educ_income', clear
merge 1:1 hhid using `progress'
keep if _merge==1 | _merge==3
drop _merge

* Generate overall variables
g credit_othformal = (credit_credi==1 | ///
						credit_sacco==1 | ///
						credit_ic==1 | ///
						credit_ngo==1 | ///
						credit_bs==1 | ///
						credit_mm==1) if credit_comm!=.
	* Generate a second version of othformal
	g credit_othformal2 = (credit_credi==1 | ///
						credit_sacco==1 | ///
						credit_ic==1 | ///
						credit_ngo==1 | ///
						credit_bs==1) if credit_comm!=.
g credit_mfis = (credit_mdi==1 | ///
					credit_mfi==1) if credit_comm!=.


* Keep certain variables
keep hhid wgt credit_comm credit_othformal credit_othformal2 credit_mfis prim_se_inc sec_se_inc

* Label variables
la var prim_se_inc "Share of income going to primary education"
la var sec_se_inc "Share of income going to secondary education"
la var credit_comm "Has loan with commercial bank"
la var credit_othformal "Has other formal loan (cred, sacc, ic, ngo, bs, mm)"
la var credit_othformal2 "Has other formal loan (cred, sacc, ic, ngo, bs)"
la var credit_mfis "Has a loan with a financial institution"

la def yesno 0 "No" 1 "Yes", modify
foreach var of varlist credit_* {
	la val `var' yesno
}

* Save data
saveold "$lsms_processed/lsms_vars_hh.dta", version(12) replace
