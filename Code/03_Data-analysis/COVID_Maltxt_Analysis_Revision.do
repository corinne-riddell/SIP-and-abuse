* read in data
import delimited "/Users/corinneriddell/Library/CloudStorage/Box-Box/Google-search-data/Data-for-Analysis/Analytic Data Set/Analytic_Data_with_leads_and_new_exposure_for_RR2.csv", encoding(ISO-8859-1) clear

* do we want to drop post time after SIP turns back off?


* drop 25-34 weeks of year for 2020 for ALL states (was only never treated in previous analysis)
drop if year==2020 & week_of_year > 25
* note: 378 observations were dropped (used to be 45)

* create numeric identifier for state
egen statenum = group(stateabbr)
tab(statenum)

* create numeric outcome and population variables
destring orig_avg, replace ignore(NA)
destring normalized_avg_and, replace ignore(NA)
destring pop_avg_2018_2019, replace ignore(NA)

************ INCOPORATE END OF SIP INTO EXPOSURE VAR ***************************

* additive version of the main model with state specific linear time trends (unweighted)
regress orig_avg i.year i.statenum i.statenum##i.year i.week_of_year i.lead_lag4_rr, vce(robust)

* additive version of the main model with state specific linear time trends (weighted)
regress orig_avg i.year i.statenum i.statenum##i.year i.week_of_year i.lead_lag4_rr [weight = pop_avg_2018_2019], vce(robust)


************ INCORPORATE WEAK VS STRONG BAN INFO ******************************
clear

* read in data
import delimited "/Users/corinneriddell/Library/CloudStorage/Box-Box/Google-search-data/Data-for-Analysis/Analytic Data Set/Analytic_Data_with_leads_and_new_exposure_for_RR3.csv", encoding(ISO-8859-1) clear


* drop 25-34 weeks of year for 2020 for ALL states (was only never treated in previous analysis)
drop if year==2020 & week_of_year > 25
* note: 378 observations were dropped (used to be 45)

* create numeric identifier for state
egen statenum = group(stateabbr)
tab(statenum)

* create numeric outcome and population variables
destring orig_avg, replace ignore(NA)
destring normalized_avg_and, replace ignore(NA)
destring pop_avg_2018_2019, replace ignore(NA)

* additive version of the main model with state specific linear time trends (weighted)
regress orig_avg i.year i.statenum i.statenum##i.year i.week_of_year i.weak_ban_ind i.strong_ban_ind [weight = pop_avg_2018_2019], vce(robust)
