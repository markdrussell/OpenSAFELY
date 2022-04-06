version 16

/*==============================================================================
DO FILE NAME:			Box plots
PROJECT:				EIA OpenSAFELY project
DATE: 					07/03/2022
AUTHOR:					J Galloway / M Russell
						adapted from C Rentsch										
DESCRIPTION OF FILE:	Box plots
DATASETS USED:			main data file
DATASETS CREATED: 		Box plots and outputs
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)						
==============================================================================*/

**Set filepaths
*global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY\Github Practice"
global projectdir `c(pwd)'
di "$projectdir"

capture mkdir "$projectdir/output/figures"

global logdir "$projectdir/logs"
di "$logdir"

**Open a log file
cap log close
log using "$logdir/box_plots.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_eia_all.dta", clear

set scheme plotplainblind

/*GP referral performance by region===========================================================================*/

preserve
gen qs1_0 =1 if time_gp_rheum_ref_appt<=3 & time_gp_rheum_ref_appt!=.
recode qs1_0 .=0 if time_gp_rheum_ref_appt!=.
gen qs1_1 =1 if time_gp_rheum_ref_appt>3 & time_gp_rheum_ref_appt<=7 & time_gp_rheum_ref_appt!=.
recode qs1_1 .=0 if time_gp_rheum_ref_appt!=.
gen qs1_2 = 1 if time_gp_rheum_ref_appt>7 & time_gp_rheum_ref_appt!=.
recode qs1_2 .=0 if time_gp_rheum_ref_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs1_0 (mean) qs1_1 (mean) qs1_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) legend(order(1 "Referral within 3 days" 2 "Referral within 7 days" 3 "Delay >7 days")) title("Time to rheumatology referral") saving("$projectdir/output/figures/regional_qs1_bar.gph", replace) name(regional_qs1_bar, replace)
graph export "$projectdir/output/figures/regional_qs1_bar.svg", replace
restore

/*
*Regional GP referral performance
preserve

graph hbox qs1, over(nuts_region) blabel(bar, color(black) position(inside) format(%9.4f)) title("Quality Standard 1: GP referral within 3 days") ytitle(Proportion meeting standard) saving("$projectdir/output/figures/regional_gpref_box.gph", replace) name(regional_gpref_box, replace)
restore
*/

*Rheum assessment performance by region==========================================================================*/

preserve
gen qs2_0 =1 if time_ref_rheum_appt<=21 & time_ref_rheum_appt!=.
recode qs2_0 .=0 if time_ref_rheum_appt!=.
gen qs2_1 =1 if time_ref_rheum_appt>21 & time_ref_rheum_appt<=42 & time_ref_rheum_appt!=.
recode qs2_1 .=0 if time_ref_rheum_appt!=.
gen qs2_2 = 1 if time_ref_rheum_appt>42 & time_ref_rheum_appt!=.
recode qs2_2 .=0 if time_ref_rheum_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) legend(order(1 "Seen within 3 weeks" 2 "Seen within 6 weeks" 3 "Delay >6 weeks")) title("Time to rheumatology assessment") saving("$projectdir/output/figures/regional_qs2_bar.gph", replace) name(regional_qs2_bar, replace)
graph export "$projectdir/output/figures/regional_qs2_bar.svg", replace
restore

*csDMARD shared care performance by region==========================================================================*/

preserve
keep if has_12m_follow_up==1 //only those patients with >12m of follow-up
gen csdmard_0 =1 if time_to_csdmard<=180 & time_to_csdmard!=.
recode csdmard_0 .=0 if time_to_csdmard!=.
gen csdmard_1 =1 if time_to_csdmard>180 & time_to_csdmard<=365 & time_to_csdmard!=.
recode csdmard_1 .=0 if time_to_csdmard!=.
gen csdmard_2 = 1 if time_to_csdmard>365 & time_to_csdmard!=.
recode csdmard_2 .=0 if time_to_csdmard!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) csdmard_0 (mean) csdmard_1 (mean) csdmard_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) legend(order(1 "csDMARD within 6 months" 2 "csDMARD within 1 year" 3 "Delay >1 year")) title("Time to shared care csDMARD") saving("$projectdir/output/figures/regional_csdmard_bar.gph", replace) name(regional_csdmard_bar, replace)
graph export "$projectdir/output/figures/regional_csdmard_bar.svg", replace
restore


log close