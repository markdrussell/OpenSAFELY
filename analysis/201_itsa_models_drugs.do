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
global projectdir `c(pwd)'
di "$projectdir"

capture mkdir "$projectdir/output/figures"
capture mkdir "$projectdir/output/tables"

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

*All patients must have 1) rheum appt 2) 6m+ follow-up after rheum appt 3) 6m of registration after appt (12m+ for biologics)
keep if has_6m_post_appt==1

**Time from rheum appt to shared care csDMARD for RA patients (not including MTX high-cost drug) 
preserve
keep if time_to_csdmard!=. & ra_code==1 //drop those with no rheum appt and/or csDMARD prescription; must have minimum of 6m follow-up after diagnosis
eststo X: estpost tabstat time_to_csdmard, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/csDMARD_delay_raandpsa.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_csdmard_delay=time_to_csdmard (p75) p75_csdmard_delay=time_to_csdmard (p25) p25_csdmard_delay=time_to_csdmard (mean) mean_csdmard_delay=time_to_csdmard (sd) sd_csdmard_delay=time_to_csdmard (count) n_csdmard_delay=time_to_csdmard, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_csdmard_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to csDMARD, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_newey_raandpsa.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_csdmard_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to csDMARD, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))  legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_prais_raandpsa.svg", replace	
restore

/*
**Time from rheum appt to shared care csDMARD for RA patients (not including MTX high-cost drug) 
preserve
keep if time_to_csdmard!=. & ra_code==1 //drop those with no rheum appt and/or csDMARD prescription; must have minimum of 6m follow-up after diagnosis
eststo X: estpost tabstat time_to_csdmard, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/csDMARD_delay_RA.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_csdmard_delay=time_to_csdmard (p75) p75_csdmard_delay=time_to_csdmard (p25) p25_csdmard_delay=time_to_csdmard (mean) mean_csdmard_delay=time_to_csdmard (sd) sd_csdmard_delay=time_to_csdmard (count) n_csdmard_delay=time_to_csdmard, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_csdmard_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to csDMARD, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_newey_ra.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_csdmard_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to csDMARD, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))  legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_prais_ra.svg", replace	
restore

**Time from rheum appt to shared care csDMARD for PsA patients (not including MTX high-cost drug)
preserve
keep if time_to_csdmard!=. & psa_code==1 //drop those with no rheum appt and/or csDMARD prescription; must have minimum of 6m follow-up after diagnosis
eststo X: estpost tabstat time_to_csdmard, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/csDMARD_delay_PsA.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_csdmard_delay=time_to_csdmard (p75) p75_csdmard_delay=time_to_csdmard (p25) p25_csdmard_delay=time_to_csdmard (mean) mean_csdmard_delay=time_to_csdmard (sd) sd_csdmard_delay=time_to_csdmard (count) n_csdmard_delay=time_to_csdmard, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_csdmard_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to csDMARD, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_newey_psa.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_csdmard_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to csDMARD, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))  legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_prais_psa.svg", replace	
restore

**Time from rheum appt to shared care MTX for RA patients (not including MTX high-cost drug) 
preserve
keep if time_to_mtx!=. & ra_code==1 //drop those with no rheum appt and/or MTX prescription; must have minimum of 6m follow-up after diagnosis
eststo X: estpost tabstat time_to_mtx, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/MTX_delay_RA.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_mtx_delay=time_to_mtx (p75) p75_mtx_delay=time_to_mtx (p25) p25_mtx_delay=time_to_mtx (mean) mean_mtx_delay=time_to_mtx (sd) sd_mtx_delay=time_to_mtx (count) n_mtx_delay=time_to_mtx, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_mtx_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to methotrexate, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_mtx_delay_newey_ra.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_mtx_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to methotrexate, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))  legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_mtx_delay_prais_ra.svg", replace	
restore

**Time from rheum appt to shared care MTX for PsA patients (not including MTX high-cost drug)
preserve
keep if time_to_mtx!=. & psa_code==1 //drop those with no rheum appt and/or MTX prescription; must have minimum of 6m follow-up after diagnosis
eststo X: estpost tabstat time_to_mtx, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/MTX_delay_PsA.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_mtx_delay=time_to_mtx (p75) p75_mtx_delay=time_to_mtx (p25) p25_mtx_delay=time_to_mtx (mean) mean_mtx_delay=time_to_mtx (sd) sd_mtx_delay=time_to_mtx (count) n_mtx_delay=time_to_mtx, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_mtx_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to methotrexate, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_mtx_delay_newey_psa.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_mtx_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to methotrexate, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))  legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_mtx_delay_prais_psa.svg", replace	
restore

**Time from rheum appt to biologic for all EIA patients (data available to 2020-11-27) - for patients who have at least 12 months of follow-up post-diagnosis

*All patients must have 1) rheum appt 2) 12m+ follow-up after rheum appt 3) 12m of registration after appt
keep if has_12m_post_appt==1

preserve
keep if time_to_biologic!=. //drop those with no rheum appt and/or biologic prescription; must have a minimum of 12m follow-up after diagnosis
eststo X: estpost tabstat time_to_biologic, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/Biol_delay_all.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2020m11)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_all.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2020m11)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_all.svg", replace	
restore

**Time from rheum appt to biologic for RA patients
preserve
keep if time_to_biologic!=. & ra_code==1 //drop those with no rheum appt and/or biologic prescription; must have a minimum of 12m follow-up after diagnosis
eststo X: estpost tabstat time_to_biologic, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/Biol_delay_ra.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2020m11)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_ra.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2020m11)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_ra.svg", replace	
restore

**Time from rheum appt to biologic for PsA patients
preserve
keep if time_to_biologic!=. & psa_code==1 //drop those with no rheum appt and/or biologic prescription; must have a minimum of 12m follow-up after diagnosis
eststo X: estpost tabstat time_to_biologic, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/Biol_delay_PsA.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2020m11)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_psa.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2020m11)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))  legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_psa.svg", replace	
restore

**Time from rheum appt to biologic for AxSpA patients
preserve
keep if time_to_biologic!=. & anksp_code==1 //drop those with no rheum appt and/or biologic prescription; must have a minimum of 12m follow-up after diagnosis
eststo X: estpost tabstat time_to_biologic, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/Biol_delay_anksp.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2020m11)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_anksp.svg", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2020m11)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small))  legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_anksp.svg", replace	
restore
*/

log close