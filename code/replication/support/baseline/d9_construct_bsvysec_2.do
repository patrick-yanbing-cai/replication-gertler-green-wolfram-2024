********************************************************************************
** Do file: d9_construct_bsvysec_2.do
** First started: September 05, 2019
** Last edited: September 8, 2023

/* Purpose: this do file takes in baseline household data from IPA and creates datasets in Stata format that are split into sections. */

********************************************************************************

clear
clear matrix
clear mata
set maxvar 10000

* Define value labels
la def yesno 0 "No" 1 "Yes", modify

* Note: In the missing definition, .r = Refused, .d = don't know, and .n = not applicable

***********************************
**                               **
**           4. ENERGY           **
**                               **
***********************************

* Call baseline dataset.
use "$bsvy_raw/fenix_clean2_rep.dta", clear
* Drop several HH that aren't part of the actual sampling framework
drop if hhid==1354 | hhid==1536 | hhid==3109 | hhid==9999 | hhid==9997
* Make .r, .d, and .n as missing, a normal .
foreach v of varlist _all {
	capture confirm numeric variable `v'
	if !_rc {
		replace `v' = . if `v'== .r | `v'==.d | `v'==.n
	}
}

* Keep if consenting.
keep if consent_ans==1

* Missing one value for difficult times
g light_difficult_times_18=(light_difficult_times=="18")

* Order and keep certain variables
order hhid energy_importance light_home light_home* light_work light_most light_sec light_third light_fourth light_fifth light_difficult_times light_difficult_times* phone_source phone_source_* phone_source2 radio_ownership ///
	light_spend light_spend_period spend_collect light_spend_difficult light_spend_difficult_period phone_spend phone_spend_period phone_spend_difficult phone_spend_difficult_period radio_spend radio_spend_period energy_spend_method energy_spend_method* preferred_source ///
	connected_national connected_local connect_work howlong any_blkout length_blkout regular_blkout satisfied_connect
keep hhid energy_importance light_home light_home* light_work light_most light_sec light_third light_fourth light_fifth light_difficult_times light_difficult_times* phone_source phone_source_* phone_source2 radio_ownership ///
	light_spend light_spend_period spend_collect light_spend_difficult light_spend_difficult_period phone_spend phone_spend_period phone_spend_difficult phone_spend_difficult_period radio_spend radio_spend_period energy_spend_method energy_spend_method* preferred_source ///
	connected_national connected_local connect_work howlong any_blkout length_blkout regular_blkout satisfied_connect

order light_home__99, after(light_home_21)

* Label a few variables.
la var light_difficult_times_18 "Pressure lamp"
la var howlong "4.18a How long has the electricity connection not been working?"

* Save dataset
save "$bsvy_processed/4_energy.dta", replace

* Flip scale for energy_importance
recode energy_importance (1=4)(2=3)(3=2)(4=1), gen(energy_importance2)
drop energy_importance

* Generate versions of variables that go out to a year.
local ens "light_spend light_spend_difficult phone_spend phone_spend_difficult radio_spend"

foreach var of local ens {
	g `var'_year=.
	replace `var'_year=0 if `var'==0
	replace `var'_year=`var'*365 if `var'_period==1
	replace `var'_year=`var'*365/2 if `var'_period==2
	replace `var'_year=`var'*365/3 if `var'_period==3
	replace `var'_year=`var'*365/4 if `var'_period==4
	replace `var'_year=`var'*365/5 if `var'_period==5
	replace `var'_year=`var'*365/6 if `var'_period==6
	replace `var'_year=`var'*52*2 if `var'_period==7
	replace `var'_year=`var'*52 if `var'_period==8
	replace `var'_year=`var'*26 if `var'_period==9
	replace `var'_year=`var'*12*2 if `var'_period==10
	replace `var'_year=`var'*12*4 if `var'_period==11
	replace `var'_year=`var'*12*5 if `var'_period==12
	replace `var'_year=`var'*12 if `var'_period==13
	replace `var'_year=`var' if `var'_period==14

	sum `var'_year, det
	replace `var'_year=`r(p99)' if `var'_year >`r(p99)' & (`var'_year!=. & `var'_year!=.d & `var'_year!=.r & `var'_year!=.n)
}
replace radio_spend_year=0 if radio_ownership==0 | radio_ownership==2 | radio_ownership==3
* Generate variable for connected to national or connected grid
g connected_natloc = (connected_national==1 | connected_local==1)
replace connect_work = 0 if connected_national==0 | connected_local==0

* Drop extraneous variables
drop light_spend light_spend_period light_spend_difficult light_spend_difficult_period phone_spend phone_spend_period phone_spend_difficult phone_spend_difficult_period radio_spend radio_spend_period connected_local

* Order
order connected_natloc, after(connected_national)

* Renaming variables
ren light_home_0 light_home_noother
ren light_home_1 light_home_biofuel
ren light_home_2 light_home_candles
ren light_home_4 light_home_firewood
ren light_home_5 light_home_kerosene
ren light_home_6 light_home_lbatt
ren light_home_7 light_home_lsolar
ren light_home_8 light_home_locogrid
ren light_home_9 light_home_natgrid
ren light_home_10 light_home_neighgen
ren light_home_11 light_home_owngen
ren light_home_12 light_home_ssolamp
ren light_home_13 light_home_ssolar
ren light_home_14 light_home_torch
ren light_home_15 light_home_phone
ren light_home_16 light_home_tadooba
ren light_home_17 light_home_lantern
ren light_home_18 light_home_plamp
ren light_home_19 light_home_cbbatt
ren light_home_20 light_home_battwire
ren light_home_21 light_home_inverter

ren light_difficult_times_0 light_diff_times_noother
ren light_difficult_times_1 light_diff_times_biofuel
ren light_difficult_times_2 light_diff_times_candles
ren light_difficult_times_4 light_diff_times_firewood
ren light_difficult_times_5 light_diff_times_kerosene
ren light_difficult_times_6 light_diff_times_lbatt
ren light_difficult_times_7 light_diff_times_lsolar
ren light_difficult_times_8 light_diff_times_locogrid
ren light_difficult_times_9 light_diff_times_natgrid
ren light_difficult_times_10 light_diff_times_neighgen
ren light_difficult_times_11 light_diff_times_owngen
ren light_difficult_times_12 light_diff_times_ssolamp
ren light_difficult_times_13 light_diff_times_ssolar
ren light_difficult_times_14 light_diff_times_torch
ren light_difficult_times_15 light_diff_times_phone
ren light_difficult_times_16 light_diff_times_tadooba
ren light_difficult_times_17 light_diff_times_lantern
ren light_difficult_times_19 light_diff_times_cbbatt
ren light_difficult_times_20 light_diff_times_battwire

ren phone_source_1 phone_charge_lsolar
ren phone_source_2 phone_charge_ssolar
ren phone_source_3 phone_charge_battbun
ren phone_source_4 phone_charge_fee
ren phone_source_5 phone_charge_free
ren phone_source_6 phone_charge_natgrid

ren energy_spend_method_1 pay_energy_cash
ren energy_spend_method_2 pay_energy_mm
ren energy_spend_method_3 pay_energy_incl_rent
ren energy_spend_method_4 pay_energy_dontpay
ren energy_spend_method_5 pay_energy_payway
ren energy_spend_method_6 pay_energy_dk
ren energy_spend_method_7 pay_energy_nolonger
ren energy_spend_method_8 pay_energy_salary
ren energy_spend_method__77 pay_energy_dk77

* Drop additional variables that are extraneous.
drop light_home light_difficult_times phone_source energy_spend_method light_home__99 phone_source__99 phone_source__88 energy_spend_method__99

* Define value labels
la def yesno 0 "No" 1 "Yes", modify

* Value labels.
foreach var of varlist light_home_noother-light_home_inverter light_diff_times_noother-phone_charge_natgrid pay_energy_cash-pay_energy_salary pay_energy_dk77 connected_natloc {
	la val `var' yesno
}

* Take care of outliers.
foreach var of varlist spend_collect light_spend_year light_spend_difficult_year phone_spend_year phone_spend_difficult_year radio_spend_year {
	sum `var', det
	replace `var'=`r(p99)' if `var' >`r(p99)' & (`var'!=. & `var'!=.d & `var'!=.r & `var'!=.n)
}

* Log several of expenditure variables.
foreach var of varlist spend_collect light_spend_year light_spend_difficult_year phone_spend_year phone_spend_difficult_year radio_spend_year {
	g l_`var' = log(`var')
}

* Make IHST versions of expenditure variables.
foreach var of varlist spend_collect light_spend_year light_spend_difficult_year phone_spend_year phone_spend_difficult_year radio_spend_year {
	g ihst_`var' = asinh(`var')
}

* Labeling variables.
la var light_home_biofuel "Biofuel used for home lighting (=1)"
la var light_home_candles "Candles used for home lighting (=1)"
la var light_home_firewood "Firewood used for home lighting (=1)"
la var light_home_kerosene "Kerosene used for home lighting (=1)"
la var light_home_lbatt "Large battery used for home lighting (=1)"
la var light_home_lsolar "Large solar system used for home lighting (=1)"
la var light_home_locogrid "Local, community grid used for home lighting (=1)"
la var light_home_natgrid "National grid used for home lighting (=1)"
la var light_home_neighgen "Neighbor generator used for home lighting (=1)"
la var light_home_owngen "Own generator used for home lighting (=1)"
la var light_home_ssolamp "Small solar lamp used for home lighting (=1)"
la var light_home_ssolar "Small solar system used for home lighting (=1)"
la var light_home_torch "Torches used for home lighting (=1)"
la var light_home_phone "Phone used for home lighting (=1)"
la var light_home_tadooba "Tadooba used for home lighting (=1)"
la var light_home_lantern "Lantern used for home lighting (=1)"
la var light_home_plamp "Pressure lamp used for home lighting (=1)"
la var light_home_cbbatt "Car or boda battery used for home lighting (=1)"
la var light_home_battwire "Battery connected to wire used for home lighting (=1)"
la var light_home_inverter "Inverter used for home lighting (=1)"

la var light_diff_times_biofuel "Biofuel used for lighting during difficult times (=1)"
la var light_diff_times_candles "Candles used for lighting during difficult times (=1)"
la var light_diff_times_firewood "Firewood used for lighting during difficult times (=1)"
la var light_diff_times_kerosene "Kerosene used for lighting during difficult times (=1)"
la var light_diff_times_lbatt "Large battery used for lighting during difficult times (=1)"
la var light_diff_times_lsolar "Large solar system used for lighting during difficult times (=1)"
la var light_diff_times_locogrid "Local, community grid used for lighting during difficult times (=1)"
la var light_diff_times_natgrid "National grid used for lighting during difficult times (=1)"
la var light_diff_times_neighgen "Neighbor generator used for lighting during difficult times (=1)"
la var light_diff_times_owngen "Own generator used for lighting during difficult times (=1)"
la var light_diff_times_ssolamp "Small solar lamp used for lighting during difficult times (=1)"
la var light_diff_times_ssolar "Small solar system used for lighting during difficult times (=1)"
la var light_diff_times_torch "Torches used for lighting during difficult times (=1)"
la var light_diff_times_phone "Phone used for lighting during difficult times (=1)"
la var light_diff_times_tadooba "Tadooba used for lighting during difficult times (=1)"
la var light_diff_times_lantern "Lantern used for lighting during difficult times (=1)"
la var light_diff_times_cbbatt "Car or boda battery used for lighting during difficult times (=1)"
la var light_diff_times_battwire "Battery connected to wire used for lighting during difficult times (=1)"

la var phone_charge_lsolar "Charged phones via large solar system (=1)"
la var phone_charge_ssolar "Charged phones via small solar system (=1)"
la var phone_charge_battbun "Charged phones via battery cell bundled (=1)"
la var phone_charge_fee "Charged phones via fee outside HH (=1)"
la var phone_charge_free "Charged phones via for free outside HH (=1)"
la var phone_charge_natgrid "Charged phones via national grid (=1)"

la var pay_energy_cash "Pay for energy via cash (=1)"
la var pay_energy_mm "Pay for energy via mobile money (=1)"
la var pay_energy_incl_rent "Pay for energy included in rent(=1)"
la var pay_energy_dontpay "Does not pay for energy (=1)"
la var pay_energy_payway "Pay for energy via payway (=1)"
la var pay_energy_dk "Doesn't know who pays for energy (=1)"
la var pay_energy_nolonger "No longer paying for energy (=1)"
la var pay_energy_salary "Pay for energy via deductions from salary (=1)"
la var pay_energy_dk77 "Don't know about paying for energy (=1)"

la var connected_natloc "Connected to either national or local community grid"

la var light_spend_year "Amount spent on lighting across both home and workplace in a year"
la var light_spend_difficult_year "Amount spent on lighting during difficult times in a year"
la var phone_spend_year "Amount spent to charge all phones in HH in a year"
la var phone_spend_difficult_year "Amount spent to charge all phones in HH during difficult times in a year"
la var radio_spend_year "Amount spent on battery cells for radio in a year"

la var energy_importance2 "How important do you consider energy in your daily expenses?"
la def energy_importance2_la 1 "Not important whatsoever" 2 "Not very important" 3 "Slightly important" 4 "Very important"
la val energy_importance2 energy_importance2_la

la var l_spend_collect "Additional money to collect/acquire... (logged)"
la var l_light_spend_year "Amount spent on lighting across both home and workplace in a year (logged)"
la var l_light_spend_difficult_year "Amount spent on lighting during difficult times in a year (logged)"
la var l_phone_spend_year "Amount spent to charge all phones in HH in a year (logged)"
la var l_phone_spend_difficult_year "Amount spent to charge all phones in HH during difficult times in a year (logged)"
la var l_radio_spend_year "Amount spent on battery cells for radio in a year (logged)"

la var ihst_spend_collect "Additional money to collect/acquire... (IHST)"
la var ihst_light_spend_year "Amount spent on lighting across both home and workplace in a year (IHST)"
la var ihst_light_spend_difficult_year "Amount spent on lighting during difficult times in a year (IHST)"
la var ihst_phone_spend_year "Amount spent to charge all phones in HH in a year (IHST)"
la var ihst_phone_spend_difficult_year "Amount spent to charge all phones in HH during difficult times in a year (IHST)"
la var ihst_radio_spend_year "Amount spent on battery cells for radio in a year (IHST)"

* Save dataset
save "$bsvy_processed/4_energy_hh.dta", replace


***********************************************
**                                           **
**           5. SOLAR HOME SYSTEMS           **
**                                           **
***********************************************

* Call baseline dataset.
use "$bsvy_raw/fenix_clean2_rep.dta", clear
* Drop several HH that aren't part of the actual sampling framework
drop if hhid==1354 | hhid==1536 | hhid==3109 | hhid==9999 | hhid==9997
* Make .r, .d, and .n as missing, a normal .
foreach v of varlist _all {
	capture confirm numeric variable `v'
	if !_rc {
		replace `v' = . if `v'== .r | `v'==.d | `v'==.n
	}
}

* Keep if consenting.
keep if consent_ans==1

* Order variables.
order useful_shs_6, after(useful_shs_5)
order hhid num_solar daysuse_shs stop_shs use_night start_night stop_night use_day start_day stop_day useful_shs* hrs_use_shs hrs_power_shs pay_self else_pay access_agent agent_reliable min_transfer min_amount mpoint_walk mpoint_cost extra_mmfee amount_mmfee how_readypay whynot_selfpay payment_issue* always_pay schedule_pay* dist_servcent
order payment_issue__99, after(payment_issue__88)
order schedule_pay__99, after(schedule_pay__77)

* Keep certain variables.
keep hhid num_solar daysuse_shs stop_shs use_night start_night stop_night use_day start_day stop_day useful_shs* hrs_use_shs hrs_power_shs pay_self else_pay access_agent agent_reliable min_transfer min_amount mpoint_walk mpoint_cost extra_mmfee amount_mmfee how_readypay whynot_selfpay payment_issue* always_pay schedule_pay* dist_servcent

* Label variable.
la var whynot_selfpay "5.12a Why aren't you making payments with your own phone?"

* Save dataset
save "$bsvy_processed/5_shs.dta", replace

* recode always_pay
recode always_pay (1=4)(2=3)(3=2)(4=1), gen(always_pay2)
drop always_pay
la def always_pay2la 1 "No, hardly ever" 2 "No, only sometimes" 3 "Yes, most of the time" 4 "Yes, always"
la val always_pay2 always_pay2la

* Leave else_pay alone

* Using start_night stop_night start_day stop_day later to make a time variable.
g use_night2 = use_night
replace use_night2 = 0 if daysuse_shs==0
order use_night2, before(start_night)
g use_day2 = use_day
replace use_day2 = 0 if daysuse_shs==0
order use_day2, before(start_day)
tostring start_night, gen(start_night_min)
tostring stop_night, gen(stop_night_min)
destring start_night_min, replace
destring stop_night_min, replace
* Transform above to minutes.
replace start_night_min = start_night_min/(1000*60)
replace stop_night_min = stop_night_min/(1000*60)
* Take into account that the stop night minute variable could have gone into the next day and "reset."
replace stop_night_min = stop_night_min + 24*60 if stop_night_min < start_night_min & stop_night_min!=. & start_night_min!=.
g night_diff = stop_night_min - start_night_min
order night_diff, after(stop_night_min)
drop start_night_min stop_night_min
tostring start_day, gen(start_day_min)
tostring stop_day, gen(stop_day_min)
destring start_day_min, replace
destring stop_day_min, replace
* Transform above to minutes
replace start_day_min = start_day_min/(1000*60)
replace stop_day_min = stop_day_min/(1000*60)
* Take into account that the stop day minute variable could have gone into the next day and "reset"
replace stop_day_min = stop_day_min + 24*60 if stop_day_min < start_day_min & stop_day_min!=. & start_day_min!=.
g day_diff = stop_day_min - start_day_min
order day_diff, after(stop_day_min)
drop start_day_min stop_day_min

* Rename
ren useful_shs_1 shs_use_light_home
ren useful_shs_2 shs_use_light_bus
ren useful_shs_3 shs_use_cook
ren useful_shs_4 shs_use_hh_access
ren useful_shs_5 shs_use_enertainm
ren useful_shs_6 shs_use_donot

ren payment_issue_0 pay_issue_never // never problem
ren payment_issue_1 pay_issue_mmt // mobile money tax
ren payment_issue_2 pay_issue_network // network issue
ren payment_issue_3 pay_issue_diffnetw // money on diff network
ren payment_issue_4 pay_issue_forgotpin // forgot pin
ren payment_issue_5 pay_issue_nomtnair // no mtn or airtel
ren payment_issue_6 pay_issue_lackfunds // lacked funds
ren payment_issue_7 pay_issue_agentnm // agent lacked money
ren payment_issue_8 pay_issue_codes // issue or delay
ren payment_issue_9 pay_issue_point // distance from mobile point
ren payment_issue_10 pay_issue_complain // cs complaint
ren payment_issue_11 pay_issue_wdepos // wrong account deposited
ren payment_issue_12 pay_issue_forgot // forgot
ren payment_issue_13 pay_issue_broken // broken SHS

ren schedule_pay_1 sched_pay_sms
ren schedule_pay_2 sched_pay_locked
ren schedule_pay_3 sched_pay_keeptrack
ren schedule_pay_4 sched_pay_famremind
ren schedule_pay_5 sched_pay_paidfull

* Drop several variables.
drop useful_shs payment_issue payment_issue__88 payment_issue__99 schedule_pay schedule_pay__99

* Define value labels
la def yesno 0 "No" 1 "Yes", modify

* Value labels.
foreach var of varlist use_night2 use_day2 shs_use_light_home-useful_shs__99 pay_issue_never-pay_issue_broken sched_pay_sms-schedule_pay__77  {
	la val `var' yesno
}

* Take care of outliers.
foreach var of varlist dist_servcent min_amount mpoint_cost amount_mmfee {
	sum `var', det
	replace `var'=`r(p99)' if `var' >`r(p99)' & (`var'!=. & `var'!=.d & `var'!=.r & `var'!=.n)
}

* Log several of the expenditure variables.
foreach var of varlist dist_servcent min_amount mpoint_cost amount_mmfee {
	g l_`var' = log(`var')
}

* Make IHST versions of the expenditure variables.
foreach var of varlist dist_servcent min_amount mpoint_cost amount_mmfee {
	g ihst_`var' = asinh(`var')
}

* Label variables.
la var shs_use_light_home "Use SHS for lighting home (=1)"
la var shs_use_light_bus "Use SHS for lighting business (=1)"
la var shs_use_cook "Use SHS for cooking (=1)"
la var shs_use_hh_access "Use SHS to charge hh accessories (=1)"
la var shs_use_enertainm "Use SHS for entertainment (=1)"
la var shs_use_donot "Do not currently use or have SHS (=1)"

la var pay_issue_never "Never had payment issues (=1)"
la var pay_issue_mmt "Payment issue with mobile money tax (=1)"
la var pay_issue_network "Payment issue from network issue (=1)"
la var pay_issue_diffnetw "Payment issue with money on different network (=1)"
la var pay_issue_forgotpin "Payment issue with forgetting PIN (=1)"
la var pay_issue_nomtnair "Payment issue with not having MTN or Airtel (=1)"
la var pay_issue_lackfunds "Payment issue with lacking funds (=1)"
la var pay_issue_agentnm "Payment issue with agent lacking money (=1)"
la var pay_issue_codes "Payment issue with issue or delay in receiving codes (=1)"
la var pay_issue_point "Payment issue with distance from mobile point (=1)"
la var pay_issue_complain "Payment issue with customer service complaint (=1)"
la var pay_issue_wdepos "Payment issue with depositing money to wrong number or account (=1)"
la var pay_issue_forgot "Payment issue with forgetting how to pay (=1)"
la var pay_issue_broken "Payment issue with broken SHS (=1)"

la var sched_pay_sms "Knows to make payment through SMS (=1)"
la var sched_pay_locked "Knows to make payment by being locked (=1)"
la var sched_pay_keeptrack "Knows to make payment by keeping track of payment (=1)"
la var sched_pay_famremind "Knows to make payment by family reminder (=1)"
la var sched_pay_paidfull "Paid in full at time of purchase (=1)"

la var use_night2 "Did you use a SHS last night (=1)"
la var use_day2 "Did you use a SHS during daytime yesterday (=1)"
la var night_diff "Minutes SHS used last night"
la var day_diff "Minutes SHS used during daytime yesterday"

la var l_dist_servcent "How long it takes to travel to the nearest ReadyPay service center (logged)"
la var l_min_amount "Starting from how much (logged)"
la var l_mpoint_cost "Cost to go to MM agent (to and from) (logged)"
la var l_amount_mmfee "How much is that extra fee (logged)"

la var ihst_dist_servcent "How long it takes to travel to the nearest ReadyPay service center (logged)"
la var ihst_min_amount "Starting from how much (IHST)"
la var ihst_mpoint_cost "Cost to go to MM agent (to and from) (IHST)"
la var ihst_amount_mmfee "How much is that extra fee (IHST)"

* Save dataset
save "$bsvy_processed/5_shs_hh.dta", replace



*******************************************
**                                       **
**           6. SOLAR LANTERNS           **
**                                       **
*******************************************

* Call baseline dataset.
use "$bsvy_raw/fenix_clean2_rep.dta", clear
* Drop several HH that aren't part of the actual sampling framework
drop if hhid==1354 | hhid==1536 | hhid==3109 | hhid==9999 | hhid==9997
* Make .r, .d, and .n as missing, a normal .
foreach v of varlist _all {
	capture confirm numeric variable `v'
	if !_rc {
	   replace `v' = . if `v'== .r | `v'==.d | `v'==.n
	}
}

* Keep if consent
keep if consent_ans==1

* Order and keep variables.
order hhid any_lantern num_lantern own_lantern costown_lantern costrent_lantern costhirepurch_lantern chargemob_lantern
keep hhid any_lantern num_lantern own_lantern costown_lantern costrent_lantern costhirepurch_lantern chargemob_lantern

* Save dataset
save "$bsvy_processed/6_solarlantern.dta", replace

* Focus on a version that is just a subset, constructed, for RHS
replace num_lantern = 0 if any_lantern==0
g own_lantern2 = (own_lantern==1)
order own_lantern2, after(own_lantern)
replace costown_lantern = 0 if any_lantern==0
g costown_lantern2 = costown_lantern
la var costown_lantern2 "Amt paid to own a solar lantern"

* Take care of outliers
sum costown_lantern, det
replace costown_lantern=`r(p99)' if costown_lantern >`r(p99)' & (costown_lantern!=. & costown_lantern!=.d & costown_lantern!=.r)

* Log variables
foreach var of varlist costown_lantern2 {
	g l_`var' = log(`var')
}

* IHST variables
foreach var of varlist costown_lantern2 {
	g ihst_`var' = asinh(`var')
}

* Label variables
la var own_lantern2 "Owns a lantern"
la var l_costown_lantern2 "Amt paid to own a solar lantern (logged)"
la var ihst_costown_lantern2 "Amt paid to own a solar lantern (IHST)"

* Define value labels
la def yesno 0 "No" 1 "Yes", modify

* Give yesno label
la val  own_lantern2 yesno

* Save dataset
save "$bsvy_processed/6_solarlantern_hh.dta", replace



****************************************************
**                                                **
**           7. LAND AND HOME OWNERSHIP           **
**                                                **
****************************************************

* Call baseline dataset
use "$bsvy_raw/fenix_clean2_rep.dta", clear
* Drop several HH that aren't part of the actual sampling framework
drop if hhid==1354 | hhid==1536 | hhid==3109 | hhid==9999 | hhid==9997
* Make .r, .d, and .n as missing, a normal .
foreach v of varlist _all {
	capture confirm numeric variable `v'
	if !_rc {
	   replace `v' = . if `v'== .r | `v'==.d | `v'==.n
	}
}

* Keep if consenting.
keep if consent_ans==1

* Order and keep variables
order hhid own_land acres_ownland rentout_land acres_rentout earn_rentout share_land acres_shareland hh_shareland hh_owned cost_renthh num_rooms sleepsit any_structure num_structure structure_type structure_type_* hyp_renthh hyp_sellhh
keep hhid own_land acres_ownland rentout_land acres_rentout earn_rentout share_land acres_shareland hh_shareland hh_owned cost_renthh num_rooms sleepsit any_structure num_structure structure_type structure_type_* hyp_renthh hyp_sellhh
order structure_type__99, after(structure_type__77)

* Save dataset
save "$bsvy_processed/7_landhome.dta", replace

replace acres_ownland = 0 if own_land==0
replace rentout_land = 0 if own_land==0
replace acres_rentout =0 if rentout_land==0 | own_land==0
replace earn_rentout = 0 if rentout_land==0 | own_land==0
replace share_land = 0 if own_land==0
replace acres_shareland = 0 if share_land==0
replace hh_shareland = 0 if share_land==0
replace num_structure = 0 if any_structure == 0

* Generate another version of hh_owned
g hh_owned2=(hh_owned==1) if hh_owned!=. & (hh_owned!=. & hh_owned!=.d & hh_owned!=.r & hh_owned!=.n)
order hh_owned2, after(hh_owned)

* Drop certain variables.
drop structure_type structure_type__99

* Rename variables.
ren structure_type_1 struct_storhous
ren structure_type_2 struct_lkraal
ren structure_type_3 struct_skraal
ren structure_type_4 struct_kitchen
ren structure_type_5 struct_washroom
ren structure_type_6 struct_sleep
ren structure_type_7 struct_restshop
ren structure_type_8 struct_rental
ren structure_type_9 struct_otherh
ren structure_type_10 struct_class
ren structure_type_11 struct_shrine
drop structure_type_*

* Define value labels
la def yesno 0 "No" 1 "Yes", modify

* Give value labels for yesno.
foreach var of varlist hh_owned2 struct_storhous-struct_shrine {
	la val `var' yesno
}

* Take care of outliers
foreach var of varlist acres_ownland earn_rentout acres_shareland cost_renthh hyp_renthh hyp_sellhh num_rooms sleepsit {
	sum `var', det
	replace `var'=`r(p99)' if `var' >`r(p99)' & (`var'!=. & `var'!=.d & `var'!=.r & `var'!=.n)
}

* Take logs
foreach var of varlist earn_rentout cost_renthh hyp_renthh hyp_sellhh {
	g l_`var' = log(`var')
}

* Take IHST
foreach var of varlist earn_rentout cost_renthh hyp_renthh hyp_sellhh {
	g ihst_`var' =  asinh(`var')
}

* Label variables
la var struct_storhous "Owns separate store house or granary (=1)"
la var struct_lkraal "Owns separate large kraal (=1)"
la var struct_skraal "Owns separate small kraal (=1)"
la var struct_kitchen "Owns separate kitchen (=1)"
la var struct_washroom "Owns separate washroom or latrine (=1)"
la var struct_sleep "Owns separate sleeping quarters (=1)"
la var struct_restshop "Owns separate bar restaurant or shop (=1)"
la var struct_rental "Owns separate rental (=1)"
la var struct_otherh "Owns separate other house (=1)"
la var struct_class "Owns separate classroom (=1)"
la var struct_shrine "Owns separate shrine or prayer structure (=1)"

la var hh_owned2 "Owns household (=1)"

la var l_earn_rentout "How much money received per month for renting out this land (logged)"
la var l_cost_renthh "How much do you pay each month to rent this house (logged)"
la var l_hyp_renthh "How much you think else would pay to rent this HH (per month) (logged)"
la var l_hyp_sellhh "How much do you think you could sell this household for? (logged)"

la var ihst_earn_rentout "How much money received per month for renting out this land (IHST)"
la var ihst_cost_renthh "How much do you pay each month to rent this house (IHST)"
la var ihst_hyp_renthh "How much you think else would pay to rent this HH (per month) (IHST)"
la var ihst_hyp_sellhh "How much do you think you could sell this household for? (IHST)"

* Save dataset
save "$bsvy_processed/7_landhome_hh.dta", replace



***********************************
**                               **
**           8. ASSETS           **
**                               **
***********************************

* Call baseline dataset.
use "$bsvy_raw/fenix_clean2_rep.dta", clear
* Drop several HH that aren't part of the actual sampling framework
drop if hhid==1354 | hhid==1536 | hhid==3109 | hhid==9999 | hhid==9997
* Make .r, .d, and .n as missing, a normal .
foreach v of varlist _all {
	capture confirm numeric variable `v'
	if !_rc {
	   replace `v' = . if `v'== .r | `v'==.d | `v'==.n
	}
}

* Keep if consenting.
keep if consent_ans==1

* Order and keep certain variables.
order hhid s8_any_bike s8_num_bike s8_any_mcycl s8_num_mcycl s8_any_car s8_num_car s8_any_foam s8_num_foam s8_any_bedfr s8_num_bedfr s8_any_wardr s8_num_wardr s8_any_sofa s8_num_sofa s8_any_stove s8_num_stove s8_any_refrig s8_num_refrig s8_any_lamp s8_num_lamp s8_any_whlbar s8_num_whlbar s8_any_oxcart s8_num_oxcart s8_any_bowsaw s8_num_bowsaw s8_any_motosaw s8_num_motosaw s8_any_tractor s8_num_tractor s8_any_hoe s8_num_hoe s8_any_slasher s8_num_slasher s8_any_panga s8_num_panga s8_any_axe s8_num_axe s8_any_sickle s8_num_sickle s8_any_spade s8_num_spade s8_any_wcan s8_num_wcan s8_any_plough s8_num_plough s8_any_generator s8_num_generator s8_any_wtank s8_num_wtank s8_any_torch s8_num_torch s8_any_cellph s8_num_cellph s8_any_smartph s8_num_smartph s8_any_tv s8_num_tv s8_any_cow s8_num_cow s8_any_sheep s8_num_sheep s8_any_goat s8_num_goat s8_any_pig s8_num_pig s8_any_donkey s8_num_donkey s8_any_bird s8_num_bird s8_any_rabbit s8_num_rabbit
keep hhid num_hh s8_any_bike s8_num_bike s8_any_mcycl s8_num_mcycl s8_any_car s8_num_car s8_any_foam s8_num_foam s8_any_bedfr s8_num_bedfr s8_any_wardr s8_num_wardr s8_any_sofa s8_num_sofa s8_any_stove s8_num_stove s8_any_refrig s8_num_refrig s8_any_lamp s8_num_lamp s8_any_whlbar s8_num_whlbar s8_any_oxcart s8_num_oxcart s8_any_bowsaw s8_num_bowsaw s8_any_motosaw s8_num_motosaw s8_any_tractor s8_num_tractor s8_any_hoe s8_num_hoe s8_any_slasher s8_num_slasher s8_any_panga s8_num_panga s8_any_axe s8_num_axe s8_any_sickle s8_num_sickle s8_any_spade s8_num_spade s8_any_wcan s8_num_wcan s8_any_plough s8_num_plough s8_any_generator s8_num_generator s8_any_wtank s8_num_wtank s8_any_torch s8_num_torch s8_any_cellph s8_num_cellph s8_any_smartph s8_num_smartph s8_any_tv s8_num_tv s8_any_cow s8_num_cow s8_any_sheep s8_num_sheep s8_any_goat s8_num_goat s8_any_pig s8_num_pig s8_any_donkey s8_num_donkey s8_any_bird s8_num_bird s8_any_rabbit s8_num_rabbit

* Variable modification.
local assets "bike mcycl car foam bedfr wardr sofa stove refrig lamp whlbar oxcart bowsaw motosaw tractor hoe slasher panga axe sickle spade wcan plough generator wtank torch cellph smartph tv cow sheep goat pig donkey bird rabbit"
foreach x of local assets {
	replace s8_num_`x' = 0 if s8_any_`x'==0
	ren s8_num_`x' num_`x'
	ren s8_any_`x' any_`x'
}

* Save dataset
save "$bsvy_processed/8_assets.dta", replace

* Bring in asset price data, using data from LSMS. Need districts and region first from the cover sheet, but will need to modify those variables slightly for proper merging across different data sources.
merge 1:1 hhid using "$bsvy_clean/1_cover_hh.dta", keepusing(district region)
drop _merge
recode district (1=216) ///
				(2=217) ///
				(3=218) ///
				(4=201) ///
				(5=420) ///
				(6=117) ///
				(7=219) ///
				(8=118) ///
				(9=220) ///
				(10=225) ///
				(11=416) ///
				(12=401) ///
				(13=402) ///
				(14=202) ///
				(15=221) ///
				(16=119) ///
				(17=226) ///
				(18=121) ///
				(19=403) ///
				(20=417) ///
				(21=203) ///
				(22=418) ///
				(23=204) ///
				(24=404) ///
				(25=405) ///
				(26=213) ///
				(27=222) ///
				(28=122) ///
				(29=102) ///
				(30=205) ///
				(31=413) ///
				(32=414) ///
				(33=206) ///
				(34=406) ///
				(35=207) ///
				(36=112) ///
				(37=407) ///
				(38=103) ///
				(39=227) ///
				(40=419) ///
				(41=421) ///
				(42=408) ///
				(43=208) ///
				(44=228) ///
				(45=228) ///
				(46=123) ///
				(47=422) ///
				(48=415) ///
				(49=229) ///
				(50=104) ///
				(51=124) ///
				(52=114) ///
				(53=223) ///
				(54=105) ///
				(55=409) ///
				(56=214) ///
				(57=209) ///
				(58=410) ///
				(59=423) ///
				(60=115) ///
				(61=106) ///
				(62=107) ///
				(63=108) ///
				(64=116) ///
				(65=109) ///
				(66=224) ///
				(67=231) ///
				(68=424) ///
				(69=411) ///
				(70=210) ///
				(71=110) ///
				(72=425) ///
				(73=412) ///
				(74=111) ///
				(75=232) ///
				(76=426) ///
				(77=215) ///
				(78=211) ///
				(79=212) ///
				(80=113) ///
				(81=201) ///
				(82=405) ///
				(83=210) ///
				(84=403) ///
				(85=403) ///
				(86=107) ///
				(87=403) ///
				(88=404), gen(district2)
recode district2 (201=131) ///
				(202=132) ///
				(203=133) ///
				(204=134) ///
				(205=135) ///
				(206=136) ///
				(207=137) ///
				(208=138) ///
				(209=139) ///
				(210=140) ///
				(211=141) ///
				(212=142) ///
				(213=143) ///
				(214=144) ///
				(215=145) ///
				(216=146) ///
				(217=147) ///
				(218=148) ///
				(219=149) ///
				(220=150) ///
				(221=151) ///
				(222=152) ///
				(223=153) ///
				(224=154) ///
				(225=155) ///
				(226=156) ///
				(227=157) ///
				(228=158) ///
				(229=159) ///
				(230=160) ///
				(231=161) ///
				(232=162) ///
				(401=170) ///
				(401=171) ///
				(402=172) ///
				(403=173) ///
				(404=174) ///
				(405=175) ///
				(406=176) ///
				(407=177) ///
				(408=178) ///
				(409=179) ///
				(410=180) ///
				(411=181) ///
				(412=182) ///
				(413=183) ///
				(414=184) ///
				(415=185) ///
				(416=186) ///
				(417=187) ///
				(418=188) ///
				(419=189) ///
				(420=190) ///
				(421=191) ///
				(422=192) ///
				(423=193) ///
				(424=194) ///
				(425=195) ///
				(426=196)
g region2 = .
replace region2 = 1 if region==2 // central
replace region2 = 2 if region==4 // eastern
replace region2 = 4 if region==3 // western
la var region2 "Region"

* Merge in price information from 2018/2019 version of LSMS.
merge m:1 district2 using "$lsms_asset_prices/asset_prices_dist.dta"
keep if _merge==1 | _merge==3
drop _merge
merge m:1 region2 using "$lsms_asset_prices/asset_prices_reg.dta"
keep if _merge==1 | _merge==3
drop _merge
g nat = 1
merge m:1 nat using "$lsms_asset_prices/asset_prices_nat.dta"
drop nat _merge

* Generate values of X data.
g v_cow = .
replace v_cow = num_cow * price1_dist if price1_dist!=.
replace v_cow = num_cow * price1_reg if price1_reg!=. & v_cow==.
replace v_cow = num_cow * price1_nat if price1_nat!=. & v_cow==.

g v_sheep = .
replace v_sheep = num_sheep * price2_dist if price2_dist!=.
replace v_sheep = num_sheep * price2_reg if price2_reg!=. & v_sheep==.
replace v_sheep = num_sheep * price2_nat if price2_nat!=. & v_sheep==.

g v_goat = .
replace v_goat = num_goat * price3_dist if price3_dist!=.
replace v_goat = num_goat * price3_reg if price3_reg!=. & v_goat==.
replace v_goat = num_goat * price3_nat if price3_nat!=. & v_goat==.

g v_pig = .
replace v_pig = num_pig * price4_dist if price4_dist!=.
replace v_pig = num_pig * price4_reg if price4_reg!=. & v_pig==.
replace v_pig = num_pig * price4_nat if price4_nat!=. & v_pig==.

g v_donkey = .
replace v_donkey = num_donkey * price5_dist if price5_dist!=.
replace v_donkey = num_donkey * price5_reg if price5_reg!=. & v_donkey==.
replace v_donkey = num_donkey * price5_nat if price5_nat!=. & v_donkey==.

g v_bird = .
replace v_bird = num_bird * price6_dist if price6_dist!=.
replace v_bird = num_bird * price6_reg if price6_reg!=. & v_bird==.
replace v_bird = num_bird * price6_nat if price6_nat!=. & v_bird==.

g v_rabbit = .
replace v_rabbit = num_rabbit * price7_dist if price7_dist!=.
replace v_rabbit = num_rabbit * price7_reg if price7_reg!=. & v_rabbit==.
replace v_rabbit = num_rabbit * price7_nat if price7_nat!=. & v_rabbit==.

g v_hoe = .
replace v_hoe = num_hoe * price8_dist if price8_dist!=.
replace v_hoe = num_hoe * price8_reg if price8_reg!=. & v_hoe==.
replace v_hoe = num_hoe * price8_nat if price8_nat!=. & v_hoe==.

g v_plough = .
replace v_plough = num_plough * price9_dist if price9_dist!=.
replace v_plough = num_plough * price9_reg if price9_reg!=. & v_plough==.
replace v_plough = num_plough * price9_nat if price9_nat!=. & v_plough==.

g v_panga = .
replace v_panga = num_panga * price10_dist if price10_dist!=.
replace v_panga = num_panga * price10_reg if price10_reg!=. & v_panga==.
replace v_panga = num_panga * price10_nat if price10_nat!=. & v_panga==.

g v_slasher = .
replace v_slasher = num_slasher * price11_dist if price11_dist!=.
replace v_slasher = num_slasher * price11_reg if price11_reg!=. & v_slasher==.
replace v_slasher = num_slasher * price11_nat if price11_nat!=. & v_slasher==.

g v_whlbar = .
replace v_whlbar = num_whlbar * price12_dist if price12_dist!=.
replace v_whlbar = num_whlbar * price12_reg if price12_reg!=. & v_whlbar==.
replace v_whlbar = num_whlbar * price12_nat if price12_nat!=. & v_whlbar==.

g v_tractor = .
replace v_tractor = num_tractor * price13_dist if price13_dist!=.
replace v_tractor = num_tractor * price13_reg if price13_reg!=. & v_tractor==.
replace v_tractor = num_tractor * price13_nat if price13_nat!=. & v_tractor==.

g v_wcan = .
replace v_wcan = num_wcan * price14_dist if price14_dist!=.
replace v_wcan = num_wcan * price14_reg if price14_reg!=. & v_wcan==.
replace v_wcan = num_wcan * price14_nat if price14_nat!=. & v_wcan==.

g v_axe = .
replace v_axe = num_axe * price15_dist if price15_dist!=.
replace v_axe = num_axe * price15_reg if price15_reg!=. & v_axe==.
replace v_axe = num_axe * price15_nat if price15_nat!=. & v_axe==.

g v_sickle = .
replace v_sickle = num_sickle * price16_dist if price16_dist!=.
replace v_sickle = num_sickle * price16_reg if price16_reg!=. & v_sickle==.
replace v_sickle = num_sickle * price16_nat if price16_nat!=. & v_sickle==.

g v_spade = .
replace v_spade = num_spade * price17_dist if price17_dist!=.
replace v_spade = num_spade * price17_reg if price17_reg!=. & v_spade==.
replace v_spade = num_spade * price17_nat if price17_nat!=. & v_spade==.

g v_oxcart = .
replace v_oxcart = num_oxcart * price18_dist if price18_dist!=.
replace v_oxcart = num_oxcart * price18_reg if price18_reg!=. & v_oxcart==.
replace v_oxcart = num_oxcart * price18_nat if price18_nat!=. & v_oxcart==.

g v_bowsaw = .
replace v_bowsaw = num_bowsaw * price19_dist if price19_dist!=.
replace v_bowsaw = num_bowsaw * price19_reg if price19_reg!=. & v_bowsaw==.
replace v_bowsaw = num_bowsaw * price19_nat if price19_nat!=. & v_bowsaw==.

g v_motosaw = .
replace v_motosaw = num_motosaw * price20_dist if price20_dist!=.
replace v_motosaw = num_motosaw * price20_reg if price20_reg!=. & v_motosaw==.
replace v_motosaw = num_motosaw * price20_nat if price20_nat!=. & v_motosaw==.

g v_bike = .
replace v_bike = num_bike * price21_dist if price21_dist!=.
replace v_bike = num_bike * price21_reg if price21_reg!=. & v_bike==.
replace v_bike = num_bike * price21_nat if price21_nat!=. & v_bike==.

g v_mcycl = .
replace v_mcycl = num_mcycl * price22_dist if price22_dist!=.
replace v_mcycl = num_mcycl * price22_reg if price22_reg!=. & v_mcycl==.
replace v_mcycl = num_mcycl * price22_nat if price22_nat!=. & v_mcycl==.

g v_car = .
replace v_car = num_car * price23_dist if price23_dist!=.
replace v_car = num_car * price23_reg if price23_reg!=. & v_car==.
replace v_car = num_car * price23_nat if price23_nat!=. & v_car==.

g v_refrig = .
replace v_refrig = num_refrig * price24_dist if price24_dist!=.
replace v_refrig = num_refrig * price24_reg if price24_reg!=. & v_refrig==.
replace v_refrig = num_refrig * price24_nat if price24_nat!=. & v_refrig==.

g v_generator = .
replace v_generator = num_generator * price25_dist if price25_dist!=.
replace v_generator = num_generator * price25_reg if price25_reg!=. & v_generator==.
replace v_generator = num_generator * price25_nat if price25_nat!=. & v_generator==.

g v_cellph = .
replace v_cellph = num_cellph * price26_dist if price26_dist!=.
replace v_cellph = num_cellph * price26_reg if price26_reg!=. & v_cellph==.
replace v_cellph = num_cellph * price26_nat if price26_nat!=. & v_cellph==.

g v_smartph = .
replace v_smartph = num_smartph * price27_dist if price27_dist!=.
replace v_smartph = num_smartph * price27_reg if price27_reg!=. & v_smartph==.
replace v_smartph = num_smartph * price27_nat if price27_nat!=. & v_smartph==.

g v_tv = .
replace v_tv = num_tv * price28_dist if price28_dist!=.
replace v_tv = num_tv * price28_reg if price28_reg!=. & v_tv==.
replace v_tv = num_tv * price28_nat if price28_nat!=. & v_tv==.

g v_stove = .
replace v_stove = num_stove * price29_dist if price29_dist!=.
replace v_stove = num_stove * price29_reg if price29_reg!=. & v_stove==.
replace v_stove = num_stove * price29_nat if price29_nat!=. & v_stove==.

g v_lamp = .
replace v_lamp = num_lamp * price30_dist if price30_dist!=.
replace v_lamp = num_lamp * price30_reg if price30_reg!=. & v_lamp==.
replace v_lamp = num_lamp * price30_nat if price30_nat!=. & v_lamp==.

g v_torch = .
replace v_torch = num_torch * price31_dist if price31_dist!=.
replace v_torch = num_torch * price31_reg if price31_reg!=. & v_torch==.
replace v_torch = num_torch * price31_nat if price31_nat!=. & v_torch==.

g v_wtank = .
replace v_wtank = num_wtank * price32_dist if price32_dist!=.
replace v_wtank = num_wtank * price32_reg if price32_reg!=. & v_wtank==.
replace v_wtank = num_wtank * price32_nat if price32_nat!=. & v_wtank==.

g v_foam = .
replace v_foam = num_foam * price33_dist if price33_dist!=.
replace v_foam = num_foam * price33_reg if price33_reg!=. & v_foam==.
replace v_foam = num_foam * price33_nat if price33_nat!=. & v_foam==.

g v_bedfr = .
replace v_bedfr = num_bedfr * price34_dist if price34_dist!=.
replace v_bedfr = num_bedfr * price34_reg if price34_reg!=. & v_bedfr==.
replace v_bedfr = num_bedfr * price34_nat if price34_nat!=. & v_bedfr==.

g v_wardr = .
replace v_wardr = num_wardr * price35_dist if price35_dist!=.
replace v_wardr = num_wardr * price35_reg if price35_reg!=. & v_wardr==.
replace v_wardr = num_wardr * price35_nat if price35_nat!=. & v_wardr==.

g v_sofa = .
replace v_sofa = num_sofa * price36_dist if price36_dist!=.
replace v_sofa = num_sofa * price36_reg if price36_reg!=. & v_sofa==.
replace v_sofa = num_sofa * price36_nat if price36_nat!=. & v_sofa==.

*Generating summary totals, with different number of items.
*Livestock
egen value_livestock = rsum(v_cow v_sheep v_goat v_pig v_donkey v_bird v_rabbit)

*Farm tools
egen value_farmtools = rsum(v_whlbar v_oxcart v_bowsaw v_motosaw v_tractor v_hoe v_slasher v_panga v_axe v_sickle v_spade v_wcan v_plough v_wtank)

*Electronic items
egen value_elec = rsum(v_tv v_smartph v_cellph v_generator)

*Household items-general
egen value_hhgoods = rsum(v_bike v_mcycl v_car v_foam v_bedfr v_wardr v_sofa v_stove v_refrig v_lamp v_torch)

*Total value of assets
egen value_hh_assets = rsum(value_livestock value_farmtools value_elec value_hhgoods)
* Replace three values with missing - two households do not report anything on the any_* indicators, and one reports only on a very few indicators.
replace value_hh_assets=. if hhid==1084 | hhid==4038 | hhid==4160

*Label variables.
la var value_livestock "Value of Livestock"
la var value_farmtools "Value of Farming Tools"
la var value_elec "Value of Electronics"
la var value_hhgoods "Value of General Household Goods"
la var value_hh_assets "Total Value of Household Assets"

* Generate two versions of value_hh_assets, with the other that caps at the 95th percentile.
g value_hh_assets95 = value_hh_assets

* Generate a version to later combine with business assets; temporarily save dataset
tempfile assetval
save `assetval'

* Replace several outliers.
sum value_hh_assets, det
replace value_hh_assets=`r(p99)' if value_hh_assets >`r(p99)' & (value_hh_assets!=. & value_hh_assets!=.d & value_hh_assets!=.r & value_hh_assets!=.n)

sum value_hh_assets95, det
replace value_hh_assets95=`r(p95)' if value_hh_assets95 >`r(p95)' & (value_hh_assets95!=. & value_hh_assets95!=.d & value_hh_assets95!=.r & value_hh_assets95!=.n)

* Log the value of total value of hh assets.
g l_value_hh_assets = log(value_hh_assets)
g l_value_hh_assets95 = log(value_hh_assets95)

* Make IHST versions.
g ihst_value_hh_assets = ln(value_hh_assets+sqrt(value_hh_assets^2+1))
g ihst_value_hh_assets95 = ln(value_hh_assets95+sqrt(value_hh_assets95^2+1))

*Transforming data to remove extra variables for import into other data sets
drop v_*
drop any_*
drop num_*

* Label variables.
la var value_hh_assets95 "Total Value of Household Assets (capped at 95th percentile)"
la var l_value_hh_assets  "Total Value of Household Assets, logged"
la var l_value_hh_assets95 "Total Value of Household Assets (capped at 95th percentile), logged"
la var ihst_value_hh_assets "Total Value of Household Assets, IHST"
la var ihst_value_hh_assets95 "Total Value of Household Assets (capped at 95th percentile), IHST"

save "$bsvy_processed/8_assets_hh.dta", replace



*********************************************
**                                         **
**           9. HOUSEHOLD INCOME           **
**                                         **
*********************************************

use "$bsvy_clean/9_hhincome.dta", clear

* Combine with assets from Section 8 to make "Household and Business Assets" variables
keep hhid asset_type1 asset_type_num1 asset_type2 asset_type_num2 asset_type3 asset_type_num3 asset_type4 asset_type_num4

* Bring in asset price data, using data from LSMS. Need districts and region first from the cover sheet, but will need to modify those variables slightly for proper merging across different data sources.
merge 1:1 hhid using "$bsvy_clean/1_cover_hh.dta", keepusing(district region)

drop _merge
recode district (1=216) ///
				(2=217) ///
				(3=218) ///
				(4=201) ///
				(5=420) ///
				(6=117) ///
				(7=219) ///
				(8=118) ///
				(9=220) ///
				(10=225) ///
				(11=416) ///
				(12=401) ///
				(13=402) ///
				(14=202) ///
				(15=221) ///
				(16=119) ///
				(17=226) ///
				(18=121) ///
				(19=403) ///
				(20=417) ///
				(21=203) ///
				(22=418) ///
				(23=204) ///
				(24=404) ///
				(25=405) ///
				(26=213) ///
				(27=222) ///
				(28=122) ///
				(29=102) ///
				(30=205) ///
				(31=413) ///
				(32=414) ///
				(33=206) ///
				(34=406) ///
				(35=207) ///
				(36=112) ///
				(37=407) ///
				(38=103) ///
				(39=227) ///
				(40=419) ///
				(41=421) ///
				(42=408) ///
				(43=208) ///
				(44=228) ///
				(45=228) ///
				(46=123) ///
				(47=422) ///
				(48=415) ///
				(49=229) ///
				(50=104) ///
				(51=124) ///
				(52=114) ///
				(53=223) ///
				(54=105) ///
				(55=409) ///
				(56=214) ///
				(57=209) ///
				(58=410) ///
				(59=423) ///
				(60=115) ///
				(61=106) ///
				(62=107) ///
				(63=108) ///
				(64=116) ///
				(65=109) ///
				(66=224) ///
				(67=231) ///
				(68=424) ///
				(69=411) ///
				(70=210) ///
				(71=110) ///
				(72=425) ///
				(73=412) ///
				(74=111) ///
				(75=232) ///
				(76=426) ///
				(77=215) ///
				(78=211) ///
				(79=212) ///
				(80=113) ///
				(81=201) ///
				(82=405) ///
				(83=210) ///
				(84=403) ///
				(85=403) ///
				(86=107) ///
				(87=403) ///
				(88=404), gen(district2)
recode district2 (201=131) ///
				(202=132) ///
				(203=133) ///
				(204=134) ///
				(205=135) ///
				(206=136) ///
				(207=137) ///
				(208=138) ///
				(209=139) ///
				(210=140) ///
				(211=141) ///
				(212=142) ///
				(213=143) ///
				(214=144) ///
				(215=145) ///
				(216=146) ///
				(217=147) ///
				(218=148) ///
				(219=149) ///
				(220=150) ///
				(221=151) ///
				(222=152) ///
				(223=153) ///
				(224=154) ///
				(225=155) ///
				(226=156) ///
				(227=157) ///
				(228=158) ///
				(229=159) ///
				(230=160) ///
				(231=161) ///
				(232=162) ///
				(401=170) ///
				(401=171) ///
				(402=172) ///
				(403=173) ///
				(404=174) ///
				(405=175) ///
				(406=176) ///
				(407=177) ///
				(408=178) ///
				(409=179) ///
				(410=180) ///
				(411=181) ///
				(412=182) ///
				(413=183) ///
				(414=184) ///
				(415=185) ///
				(416=186) ///
				(417=187) ///
				(418=188) ///
				(419=189) ///
				(420=190) ///
				(421=191) ///
				(422=192) ///
				(423=193) ///
				(424=194) ///
				(425=195) ///
				(426=196)
g region2 = .
replace region2 = 1 if region==2 // central
replace region2 = 2 if region==4 // eastern
replace region2 = 4 if region==3 // western

* Merge in price information.
merge m:1 district2 using "$lsms_asset_prices/asset_busprices_dist.dta"
keep if _merge==1 | _merge==3
drop _merge
merge m:1 region2 using "$lsms_asset_prices/asset_busprices_reg.dta"
keep if _merge==1 | _merge==3
drop _merge
g nat = 1
merge m:1 nat using "$lsms_asset_prices/asset_busprices_nat.dta"
drop nat _merge

* Generate values of X data.
* Replace if other specify with missing
replace asset_type1 = . if asset_type1==-66
replace asset_type2 = . if asset_type2==-66
replace asset_type3 = . if asset_type3==-66
replace asset_type4 = . if asset_type4==-66
* Note: a few households seem to be double or triple listing, replace with missing value
* br if asset_type1==asset_type2 & asset_type1!=. & asset_type2!=.
replace asset_type4 = . if asset_type1==asset_type2 & asset_type2==asset_type3 & asset_type3==asset_type4
replace asset_type3 = . if asset_type1==asset_type2 & asset_type2==asset_type3
* Replace if the same number, otherwise fold into asset_type1
replace asset_type2 = . if asset_type1==asset_type2 & asset_type_num1==asset_type_num2
g tag = 1 if asset_type1==asset_type2 & asset_type_num1!=. & asset_type_num2!=. & asset_type1!=.
replace asset_type_num1 = asset_type_num1 + asset_type_num2 if asset_type1==asset_type2 & asset_type_num1!=. & asset_type_num2!=. & asset_type1!=.
replace asset_type2 = . if tag==1
drop tag
assert asset_type1!=asset_type3 if asset_type1!=. & asset_type3!=.

replace asset_type4=. if asset_type1==asset_type4 & asset_type_num1==asset_type_num4
assert asset_type1!=asset_type4 if asset_type1!=. & asset_type4!=.

assert asset_type1!=asset_type2 if asset_type1!=. & asset_type2!=.

g tag = 1 if asset_type2==asset_type4 & asset_type_num2!=. & asset_type_num4!=. & asset_type2!=.
replace asset_type_num2 = asset_type_num2 + asset_type_num4 if tag==1
replace asset_type4 = . if tag==1
drop tag
assert asset_type2!=asset_type4 if asset_type2!=. & asset_type4!=.

g tag = 1 if asset_type2==asset_type3 & asset_type_num2!=. & asset_type_num3!=. & asset_type2!=.
replace asset_type_num2 = asset_type_num2 + asset_type_num3 if tag==1
replace asset_type3 = . if tag==1
drop tag
assert asset_type2!=asset_type3 if asset_type2!=. & asset_type3!=.

g tag = 1 if asset_type3==asset_type4 & asset_type_num3!=. & asset_type_num4!=. & asset_type3!=.
replace asset_type_num3 = asset_type_num3 + asset_type_num4 if tag==1
replace asset_type4 = . if tag==1
drop tag
assert asset_type3!=asset_type4 if asset_type3!=. & asset_type4!=.

foreach x of numlist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 78 79 80 81 82 83 84 85 86 87 88 89 90 91 {
	g v_`x' = .
	replace v_`x' = asset_type_num1 * bprice`x'_dist if bprice`x'_dist!=. & asset_type1==`x'
	replace v_`x' = asset_type_num1 * bprice`x'_reg if bprice`x'_reg!=. & v_`x'==. & asset_type1==`x'
	replace v_`x' = asset_type_num1 * bprice`x'_nat if bprice`x'_nat!=. & v_`x'==. & asset_type1==`x'
}

foreach x of numlist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 78 79 80 81 82 83 84 85 86 87 88 89 90 91 {
	replace v_`x' = asset_type_num2 * bprice`x'_dist if bprice`x'_dist!=. & v_`x'==. & asset_type2==`x'
	replace v_`x' = asset_type_num2 * bprice`x'_reg if bprice`x'_reg!=. & v_`x'==. & asset_type2==`x'
	replace v_`x' = asset_type_num2 * bprice`x'_nat if bprice`x'_nat!=. & v_`x'==. & asset_type2==`x'
}

foreach x of numlist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 78 79 80 81 82 83 84 85 86 87 88 89 90 91 {
	replace v_`x' = asset_type_num3 * bprice`x'_dist if bprice`x'_dist!=. & v_`x'==. & asset_type3==`x'
	replace v_`x' = asset_type_num3 * bprice`x'_reg if bprice`x'_reg!=. & v_`x'==. & asset_type3==`x'
	replace v_`x' = asset_type_num3 * bprice`x'_nat if bprice`x'_nat!=. & v_`x'==. & asset_type3==`x'
}

foreach x of numlist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 78 79 80 81 82 83 84 85 86 87 88 89 90 91 {
	replace v_`x' = asset_type_num4 * bprice`x'_dist if bprice`x'_dist!=. & v_`x'==. & asset_type4==`x'
	replace v_`x' = asset_type_num4 * bprice`x'_reg if bprice`x'_reg!=. & v_`x'==. & asset_type4==`x'
	replace v_`x' = asset_type_num4 * bprice`x'_nat if bprice`x'_nat!=. & v_`x'==. & asset_type4==`x'
}

egen value_business = rsum(v_1 v_2 v_3 v_4 v_5 v_6 v_7 v_8 v_9 v_10 v_11 v_12 v_13 v_14 v_15 v_16 v_17 v_18 v_19 v_20 v_21 v_22 v_23 v_24 v_25 v_26 v_27 v_28 v_29 v_30 v_31 v_32 v_33 v_34 v_35 v_36 v_37 v_38 v_39 v_40 v_41 v_42 v_43 v_44 v_46 v_47 v_48 v_49 v_50 v_51 v_52 v_53 v_54 v_55 v_56 v_57 v_58 v_59 v_60 v_61 v_62 v_63 v_64 v_65 v_66 v_67 v_68 v_69 v_70 v_78 v_79 v_80 v_81 v_82 v_83 v_84 v_85 v_86 v_87 v_88 v_89 v_90 v_91)

* Generate a copy
g value_business95 = value_business

*Label variables.
la var value_business "Value of business assets"

* Generate two versions of value_hh_assets, with the other that caps at the 95th percentile.
merge 1:1 hhid using `assetval', keepusing(value_hh_assets value_hh_assets95)

* Sum asset variables from both household and business sides
g value_comb_assets = value_hh_assets + value_business
g value_comb_assets95 = value_hh_assets95 + value_business95

* Replace several outliers.
sum value_comb_assets, det
replace value_comb_assets=`r(p99)' if value_comb_assets >`r(p99)' & (value_comb_assets!=. & value_comb_assets!=.d & value_comb_assets!=.r & value_comb_assets!=.n)

sum value_comb_assets95, det
replace value_comb_assets95=`r(p95)' if value_comb_assets95 >`r(p95)' & (value_comb_assets95!=. & value_comb_assets95!=.d & value_comb_assets95!=.r & value_comb_assets95!=.n)

* Log the value of total value of hh assets.
g l_value_comb_assets = log(value_comb_assets)
g l_value_comb_assets95 = log(value_comb_assets95)

* Make IHST versions.
g ihst_value_comb_assets = ln(value_comb_assets+sqrt(value_comb_assets^2+1))
g ihst_value_comb_assets95 = ln(value_comb_assets95+sqrt(value_comb_assets95^2+1))

* Keep basic data
keep hhid value_comb_assets value_comb_assets95 l_value_comb_assets l_value_comb_assets95 ihst_value_comb_assets ihst_value_comb_assets95

* Label variables
la var value_comb_assets "Value of household and business assets, 99th percentile"
la var value_comb_assets95 "Value of household and business assets, 95th percentile"
la var l_value_comb_assets "Value of household and business assets, 99th percentile (logged)"
la var l_value_comb_assets95 "Value of household and business assets, 95th percentile (logged)"
la var ihst_value_comb_assets "Value of household and business assets, 99th percentile (IHST)"
la var ihst_value_comb_assets95 "Value of household and business assets, 95th percentile (IHST)"

* Save dataset
save "$bsvy_processed/9_busassets.dta", replace


************************************************
**                                            **
**           10. BORROW, SAVE, LEND           **
**                                            **
************************************************

* Call baseline dataset.
use "$bsvy_raw/fenix_clean2_rep.dta", clear
* Drop several HH that aren't part of the actual sampling framework
drop if hhid==1354 | hhid==1536 | hhid==3109 | hhid==9999 | hhid==9997
* Make .r, .d, and .n as missing, a normal .
foreach v of varlist _all {
	capture confirm numeric variable `v'
	if !_rc {
	   replace `v' = . if `v'== .r | `v'==.d | `v'==.n
	}
}

* Keep if consenting
keep if consent_ans==1

* Order and keep certain variables.
order hhid any_mobilebank any_mobilemoney any_creditgroup number_creditgroup time_creditgroup frequency_creditgroup contribute_creditgroup receive_creditgroup
keep hhid any_mobilebank any_mobilemoney any_creditgroup number_creditgroup time_creditgroup frequency_creditgroup contribute_creditgroup receive_creditgroup

* Save dataset
save "$bsvy_processed/10A_coop.dta", replace

****************************

* Section off
replace number_creditgroup=0 if any_creditgroup==0
replace time_creditgroup=0 if any_creditgroup==0
replace frequency_creditgroup=0 if any_creditgroup==0
la def time_creditgroup 0 "Not in credit group", modify
la def frequency_creditgroup 0 "Not in credit group", modify
replace contribute_creditgroup=0 if any_creditgroup==0
replace receive_creditgroup=0 if any_creditgroup==0

* Take care of outliers
foreach var of varlist contribute_creditgroup receive_creditgroup {
	sum `var', det
	replace `var'=`r(p99)' if `var'>`r(p99)' & (`var'!=. & `var'!=.d & `var'!=.r & `var'!=.n)

}

* Generate logged versions of variables.
foreach var of varlist contribute_creditgroup receive_creditgroup {
	g l_`var' = log(`var')
}

* Generate IHST versions of varaibles.
foreach var of varlist contribute_creditgroup receive_creditgroup {
	g ihst_`var' = asinh(`var')
}

* Label variables
la var l_contribute_creditgroup "How much contributed to group(s) in the last 12 months (logged)"
la var l_receive_creditgroup "How much received in total in the last 12 months (logged)"
la var ihst_contribute_creditgroup "How much contributed to group(s) in the last 12 months (IHST)"
la var ihst_receive_creditgroup "How much received in total in the last 12 months (IHST)"

* Save dataset
save "$bsvy_processed/10A_coop_hh.dta", replace



************************************************************************************************************

* Call baseline dataset.
use "$bsvy_raw/fenix_clean2_rep.dta", clear
* Drop several HH that aren't part of the actual sampling framework
drop if hhid==1354 | hhid==1536 | hhid==3109 | hhid==9999 | hhid==9997
* Make .r, .d, and .n as missing, a normal .
foreach v of varlist _all {
	capture confirm numeric variable `v'
	if !_rc {
	   replace `v' = . if `v'== .r | `v'==.d | `v'==.n
		}
}

* Keep if consenting.
keep if consent_ans==1

* Order and keep certain variables.
order hhid any_loans num_loans mm_loans num_mmloans amount_mmloan source_loan* timing_loan* repay_loan* use_loan* collateral_loan_* collateral_loan2_* repaying_loan* total_loans ever_refused source_refusal* hypo_loan hypo_source_loan hypo2_loan hypo2_source_loan readypay_loan_plan*
order source_refusal_13, before(source_refusal__99)
order readypay_loan_plan__88 readypay_loan_plan__99, after(readypay_loan_plan_9)
keep hhid any_loans num_loans mm_loans num_mmloans amount_mmloan source_loan* timing_loan* repay_loan* use_loan* collateral_loan_* collateral_loan2_* repaying_loan* total_loans ever_refused source_refusal* hypo_loan hypo_source_loan hypo2_loan hypo2_source_loan readypay_loan_plan*

* Value labels
la def loan_use 11 "Purchase land" 12 "Purchase livestock or agricultural inputs", modify

* Label variables
la var source_loan_1 "10.4 From whom did you take loan #1"
la var source_loan_2 "10.4 From whom did you take loan #2"
la var source_loan_3 "10.4 From whom did you take loan #3"
la var source_loan_4 "10.4 From whom did you take loan #4"
la var source_loan_5 "10.4 From whom did you take loan #5"
la var source_loan_6 "10.4 From whom did you take loan #6"
la var source_loan_7 "10.4 From whom did you take loan #7"
la var source_loan_8 "10.4 From whom did you take loan #8"
la var source_loan_9 "10.4 From whom did you take loan #9"
la var source_loan_10 "10.4 From whom did you take loan #10"

la var use_loan_1 "10.7 What did you use most of loan #1 for"
la var use_loan_2 "10.7 What did you use most of loan #2 for"
la var use_loan_3 "10.7 What did you use most of loan #3 for"
la var use_loan_4 "10.7 What did you use most of loan #4 for"
la var use_loan_5 "10.7 What did you use most of loan #5 for"
la var use_loan_6 "10.7 What did you use most of loan #6 for"
la var use_loan_7 "10.7 What did you use most of loan #7 for"
la var use_loan_8 "10.7 What did you use most of loan #8 for"
la var use_loan_9 "10.7 What did you use most of loan #9 for"
la var use_loan_10 "10.7 What did you use most of loan #10 for"

la var collateral_loan_1 "10.8 What, if anything, did you use for collateral for loan #1?"
la var collateral_loan_2 "10.8 What, if anything, did you use for collateral for loan #2?"
la var collateral_loan_3 "10.8 What, if anything, did you use for collateral for loan #3?"
la var collateral_loan_4 "10.8 What, if anything, did you use for collateral for loan #4?"
la var collateral_loan_5 "10.8 What, if anything, did you use for collateral for loan #5?"
la var collateral_loan_6 "10.8 What, if anything, did you use for collateral for loan #6?"
la var collateral_loan_7 "10.8 What, if anything, did you use for collateral for loan #7?"
la var collateral_loan_8 "10.8 What, if anything, did you use for collateral for loan #8?"
la var collateral_loan_9 "10.8 What, if anything, did you use for collateral for loan #9?"
la var collateral_loan_10 "10.8 What, if anything, did you use for collateral for loan #10?"

la var collateral_loan2_1 "Collateral for loan #1, recategorized"
la var collateral_loan2_2 "Collateral for loan #2, recategorized"
la var collateral_loan2_3 "Collateral for loan #3, recategorized"
la var collateral_loan2_4 "Collateral for loan #4, recategorized"
la var collateral_loan2_5 "Collateral for loan #5, recategorized"
la var collateral_loan2_6 "Collateral for loan #6, recategorized"
la var collateral_loan2_7 "Collateral for loan #7, recategorized"
la var collateral_loan2_8 "Collateral for loan #8, recategorized"
la var collateral_loan2_9 "Collateral for loan #9, recategorized"
la var collateral_loan2_10 "Collateral for loan #10, recategorized"

* Save dataset
save "$bsvy_processed/10B_loans.dta", replace

*** Note for use during endline: What is the median mobile money loan amount?
sum amount_mmloan, det // 60,000

****************************

* Section off
replace num_loans=0 if any_loans==0
replace mm_loans=0 if any_loans==0
replace num_mmloans=0 if mm_loans==0
replace amount_mmloan=0 if num_mmloans==0
replace total_loans=0 if any_loans==0

* Develop a row-sum variable of total loans to be repaid (w/ interest), depending on whether the loan is still being repaid
forv x = 1/10 {
	g c_repay_loan_`x' = repay_loan_`x'
	replace c_repay_loan_`x' = 0 if repaying_loan_`x'==0
}
* Generate amount to be repaid accross loans
egen toberepaid = rsum(c_repay_loan_1 c_repay_loan_2 c_repay_loan_3 c_repay_loan_4 c_repay_loan_5 c_repay_loan_6 c_repay_loan_7 c_repay_loan_8 c_repay_loan_9 c_repay_loan_10)
replace toberepaid = . if any_loans==.
drop c_repay_loan_*

* Develop a variable that records whether they have a loan with a microfinance
g microfloan = 0 if any_loans!=.
forv x = 1/10 {
	replace microfloan = 1 if source_loan_`x'==5
}

* Develop a variable that records average size of microfinance loans
forv x = 1/10 {
	g c_repay_loan_`x' = repay_loan_`x'
	replace c_repay_loan_`x' = . if source_loan_`x'!=5
}
egen microfloan_size = rowmean(c_repay_loan_1 c_repay_loan_2 c_repay_loan_3 c_repay_loan_4 c_repay_loan_5 c_repay_loan_6 c_repay_loan_7 c_repay_loan_8 c_repay_loan_9 c_repay_loan_10)
drop c_repay_loan_*

drop source_loan_* timing_loan_* repay_loan_* use_loan_* collateral_loan* repaying_loan_* source_refusal source_refusal_* hypo_source_loan hypo2_source_loan readypay_loan_plan readypay_loan_plan__88 readypay_loan_plan__99

* Rename
ren readypay_loan_plan_1 rdypay_loan_sfl
ren readypay_loan_plan_2 rdypay_loan_micro
ren readypay_loan_plan_3 rdypay_loan_hhneeds
ren readypay_loan_plan_4 rdypay_loan_aginp
ren readypay_loan_plan_5 rdypay_loan_bus
ren readypay_loan_plan_6 rdypay_loan_emerg
ren readypay_loan_plan_7 rdypay_loan_build
ren readypay_loan_plan_8 rdypay_loan_notint
ren readypay_loan_plan_9 rdypay_loan_health

* Generate a 95th percentile version
g total_loans95 = total_loans

* Take care of outliers
foreach var of varlist amount_mmloan total_loans toberepaid microfloan_size {
	sum `var', det
	replace `var'=`r(p99)' if `var'>`r(p99)' & (`var'!=. & `var'!=.d & `var'!=.r & `var'!=.n)
}
foreach var of varlist total_loans95 {
	sum `var', det
	replace `var'=`r(p95)' if `var'>`r(p95)' & (`var'!=. & `var'!=.d & `var'!=.r & `var'!=.n)
}

* Develop logged version of variables.
foreach var of varlist amount_mmloan total_loans toberepaid {
	g l_`var' = log(`var')
}
* Develop IHST version of variables.
foreach var of varlist amount_mmloan total_loans toberepaid {
	g ihst_`var' = asinh(`var')
}

* Define value labels
la def yesno 0 "No" 1 "Yes", modify

* Value label.
foreach var of varlist rdypay_loan_sfl-rdypay_loan_health {
	la val `var' yesno
}

* Variable labels.
la var rdypay_loan_sfl "ReadyPay loan to be used for school fee loan (=1)"
la var rdypay_loan_micro "ReadyPay loan to be used for microenterprise startup (=1)"
la var rdypay_loan_hhneeds "ReadyPay loan to be used for HH needs (=1)"
la var rdypay_loan_aginp "ReadyPay loan to be used for ag inputs (=1)"
la var rdypay_loan_bus "ReadyPay loan to be used for invest in business (=1)"
la var rdypay_loan_emerg "ReadyPay loan to be used for emergency (=1)"
la var rdypay_loan_build "ReadyPay loan to be used for building (=1)"
la var rdypay_loan_notint "No longer interested in ReadyPay loan (=1)"
la var rdypay_loan_health "ReadyPay loan to be used for health (=1)"
la var toberepaid "Total to be repaid at end of loans, for loans still being repaid"
la var microfloan_size "Average size of microfinance loan"
la var microfloan "Took microfinance loan in past 12 months (=1)"

la var l_amount_mmloan "What is the largest loan amt ever received through mobile mon (logged)"
la var l_total_loans "In the last 12 months, how much money did you borrow in total? (logged)"
la var l_toberepaid "Total to be repaid at end of loans, for loans still being repaid (logged)"
la var ihst_amount_mmloan "What is the largest loan amt ever received through mobile mon (IHST)"
la var ihst_total_loans "In the last 12 months, how much money did you borrow in total? (IHST)"
la var ihst_toberepaid "Total to be repaid at end of loans, for loans still being repaid (IHST)"

la var total_loans95 "In last 12 months, money borrowed in total? UGX 95th percentile"

* Save dataset
save "$bsvy_processed/10B_loans_hh.dta", replace



************************************************************************************************************

* Call baseline dataset.
use "$bsvy_raw/fenix_clean2_rep.dta", clear
* Drop several HH that aren't part of the actual sampling framework
drop if hhid==1354 | hhid==1536 | hhid==3109 | hhid==9999 | hhid==9997
* Make .r, .d, and .n as missing, a normal .
foreach v of varlist _all {
	capture confirm numeric variable `v'
	if !_rc {
	   replace `v' = . if `v'== .r | `v'==.d | `v'==.n
	}
}

* Keep if consenting.
keep if consent_ans==1

order location_savings_1, before(location_savings_1_1)
order location_savings_2, before(location_savings_1_2)
order location_savings_3, before(location_savings_1_3)
order location_savings_4, before(location_savings_1_4)
order location_savings_5, before(location_savings_1_5)
order location_savings_6, before(location_savings_1_6)
order location_savings_12_1, after(location_savings_11_1)
order location_savings_12_2, after(location_savings_11_2)
order hhid any_savings num_savings location_savings* savings_length* savings_amount* savings_deposit* savings_withdrawal*
keep hhid any_savings num_savings location_savings* savings_length* savings_amount* savings_deposit* savings_withdrawal*

* Relabel certain variables.
forv x = 1/6 {
	la var location_savings_`x' "Where do you keep your savings number `x'?"
	la var savings_length_`x' "How many months have you been saving at number `x' for?"
	la var savings_amount_`x' "10.19 How much do you have saved at `x' now?"
	la var savings_deposit_`x' "10.20 How many times in last 3 months have you or members of hh put money into location `x'?"
	la var savings_withdrawal_`x' "10.21 How much money have you withdrawn from `x' in the past 3 months?"
}

* Save dataset
save "$bsvy_processed/10C_savings.dta", replace

******************************
* Replace num_savings with zero if no savings
replace num_savings = 0 if any_savings==0
* Replace with zeros
foreach var of varlist savings_amount_* {
	replace `var' = 0 if `var'==. | `var'==.d | `var'==.r | `var'==.n
}
* Sum across values to arrive at total savings.
egen total_savings = rsum(savings_amount_1 savings_amount_2 savings_amount_3 savings_amount_4 savings_amount_5 savings_amount_6)
replace total_savings = . if any_savings==.

* Drop extraneous variables.
drop location_savings_1-location_savings__99_1 location_savings_2-location_savings__99_2 location_savings_3-location_savings__99_3 location_savings_4-location_savings__99_4 location_savings_5-location_savings__99_5 location_savings_6-location_savings__99_6 savings_length_* savings_amount_* savings_deposit_* savings_withdrawal_*

* Take care of outliers
foreach var of varlist total_savings {
	sum `var', det
	replace `var'=`r(p99)' if `var'>`r(p99)' & (`var'!=. & `var'!=.d & `var'!=.r & `var'!=.n)
}

* Generate logged versions of certain variables.
foreach var of varlist total_savings {
	g l_`var' = log(`var')
}

* Generate IHST versions of certain variables.
foreach var of varlist total_savings {
	g ihst_`var' = asinh(`var')
}

* Variable labels
la var total_savings "Total savings"
la var l_total_savings "Total savings (logged)"
la var ihst_total_savings "Total savings (IHST)"

* Save dataset
save "$bsvy_processed/10C_savings_hh.dta", replace


************************************************************************************************************

* Call baseline dataset.
use "$bsvy_raw/fenix_clean2_rep.dta", clear
* Drop several HH that aren't part of the actual sampling framework
drop if hhid==1354 | hhid==1536 | hhid==3109 | hhid==9999 | hhid==9997
* Make .r, .d, and .n as missing, a normal .
foreach v of varlist _all {
	capture confirm numeric variable `v'
	if !_rc {
	   replace `v' = . if `v'== .r | `v'==.d | `v'==.n
	}
}

* Keep if consenting.
keep if consent_ans==1

* Order and keep certain variables
order hhid ever_given num_given given_recipient* given_amount* given_waiting*
keep hhid ever_given num_given given_recipient* given_amount* given_waiting*

forv x = 1/12 {
	la var given_recipient_`x' "10.24 To whom did you give loan #`x'?"
}

* Save dataset
save "$bsvy_processed/10D_lending.dta", replace

*******************************

* Separate out
replace num_given = 0 if ever_given==0

foreach var of varlist given_amount_* {
	replace `var' = 0 if `var'==. | `var'==.d | `var'==.r | `var'==.n
}

egen total_given = rsum(given_amount_1 given_amount_2 given_amount_3 given_amount_4 given_amount_5 given_amount_6 given_amount_7 given_amount_8 given_amount_9 given_amount_10 given_amount_11 given_amount_12)

replace total_given = . if ever_given==.

* Drop
drop given_recipient_* given_amount_* given_waiting_*

* Take care of outliers
foreach var of varlist total_given {
	sum `var', det
	replace `var'=`r(p99)' if `var'>`r(p99)' & (`var'!=. & `var'!=.d & `var'!=.r & `var'!=.n)
}

* Develop logged versions of variables.
foreach var of varlist total_given {
	g l_`var' = log(`var')
}

* Develop IHST versions of variables.
foreach var of varlist total_given {
	g ihst_`var' = asinh(`var')
}

* Variable labels.
la var total_given "Total amount loaned out in last 12 months"
la var l_total_given "Total amount loaned out in last 12 months (logged)"
la var ihst_total_given "Total amount loaned out in last 12 months (IHST)"

* Save dataset
save "$bsvy_processed/10D_lending_hh.dta", replace
