********************************************************************************
** Do file: d10_construct_esvysec_2.do
** First started: April 22, 2020
** Last edited: September 8, 2023

/* Purpose: this do file takes in endline household data from IPA and creates datasets in Stata format that are split into sections. */

********************************************************************************

clear
clear matrix
clear mata
set maxvar 10000

* Define value labels
la def yesno 0 "No" 1 "Yes", modify

**************************************************
**                                              **
**           1. HOUSEHOLD INFORMATION           **
**                                              **
**************************************************

* Call endline dataset
use "$esvy_raw/fenix_clean_pii_20200830_rep.dta", clear
* Keep if consenting
keep if consent_ans==1
* Destring and replace hhid
destring hhid, replace
* Make .r, .d, and .n as missing, as well as other instances of missing/don't know, for numeric
		foreach v of varlist _all {
						capture confirm numeric variable `v'
						if !_rc {
							   replace `v' = . if `v'== .r | `v'==.d | `v'==.n
						}
		}

* Order and ensure uniqueness among hhid.
order hhid
isid hhid
* Clean.
drop consent_ans

* Leave out enumerator info and other variables
keep hhid starttime endtime deviceid date district1 subcounty2 district subcounty_real
order hhid starttime endtime deviceid date district1 subcounty2 district subcounty_real

* Label variables
la var district1 "District from baseline"
la var subcounty2 "Subcounty from baseline"

* Save dataset.
save "$esvy_processed/1_hhinfo.dta", replace



**********************************************************
**                                                      **
**           3. ASSETS AND LAND (LAND PORTION)          **
**                                                      **
**********************************************************

* Call endline data
use "$esvy_raw/fenix_clean_pii_20200830_rep.dta", clear
* Keep if consenting
keep if consent_ans==1
destring hhid, replace

* Some cleaning
replace purch_land = "2" if hhid==1880 | hhid==2554 | hhid==1667
replace sold_land = "0" if hhid==3661

replace purch_land = "-77" if purch_land=="Don't know"
replace sold_land = "-77" if sold_land=="Don't know"

destring purch_land, replace
destring sold_land, replace

la def purch_landla 0 "No" 1 "Purchased" 2 "Rented" -77 "Don't know"
la val purch_land purch_landla

la def sold_landla 0 "No" 1 "Sold" 2 "Rented out" -77 "Don't know"
la val sold_land sold_landla


* Keep and order certain variables
keep hhid confirm_land acres_ownland purch_land pay_newland rent_newland sold_land receive_land acres_rentout rent_land share_land acres_shareland hh_shareland
order hhid confirm_land acres_ownland purch_land pay_newland rent_newland sold_land receive_land acres_rentout rent_land share_land acres_shareland hh_shareland

* Save dataset
save "$esvy_processed/3B_land", replace



*****************************************************
**                                                 **
**           4. FARM AND BUSINESS INCOME           **
**                                                 **
*****************************************************

* Call endline data
use "$esvy_raw/fenix_clean_pii_20200830_rep.dta", clear
* Keep if consenting
keep if consent_ans==1
destring hhid, replace

* This dataset will be geared towards business assets

* Keep and order data
keep hhid more_bus_assets which_bus_assets purch_assets_rpt_1 asset_id1_1 asset_name1_1 num_purch_bus_assets_1 amt_purch_bus_assets_1_1 amt_purch_bus_assets_1_2 amt_purch_bus_assets_1_3 amt_purch_bus_assets_1_4 amt_purch_bus_assets_1_5 amt_purch_bus_assets_1_6 amt_purch_bus_assets_1_7 amt_purch_bus_assets_1_8 amt_purch_bus_assets_1_9 amt_purch_bus_assets_1_10 amt_purch_bus_assets_1_11 amt_purch_bus_assets_1_12 amt_purch_bus_assets_1_13 sell_bus_assets which_sell_assets which_sell_assets which_bus_assets_* asset_id2_1 asset_name2_1 num_sell_bus_assets_1 amt_sell_bus_assets1_1 amt_sell_bus_assets1_2 amt_sell_bus_assets1_3 amt_sell_bus_assets1_4 amt_sell_bus_assets1_5 amt_sell_bus_assets1_6 amt_sell_bus_assets1_7 amt_sell_bus_assets1_8 amt_sell_bus_assets1_9 amt_sell_bus_assets1_10 amt_sell_bus_assets1_11 amt_sell_bus_assets1_12 amt_sell_bus_assets1_13 amt_sell_bus_assets1_14 amt_sell_bus_assets1_15 amt_sell_bus_assets1_16 amt_sell_bus_assets1_17 amt_sell_bus_assets1_18 amt_sell_bus_assets1_19 amt_sell_bus_assets1_20 baseline_business any_business type_business business_asset1 asset_type1 asset_type1_num amt_purch_new_asset1 business_asset2 asset_type2 asset_type2_num amt_purch_new_asset2 business_asset3 asset_type3 asset_type3_num amt_purch_new_asset3 seasonal_newbusiness newbusiness_earn monthnewbusiness_earn newbusiness_normal newbusiness_low newbusiness_high still_farm farm6_earn seasfarm_earn any_farm any_crops earned_crops
order hhid more_bus_assets which_bus_assets purch_assets_rpt_1 asset_id1_1 asset_name1_1 num_purch_bus_assets_1 amt_purch_bus_assets_1_1 amt_purch_bus_assets_1_2 amt_purch_bus_assets_1_3 amt_purch_bus_assets_1_4 amt_purch_bus_assets_1_5 amt_purch_bus_assets_1_6 amt_purch_bus_assets_1_7 amt_purch_bus_assets_1_8 amt_purch_bus_assets_1_9 amt_purch_bus_assets_1_10 amt_purch_bus_assets_1_11 amt_purch_bus_assets_1_12 amt_purch_bus_assets_1_13 sell_bus_assets which_sell_assets which_sell_assets which_bus_assets_* asset_id2_1 asset_name2_1 num_sell_bus_assets_1 amt_sell_bus_assets1_1 amt_sell_bus_assets1_2 amt_sell_bus_assets1_3 amt_sell_bus_assets1_4 amt_sell_bus_assets1_5 amt_sell_bus_assets1_6 amt_sell_bus_assets1_7 amt_sell_bus_assets1_8 amt_sell_bus_assets1_9 amt_sell_bus_assets1_10 amt_sell_bus_assets1_11 amt_sell_bus_assets1_12 amt_sell_bus_assets1_13 amt_sell_bus_assets1_14 amt_sell_bus_assets1_15 amt_sell_bus_assets1_16 amt_sell_bus_assets1_17 amt_sell_bus_assets1_18 amt_sell_bus_assets1_19 amt_sell_bus_assets1_20 baseline_business any_business type_business business_asset1 asset_type1 asset_type1_num amt_purch_new_asset1 business_asset2 asset_type2 asset_type2_num amt_purch_new_asset2 business_asset3 asset_type3 asset_type3_num amt_purch_new_asset3 seasonal_newbusiness newbusiness_earn monthnewbusiness_earn newbusiness_normal newbusiness_low newbusiness_high still_farm farm6_earn seasfarm_earn any_farm any_crops earned_crops

* Label variables
la var which_bus_assets_n_0 "None"
la var which_bus_assets_4 "Bee hive"
la var which_bus_assets_7 "Boat"
la var which_bus_assets_9 "Bottles of Medicine"
la var which_bus_assets_19 "Credit card/point of sale machine"
la var which_bus_assets_24 "Generator"
la var which_bus_assets_26 "Ground Leveling Machine"
la var which_bus_assets_28 "Hot plate/frying pan"
la var which_bus_assets_29 "Ice maker"
la var which_bus_assets_30 "Jack Plane"
la var which_bus_assets_31 "Juice dispensers"
la var which_bus_assets_32 "Kerosene Lamp"
la var which_bus_assets_34 "Lead Battery (350K)"
la var which_bus_assets_39 "Ox cart"
la var which_bus_assets_42 "Plough"
la var which_bus_assets_45 "Pressure Jet Machine"
la var which_bus_assets_47 "Public address system (sound system)"
la var which_bus_assets_51 "Sander"
la var which_bus_assets_52 "Scanning Machine"
la var which_bus_assets_54 "Sphygmomanometer"
la var which_bus_assets_55 "Structure (classroom/schoolhouse/rental/house)"
la var which_bus_assets_60 "Turkeys, chickens, birds"
la var which_bus_assets_61 "TV Decoder"
la var which_bus_assets_62 "Washing Bay"
la var which_bus_assets_63 "Water tank"
la var which_bus_assets_69 "Animal Feeder"
la var which_bus_assets_70 "Pool Table"
la var which_bus_assets_71 "Pots/Pans/Large flasks"
la var which_bus_assets_72 "Cooking Utensils"
la var which_bus_assets_73 "Microwave"
la var which_bus_assets_74 "Inverter"
la var which_bus_assets_75 "Solar Device"
la var which_bus_assets_n "4.0b Which business assets?"

* Drop extraneous variables
drop baseline_business

* Save dataset
save "$esvy_processed/4_busassets", replace

* Manipulate further
egen purch_busass_val = rsum(amt_purch_bus_assets_1_1 amt_purch_bus_assets_1_2 amt_purch_bus_assets_1_3 amt_purch_bus_assets_1_4 amt_purch_bus_assets_1_5 amt_purch_bus_assets_1_6 amt_purch_bus_assets_1_7 amt_purch_bus_assets_1_8 amt_purch_bus_assets_1_9 amt_purch_bus_assets_1_10 amt_purch_bus_assets_1_11 amt_purch_bus_assets_1_12 amt_purch_bus_assets_1_13 amt_purch_new_asset1 amt_purch_new_asset2 amt_purch_new_asset3)

egen sell_busass_val = rsum(amt_sell_bus_assets1_1 amt_sell_bus_assets1_2 amt_sell_bus_assets1_3 amt_sell_bus_assets1_4 amt_sell_bus_assets1_5 amt_sell_bus_assets1_6 amt_sell_bus_assets1_7 amt_sell_bus_assets1_8 amt_sell_bus_assets1_9 amt_sell_bus_assets1_10 amt_sell_bus_assets1_11 amt_sell_bus_assets1_12 amt_sell_bus_assets1_13 amt_sell_bus_assets1_14 amt_sell_bus_assets1_15 amt_sell_bus_assets1_16 amt_sell_bus_assets1_17 amt_sell_bus_assets1_18 amt_sell_bus_assets1_19 amt_sell_bus_assets1_20)

merge 1:1 hhid using "$esvy_clean/3A_assets_hh.dta", keepusing(buy_assets_val sell_assets_val)

* Generate variables
g buy_com_assets = buy_assets_val + purch_busass_val
g sell_com_assets = sell_assets_val + sell_busass_val
g net_com_assets = buy_com_assets - sell_com_assets

* Cap at 99
sum buy_com_assets, det
replace buy_com_assets=`r(p99)' if buy_com_assets > `r(p99)' & buy_com_assets!=.

sum sell_com_assets, det
replace sell_com_assets=`r(p99)' if sell_com_assets > `r(p99)' & sell_com_assets!=.

sum net_com_assets, det
replace net_com_assets=`r(p99)' if net_com_assets >`r(p99)' & net_com_assets!=.
replace net_com_assets=`r(p1)' if net_com_assets <`r(p1)' & net_com_assets!=.

* Note: divide by 3704 to make USD (2019)
replace buy_com_assets = buy_com_assets/3704
replace sell_com_assets = sell_com_assets/3704
replace net_com_assets = net_com_assets/3704

*Do inverse hyperbolic sine transformations on the above
foreach var of varlist buy_com_assets sell_com_assets net_com_assets {
	g ihst_`var' = asinh(`var')
}

* Keep variables
keep hhid buy_com_assets sell_com_assets net_com_assets ihst_buy_com_assets ihst_sell_com_assets ihst_net_com_assets

* Label variables
la var buy_com_assets "USD combined asset purchases value, winsorized at 99th percentile"
la var sell_com_assets "USD combined asset sales value, winsorized at 99th percentile"
la var net_com_assets "USD combined net asset value, winsorized at 1st and 99th percentile"
la var ihst_buy_com_assets "USD combined asset purchases value, winsorized at 99th percentile, IHST"
la var ihst_sell_com_assets "USD combined asset sales value, winsorized at 99th percentile, IHST"
la var ihst_net_com_assets "USD combined net asset value, winsorized at 1st and 99th percentile, IHST"

* Save dataset
save "$esvy_processed/4_comassets_val", replace



**************************************
**                                  **
**           NO SECTION 5           **
**                                  **
**************************************



***********************************************
**                                           **
**           6A. READYPAY LOAN USE           **
**                                           **
***********************************************

* Call endline data
use "$esvy_raw/fenix_clean_pii_20200830_rep.dta", clear
* Keep if consenting
keep if consent_ans==1
destring hhid, replace

* Order several variables
forv x = 1/17 {
	order given_recipient_`x', before(given_amount_`x')
}

order hhid took_sfloan readypay_use readypay_use_0 readypay_use_1 readypay_use_2 readypay_use_3 readypay_use_4 readypay_use_5 readypay_use_6 readypay_use_7 readypay_use_8 readypay_use_9 ///
	readypay_use_10 readypay_use_11 readypay_use_12 readypay_use_13 readypay_use_14 readypay_use_15 readypay_use_* ///
	readypay_basic  readypay_emerg readypay_house readypay_othbus readypay_mybus readypay_medical readypay_loan readypay_rent readypay_land readypay_agric readypay_schfee ///
	readypay_trnspt readypay_oth readypay_intent readypay_orig* refer continue notcontinue notcontinue* ///
	start_savings save_place_1 save_place_2 save_place_3 save_place_4 save_place_5 save_place_6 old_savings_1-amount_saved_11 new_savings num_newsav ///
	r8_count posn_sav_1 location_savings_1 savings_start_mo_1 savings_amount_1 posn_sav_2 location_savings_2 savings_start_mo_2 savings_amount_2 posn_sav_3 location_savings_3 savings_start_mo_3 savings_amount_3 savings_deposit savings_withdrawal savings_total ///
	start_lending ever_given num_given r9_count posn_r9_1 given_recipient_1-given_waiting_17 total_given ///
	start_assistance-otherincome ///
	start_coop baseline_savgrp baseline_numsavgrp any_mobilebank-receive_creditgroup

keep hhid took_sfloan readypay_use readypay_use_0 readypay_use_1 readypay_use_2 readypay_use_3 readypay_use_4 readypay_use_5 readypay_use_6 readypay_use_7 readypay_use_8 readypay_use_9 ///
	readypay_use_10 readypay_use_11 readypay_use_12 readypay_use_13 readypay_use_14 readypay_use_15 readypay_use_* ///
	readypay_basic  readypay_emerg readypay_house readypay_othbus readypay_mybus readypay_medical readypay_loan readypay_rent readypay_land readypay_agric readypay_schfee ///
	readypay_trnspt readypay_oth readypay_intent readypay_orig* refer continue notcontinue notcontinue* ///
	start_savings save_place_1 save_place_2 save_place_3 save_place_4 save_place_5 save_place_6 old_savings_1-amount_saved_11 new_savings num_newsav ///
	r8_count posn_sav_1 location_savings_1 savings_start_mo_1 savings_amount_1 posn_sav_2 location_savings_2 savings_start_mo_2 savings_amount_2 posn_sav_3 location_savings_3 savings_start_mo_3 savings_amount_3 savings_deposit savings_withdrawal savings_total ///
	start_lending ever_given num_given r9_count posn_r9_1 given_recipient_1-given_waiting_17 total_given ///
	start_assistance-otherincome ///
	start_coop baseline_savgrp baseline_numsavgrp any_mobilebank-receive_creditgroup

* Drop extraneous variables
drop start_savings posn_sav_1 posn_sav_2 posn_sav_3 start_lending posn_r9_1 posn_r9_2 posn_r9_3 posn_r9_4 posn_r9_5 posn_r9_6 posn_r9_7 posn_r9_8 posn_r9_9 posn_r9_10 posn_r9_11 posn_r9_12 posn_r9_13 posn_r9_14 posn_r9_15 posn_r9_16 posn_r9_17 start_assistance start_coop

* Label variables
la var took_sfloan "Took loan (from baseline)"
la var readypay_use "6A.0 What did you use the Term 2 ReadyPay School Fee loan for?"
la var readypay_use_2 "Buying non-essentials (luxury or enjoyment)"
la var readypay_use_3 "Ceremony,wedding, bridal price"
la var readypay_use_4 "Church tithe"
la var readypay_use__77 "Don't know"
la var save_place_1 "Savings 1 kept in location(s)"
la var save_place_2 "Savings 2 kept in location(s)"
la var save_place_3 "Savings 3 kept in location(s)"
la var save_place_4 "Savings 4 kept in location(s)"
la var save_place_5 "Savings 5 kept in location(s)"
la var save_place_6 "Savings 6 kept in location(s)"
la var r8_count "Number of new savings places"
la var r9_count "Number of new loans given out"
forv x = 1/17 {
	la var given_recipient_`x' "6.22a To whom did you give loan `x'"
}
la var cal_assistance "9.4 Has anyone in the family benefitted from a cash assistance program run by the government or a non-governmental organization in the last 12 months? (from baseline)"
la var cal_pension "9.5 Has anyone in the household received any pension or life insurance benefits over the past 12 months? (from baseline)"
la var cal_remittance "9.6 Has the household received any remittances or monetary assitance from local sources over the past 12 months? (from baseline)"
la var cal_otherincome "9.7 Has anyone in the household  received any other income from (e.g. inheritance, alimony, scholarship, other unspecified income) in the past 12 months? (from baseline)"
la var baseline_savgrp "10.1 Do you participate in any savings or credit lending/cooperative organizations? E.g. ROSCA, SACCO, VSLAs? (from baseline)"
la var baseline_numsavgrp "10.1z How many groups do you participate in? (from baseline)"

* Define value labels
la def yesno 0 "No" 1 "Yes", modify

foreach var of varlist took_sfloan readypay_use_0 readypay_use_1 readypay_use_2 readypay_use_3 readypay_use_4 readypay_use_5 readypay_use_6 readypay_use_7 readypay_use_8 readypay_use_9 readypay_use_10 readypay_use_11 readypay_use_12 readypay_use_13 readypay_use_14 readypay_use_15 readypay_use__66 readypay_use__99 readypay_use__77 readypay_orig_8 readypay_orig_5 readypay_orig_0 readypay_orig_14 readypay_orig__99 readypay_orig__66 readypay_orig_1 readypay_orig_10 readypay_orig_6 readypay_orig_7 cal_assistance cal_pension cal_remittance cal_otherincome baseline_savgrp {
	la val `var' yesno
}

* Save dataset
save "$esvy_processed/6A_rdypyloanuse", replace


***************************************
**                                   **
**           7. WELL-BEING           **
**                                   **
***************************************

* Call endline data
use "$esvy_raw/fenix_clean_pii_20200830_rep.dta", clear
* Keep if consenting
keep if consent_ans==1
destring hhid, replace

* Keep and order
keep hhid health start_wellbeing worry_health relat worry_relat emerg worry_emerg tribes worry_tribes basic_needs worry_basic other_expense worry_expens educat worry_educat medic worry_medic occup worry_occup idle worry_idle etoh worry_etoh death worry_death debt worry_debt jobloss worry_jobloss crops worry_crops thorough careless reliable disorg lazy motiv efficient follow_thru distracted
order hhid health start_wellbeing worry_health relat worry_relat emerg worry_emerg tribes worry_tribes basic_needs worry_basic other_expense worry_expens educat worry_educat medic worry_medic occup worry_occup idle worry_idle etoh worry_etoh death worry_death debt worry_debt jobloss worry_jobloss crops worry_crops thorough careless reliable disorg lazy motiv efficient follow_thru distracted

* Rename two variables for easier looping
ren basic_needs basic
ren other_expense expens

* Drop extraneous variables
drop start_wellbeing

		* Make .r, .d, and .n as missing
		foreach v of varlist _all {
						capture confirm numeric variable `v'
						if !_rc {
							   replace `v' = . if `v'== .r | `v'==.d | `v'==.n
						}
		}

		foreach v of varlist _all {
						capture confirm numeric variable `v'
						if !_rc {
		replace `v' = . if `v' ==77 | (`v'>76 & `v'<78) | ///
							   `v' == -77 | (`v'>-78 & `v'<-76) | ///
							   `v'==99 | (`v'>98 & `v'<100) | ///
							   `v'==-99 | (`v'>-100 & `v'<-98) | ///
							   `v' == .77 | (`v'>.76 & `v'<.78) | ///
							   `v' == -.77 | (`v'>-.78 & `v'<-.76) | ///
							   `v' == .99 | (`v'>.98 & `v'<1) | ///
							   `v' == -.99 | (`v'>-.98 & `v'<-1)
						}
		}

* Save dataset
save "$esvy_processed/7_wellbeing", replace

/*
Make some shock variables conditional
Also note the categories: where A = problem with money, B = money matters for coping, and C = money doesn't help

(1) B: health - health problems or illness: none
(2) C: relat - problems at home with relatives: *** not single HH
(3) B: emerg - accident or disaster: none
(4) C: tribes - problems with people in other tribes: none
(5) A: basic - not having enough money for basic needs: none
(6) A: expens - not having enough money for other living expenses: none
(7) A: educat - unable to educate all of your children: *** school aged >=5 & <=20
(8) A: medic - not having enough mone for medicine: none
(9) B: occup - difficulty finding work: none
(10) C: idle - idleness of children or spouse: *** have age <= 20 or spouse
(11) C: etoh - alcohol consumption of children or spouse: *** have age <= 20 or spouse
(12) B: death - death of a family member: none
(13) A: debt - debts owed to others: none
(14) B: jobloss - job loss: *** someone in HH works wage
(15) B: crops - weather affecting crops: *** owns farm or grows crops
*/

	* First, grab some information from baseline
	* relat
	use "$bsvy_clean/2_roster", clear
	g count = 1
	bys hhid: egen for_relat_cond = total(count)
	g relat_cond = (for_relat_cond!=1)
	* educat
	g for_educat_cond = (age>=5 & age<=20)
	bys hhid: egen educat_cond = max(for_educat_cond)
	* idle
	g for_idle_cond = (relation==5 | relation==17)
	bys hhid: egen idle_cond = max(for_idle_cond)
	* etoh
	g for_etoh_cond = (relation==5 | relation==17)
	bys hhid: egen etoh_cond = max(for_etoh_cond)
	* jobloss
	g for_jobloss_cond = (hmem_works_out==1)
	bys hhid: egen jobloss_cond = max(for_jobloss_cond)
	duplicates drop hhid, force
	* Merge in some more info
	merge 1:1 hhid using "$bsvy_clean/9_hhincome", keepusing(any_farm any_crops)
	keep if _merge==3
	g crops_cond = (any_farm==1 | any_crops==1)


	keep hhid relat_cond educat_cond idle_cond etoh_cond jobloss_cond crops_cond

	tempfile baselineinfo
	save `baselineinfo'


* Call dataset again
use "$esvy_processed/7_wellbeing", clear
merge 1:1 hhid using `baselineinfo' // not note all make the merge
keep if _merge==1 | _merge==3
drop _merge

* Making missing the shock/scale variables for instances where the condition is not fulfilled
replace relat = . if relat_cond!=1
replace worry_relat = . if relat_cond!=1

replace educat = . if educat_cond!=1
replace worry_educat = . if educat_cond!=1

replace idle = . if idle_cond!=1
replace worry_idle = . if idle_cond!=1

replace etoh = . if etoh_cond!=1
replace worry_etoh = . if etoh_cond!=1

replace jobloss = . if jobloss_cond!=1
replace worry_jobloss = . if jobloss_cond!=1

replace crops = . if crops_cond!=1
replace worry_jobloss = . if crops_cond!=1


* For shock index: create first a proportion of shocks of type A/B/C experienced
local all_A = "basic expens educat medic debt"
g shock_tot_A = 0
g shock_tot_A_numerator = 0
foreach x of local all_A {
	replace shock_tot_A = 1 + shock_tot_A if `x'!=.
	replace shock_tot_A_numerator = 1 + shock_tot_A_numerator if `x'==1
}
g shockAindex = shock_tot_A_numerator/shock_tot_A
drop shock_tot_A_numerator shock_tot_A

local all_B = "health emerg occup death jobloss crops"
g shock_tot_B = 0
g shock_tot_B_numerator = 0
foreach x of local all_B {
	replace shock_tot_B = 1 + shock_tot_B if `x'!=.
	replace shock_tot_B_numerator = 1 + shock_tot_B_numerator if `x'==1
}
g shockBindex = shock_tot_B_numerator/shock_tot_B
drop shock_tot_B_numerator shock_tot_B

local all_C = "relat tribes idle etoh"
g shock_tot_C = 0
g shock_tot_C_numerator = 0
foreach x of local all_C {
	replace shock_tot_C = 1 + shock_tot_C if `x'!=.
	replace shock_tot_C_numerator = 1 + shock_tot_C_numerator if `x'==1
}
g shockCindex = shock_tot_C_numerator/shock_tot_C
drop shock_tot_C_numerator shock_tot_C

* Make values for scale from 0 to 1
local shocklabels = "health relat emerg tribes basic expens educat medic occup idle etoh death debt jobloss crops"
foreach x of local shocklabels {
	g worry_`x'_01 = .
	replace worry_`x'_01 = 0 if worry_`x' == 1
	replace worry_`x'_01 = 1/3 if worry_`x' == 2
	replace worry_`x'_01 = 2/3 if worry_`x' == 3
	replace worry_`x'_01 = 1 if worry_`x' == 4
}

* For scale index: create average worrying scale that averages across shocks
local all_A = "worry_basic_01 worry_expens_01 worry_educat_01 worry_medic_01 worry_debt_01"
g scale_tot_A = 0
egen scale_tot_A_numerator = rsum(worry_basic_01 worry_expens_01 worry_educat_01 worry_medic_01 worry_debt_01)
foreach x of local all_A {
	replace scale_tot_A = 1 + scale_tot_A if `x'!=.
}
g scaleAindex = scale_tot_A_numerator/scale_tot_A
drop scale_tot_A_numerator scale_tot_A

local all_B = "worry_health_01 worry_emerg_01 worry_occup_01 worry_death_01 worry_jobloss_01 worry_crops_01"
g scale_tot_B = 0
egen scale_tot_B_numerator = rsum(worry_health_01 worry_emerg_01 worry_occup_01 worry_death_01 worry_jobloss_01 worry_crops_01)
foreach x of local all_B {
	replace scale_tot_B = 1 + scale_tot_B if `x'!=.
}
g scaleBindex = scale_tot_B_numerator/scale_tot_B
drop scale_tot_B_numerator scale_tot_B

local all_C = "worry_relat_01 worry_tribes_01 worry_idle_01 worry_etoh_01"
g scale_tot_C = 0
egen scale_tot_C_numerator = rsum(worry_relat_01 worry_tribes_01 worry_idle_01 worry_etoh_01)
foreach x of local all_C {
	replace scale_tot_C = 1 + scale_tot_C if `x'!=.
}
g scaleCindex = scale_tot_C_numerator/scale_tot_C
drop scale_tot_C_numerator scale_tot_C

* Drop extraneous variables
drop worry_health_01-worry_crops_01

* Label variables
la var relat_cond "More than 1 person in household (condition for househould question)"
la var educat_cond "Had children between ages of 5 to 20 in household (condition for educ qn)"
la var idle_cond "Has children or spouse (condition for idle question)"
la var etoh_cond "Has children or spouse (condition for alcohol cons question)"
la var jobloss_cond "Works wage job (condition for job loss question)"
la var crops_cond "Grows crops (condition for crops qn)"
la var shockAindex "Proportion of shocks experienced in past 6 months related to problems with money (cat A)"
la var shockBindex "Proportion of shocks experienced in past 6 months related to problems where money matters for coping (cat B)"
la var shockCindex "Proportion of shocks experienced in past 6 months related to problems where money doesn't help (cat C)"
la var scaleAindex "Index of worry about cat A shocks"
la var scaleBindex "Index of worry about cat B shocks"
la var scaleCindex "Index of worry about cat C shocks"

* Label var
foreach var of varlist relat_cond educat_cond idle_cond etoh_cond jobloss_cond crops_cond {
	la val `var' yesno
}

* Save dataset
save "$esvy_processed/7_wellbeing_hh", replace



***********************************************
**                                           **
**           8. SOLAR HOME SYSTEMS           **
**                                           **
***********************************************


**********************************************
**                                          **
**           9. LOCKED OCCURENCES           **
**                                          **
**********************************************

* Load data
use "$esvy_raw/fenix_clean_pii_20200830_rep.dta", clear
keep if consent_ans==1
destring hhid, replace

keep hhid neighbors w_neighbors day_1000 day_2000 day_3000 day_4000 day_5000 week_10000 week_14000 week_20000 week_24000 week_29000
		* Make .r, .d, and .n as missing
		foreach v of varlist _all {
						capture confirm numeric variable `v'
						if !_rc {
							   replace `v' = . if `v'== .r | `v'==.d | `v'==.n
						}
		}

* Save dataset
save "$esvy_processed/9_lockedoccurences", replace

**********************************************

* Create version that manipulates
g w_neighbors_01 = .
replace w_neighbors_01 = 0 if w_neighbors==1
replace w_neighbors_01 = 1/3 if w_neighbors==2
replace w_neighbors_01 = 2/3 if w_neighbors==3
replace w_neighbors_01 = 1 if w_neighbors==4

g wtpday = .
replace wtpday=0 if day_1000==0
replace wtpday=1000 if day_1000==1
replace wtpday=2000 if day_2000==1
replace wtpday=3000 if day_3000==1
replace wtpday=4000 if day_4000==1
replace wtpday=5000 if day_5000==1

g wtpweek = .
replace wtpweek=0 if week_10000==0
replace wtpweek=10000 if week_10000==1
replace wtpweek=14000 if week_14000==1
replace wtpweek=20000 if week_20000==1
replace wtpweek=24000 if week_24000==1
replace wtpweek=29000 if week_29000==1

la var w_neighbors_01 "Worried about neighbors transformed to 0 to 1 range"
la var wtpday "WTP to use SHS for one locked day"
la var wtpweek "WTP to use SHS for one locked week"

* Save dataset
save "$esvy_processed/9_lockedoccurences_hh", replace
