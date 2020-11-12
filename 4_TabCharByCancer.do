***** 4_TabCharByCancer.do *****
use data/Cohort_Dataset.dta, clear

global colvar = "cancertype"


** Define column headers
label define ${colvar}_ 0 "Total", modify
local collist = "0 1 2 3 4" 

* Total N per column
foreach col of local collist {
	local label`col' : label ${colvar}_ `col'
	if `col'==0 {
		qui: count
	}
	else {
		qui: count if ${colvar}==`col'
	}
	local coltotal_`col' = `r(N)'
	di " `col' - `label`col'' (n=`coltotal_`col'')"
}

** Categorical vars
foreach var in sex agecat sizecat loca_adrmet synvsmeta other_metastasis surgcat surgextent radical {
	di "`var'"
	preserve
	
	* Count nonmissing 
	qui: count if !mi(`var')
	local nonmiss = `r(N)'
	
	* Count each category
	qui: statsby, by(${colvar} `var') clear : count
	
	* Reshape
	qui: reshape wide N , i(`var') j(${colvar}) 
	
	* Calculate rowtotal
	qui: egen N0 = rowtotal(N*)
	
	* Calculate column percentage
	foreach col of local collist {
		capture: egen perc_`col' = pc(N`col')
		capture: gen cell_`col' = 	string(N`col') /// N
							+ " (" ///
							+ string(round(perc_`col', 0.1), "%3.1f") ///
							+ ")"
	capture: drop N`col' perc_`col'
	}
	
	* Row names (subgroups)
	qui: decode `var', gen(seccol)
	qui: replace seccol = seccol + ", n (%)"
	
	* Row names (var group)
	local name : variable label `var'
	local obsno = _N+1
	qui: set obs `obsno'
	
	qui: gen var = "`var'"
	qui: gen firstcol = "`name'" if _n==_N
	
	* Add nonmissing
	if `nonmiss'<$Ncohort { // Missing data
		qui: replace firstcol = firstcol + " [n=`nonmiss']" if _n==_N
	}
	
	* Sort and order
	gsort -firstcol +`var'
	qui: drop `var'
	order var firstcol seccol cell_0 cell_*
	
	* Save
	tempfile results_`var'
	qui: save `results_`var'', replace
	
	restore
}


** Continous results
foreach var in mean.age mean.bmi mean.cci median.delay median.patosize  { //  
	di "`var'"
	preserve
	
	local type = substr("`var'", 1, strpos("`var'", ".")-1)
	local var = substr("`var'", strpos("`var'", ".")+1, .)
	di "`type' - `var'"
	
	local name : variable label `var'
	
	* Median
	if "`type'"=="median" {
		* Calculate median and range
		qui: statsby, by(${colvar}) clear total: su `var', detail
		gen cell_ = string(round(p50, 1), "%3.0f") /// Median
								+ " (" /// 
								+ string(round(p25, 1), "%3.0f") /// min
								+ "-" ///
								+ string(round(p75, 1), "%3.0f") /// max
								+ ")"
		
		* Row names (var group)
		qui: gen firstcol = "`name', median (IQR)" 
		qui: gen seccol = " "
		qui: gen var = "`var'"
	}
	
	* Mean
	if "`type'"=="mean" {
		* Calculate mean and SD
		qui: statsby, by(${colvar}) clear total: su `var', detail
		if inlist("`var'", "age", "bmi", "cci") {
			gen cell_ = string(round(mean, 0.1), "%3.1f") /// Median
								+ " (" /// 
								+ string(round(sd, 0.1), "%3.1f") /// min
								+ ")"
		}
		else {
			gen cell_ = string(round(mean, 1), "%3.0f") /// Median
								+ " (" /// 
								+ string(round(sd, 1), "%3.0f") /// min
								+ ")"
		}
		
		* Row names (var group)
		qui: gen firstcol = "`name', mean (SD)" 
		qui: gen seccol = " "
		qui: gen var = "`var'"
	}
	
	* Reshape 
	qui: recode ${colvar} (.=0)
	keep var var firstcol seccol ${colvar} cell_
	qui: reshape wide cell_, i(var) j(${colvar})
	
	* Order
	order var firstcol seccol cell_0 cell_* 
	
	* Save
	tempfile results_`var'
	qui: save `results_`var'', replace
	
	restore
}


*** Special variables
** Surg duration by surgical approach
levelsof surgcat_simple

foreach var in optime {
	local name : variable label `var'
	
	qui: count if !mi(`var')
	local nonmiss = `r(N)'
	
	* Calculate median and range (total)
	qui: levelsof surgcat_simple, local(subgroups)
	foreach grp of local subgroups {
		qui: su `var' if surgcat_simple==`grp', detail
		
		local var_grp_`grp' = string(round(`r(p50)', 1), "%3.0f") /// Median
							+ " (" /// 
							+ string(round(`r(p25)', 1), "%3.0f") /// min
							+ "-" ///
							+ string(round(`r(p75)', 1), "%3.0f") /// max
							+ ")"
		
		di "surgcat, subgrp `grp' median (IQR): `var_grp_`grp'')"
		
	}
	
	* Calculate median and range (by colvar)
	qui: statsby, by(surgcat_simple $colvar) clear: su `var', detail
	
	gen cell_ = string(round(p50, 1), "%3.0f") /// Median
							+ " (" /// 
							+ string(round(p25, 1), "%3.0f") /// min
							+ "-" ///
							+ string(round(p75, 1), "%3.0f") /// max
							+ ")"
	keep surgcat cell_ $colvar
	
	* Reshape
	qui: reshape wide cell_ , i(surgcat_simple) j(${colvar}) 
	
	* Add total value
	gen cell_0 = ""
	foreach grp of local subgroups {
		replace cell_0 = "`var_grp_`grp''" if surgcat_simple==`grp'
	}
	
	* Row names (var group)
	local obs = `r(N)'+1
	set obs `obs'
	sort cell_1
	qui: gen firstcol = "`name' [n=`nonmiss']" if _n==1
	qui: gen var = "`var'"
	
	decode surgcat_simple, gen(seccol)
	replace seccol = seccol + ", median (IQR)" if mi(firstcol)
	
	* Order
	drop surgcat_simple
	order var firstcol seccol cell_0 cell_* 
	
	* Save
	tempfile results_`var'
	qui: save `results_`var'', replace

}


** Combining results
* Headings and N 
drop _all
qui: set obs 2
gen var = " "
qui: gen firstcol = "Patients, n " if _n==2
gen seccol = " "
foreach col of local collist {
	di " `col' - `label`col''"
	qui: gen cell_`col' = "`label`col''" if _n==1
	qui: replace cell_`col' = "`coltotal_`col''" if _n==2
}

* Appending results 
foreach var in sex agecat age bmi cci delay sizecat patosize loca_adrmet synvsmeta other_metastasis surgcat surgextent radical optime {
	qui: append using `results_`var''
}

* Format first column
qui: replace seccol = subinstr(seccol, "{&ge}", ustrunescape("\u2265"), 1) // equal-or-above-sign
qui: gen rowname = firstcol
qui: replace rowname = "    " + seccol if mi(rowname)

* Format cells
qui: ds cell*
foreach var in `r(varlist)' {
	qui: replace `var' = "-" if `var'==". (.)" | !mi(seccol) & mi(`var')
}
gen row = _n


*** Export 
save results/TabCharByCancer.dta, replace