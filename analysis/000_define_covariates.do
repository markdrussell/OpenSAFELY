/*==============================================================================
DO FILE NAME:			define covariates
PROJECT:				EIA OpenSAFELY project
DATE: 					07/03/2022
AUTHOR:					J Galloway / M Russell
						adapted from C Rentsch										
DESCRIPTION OF FILE:	data management for EIA project  
						reformat variables 
						categorise variables
						label variables 
DATASETS USED:			data in memory (from output/input.csv)
DATASETS CREATED: 		analysis files
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)						
==============================================================================*/

**Set filepaths
global projectdir "C:/Users/k1754142/OneDrive/PhD Project/OpenSAFELY/Github Practice"
*global projectdir `c(pwd)'

global logdir "$projectdir/logs"

**Open a log file
cap log close
log using "$logdir/cleaning_dataset.smcl", replace

di "$projectdir"
di "$logdir"

import delimited "$projectdir/output/input.csv", clear

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Set index dates ===========================================================*/
global year_preceding = "01/03/2018"
global start_date = "01/03/2019"
global end_date = "01/03/2022"

**Rename variables (some are too long for Stata to handle) =======================================*/
rename chronic_respiratory_disease chronic_resp_disease

**Convert date strings to dates ====================================================*/
***Some dates are given with month/year only, so adding day 15 to enable them to be processed as dates 

foreach var of varlist 	 hba1c_mmol_per_mol_date			///
						 hba1c_percentage_date				///
						 creatinine_date      				///
						 bmi_date_measured		            ///
						 abatacept							///
						 adalimumab							///	
						 baricitinib						///
						 certolizumab						///
						 etanercept							///
						 golimumab							///
						 guselkumab							///	
						 infliximab							///
						 ixekizumab							///
						 methotrexate_hcd					///
						 rituximab							///
						 sarilumab							///
						 secukinumab						///	
						 tocilizumab						///
						 tofacitinib						///
						 upadacitinib						///
						 ustekinumab						///
						 {
						 	
		capture confirm string variable `var'
		if _rc!=0 {
			assert `var'==.
			rename `var' `var'_date
		}
	
		else {
				replace `var' = `var' + "-15"
				rename `var' `var'_dstr
				replace `var'_dstr = " " if `var'_dstr == "-15"
				gen `var'_date = date(`var'_dstr, "YMD") 
				order `var'_date, after(`var'_dstr)
				drop `var'_dstr
		}
	
	format `var'_date %td
}

**Conversion for dates with day already included ====================================================*/

foreach var of varlist 	 died_date_ons						///
					     eia_code_date 						///
						 rheum_appt_date					///
					     ra_code_date						///
						 psa_code_date						///
						 anksp_code_date					///
						 last_gp_prerheum_date				///
						 last_gp_precode_date				///	
						 last_gp_refrheum_date				///
						 last_gp_refcode_date				///
						 referral_rheum_prerheum			///
						 referral_rheum_precode				///	
						 chronic_cardiac_disease			///
						 diabetes							///
						 hypertension						///	
						 chronic_resp_disease				///
						 copd								///
						 chronic_liver_disease				///
						 stroke								///
						 lung_cancer						///
						 haem_cancer						///
						 other_cancer						///
						 esrf								///
						 organ_transplant					///
						 hydroxychloroquine					///
						 leflunomide						///
						 methotrexate						///
						 methotrexate_inj					///
						 sulfasalazine						///
						 {
						 		 
		capture confirm string variable `var'
		if _rc!=0 {
			assert `var'==.
			rename `var' `var'_date
		}
	
		else {
				rename `var' `var'_dstr
				gen `var'_date = date(`var'_dstr, "YMD") 
				order `var'_date, after(`var'_dstr)
				drop `var'_dstr
				gen `var'_date15 = `var'_date+15
				order `var'_date15, after(`var'_date)
				drop `var'_date
				rename `var'_date15 `var'_date
		}
	
	format `var'_date %td
}
						 
**Rename variables with extra 'date' added to the end of variable names===========================================================*/ 
rename rheum_appt_date_date rheum_appt_date
rename eia_code_date_date eia_code_date
rename ra_code_date_date ra_code_date
rename psa_code_date_date psa_code_date
rename anksp_code_date_date anksp_code_date
rename died_date_ons_date died_ons_date
rename last_gp_prerheum_date_date last_gp_prerheum_date
rename last_gp_refrheum_date_date last_gp_refrheum_date
rename last_gp_refcode_date_date last_gp_refcode_date
rename last_gp_precode_date_date last_gp_precode_date
rename hba1c_mmol_per_mol_date_date hba1c_mmol_per_mol_date
rename hba1c_percentage_date_date hba1c_percentage_date
rename creatinine_date_date creatinine_date
rename creatinine creatinine_value 
rename bmi_date_measured_date bmi_date
rename bmi bmi_value

**Create binary indicator variables for relevant conditions ====================================================*/

foreach var of varlist 	 eia_code_date 						///
						 rheum_appt_date					///
					     ra_code_date						///
						 psa_code_date						///
						 anksp_code_date					///
						 died_ons_date						///
						 last_gp_prerheum_date				///
						 last_gp_precode_date				///	
						 last_gp_refrheum_date				///
						 last_gp_refcode_date				///
						 referral_rheum_prerheum_date		///
						 referral_rheum_precode_date		///	
						 chronic_cardiac_disease_date		///
						 diabetes_date						///
						 hypertension_date					///
						 chronic_resp_disease_date			///
						 copd_date							///
						 chronic_liver_disease_date			///
						 stroke_date						///
						 lung_cancer_date					///
						 haem_cancer_date					///		
						 other_cancer_date					///
						 esrf_date							///
						 creatinine_date					///
						 organ_transplant_date				///
						 hydroxychloroquine_date			///	
						 leflunomide_date					///
						 methotrexate_date					///
						 methotrexate_inj_date				///		
						 sulfasalazine_date					///
						 abatacept_date						///
						 adalimumab_date					///
						 baricitinib_date					///
						 certolizumab_date					///
						 etanercept_date					///
						 golimumab_date						///
						 guselkumab_date					///
						 infliximab_date					///
						 ixekizumab_date					///
						 methotrexate_hcd_date				///
						 rituximab_date						///		
						 sarilumab_date						///
						 secukinumab_date					///
						 tocilizumab_date					///		
						 tofacitinib_date					///
						 upadacitinib_date					///
						 ustekinumab_date   {				
	/*date ranges are applied in python, so presence of date indicates presence of 
	  disease in the correct time frame*/ 
	local newvar =  substr("`var'", 1, length("`var'") - 5)
	gen `newvar' = (`var'!=. )
	order `newvar', after(`var')
}

**Create and label variables ===========================================================*/

**Demographics
***Sex
gen male = 1 if sex == "M"
replace male = 0 if sex == "F"
lab var male "Male"

***Ethnicity
replace ethnicity = .u if ethnicity == .
****rearrange in order of prevalence
recode ethnicity 2=6 /* mixed to 6 */
recode ethnicity 3=2 /* south asian to 2 */
recode ethnicity 4=3 /* black to 3 */
recode ethnicity 6=4 /* mixed to 4 */
recode ethnicity 5=4 /* other to 4 */

label define ethnicity 	1 "White"  					///
						2 "Asian/Asian British"		///
						3 "Black"  					///
						4 "Mixed/Other"				///
						.u "Missing"
label values ethnicity ethnicity
lab var ethnicity "Ethnicity"

***STP 
rename stp stp_old
bysort stp_old: gen stp = 1 if _n==1
replace stp = sum(stp) //
drop stp_old

***Regions
encode region, gen(nuts_region)

***IMD
*Group into 5 groups
rename imd imd_o
egen imd = cut(imd_o), group(5) icodes 
*Add one to create groups 1-5 
replace imd = imd + 1
*-1 is missing, should be excluded from population 
replace imd = .u if imd_o == -1
drop imd_o
*Reverse the order (so high is more deprived)
recode imd 5 = 1 4 = 2 3 = 3 2 = 4 1 = 5 .u = .u
label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" .u "Missing"
label values imd imd 
lab var imd "Index of multiple deprivation"

***Age variables
*Nb. works if ages 18 and over
*Create categorised age
drop if age<18 & age !=.
drop if age>109 & age !=.
drop if age==.
lab var age "Age"

recode age 18/39.9999 = 1 /// 
           40/49.9999 = 2 ///
		   50/59.9999 = 3 ///
	       60/69.9999 = 4 ///
		   70/79.9999 = 5 ///
		   80/max = 6, gen(agegroup) 

label define agegroup 	1 "18-39" ///
						2 "40-49" ///
						3 "50-59" ///
						4 "60-69" ///
						5 "70-79" ///
						6 "80+"
						
label values agegroup agegroup
lab var agegroup "Age group"

*Create binary age
recode age min/69.999 = 0 ///
           70/max = 1, gen(age70)

*Create restricted cubic splines for age
mkspline age = age, cubic nknots(4)

***Body Mass Index
*Recode strange values 
replace bmi_value = . if bmi_value == 0 
replace bmi_value = . if !inrange(bmi_value, 10, 80)

*Restrict to within 10 years of EIA diagnosis date and aged>16 
gen bmi_time = (eia_code_date - bmi_date)/365.25
gen bmi_age = age - bmi_time
replace bmi_value = . if bmi_age < 16 
replace bmi_value = . if bmi_time > 10 & bmi_time != . 

*Set to missing if no date, and vice versa 
replace bmi_value = . if bmi_date == . 
replace bmi_date = . if bmi_value == . 
replace bmi_time = . if bmi_value == . 
replace bmi_age = . if bmi_value == . 

*Create BMI categories
gen 	bmicat = .
recode  bmicat . = 1 if bmi_value < 18.5
recode  bmicat . = 2 if bmi_value < 25
recode  bmicat . = 3 if bmi_value < 30
recode  bmicat . = 4 if bmi_value < 35
recode  bmicat . = 5 if bmi_value < 40
recode  bmicat . = 6 if bmi_value < .
replace bmicat = .u if bmi_value >= .

label define bmicat 1 "Underweight (<18.5)" 	///
					2 "Normal (18.5-24.9)"		///
					3 "Overweight (25-29.9)"	///
					4 "Obese I (30-34.9)"		///
					5 "Obese II (35-39.9)"		///
					6 "Obese III (40+)"			///
					.u "Missing"
					
label values bmicat bmicat
lab var bmicat "BMI"

*Create less granular categorisation
recode bmicat 1/3 .u = 1 4 = 2 5 = 3 6 = 4, gen(obese4cat)

label define obese4cat 	1 "No record of obesity" 	///
						2 "Obese I (30-34.9)"		///
						3 "Obese II (35-39.9)"		///
						4 "Obese III (40+)"		

label values obese4cat obese4cat
order obese4cat, after(bmicat)

***Smoking 
label define smoke 1 "Never" 2 "Former" 3 "Current" .u "Missing"

gen     smoke = 1  if smoking_status == "N"
replace smoke = 2  if smoking_status == "E"
replace smoke = 3  if smoking_status == "S"
replace smoke = .u if smoking_status == "M"
replace smoke = .u if smoking_status == "" 

label values smoke smoke
lab var smoke "Smoking status"
drop smoking_status

*Create non-missing 3-category variable for current smoking (assumes missing smoking is never smoking)
recode smoke .u = 1, gen(smoke_nomiss)
order smoke_nomiss, after(smoke)
label values smoke_nomiss smoke

**Clinical comorbidities
***eGFR
*Set implausible creatinine values to missing (Note: zero changed to missing)
replace creatinine_value = . if !inrange(creatinine_value, 20, 3000) 

*Remove creatinine dates if no measurements, and vice versa 
replace creatinine_value = . if creatinine_date == . 
replace creatinine_date = . if creatinine_value == . 
replace creatinine = . if creatinine_value == .
recode creatinine .=0

*Divide by 88.4 (to convert umol/l to mg/dl) 
gen SCr_adj = creatinine_value/88.4

gen min = .
replace min = SCr_adj/0.7 if male==0
replace min = SCr_adj/0.9 if male==1
replace min = min^-0.329  if male==0
replace min = min^-0.411  if male==1
replace min = 1 if min<1

gen max=.
replace max=SCr_adj/0.7 if male==0
replace max=SCr_adj/0.9 if male==1
replace max=max^-1.209
replace max=1 if max>1

gen egfr=min*max*141
replace egfr=egfr*(0.993^age)
replace egfr=egfr*1.018 if male==0
label var egfr "egfr calculated using CKD-EPI formula with no ethnicity"

*Categorise into ckd stages
egen egfr_cat_all = cut(egfr), at(0, 15, 30, 45, 60, 5000)
recode egfr_cat_all 0 = 5 15 = 4 30 = 3 45 = 2 60 = 0, generate(ckd_egfr)

gen egfr_cat = .
recode egfr_cat . = 3 if egfr < 30
recode egfr_cat . = 2 if egfr < 60
recode egfr_cat . = 1 if egfr < .
replace egfr_cat = .u if egfr >= .

label define egfr_cat 	1 ">=60" 		///
						2 "30-59"		///
						3 "<30"			///
						.u "Missing"
					
label values egfr_cat egfr_cat
lab var egfr_cat "eGFR"

*If missing eGFR, assume normal
gen egfr_cat_nomiss = egfr_cat
replace egfr_cat_nomiss = 1 if egfr_cat == .u

label define egfr_cat_nomiss 	1 ">=60/missing" 	///
								2 "30-59"			///
								3 "<30"	
label values egfr_cat_nomiss egfr_cat_nomiss
lab var egfr_cat_nomiss "eGFR"

gen egfr_date = creatinine_date
format egfr_date %td

*Add in end stage renal failure and create a single CKD variable 
*Missing assumed to not have CKD 
gen ckd = 0
replace ckd = 1 if ckd_egfr != . & ckd_egfr >= 1
replace ckd = 1 if esrf == 1

label define ckd 0 "No CKD" 1 "CKD"
label values ckd ckd
label var ckd "Chronic kidney disease"

*Create date (most recent measure prior to index)
gen temp1_ckd_date = creatinine_date if ckd_egfr >=1
gen temp2_ckd_date = esrf_date if esrf == 1
gen ckd_date = max(temp1_ckd_date,temp2_ckd_date) 
format ckd_date %td 

drop temp1_ckd_date temp2_ckd_date SCr_adj min max ckd_egfr egfr_cat_all

***HbA1c
*Set zero or negative to missing
replace hba1c_percentage   = . if hba1c_percentage <= 0
replace hba1c_mmol_per_mol = . if hba1c_mmol_per_mol <= 0

*Change implausible values to missing
replace hba1c_percentage   = . if !inrange(hba1c_percentage, 1, 20)
replace hba1c_mmol_per_mol = . if !inrange(hba1c_mmol_per_mol, 10, 200)

*Set most recent values of >24 months prior to EIA diagnosis date to missing
replace hba1c_percentage   = . if (eia_code_date - hba1c_percentage_date) > 24*30 & hba1c_percentage_date != .
replace hba1c_mmol_per_mol = . if (eia_code_date - hba1c_mmol_per_mol_date) > 24*30 & hba1c_mmol_per_mol_date != .

*Clean up dates
replace hba1c_percentage_date = . if hba1c_percentage == .
replace hba1c_mmol_per_mol_date = . if hba1c_mmol_per_mol == .

*Express  HbA1c as percentage
*Express all values as perecentage 
noi summ hba1c_percentage hba1c_mmol_per_mol 
gen 	hba1c_pct = hba1c_percentage 
replace hba1c_pct = (hba1c_mmol_per_mol/10.929)+2.15 if hba1c_mmol_per_mol<. 

*Valid % range between 0-20  
replace hba1c_pct = . if !inrange(hba1c_pct, 1, 20) 
replace hba1c_pct = round(hba1c_pct, 0.1)

*Categorise HbA1c and diabetes
*Group hba1c pct
gen 	hba1ccat = 0 if hba1c_pct <  6.5
replace hba1ccat = 1 if hba1c_pct >= 6.5  & hba1c_pct < 7.5
replace hba1ccat = 2 if hba1c_pct >= 7.5  & hba1c_pct < 8
replace hba1ccat = 3 if hba1c_pct >= 8    & hba1c_pct < 9
replace hba1ccat = 4 if hba1c_pct >= 9    & hba1c_pct !=.
label define hba1ccat 0 "<6.5%" 1">=6.5-7.4" 2">=7.5-7.9" 3">=8-8.9" 4">=9"
label values hba1ccat hba1ccat

*Express all values as mmol
gen hba1c_mmol = hba1c_mmol_per_mol
replace hba1c_mmol = (hba1c_percentage*10.929)-23.5 if hba1c_percentage<. & hba1c_mmol==.

*Group hba1c mmol
gen 	hba1ccatmm = 0 if hba1c_mmol < 58
replace hba1ccatmm = 1 if hba1c_mmol >= 58 & hba1c_pct !=.
replace hba1ccatmm =.u if hba1ccatmm==. 
label define hba1ccatmm 0 "HbA1c <58mmol/mol" 1 "HbA1c >=58mmol/mol" .u "Missing"
label values hba1ccatmm hba1ccatmm
lab var hba1ccatmm "HbA1c"

*Create diabetes, split by control/not (assumes missing = no diabetes)
gen     diabcat = 1 if diabetes==0
replace diabcat = 2 if diabetes==1 & inlist(hba1ccat, 0, 1)
replace diabcat = 3 if diabetes==1 & inlist(hba1ccat, 2, 3, 4)
replace diabcat = 4 if diabetes==1 & !inlist(hba1ccat, 0, 1, 2, 3, 4)

label define diabcat 	1 "No diabetes" 			///
						2 "Controlled diabetes"		///
						3 "Uncontrolled diabetes" 	///
						4 "Diabetes, no hba1c measure"
label values diabcat diabcat

*Create cancer variable 'other cancer currently', includes carcinoma of the head and neck - need to confirm if this excludes NMSC
gen cancer =0
replace cancer =1 if lung_cancer ==1 | haem_cancer ==1 | other_cancer ==1
lab var cancer "Cancer"

*Create other comorbid variables
gen combined_cv_comorbid =1 if chronic_cardiac_disease ==1 | stroke==1
recode combined_cv_comorbid .=0

*Delete unneeded variables
drop hba1c_pct hba1c_percentage hba1c_mmol_per_mol

*Label variables
lab var hypertension "Hypertension"
lab var diabetes "Diabetes"
lab var stroke "Stroke"
lab var chronic_resp_disease "Chronic respiratory disease"
lab var copd "COPD"
lab var esrf "End-stage renal failure"
lab var chronic_liver_disease "Chronic liver disease"
lab var chronic_cardiac_disease "Chronic cardiac disease"

*Refine diagnostic window=============================================================*/

**All patients should have EIA code
tab eia_code
keep if eia_code==1

**Keep patients with first EIA code in GP record if code was after 1st March 2019
keep if eia_code_date>=date("$start_date", "DMY") & eia_code_date!=. 
tab eia_code

**Month/Year of diagnosis
gen year_diag=year(eia_code_date)
format year_diag %ty
gen month_diag=month(eia_code_date)
gen mo_year_diagn=ym(year_diag, month_diag)
format mo_year_diagn %tm

**For analyses below, all patients should have at least 6 months of follow-up after EIA code
tab has_6m_follow_up
tab has_12m_follow_up
tab mo_year_diagn has_6m_follow_up
tab mo_year_diagn has_12m_follow_up
drop if has_6m_follow_up!=1  //////////////////////////////Need to adjust below
tab has_12m_follow_up //if vast majority

*Include only most recent EIA sub-diagnosis
replace ra_code =0 if psa_code_date >= ra_code_date & psa_code_date !=.
replace ra_code =0 if anksp_code_date >= ra_code_date & anksp_code_date !=.
replace psa_code =0 if ra_code_date >= psa_code_date & ra_code_date !=.
replace psa_code =0 if anksp_code_date >= psa_code_date & anksp_code_date !=.
replace anksp_code =0 if psa_code_date >= anksp_code_date & psa_code_date !=.
replace anksp_code =0 if ra_code_date >= anksp_code_date & ra_code_date !=.
gen eia_diagnosis=1 if ra_code==1
replace eia_diagnosis=2 if psa_code==1
replace eia_diagnosis=3 if anksp_code==1
lab define eia_diagnosis 1 "RA" 2 "PsA" 3 "AxSpA", modify
lab val eia_diagnosis eia_diagnosis
tab eia_diagnosis
drop if eia_diagnosis==.

*Define appointments and referrals======================================*/

**Rheumatology appt 
tab rheum_appt  //proportion with first rheum outpatient date in the year before EIA code appears in GP record 
tab rheum_appt if rheum_appt_date<eia_code_date & rheum_appt_date!=. //confirm proportion who had rheum appt (i.e. not missing) and appt before EIA code 

**Rheumatology referrals
tab referral_rheum_prerheum //last rheum referral in the year before rheumatology outpatient (requires rheum appt to have been present)
tab referral_rheum_prerheum if rheum_appt!=0  //last rheum referral in the year before rheumatology outpatient if rheum appt date present
tab referral_rheum_prerheum if rheum_appt!=0 & referral_rheum_prerheum_date<rheum_appt_date  //last rheum referral in the year before rheumatology outpatient, assuming ref date before rheum appt date
tab referral_rheum_precode //last rheum referral in the year before EIA code (could use if rheum appt missing)
gen referral_rheum_comb_date = referral_rheum_prerheum_date if referral_rheum_prerheum_date!=.
replace referral_rheum_comb_date = referral_rheum_precode_date if referral_rheum_prerheum_date==. & referral_rheum_precode_date!=.
format %td referral_rheum_comb_date

**GP appointments
tab last_gp_refrheum //proportion with last GP appointment in year before rheum referral (pre-rheum appt)
gen all_appts=1 if last_gp_refrheum==1 & referral_rheum_prerheum==1 & rheum_appt==1 & eia_code==1 & last_gp_refrheum_date<referral_rheum_prerheum_date & referral_rheum_prerheum_date<rheum_appt_date & rheum_appt_date<eia_code_date 
recode all_appts .=0
tab all_appts //KEY - proportion who had a last gp appt, then rheum ref, then rheum appt, then EIA code 
tab last_gp_refcode	if referral_rheum_precode!=0 //last GP appointment before rheum ref if present (pre-eia code ref)
tab last_gp_prerheum if rheum_appt!=0 //last GP appointment before rheum appt (if present)
tab last_gp_precode //last GP appointment before EIA code

**For sensitivity analyses for those without rheum_appt, replace diagnosis date as EIA code date if rheum appt pre-code is missing or after
gen eia_diagnosis_date_nomiss=rheum_appt_date if rheum_appt_date!=.
format %td eia_diagnosis_date_nomiss
replace eia_diagnosis_date_nomiss=eia_code_date if (rheum_appt_date==. | rheum_appt_date>eia_code_date) & eia_code_date!=.
gen eia_diagnosis_nomiss=1 if eia_diagnosis_date_nomiss!=.
recode eia_diagnosis_nomiss .=0
tab eia_diagnosis_nomiss

*Define drugs and dates=====================================================*/

**csDMARDs (not including high cost MTX; wouldn't be shared care)
gen csdmard=1 if hydroxychloroquine==1 | leflunomide==1 | methotrexate==1 | methotrexate_inj==1 | sulfasalazine==1
recode csdmard .=0 
tab csdmard 
bys eia_diagnosis: tab csdmard

**csDMARDs (including high cost MTX)
gen csdmard_hcd=1 if hydroxychloroquine==1 | leflunomide==1 | methotrexate==1 | methotrexate_inj==1 | methotrexate_hcd==1 | sulfasalazine==1
recode csdmard_hcd .=0 
tab csdmard_hcd
bys eia_diagnosis: tab csdmard_hcd 

**Date of first csDMARD script (not including high cost MTX prescriptions)
gen csdmard_date=min(hydroxychloroquine_date, leflunomide_date, methotrexate_date, methotrexate_inj_date, sulfasalazine_date)
format %td csdmard_date

**Date of first csDMARD script (including high cost MTX prescriptions)
gen csdmard_hcd_date=min(hydroxychloroquine_date, leflunomide_date, methotrexate_date, methotrexate_inj_date, methotrexate_hcd_date, sulfasalazine_date)
format %td csdmard_hcd_date

**Biologic use
gen biologic=1 if abatacept==1 | adalimumab==1 | baricitinib==1 | certolizumab==1 | etanercept==1 | golimumab==1 | guselkumab==1 | infliximab==1 | ixekizumab==1 | rituximab==1 | sarilumab==1 | secukinumab==1 | tocilizumab==1 | tofacitinib==1 | upadacitinib==1 | ustekinumab==1 
recode biologic .=0
tab biologic 
bys eia_diagnosis: tab biologic 

**Date of first biologic script
gen biologic_date=min(abatacept_date, adalimumab_date, baricitinib_date, certolizumab_date, etanercept_date, golimumab_date, guselkumab_date, infliximab_date, ixekizumab_date, rituximab_date, sarilumab_date, secukinumab_date, tocilizumab_date, tofacitinib_date, upadacitinib_date, ustekinumab_date)
format %td biologic_date

**Exclude if first csdmard or biologic was before first rheum appt
***Nb. could introduce leeway e.g. 30 days?
tab csdmard if rheum_appt_date!=. & csdmard_date!=. & csdmard_date<rheum_appt_date
drop if rheum_appt_date!=. & csdmard_date!=. & csdmard_date<rheum_appt_date
tab biologic if rheum_appt_date!=. & biologic_date!=. & biologic_date<rheum_appt_date 
drop if rheum_appt_date!=. & biologic_date!=. & biologic_date<rheum_appt_date 

*Number of EIA diagnoses in 1-year time windows=========================================*/

gen diagnosis_year=1 if eia_code_date>=td(01mar2019) & eia_code_date<td(01mar2020)
replace diagnosis_year=2 if eia_code_date>=td(01mar2020) & eia_code_date<td(01mar2021)
replace diagnosis_year=3 if eia_code_date>=td(01mar2021) & eia_code_date<td(01mar2022)
lab define diagnosis_year 1 "March 2019-March 2020" 2 "March 2020-March 2021" 3 "March 2021-March 2022", modify
lab val diagnosis_year diagnosis_year
lab var diagnosis_year "Year of diagnosis"
tab diagnosis_year
bys eia_diagnosis: tab diagnosis_year

*Time to referral, appointment and EIA code=============================================*/

**Time from last GP to rheum ref before rheum appt (i.e. if appts are present and in correct time order) //Note - referral could be coded before GP appt?
gen time_gp_rheum_ref_appt = (referral_rheum_prerheum_date - last_gp_refrheum_date) if referral_rheum_prerheum_date!=. & last_gp_refrheum_date!=. & rheum_appt_date!=. & referral_rheum_prerheum_date>last_gp_refrheum_date & referral_rheum_prerheum_date<rheum_appt_date & rheum_appt_date<eia_code_date
tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //all patients
bys eia_diagnosis: tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //by region

**Time from last GP to rheum ref before eia code (sensitivity analysis; includes those with no rheum appt)
gen time_gp_rheum_ref_code = (referral_rheum_precode_date - last_gp_refcode_date) if referral_rheum_precode_date!=. & last_gp_refcode_date!=. & referral_rheum_precode_date>last_gp_refcode_date & referral_rheum_precode_date<eia_code_date
tabstat time_gp_rheum_ref_code, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_rheum_ref_code, stats (n mean p50 p25 p75)

**Time from last GP to rheum ref (combined - sensitivity analysis; includes those with no rheum appt)
gen time_gp_rheum_ref_comb = time_gp_rheum_ref_appt 
replace time_gp_rheum_ref_comb = time_gp_rheum_ref_code if time_gp_rheum_ref_appt==. & time_gp_rheum_ref_code!=.
tabstat time_gp_rheum_ref_comb, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_rheum_ref_comb, stats (n mean p50 p25 p75)

**Time from last GP pre-rheum appt to first rheum appt (key sensitivity analysis; includes those with no rheum ref)
gen time_gp_rheum_appt = (rheum_appt_date - last_gp_prerheum_date) if rheum_appt_date!=. & last_gp_prerheum_date!=. & rheum_appt_date>last_gp_prerheum_date & rheum_appt_date<eia_code_date
tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75) //by region

**Time from last GP pre-code to EIA code (sensitivity analysis; includes those with no rheum ref and/or no rheum appt)
gen time_gp_eia_code = (eia_code_date - last_gp_precode_date) if eia_code_date!=. & last_gp_precode_date!=. & eia_code_date>last_gp_precode_date
tabstat time_gp_eia_code, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_eia_code, stats (n mean p50 p25 p75)

**Time from last GP to EIA diagnosis (combined - sensitivity analysis; includes those with no rheum appt)
gen time_gp_eia_diag = time_gp_rheum_appt
replace time_gp_eia_diag = time_gp_eia_code if time_gp_rheum_appt==. & time_gp_eia_code!=.
tabstat time_gp_eia_diag, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_gp_eia_diag, stats (n mean p50 p25 p75)

**Time from rheum ref to rheum appt (i.e. if appts are present and in correct time order)
gen time_ref_rheum_appt = (rheum_appt_date - referral_rheum_prerheum_date) if rheum_appt_date!=. & referral_rheum_prerheum_date!=. & referral_rheum_prerheum_date<rheum_appt_date & rheum_appt_date<eia_code_date
tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75) //all patients by diagnosis year
bys nuts_region: tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75) //by region

**Time from rheum ref or last GP to rheum appt (combined - sensitivity analysis; includes those with no rheum ref)
gen time_refgp_rheum_appt = time_ref_rheum_appt
replace time_refgp_rheum_appt = time_gp_rheum_appt if time_ref_rheum_appt==. & time_gp_rheum_appt!=.
bys eia_diagnosis: tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75) //all patients by diagnosis year
bys nuts_region: tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75) //by region

**Time from rheum ref to EIA code (sensitivity analysis; includes those with no rheum appt)
gen time_ref_rheum_eia = (eia_code_date - referral_rheum_precode_date) if eia_code_date!=. & referral_rheum_precode_date!=. & referral_rheum_precode_date<eia_code_date  
tabstat time_ref_rheum_eia, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_ref_rheum_eia, stats (n mean p50 p25 p75)

**Time from rheum ref to EIA diagnosis (combined - sensitivity analysis; includes those with no rheum appt)
gen time_ref_rheum_eia_comb = time_ref_rheum_appt
replace time_ref_rheum_eia_comb = time_ref_rheum_eia if time_ref_rheum_appt==. & time_ref_rheum_eia!=.
tabstat time_ref_rheum_eia_comb, stats (n mean p50 p25 p75)
bys eia_diagnosis: tabstat time_ref_rheum_eia_comb, stats (n mean p50 p25 p75)

**Time from rheum appt to EIA code (i.e. if appts are present and in correct time order)
gen time_rheum_eia_code = (eia_code_date - rheum_appt_date) if eia_code_date!=. & rheum_appt_date!=. & rheum_appt_date<eia_code_date 
tabstat time_rheum_eia_code, stats (n mean p50 p25 p75) 
bys eia_diagnosis: tabstat time_rheum_eia_code, stats (n mean p50 p25 p75) 

*Time to first csDMARD prescriptions - all of the below are shared care prescriptions, aside from those with MTX_high cost drug data included======================================================================*/

**Time to first csDMARD script for RA patients, whereby first rheum appt is classed as diagnosis date (assumes rheum appt present; not including high cost MTX prescriptions)
gen time_to_csdmard=(csdmard_date-rheum_appt_date) if csdmard==1 & rheum_appt_date!=. & csdmard_date>rheum_appt_date 
tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for RA patients (including high cost MTX prescriptions)
gen time_to_csdmard_hcd=(csdmard_hcd_date-rheum_appt_date) if csdmard_hcd==1 & rheum_appt_date!=. & csdmard_hcd_date>rheum_appt_date 
tabstat time_to_csdmard_hcd if ra_code==1, stats (n mean p50 p25 p75) 

**Time to first csDMARD script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_csdmard_hcd if psa_code==1, stats (n mean p50 p25 p75) 

**csDMARD time categories for RA patients (not including high cost MTX prescriptions) - consider restricting to patients with only 12m follow-up
gen csdmard_6w=1 if time_to_csdmard<=42 & time_to_csdmard!=. 
recode csdmard_6w .=0
tab csdmard_6w if ra_code==1
gen csdmard_3m=1 if time_to_csdmard<=90 & time_to_csdmard!=. 
recode csdmard_3m .=0
tab csdmard_3m if ra_code==1
gen csdmard_6m=1 if time_to_csdmard<=180 & time_to_csdmard!=. 
recode csdmard_6m .=0
tab csdmard_6m if ra_code==1
gen csdmard_12m=1 if time_to_csdmard<=365 & time_to_csdmard!=. 
recode csdmard_12m .=0
tab csdmard_12m if ra_code==1

**csDMARD time categories for RA patients (including high cost MTX prescriptions)
gen csdmard_hcd_6w=1 if time_to_csdmard_hcd<=42 & time_to_csdmard_hcd!=.
recode csdmard_hcd_6w .=0
tab csdmard_hcd_6w if ra_code==1
gen csdmard_hcd_3m=1 if time_to_csdmard_hcd<=90 & time_to_csdmard_hcd!=.
recode csdmard_hcd_3m .=0
tab csdmard_hcd_3m if ra_code==1
gen csdmard_hcd_6m=1 if time_to_csdmard_hcd<=180 & time_to_csdmard_hcd!=.
recode csdmard_hcd_6m .=0
tab csdmard_hcd_6m if ra_code==1
gen csdmard_hcd_12m=1 if time_to_csdmard_hcd<=365 & time_to_csdmard_hcd!=.
recode csdmard_hcd_12m .=0
tab csdmard_hcd_12m if ra_code==1

**csDMARD time categories for PsA patients (not including high cost MTX prescriptions)
tab csdmard_6w if psa_code==1
tab csdmard_3m if psa_code==1
tab csdmard_6m if psa_code==1
tab csdmard_12m if psa_code==1

**csDMARD time categories for PsA patients (including high cost MTX prescriptions)
tab csdmard_hcd_6w if psa_code==1
tab csdmard_hcd_3m if psa_code==1
tab csdmard_hcd_6m if psa_code==1
tab csdmard_hcd_12m if psa_code==1

**What was first shared care csDMARD (not including high cost MTX prescriptions)
gen first_csD=""
foreach var of varlist hydroxychloroquine_date leflunomide_date methotrexate_date methotrexate_inj_date sulfasalazine_date {
	replace first_csD="`var'" if csdmard_date==`var' & csdmard_date!=.
	}
gen first_csDMARD = substr(first_csD, 1, length(first_csD) - 5) if first_csD!=""
drop first_csD
tab first_csDMARD if ra_code==1 //for RA patients
tab first_csDMARD if psa_code==1 //for PsA patients

**What was first csDMARD (including high cost MTX prescriptions)
gen first_csD_hcd=""
foreach var of varlist hydroxychloroquine_date leflunomide_date methotrexate_date methotrexate_inj_date methotrexate_hcd_date sulfasalazine_date {
	replace first_csD_hcd="`var'" if csdmard_hcd_date==`var' & csdmard_hcd_date!=.
	}
gen first_csDMARD_hcd = substr(first_csD_hcd, 1, length(first_csD_hcd) - 5) if first_csD_hcd!=""
drop first_csD_hcd
tab first_csDMARD_hcd if ra_code==1 //for RA patients
tab first_csDMARD_hcd if psa_code==1 //for PsA patients
 
**Methotrexate use (not including high cost MTX prescriptions)
gen mtx=1 if methotrexate==1 | methotrexate_inj==1
recode mtx .=0 
tab mtx if ra_code==1 //for RA patients
tab mtx if psa_code==1 //for PsA patients

**Methotrexate use (including high cost MTX prescriptions)
gen mtx_hcd=1 if methotrexate==1 | methotrexate_inj==1 | methotrexate_hcd==1
recode mtx_hcd .=0 
tab mtx_hcd if ra_code==1 //for RA patients
tab mtx_hcd if psa_code==1 //for PsA patients

**Date of first methotrexate script (not including high cost MTX prescriptions)
gen mtx_date=min(methotrexate_date, methotrexate_inj_date)
format %td mtx_date

**Date of first methotrexate script (including high cost MTX prescriptions)
gen mtx_hcd_date=min(methotrexate_date, methotrexate_inj_date, methotrexate_hcd_date)
format %td mtx_hcd_date

**Time to first methotrexate script for RA patients (not including high cost MTX prescriptions)
gen time_to_mtx=(mtx_date-rheum_appt_date) if mtx==1 & rheum_appt_date!=. & mtx_date>rheum_appt_date 
tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for RA patients (including high cost MTX prescriptions)
gen time_to_mtx_hcd=(mtx_hcd_date-rheum_appt_date) if mtx_hcd==1 & rheum_appt_date!=. & mtx_hcd_date>rheum_appt_date 
tabstat time_to_mtx_hcd if ra_code==1, stats (n mean p50 p25 p75)

**Time to first methotrexate script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75)
bys diagnosis_year: tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_mtx_hcd if psa_code==1, stats (n mean p50 p25 p75)

**Methotrexate time categories for RA patients (not including high-cost MTX) //Nb. this is time period from rheum appt (i.e. diagnosis) to shared care, not from referral to first script 
gen mtx_6w=1 if time_to_mtx<=42 & time_to_mtx!=.
recode mtx_6w .=0
tab mtx_6w if ra_code==1
gen mtx_3m=1 if time_to_mtx<=90 & time_to_mtx!=.
recode mtx_3m .=0
tab mtx_3m if ra_code==1
gen mtx_6m=1 if time_to_mtx<=180 & time_to_mtx!=.
recode mtx_6m .=0
tab mtx_6m if ra_code==1
gen mtx_12m=1 if time_to_mtx<=365 & time_to_mtx!=. 
recode mtx_12m .=0
tab mtx_12m if ra_code==1

**Methotrexate time categories for RA patients (including high-cost MTX)
gen mtx_hcd_6w=1 if time_to_mtx_hcd<=42 & time_to_mtx_hcd!=.
recode mtx_hcd_6w .=0
tab mtx_hcd_6w if ra_code==1
gen mtx_hcd_3m=1 if time_to_mtx_hcd<=90 & time_to_mtx_hcd!=.
recode mtx_hcd_3m .=0
tab mtx_hcd_3m if ra_code==1
gen mtx_hcd_6m=1 if time_to_mtx_hcd<=180 & time_to_mtx_hcd!=.
recode mtx_hcd_6m .=0
tab mtx_hcd_6m if ra_code==1
gen mtx_hcd_12m=1 if time_to_mtx_hcd<=365 & time_to_mtx_hcd!=.
recode mtx_hcd_12m .=0
tab mtx_hcd_12m if ra_code==1

**Methotrexate time categories for PsA patients (not including high-cost MTX)
tab mtx_6w if psa_code==1
tab mtx_3m if psa_code==1
tab mtx_6m if psa_code==1
tab mtx_12m if psa_code==1

**Methotrexate time categories for PsA patients (including high-cost MTX)
tab mtx_hcd_6w if psa_code==1
tab mtx_hcd_3m if psa_code==1
tab mtx_hcd_6m if psa_code==1
tab mtx_hcd_12m if psa_code==1

**Time to first biologic script, whereby first rheum appt is classed as diagnosis date (assumes rheum appt present); high_cost drug data available to Nov 2020======================================================================*/

*Below analyses are only for patients with at least 12 months of follow-up available after EIA code
tab has_12m_follow_up
gen time_to_biologic=(biologic_date-rheum_appt_date) if biologic==1 & rheum_appt_date!=. & biologic_date>rheum_appt_date 
tabstat time_to_biologic if has_12m_follow_up==1, stats (n mean p50 p25 p75) //for all EIA patients
bys eia_diagnosis: tabstat time_to_biologic if has_12m_follow_up==1, stats (n mean p50 p25 p75) 
bys diagnosis_year: tabstat time_to_biologic if ra_code==1 & has_12m_follow_up==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_biologic if ra_code==1 & has_12m_follow_up==1, stats (n mean p50 p25 p75) //by region

**What was first biologic
gen first_bio=""
foreach var of varlist abatacept_date adalimumab_date baricitinib_date certolizumab_date etanercept_date golimumab_date guselkumab_date infliximab_date ixekizumab_date rituximab_date sarilumab_date secukinumab_date tocilizumab_date tofacitinib_date upadacitinib_date ustekinumab_date {
	replace first_bio="`var'" if biologic_date==`var' & biologic_date!=.
	}
gen first_biologic = substr(first_bio, 1, length(first_bio) - 5)	
drop first_bio
tab first_biologic if has_12m_follow_up==1 //for all EIA patients
bys eia_diagnosis: tab first_biologic if has_12m_follow_up==1

**Biologic time categories (for all patients)
gen biologic_6m=1 if time_to_biologic<=180 & time_to_biologic!=.
recode biologic_6m .=0
tab biologic_6m if has_12m_follow_up==1 //for all EIA patients
bys eia_diagnosis: tab biologic_6m if has_12m_follow_up==1
gen biologic_12m=1 if time_to_biologic<=365 & time_to_biologic!=.
recode biologic_12m .=0
tab biologic_12m if has_12m_follow_up==1 //for all EIA patients
bys eia_diagnosis: tab biologic_12m if has_12m_follow_up==1

**Biologic time categories (by year)
bys diagnosis_year: tab biologic_6m if has_12m_follow_up==1 //for all EIA patients
bys diagnosis_year eia_diagnosis: tab biologic_6m if has_12m_follow_up==1 //for each diagnosis
bys diagnosis_year: tab biologic_12m if has_12m_follow_up==1 //for all EIA patients
bys diagnosis_year eia_diagnosis: tab biologic_12m if has_12m_follow_up==1 //for each diagnosis

save "$projectdir/output/data/file_eia_all", replace

log close
