********* WWS508c PS# *********
*  Spring 2018			      *
*  Author : Luke Strathmann   *
*  Email: ls21@princeton.edu  *
*******************************
//any disclaimer...//
//credit: the rest of group members' names//

clear all
cd "/Users/lstrathm/Desktop/Princeton/Spring 2018/Metrics/ps2"
//below command: you don't have to keep pressing the space bar when stata pauses//
set more off


set more off
set matsize 10000
capture log close
log using PS2.log, replace

*Download outreg2
ssc install outreg2


********************************************************************************
**                                   P1                                       **
********************************************************************************
//comment code if it needs some explanations//
**code goes here (without the stars before and after, of course)**


**Interpreation: Returns to Schooling. i.e., for each additional year of//
// schooling, how much additional income an indivual can expect, on average//
// " The Mincer equation provides estimates of the average monetary returns of ]
// one additional year of education."
// "a pricing equation or hedonic wage function revealing how the labor market //
//rewards produc- tive attributes like schooling and work experience"
// from: http://athena.sas.upenn.edu/petra/papers/llmincer.pdf
// estimates private not public benefit, yet schooling often publicly funded



///Squared- the effect of experience changes when you get more experience
// Possible that the additional $$ from experience increases at descreasing rate
// 




********************************************************************************
**                                   P2                                       **
********************************************************************************
//comment//
**code**
**//Run dat file//
run cps08

gen hourlywage = (incwage / (uhrswork * wkswork1)) 
label variable hourlywage "hourly wage"

gen loghourlywage = ln(incwage / (uhrswork * wkswork1)) 
label variable loghourlywage "Log hourly wage"


**Generate race variables
gen white=1 if race==100
replace white=0 if race!=100
gen black=1 if race==200
replace black=0 if race!=200
gen other=1 if race > 200
replace other=0 if race<=200

label variable white "White race dummy"
label variable black "Black race dummy"
label variable other "Other race dummy"

//generate education variable for years of schooling
gen educyears = educ
label variable educyears "Years of education"

#delimit ;
recode educyears
	0	=	0
	1	=	0
	2	=	.5
	10	=	2.5
	11	=	1
	12	=	2
	13	=	3
	14	=	4
	20	=	5.5
	21	=	5
	22	=	6
	30	=	7.5
	31	=	6
	32	=	8
	40	=	9
	50	=	10
	60	=	11
	70	=	12
	71	=	11.5
	72	=	12
	73	=	12
	80	=	13
	81	=	14.5
	90	=	14
	91	=	14
	92	=	14
	100	=	15
	110	=	16
	111	=	16
	120	=	17
	121	=	17
	122	=	18
	123	=	18
	124	=	19
	125	=	20
	999	=	.
;
#delimit cr


// generage potential experience variable
gen exper = (age - educyears - 5)
label variable exper "Potential experience"

// generate exper^2 variable
gen exper2 = exper^2
label variable exper2 "Squared potential experience"

// drop anyone who worked less than 35 hours in a typical week
//and drop anyone with missing wages or education
drop if uhrswork < 35
drop if incwage == . | educyears == .

// summarize the data
sum educyears
gen educyearssd = r(sd)
label variable educyearssd "SD educyears"
di educyearssd

sum loghourlywage
gen loghourlywagesd = r(sd)
label variable loghourlywagesd "SD loghourlywages"
di loghourlywagesd

gen male=1 if sex==1
replace male=0 if male==.

***Summary stats (SEXY TABLE - THANKS ALEX)
qui estpost sum
esttab using PS2_Summarytable.xls, label cells("count mean sd min max") booktabs replace



********************************************************************************
**                                   P3                                       **
********************************************************************************
//comment//
**code**

reg loghourlywage educyears, r beta

//Based on your regression coefficient and the summary statistics in your answer 
//to question(2), calculate the correlation between education and the log hourly 
//wage.
di _b[educyears]*(educyearssd/loghourlywagesd)


//Confirm that your calculation is correct using Stata’s corr command
corr loghourlywage educyears

// Show mathematically how the correlation coefficient relates to the regression
//coefficient and the R2
di (_b[educyears]*(educyearssd/loghourlywagesd))^2


**Check that correlation squared is R-squared
di (0.4011)^2



********************************************************************************
**                                   P4                                       **
********************************************************************************
//comment//
**code**


//Estimate the Mincerian Wage Equation. What is the estimated return to
//education?
reg loghourlywage educyears exper exper2, r
outreg2 using PS2_Outreg.xls, ctitle (CPS Short) replace label

//Frisch-Waugh Theorem
reg loghourlywage exper exper2
predict u_loghourlywage, resid

reg educyears exper exper2
predict u_educyears, resid

reg u_loghourlywage u_educyears
outreg2 using PS2_Frish-Waugh.xls, ctitle (CPS Short) replace label

reg loghourlywage educyears exper exper2
outreg2 using PS2_Frish-Waugh.xls, ctitle (CPS Short) append label


********************************************************************************
**                                   P5                                       **
********************************************************************************
//comment//
**code**


//Estimate an “extended” Mincerian Wage Equation that controls for race and sex.
local controls white black male

reg loghourlywage educyears exper exper2 `controls', r 	
outreg2 using PS2_Outreg.xls, ctitle(CPS Extended) addtext(Race and Sex Controls,X)append label

********************************************************************************
**                                   P6                                       **
********************************************************************************
//comment//
**code**


reg loghourlywage educyears exper exper2 male black other, r 	
sort exper
gen p_ln_hr_wageX =  _b[exper]*exper + _b[exper2]*exper2 + _b[educyears]*13.74004 + _b[male]*.565497 +_b[black]*.108705 + _b[other]*.084295 + _b[_cons] 
				  
sum p_ln_hr_wageX

graph twoway (line p_ln_hr_wageX exper)


********************************************************************************
**                                   P7                                       **
********************************************************************************
//comment//
**code**


//run NLSY data.
use nlsy79

label variable educ "Years of education"
label variable male "Gender"

//Generate a log hourly wage variable and a “potential experience” variable.
gen loghourlywage = ln(laborinc07 / hours07) 
label variable loghourlywage "Log hourly wage"

gen hourlywage = (laborinc07 / hours07)
label variable hourlywage "hourly wage"

//Drop anyone who worked less than 35 hrs/week for 50 weeks.
drop if hours07 < (35*50)

//Summarize the data.
sum loghourlywage

********************************************************************************
**                                   P8                                       **
********************************************************************************
//comment//
**code**


//Estimate an extended Mincerian Wage Equation with controls for race/ethnicity 
// and sex.
gen age07 = (age79 + 28)

// generage potential experience variable
gen exper = (age07 - educ - 5)
label variable exper "Potential experience"

// generate exper^2 variable
gen exper2 = exper^2
label variable exper2 "Squared potential experience"

//Estimate an “extended” Mincerian Wage Equation that controls for race and sex.
local controls black hisp male

reg loghourlywage educ exper exper2 `controls', r
reg loghourlywage educ exper exper2 black hisp male, r
outreg2 using PS2_Outreg.xls, ctitle(NSLY Extended) addtext(Race and Gender Controls,X)append label 	

//How do your estimates of the return to education and the return to experience 
//compare to the estimates from the CPS? If there are differences, hypothesize 
//why.
//See submitted assignment.

********************************************************************************
**                                   P9                                       **
********************************************************************************
//comment//
**code**

********************************************************************************
**                                   P10                                       **
********************************************************************************
//comment//
**code**

reg loghourlywage educ exper exper2 black hisp male foreign urban14 mag14 news14 lib14 educ_mom educ_dad numsibs, r
