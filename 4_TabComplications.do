***** 4_TabComplications.do *****
frame reset

*** Prepare data
use data/Cohort_Dataset.dta, clear
describe cd_*

** Change labels 
label var cd_uti___1 "Urinary tract infection (choice=)"
label var cd_other3___1 "Other (choice=)"
label var cd_other4___1 "Other (choice=)"

** Combine complications
* Other CD 1 + other CD 2 + rare complications
egen anycomp = rowmax(cd_other2___* cd_oedema___* cd_nerve___*)
replace cd_other1___1 =1 if anycomp==1
label var cd_other1___1 "Other (choice=)"
drop cd_other2___* cd_oedema___* cd_nerve___* anycomp


*** Group complications in Clavien-Dindo 
* Categories
gen cdcat = .
label var cdcat "Clavien-Dindo classification"
label define cdcat_ ///
	0 "No complications" ///
	1 "Clavien-Dindo 1 or 2" ///
	3 "Clavien-Dindo 3" ///
	4 "Clavien-Dindo 4" ///
	5 "Clavien-Dindo 5" ///
	.a "Missing records"
label value cdcat cdcat_

* Define comp classes
global cd1 = "cd_bleeding cd_organcapsular cd_tumorleak cd_woundinfec cd_gi cd_uti cd_pneumonia cd_atelec  cd_other1" // CD 1-2

global cd3 = "cd_conversion cd_organresec cd_abssevere cd_pleuraex cd_organadhere cd_reopbleeding cd_organlesion cd_ulcer cd_other3" // CD 3

global cd4 = "cd_chola cd_renalinsuf cd_delir cd_abdocat cd_cardiac cd_circcol cd_sepsis cd_renalinfarc cd_pancreas cd_ai cd_multiorgan cd_other4" // CD 4

global cd5 = "cd_death" // CD 5

* CD5 Death
gen cd_death = 1 if alive==0 & surv<=30
label var cd_death "Death with 30 days"
recode cdcat (.=5) if cd_death==1

* Missing
recode cdcat (.=.a) if mi(compli_during) & mi(compli_after) & mi(compli_postop) & cd_death!=1
drop if cdcat==.a
global footnote_comp_miss = `r(N_drop)'

drop if mi(surgcat_simple)
global footnote_comp_nosurg = `r(N_drop)'

** CD 1-4
foreach cdcat in 4 3 1 {
	di _n "CD`cdcat'"
	
	foreach var of global cd`cdcat' {
		di "`var'"
		* Combine the three peri, post and long term complications
		qui: ds `var'*
		local vars = "`r(varlist)'"
		local varlist = subinstr("`vars'", " ", ", ", .)
		qui: gen `var' = 1 if inlist(1, `varlist') 
		
		* Add label
		local label : var label `var'___1
		local label = substr("`label'", 1, strpos("`label'", "(choice=")-2)
		
		drop `vars'
		label var `var' "`label'"
		
		* Recode cdcat
		qui: recode cdcat (.=`cdcat') if `var'==1
	}
}

* No complications
recode cdcat (.=0)
tab cdcat, mi


*** Generate table
addtab_setup, frame(table) columnvar(surgcat_simple)
addtab_no if cdcat==0, var(cdcat) rowname("No complications") colp

foreach cdcat in 1 3 4 5 {
	local label : label cdcat_ `cdcat'
	di "`label'"
	* Add CD types and n(%)
	qui: addtab_no if cdcat==`cdcat', var(cdcat) rowname("`label', n (%)") colp
	
	* Add details
	foreach var of global cd`cdcat' {
		local label : var label `var'
		qui: addtab_no if `var'==1, var(`var') rowname("`label', n")
	}
}

* Export
frame table: save results/TabComplications.dta, replace