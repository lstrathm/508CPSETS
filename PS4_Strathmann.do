********* WWS508c PS# *********
*  Spring 2018			      *
*  Author : Luke Strathmann   *
*  Email: ls21@princeton.edu  *
*******************************
//credit: Joelle Gamble, Chris Austin, Somya Baja, Luke Strathmann, Ana Korolkova//

clear all

*Set directory, dta file, etc.
cd "/Users/lstrathm/Desktop/Princeton/Spring 2018/Metrics/ps4"
**cd "C:\Users\TerryMoon\Dropbox\Teaching Princeton\wws508c 2018S\ps\ps4"
use wws508c_deming.dta


set more off
set matsize 800
capture log close
pause on
log using PS4.log, replace

*Download outreg2
ssc install outreg2

**find missing values
ssc install mdesc
mdesc

********************************************************************************
**                                   P1                                       **
********************************************************************************

sum
tab head_start

graph bar, over(head_start) title("Head Strart Participation")
graph bar (count), over(head_start)
	
*generate variable for mom education levels
gen momdedcat = 0 
replace momdedcat = 1 if momed == 12
replace momdedcat = 2 if momed > 12
replace momdedcat = 3 if momed == 16 
replace momdedcat = 4 if momed > 16 
replace momdedcat = . if momed == .

label variable momdedcat "Educational Attainment"
label define ed 0 "some school" 1 "completed high school" 2 "some college " 3 "completed college" 4 "Post-Grad"
label values momdedcat ed

tab head_start momdedcat, co row

graph bar, over(momdedcat) title("Mom Education")

tab lnbw

**generate lnbw percentile for crosstab vs. 
gen lnbw_pctile = 0
replace lnbw_pctile = 1 if lnbw < 4.60517
replace lnbw_pctile = 2 if (lnbw > 4.60517) & (lnbw < 4.70953)
replace lnbw_pctile = 3 if (lnbw > 4.70953) & (lnbw < 4.787492)
replace lnbw_pctile = 4 if (lnbw > 4.787492) & (lnbw < 4.875197)
replace lnbw_pctile = 5 if lnbw > 4.875197
replace lnbw_pctile = . if lnbw == .
label variable lnbw_pctile "Birth Weight Percentile Bins"
label define lbw 1 "0-20" 2 "20-40" 3 "40-60" 4 "60-80" 5 "80-100"
label values lnbw_pctile lbw

tab hsgrad

foreach var in male black hispanic momdedcat lnbw_pctile hsgrad somecoll {
	tab head_start `var', co
	}


********************************************************************************
**                                   P2                                       **
********************************************************************************

*OLS 
reg comp_score_5to6 head_start

*OLS, robust
reg comp_score_5to6 head_start, r

***OLS with cluster robust standard errors
reg comp_score_5to6 head_start, r cluster(mom_id)

***OLS with controls
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
reg comp_score_5to6 head_start `controls', r cluster(mom_id)


********************************************************************************
**                                   P3                                      **
********************************************************************************

**Set panel data so Stata knows we're doing family level FE
xtset mom_id

**w/o controls
xtreg comp_score_5to6 head_start, i(mom_id) fe

**with controls
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg comp_score_5to6 head_start `controls', i(mom_id) fe


********************************************************************************
**                                   P4                                       **
********************************************************************************

***See answer explanation
***Wasn't clear on how to test this assumption

********************************************************************************
**                                   P5                                       **
********************************************************************************


**5-6
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg comp_score_5to6 head_start `controls', i(mom_id) fe
outreg2 using PS4_Q5_Outreg.xls, ctitle(5-6) replace label

**7-10
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg comp_score_7to10 head_start `controls', i(mom_id) fe
outreg2 using PS4_Q5_Outreg.xls, ctitle(7-10) append label

**1114
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg comp_score_11to14 head_start `controls', i(mom_id) fe
outreg2 using PS4_Q5_Outreg.xls, ctitle(11-14) append label


********************************************************************************
**                                   P6                                       **
********************************************************************************

**Other outcomes

**Repeat
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg repeat head_start `controls', i(mom_id) fe
outreg2 using PS4_Q6_Outreg.xls, ctitle(Repeat) replace label

**HS grad
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg hsgrad head_start `controls', i(mom_id) fe
outreg2 using PS4_Q6_Outreg.xls, ctitle(HS Grad) append label

**College
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg somecoll head_start `controls', i(mom_id) fe
outreg2 using PS4_Q6_Outreg.xls, ctitle(Some College) append label

**health
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg fphealth head_start `controls', i(mom_id) fe
outreg2 using PS4_Q6_Outreg.xls, ctitle(Health Status) append label


********************************************************************************
**                                   P7                                       **
********************************************************************************

***Interactions: race

**Repeat
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg repeat i.head_start##i.black `controls', i(mom_id) fe
outreg2 using PS4_Q7_Outreg.xls, ctitle(Repeat_black) replace label

**HS grad
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg hsgrad i.head_start##i.black `controls', i(mom_id) fe
outreg2 using PS4_Q7_Outreg.xls, ctitle(hsgrad_black) append label

**College
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg somecoll i.head_start##i.black `controls', i(mom_id) fe
outreg2 using PS4_Q7_Outreg.xls, ctitle(somecoll_black) append label


**health
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg fphealth i.head_start##i.black `controls', i(mom_id) fe
outreg2 using PS4_Q7_Outreg.xls, ctitle(fphealth_black) append label


***Interactions: Gender

**Repeat
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg repeat i.head_start##i.male `controls', i(mom_id) fe
outreg2 using PS4_Q7_Outreg.xls, ctitle(Repeat_male) append label


**HS grad
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg hsgrad i.head_start##i.male `controls', i(mom_id) fe
outreg2 using PS4_Q7_Outreg.xls, ctitle(hsgrad_male) append label


**College
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg somecoll i.head_start##i.male `controls', i(mom_id) fe
outreg2 using PS4_Q7_Outreg.xls, ctitle(somecoll_male) append label


**health
local controls male black hispanic momed dadhome_0to3 lninc_0to3 lnbw
xtreg fphealth i.head_start##i.male `controls', i(mom_id) fe
outreg2 using PS4_Q7_Outreg.xls, ctitle(fbhealth_male) append label


********************************************************************************
**                                   P8                                       **
********************************************************************************

***See answer file
