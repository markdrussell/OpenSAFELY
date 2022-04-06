/*==============================================================================
DO FILE NAME:			baseline tables
PROJECT:				EIA OpenSAFELY project
DATE: 					07/03/2022
AUTHOR:					J Galloway / M Russell
						adapted from C Rentsch										
DESCRIPTION OF FILE:	baseline tables
DATASETS USED:			main data file
DATASETS CREATED: 		tables
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)						
==============================================================================*/

**Set filepaths
*global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY\Github Practice"
global projectdir `c(pwd)'
di "$projectdir"

global logdir "$projectdir/logs"
di "$logdir"

**Open a log file
cap log close
log using "$logdir/descriptive_tables.smcl", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_eia_all.dta", clear

/*Tables=====================================================================================*/
*Baseline table by eia diagnosis
preserve
table1_mc, by(eia_diagnosis) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(age contn %3.0f \ ///
		 agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabetes bin %5.1f \ ///
		 hba1ccatmm cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 cancer bin %5.1f \ ///
		 chronic_resp_disease bin  %5.1f \ ///
		 chronic_liver_disease bin %5.1f \ ///
		 ckd cat %5.1f \ ///
		 egfr_cat_nomiss cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 ) clear
restore

*Baseline table by year of diagnosis
preserve
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(age contn %3.0f \ ///
		 agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabetes bin %5.1f \ ///
		 hba1ccatmm cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 cancer bin %5.1f \ ///
		 chronic_resp_disease bin  %5.1f \ ///
		 chronic_liver_disease bin %5.1f \ ///
		 ckd cat %5.1f \ ///
		 egfr_cat_nomiss cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 ) clear
restore

*Referral standards, by eia diagnosis
preserve
table1_mc, by(eia_diagnosis) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) clear
restore

**With missing data
preserve
table1_mc, by(eia_diagnosis) total(before) missing onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) clear
restore

*Referral standards, by year of diagnosis
preserve
table1_mc, by(diagnosis_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) clear
restore

**With missing data
preserve
table1_mc, by(diagnosis_year) total(before) missing onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) clear
restore


*Referral standards, by region
preserve
table1_mc, by(nuts_region) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) clear
restore

**With missing data
preserve
table1_mc, by(nuts_region) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 6 months, for those with at least 6m registration
preserve
keep if has_6m_follow_up==1
table1_mc, by(eia_diagnosis) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_6m cat %3.1f \ ///
		 mtx_6m cat %3.1f \ ///
		 ssz_6m cat %3.1f \ ///
		 hcq_6m cat %3.1f \ ///
		 lef_6m cat %3.1f \ ///
		 biologic_6m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 12 months, for those with at least 12m registration
preserve
keep if has_12m_follow_up==1
table1_mc, by(eia_diagnosis) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_12m cat %3.1f \ ///
		 mtx_12m cat %3.1f \ ///
		 ssz_12m cat %3.1f \ ///
		 hcq_12m cat %3.1f \ ///
		 lef_12m cat %3.1f \ ///
		 biologic_12m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 6 and 12 months, for those with at least 12m registration
preserve
keep if has_12m_follow_up==1
table1_mc, by(eia_diagnosis) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_6m cat %3.1f \ ///
		 csdmard_12m cat %3.1f \ ///
		 mtx_6m cat %3.1f \ ///
		 mtx_12m cat %3.1f \ ///
		 ssz_6m cat %3.1f \ ///
		 ssz_12m cat %3.1f \ ///
		 hcq_6m cat %3.1f \ ///
		 hcq_12m cat %3.1f \ ///
		 lef_6m cat %3.1f \ ///
		 lef_12m cat %3.1f \ ///
		 biologic_6m cat %3.1f \ ///
		 biologic_12m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 6 months, for those with at least 6m registration, for all patients by year of diagnosis
preserve
keep if has_6m_follow_up==1
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_6m cat %3.1f \ ///
		 mtx_6m cat %3.1f \ ///
		 ssz_6m cat %3.1f \ ///
		 hcq_6m cat %3.1f \ ///
		 lef_6m cat %3.1f \ ///
		 biologic_6m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 12 months, for those with at least 12m registration, by all patients year of diagnosis
preserve
keep if has_12m_follow_up==1
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_12m cat %3.1f \ ///
		 mtx_12m cat %3.1f \ ///
		 ssz_12m cat %3.1f \ ///
		 hcq_12m cat %3.1f \ ///
		 lef_12m cat %3.1f \ ///
		 biologic_12m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 6 and 12 months, for those with at least 12m registration, by all patients year of diagnosis
preserve
keep if has_12m_follow_up==1
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_6m cat %3.1f \ ///
		 csdmard_12m cat %3.1f \ ///
		 mtx_6m cat %3.1f \ ///
		 mtx_12m cat %3.1f \ ///
		 ssz_6m cat %3.1f \ ///
		 ssz_12m cat %3.1f \ ///
		 hcq_6m cat %3.1f \ ///
		 hcq_12m cat %3.1f \ ///
		 lef_6m cat %3.1f \ ///
		 lef_12m cat %3.1f \ ///
		 biologic_6m cat %3.1f \ ///
		 biologic_12m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 6 months, for those with at least 6m registration, for RA patients by year of diagnosis
preserve
keep if has_6m_follow_up==1 & ra_code==1
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_6m cat %3.1f \ ///
		 mtx_6m cat %3.1f \ ///
		 ssz_6m cat %3.1f \ ///
		 hcq_6m cat %3.1f \ ///
		 lef_6m cat %3.1f \ ///
		 biologic_6m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 12 months, for those with at least 12m registration, by RA patients year of diagnosis
preserve
keep if has_12m_follow_up==1 & ra_code==1
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_12m cat %3.1f \ ///
		 mtx_12m cat %3.1f \ ///
		 ssz_12m cat %3.1f \ ///
		 hcq_12m cat %3.1f \ ///
		 lef_12m cat %3.1f \ ///
		 biologic_12m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 6 and 12 months, for those with at least 12m registration, by RA patients year of diagnosis
preserve
keep if has_12m_follow_up==1 & ra_code==1
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_6m cat %3.1f \ ///
		 csdmard_12m cat %3.1f \ ///
		 mtx_6m cat %3.1f \ ///
		 mtx_12m cat %3.1f \ ///
		 ssz_6m cat %3.1f \ ///
		 ssz_12m cat %3.1f \ ///
		 hcq_6m cat %3.1f \ ///
		 hcq_12m cat %3.1f \ ///
		 lef_6m cat %3.1f \ ///
		 lef_12m cat %3.1f \ ///
		 biologic_6m cat %3.1f \ ///
		 biologic_12m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 6 months, for those with at least 6m registration, for PsA patients by year of diagnosis
preserve
keep if has_6m_follow_up==1 & psa_code==1
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_6m cat %3.1f \ ///
		 mtx_6m cat %3.1f \ ///
		 ssz_6m cat %3.1f \ ///
		 hcq_6m cat %3.1f \ ///
		 lef_6m cat %3.1f \ ///
		 biologic_6m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 12 months, for those with at least 12m registration, by PsA patients year of diagnosis
preserve
keep if has_12m_follow_up==1 & psa_code==1
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_12m cat %3.1f \ ///
		 mtx_12m cat %3.1f \ ///
		 ssz_12m cat %3.1f \ ///
		 hcq_12m cat %3.1f \ ///
		 lef_12m cat %3.1f \ ///
		 biologic_12m cat %3.1f \ ///
		 ) clear
restore

*Drug prescription table at 6 and 12 months, for those with at least 12m registration, by PsA patients year of diagnosis
preserve
keep if has_12m_follow_up==1 & psa_code==1
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_6m cat %3.1f \ ///
		 csdmard_12m cat %3.1f \ ///
		 mtx_6m cat %3.1f \ ///
		 mtx_12m cat %3.1f \ ///
		 ssz_6m cat %3.1f \ ///
		 ssz_12m cat %3.1f \ ///
		 hcq_6m cat %3.1f \ ///
		 hcq_12m cat %3.1f \ ///
		 lef_6m cat %3.1f \ ///
		 lef_12m cat %3.1f \ ///
		 biologic_6m cat %3.1f \ ///
		 biologic_12m cat %3.1f \ ///
		 ) clear
restore

log close