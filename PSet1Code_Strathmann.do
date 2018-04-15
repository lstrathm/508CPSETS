********* WWS508c PS# *********
*  Spring 2018			      *
*  Author : First Last        *
*  Email: email@princeton.edu *
*******************************
//any disclaimer...//
//credit: the rest of group members' names//

clear all
cd "/Users/lstrathm/Downloads/PS1"
use project_star_ps1.dta
//below command: you don't have to keep pressing the space bar when stata pauses//
set more off

********************************************************************************
**                                   P1                                       **
********************************************************************************
//comment code if it needs some explanations//
**code goes here (without the stars before and after, of course)**
** Variable names: ssex srace sesk tcombssk treadssk tmathssk cltypek classid hdegk totexpk tracek schtypek

sum 
tab ssex
tab srace
tab sesk
tab tcombssk
tab treadssk
tab tmathssk
tab cltypek
tab classid
tab hdegk
tab totexpk 
tab tracek 
tab schtypek

**Race by classroom type
tab srace cltypek
tab srace cltypek, column

**Gender by classroom type
tab ssex cltypek
tab ssex cltypek, column

** student race by teacher degree
tab srace hdegk
tab srace hdegk, column row
tab srace hdegk, row

**
tab hdegk tracek

** Chi squared to test independence 
tab cltypek srace, chi2
tab cltypek ssex, chi2
tab cltypek sesk, chi2

*** intepreation: Failing to reject the null - can't say that they're independent 






********************************************************************************
**                                   P2                                       **
********************************************************************************
//comment//
**code**
***baseline randomiZation check

** Chi squared to test independence 
tab cltypek srace, chi2
tab cltypek ssex, chi2
tab cltypek sesk, chi2
*** intepreation: Failing to reject the null - can't say that they're independent 



*** intepreation: Failing to reject the null - can't say that they're independent 


********************************************************************************
**                                   P3                                       **
********************************************************************************
//comment//
**code**

sum tcombssk if cltypek==1
sum tcombssk if cltypek==2
sum tcombssk if cltypek==3
sum treadssk if cltypek==1
sum treadssk if cltypek==2
sum treadssk if cltypek==3
sum tmathssk if cltypek==1
sum tmathssk if cltypek==2
sum tmathssk if cltypek==3
tabstat treadssk tmathssk, by(cltypek) stat(n, mean, sd)

*****
** Mean math large = mean math small
** Mean math large= 490.9913; 49.51013
** Mean math small= 

****See handwritten notes

gen smallclass1 = cltypek
gen smallclass2 = cltypek

label values smallclass1 cltypek
label values smallclass2 cltypek

***ttest comparing small to large
replace smallclass1 = . if smallclass1 == 3
ttest treadssk, by(smallclass1)
ttest tmathssk, by(smallclass1)

***Ttest comparing regular to regular+aid
replace smallclass2 = . if smallclass2 == 1
ttest treadssk, by(smallclass2)
ttest tmathssk, by(smallclass2)




** Mean read large = mean read small
** 
** 


********************************************************************************
**                                   P4                                   **
********************************************************************************
//comment//
**code**

***** Seee handwritten notes

*** make variable with replacement values
*** 





********************************************************************************
**                                   P5                                       **
********************************************************************************
//comment//
**code**

***Class size differential effect by:

tabstat tcombssk if cltypek==1, by(srace) stat(n, mean, sd)
tabstat tcombssk if cltypek==2, by(srace) stat(n, mean, sd)
tabstat tcombssk if cltypek==3, by(srace) stat(n, mean, sd)
tabstat tcombssk if cltypek==1, by(sesk) stat(n, mean, sd)
tabstat tcombssk if cltypek==2, by(sesk) stat(n, mean, sd)
tabstat tcombssk if cltypek==3, by(sesk) stat(n, mean, sd)
tabstat tcombssk if cltypek==1, by(schtypek) stat(n, mean, sd)
tabstat tcombssk if cltypek==2, by(schtypek) stat(n, mean, sd)
tabstat tcombssk if cltypek==3, by(schtypek) stat(n, mean, sd)


***Starting point within classroom size

***thing that we need to vary is class room - how much does you changing 
**classsize effect different communities

**Black vs. white

*1) Effect of class size on test for black students
****T-test of mean test for black students in large vs. small 
*2) effecting of class size on test for white students
****T-test of mean test for white students in large vs. small
*3) Compare

gen blackwhite = srace
replace blackwhite = . if blackwhite == 6

**1)ttest of test scores for black students small v large class
ttest tcombssk if blackwhite == 2, by(smallclass1)
***Difference = 15.84935; standard error: 4.269511; t= 3.7122; n= 1,177

**2)ttest of test scores for white students small v large class
ttest tcombssk if blackwhite == 1, by(smallclass1)
***Difference = 12.79163; standard error: 2.929459; t= 4.3665; n= 2,545

***Comparing difference of test scores for blacks vs. whites? Is the difference statistically significant?
di 15.84935-12.79163
**3.05772
di 3.05772/(4.269511+2.929459)
** t-stat - .4247441


**ttest 
 

**Poor vs. non-poor


*1) Effect of class size on test for poor students
*2) effecting of class size on test for nonpoors students
*3) Compare





**Rural vs. non-rural
*1) Effect of class size on test for rural students
*2) effecting of class size on test for nonrural students
*3) Compare




********************************************************************************
**                                   P# 6                                     **
********************************************************************************
//comment//
**code**

preserve 

collapse tcombssk treadssk tmathssk smallclass1 smallclass2, by(classid)
ttest treadssk, by(smallclass1)
ttest tmathssk, by(smallclass1)

restore

**compare 
ttest treadssk, by(smallclass1)
ttest tmathssk, by(smallclass1)

********************************************************************************
**                                   P# 7                                   **
********************************************************************************
//comment//
**code**


ttest tcombssk, by(smallclass1) unequal
ttest tcombssk, by(blackwhite) unequal
ttest tcombssk, by(ssex) unequal
ttest tcombssk, by(sesk) unequal




