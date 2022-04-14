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

**Set index dates ===========================================================*/
global year_preceding = "01/03/2018"
global start_date = "01/03/2019"
global outpatient_date = "01/04/2019"
global fup_6m_date = "01/09/2021"
global end_date = "01/03/2022"

*Descriptive statistics======================================================================*/

**Total number of patients with diagnosis date (i.e. first rheum appt date) after 1st March 2019 and before 1st March 2022
tab eia_code

**Verify that all diagnoses were in study windows
tab diagnosis_year, missing
tab mo_year_diagn, missing

**EIA sub-diagnosis (most recent code)
tab eia_diagnosis, missing

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
tab diabcatm, missing //on basis of converted %
tab cancer, missing //lung, haem or other cancer
tab hypertension, missing
tab stroke, missing
tab chronic_resp_disease, missing
tab copd, missing
tab chronic_liver_disease, missing
tab chronic_cardiac_disease, missing

/*Tables=====================================================================================*/
*Baseline table by eia diagnosis
table1_mc, by(eia_diagnosis) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcatm cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 cancer bin %5.1f \ ///
		 chronic_resp_disease bin  %5.1f \ ///
		 chronic_liver_disease bin %5.1f \ ///
		 ckd cat %5.1f \ ///
		 egfr_cat_nomiss cat %5.1f \ ///
		 ) saving("$projectdir/output/tables/baseline_bydiagnosis.csv", replace)

*Baseline table by year of diagnosis
table1_mc, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcatm cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 cancer bin %5.1f \ ///
		 chronic_resp_disease bin  %5.1f \ ///
		 chronic_liver_disease bin %5.1f \ ///
		 ckd cat %5.1f \ ///
		 egfr_cat_nomiss cat %5.1f \ ///
		 ) saving("$projectdir/output/tables/baseline_byyear.csv", replace)

*Medications pre-time windows=====================================================================================*/

**Proportion with a csDMARD shared care prescription at any point after diagnosis (unequal follow-up); patients excluded if csDMARD or biologic was >60 days before rheumatology appt date (if present)
tab csdmard, missing
bys eia_diagnosis: tab csdmard
tab csdmard_hcd, missing //including high cost MTX scripts (not shared care)
bys eia_diagnosis: tab csdmard_hcd, missing //including high cost MTX scripts (not shared care)
tab csdmard if rheum_appt_date!=. & csdmard_date!=. & (csdmard_date + 60)<rheum_appt_date //verify that no prescriptions were >60 days before rheumatology appt date

**Proportion with a bDMARD or tsDMARD prescription at any point after diagnosis (unequal follow-up); patients excluded if csDMARD or biologic was >60 days before rheumatology appt date (if present)
tab biologic, missing
bys eia_diagnosis: tab biologic, missing 
tab biologic if rheum_appt_date!=. & biologic_date!=. & (biologic_date + 60)<rheum_appt_date  //verify that no prescriptions were >60 days before rheumatology appt date

**Number of EIA diagnoses in 1-year time windows (where diagnosis date defined by first rheum appt if present, and EIA code if not)================================================*/
tab diagnosis_year, missing
bys eia_diagnosis: tab diagnosis_year, missing

**Number of EIA codes in 1-year time windows (defined by date of first eia code in notes)
tab code_year, missing
bys eia_diagnosis: tab code_year, missing

*Referral and appointment performance==============================================================================*/

**Nb. not excluding those without 6m+ follow-up for this section

**Rheumatology appt 
tab rheum_appt, missing //proportion of patients with a rheum outpatient date in the two years before EIA code appeared in GP record; but, data only from April 2019 onwards
tab rheum_appt if diagnosis_date>=date("$outpatient_date", "DMY"), missing //proportion of patients with a rheum appt from April 2019 onwards

**By region
bys nuts_region: tab rheum_appt //check proportion by region

**Rheumatology referrals
tab referral_rheum_prerheum //last rheum referral in the 2 years before rheumatology outpatient (requires rheum appt to have been present)
tab referral_rheum_prerheum if rheum_appt!=0 & referral_rheum_prerheum_date<=rheum_appt_date  //last rheum referral in the year before rheumatology outpatient, assuming ref date before rheum appt date (should be accounted for by Python code)
tab referral_rheum_precode //last rheum referral in the 2 years before EIA code (could potentially use if rheum appt missing)
tab referral_rheum_precode //last rheum referral in the 2 years before EIA code (could use if rheum appt missing)

**GP appointments
tab last_gp_refrheum //proportion with last GP appointment in year before rheum referral (pre-rheum appt); requires there to have been a rheum referral
tab all_appts, missing //KEY - proportion who had a last gp appt, then rheum ref, then rheum appt
tab last_gp_refcode //last GP appointment before rheum ref (i.e. pre-eia code ref); requires there to have been a rheum referral before an EIA code (i.e. rheum appt could have been missing)
tab last_gp_prerheum //last GP appointment before rheum appt; requires there to have been a rheum appt before and EIA code
tab last_gp_precode //last GP appointment before EIA code

**Time from last GP to rheum ref before rheum appt (i.e. if appts are present and in correct order)
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

**Time from rheum appt to EIA code
tabstat time_rheum_eia_code, stats (n mean p50 p25 p75) 
bys eia_diagnosis: tabstat time_rheum_eia_code, stats (n mean p50 p25 p75) 

**Referral standards, by eia diagnosis
table1_mc, by(eia_diagnosis) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_bydiag_nomiss.csv", replace)

**With missing data
table1_mc, by(eia_diagnosis) total(before) missing onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_bydiag_miss.csv", replace)

*Referral standards, by year of diagnosis
table1_mc, by(diagnosis_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_byyear_nomiss.csv", replace)

**With missing data
table1_mc, by(diagnosis_year) total(before) missing onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_byyear_miss.csv", replace)

*Referral standards, by region
table1_mc, by(nuts_region) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_byregion_nomiss.csv", replace)

**With missing data
table1_mc, by(nuts_region) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 gp_ref_3d cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 ref_appt_3w cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_byregion_miss.csv", replace)

*Time to first csDMARD prescriptions - all of the below are shared care prescriptions, aside from those with MTX_high cost drug data included======================================================================*/

*All patients must have 1) rheum appt 2) 6m+ follow-up after rheum appt 3) 6m of registration after appt (12m+ for biologics)
keep if has_6m_post_appt==1
tab has_12m_post_appt

**Time to first csDMARD script for RA patients, whereby first rheum appt is classed as diagnosis date (if rheum appt present and before csDMARD date; not including high cost MTX prescriptions)
tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for RA patients (including high cost MTX prescriptions)
tabstat time_to_csdmard_hcd if ra_code==1, stats (n mean p50 p25 p75) 
bys diagnosis_year: tabstat time_to_csdmard_hcd if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard_hcd if ra_code==1, stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_csdmard_hcd if psa_code==1, stats (n mean p50 p25 p75) 
bys diagnosis_year: tabstat time_to_csdmard_hcd if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard_hcd if psa_code==1, stats (n mean p50 p25 p75) //by region

**csDMARD time categories for RA and PsA patients (not including high cost MTX prescriptions)
tab csdmard_time if ra_code==1, missing
tab csdmard_time if psa_code==1, missing

**csDMARD time categories for RA and PsA patients (including high cost MTX prescriptions)
tab csdmard_hcd_time if ra_code==1, missing 
tab csdmard_hcd_time if psa_code==1, missing 

**What was first shared care csDMARD (not including high cost MTX prescriptions)
tab first_csDMARD if ra_code==1 //for RA patients
tab first_csDMARD if psa_code==1 //for PsA patients

**What was first csDMARD (including high cost MTX prescriptions)
tab first_csDMARD_hcd if ra_code==1 //for RA patients
tab first_csDMARD_hcd if psa_code==1 //for PsA patients
 
**Methotrexate use (not including high cost MTX prescriptions)
tab mtx if ra_code==1 //for RA patients; Nb. this is just a check; need time-to-MTX instead (below)
tab mtx if psa_code==1 //for PsA patients

**Methotrexate use (including high cost MTX prescriptions)
tab mtx_hcd if ra_code==1 //for RA patients
tab mtx_hcd if psa_code==1 //for PsA patients

**Time to first methotrexate script for RA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for RA patients (including high cost MTX prescriptions)
tabstat time_to_mtx_hcd if ra_code==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_mtx_hcd if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx_hcd if ra_code==1, stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_mtx_hcd if psa_code==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_mtx_hcd if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx_hcd if psa_code==1, stats (n mean p50 p25 p75) //by region

**Methotrexate time categories for RA and PsA patients (not including high-cost MTX)
tab mtx_time if ra_code==1, missing 
tab mtx_time if psa_code==1, missing 

**Methotrexate time categories for RA patients (including high-cost MTX)
tab mtx_hcd_time if ra_code==1, missing 
tab mtx_hcd_time if psa_code==1, missing 

**Sulfasalazine time categories for RA and PsA patients
tab ssz_time if ra_code==1, missing 
tab ssz_time if psa_code==1, missing 

**Hydroxychloroquine time categories for RA and PsA patients
tab hcq_time if ra_code==1, missing 
tab hcq_time if psa_code==1, missing 

**Leflunomide time categories for RA and PsA patients
tab lef_time if ra_code==1, missing 
tab lef_time if psa_code==1, missing 

*Drug prescription table, for those with at least 6m registration
table1_mc, by(eia_diagnosis) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_bydiag_miss.csv", replace)

*Drug prescription table, for those with at least 6m registration for RA patients
table1_mc if ra_code==1, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyear_ra_miss.csv", replace)
		 
*Drug prescription table, for those with at least 6m registration for PsA patients
table1_mc if psa_code==1, by(diagnosis_year) total(diagnosis_year) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyear_psa_miss.csv", replace)
		 
**Time to first biologic script, whereby first rheum appt is classed as diagnosis date; high_cost drug data available to Nov 2020======================================================================*/

*All patients must have 1) rheum appt 2) 12m+ follow-up after rheum appt 3) 12m of registration after appt
keep if has_12m_post_appt==1

tabstat time_to_biologic, stats (n mean p50 p25 p75) //for all EIA patients
bys eia_diagnosis: tabstat time_to_biologic, stats (n mean p50 p25 p75) 
bys diagnosis_year: tabstat time_to_biologic, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_biologic, stats (n mean p50 p25 p75) //by region

**What was first biologic - suppress due to small numbers
/*
tab first_biologic //for all EIA patients
bys eia_diagnosis: tab first_biologic
*/

**Biologic time categories (for all patients)
tab biologic_time 

**Biologic time categories (by diagnosis)
bys eia_diagnosis: tab biologic_time 

**Biologic time categories (by year)
bys diagnosis_year: tab biologic_time

*Drug prescription table at 12 months, for those with at least 12m registration
table1_mc, by(eia_diagnosis) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_bydiag_miss.csv", replace)
		 
*Drug prescription table at 12 months, for RA patients with at least 12m registration, by year of diagnosis
table1_mc if ra_code==1, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_ra_miss.csv", replace)

*Drug prescription table at 12 months, for PsA patients with at least 12m registration, by year of diagnosis
table1_mc if psa_code==1, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_psa_miss.csv", replace)

*Drug prescription table at 12 months, for AxSpA patients with at least 12m registration, by year of diagnosis
table1_mc if anksp_code==1, by(diagnosis_year) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_axspa_miss.csv", replace)

log close