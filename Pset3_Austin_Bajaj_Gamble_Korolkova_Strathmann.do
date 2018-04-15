********* WWS508c PS# *********
*  Spring 2018			      *
*  Author : Luke Strathmann   *
*  Email: ls21@princeton.edu  *
*******************************
//credit: Joelle Gamble, Chris Austin, Somya Baja, Luke Strathmann, Ana Korolkova//

clear all

*Set directory, dta file, etc.
cd "C:\Users\TerryMoon\Dropbox\Teaching Princeton\wws508c 2018S\ps\ps2"
use nhis2000.dta


set more off
set matsize 800
capture log close
pause on
log using PS3.log, replace

*Download outreg2
ssc install outreg2

**find missing values
ssc install mdesc
mdesc

********************************************************************************
**                                   P1                                       **
********************************************************************************

tab health
gen healthbinary = (health == 4 | health == 5)
label variable healthbinary "Poor health = 1"
graph bar, over(health) title("Health Status")
graph bar (count), over(health)
tab mort5
graph bar, over(mort5) title("Mortality") blabel(bar)


foreach var in sex white black hisp other {
	tab healthbinary `var', co
	tab mort5 `var', co
	}

********************************************************************************
**                                   P2                                       **
********************************************************************************

***Generate age level averages for mortality
bysort age: egen male_mort_ave = mean(mort5) if sex == 1
bysort age: egen female_mort_ave = mean(mort5) if sex == 2

**Generate means for horizontal reference line
sum mort5 if sex == 1
local malemort = r(mean)
sum mort5 if sex == 2
local femalemort = r(mean)
di (`malemort')
di (`femalemort')

*Mortality status by age graph
sum mort5 if sex == 1
local malemort = r(mean)
di (`malemort')
line male_mort_ave age || line female_mort_ave age, legend(label(1 "Average Male Mortality") ///
 label(2 "Average Female Mortality")) ytitle("Died within 5 years of survey") ///
 title("Mortality Rate by Age") yline(.08865188, lcolor(navy)) yline(.0757157, lcolor(maroon))

***Generates age level averages for health binary
bysort age: egen male_health_ave = mean(healthbinary) if sex == 1
bysort age: egen female_health_ave = mean(healthbinary) if sex == 2

**Generate means for horizontal reference line
sum healthbinary if sex == 1
local malehealth = r(mean)
sum healthbinary if sex == 2
local femalehealth = r(mean)
di (`malehealth')
di (`femalehealth')

*Health status by age graph
line male_health_ave age || line female_health_ave age, legend(label(1 "Average Male Health Outcome") ///
label(2 "Average Female Health Outcome")) ytitle("Percent who reported poor or fair health") ///
title("Health Status by Age") yline(.13023819, lcolor(navy)) yline(.15310512, lcolor(maroon))


********************************************************************************
**                                   P3                                      **
********************************************************************************


***Generate categorical Income Variables
gen income = 0
replace income = 1 if faminc_20t75 == 1
replace income = 2 if faminc_gt75 == 1
replace income = . if faminc_20t75 == . & faminc_gt75 == .

label variable income "Family Income Level"
label define inc 0 "Under 20K" 1 "20-75K" 2 "Over 75k"
label values income inc

*generate variable for education levels
tab edyrs
gen edu = 0 
replace edu = 1 if edy == 12
replace edu = 2 if edy > 12
replace edu = 3 if edy == 16 
replace edu = 4 if edy > 16 
replace edu = . if edy == .

label variable income "Educational Attainment"
label define ed 0 "some school" 1 "completed high school" 2 "some college " 3 "completed college" 4 "Post-Grad"
label values edu ed

*generate variable for race
gen race = 0 
replace race = 1 if black == 1
replace race = 2 if hisp ==  1
replace race = . if black == . & hisp == .

label variable race "Race"
label define ethn 0 "Non-Hispanic white" 1 "Non-hispanic black" 2 "Hispanic"
label values race ethn


*fair/poor health by the level of family income.
graph bar healthbinary, over(income) ytitle(Percent self-report fair or poor health) title(Health Outcomes by Income Leavel)

*Mortality rate by the level of family income
graph bar mort5, over(income) ytitle(Mortality Rate) title(Mortality Rate by Income Level)

*fair/poor health by education level
graph bar healthbinary, over(edu) ytitle(Percent self-report fair or poor health) title(Health Outcomes by Education Level)

*Mortality by education level
graph bar mort5, over(edu) ytitle(Mortality Rate) title(Mortality Rate by Education Level)

*fair/poor health by race/ethnicity
graph bar healthbinary, over(race) ytitle(Percent self-report fair or poor health) title(Health Outcomes by Race)

*Mortality by race/ethnicity
graph bar mort5, over(race) ytitle(Mortality Rate) title(Mortality Rate by Race)



********************************************************************************
**                                   P4                                       **
********************************************************************************


*loop throug each dependent variable
foreach var of varlist healthbinary mort5 {

	*run linear probability model
	reg `var' age edu white black hisp faminc_gt75 faminc_20t75, r

	*run probit
	qui probit `var' age edu white black hisp faminc_gt75 faminc_20t75, r
	margins, dydx(*)
	
	*run logit
	qui logit `var' age edu white black hisp faminc_gt75 faminc_20t75, r
	margins, dydx(*)
}

reg mort5 age edu white black hisp faminc_gt75 faminc_20t75, r
outreg2 using PS3_Q4a_Outreg.xls, ctitle(Mortality LPM) addtext(LPM,X)replace label
predict p_ols

probit mort5 age edu white black hisp faminc_gt75 faminc_20t75, r
outreg2 using PS3_Q4a_Outreg.xls, ctitle(Mortality Probit) addtext(Probit,X)append label
predict p_probit

logit mort5 age edu white black hisp faminc_gt75 faminc_20t75, r
outreg2 using PS3_Q4a_Outreg.xls, ctitle(Mortality Probit) addtext(Probit,X)append label
predict p_logit

sum p_*
corr p_*


reg healthbinary age edu white black hisp faminc_gt75 faminc_20t75, r
outreg2 using PS3_Q4b_Outreg.xls, ctitle(Health Status LPM) addtext(LPM,X)append label
predict b_ols

probit healthbinary age edu white black hisp faminc_gt75 faminc_20t75, r
outreg2 using PS3_Q4b_Outreg.xls, ctitle(Health Status Probit) addtext(Probit,X)append label
predict b_probit

logit healthbinary age edu white black hisp faminc_gt75 faminc_20t75, r
outreg2 using PS3_Q4b_Outreg.xls, ctitle(Health Status Logit) addtext(Logit,X)append label
predict b_logit

sum b_*
corr b_*


***Marginal effects


probit mort5 age edu faminc_gt75 faminc_20t75 white hisp other, r
outreg2 using PS3_Q4c_Outreg.xls, ctitle(Mortality Probit MFX) addtext(Probit,X)replace label
mfx compute

logit mort5 age edu faminc_gt75 faminc_20t75 white hisp other, r
outreg2 using PS3_Q4c_Outreg.xls, ctitle(Mortality Logit MFX) addtext(Logit,X)append label
mfx compute

probit healthbinary age edu faminc_gt75 faminc_20t75 white hisp other, r
outreg2 using PS3_Q4c_Outreg.xls, ctitle(Health Status Probit MFX) addtext(Probit,X)append label
mfx compute 

logit healthbinary age edu faminc_gt75 faminc_20t75 white hisp other, r
outreg2 using PS3_Q4c_Outreg.xls, ctitle(Health Status Logit MFX) addtext(Logit,X)append label
mfx compute


***generate lowincome variable
gen lowincome = 1
replace lowincome = 0 if faminc_20t75 == 1
replace lowincome = 0 if faminc_gt75 == 1
replace lowincome = . if faminc_20t75 == . & faminc_gt75 == .

**re-run just to check 
probit mort5 age edu faminc_20t75 lowincome white hisp other, r
mfx compute



********************************************************************************
**                                   P5                                       **
********************************************************************************


*run logit
logit mort5 age edyr hisp black##faminc_g faminc_2, r

*get all the marginal effects
margins, dydx(*)

*get the marginal effect of income for high income blacks
margins black, dydx(faminc_g)




preserve

foreach var in age edu income race {
	su `var'
	gen `var'_mean = r(mean)
}

probit mort5 age edu income race, r

*For average person
di normprob(_b[age]*age_mean + _b[edu]*edu_mean + ///
	_b[income]*income_mean +_b[race]*race_mean + _b[_cons])

*Relative risk for high-income African-Americans = 2.6%
di normprob(_b[age]*age_mean + _b[edu]*edu_mean + ///
	_b[income]*3 +_b[race]*1 + _b[_cons])

*Relative risk for low-income whites = 5.1% / nearly 2x more likely than high-income blacks
di normprob(_b[age]*age_mean + _b[edu]*edu_mean + ///
	_b[income]*1 +_b[race]*3 + _b[_cons])

restore



********************************************************************************
**                                   P6                                       **
********************************************************************************


**Somya says nothing is causal.... [Please see Write up for full response]


********************************************************************************
**                                   P7                                       **
********************************************************************************

recode uninsured 2=0

local socioeconomic_controls edyrs race

corr uninsured lowincome

corr lowincome bmi uninsured cancerev cheartdiev heartattev hypertenev diabeticev alc5upyr smokev vig10fwk bacon

corr faminc_20t75 bmi uninsured cancerev cheartdiev heartattev hypertenev diabeticev alc5upyr smokev vig10fwk bacon

corr faminc_gt75 bmi uninsured cancerev cheartdiev heartattev hypertenev diabeticev alc5upyr smokev vig10fwk bacon 


*Step 2. Check significance of IV on DV without mediating variable. Testing 
*whether Uninsured is mediator. 
logistic healthbinary lowincome faminc_20t75 `socioeconomic_controls'
logistic mort5 lowincome faminc_20t75 `socioeconomic_controls'

*Step 3. Check significance of IV and Mediator after including Mediator in reg.
logistic healthbinary lowincome faminc_20t75 uninsured `socioeconomic_controls'
logistic mort5 lowincome faminc_20t75 uninsured `socioeconomic_controls'


***See Joelle's code for interaction - 


********************************************************************************
**                                   P8                                       **
********************************************************************************

preserve

oprobit mort5 health income edyrs race uninsured

*Generate predictions by self-reported health status, setting all the other
*covariates equal to their means:
foreach var in income edyrs race uninsured {
  sum `var'
  replace `var' = r(mean)	
  }

*we generate predicted probability, for mort5 = 1
predict p_hat_0, outcome(0)
predict p_hat_1, outcome(1)

*graph the results
sort health
twoway (connect p_hat_1 health), ///
       legend(label(1 "Died within 5 yrs")) ytitle(Predicted mortality probability) ///
	   title(Predicted probability of dying within 5 years)

restore


********************************************************************************
**                                   P9                                       **
********************************************************************************


local healthcontrols uninsured hypertenev diabeticev alc5upyr smokev vig10fwk

oprobit health lowincome faminc_20t75 edyrs black hisp other `healthcontrols'
mfx compute 

probit healthbinary lowincome faminc_20t75 edyrs black hisp other `healthcontrols'
mfx compute


********************************************************************************
**                                   P10                                       **
********************************************************************************

****

**Graph for black == 1
oprobit health income edyrs `healthcontrols' if black == 1

*Generate predictions by self-reported health status, setting all the other
*covariates equal to their means:
foreach var in edyrs uninsured {
  sum `var'
  replace `var' = r(mean)
  }

*Generate predicted probability of health status, by income category
predict b_hat_1, outcome(1)
predict b_hat_2, outcome(2)
predict b_hat_3, outcome(3)
predict b_hat_4, outcome(4)
predict b_hat_5, outcome(5)

*graph the results
sort income
twoway (connect b_hat_1 income)(connect b_hat_2 income)(connect b_hat_3 income) ///
	(connect b_hat_4 income)(connect b_hat_5 income), legend(label(1 "Excellent") ///
	label(2 "Very good") label(3 "Good") label(4 "Fair") label(5 "Poor")) ///
	ytitle(Predicted probability) title(Predicted probability of health status) ///
	subtitle(black == 1)

**run again for white == 1
oprobit health income edyrs `healthcontrols' if white == 1

*Generate predictions by self-reported health status, setting all the other
*covariates equal to their means:
foreach var in edyrs uninsured {
  sum `var'
  replace `var' = r(mean)
  }

*Generate predicted probability of health status, by income category
predict w_hat_1, outcome(1)
predict w_hat_2, outcome(2)
predict w_hat_3, outcome(3)
predict w_hat_4, outcome(4)
predict w_hat_5, outcome(5)

*graph the results
twoway (connect w_hat_1 income)(connect w_hat_2 income)(connect w_hat_3 income) ///
	(connect w_hat_4 income)(connect w_hat_5 income), legend(label(1 "Excellent") ///
	label(2 "Very good") label(3 "Good") label(4 "Fair") label(5 "Poor")) ///
	ytitle(Predicted probability) title(Predicted probability of health status) ///
	subtitle(white == 1)

*generate differences in predicted probability of health status between races, 
*by income category
forv i = 1/5 {
	gen diff_hat_`i' = w_hat_`i' - b_hat_`i'  
	}
	   
//How do they compare with the unadjusted histogram of self-reported health 
//status for blacks and whites?
sort income
twoway (connect diff_hat_1 income)(connect diff_hat_2 income) ///
	(connect diff_hat_3 income)(connect diff_hat_4 income)(connect diff_hat_5 income), ///
	legend(label(1 "Excellent") label(2 "Very good") label(3 "Good") ///
	label(4 "Fair") label(5 "Poor")) ytitle(Predicted Probability Differences) ///
	title(Differences in predicted health status) subtitle(between whites and blacks)

*In general, differences show that whites are more likely to be in very good or
*excellent health compared to blacks. Blacks are more likely to report poor,
*fair or good health compared to whites across all income categories.
	
graph bar healthbinary mort5, by(race) legend(label(1 "Poor or fair health") ///
	label(2 "Died within 5 years of survey"))

********** [Collaborated with Alex Kaufman to get below loop output - ///
***backed out individual margins to confirm results below.

*run ordered probit
oprobit health age edyr black hisp fam*, r
cap drop prob_health* 
cap drop avg_*
cap drop mat*

***back out individual margins***


margins, atmeans by(black) predict(outcome(1))
margins, atmeans by(black) predict(outcome(2))
margins, atmeans by(black) predict(outcome(3))
margins, atmeans by(black) predict(outcome(4))
margins, atmeans by(black) predict(outcome(5)) 


margins, atmeans by(white) predict(outcome(1))
margins, atmeans by(white) predict(outcome(2))
margins, atmeans by(white) predict(outcome(3))
margins, atmeans by(white) predict(outcome(4))
margins, atmeans by(white) predict(outcome(5))


*predict probabilities for each value and estimate probabilities
foreach race of varlist white black {
	forvalues i = 1/5 {
		*predict prob_health_`i'_`race' , outcome(`i') // predict prob of health == i
		*predict the average probability of health ranking i at the average values of other variables (by race)
		margins, atmeans by(`race') predict(outcome(`i')) 
		matrix mat_`i' = r(table) //retrieve value of estimate
		gen avg_`race'_`i'_p = mat_`i'[1,2] //create a new variable with that estimate
	}
}

graph bar avg_black*, ytitle(Average Predicted Probability) title(Predicted Health Ratings for Blacks) legend(label(1 "Excellent") label(2 "Very Good") label(3 "Good") label(4 "Fair") label(5 "Poor"))

graph bar avg_white*, ytitle(Average Predicted Probability) title(Predicted Health Ratings for Whites) legend(label(1 "Excellent") label(2 "Very Good") label(3 "Good") label(4 "Fair") label(5 "Poor"))

tab health if black==1
tab health if white==1

hist health if black == 1
hist health if white == 1


