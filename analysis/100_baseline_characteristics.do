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
capture mkdir "$projectdir/output/figures"

global logdir "$projectdir/logs"
di "$logdir"

**Open a log file
cap log close
log using "$logdir/descriptive_tables.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_eia_all.dta", clear

set scheme plotplainblind

**Set index dates ===========================================================*/
global year_preceding = "01/04/2018"
global start_date = "01/04/2019"
global appt_date = "01/04/2021"
global end_date = "01/04/2022"

*Descriptive statistics======================================================================*/

**Total number of patients with diagnosis date after 1st April 2019 and before 1st April 2022
tab eia_code

**Verify that all diagnoses were in study windows
tab mo_year_diagn, missing
tab diagnosis_6m, missing
tab diagnosis_year, missing

**EIA sub-diagnosis (most recent code)
tab eia_diagnosis, missing
bys eia_diagnosis: tab diagnosis_6m, missing
bys eia_diagnosis: tab diagnosis_year, missing

*Graph of diagnoses by month, by disease
preserve
recode ra_code 0=.
recode psa_code 0=.
recode anksp_code 0=.
recode undiff_code 0=.
*eststo X: estpost tab mo_year_diagn_s by(eia_diagnosis)
*esttab X using "$projectdir/output/tables/diag_count_bymonth.csv", cells("b pct cumpct") collabels("Count" "Percentage" "Cumulative Percentage") replace plain nomtitle noobs
collapse (count) total_diag=eia_code ra_diag=ra_code psa_diag=psa_code axspa_diag=anksp_code undiff_diag=undiff_code, by(mo_year_diagn) 
export delimited using "$projectdir/output/tables/diag_count_bymonth.csv", replace

twoway connected total_diag mo_year_diagn, ytitle("Number of new diagnoses per month", size(medsmall)) || connected ra_diag mo_year_diagn, color(sky) || connected psa_diag mo_year_diagn, color(red) || connected axspa_diag mo_year_diagn, color(green) || connected undiff_diag mo_year_diagn, color(gold) xline(722) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021" 747 "Apr 2022", nogrid ) title("", size(small)) name(incidence_twoway, replace) legend(region(fcolor(white%0)) order(1 "Total EIA diagnoses" 2 "RA" 3 "PsA" 4 "AxSpA" 5 "Undiff IA")) saving("$projectdir/output/figures/incidence_twoway.gph", replace)
	graph export "$projectdir/output/figures/incidence_twoway.svg", replace
	
restore	

*Graph of rheumatology appointments by month, by disease
preserve
keep if rheum_appt_date!=.
recode ra_code 0=.
recode psa_code 0=.
recode anksp_code 0=.
recode undiff_code 0=.
collapse (count) total_diag=eia_code ra_diag=ra_code psa_diag=psa_code axspa_diag=anksp_code undiff_diag=undiff_code, by(mo_year_appt)
export delimited using "$projectdir/output/tables/appt_count_bymonth.csv", replace 

twoway connected total_diag mo_year_appt, ytitle("Number of new diagnoses per month", size(medsmall)) || connected ra_diag mo_year_appt, color(sky) || connected psa_diag mo_year_appt, color(red) || connected axspa_diag mo_year_appt, color(green) || connected undiff_diag mo_year_appt, color(gold) xline(722) ylabel(, nogrid) xtitle("Date of first rheumatology appointment", size(medsmall) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021" 747 "Apr 2022", nogrid ) title("", size(small)) name(incidence_twoway_appt, replace) legend(region(fcolor(white%0)) order(1 "Total EIA diagnoses" 2 "RA" 3 "PsA" 4 "AxSpA" 5 "Undiff IA")) saving("$projectdir/output/figures/incidence_twoway_appt.gph", replace)
	graph export "$projectdir/output/figures/incidence_twoway_appt.svg", replace
	
restore

**For first rheumatology appt date
tab mo_year_appt, missing
tab appt_6m, missing
tab appt_year, missing
bys eia_diagnosis: tab appt_6m, missing
bys eia_diagnosis: tab appt_year, missing

**Demographics
tabstat age, stats (n mean sd)
bys eia_diagnosis: tabstat age, stats (n mean sd)
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
table1_mc, by(eia_diagnosis) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
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
		 ) saving("$projectdir/output/tables/baseline_bydiagnosis.xls", replace)

*Baseline table by year of diagnosis
table1_mc, by(diagnosis_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
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
		 ) saving("$projectdir/output/tables/baseline_byyear.xls", replace)

*Referral and appointment performance==============================================================================*/

**Rheumatology appt 
tab rheum_appt, missing //proportion of patients with a rheum outpatient date in the 12 months before EIA code appeared in GP record; but, data only from April 2019 onwards
tab rheum_appt2, missing //proportion of patients with a rheum outpatient date in the 6 months before EIA code appeared in GP record; but, data only from April 2019 onwards
tab rheum_appt3, missing //proportion of patients with a rheum outpatient date in the 2 years before EIA code appeared in GP record; but, data only from April 2019 onwards

**Check if above criteria are picking up the same appt
tabstat time_rheum_eia_code, stats (n mean p50 p25 p75) //using 12 months pre-EIA code
tabstat time_rheum2_eia_code, stats (n mean p50 p25 p75) //using 6 months pre-EIA code
tabstat time_rheum3_eia_code, stats (n mean p50 p25 p75) //using 2 years pre-EIA code

**By region
bys nuts_region: tab rheum_appt if nuts_region!=. //check proportion by region

**Rheumatology referrals
tab referral_rheum_prerheum //last rheum referral in the 2 years before rheumatology outpatient (requires rheum appt to have been present)
tab referral_rheum_prerheum if rheum_appt!=0 & referral_rheum_prerheum_date<=rheum_appt_date  //last rheum referral in the 2 years before rheumatology outpatient, assuming ref date before rheum appt date 
tab referral_rheum_precode //last rheum referral in the 2 years before EIA code (could potentially use if rheum appt missing)

**GP appointments
tab last_gp_refrheum //proportion with last GP appointment in year before rheum referral (pre-rheum appt); requires there to have been a rheum referral
tab all_appts, missing //KEY - proportion who had a last gp appt, then rheum ref, then rheum appt
tab last_gp_refcode //last GP appointment before rheum ref (i.e. pre-eia code ref); requires there to have been a rheum referral before an EIA code (i.e. rheum appt could have been missing)
tab last_gp_prerheum //last GP appointment before rheum appt; requires there to have been a rheum appt before and EIA code
tab last_gp_precode //last GP appointment before EIA code

**Check number of rheumatology appts in the year before EIA code
tabstat rheum_appt_count, stat (n mean sd p50 p25 p75)
bys diagnosis_year: tabstat rheum_appt_count, stat (n mean sd p50 p25 p75)
bys appt_year: tabstat rheum_appt_count if appt_year!=., stat (n mean sd p50 p25 p75)

*Time to referral=============================================*/

*Restrict all analyses below to patients with rheum appt
keep if rheum_appt_date!=. & rheum_appt_date<td(01apr2021) //note code + 60 day upper limit in study definition

**Time from last GP to rheum ref before rheum appt (i.e. if appts are present and in correct order)
tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //all patients (should be same number as all appts)
bys eia_diagnosis: tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //by eia diagnosis
bys appt_6m: tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //by diagnosis year
bys appt_year: tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_gp_rheum_ref_appt if nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time from GP to rheum ref categorised
tab gp_ref_cat, missing
tab gp_ref_cat
bys eia_diagnosis: tab gp_ref_cat, missing
bys eia_diagnosis: tab gp_ref_cat
bys appt_6m: tab gp_ref_cat, missing
bys appt_6m: tab gp_ref_cat
bys appt_year: tab gp_ref_cat, missing
bys appt_year: tab gp_ref_cat
bys nuts_region: tab gp_ref_cat if nuts_region!=., missing
bys nuts_region: tab gp_ref_cat if nuts_region!=.

/*
tab gp_ref_3d, missing
tab gp_ref_3d
bys eia_diagnosis: tab gp_ref_3d, missing
bys eia_diagnosis: tab gp_ref_3d
bys appt_6m: tab gp_ref_3d, missing
bys appt_6m: tab gp_ref_3d
bys nuts_region: tab gp_ref_3d if nuts_region!=., missing
bys nuts_region: tab gp_ref_3d if nuts_region!=.
*/

**Time from last GP to rheum ref before eia code (sensitivity analysis; includes those with no rheum appt)
tabstat time_gp_rheum_ref_code, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_rheum_ref_code, stats (n mean p50 p25 p75)

**Time from last GP to rheum ref (combined - sensitivity analysis; includes those with no rheum appt)
tabstat time_gp_rheum_ref_comb, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_rheum_ref_comb, stats (n mean p50 p25 p75)

*Time to appointment=============================================*/

**Time from last GP pre-rheum appt to first rheum appt (proxy measure for referral to appt delay)
tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75)
bys appt_6m: tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75) //by diagnosis year
bys appt_year: tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_gp_rheum_appt if nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time from rheum ref to rheum appt (i.e. if appts are present and in correct time order)
tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75)
bys appt_6m: tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75) //all patients by diagnosis year
bys appt_year: tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75) //all patients by diagnosis year
bys nuts_region: tabstat time_ref_rheum_appt if nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time from last GP to rheum appt categorised
tab gp_appt_cat, missing
tab gp_appt_cat
bys eia_diagnosis: tab gp_appt_cat, missing
bys eia_diagnosis: tab gp_appt_cat
bys appt_6m: tab gp_appt_cat, missing
bys appt_6m: tab gp_appt_cat
bys appt_year: tab gp_appt_cat, missing
bys appt_year: tab gp_appt_cat
bys nuts_region: tab gp_appt_cat if nuts_region!=., missing
bys nuts_region: tab gp_appt_cat if nuts_region!=.

**Below is what is used for ITSA models (on a month by month basis)
tab gp_appt_3w
bys eia_diagnosis: tab gp_appt_3w
bys appt_year: tab gp_appt_3w 
bys nuts_region: tab gp_appt_3w if nuts_region!=.

**Time from rheum ref to rheum appt categorised
tab ref_appt_cat, missing
tab ref_appt_cat
bys eia_diagnosis: tab ref_appt_cat, missing
bys eia_diagnosis: tab ref_appt_cat
bys appt_6m: tab ref_appt_cat, missing
bys appt_6m: tab ref_appt_cat
bys appt_year: tab ref_appt_cat, missing
bys appt_year: tab ref_appt_cat
bys nuts_region: tab ref_appt_cat if nuts_region!=., missing
bys nuts_region: tab ref_appt_cat if nuts_region!=.

/*
tab ref_appt_3w, missing
tab ref_appt_3w
bys eia_diagnosis: tab ref_appt_3w, missing
bys eia_diagnosis: tab ref_appt_3w
bys appt_6m: tab ref_appt_3w, missing
bys appt_6m: tab ref_appt_3w
bys nuts_region: tab ref_appt_3w if nuts_region!=., missing
bys nuts_region: tab ref_appt_3w if nuts_region!=.
*/

**Time from rheum ref or last GP to rheum appt (combined - sensitivity analysis; includes those with no rheum ref)
tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75)
bys appt_6m: tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75) //all patients by diagnosis year
bys nuts_region: tabstat time_refgp_rheum_appt if nuts_region!=., stats (n mean p50 p25 p75) //by region

*Time to EIA code==================================================*/

**Time from last GP pre-code to EIA code (sensitivity analysis; includes those with no rheum ref and/or no rheum appt)
tabstat time_gp_eia_code, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_eia_code, stats (n mean p50 p25 p75)

**Time from last GP to EIA diagnosis (combined - sensitivity analysis; includes those with no rheum appt)
tabstat time_gp_eia_diag, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_eia_diag, stats (n mean p50 p25 p75)

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
		 ref_appt_cat cat %3.1f \ ///
		 gp_appt_cat cat %3.1f \ ///
		 gp_appt_cat_19 cat %3.1f \ ///
		 gp_appt_cat_20 cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_bydiag_nomiss.xls", replace)		 
		 
**Check if total is sum of years - remember, +60 limit after code date		 

/*
**With missing data
table1_mc, by(eia_diagnosis) total(before) missing onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 gp_appt_cat cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_bydiag_miss.xls", replace)
*/ 
		 
*Referral standards, by 12 months periods - date of first appt rather than date of EIA code
table1_mc, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 gp_appt_cat cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_byyear_nomiss.xls", replace) 
		 
**May not need this table, if same as above		 
		 
/*
**With missing data
table1_mc, by(appt_6m) total(before) missing onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 gp_appt_cat cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_byyear_miss.xls", replace)
*/ 

*Referral standards, by region
table1_mc if nuts_region!=., by(nuts_region) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 gp_appt_cat cat %3.1f \ ///
		 gp_appt_cat_19 cat %3.1f \ ///
		 gp_appt_cat_20 cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_byregion_nomiss.xls", replace)

/*		 
**With missing data
table1_mc, by(nuts_region) total(before) onecol missing nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 gp_appt_cat cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_byregion_miss.xls", replace)
*/ 

*Time from rheum appt to first csDMARD prescriptions on primary care record======================================================================*/

*All patients must have 1) rheum appt 2) 12m follow-up after rheum appt 3) 12m of registration after appt
keep if has_12m_post_appt==1 & rheum_appt_date<td(01apr2021)
tab mo_year_diagn, missing
tab mo_year_appt, missing

**Proportion with a csDMARD prescription in GP record at any point after diagnosis (unequal follow-up); patients excluded if csDMARD or biologic was >60 days before rheumatology appt date (if present)
tab csdmard, missing
tab csdmard if (csdmard_date<=rheum_appt_date+365), missing //with 12-month limit
bys eia_diagnosis: tab csdmard
bys eia_diagnosis: tab csdmard if (csdmard_date<=rheum_appt_date+365) //with 12-month limit

**With high cost MTX data
tab csdmard_hcd, missing //including high cost MTX scripts 
tab csdmard_hcd if (csdmard_hcd_date<=rheum_appt_date+365), missing //with 12-month limit
bys eia_diagnosis: tab csdmard_hcd, missing //including high cost MTX scripts 
bys eia_diagnosis: tab csdmard_hcd if (csdmard_hcd_date<=rheum_appt_date+365) //with 12-month limit

**Compare proportion with more than one script issued for csDMARDs
tab csdmard, missing //all prescriptions, for comparison
tab csdmard_shared, missing //issued more than once (shared care)

**Time to first csDMARD in GP record for RA patients, whereby first rheum appt is classed as diagnosis date (if rheum appt present and before csDMARD date; not including high cost MTX prescriptions); prescription must be within 12 months of diagnosis for all csDMARDs below (could change in future analyses)
tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75)
bys appt_6m: tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys appt_year: tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if ra_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75)
bys appt_6m: tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys appt_year: tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if psa_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

/*
**Time to first csDMARD script for RA patients (including high cost MTX prescriptions)
tabstat time_to_csdmard_hcd if ra_code==1, stats (n mean p50 p25 p75) 
bys appt_6m: tabstat time_to_csdmard_hcd if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard_hcd if ra_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_csdmard_hcd if psa_code==1, stats (n mean p50 p25 p75) 
bys appt_6m: tabstat time_to_csdmard_hcd if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard_hcd if psa_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region
*/

**Time to first csDMARD script for Undiff IA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if undiff_code==1, stats (n mean p50 p25 p75)
bys appt_6m: tabstat time_to_csdmard if undiff_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys appt_year: tabstat time_to_csdmard if undiff_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if undiff_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**csDMARD time categories for RA and PsA patients (not including high cost MTX prescriptions)
tab csdmard_time if ra_code==1, missing
tab csdmard_time if psa_code==1, missing
tab csdmard_time if undiff_code==1, missing

/*
**csDMARD time categories for RA and PsA patients (including high cost MTX prescriptions)
tab csdmard_hcd_time if ra_code==1, missing 
tab csdmard_hcd_time if psa_code==1, missing 
tab csdmard_hcd_time if undiff_code==1, missing
*/

**What was first shared care csDMARD (not including high cost MTX prescriptions)
tab first_csDMARD
bys appt_year: tab first_csDMARD //did choice of first drug vary by year
tab first_csDMARD if ra_code==1 //for RA patients
tab first_csDMARD if psa_code==1 //for PsA patients
tab first_csDMARD if undiff_code==1 //for Undiff IA patients

**What was first csDMARD (including high cost MTX prescriptions)
tab first_csDMARD_hcd if ra_code==1 //for RA patients
tab first_csDMARD_hcd if psa_code==1 //for PsA patients
tab first_csDMARD_hcd if undiff_code==1 //for Undiff IA patients
 
**Methotrexate use (not including high cost MTX prescriptions)
tab mtx if ra_code==1 //for RA patients; Nb. this is just a check; need time-to-MTX instead (below)
tab mtx if ra_code==1 & (mtx_date<=rheum_appt_date+365) //with 12-month limit
tab mtx if psa_code==1 //for PsA patients
tab mtx if psa_code==1 & (mtx_date<=rheum_appt_date+365) //with 12-month limit
tab mtx if undiff_code==1 //for undiff IA patients
tab mtx if undiff_code==1 & (mtx_date<=rheum_appt_date+365) //with 12-month limit

**Compare proportion with more than one script issued for csDMARDs
tab mtx, missing //all prescriptions (for comparison)
tab mtx_shared, missing //issued more than once (shared care)
tab mtx_issue, missing //issed none vs. once vs. more than once

/*
**Methotrexate use (including high cost MTX prescriptions)
tab mtx_hcd if ra_code==1 //for RA patients
tab mtx_hcd if ra_code==1 & (mtx_hcd_date<=rheum_appt_date+365) //with 12-month limit
tab mtx_hcd if psa_code==1 //for PsA patients
tab mtx_hcd if psa_code==1 & (mtx_hcd_date<=rheum_appt_date+365) //with 12-month limit
tab mtx_hcd if undiff_code==1 //for undiff IA patients
tab mtx_hcd if undiff_code==1 & (mtx_hcd_date<=rheum_appt_date+365) //with 12-month limit
*/

**Time to first methotrexate script for RA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75)
bys appt_year: tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if ra_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75)
bys appt_year: tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if psa_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

/*
**Time to first methotrexate script for RA patients (including high cost MTX prescriptions)
tabstat time_to_mtx_hcd if ra_code==1, stats (n mean p50 p25 p75)
bys appt_year: tabstat time_to_mtx_hcd if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx_hcd if ra_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_mtx_hcd if psa_code==1, stats (n mean p50 p25 p75)
bys appt_year: tabstat time_to_mtx_hcd if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx_hcd if psa_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region
*/

**Time to first methotrexate script for Undiff IA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if undiff_code==1, stats (n mean p50 p25 p75)
bys appt_year: tabstat time_to_mtx if undiff_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if undiff_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Methotrexate time categories for RA, PsA and Undiff IA patients (not including high-cost MTX)
tab mtx_time if ra_code==1, missing 
tab mtx_time if psa_code==1, missing 
tab mtx_time if undiff_code==1, missing 

/*
**Methotrexate time categories (including high-cost MTX)
tab mtx_hcd_time if ra_code==1, missing 
tab mtx_hcd_time if psa_code==1, missing 
tab mtx_hcd_time if undiff_code==1, missing 
*/

**Sulfasalazine time categories
tab ssz_time if ra_code==1, missing 
tab ssz_time if psa_code==1, missing 
tab ssz_time if undiff_code==1, missing 

**Compare proportion with more than one script issued for csDMARDs
tab ssz, missing //all prescriptions (for comparison)
tab ssz_shared, missing //issued more than once (shared care)
tab ssz_issue, missing //issed none vs. once vs. more than once

**Hydroxychloroquine time categories
tab hcq_time if ra_code==1, missing 
tab hcq_time if psa_code==1, missing 
tab hcq_time if undiff_code==1, missing 

**Compare proportion with more than one script issued for csDMARDs
tab hcq, missing //all prescriptions (for comparison)
tab hcq_shared, missing //issued more than once (shared care)
tab hcq_issue, missing //issed none vs. once vs. more than once

**Leflunomide time categories
tab lef_time if ra_code==1, missing 
tab lef_time if psa_code==1, missing 
tab lef_time if undiff_code==1, missing 

**Compare proportion with more than one script issued for csDMARDs
tab lef, missing //all prescriptions (for comparison)
tab lef_shared, missing //issued more than once (shared care)
tab lef_issue, missing //issed none vs. once vs. more than once

*Drug prescription table, for those with at least 12m registration
table1_mc if eia_diagnosis!=3, by(eia_diagnosis) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_bydiag_miss.xls", replace)
		 
*Drug prescription table, for those with at least 12m registration; all diagnoses but for AxSpA
table1_mc if eia_diagnosis!=3, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyear_miss.xls", replace)		 

*Drug prescription table, for those with at least 12m registration for RA patients
table1_mc if ra_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyear_ra_miss.xls", replace)
		 
*Drug prescription table, for those with at least 12m registration for PsA patients
table1_mc if psa_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyear_psa_miss.xls", replace)

*Drug prescription table, for those with at least 12m registration for Undiff IA patients
table1_mc if undiff_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyear_undiff_miss.xls", replace) 
		 
*Drug prescription table, for those with at least 12m registration for all diagnoses, by year
table1_mc, by(eia_diagnosis) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 csdmard_time_19 cat %3.1f \ ///
		 csdmard_time_20 cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyearanddisease.xls", replace) 		
		 
*Drug prescription table, for those with at least 12m registration for all diagnoses, by region and year
table1_mc if nuts_region!=., by(nuts_region) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 csdmard_time_19 cat %3.1f \ ///
		 csdmard_time_20 cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyearandregion.xls", replace) 			 
		 
**Time to first biologic script, whereby first rheum appt is classed as diagnosis date; high cost drug data available to Nov 2020======================================================================*/

**Proportion with a bDMARD or tsDMARD prescription at any point after diagnosis (unequal follow-up); patients excluded if csDMARD or biologic was >60 days before rheumatology appt date (if present)
tab biologic, missing
tab biologic if (biologic_date<=rheum_appt_date+365), missing //with 12-month limit

/*Suppress due to small numbers
bys eia_diagnosis: tab biologic, missing 
bys eia_diagnosis: tab biologic if (biologic_date<=rheum_appt_date+365), missing //with 12-month limit 

tabstat time_to_biologic, stats (n mean p50 p25 p75) //for all EIA patients
bys eia_diagnosis: tabstat time_to_biologic, stats (n mean p50 p25 p75) 
bys appt_6m: tabstat time_to_biologic, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_biologic if nuts_region!=., stats (n mean p50 p25 p75) //by region

**What was first biologic

tab first_biologic //for all EIA patients
bys eia_diagnosis: tab first_biologic

**Biologic time categories (for all patients)
tab biologic_time 

**Biologic time categories (by diagnosis)
bys eia_diagnosis: tab biologic_time 

**Biologic time categories (by time period)
bys appt_6m: tab biologic_time

*Drug prescription table at 12 months, for those with at least 12m registration
table1_mc, by(eia_diagnosis) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_bydiag_miss.xls", replace)
		 
*Drug prescription table at 12 months, for all patients with at least 12m registration, by year of diagnosis
table1_mc, by(appt_6m) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_miss.xls", replace)
		 
*Drug prescription table at 12 months, for RA patients with at least 12m registration, by year of diagnosis
table1_mc if ra_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_ra_miss.xls", replace)

*Drug prescription table at 12 months, for PsA patients with at least 12m registration, by year of diagnosis
table1_mc if psa_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_psa_miss.xls", replace)

*Drug prescription table at 12 months, for AxSpA patients with at least 12m registration, by year of diagnosis
table1_mc if anksp_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_axspa_miss.xls", replace)
		 
*Drug prescription table at 12 months, for Undiff IA patients with at least 12m registration, by year of diagnosis
table1_mc if undiff_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_undiff_miss.xls", replace)
*/		 

*Output tables as CSVs		 
import excel "$projectdir/output/tables/baseline_bydiagnosis.xls", clear
outsheet * using "$projectdir/output/tables/baseline_bydiagnosis.csv" , comma nonames replace	

import excel "$projectdir/output/tables/baseline_byyear.xls", clear
outsheet * using "$projectdir/output/tables/baseline_byyear.csv" , comma nonames replace		 

import excel "$projectdir/output/tables/referral_bydiag_nomiss.xls", clear
outsheet * using "$projectdir/output/tables/referral_bydiag_nomiss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/referral_byyear_nomiss.xls", clear
outsheet * using "$projectdir/output/tables/referral_byyear_nomiss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/referral_byregion_nomiss.xls", clear
outsheet * using "$projectdir/output/tables/referral_byregion_nomiss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_bydiag_miss.xls", clear
outsheet * using "$projectdir/output/tables/drug_bydiag_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyear_miss.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyear_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyear_ra_miss.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyear_ra_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyear_psa_miss.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyear_psa_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyear_undiff_miss.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyear_undiff_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyearanddisease.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyearanddisease.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyearandregion.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyearandregion.csv" , comma nonames replace	

/*
import excel "$projectdir/output/tables/biol_bydiag_miss.xls", clear
outsheet * using "$projectdir/output/tables/biol_bydiag_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/biol_byyear_miss.xls", clear
outsheet * using "$projectdir/output/tables/biol_byyear_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/biol_byyear_ra_miss.xls", clear
outsheet * using "$projectdir/output/tables/biol_byyear_ra_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/biol_byyear_psa_miss.xls", clear
outsheet * using "$projectdir/output/tables/biol_byyear_psa_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/biol_byyear_axspa_miss.xls", clear
outsheet * using "$projectdir/output/tables/biol_byyear_axspa_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/biol_byyear_undiff_miss.xls", clear
outsheet * using "$projectdir/output/tables/biol_byyear_undiff_miss.csv" , comma nonames replace
*/	

log close