********************************************************************************
** Do file: c3_build_busasset_prices.do
** First started: December 22, 2020
** Last edited: September 8, 2023

/* Purpose: this do file develops median, regional asset prices for business assets
from the Uganda LSMS 2019 survey as well as from internet sources */

********************************************************************************

clear
clear matrix
clear mata
set maxvar 10000

/* Note: need to account for inflation, where Fenix baseline survey data is in 2019 */
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
* Temporarily save file
tempfile areainfo
save `areainfo'


///////////////////////////////////////////////////////////////////////////////////////////

/*

Files used for assets:

AGSEC6A - Large livestock
AGSEC6B - Medium livestock
AGSEC6C - Small livestock/poultry
AGSEC10 - Farming implements
GSEC15C - Non-Durable Goods
GSEC15D - Household goods
GSEC14 - Household goods

*/

///////////////////////////////////////////////////////////////////////////////////////////

* Evaluation of Farm Implements values
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
replace asset_id = 90 if A10itemcod_ID==2 // Plough (survey) as ploughs (lsms)
replace asset_id = 20 if A10itemcod_ID==3 // Gardening tools/equipment (e.g. spade, panga, hoe) (survey) as pangas (lsms)
replace asset_id = 2 if A10itemcod_ID==4 // carving chisel (survey) as slashers (lsms)
replace asset_id = 89 if A10itemcod_ID==5 // Wheel barrow (survey) as Wheel barrows (lsms)
replace asset_id = 26 if A10itemcod_ID==8 // Misc. small tools (paint scraper, hammer, metalwork needle, trowel ??) (survey) as pruning knives (lsms)

replace asset_id = 81 if A10itemcod_ID==11 // Grinding machine/mill (survey) as Sheller (lsms)
replace asset_id = 83 if A10itemcod_ID==14 // Ox cart (survey) as Ox plough (lsms)
replace asset_id = 3 if A10itemcod_ID==16 // chips making machine (survey) as harrow/cultivator (lsms)
replace asset_id = 9 if A10itemcod_ID==19 // napsack chemical sprayer (survey) as sprayer (lsms)
* Copy asset_id 41 later as similar to 16
* Copy asset_id 80 later as similar to 26
*replace asset_id = 41 if A10itemcod_ID==10 // Power saw (survey) as chain/band saw (lsms)
*replace asset_id = 80 if A10itemcod_ID==8 // Axe (survey) as pruning knives (lsms)
* NOT PRESENT
*replace asset_id = 16 if A10itemcod_ID==10 // table saw (survey) as chain/band saw (lsms)

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
			replace price = 8000000 if asset_id==3
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

* Generate asset id
g asset_id = .
replace asset_id = 79 if h14q02==10 // Bicycle (survey) as Bicycle (lsms)
replace asset_id = 1 if h14q02==11 // boda (survey) as motorcycle (lsms)
replace asset_id = 78 if h14q02==12 // Car (survey) as Motor vehicle (lsms)

g price = h14q05/h14q04

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
		tempfile assets5_nat
		save `assets5_nat'
	restore

///////////////////////////////////////////////////////////////////////////////////////////

use "$lsms2018/GSEC15C", clear

* Merge area variables
merge m:1 hhid using `areainfo', keepusing(district2 region2 interv_year)

* Drop northern region, as northern region did not feature in experiment
drop if region2==3

* Generate asset id
g asset_id = .
replace asset_id = 21 if CEC02==303 // Structure (rental building/house) (survey) as Imputed value of free house (lsms) - *** should maybe be some proportion
replace asset_id = 28 if CEC02==457 // Lead Battery (350K) (survey) as Batteries (Dry cells) (lsms)
* Copy asset_id 23 later as similar to 21
* Copy asset_id 59 later as similar to 28
* replace asset_id = 23 if CEC02==303 // Structure (classroom/schoolhouse) (survey) as Imputed value of free house (lsms) - *** should maybe be some proportion
* replace asset_id = 59 if CEC02==457 // Car Battery (survey) as Batteries (Dry cells) (lsms)

g price = CEC05/CEC04
* Note: price for rental has no units
replace price = CEC05 if CEC02==303

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
		tempfile assets7_dist
		save `assets7_dist'
	restore

	preserve
		collapse (median) price (sum) counter, by(region2 asset_id)
		drop if asset_id==. | region2==.
		replace price = . if counter < 30
		drop counter
		tempfile assets7_reg
		save `assets7_reg'
	restore

	preserve
		collapse (median) price, by(asset_id)
		drop if asset_id==.
			*replace price = 500000 if asset_id==24
		tempfile assets7_nat
		save `assets7_nat'
	restore


///////////////////////////////////////////////////////////////////////////////////////////


* Note: for the remaining items, need to believe they describe just one item purchased (are low values anyway)

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
replace asset_id = 17 if CED02==301 // weighing scale (survey) as furniture items (lsms)
replace asset_id = 88 if CED02==304 // Mattress (survey) as Bedding Mattresses (lsms)
replace asset_id = 65 if CED02==305 // Woolen (Baby) Blanket (survey) as Blankets (lsms)
replace asset_id = 4 if CED02==401 // hair dryer (survey) as appliances (lsms)
replace asset_id = 10 if CED02==402 // oven/stove (survey) as charcoal and kerosene stoves (lsms)
replace asset_id = 5 if CED02==4021 // hot plate (survey) as electric/gas cooker (lsms)
replace asset_id = 8 if CED02==403 // nail gun (survey) as electronic equipment (lsms)
replace asset_id = 85 if CED02==405 // Radio (survey) as Radio (lsms)
replace asset_id = 19 if CED02==408 // computer (survey) as computers for household use (lsms)

* Copy asset_id 18 later as similar to 17
* Copy asset_id 6 later as similar to 4
* Copy asset_id 7 later as similar to 4
* Copy asset_id 13 later as similar to 4
* Copy asset_id 27 later as similar to 4
* Copy asset_id 29 later as similar to 4
* Copy asset_id 30 later as similar to 4
* Copy asset_id 64 later as similar to 4
* Copy asset_id 11 later as similar to 10
* Copy asset_id 69 later as similar to 10
* Copy asset_id 22 later as similar to 5
* Copy asset_id 12 later as similar to 8
* Copy asset_id 14 later as similar to 8
* Copy asset_id 15 later as similar to 8
* Copy asset_id 82 later as similar to 8
* Copy asset_id 25 later as similar to 19
* replace asset_id = 18 if CED02==301 // furniture (survey) as furniture items (lsms)
* replace asset_id = 6 if CED02==401 // ice maker (survey) as appliances (lsms)
* replace asset_id = 7 if CED02==401 // juice dispenser (survey) as appliances (lsms)
* replace asset_id = 13 if CED02==401 // refrigerator (survey) as appliances (lsms)
* replace asset_id = 27 if CED02==401 // Air Compressor (survey) as Appliances (lsms)
* replace asset_id = 29 if CED02==401 // Welder (welding machine) (survey) as Appliances (lsms)
* replace asset_id = 30 if CED02==401 // Drill (survey) as Appliances (lsms)
* replace asset_id = 64 if CED02==401 // DVD Player (survey) as Appliances (lsms)
* replace asset_id = 11 if CED02==402 // popcorn machine (survey) as charcoal and kerosene stoves (lsms)
* replace asset_id = 69 if CED02==402 // Meat Smoking Wires (survey) as Charcoal and Kerosene Stoves (lsms)
* replace asset_id = 22 if CED02==4021 // Kerosene Lamp (survey) as electric/gas cooker (lsms)
* replace asset_id = 12 if CED02==403 // printer (survey) as electronic equipment (lsms)
* replace asset_id = 14 if CED02==403 // television (survey) as electronic equipment (lsms)
* replace asset_id = 15 if CED02==403 // sewing machine (survey) as electronic equipment (lsms)
* replace asset_id = 82 if CED02==403 // Phone (survey) as Electronic Equipment (lsms)
* replace asset_id = 25 if CED02==408 // Credit card/terminal machine/point of sale machine (survey) as Computers for household use (lsms)
* NOT PRESENT
*replace asset_id = 24 if CED02==501 // Containers: soda crates, boxes, drums etc. (survey) as Plastic basins (lsms)
*replace asset_id = 84 if CED02==5042 // Pots (survey) as Saucepan/cook-pot/pressure cooker/thermal cooker etc (lsms)


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

* Bring in values for other business assets from other sources (mostly online)

* Table saw: asset_id = 16, 500000
* Vice: asset_id = 31, 185000
* Washing Bay: asset_id = 32, 30000000
* Pump: asset_id = 33, 1300000
* Timber: asset_id = 34, 5000
* Pregnancy Delivery Kits: asset_id = 35, 20000
* Camera: asset_id = 36, 2000000
* Soil Compactor: asset_id = 37, 5000000
* Mirror: asset_id = 38, 50000
* 200L Fermentation Tank: asset_id = 39, 7400000
* Sander: asset_id = 40, 250000
* Public address system (sound system): asset_id = 42, 400000
* Rotter Machine (curving furniture): asset_id = 43, 74000000
* Buffet Food Warmer: asset_id = 44, 250000
* Sphygmomanometer: asset_id = 46, 110000
* Audio mixing console (DJ mixer): asset_id = 47, 500000
* Microsoft Snipping Tool: asset_id = 48, 0
* Scanning Machine (scanner): asset_id = 49, 1000000
* Tarpaulin: asset_id = 50, 75000
* Sisal Sack: asset_id = 51, 5000
* Metal Archway: asset_id = 52, 130000
* Air Pump Machine: asset_id = 53, 70000
* Planing Machine: asset_id = 54, 2000000
* Pressure Jet Machine: asset_id = 55, 1000000
* Paint Sprayer Machine: asset_id = 56, 100000
* Welding Vice: asset_id = 57, 150000
* Ground Leveling Machine: asset_id = 58, 4000000
* Woofer: asset_id = 60, 100000
* Butcher's Knife: asset_id = 61, 20000
* Hurler Machine: asset_id = 62, 7000000
* Binding Machine: asset_id = 63, 400000
* Jigsaw Woodworking Machine: asset_id = 66, 440000
* Polybag Sealer: asset_id = 67, 100000
* Jack Plane: asset_id = 68, 300000
* TV Decoder: asset_id = 70, 100000
* Turkeys, chickens, birds: asset_id = 86, 13000
* Water tank: asset_id = 87, 300000
* Generator: asset_id = 91, 300000
* Container: asset_id = 24, 10000
* Pots: asset_id = 84, 25000

*** Ignore -66 Other Specify because not available


*** Bring together files ***
* District dataset
use `assets7_dist', clear
append using `assets4_dist'
append using `assets5_dist'
append using `assets6_dist'
ren price bprice
reshape wide bprice, i(district2) j(asset_id)
	/* Recall the items that were not included because they were not available, but are basically copies of another variable. Bring in here. */
	g bprice16 = 500000
	g bprice24 = 10000
	g bprice31 = 185000
	g bprice32 = 30000000
	g bprice33 = 1300000
	g bprice34 = 5000
	g bprice35 = 20000
	g bprice36 = 2000000
	g bprice37 = 5000000
	g bprice38 = 50000
	g bprice39 = 7400000
	g bprice40 = 250000
	g bprice42 = 400000
	g bprice43 = 74000000
	g bprice44 = 250000
	g bprice46 = 110000
	g bprice47 = 500000
	g bprice48 = 0
	g bprice49 = 1000000
	g bprice50 = 75000
	g bprice51 = 5000
	g bprice52 = 130000
	g bprice53 = 70000
	g bprice54 = 2000000
	g bprice55 = 1000000
	g bprice56 = 100000
	g bprice57 = 150000
	g bprice58 = 4000000
	g bprice60 = 100000
	g bprice61 = 20000
	g bprice62 = 7000000
	g bprice63 = 400000
	g bprice66 = 440000
	g bprice67 = 100000
	g bprice68 = 300000
	g bprice70 = 100000
	g bprice84 = 25000
	g bprice86 = 13000
	g bprice87 = 300000
	g bprice91 = 300000

	g bprice41 = bprice16
	g bprice80 = bprice26
	g bprice23 = bprice21
	g bprice59 = bprice28
	g bprice18 = bprice17
	g bprice6 = bprice4
	g bprice7 = bprice4
	g bprice13 = bprice4
	g bprice27 = bprice4
	g bprice29 = bprice4
	g bprice30 = bprice4
	g bprice64 = bprice4
	g bprice11 = bprice10
	g bprice69 = bprice10
	g bprice22 = bprice5
	g bprice12 = bprice8
	g bprice14 = bprice8
	g bprice15 = bprice8
	g bprice82 = bprice8
	g bprice25 = bprice19

	order district2 bprice1 bprice2 bprice3 bprice4 bprice5 bprice6 bprice7 bprice8 bprice9 bprice10 ///
		bprice11 bprice12 bprice13 bprice14 bprice15 bprice16 bprice17 bprice18 bprice19 bprice20 ///
		bprice21 bprice22 bprice23 bprice24 bprice25 bprice26 bprice27 bprice28 bprice29 bprice30 ///
		bprice31 bprice32 bprice33 bprice34 bprice35 bprice36 bprice37 bprice38 bprice39 bprice40 ///
		bprice41 bprice42 bprice43 bprice44 bprice46 bprice47 bprice48 bprice49 bprice50 ///
		bprice51 bprice52 bprice53 bprice54 bprice55 bprice56 bprice57 bprice58 bprice59 bprice60 ///
		bprice61 bprice62 bprice63 bprice64 bprice65 bprice66 bprice67 bprice68 bprice69 bprice70 ///
		bprice78 bprice79 bprice80 ///
		bprice81 bprice82 bprice83 bprice84 bprice85 bprice86 bprice87 bprice88 bprice89 bprice90 ///
		bprice91

foreach var of varlist bprice1-bprice91 {
	ren `var' `var'_dist
}
* Label variables
la var district2 "District ID"
* la var bprice1_dist "Price (UGX 2019) of X (district-level)"

* Save dataset
save "$lsms_asset_prices/asset_busprices_dist", replace


* Region dataset
use `assets7_reg', clear
append using `assets4_reg'
append using `assets5_reg'
append using `assets6_reg'
ren price bprice
reshape wide bprice, i(region2) j(asset_id)
	/* Recall the items that were not included because they were not available, but are basically copies of another variable. Bring in here. */
	/* Recall the items that were not included because they were not available, but are basically copies of another variable. Bring in here. */
	g bprice16 = 500000
	g bprice24 = 10000
	g bprice31 = 185000
	g bprice32 = 30000000
	g bprice33 = 1300000
	g bprice34 = 5000
	g bprice35 = 20000
	g bprice36 = 2000000
	g bprice37 = 5000000
	g bprice38 = 50000
	g bprice39 = 7400000
	g bprice40 = 250000
	g bprice42 = 400000
	g bprice43 = 74000000
	g bprice44 = 250000
	g bprice46 = 110000
	g bprice47 = 500000
	g bprice48 = 0
	g bprice49 = 1000000
	g bprice50 = 75000
	g bprice51 = 5000
	g bprice52 = 130000
	g bprice53 = 70000
	g bprice54 = 2000000
	g bprice55 = 1000000
	g bprice56 = 100000
	g bprice57 = 150000
	g bprice58 = 4000000
	g bprice60 = 100000
	g bprice61 = 20000
	g bprice62 = 7000000
	g bprice63 = 400000
	g bprice66 = 440000
	g bprice67 = 100000
	g bprice68 = 300000
	g bprice70 = 100000
	g bprice84 = 25000
	g bprice86 = 13000
	g bprice87 = 300000
	g bprice91 = 300000

	g bprice41 = bprice16
	g bprice80 = bprice26
	g bprice23 = bprice21
	g bprice59 = bprice28
	g bprice18 = bprice17
	g bprice6 = bprice4
	g bprice7 = bprice4
	g bprice13 = bprice4
	g bprice27 = bprice4
	g bprice29 = bprice4
	g bprice30 = bprice4
	g bprice64 = bprice4
	g bprice11 = bprice10
	g bprice69 = bprice10
	g bprice22 = bprice5
	g bprice12 = bprice8
	g bprice14 = bprice8
	g bprice15 = bprice8
	g bprice82 = bprice8
	g bprice25 = bprice19
	order region2 bprice1 bprice2 bprice3 bprice4 bprice5 bprice6 bprice7 bprice8 bprice9 bprice10 ///
		bprice11 bprice12 bprice13 bprice14 bprice15 bprice16 bprice17 bprice18 bprice19 bprice20 ///
		bprice21 bprice22 bprice23 bprice24 bprice25 bprice26 bprice27 bprice28 bprice29 bprice30 ///
		bprice31 bprice32 bprice33 bprice34 bprice35 bprice36 bprice37 bprice38 bprice39 bprice40 ///
		bprice41 bprice42 bprice43 bprice44 bprice46 bprice47 bprice48 bprice49 bprice50 ///
		bprice51 bprice52 bprice53 bprice54 bprice55 bprice56 bprice57 bprice58 bprice59 bprice60 ///
		bprice61 bprice62 bprice63 bprice64 bprice65 bprice66 bprice67 bprice68 bprice69 bprice70 ///
		bprice78 bprice79 bprice80 ///
		bprice81 bprice82 bprice83 bprice84 bprice85 bprice86 bprice87 bprice88 bprice89 bprice90 ///
		bprice91
foreach var of varlist bprice1-bprice91 {
	ren `var' `var'_reg
}

* Label variables
la var region2 "Region ID"
*la var price1_reg "Price (UGX 2019) of X (region-level)"

save "$lsms_asset_prices/asset_busprices_reg", replace

* National dataset
use `assets7_nat', clear
append using `assets4_nat'
append using `assets5_nat'
append using `assets6_nat'
g nat = 1
ren price bprice
reshape wide bprice, i(nat) j(asset_id)
	/* Recall the items that were not included because they were not available, but are basically copies of another variable. Bring in here. */
	g bprice16 = 500000
	g bprice24 = 10000
	g bprice31 = 185000
	g bprice32 = 30000000
	g bprice33 = 1300000
	g bprice34 = 5000
	g bprice35 = 20000
	g bprice36 = 2000000
	g bprice37 = 5000000
	g bprice38 = 50000
	g bprice39 = 7400000
	g bprice40 = 250000
	g bprice42 = 400000
	g bprice43 = 74000000
	g bprice44 = 250000
	g bprice46 = 110000
	g bprice47 = 500000
	g bprice48 = 0
	g bprice49 = 1000000
	g bprice50 = 75000
	g bprice51 = 5000
	g bprice52 = 130000
	g bprice53 = 70000
	g bprice54 = 2000000
	g bprice55 = 1000000
	g bprice56 = 100000
	g bprice57 = 150000
	g bprice58 = 4000000
	g bprice60 = 100000
	g bprice61 = 20000
	g bprice62 = 7000000
	g bprice63 = 400000
	g bprice66 = 440000
	g bprice67 = 100000
	g bprice68 = 300000
	g bprice70 = 100000
	g bprice84 = 25000
	g bprice86 = 13000
	g bprice87 = 300000
	g bprice91 = 300000

	g bprice41 = bprice16
	g bprice80 = bprice26
	g bprice23 = bprice21
	g bprice59 = bprice28
	g bprice18 = bprice17
	g bprice6 = bprice4
	g bprice7 = bprice4
	g bprice13 = bprice4
	g bprice27 = bprice4
	g bprice29 = bprice4
	g bprice30 = bprice4
	g bprice64 = bprice4
	g bprice11 = bprice10
	g bprice69 = bprice10
	g bprice22 = bprice5
	g bprice12 = bprice8
	g bprice14 = bprice8
	g bprice15 = bprice8
	g bprice82 = bprice8
	g bprice25 = bprice19
		order nat bprice1 bprice2 bprice3 bprice4 bprice5 bprice6 bprice7 bprice8 bprice9 bprice10 ///
		bprice11 bprice12 bprice13 bprice14 bprice15 bprice16 bprice17 bprice18 bprice19 bprice20 ///
		bprice21 bprice22 bprice23 bprice24 bprice25 bprice26 bprice27 bprice28 bprice29 bprice30 ///
		bprice31 bprice32 bprice33 bprice34 bprice35 bprice36 bprice37 bprice38 bprice39 bprice40 ///
		bprice41 bprice42 bprice43 bprice44 bprice46 bprice47 bprice48 bprice49 bprice50 ///
		bprice51 bprice52 bprice53 bprice54 bprice55 bprice56 bprice57 bprice58 bprice59 bprice60 ///
		bprice61 bprice62 bprice63 bprice64 bprice65 bprice66 bprice67 bprice68 bprice69 bprice70 ///
		bprice78 bprice79 bprice80 ///
		bprice81 bprice82 bprice83 bprice84 bprice85 bprice86 bprice87 bprice88 bprice89 bprice90 ///
		bprice91
foreach var of varlist bprice1-bprice91 {
	ren `var' `var'_nat
}

* Label variables
la var nat "National ID"
*la var price1_nat "Price (UGX 2019) of X (national-level)"

save "$lsms_asset_prices/asset_busprices_nat", replace
