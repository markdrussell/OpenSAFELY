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
*global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY\Github JG Practice"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY\Github JG Practice"
global projectdir `c(pwd)'
di "$projectdir"

global logdir "$projectdir/logs"
di "$logdir"

**Open a log file
cap log close
log using "$logdir/itsa_models.smcl", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_eia_all.dta", clear

set scheme plotplainblind

/*ITSA models===========================================================================*/

**Delay from rheum referral to rheum appt (all diagnoses)
preserve
asdoc tabstat time_ref_rheum_appt, by(mo_year_diagn) stat(count p50 p75 p25 mean sd) save($projectdir/output/tables/diagnostic_delay_all.doc) dec(0)
keep if time_ref_rheum_appt!=. //drop those with no rheum ref and/or rheum appt
collapse (p50) p50_diag_delay=time_ref_rheum_appt (p75) p75_diag_delay=time_ref_rheum_appt (p25) p25_diag_delay=time_ref_rheum_appt (mean) mean_diag_delay=time_ref_rheum_appt (sd) sd_diag_delay=time_ref_rheum_appt (count) n_diag_delay=time_ref_rheum_appt, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_diag_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to diagnosis, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_diagnostic_delay_newey.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_diagnostic_delay_newey.svg", as(svg) replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_diag_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to diagnosis, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_diagnostic_delay_prais.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_diagnostic_delay_prais.svg", as(svg) replace	
restore

/*
**Time from last GP appt to rheum referral (all diagnoses)
preserve
keep if time_gp_rheum_ref_appt!=. //drop those with no last GP appt and/or rheum ref
collapse (p50) p50_ref_delay=time_gp_rheum_ref_appt (p75) p75_ref_delay=time_gp_rheum_ref_appt (p25) p25_ref_delay=time_gp_rheum_ref_appt (mean) mean_ref_delay=time_gp_rheum_ref_appt (sd) sd_ref_delay=time_gp_rheum_ref_appt (count) n_ref_delay=time_gp_rheum_ref_appt, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_ref_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to referral, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_referral_delay_newey.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_referral_delay_newey.svg", as(svg) replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_ref_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to referral, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_referral_delay_prais.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_referral_delay_prais.svg", as(svg) replace	
restore

**Delay from rheum appt to shared care csDMARD for RA patients (not including MTX high-cost drug) - may need to cut sooner to give sufficient time for DMARD
preserve
keep if time_to_csdmard!=. & ra_code==1 //drop those with no rheum appt and/or csDMARD prescription
collapse (p50) p50_csdmard_delay=time_to_csdmard (p75) p75_csdmard_delay=time_to_csdmard (p25) p25_csdmard_delay=time_to_csdmard (mean) mean_csdmard_delay=time_to_csdmard (sd) sd_csdmard_delay=time_to_csdmard (count) n_csdmard_delay=time_to_csdmard, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_csdmard_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to csDMARD, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_csDMARD_delay_newey.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_newey_ra.tif", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_csdmard_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to csDMARD, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small))  legend(off) saving("$projectdir/output/figures/ITSA_csDMARD_delay_prais.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_prais_ra.tif", replace	
restore

**Delay from rheum appt to shared care csDMARD for PsA patients (not including MTX high-cost drug) - may need to cut sooner to give sufficient time for DMARD
preserve
keep if time_to_csdmard!=. & psa_code==1 //drop those with no rheum appt and/or csDMARD prescription
collapse (p50) p50_csdmard_delay=time_to_csdmard (p75) p75_csdmard_delay=time_to_csdmard (p25) p25_csdmard_delay=time_to_csdmard (mean) mean_csdmard_delay=time_to_csdmard (sd) sd_csdmard_delay=time_to_csdmard (count) n_csdmard_delay=time_to_csdmard, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_csdmard_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to csDMARD, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_csDMARD_delay_newey.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_newey_psa.tif", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_csdmard_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to csDMARD, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small))  legend(off) saving("$projectdir/output/figures/ITSA_csDMARD_delay_prais.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_csDMARD_delay_prais_psa.tif", replace	
restore

**Delay from rheum appt to shared care MTX for RA patients (not including MTX high-cost drug) - may need to cut sooner to give sufficient time for DMARD
preserve
keep if time_to_mtx!=. & ra_code==1 //drop those with no rheum appt and/or MTX prescription
collapse (p50) p50_mtx_delay=time_to_mtx (p75) p75_mtx_delay=time_to_mtx (p25) p25_mtx_delay=time_to_mtx (mean) mean_mtx_delay=time_to_mtx (sd) sd_mtx_delay=time_to_mtx (count) n_mtx_delay=time_to_mtx, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_mtx_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to methotrexate, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_mtx_delay_newey_ra.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_mtx_delay_newey_ra.tif", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_mtx_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to methotrexate, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small))  legend(off) saving("$projectdir/output/figures/ITSA_mtx_delay_prais_ra.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_mtx_delay_prais_ra.tif", replace	
restore

**Delay from rheum appt to shared care MTX for PsA patients (not including MTX high-cost drug) - may need to cut sooner to give sufficient time for DMARD
preserve
keep if time_to_mtx!=. & psa_code==1 //drop those with no rheum appt and/or mtx prescription
collapse (p50) p50_mtx_delay=time_to_mtx (p75) p75_mtx_delay=time_to_mtx (p25) p25_mtx_delay=time_to_mtx (mean) mean_mtx_delay=time_to_mtx (sd) sd_mtx_delay=time_to_mtx (count) n_mtx_delay=time_to_mtx, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_mtx_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to methotrexate, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_mtx_delay_newey_psa.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_mtx_delay_newey_psa.tif", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_mtx_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to methotrexate, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small))  legend(off) saving("$projectdir/output/figures/ITSA_mtx_delay_prais_psa.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_mtx_delay_prais_psa.tif", replace	
restore

**Delay from rheum appt to biologic for RA patients - may need to cut sooner to give sufficient time for DMARD
preserve
keep if time_to_biologic!=. & ra_code==1 //drop those with no rheum appt and/or biologic prescription
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_biologic_delay_newey_ra.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_ra.tif", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small))  legend(off) saving("$projectdir/output/figures/ITSA_biologic_delay_prais_ra.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_ra.tif", replace	
restore

**Delay from rheum appt to biologic for PsA patients - may need to cut sooner to give sufficient time for DMARD
preserve
keep if time_to_biologic!=. & psa_code==1 //drop those with no rheum appt and/or biologic prescription - may need to cut sooner to give sufficient time for DMARD
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_biologic_delay_newey_psa.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_psa.tif", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small))  legend(off) saving("$projectdir/output/figures/ITSA_biologic_delay_prais_psa.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_psa.tif", replace	
restore

**Delay from rheum appt to biologic for AxSpA patients - may need to cut sooner to give sufficient time for DMARD
preserve
keep if time_to_biologic!=. & anksp_code==1 //drop those with no rheum appt and/or biologic prescription - may need to cut sooner to give sufficient time for DMARD
collapse (p50) p50_biologic_delay=time_to_biologic (p75) p75_biologic_delay=time_to_biologic (p25) p25_biologic_delay=time_to_biologic (mean) mean_biologic_delay=time_to_biologic (sd) sd_biologic_delay=time_to_biologic (count) n_biologic_delay=time_to_biologic, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 6 lags
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) lag(6) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small)) legend(off) saving("$projectdir/output/figures/ITSA_biologic_delay_newey_anksp.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_newey_anksp.tif", replace
actest, lag(18)	

**Prais-Winsten	
itsa p50_biologic_delay if inrange(mo_year_diagn, tm(2019m3), tm(2022m3)), single trperiod(2020m3) replace prais rhotype(tscorr) vce(robust) figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Median time to biologic, days", size(medsmall) margin(small)) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(710 "Mar 2019" 716 "Sep 2019" 722 "Mar 2020" 728 "Sep 2020" 734 "Mar 2021" 740 "Sep 2021" 746 "Mar 2022", nogrid) note("", size(v.small))  legend(off) saving("$projectdir/output/figures/ITSA_biologic_delay_prais_anksp.gph", replace)) posttrend 
	graph export "$projectdir/output/figures/ITSA_biologic_delay_prais_anksp.tif", replace	
restore
*/

log close