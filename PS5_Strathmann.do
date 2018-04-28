********* WWS508c PS#5 *********
*  Spring 2018			      *
*  Author : Luke Strathmann   *
*  Email: ls21@princeton.edu  *
*******************************
//credit: Joelle Gamble, Chris Austin, Somya Baja, Luke Strathmann, Ana Korolkova//

clear all

*Set directory, dta file, etc.
cd "/Users/lstrathm/Desktop/Princeton/Spring 2018/Metrics/ps5"
**cd "C:\Users\TerryMoon\Dropbox\Teaching Princeton\wws508c 2018S\ps\ps5"
use wws508c_crime_ps5.dta


set more off
set matsize 800
capture log close
pause on
log using PS5.log, replace

*Download outreg2
ssc install outreg2

**find missing values
ssc install mdesc
mdesc

********************************************************************************
**                                   P1                                       **
********************************************************************************

***Label Variables
label variable birthyr "Birth year"
label variable draftnumber "Draft number (1-1000)"
label variable conscripted "Fraction conscripted"
label variable crimerate "Fraction with criminal record by 2005"
label variable property "Fraction with property crime conviction in 2000-2005"
label variable murder "Fraction with murder conviciton in 2000-2005"
label variable drug "Fraction with drug conviction in 2000-2005"
label variable sexual "Fraction with sex crime conviction in 2000-2005"
label variable threat "Fraction with threat conviction in 200-2005"
label variable arms "Fraction with weapons-related conviction in 2000-2005"
label variable whitecollar "Fraction with white collar crime conviction in 2000-2005"
label variable argentine "Fraction non-indigenous Argentinean"
label variable indigenous "Fraction indigenous Argentinean"
label variable naturalized "Fraction naturalized citizens"

sum

sum crimerate
tab crimerate
tab birthyr
tab conscripted

**Crimerate by year
sum crimerate if birthyr==1958
sum crimerate if birthyr==1959
sum crimerate if birthyr==1960
sum crimerate if birthyr==1961
sum crimerate if birthyr==1962

graph bar crimerate, over(birthyr) title("Avg Crimerate by Year")

**Conscription by year
sum conscripted if birthyr==1958
sum conscripted if birthyr==1959
sum conscripted if birthyr==1960
sum conscripted if birthyr==1961
sum conscripted if birthyr==1962

graph bar conscripted, over(birthyr) title("Avg Conscription rate by Year")

***	Chris is more elegant at making Loops than Luke
foreach i in 1958 1959 1960 1961 1962 {
	di "Concripted rate and Crime Rate for birth cohort `i'"
	su conscripted if birthyr == `i'
	su crimerate if birthyr == `i'	
	di ""
}

********************************************************************************
**                                   P2                                       **
********************************************************************************

sum argentine indigenous naturalized
tab argentine
** 72% have value 1
tab indigenous
** 81% have value 0
tab naturalized
**89% have value 0


**Basic OLS 
reg crimerate conscripted
reg crimerate conscripted, r

**Basic OLS w/ controls
reg crimerate conscripted argentine indigenous naturalized
reg crimerate conscripted argentine indigenous naturalized, r

**What about other crime rates?
**Note that these variabels do not show you # of crimes committed per person
**No way to distinguish repeat/serious offenders
outreg2 using PS5_Q2_Outreg.xls, ctitle(crimerate) replace label
reg arms conscripted argentine indigenous naturalized, r
outreg2 using PS5_Q2_Outreg.xls, ctitle(arms) append label
reg property conscripted argentine indigenous naturalized, r
outreg2 using PS5_Q2_Outreg.xls, ctitle(property) append label
reg sexual conscripted argentine indigenous naturalized, r
outreg2 using PS5_Q2_Outreg.xls, ctitle(sexual) append label
reg murder conscripted argentine indigenous naturalized, r
outreg2 using PS5_Q2_Outreg.xls, ctitle(murder) append label
reg threat conscripted argentine indigenous naturalized, r
outreg2 using PS5_Q2_Outreg.xls, ctitle(threat) append label
reg drug conscripted argentine indigenous naturalized, r
outreg2 using PS5_Q2_Outreg.xls, ctitle(drug) append label
reg whitecollar conscripted argentine indigenous naturalized, r
outreg2 using PS5_Q2_Outreg.xls, ctitle(whitecollar) append label

**Check against Chris w/ birth year dummies
foreach var of varlist arms-whitecollar {
	reg `var' conscripted argentine indigenous naturalized i.birthyr, r
	}

	
	
***Our parameter of interest is the effect of serving in the military on the 
***likelihood of developing a criminal record in adulthood. 
***Endogeneity of military / crime
********************************************************************************
**                                   P3                                       **
********************************************************************************

***code a variable that equals 1 if eligible, 0 if not:
gen cutoff = 0 
replace cutoff = 1 if birthyr == 1958 & draftnumber >= 175
replace cutoff = 1 if birthyr == 1959 & draftnumber >= 320
replace cutoff = 1 if birthyr == 1960 & draftnumber >= 341
replace cutoff = 1 if birthyr == 1961 & draftnumber >= 350
replace cutoff = 1 if birthyr == 1962 & draftnumber >= 320
lab var cutoff "1 if Eligible; 0 if not"

sum cutoff
tab cutoff

**THIS generates the same variable as Somya + Chris (who did it another way). Hooray!

********************************************************************************
**                                   P4                                       **
********************************************************************************

***Use Eligble as an Instrument -- > affect conscription, but likely not crime
*** B/c as good as random

***Does eligibilty predict conscription?
areg conscripted cutoff, robust absorb(birthyr)
areg conscripted cutoff argentine indigenous naturalized, robust absorb(birthyr)
regress conscripted cutoff if birthyr == 1958, robust
regress conscripted cutoff if birthyr == 1959, robust
regress conscripted cutoff if birthyr == 1960, robust
regress conscripted cutoff if birthyr == 1961, robust
regress conscripted cutoff if birthyr == 1962, robust
***Eligiblity is a large predictor of conscription

**The point estimate of the coefficient on draft Eligible from the pooled 
**sample indicates that the probability of serving in the military for men in 
**the cohorts 1958–1962 was 66 percentage points higher for those in the 
**draft-eligible group than for those in the draft-exempted group.

reg conscripted cutoff argentine indigenous naturalized i.birthyr, r

***YES we should control for birthyear b/c different yrs have different amounts
***of military activity. If you are conscripted during war vs. peace times
***your outcomes probably look very different

***Including ethnic composition doesn't seem to change results.


********************************************************************************
**                                   P5                                       **
********************************************************************************

*Compute IV coefficient as ratio of reduced form to first stage

**Get that first stage
reg conscripted cutoff argentine indigenous naturalized i.birthyr 
estimates store first_stage
reg crimerate cutoff argentine indigenous naturalized i.birthyr
estimates store reduced_form
suest first_stage reduced_form, robust
nlcom [reduced_form_mean]cutoff/[first_stage_mean]cutoff

**Effects of .0018, and then .0027 for 2sls

sum crimerate if cutoff==0
sum crimerate if cutoff==1
**baseline crime rates for non-conscripters == 6.8%

**Can scale to get probability: 

di 100*(.0026714 / .0680937)
**result: 3.92

**Military service signifiantly increases crime rates by 3.92 percent.

**our instrumental variable results suggest that conscription raises a 
**complier adult man’s lifetime probability of being prosecuted or 
**incarcerated by 0.27 percentage points from a baseline lifetime 
**rate of conviction of around 6.8 percent, to 7.07 percent

********************************************************************************
**                                   P6                                       **
********************************************************************************

**See above!!

********************************************************************************
**                                   P7                                       **
********************************************************************************

*2SLS estimate for main crime rate variable
ivregress 2sls crimerate (conscripted=cutoff) argentine indigenous naturalized i.birthyr,robust first
pause

***Our OLS estimate from earlier is 0.00232***, whereas now the IV LATE estimate is .00267
*** As we saw from Q4 above, eligibility significantly predicts conscription,
*** so this makes sense

**For the other crimes
foreach i of varlist crimerate-whitecollar {
	ivregress 2sls `i' (conscripted=cutoff) argentine indigenous naturalized i.birthyr,robust first
	pause
}

********************************************************************************
**                                   P8                                       **
********************************************************************************

**Assumptions are relevance and eligibility
**Relevance: Eligibility must correlate w/ / predict consciption
**Exogeneity: Eligibility is uncorrelated with the errors term!

ttest argentine, by(cutoff)
ttest indigenous, by (cutoff)
ttest naturalized, by (cutoff)

**For our available pre-treatment variables, there are no statistically 
**significant differences between the two groups. This suggests
**that the randomization of draft eligibility allows us to ignore treatment 
**assignment for post-treatment outcomes of interest.

***Could also F test
reg conscripted cutoff argentine indigenous naturalized i.birthyr, r
test argentine indigenous naturalized

***F = 1.72; P-value = 0.1606


********************************************************************************
**                                   P9                                       **
********************************************************************************

**"After the lottery, individuals were called for physical and mental examinations"
**^^^ This is potentially troublesome
** the results may be contaminated by the strategic behavior of those seeking 
***to avoid military service. In a world without strategic behavior and in 
**which all men received medical exami- nations, we would expect the proportion
** of individuals failing the medical examina- tion to be the same for the 
**draft-eligible and the draft-ineligible groups

***Unless we assume a constant treatment effect, the IV estimator does not recover ATE
**Under other assumptions, it recover LATES - the average effect of treatment
** on those individuals who treatment status is induced by the instrument 
** (i.e., by the dummy variable draft eligible) 

**these people conscripted BECAUSE they were assigned a high lottery #,
** BUT wouldn't have served otherwise. 

**the results would not generalize to the population of 
**volunteers or to the population of young men who under no circumstances would
** have passed, legitimately or not, the pre-induction medical examination.

***IN ABSENSE OF ALWAYS TAKERS, TOT == LATE
***But not SO FAST, we know there are some low lottery numbers who 
** are military people



********************************************************************************
**                                   P10                                      **
********************************************************************************

***You would have to make A LOT of assumptions to be able to take this study
**and try to convince Israel it's relevant to them. 

**I'm not willing to make these assumptions. 

**e.g., let's assume 90% of Israelis always want to consript - that completely 
**changes how we scalethink about our estimate our estimate 

**It's an entirely different miltiary system (i.e. "treatment); just as we see different 
** effects by birth years b/c of intensity of war, we'd expect to see different 
**effects in Israel b/c of different nature/culture of war. 


