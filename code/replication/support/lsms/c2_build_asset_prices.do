********************************************************************************
** Do file: c2_build_asset_prices.do
** First started: July 11, 2020
** Last edited: September 8, 2023

/* Purpose: this do file develops regional (i.e., district-level, region-level, and national-level) asset prices from the Uganda LSMS 2019 survey */

********************************************************************************

clear
clear matrix
clear mata
set maxvar 10000

/* Note: need to account for inflation, where Fenix baseline survey data is in 2019. Develop locals. */
* Source: https://data.worldbank.org/indicator/FP.CPI.TOTL.ZG?locations=UG

local i18 = 102.624/100
local i19 = 102.869/100

/* Recode district and region codes for proper merging with baseline survey, for the asset datasets
that will be created. */
use "$lsms2018/GSEC1", clear
g HHID = hhid
recode district_code (200=144) ///
				(201=131) ///
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
				(233=140) ///
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
				(426=196) ///
				(427=177) ///
				(428=177) ///
				(429=174) ///
				(432=173), gen(district2)
g region2 = region
* Manipulate year of survey to incorporate inflation later on
g interv_year = substr(s1bq02,1,4)
destring interv_year, replace
* Temporarily save dataset
tempfile areainfo
save `areainfo'


///////////////////////////////////////////////////////////////////////////////////////////

/*

Files used for assets:

AGSEC6A - Large livestock
AGSEC6B - Medium livestock
AGSEC6C - Small livestock/poultry
AGSEC10 - Farming implements
GSEC15D - Household goods
GSEC14 - Household goods

*/


///////////////////////////////////////////////////////////////////////////////////////////

* Evaluation of Livestock values

* Large livestock
use "$lsms2018/AGSEC6A", clear

* Merge in area variables
merge m:1 hhid using `areainfo', keepusing(district2 region2)

* Drop northern region, as northern region did not feature in experiment
drop if region2==3

* Rename variables
rename s6aq13b value_bought
rename s6aq14b value_sold

* Generate asset id variable
g asset_id = .
replace asset_id = 1 if inlist(LiveStockID, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
replace asset_id = 5 if LiveStockID==11

* Generating average value (bought and sold).
* Average value where there are non-zero values for both livestock bought and livestock sold
g price=(value_bought+value_sold)/2 if value_bought>0 & value_sold>0
* Average values were one or both entries have a zero value or blank
replace price=value_bought if value_bought>0 & value_sold<=0
replace price=value_bought if value_bought>0 & value_sold==.
replace price=value_sold if value_bought<=0 & value_sold>0
replace price=value_sold if value_bought==. & value_sold>0

* Incorporate inflation
replace price = price*`i18'*`i19'

* Generate a counter variable that will be used for price construction. If counter is less than 30, will make price missing (thought process: not enough info to infer)
g counter = 1 if price!=.

	* Collapse into part datasets, save as tempfile (reshape later)
	preserve
		collapse (median) price (sum) counter, by(district2 asset_id)
		drop if asset_id==. | district2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets1_dist
		save `assets1_dist'
	restore

	preserve
		collapse (median) price (sum) counter, by(region2 asset_id)
		drop if asset_id==. | region2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets1_reg
		save `assets1_reg'
	restore

	preserve
		collapse (median) price, by(asset_id)
		drop if asset_id==.
		tempfile assets1_nat
		save `assets1_nat'
	restore


* Medium livestock
use "$lsms2018/AGSEC6B", clear

* Merge area variables
merge m:1 hhid using `areainfo', keepusing(district2 region2)

* Drop northern region, as northern region did not feature in experiment
drop if region2==3

* Rename variables
rename s6bq13b value_bought
rename s6bq14b value_sold

* Generate asset id
g asset_id = .
replace asset_id = 2 if inlist(ALiveStock_Small_ID, 15,16,20,21) // sheep
replace asset_id = 3 if inlist(ALiveStock_Small_ID, 13,14,18,19) // goats
replace asset_id = 4 if inlist(ALiveStock_Small_ID, 17,22) // pigs

* Generating average value (bought and sold)
* Average value where there are non-zero values for both livestock bought and livestock sold
g price=(value_bought+value_sold)/2 if value_bought>0 & value_sold>0
* Average values were one or both entries have a zero value or blank
replace price=value_bought if value_bought>0 & value_sold<=0
replace price=value_bought if value_bought>0 & value_sold==.
replace price=value_sold if value_bought<=0 & value_sold>0
replace price=value_sold if value_bought==. & value_sold>0

* Incorporate inflation
replace price = price*`i18'*`i19'

* Generate a counter variable that will be used for price construction. If counter is less than 30, will make price missing (thought process: not enough info to infer)
g counter = 1 if price!=.

	* Collapse into part datasets, save as tempfile (reshape later)
	preserve
		collapse (median) price (sum) counter, by(district2 asset_id)
		drop if asset_id==. | district2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets2_dist
		save `assets2_dist'
	restore

	preserve
		collapse (median) price (sum) counter, by(region2 asset_id)
		drop if asset_id==. | region2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets2_reg
		save `assets2_reg'
	restore

	preserve
		collapse (median) price, by(asset_id)
		drop if asset_id==.
		tempfile assets2_nat
		save `assets2_nat'
	restore


* Small livestock/poultry
use "$lsms2018/AGSEC6C", clear

* Merge area variables
merge m:1 hhid using `areainfo', keepusing(district2 region2)

* Drop northern region, as northern region did not feature in experiment
drop if region2==3

* Rename variables
rename s6cq13b value_bought
rename s6cq14b value_sold

* Generate asset id
g asset_id = .
replace asset_id = 6 if inlist(APCode, 23,24,25,26)
replace asset_id = 7 if APCode==27

* Generating average value (bought and sold)
* Average value where there are non-zero values for both livestock bought and livestock sold
g price=(value_bought+value_sold)/2 if value_bought>0 & value_sold>0
* Average values were one or both entries have a zero value or blank
replace price=value_bought if value_bought>0 & value_sold<=0
replace price=value_bought if value_bought>0 & value_sold==.
replace price=value_sold if value_bought<=0 & value_sold>0
replace price=value_sold if value_bought==. & value_sold>0

* Incorporate inflation
replace price = price*`i18'*`i19'

* Generate a counter variable that will be used for price construction. If counter is less than 30, will make price missing (thought process: not enough info to infer)
g counter = 1 if price!=.

	* Collapse into part datasets, save as tempfile (reshape later)
	preserve
		collapse (median) price (sum) counter, by(district2 asset_id)
		drop if asset_id==. | district2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets3_dist
		save `assets3_dist'
	restore

	preserve
		collapse (median) price (sum) counter, by(region2 asset_id)
		drop if asset_id==. | region2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets3_reg
		save `assets3_reg'
	restore

	preserve
		collapse (median) price, by(asset_id)
		drop if asset_id==.
		tempfile assets3_nat
		save `assets3_nat'
	restore


///////////////////////////////////////////////////////////////////////////////////////////

*Evaluation of Farm Implements values
use "$lsms2018/AGSEC10", clear

* Merge area variables
merge m:1 hhid using `areainfo', keepusing(district2 region2)

* Drop northern region, as northern region did not feature in experiment
drop if region2==3

* Rename variables
rename s10q01a num_item
rename s10q02a value_items_total

* Generate asset id
g asset_id = .
replace asset_id = 8 if A10itemcod_ID==1 // hoe
replace asset_id = 9 if A10itemcod_ID==2 // ploughs
replace asset_id = 10 if A10itemcod_ID==3 // pangas
replace asset_id = 11 if A10itemcod_ID==4 // slashers
replace asset_id = 12 if A10itemcod_ID==5 // wheel barrows
replace asset_id = 13 if A10itemcod_ID==6 // tractor
replace asset_id = 14 if A10itemcod_ID==7 // watering cans
replace asset_id = 15 if A10itemcod_ID==8 // pruning knives, call axe
*replace asset_id = 16 , A10itemcod==9 // pruning saws, copy slashers later
replace asset_id = 17 if A10itemcod_ID==12 // spade
replace asset_id = 18 if A10itemcod_ID==23 // animal drawn cart, but not here
replace asset_id = 19 if A10itemcod_ID==9 // pruning saws, call bow saw
replace asset_id = 20 if A10itemcod_ID==10 // chain/band saws, but not here


* The survey asked respondents the number of each type of farming implement owned and the total estimated value of all of each item owned by the household
g price = value_items_total/num_item

* Incorporate inflation
replace price = price*`i18'*`i19'

* Generate a counter variable that will be used for price construction. If counter is less than 30, will make price missing (thought process: not enough info to infer)
g counter = 1 if price!=.

* Collapse into part datasets, save as tempfile (reshape later)
	preserve
		collapse (median) price (sum) counter, by(district2 asset_id)
		drop if asset_id==. | district2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets4_dist
		save `assets4_dist'
	restore

	preserve
		collapse (median) price (sum) counter, by(region2 asset_id)
		drop if asset_id==. | region2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets4_reg
		save `assets4_reg'
	restore

	preserve
		collapse (median) price, by(asset_id)
		drop if asset_id==.
			replace price = 30000 if asset_id== 13
		tempfile assets4_nat
		save `assets4_nat'
	restore


///////////////////////////////////////////////////////////////////////////////////////////

* Evaluation of general household goods values
use "$lsms2018/GSEC14", clear

* Merge area variables
merge m:1 hhid using `areainfo', keepusing(district2 region2 interv_year) // note: not a lot

* Drop northern region, as northern region did not feature in experiment
drop if region2==3

g price = h14q05/h14q04

* Incorporate inflation
replace price = price*`i19' if interv_year==2018

* Generate asset id
g asset_id = .
replace asset_id = 21 if h14q02==10 // bicycle
replace asset_id = 22 if h14q02==11 // motorcycle
replace asset_id = 23 if h14q02==12 // motor vehicle
replace asset_id = 24 if h14q02==24 // refrigerator
replace asset_id = 25 if h14q02==8 // generators
* For difference between regular phone and smart phone, assume above 100k is smart phone
replace asset_id = 26 if h14q02==16 & price < 100000
replace asset_id = 27 if h14q02==16 & price >= 100000 & price!=.
replace asset_id = 28 if h14q02==6 // television

* Generate a counter variable that will be used for price construction. If counter is less than 30, will make price missing (thought process: not enough info to infer)
g counter = 1 if price!=.

* Collapse into part datasets, save as tempfile (reshape later)
	preserve
		collapse (median) price (sum) counter, by(district2 asset_id)
		drop if asset_id==. | district2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets5_dist
		save `assets5_dist'
	restore

	preserve
		collapse (median) price (sum) counter, by(region2 asset_id)
		drop if asset_id==. | region2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets5_reg
		save `assets5_reg'
	restore

	preserve
		collapse (median) price, by(asset_id)
		drop if asset_id==.
			replace price = 500000 if asset_id==24
		tempfile assets5_nat
		save `assets5_nat'
	restore


///////////////////////////////////////////////////////////////////////////////////////////

use "$lsms2018/GSEC15D", clear

* Merge area variables
merge m:1 hhid using `areainfo', keepusing(district2 region2 interv_year)

* Drop northern region, as northern region did not feature in experiment
drop if region2==3

* Rename variables
rename CED03 value_past
rename CED04 value_postprod
rename CED05 value_gifts

* Generate asset id
g asset_id = .
replace asset_id = 29 if CED02==402 // charcoal and kerosene stove
* replace asset_id = 30 if itmcd==402 // for lamp
* replace asset_id = 31 if itmcd==402 // for torch
* replace asset_id = 32 if itmcd== suggested value of 414000
replace asset_id = 33 if CED02==304 // bedding mattresses
replace asset_id = 34 if CED02==302 // carpets, mats
replace asset_id = 35 if CED02==301 // furniture items
* replace asset_id = 36 if itmcd==301

* For household goods, three different values were presented in the survey results:
* 1. How much value came from purchases in the past
* 2. How much value came from own-production in the past
* 3. How much value came from gifts/in-kind sources in the past

* Generating average values for household goods where all three value entries have a non-zero value
g price=(value_past+value_postprod+value_gifts)/3 if value_past>0 & value_postprod>0 & value_gifts>0
* Generating average values for household goods where one or more of the entries has a zero value or blank entry
replace price = (value_past+value_postprod)/2 if value_past>0 & value_postprod>0 & value_gifts<=0
replace price = (value_past+value_postprod)/2 if value_past>0 & value_postprod>0 & value_gifts==.
replace price = (value_past+value_gifts)/2 if value_past>0 & value_postprod<=0 & value_gifts>0
replace price = (value_past+value_gifts)/2 if value_past>0 & value_postprod==. & value_gifts>0
replace price = (value_gifts+value_postprod)/2 if value_past<=0 & value_postprod>0 & value_gifts>0
replace price = (value_gifts+value_postprod)/2 if value_past==. & value_postprod>0 & value_gifts>0
replace price = value_past if value_past>0 & value_postprod<=0 & value_gifts<=0
replace price = value_past if value_past>0 & value_postprod==. & value_gifts<=0
replace price = value_past if value_past>0 & value_postprod<=0 & value_gifts==.
replace price = value_past if value_past>0 & value_postprod==. & value_gifts==.
replace price = value_postprod if value_past<=0 & value_postprod>0 & value_gifts<=0
replace price = value_postprod if value_past==. & value_postprod>0 & value_gifts<=0
replace price = value_postprod if value_past<=0 & value_postprod>0 & value_gifts==.
replace price = value_postprod if value_past==. & value_postprod>0 & value_gifts==.
replace price = value_gifts if value_past<=0 & value_postprod<=0 & value_gifts>0
replace price = value_gifts if value_past<=0 & value_postprod==. & value_gifts>0
replace price = value_gifts if value_past==. & value_postprod<=0 & value_gifts>0
replace price = value_gifts if value_past==. & value_postprod==. & value_gifts>0

* Incorporate inflation
replace price = price*`i19' if interv_year==2018

* Generate a counter variable that will be used for price construction. If counter is less than 30, will make price missing (thought process: not enough info to infer)
g counter = 1 if price!=.

	* Collapse into part datasets, save as tempfile (reshape later)
	preserve
		collapse (median) price (sum) counter, by(district2 asset_id)
		drop if asset_id==. | district2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets6_dist
		save `assets6_dist'
	restore

	preserve
		collapse (median) price (sum) counter, by(region2 asset_id)
		drop if asset_id==. | region2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets6_reg
		save `assets6_reg'
	restore

	preserve
		collapse (median) price, by(asset_id)
		drop if asset_id==.
		tempfile assets6_nat
		save `assets6_nat'
	restore


///////////////////////////////////////////////////////////////////////////////////////////

*** Bring together files ***
* District dataset
use `assets1_dist', clear
append using `assets2_dist'
append using `assets3_dist'
append using `assets4_dist'
append using `assets5_dist'
append using `assets6_dist'
reshape wide price, i(district2) j(asset_id)
	/* Recall the items that were not included because they were not available, but are basically copies of another variable. Bring in here. */
	g price16 = price11
	g price18 = 250000
	g price20 = 4750
	g price30 = price29
	g price31 = price29
	g price32 = 414000
	g price36 = price35
	order district2 price1 price2 price3 price4 price5 price6 price7 price8 price9 price10 ///
		price11 price12 price13 price14 price15 price16 price17 price18 price19 price20 ///
		price21 price22 price23 price24 price25 price26 price27 price28 price29 price30 ///
		price31 price32 price33 price34 price35 price36
foreach var of varlist price1-price36 {
	ren `var' `var'_dist
}
* Label variables
la var district2 "District ID"
la var price1_dist "Price (UGX 2019) of cattle (district-level)"
la var price2_dist "Price (UGX 2019) of sheep (district-level)"
la var price3_dist "Price (UGX 2019) of goat (district-level)"
la var price4_dist "Price (UGX 2019) of pig (district-level)"
la var price5_dist "Price (UGX 2019) of donkey/mule (district-level)"
la var price6_dist "Price (UGX 2019) of poultry (district-level)"
la var price7_dist "Price (UGX 2019) of rabbit (district-level)"
la var price8_dist "Price (UGX 2019) of hoe (district-level)"
la var price9_dist "Price (UGX 2019) of plough (district-level)"
la var price10_dist "Price (UGX 2019) of panga (district-level)"
la var price11_dist "Price (UGX 2019) of slasher (district-level)"
la var price12_dist "Price (UGX 2019) of wheel barrow (district-level)"
la var price13_dist "Price (UGX 2019) of tractor (district-level)"
la var price14_dist "Price (UGX 2019) of watering can (district-level)"
la var price15_dist "Price (UGX 2019) of axe (district-level)"
la var price16_dist "Price (UGX 2019) of sickle (district-level)"
la var price17_dist "Price (UGX 2019) of spade (district-level)"
la var price18_dist "Price (UGX 2019) of ox cart (district-level)"
la var price19_dist "Price (UGX 2019) of bow saw (district-level)"
la var price20_dist "Price (UGX 2019) of motorized saw (district-level)"
la var price21_dist "Price (UGX 2019) of bicycle (district-level)"
la var price22_dist "Price (UGX 2019) of motorcycle (district-level)"
la var price23_dist "Price (UGX 2019) of motor vehicle (district-level)"
la var price24_dist "Price (UGX 2019) of refrigerator (district-level)"
la var price25_dist "Price (UGX 2019) of generator (district-level)"
la var price26_dist "Price (UGX 2019) of phone (district-level)"
la var price27_dist "Price (UGX 2019) of smartphone (district-level)"
la var price28_dist "Price (UGX 2019) of television (district-level)"
la var price29_dist "Price (UGX 2019) of charcoal and kerosene stove (district-level)"
la var price30_dist "Price (UGX 2019) of lamp (district-level)"
la var price31_dist "Price (UGX 2019) of torch (district-level)"
la var price32_dist "Price (UGX 2019) of water tank (district-level)"
la var price33_dist "Price (UGX 2019) of foam mattress (district-level)"
la var price34_dist "Price (UGX 2019) of bedframe (district-level)"
la var price35_dist "Price (UGX 2019) of wardrobe (district-level)"
la var price36_dist "Price (UGX 2019) of sofa (district-level)"

* Save dataset
save "$lsms_asset_prices/asset_prices_dist", replace


* Region dataset
use `assets1_reg', clear
append using `assets2_reg'
append using `assets3_reg'
append using `assets4_reg'
append using `assets5_reg'
append using `assets6_reg'
reshape wide price, i(region2) j(asset_id)
	/* Recall the items that were not included because they were not available, but are basically copies of another variable. Bring in here. */
	g price16 = price11
	g price18 = 250000
	g price20 = 4750
	g price30 = price29
	g price31 = price29
	g price32 = 414000
	g price36 = price35
	order region2 price1 price2 price3 price4 price5 price6 price7 price8 price9 price10 ///
		price11 price12 price13 price14 price15 price16 price17 price18 price19 price20 ///
		price21 price22 price23 price24 price25 price26 price27 price28 price29 price30 ///
		price31 price32 price33 price34 price35 price36
foreach var of varlist price1-price36 {
	ren `var' `var'_reg
}

* Label variables
la var region2 "Region ID"
la var price1_reg "Price (UGX 2019) of cattle (region-level)"
la var price2_reg "Price (UGX 2019) of sheep (region-level)"
la var price3_reg "Price (UGX 2019) of goat (region-level)"
la var price4_reg "Price (UGX 2019) of pig (region-level)"
la var price5_reg "Price (UGX 2019) of donkey/mule (region-level)"
la var price6_reg "Price (UGX 2019) of poultry (region-level)"
la var price7_reg "Price (UGX 2019) of rabbit (region-level)"
la var price8_reg "Price (UGX 2019) of hoe (region-level)"
la var price9_reg "Price (UGX 2019) of plough (region-level)"
la var price10_reg "Price (UGX 2019) of panga (region-level)"
la var price11_reg "Price (UGX 2019) of slasher (region-level)"
la var price12_reg "Price (UGX 2019) of wheel barrow (region-level)"
la var price13_reg "Price (UGX 2019) of tractor (region-level)"
la var price14_reg "Price (UGX 2019) of watering can (region-level)"
la var price15_reg "Price (UGX 2019) of axe (region-level)"
la var price16_reg "Price (UGX 2019) of sickle (region-level)"
la var price17_reg "Price (UGX 2019) of spade (region-level)"
la var price18_reg "Price (UGX 2019) of ox cart (region-level)"
la var price19_reg "Price (UGX 2019) of bow saw (region-level)"
la var price20_reg "Price (UGX 2019) of motorized saw (region-level)"
la var price21_reg "Price (UGX 2019) of bicycle (region-level)"
la var price22_reg "Price (UGX 2019) of motorcycle (region-level)"
la var price23_reg "Price (UGX 2019) of motor vehicle (region-level)"
la var price24_reg "Price (UGX 2019) of refrigerator (region-level)"
la var price25_reg "Price (UGX 2019) of generator (region-level)"
la var price26_reg "Price (UGX 2019) of phone (region-level)"
la var price27_reg "Price (UGX 2019) of smartphone (region-level)"
la var price28_reg "Price (UGX 2019) of television (region-level)"
la var price29_reg "Price (UGX 2019) of charcoal and kerosene stove (region-level)"
la var price30_reg "Price (UGX 2019) of lamp (region-level)"
la var price31_reg "Price (UGX 2019) of torch (region-level)"
la var price32_reg "Price (UGX 2019) of water tank (region-level)"
la var price33_reg "Price (UGX 2019) of foam mattress (region-level)"
la var price34_reg "Price (UGX 2019) of bedframe (region-level)"
la var price35_reg "Price (UGX 2019) of wardrobe (region-level)"
la var price36_reg "Price (UGX 2019) of sofa (region-level)"

save "$lsms_asset_prices/asset_prices_reg", replace

* National dataset
use `assets1_nat', clear
append using `assets2_nat'
append using `assets3_nat'
append using `assets4_nat'
append using `assets5_nat'
append using `assets6_nat'
g nat = 1
reshape wide price, i(nat) j(asset_id)
	/* Recall the items that were not included because they were not available, but are basically copies of another variable. Bring in here. */
	g price16 = price11
	g price18 = 250000
	g price20 = 4750
	g price30 = price29
	g price31 = price29
	g price32 = 414000
	g price36 = price35
		order nat price1 price2 price3 price4 price5 price6 price7 price8 price9 price10 ///
		price11 price12 price13 price14 price15 price16 price17 price18 price19 price20 ///
		price21 price22 price23 price24 price25 price26 price27 price28 price29 price30 ///
		price31 price32 price33 price34 price35 price36
foreach var of varlist price1-price36 {
	ren `var' `var'_nat
}

* Label variables
la var nat "National ID"
la var price1_nat "Price (UGX 2019) of cattle (national-level)"
la var price2_nat "Price (UGX 2019) of sheep (national-level)"
la var price3_nat "Price (UGX 2019) of goat (national-level)"
la var price4_nat "Price (UGX 2019) of pig (national-level)"
la var price5_nat "Price (UGX 2019) of donkey/mule (national-level)"
la var price6_nat "Price (UGX 2019) of poultry (national-level)"
la var price7_nat "Price (UGX 2019) of rabbit (national-level)"
la var price8_nat "Price (UGX 2019) of hoe (national-level)"
la var price9_nat "Price (UGX 2019) of plough (national-level)"
la var price10_nat "Price (UGX 2019) of panga (national-level)"
la var price11_nat "Price (UGX 2019) of slasher (national-level)"
la var price12_nat "Price (UGX 2019) of wheel barrow (national-level)"
la var price13_nat "Price (UGX 2019) of tractor (national-level)"
la var price14_nat "Price (UGX 2019) of watering can (national-level)"
la var price15_nat "Price (UGX 2019) of axe (national-level)"
la var price16_nat "Price (UGX 2019) of sickle (national-level)"
la var price17_nat "Price (UGX 2019) of spade (national-level)"
la var price18_nat "Price (UGX 2019) of ox cart (national-level)"
la var price19_nat "Price (UGX 2019) of bow saw (national-level)"
la var price20_nat "Price (UGX 2019) of motorized saw (national-level)"
la var price21_nat "Price (UGX 2019) of bicycle (national-level)"
la var price22_nat "Price (UGX 2019) of motorcycle (national-level)"
la var price23_nat "Price (UGX 2019) of motor vehicle (national-level)"
la var price24_nat "Price (UGX 2019) of refrigerator (national-level)"
la var price25_nat "Price (UGX 2019) of generator (national-level)"
la var price26_nat "Price (UGX 2019) of phone (national-level)"
la var price27_nat "Price (UGX 2019) of smartphone (national-level)"
la var price28_nat "Price (UGX 2019) of television (national-level)"
la var price29_nat "Price (UGX 2019) of charcoal and kerosene stove (national-level)"
la var price30_nat "Price (UGX 2019) of lamp (national-level)"
la var price31_nat "Price (UGX 2019) of torch (national-level)"
la var price32_nat "Price (UGX 2019) of water tank (national-level)"
la var price33_nat "Price (UGX 2019) of foam mattress (national-level)"
la var price34_nat "Price (UGX 2019) of bedframe (national-level)"
la var price35_nat "Price (UGX 2019) of wardrobe (national-level)"
la var price36_nat "Price (UGX 2019) of sofa (national-level)"

save "$lsms_asset_prices/asset_prices_nat", replace
