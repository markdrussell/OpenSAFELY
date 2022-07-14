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
*global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY\Github Practice"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY\Github Practice"
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

**Time from rheum appt to first csDMARD in GP record for RA, PsA and Undiff IA patients combined (not high-cost drugs) 
preserve
keep if ra_code==1 | psa_code==1 | undiff_code==1
tab mo_year_appt csdmard_6m if mo_year_appt!=., row  //proportion of patients with csDMARD prescription in GP record within 6 months of diagnosis
eststo X: estpost tabstat csdmard_6m, stat(n mean) by(mo_year_appt_s)
esttab X using "$projectdir/output/tables/appt_to_csdmard_ITSA_table.csv", cells("count mean") collabels("Count" "Mean proportion") replace plain nomtitle noobs
collapse (mean) mean_csdmard_delay=csdmard_6m, by(mo_year_appt)

tsset mo_year_appt

**Newey Standard Errors with 5 lags
itsa mean_csdmard_delay if inrange(mo_year_appt, tm(2019m4), tm(2021m4)), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Mean proportion prescribed csDMARD in primary care within 6 months", size(small) margin(small)) yscale(range(0.2(0.1)0.8)) ylabel(0.2(0.1)0.8, format(%03.1f) nogrid) xtitle("Date of first rheumatology appointment", size(small) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_newey.svg", as(svg) replace
actest, lag(18)	

**Prais-Winsten	
itsa mean_csdmard_delay if inrange(mo_year_appt, tm(2019m4), tm(2021m4)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(small)) ytitle("Mean proportion prescribed csDMARD in primary care within 6 months", size(small) margin(small)) yscale(range(0.2(0.1)0.8)) ylabel(0.2(0.1)0.8, format(%03.1f) nogrid) xtitle("Date of first rheumatology appointment", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_prais.svg", as(svg) replace	
	
**Newey Standard Errors with 3 lags - sensitivity with second cut point
itsa mean_csdmard_delay if inrange(mo_year_appt, tm(2019m4), tm(2021m4)), single trperiod(2020m3; 2020m5) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Mean proportion prescribed csDMARD in primary care within 6 months", size(small) margin(small)) yscale(range(0.2(0.1)0.8)) ylabel(0.2(0.1)0.8, format(%03.1f) nogrid) xtitle("Date of first rheumatology appointment", size(small) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_newey_sensitivity.svg", as(svg) replace
	
lincom _x_t2020m3 + _x_t2020m5
	
actest, lag(18)	

**Prais-Winsten	- sensitivity with second cut point
itsa mean_csdmard_delay if inrange(mo_year_appt, tm(2019m4), tm(2021m4)), single trperiod(2020m3; 2020m5) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Mean proportion prescribed csDMARD in primary care within 6 months", size(small) margin(small)) yscale(range(0.2(0.1)0.8)) ylabel(0.2(0.1)0.8, format(%03.1f) nogrid) xtitle("Date of first rheumatology appointment", size(small) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_prais_sensitivity.svg", as(svg) replace	
	
lincom _x_t2020m3 + _x_t2020m5
	
restore

/*
**Time from rheum appt to biologic for all EIA patients (data available to 2020-11-27) - for patients who have at least 12 months of follow-up post-diagnosis

*All patients must have 1) rheum appt 2) 12m+ follow-up after rheum appt 3) 12m of registration after appt

preserve
keep if time_to_biologic!=. //drop those with no rheum appt and/or biologic prescription; must have a minimum of 12m follow-up after diagnosis
eststo X: estpost tabstat time_to_biologic, by(mo_year_appt_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/Biol_delay_all.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_appt)

tsset mo_year_appt

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_appt, tm(2019m3), tm(2020m11)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_all.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_appt, tm(2019m3), tm(2020m11)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_all.svg", replace	
restore

**Time from rheum appt to biologic for RA patients
preserve
keep if time_to_biologic!=. & ra_code==1 //drop those with no rheum appt and/or biologic prescription; must have a minimum of 12m follow-up after diagnosis
eststo X: estpost tabstat time_to_biologic, by(mo_year_appt_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/Biol_delay_ra.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_appt)

tsset mo_year_appt

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_appt, tm(2019m3), tm(2020m11)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_ra.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_appt, tm(2019m3), tm(2020m11)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_ra.svg", replace	
restore

**Time from rheum appt to biologic for PsA patients
preserve
keep if time_to_biologic!=. & psa_code==1 //drop those with no rheum appt and/or biologic prescription; must have a minimum of 12m follow-up after diagnosis
eststo X: estpost tabstat time_to_biologic, by(mo_year_appt_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/Biol_delay_PsA.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_appt)

tsset mo_year_appt

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_appt, tm(2019m3), tm(2020m11)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_psa.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_appt, tm(2019m3), tm(2020m11)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))  legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_psa.svg", replace	
restore

**Time from rheum appt to biologic for AxSpA patients
preserve
keep if time_to_biologic!=. & anksp_code==1 //drop those with no rheum appt and/or biologic prescription; must have a minimum of 12m follow-up after diagnosis
eststo X: estpost tabstat time_to_biologic, by(mo_year_appt_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/Biol_delay_anksp.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_appt)

tsset mo_year_appt

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_appt, tm(2019m3), tm(2020m11)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_anksp.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_appt, tm(2019m3), tm(2020m11)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))  legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_anksp.svg", replace	
restore
*/

log close