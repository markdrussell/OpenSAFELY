version 16

/*==============================================================================
DO FILE NAME:			ITSA models for drugs
PROJECT:				EIA OpenSAFELY project
DATE: 					07/03/2022
AUTHOR:					J Galloway / M Russell
						adapted from C Rentsch										
DESCRIPTION OF FILE:	ITSA models for drugs
DATASETS USED:			main data file
DATASETS CREATED: 		ITSA figures and outputs
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)						
==============================================================================*/

**Set filepaths
global projectdir `c(pwd)'
di "$projectdir"

capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

global logdir "$projectdir/logs"
di "$logdir"

**Open a log file
cap log close
log using "$logdir/itsa_models_drugs.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_eia_all.dta", clear

set scheme plotplainblind

/*ITSA models for csDMARD prescriptions===========================================================================*/

*All patients must have 1) rheum appt and GP appt 2) 12m+ follow-up after rheum appt 3) 12m+ of registration after appt
keep if has_12m_post_appt==1

**Time from rheum appt to first csDMARD in GP record for RA, PsA and Undiff IA patients combined
preserve
keep if ra_code==1 | psa_code==1 | undiff_code==1
tab mo_year_appt csdmard_6m if mo_year_appt!=., row  //proportion of patients with csDMARD prescription in GP record within 6 months of diagnosis
eststo X: estpost tabstat csdmard_6m, stat(n mean) by(mo_year_appt_s)
esttab X using "$projectdir/output/tables/appt_to_csdmard_ITSA_table.csv", cells("count mean") collabels("Count" "Mean proportion") replace plain nomtitle noobs
collapse (mean) mean_csdmard_delay=csdmard_6m, by(mo_year_appt)

tsset mo_year_appt

**Newey Standard Errors with 5 lags
itsa mean_csdmard_delay if inrange(mo_year_appt, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Mean proportion prescribed csDMARD in primary care within 6 months", size(small) margin(small)) yscale(range(0.2(0.1)0.8)) ylabel(0.2(0.1)0.8, format(%03.1f) nogrid) xtitle("Date of first rheumatology appointment", size(small) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_newey.svg", as(svg) replace
actest, lag(18)	

**Prais-Winsten	
itsa mean_csdmard_delay if inrange(mo_year_appt, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(small)) ytitle("Mean proportion prescribed csDMARD in primary care within 6 months", size(small) margin(small)) yscale(range(0.2(0.1)0.8)) ylabel(0.2(0.1)0.8, format(%03.1f) nogrid) xtitle("Date of first rheumatology appointment", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_prais.svg", as(svg) replace	
	
**Newey Standard Errors with 5 lags - sensitivity with second cut point
itsa mean_csdmard_delay if inrange(mo_year_appt, tm(2019m4), tm(2021m10)), single trperiod(2020m3; 2020m5) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Mean proportion prescribed csDMARD in primary care within 6 months", size(small) margin(small)) yscale(range(0.2(0.1)0.8)) ylabel(0.2(0.1)0.8, format(%03.1f) nogrid) xtitle("Date of first rheumatology appointment", size(small) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_newey_sensitivity.svg", as(svg) replace
	
lincom _x_t2020m3 + _x_t2020m5
	
actest, lag(18)	

**Prais-Winsten	- sensitivity with second cut point
itsa mean_csdmard_delay if inrange(mo_year_appt, tm(2019m4), tm(2021m10)), single trperiod(2020m3; 2020m5) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Mean proportion prescribed csDMARD in primary care within 6 months", size(small) margin(small)) yscale(range(0.2(0.1)0.8)) ylabel(0.2(0.1)0.8, format(%03.1f) nogrid) xtitle("Date of first rheumatology appointment", size(small) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_prais_sensitivity.svg", as(svg) replace	
	
lincom _x_t2020m3 + _x_t2020m5
	
restore

log close