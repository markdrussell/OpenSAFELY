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
*global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY\Github JG Practice"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY\Github JG Practice"
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
*Table 1a - 
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

/*
*Table 1b - by imid type 
table1_mc, by(joint) total(before) onecol iqrmiddle(",")  ///
	vars(agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f \ ///
		 standtnf bin %5.1f \ ///
		 standil6 bin %5.1f \ ///
		 standritux bin %5.1f \ ///
		 standil17 bin %5.1f \ ///
		 standjaki bin %5.1f \ ///
		 standvedolizumab bin %5.1f \ ///
		 standabatacept bin %5.1f )
		 
table1_mc, by(skin) total(before) onecol iqrmiddle(",")  ///
	vars(agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f \ ///
		 standtnf bin %5.1f \ ///
		 standil23 bin %5.1f \ ///
		 standil17 bin %5.1f \ ///
		 standabatacept bin %5.1f )
		 
table1_mc, by(bowel) total(before) onecol iqrmiddle(",") ///
	vars(agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f \ ///
		 standtnf bin %5.1f \ ///
		 standjaki bin %5.1f \ ///
		 standvedolizumab bin %5.1f  )	
	
*Table 2 - high cost drugs (v non-high cost) - single group contribution only
table1_mc, by(imiddrugcategory) total(before) onecol iqrmiddle(",")  ///
	vars(joint bin %5.1f \ ///
		psoriatic_arthritis bin %5.1f \	///			
		rheumatoid_arthritis bin %5.1f \	///  
		ankylosing_spondylitis bin %5.1f \ ///	
		skin bin %5.1f \ ///
		psoriasis bin %5.1f \ ///
		hidradenitis_suppurativa bin %5.1f \	///
		bowel bin %5.1f \ ///
		ulcerative_colitis bin %5.1f	\ ///
		crohns_disease bin %5.1f \ ///
		ibd_uncla bin %5.1f \ ///	
		agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f )

keep if imid==1
		 
*2a IMID only: TNFi vs standard systemic
table1_mc, by(standtnf) total(before) onecol iqrmiddle(",") ///
	vars(joint bin %5.1f \ ///
		psoriatic_arthritis bin %5.1f \	///			
		rheumatoid_arthritis bin %5.1f \	///  
		ankylosing_spondylitis bin %5.1f \ ///	
		skin bin %5.1f \ ///
		psoriasis bin %5.1f \ ///
		hidradenitis_suppurativa bin %5.1f \	///
		bowel bin %5.1f \ ///
		ulcerative_colitis bin %5.1f	\ ///
		crohns_disease bin %5.1f \ ///
		ibd_uncla bin %5.1f \ ///	
		agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f )

*2b IMID only:  IL-12/23i vs standard systemic
table1_mc, by(standil23) total(before) onecol iqrmiddle(",")  ///
	vars(joint bin %5.1f \ ///
		psoriatic_arthritis bin %5.1f \	///			
		rheumatoid_arthritis bin %5.1f \	///  
		ankylosing_spondylitis bin %5.1f \ ///	
		skin bin %5.1f \ ///
		psoriasis bin %5.1f \ ///
		hidradenitis_suppurativa bin %5.1f \	///
		bowel bin %5.1f \ ///
		ulcerative_colitis bin %5.1f	\ ///
		crohns_disease bin %5.1f \ ///
		ibd_uncla bin %5.1f \ ///	
		agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f )

*2c Psoriasis, PsA, AS only: IL-17i vs standard systemic
table1_mc, by(standil17) total(before) onecol iqrmiddle(",")  ///
	vars(joint bin %5.1f \ ///
		psoriatic_arthritis bin %5.1f \	///			
		rheumatoid_arthritis bin %5.1f \	///  
		ankylosing_spondylitis bin %5.1f \ ///	
		skin bin %5.1f \ ///
		psoriasis bin %5.1f \ ///
		hidradenitis_suppurativa bin %5.1f \	///
		bowel bin %5.1f \ ///
		ulcerative_colitis bin %5.1f	\ ///
		crohns_disease bin %5.1f \ ///
		ibd_uncla bin %5.1f \ ///	
		agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f )

*2d IMID only: JAKi vs standard systemic 
table1_mc, by(standjaki) total(before) onecol iqrmiddle(",")  ///
	vars(joint bin %5.1f \ ///
		psoriatic_arthritis bin %5.1f \	///			
		rheumatoid_arthritis bin %5.1f \	///  
		ankylosing_spondylitis bin %5.1f \ ///	
		skin bin %5.1f \ ///
		psoriasis bin %5.1f \ ///
		hidradenitis_suppurativa bin %5.1f \	///
		bowel bin %5.1f \ ///
		ulcerative_colitis bin %5.1f	\ ///
		crohns_disease bin %5.1f \ ///
		ibd_uncla bin %5.1f \ ///	
		agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f )

*2e IMID only: RTX vs standard systemic
table1_mc, by(standritux) total(before) onecol iqrmiddle(",")  ///
	vars(joint bin %5.1f \ ///
		agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f )

*2f IMID only: IL6 vs standard systemic
table1_mc, by(standil6) total(before) onecol iqrmiddle(",")  ///
	vars(joint bin %5.1f \ ///
		agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f )

*2g IMID only: Infliximab vs standard systemic
table1_mc, by(standinflix) total(before) onecol iqrmiddle(",") ///
	vars(joint bin %5.1f \ ///
		psoriatic_arthritis bin %5.1f \	///			
		rheumatoid_arthritis bin %5.1f \	///  
		ankylosing_spondylitis bin %5.1f \ ///	
		skin bin %5.1f \ ///
		psoriasis bin %5.1f \ ///
		hidradenitis_suppurativa bin %5.1f \	///
		bowel bin %5.1f \ ///
		ulcerative_colitis bin %5.1f	\ ///
		crohns_disease bin %5.1f \ ///
		ibd_uncla bin %5.1f \ ///	
		agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f )

*2h IMID only: Vedolizumab vs standard systemic
table1_mc, by(standvedolizumab) total(before) onecol iqrmiddle(",") ///
	vars(joint bin %5.1f \ ///
		psoriatic_arthritis bin %5.1f \	///			
		rheumatoid_arthritis bin %5.1f \	///  
		ankylosing_spondylitis bin %5.1f \ ///	
		skin bin %5.1f \ ///
		psoriasis bin %5.1f \ ///
		hidradenitis_suppurativa bin %5.1f \	///
		bowel bin %5.1f \ ///
		ulcerative_colitis bin %5.1f	\ ///
		crohns_disease bin %5.1f \ ///
		ibd_uncla bin %5.1f \ ///	
		agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f )

*2i IMID only: Abatacept vs standard systemic
table1_mc, by(standabatacept) total(before) onecol iqrmiddle(",") ///
	vars(joint bin %5.1f \ ///
		psoriatic_arthritis bin %5.1f \	///			
		rheumatoid_arthritis bin %5.1f \	///  
		ankylosing_spondylitis bin %5.1f \ ///	
		skin bin %5.1f \ ///
		psoriasis bin %5.1f \ ///
		hidradenitis_suppurativa bin %5.1f \	///
		bowel bin %5.1f \ ///
		ulcerative_colitis bin %5.1f	\ ///
		crohns_disease bin %5.1f \ ///
		ibd_uncla bin %5.1f \ ///	
		agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 obese4cat cat %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 chronic_cardiac_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 combined_cv_comorbid bin %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcat cat %5.1f \ ///
		 cancer cat %5.1f \ ///
		 ckd_egfr cat %5.1f \ ///
		 esrf bin %5.1f \ ///
		 chronic_respiratory_disease cat  %5.1f \ ///
		 chronic_liver_disease cat %5.1f \ ///
		 gp_consult_count contn %5.1f \ ///
		 steroidcat bin %5.1f \ ///
		 oral_prednisolone_3m_0m contn %5.1f )
		 
*/		 
		 
log close