version 16

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

capture mkdir "$projectdir/output/tables"

global logdir "$projectdir/logs"
di "$logdir"

**Open a log file
cap log close
log using "$logdir/descriptive_tables.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_eia_all.dta", clear

*Descriptive statistics======================================================================*/

**All patients with eia code in window after 1st March 2019
tab eia_code
codebook eia_code_date

**EIA sub-diagnosis (most recent code)
tab eia_diagnosis, missing

**Proportion with a csDMARD shared care prescription at any point after diagnosis (unequal follow-up); patients excluded if csDMARD or biologic was before rheumatology appt date (if present)
tab csdmard, missing
bys eia_diagnosis: tab csdmard
tab csdmard_hcd, missing //including high cost MTX scripts (not shared care)
bys eia_diagnosis: tab csdmard_hcd, missing //including high cost MTX scripts (not shared care)
tab csdmard if rheum_appt_date!=. & csdmard_date!=. & csdmard_date<rheum_appt_date //verify that no prescriptions were before rheum appt date

**Proportion with a bDMARD or tsDMARD prescription at any point after diagnosis (unequal follow-up); patients excluded if csDMARD or biologic was before rheumatology appt date (if present)
tab biologic, missing
bys eia_diagnosis: tab biologic, missing 
tab biologic if rheum_appt_date!=. & biologic_date!=. & biologic_date<rheum_appt_date //verify that no prescriptions were before rheum appt date

**Number of EIA diagnoses in 1-year time windows
tab diagnosis_year, missing
bys eia_diagnosis: tab diagnosis_year, missing

**Proportion of patients with at least 6 or 12 months of GP follow-up after EIA code
tab has_6m_follow_up
tab has_12m_follow_up
tab mo_year_diagn has_6m_follow_up
tab mo_year_diagn has_12m_follow_up
tab diagnosis_year if has_6m_follow_up==1, missing
bys eia_diagnosis: tab diagnosis_year if has_6m_follow_up==1, missing
tab diagnosis_year if has_12m_follow_up==1, missing
bys eia_diagnosis: tab diagnosis_year if has_12m_follow_up==1, missing

**Demographics
tab agegroup, missing
tab male, missing
tab ethnicity, missing
tab imd, missing
tab region, missing

**Comorbidities
tab smoke, missing
tabstat bmi_value, stats (n mean p50 p25 p75)
tab bmicat, missing
tabstat creatinine_value, stats (n mean p50 p25 p75)
tabstat egfr, stats (n mean p50 p25 p75)
tab egfr_cat, missing
tab egfr_cat_nomiss, missing
tab esrf, missing
tab ckd, missing //combination of creatinine and esrf codes
tab diabetes, missing 
tabstat hba1c_percentage, stats (n mean p50 p25 p75)
tabstat hba1c_mmol_per_mol, stats (n mean p50 p25 p75)
tabstat hba1c_pct, stats (n mean p50 p25 p75) //with conversion of mmol values
tab hba1ccat, missing
tabstat hba1c_mmol, stats (n mean p50 p25 p75) //with conversion of % values
tab hba1ccatmm, missing
tab diabcat, missing //on basis of converted %
tab cancer, missing //lung, haem or other cancer
tab hypertension, missing
tab stroke, missing
tab chronic_resp_disease, missing
tab copd, missing
tab chronic_liver_disease, missing
tab chronic_cardiac_disease, missing

/*Tables=====================================================================================*/
*Baseline table by eia diagnosis
preserve
table1_mc, by(eia_diagnosis) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(agegroup cat %5.1f \ ///
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
	vars(agegroup cat %5.1f \ ///
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

*Referral and appointment performance==============================================================================*/

**Nb. not excluding those without 6m+ follow-up

**Rheumatology appt 
tab rheum_appt  //proportion with first rheum outpatient date in the year before EIA code appears in GP record (could change to two years)
tab rheum_appt if rheum_appt_date<eia_code_date & rheum_appt_date!=. //confirm proportion who had rheum appt (i.e. not missing) and appt before EIA code (should be accounted for by Python code)

**Rheumatology referrals
tab referral_rheum_prerheum //last rheum referral in the year before rheumatology outpatient (requires rheum appt to have been present, and rheum appt to be before EIA code)
tab referral_rheum_prerheum if rheum_appt!=0  //last rheum referral in the year before rheumatology outpatient if rheum appt date present
tab referral_rheum_prerheum if rheum_appt!=0 & referral_rheum_prerheum_date<rheum_appt_date  //last rheum referral in the year before rheumatology outpatient, assuming ref date before rheum appt date (should be accounted for by Python code)
tab referral_rheum_precode //last rheum referral in the year before EIA code (could use if rheum appt missing)
codebook referral_rheum_comb_date //combination of referral pre-rheum appt (if present) and referral pre-code if not

**GP appointments
tab last_gp_refrheum //proportion with last GP appointment in year before rheum referral (pre-rheum appt); requires there to have been a rheum referral, before a rheum appt, before an EIA code
tab all_appts, missing //KEY - proportion who had a last gp appt, then rheum ref, then rheum appt, then EIA code 
tab last_gp_refcode //last GP appointment before rheum ref (i.e. pre-eia code ref); requires there to have been a rheum referral before an EIA code (i.e. rheum appt could have been missing)
tab last_gp_prerheum //last GP appointment before rheum appt; requires there to have been a rheum appt before and EIA code
tab last_gp_precode //last GP appointment before EIA code

**For sensitivity analyses for those without rheum_appt, replace diagnosis date as EIA code date if rheum appt pre-code is missing or after
tab eia_diagnosis_nomiss

**Time from last GP to rheum ref before rheum appt (i.e. if appts are present and in correct time order) //Note - referral could (in theory) be coded just before GP appt
tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //all patients (should be same number as all_appts)
bys eia_diagnosis: tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //by eia diagnosis
bys diagnosis_year: tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //by region

**Time from GP to rheum ref categorised
tab gp_ref_cat, missing
tab gp_ref_cat
bys eia_diagnosis: tab gp_ref_cat, missing
bys eia_diagnosis: tab gp_ref_cat
bys diagnosis_year: tab gp_ref_cat, missing
bys diagnosis_year: tab gp_ref_cat
bys nuts_region: tab gp_ref_cat, missing
bys nuts_region: tab gp_ref_cat

tab gp_ref_3d, missing
tab gp_ref_3d
bys eia_diagnosis: tab gp_ref_3d, missing
bys eia_diagnosis: tab gp_ref_3d
bys diagnosis_year: tab gp_ref_3d, missing
bys diagnosis_year: tab gp_ref_3d
bys nuts_region: tab gp_ref_3d, missing
bys nuts_region: tab gp_ref_3d

**Time from last GP to rheum ref before eia code (sensitivity analysis; includes those with no rheum appt)
tabstat time_gp_rheum_ref_code, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_rheum_ref_code, stats (n mean p50 p25 p75)

**Time from last GP to rheum ref (combined - sensitivity analysis; includes those with no rheum appt)
tabstat time_gp_rheum_ref_comb, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_rheum_ref_comb, stats (n mean p50 p25 p75)

**Time from last GP pre-rheum appt to first rheum appt (key sensitivity analysis; includes those with no rheum ref)
tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75) //by region

**Time from last GP pre-code to EIA code (sensitivity analysis; includes those with no rheum ref and/or no rheum appt)
tabstat time_gp_eia_code, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_eia_code, stats (n mean p50 p25 p75)

**Time from last GP to EIA diagnosis (combined - sensitivity analysis; includes those with no rheum appt)
tabstat time_gp_eia_diag, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_eia_diag, stats (n mean p50 p25 p75)

**Time from rheum ref to rheum appt (i.e. if appts are present and in correct time order)
tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75) //all patients by diagnosis year
bys nuts_region: tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75) //by region

**Time from rheum ref to rheum appt categorised
tab ref_appt_cat, missing
tab ref_appt_cat
bys eia_diagnosis: tab ref_appt_cat, missing
bys eia_diagnosis: tab ref_appt_cat
bys diagnosis_year: tab ref_appt_cat, missing
bys diagnosis_year: tab ref_appt_cat
bys nuts_region: tab ref_appt_cat, missing
bys nuts_region: tab ref_appt_cat

tab ref_appt_3w, missing
tab ref_appt_3w
bys eia_diagnosis: tab ref_appt_3w, missing
bys eia_diagnosis: tab ref_appt_3w
bys diagnosis_year: tab ref_appt_3w, missing
bys diagnosis_year: tab ref_appt_3w
bys nuts_region: tab ref_appt_3w, missing
bys nuts_region: tab ref_appt_3w

**Time from rheum ref or last GP to rheum appt (combined - sensitivity analysis; includes those with no rheum ref)
tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75) //all patients by diagnosis year
bys nuts_region: tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75) //by region

**Time from rheum ref to EIA code (sensitivity analysis; includes those with no rheum appt)
tabstat time_ref_rheum_eia, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_ref_rheum_eia, stats (n mean p50 p25 p75)

**Time from rheum ref to EIA diagnosis (combined - sensitivity analysis; includes those with no rheum appt)
tabstat time_ref_rheum_eia_comb, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_ref_rheum_eia_comb, stats (n mean p50 p25 p75)

**Time from rheum appt to EIA code (i.e. if appts are present and in correct time order)
tabstat time_rheum_eia_code, stats (n mean p50 p25 p75) 
bys eia_diagnosis: tabstat time_rheum_eia_code, stats (n mean p50 p25 p75) 

**Referral standards, by eia diagnosis
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

*Time to first csDMARD prescriptions - all of the below are shared care prescriptions, aside from those with MTX_high cost drug data included======================================================================*/

*All patients below must have at least six months of GP registration after EIA code (12m+ for biologics)

**Time to first csDMARD script for RA patients, whereby first rheum appt is classed as diagnosis date (if rheum appt present and before csDMARD date; not including high cost MTX prescriptions)
tabstat time_to_csdmard if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_csdmard if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for RA patients (including high cost MTX prescriptions)
tabstat time_to_csdmard_hcd if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) 
bys diagnosis_year: tabstat time_to_csdmard_hcd if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard_hcd if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_csdmard if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_csdmard_hcd if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) 
bys diagnosis_year: tabstat time_to_csdmard_hcd if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard_hcd if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region

**csDMARD time categories for RA patients (not including high cost MTX prescriptions)
tab csdmard_3m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab csdmard_3m if ra_code==1 & has_6m_follow_up==1
tab csdmard_6m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab csdmard_6m if ra_code==1 & has_6m_follow_up==1
tab csdmard_12m if ra_code==1 & has_12m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab csdmard_12m if ra_code==1 & has_12m_follow_up==1 //for patients with at least 12m registration

**csDMARD time categories for RA patients (including high cost MTX prescriptions)
tab csdmard_hcd_3m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab csdmard_hcd_3m if ra_code==1 & has_6m_follow_up==1
tab csdmard_hcd_6m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab csdmard_hcd_6m if ra_code==1 & has_6m_follow_up==1
tab csdmard_hcd_12m if ra_code==1 & has_12m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab csdmard_hcd_12m if ra_code==1 & has_12m_follow_up==1 //for patients with at least 12m registration

**csDMARD time categories for PsA patients (not including high cost MTX prescriptions)
tab csdmard_3m if psa_code==1 & has_6m_follow_up==1, missing
tab csdmard_6m if psa_code==1 & has_6m_follow_up==1, missing
tab csdmard_12m if psa_code==1 & has_12m_follow_up==1, missing

**csDMARD time categories for PsA patients (including high cost MTX prescriptions)
tab csdmard_hcd_3m if psa_code==1 & has_6m_follow_up==1, missing
tab csdmard_hcd_6m if psa_code==1 & has_6m_follow_up==1, missing
tab csdmard_hcd_12m if psa_code==1 & has_12m_follow_up==1, missing

**What was first shared care csDMARD (not including high cost MTX prescriptions)
tab first_csDMARD if ra_code==1 & has_6m_follow_up==1 //for RA patients
tab first_csDMARD if psa_code==1 & has_6m_follow_up==1 //for PsA patients

**What was first csDMARD (including high cost MTX prescriptions)
tab first_csDMARD_hcd if ra_code==1 & has_6m_follow_up==1 //for RA patients
tab first_csDMARD_hcd if psa_code==1 & has_6m_follow_up==1 //for PsA patients
 
**Methotrexate use (not including high cost MTX prescriptions)
tab mtx if ra_code==1 & has_6m_follow_up==1 //for RA patients; Nb. this is just a check; need time-to-MTX instead (below)
tab mtx if psa_code==1 & has_6m_follow_up==1 //for PsA patients

**Methotrexate use (including high cost MTX prescriptions)
tab mtx_hcd if ra_code==1 & has_6m_follow_up==1 //for RA patients
tab mtx_hcd if psa_code==1 & has_6m_follow_up==1 //for PsA patients

**Time to first methotrexate script for RA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_mtx if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for RA patients (including high cost MTX prescriptions)
tabstat time_to_mtx_hcd if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_mtx_hcd if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx_hcd if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_mtx if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_mtx_hcd if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_mtx_hcd if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx_hcd if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region

**Methotrexate time categories for RA patients (not including high-cost MTX) //Nb. this is time period from rheum appt (i.e. diagnosis) to shared care, not from referral to first script 
tab mtx_3m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab mtx_3m if ra_code==1 & has_6m_follow_up==1
tab mtx_6m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab mtx_6m if ra_code==1 & has_6m_follow_up==1
tab mtx_12m if ra_code==1 & has_12m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after mtx script
tab mtx_12m if ra_code==1 & has_12m_follow_up==1 //for patients with at least 12m registration

**Methotrexate time categories for RA patients (including high-cost MTX)
tab mtx_hcd_3m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab mtx_hcd_3m if ra_code==1 & has_6m_follow_up==1
tab mtx_hcd_6m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab mtx_hcd_6m if ra_code==1 & has_6m_follow_up==1
tab mtx_hcd_12m if ra_code==1 & has_12m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab mtx_hcd_12m if ra_code==1 & has_12m_follow_up==1 //for patients with at least 12m registration

**Methotrexate time categories for PsA patients (not including high-cost MTX)
tab mtx_3m if psa_code==1 & has_6m_follow_up==1, missing
tab mtx_6m if psa_code==1 & has_6m_follow_up==1, missing
tab mtx_12m if psa_code==1 & has_12m_follow_up==1, missing //with a least 12m registration

**Methotrexate time categories for PsA patients (including high-cost MTX)
tab mtx_hcd_3m if psa_code==1 & has_6m_follow_up==1, missing
tab mtx_hcd_6m if psa_code==1 & has_6m_follow_up==1, missing
tab mtx_hcd_12m if psa_code==1 & has_12m_follow_up==1, missing //with a least 12m registration

**Sulfasalazine use
tabstat time_to_ssz if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
tabstat time_to_ssz if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_ssz if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year for RA
bys diagnosis_year: tabstat time_to_ssz if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year for PsA
bys nuts_region: tabstat time_to_ssz if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region for RA
bys nuts_region: tabstat time_to_ssz if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region for PsA

**Sulfasalazine time categories for RA patients //Nb. this is time period from rheum appt (i.e. diagnosis) to shared care, not from referral to first script 
tab ssz_3m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab ssz_3m if ra_code==1 & has_6m_follow_up==1
tab ssz_6m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab ssz_6m if ra_code==1 & has_6m_follow_up==1
tab ssz_12m if ra_code==1 & has_12m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after ssz script
tab ssz_12m if ra_code==1 & has_12m_follow_up==1 //for patients with at least 12m registration

**Sulfasalazine time categories for PsA patients
tab ssz_3m if psa_code==1 & has_6m_follow_up==1, missing
tab ssz_6m if psa_code==1 & has_6m_follow_up==1, missing
tab ssz_12m if psa_code==1 & has_12m_follow_up==1, missing //with a least 12m registration

**Hydroxychloroquine use
tabstat time_to_hcq if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
tabstat time_to_hcq if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_hcq if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year for RA
bys diagnosis_year: tabstat time_to_hcq if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year for PsA
bys nuts_region: tabstat time_to_hcq if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region for RA
bys nuts_region: tabstat time_to_hcq if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region for PsA

**Hydroxychloroquine time categories for RA patients //Nb. this is time period from rheum appt (i.e. diagnosis) to shared care, not from referral to first script 
tab hcq_3m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab hcq_3m if ra_code==1 & has_6m_follow_up==1
tab hcq_6m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab hcq_6m if ra_code==1 & has_6m_follow_up==1
tab hcq_12m if ra_code==1 & has_12m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after hcq script
tab hcq_12m if ra_code==1 & has_12m_follow_up==1 //for patients with at least 12m registration

**Hydroxychloroquine time categories for PsA patients
tab hcq_3m if psa_code==1 & has_6m_follow_up==1, missing
tab hcq_6m if psa_code==1 & has_6m_follow_up==1, missing
tab hcq_12m if psa_code==1 & has_12m_follow_up==1, missing //with a least 12m registration

**Leflunomide use
tabstat time_to_lef if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
tabstat time_to_lef if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_lef if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year for RA
bys diagnosis_year: tabstat time_to_lef if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year for PsA
bys nuts_region: tabstat time_to_lef if ra_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region for RA
bys nuts_region: tabstat time_to_lef if psa_code==1 & has_6m_follow_up==1, stats (n mean p50 p25 p75) //by region for PsA

**Leflunomide time categories for RA patients //Nb. this is time period from rheum appt (i.e. diagnosis) to shared care, not from referral to first script 
tab lef_3m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab lef_3m if ra_code==1 & has_6m_follow_up==1
tab lef_6m if ra_code==1 & has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after csDMARD script
tab lef_6m if ra_code==1 & has_6m_follow_up==1
tab lef_12m if ra_code==1 & has_12m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after lef script
tab lef_12m if ra_code==1 & has_12m_follow_up==1 //for patients with at least 12m registration

**Leflunomide time categories for PsA patients
tab lef_3m if psa_code==1 & has_6m_follow_up==1, missing
tab lef_6m if psa_code==1 & has_6m_follow_up==1, missing
tab lef_12m if psa_code==1 & has_12m_follow_up==1, missing //with a least 12m registration

**Time to first biologic script, whereby first rheum appt is classed as diagnosis date (assumes rheum appt present); high_cost drug data available to Nov 2020======================================================================*/

*Below analyses are only for patients with at least 12 months of follow-up available after EIA code
tabstat time_to_biologic if has_12m_follow_up==1, stats (n mean p50 p25 p75) //for all EIA patients
bys eia_diagnosis: tabstat time_to_biologic if has_12m_follow_up==1, stats (n mean p50 p25 p75) 
bys diagnosis_year: tabstat time_to_biologic if ra_code==1 & has_12m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_biologic if ra_code==1 & has_12m_follow_up==1, stats (n mean p50 p25 p75) //by region

**What was first biologic
tab first_biologic if has_12m_follow_up==1 //for all EIA patients
bys eia_diagnosis: tab first_biologic if has_12m_follow_up==1

**Biologic time categories (for all patients)
tab biologic_3m if has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after bDMARD/tsDMARD script
tab biologic_3m if has_6m_follow_up==1
tab biologic_6m if has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after bDMARD/tsDMARD script
tab biologic_6m if has_6m_follow_up==1
tab biologic_12m if has_12m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after bDMARD/tsDMARD script
tab biologic_12m if has_12m_follow_up==1 //for patients with at least 12m registration

**Biologic time categories (by diagnosis)
bys eia_diagnosis: tab biologic_3m if has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after bDMARD/tsDMARD script
bys eia_diagnosis: tab biologic_3m if has_6m_follow_up==1
bys eia_diagnosis: tab biologic_6m if has_6m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after bDMARD/tsDMARD script
bys eia_diagnosis: tab biologic_6m if has_6m_follow_up==1
bys eia_diagnosis: tab biologic_12m if has_12m_follow_up==1, missing //missing will be patients with no rheum appt and/or rheum appt after bDMARD/tsDMARD script
bys eia_diagnosis: tab biologic_12m if has_12m_follow_up==1 //for patients with at least 12m registration

**Biologic time categories (by year)
bys diagnosis_year: tab biologic_6m if has_6m_follow_up==1, missing //for all EIA patients with at least 6m follow-up
bys diagnosis_year eia_diagnosis: tab biologic_6m if has_6m_follow_up==1, missing //for each diagnosis with at least 6m follow-up
bys diagnosis_year: tab biologic_12m if has_12m_follow_up==1, missing //for all EIA patients
bys diagnosis_year eia_diagnosis: tab biologic_12m if has_12m_follow_up==1, missing //for each diagnosis

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