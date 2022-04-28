version 16

/*==============================================================================
DO FILE NAME:			ITSA models
PROJECT:				EIA OpenSAFELY project
DATE: 					07/03/2022
AUTHOR:					J Galloway / M Russell
						adapted from C Rentsch										
DESCRIPTION OF FILE:	ITSA models
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
log using "$logdir/itsa_models.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_eia_all.dta", clear

set scheme plotplainblind

/*ITSA models for appt and referral times===========================================================================*/

**Time from last GP appt to rheum referral (all diagnoses) - median time to referral
preserve
keep if time_gp_rheum_ref_appt!=. //drop those with no last GP appt and/or rheum ref
eststo X: estpost tabstat time_gp_rheum_ref_appt, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/referral_delay_GP_to_ref.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_ref_delay=time_gp_rheum_ref_appt (p75) p75_ref_delay=time_gp_rheum_ref_appt (p25) p25_ref_delay=time_gp_rheum_ref_appt (mean) mean_ref_delay=time_gp_rheum_ref_appt (sd) sd_ref_delay=time_gp_rheum_ref_appt (count) n_ref_delay=time_gp_rheum_ref_appt, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_ref_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to referral, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_referral_delay_newey_median.svg", as(svg) replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_ref_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to referral, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_referral_delay_prais_median.svg", as(svg) replace	

**Time from last GP appt to rheum referral (all diagnoses) - mean time to referral

**Newey Standard Errors with 6 lags
itsa mean_ref_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Mean time to referral, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_referral_delay_newey_mean.svg", as(svg) replace
actest, lag(18)	

**Prais-Winsten	
itsa mean_ref_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Mean time to referral, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_referral_delay_prais_mean.svg", as(svg) replace	
restore

**Time from rheum referral to rheum appt (all diagnoses)
preserve
keep if time_ref_rheum_appt!=. //drop those with no rheum ref and/or rheum appt
eststo X: estpost tabstat time_ref_rheum_appt, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/diagnostic_delay_ref_rheum_appt.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_diag_delay=time_ref_rheum_appt (p75) p75_diag_delay=time_ref_rheum_appt (p25) p25_diag_delay=time_ref_rheum_appt (mean) mean_diag_delay=time_ref_rheum_appt (sd) sd_diag_delay=time_ref_rheum_appt (count) n_diag_delay=time_ref_rheum_appt, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_diag_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to diagnosis, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_diagnostic_delay_newey.svg", as(svg) replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_diag_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to diagnosis, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_diagnostic_delay_prais.svg", as(svg) replace	

**Time from rheum referral to rheum appt (all diagnoses) with second cut point corresponding to Jan 2021 lockdown
**Newey Standard Errors with 6 lags
itsa p50_diag_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3; 2021m1) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to diagnosis, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_diagnostic_delay_newey_2cuts.svg", as(svg) replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_diag_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3; 2021m1) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to diagnosis, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_diagnostic_delay_prais_2cuts.svg", as(svg) replace	
restore

**Time from last GP (pre-rheum appt) to rheum appt (all diagnoses)
preserve
keep if time_gp_rheum_appt!=. //drop those with no rheum ref and/or rheum appt
eststo X: estpost tabstat time_gp_rheum_appt, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/diagnostic_delay_GP_rheum_appt.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_diag_delay=time_gp_rheum_appt (p75) p75_diag_delay=time_gp_rheum_appt (p25) p25_diag_delay=time_gp_rheum_appt (mean) mean_diag_delay=time_gp_rheum_appt (sd) sd_diag_delay=time_gp_rheum_appt (count) n_diag_delay=time_gp_rheum_appt, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_diag_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to diagnosis, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_diagnostic_delay_GP_newey.svg", as(svg) replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_diag_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to diagnosis, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_diagnostic_delay_GP_prais.svg", as(svg) replace	
restore

**Sensitivity analyses using combination of time from rheum ref to rheum appt; or, if no ref present, time from last GP appt to rheum appt (all diagnoses)
preserve
keep if time_refgp_rheum_appt!=. //drop those with no rheum ref and/or rheum appt
eststo X: estpost tabstat time_refgp_rheum_appt, by(mo_year_diagn_s) stat(count p50 p75 p25 mean sd) 
esttab X using "$projectdir/output/tables/diagnostic_delay_GPref_rheum_appt.csv", cells("count p50 p75 p25 mean sd") replace plain nomtitle noobs
collapse (p50) p50_diag_delay=time_refgp_rheum_appt (p75) p75_diag_delay=time_refgp_rheum_appt (p25) p25_diag_delay=time_refgp_rheum_appt (mean) mean_diag_delay=time_refgp_rheum_appt (sd) sd_diag_delay=time_refgp_rheum_appt (count) n_diag_delay=time_refgp_rheum_appt, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_diag_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to diagnosis, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_diagnostic_delay_GPref_newey.svg", as(svg) replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_diag_delay if inrange(mo_year_diagn, tm(2019m4), tm(2021m10)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to diagnosis, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021", nogrid) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_diagnostic_delay_GPref_prais.svg", as(svg) replace	
restore

log close