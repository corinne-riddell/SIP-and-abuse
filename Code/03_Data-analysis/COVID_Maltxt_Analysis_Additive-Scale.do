/*****************************************************************************************/
/** Program: COVID_Maltxt_Analysis_Additive_Scale										**/
/** Created by: Kriszta Farkas and Corinne Riddell			    						**/
/** Date created: 04/07/2021															**/
/** Date updated: June 22, 2021										    	            **/
/** Purpose: COVID Maltxt Analysis														**/
/**																						**/
/** 			 																		**/
/*****************************************************************************************/

* read in data
import delimited "/Users/corinneriddell/Library/CloudStorage/Box-Box/Google-search-data/Data-for-Analysis/Analytic Data Set/Analytic_Data_with_leads.csv", encoding(ISO-8859-1) clear

tab year 
tab weekaftersip_v1

tab stateabbr
* remove US level data from analysis
drop if stateabbr=="US"

* drop 2017 data for all analyses except for negative control
drop if year==2017

tab weekaftersip_v1 lead_lag4

* restrict post period to 10 weeks of SIP
drop if weekaftersip_v1 > 11

tab(lead_lag4)
tab(weekaftersip_v1) if year==2020
tab week_of_year if year == 2020

* check week_of_year in 2020 for ever vs. never SIP states
tabulate week_of_year if year==2020 & eversip==1
* note: range = 1-25
tabulate week_of_year if year==2020 & eversip==0
* note: as is, range = 1-34

* drop 25-34 weeks of year for 2020 for never-SIP states
drop if year==2020 & week_of_year > 25 & eversip==0
* note: 45 observations were dropped

* create numeric identifier for state
egen statenum = group(stateabbr)
tab(statenum)

* create numeric outcome and population variables
destring orig_avg, replace ignore(NA)
destring normalized_avg_and, replace ignore(NA)
destring pop_avg_2018_2019, replace ignore(NA)

* create 5-week-period after/of SIP variable to improve precision
sort stateabbr year week_of_year
recode weekaftersip_v1 (0 = 0) (1/5 = 1) (5/max = 2), gen(five_wks_after)
tabulate weekaftersip_v1 five_wks_after

************ LOOK AT DISTRIBUTION OF OUTCOME VARIABLE ************
*hist(orig_avg)
*hist(normalized_avg_and)

************ ADDITIVE MODEL ******************************************
* allows us to incorporate weights for each state

* additive version of the main model (weighted)
regress orig_avg i.year i.statenum i.week_of_year i.lead_lag4 [weight = pop_avg_2018_2019], vce(robust)

* additive version of the main model (unweighted)
regress orig_avg i.year i.statenum i.week_of_year i.lead_lag4, vce(robust)

predict p1

************ INCOPORATE STATE-SPECIFIC YEAR TRENDS *****************************

* additive version of the main model with state specific linear time trends (unweighted)
regress orig_avg i.year i.statenum i.statenum##i.year i.week_of_year i.lead_lag4, vce(robust)

predict p2

* additive version of the main model with state specific linear time trends (weighted)
regress orig_avg i.year i.statenum i.statenum##i.year i.week_of_year i.lead_lag4 [weight = pop_avg_2018_2019], vce(robust)

************ SENSITIVITY ANALYSIS - NORMALIZED GOOGLE TRENDS VALUE ************
** additive fixed effects model: 
* fixed effects on year and week of year (time), state;
* state specific time trends (interaction between state and year); 
* lead/lags for SIP indexed by week (i.e., time-varying txt indicator);
* robust standard errors for correct statistical inference
* "AND"-NORMALIZED VALUE - incorporating normalization by creating new outcome 
* normalized_avg_and = (orig_avg/orig_and_value)*1M

* 1) weighted by population size
regress normalized_avg_and i.year i.statenum i.statenum##i.year i.week_of_year i.lead_lag4 [weight = pop_avg_2018_2019], vce(robust)

* 2) unweighted by population size
regress normalized_avg_and i.year i.statenum i.statenum##i.year i.week_of_year i.lead_lag4, vce(robust)

************ SENSITIVITY ANALYSIS - DROP STATES WITH ANY MISSINGS (n=9)*********
** additive fixed effects model): 
* fixed effects on year and week of year (time), state;
* state specific time trends (interaction between state and year); 
* lead/lags for SIP indexed by week (i.e., time-varying txt indicator);
* robust standard errors for correct statistical inference

* drop states with missings
list stateabbr if orig_avg == .
* HI, ID, KS, ME, NE (control), NH, NM, UT (control), WV
drop if stateabbr=="HI"
drop if stateabbr=="ID"
drop if stateabbr=="KS"
drop if stateabbr=="ME"
drop if stateabbr=="NE"
drop if stateabbr=="NH"
drop if stateabbr=="NM"
drop if stateabbr=="UT"
drop if stateabbr=="WV"

* 1) weighted by population size
regress orig_avg i.year i.statenum i.statenum##i.year i.week_of_year i.lead_lag4 [weight = pop_avg_2018_2019], vce(robust)

* 2) unweighted by population size
regress orig_avg i.year i.statenum i.statenum##i.year i.week_of_year i.lead_lag4, vce(robust)

************ SENSITIVITY ANALYSIS - DROP STATES WITH ANY CHANGE IN MISSINGNESS PRE-/POST-SIP ************

* drop relevant states
* HI, ID, KS, ME, NE (control), NH, NM, UT (control), WV, NV, SC, 
* MS, WI, IA (control), KY, MN, CO, MA, NC, LA, AR (control), OK (control),
* CT, AL, MD, OR, TN

* these are already dropped from the previous analysis but listing them here 
* for completion
drop if stateabbr=="HI"
drop if stateabbr=="ID"
drop if stateabbr=="KS"
drop if stateabbr=="ME"
drop if stateabbr=="NE"
drop if stateabbr=="NH"
drop if stateabbr=="NM"
drop if stateabbr=="UT"
drop if stateabbr=="WV"

drop if stateabbr=="NV"
drop if stateabbr=="SC"
drop if stateabbr=="MS"
drop if stateabbr=="WI"
drop if stateabbr=="IA"
drop if stateabbr=="KY"
drop if stateabbr=="MN"
drop if stateabbr=="CO"
drop if stateabbr=="MA"

drop if stateabbr=="NC"
drop if stateabbr=="LA"
drop if stateabbr=="AR"
drop if stateabbr=="OK"
drop if stateabbr=="CT"
drop if stateabbr=="AL"
drop if stateabbr=="MD"
drop if stateabbr=="OR"
drop if stateabbr=="TN"

*restrict post-SIP period further to ensure exposure variation - no exposure variation by week 15 of 2020, so restricting to week 14
drop if year==2020 & week_of_year >14 //140 observations deleted

* Have only 8 and 3 states contributing to 1 and 2 weeks after SIP introduced 
* after this deletion
tab(lead_lag4) if year==2020
*  lead_lag4 |      Freq.     Percent        Cum.
*------------+-----------------------------------
*          0 |         35       16.67       16.67
*          1 |         15        7.14       23.81
*          2 |         15        7.14       30.95
*          3 |         15        7.14       38.10
*          4 |         15        7.14       45.24
*          5 |         15        7.14       52.38
*          6 |         15        7.14       59.52
*          7 |         15        7.14       66.67
*          8 |         15        7.14       73.81
*          9 |         15        7.14       80.95
*         10 |         15        7.14       88.10
*         11 |         14        6.67       94.76
*         12 |          8        3.81       98.57
*         13 |          3        1.43      100.00
*------------+-----------------------------------
*      Total |        210      100.00

list stateabbr week_of_year weekaftersip_v1 sip_v1 lead_lag4 if weekaftersip_v1 >0

tab sip_v1
*tab sip_v1
*
*     SIP_v1 |      Freq.     Percent        Cum.
*------------+-----------------------------------
*          0 |      1,745       98.59       98.59
*          1 |         25        1.41      100.00
*------------+-----------------------------------
*      Total |      1,770      100.00

* 1) weighted by population size
regress orig_avg i.year i.statenum i.statenum##i.year i.week_of_year i.lead_lag4 [weight = pop_avg_2018_2019], vce(robust)

* 2) unweighted by population size
regress orig_avg i.year i.statenum i.statenum##i.year i.week_of_year i.lead_lag4, vce(robust)
