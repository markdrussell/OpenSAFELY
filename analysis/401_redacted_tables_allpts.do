version 16

/*==============================================================================
DO FILE NAME:			redacted output tables
PROJECT:				EIA OpenSAFELY project
DATE: 					07/03/2022
AUTHOR:					J Galloway / M Russell
						adapted from C Rentsch										
DESCRIPTION OF FILE:	redacted output table
DATASETS USED:			main data file
DATASETS CREATED: 		redacted output table
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)						
==============================================================================*/

**Set filepaths
*global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY\Github Practice"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY\Github Practice"
global projectdir `c(pwd)'
di "$projectdir"

capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

global logdir "$projectdir/logs"
di "$logdir"

**Open a log file
cap log close
log using "$logdir/redacted_tables_allpts.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

set scheme plotplainblind

**Set index dates ===========================================================*/
global year_preceding = "01/04/2018"
global start_date = "01/04/2019"
global appt_date = "01/04/2021"
global end_date = "01/04/2022"

*Descriptive statistics======================================================================*/

**Baseline table for reference population
clear *
save "$projectdir/output/data/table_1_rounded_allpts.dta", replace emptyok
use "$projectdir/output/data/file_eia_allpts.dta", clear

foreach var of varlist ckd chronic_liver_disease chronic_resp_disease cancer stroke chronic_cardiac_disease diabcatm hypertension smoke bmicat imd ethnicity male agegroup {
	preserve
	contract `var'
	local v : variable label `var' 
	gen variable = `"`v'"'
    decode `var', gen(categories)
	gen count = round(_freq, 5)
	egen total = total(count)
	gen percent = round((count/total)*100, 0.1)
	order total, after(percent)
	gen countstr = string(count)
	replace countstr = "<6" if count<=5
	order countstr, after(count)
	drop count
	rename countstr count
	tostring percent, gen(percentstr) force format(%9.1f)
	replace percentstr = "-" if count =="<6"
	order percentstr, after(percent)
	drop percent
	rename percentstr percent
	gen totalstr = string(total)
	replace totalstr = "-" if count =="<6"
	order totalstr, after(total)
	drop total
	rename totalstr total
	list variable categories count percent total
	keep variable categories count percent total
	append using "$projectdir/output/data/table_1_rounded_allpts.dta"
	save "$projectdir/output/data/table_1_rounded_allpts.dta", replace
	restore
}
use "$projectdir/output/data/table_1_rounded_allpts.dta", clear
export excel "$projectdir/output/tables/table_1_rounded_allpts.xls", replace keepcellfmt firstrow(variables)

*Output tables as CSVs		 
import excel "$projectdir/output/tables/table_1_rounded_allpts.xls", clear
export delimited using "$projectdir/output/tables/table_1_rounded_allpts.csv" , novarnames  replace		

log close