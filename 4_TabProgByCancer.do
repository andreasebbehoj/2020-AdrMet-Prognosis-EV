***** 4_TabProgByCancer.do *****


*** Preparing data analysis
use data/Cohort_Dataset.dta, clear

** Outcome var
stset surv, failure(alive==0)

** Exposure vars
global expvar = "ib1.sex c.age ib1.agecat c.cci c.bmi ib1.sizecat c.patosize ib2.synvsmeta ib0.other_metastasis"

* Transforming continues exp vars
local age_per = 10
replace age = age/`age_per'

local patosize_per = 10
replace patosize = patosize/`patosize_per'

local bmi_per = 1
replace bmi = bmi/`bmi_per'

local cci_per = 1
replace cci = cci/`cci_per'

** Adjusted model
global adjvar = "ib1.sex c.age c.cci"


*** Loop over columnvar
tempfile master
save `master', replace

levelsof cancertype, local(columnvars)
foreach columnvar of local columnvars {
	
use `master', clear
keep if cancertype==`columnvar'
*** Setup frame
capture: frame change default
capture: frame drop table

frame create table
frame table {
	set obs 1
	gen columnvar = .
	gen varanalysis = "Varanalysis"
	gen varname = "Varname"
	gen vartype = "Vartype"
	gen varheader = "Varheader"
	gen subgrp = .
	gen subname = "Subgrp name"
	gen n = "n event / n total"
	gen hr_crude = "Crude HR (95%CI)"
	gen hr_crude_p = "P"
	gen hr_adjust = "Adjusted HR (95%CI) #"
	gen hr_adjust_p = "P"
	gen median = "Median survival, years (IQR)"
	gen surv1 = "1-year survival, % (95%CI)"
}

** Add varnames, subgroups and N
foreach varanalysis of global expvar {
	di _n(1) "Var and vartype:" _n _col(5) "`varanalysis'"
	
	* Increase obs no
	newrow, frame(table)

	* Define var data
	local varname = substr("`varanalysis'", strpos("`varanalysis'", ".")+1, .)
	local varheader : variable label `varname'
	local vartype = substr("`varanalysis'", 1, 1)
	
	* Varheaders and N
	qui frame table: replace varheader = "`varheader'" if _n==_N
	
	if "`vartype'"=="c" { // Continuous var
		count if !mi(`varname')
		local Ntotal = `r(N)'
		count if !mi(`varname') & alive==0
		local Nevent = `r(N)'
		
		frame table {
			qui: replace varheader = varheader + " (per ``varname'_per')" if _n==_N
			qui: replace n = "`Nevent'/`Ntotal'" if _n==_N
		}
	}
	
	if "`vartype'"=="i" { // Categorical vars
		di _col(5) "Sub groups of catvar:"
		qui: levelsof `varname'
		foreach subgrp in `r(levels)' {
			count if `varname'==`subgrp'
			local Ntotal = `r(N)'
			count if `varname'==`subgrp' & alive==0
			local Nevent = `r(N)'
		
			local subname : label `varname'_ `subgrp'
			di _col(10) "`subgrp' (`subname') "
			
			newrow, frame(table)
			frame table {
				qui: replace n = "`Nevent'/`Ntotal'" if _n==_N
				qui: replace subgrp = `subgrp' if _n==_N
				qui: replace subname = "`subname'" if _n==_N
			}
			
		}
		
	}
	
	* Add var data (to all within same varanalysis)
	frame table {
		qui: replace varanalysis = "`varanalysis'" if mi(varanalysis)
		qui: replace varname = "`varname'" if mi(varname)
		qui: replace vartype= "`vartype'" if mi(vartype)
		qui: replace columnvar = `columnvar'
	}	
}


*** Calculate Crude HR
foreach varanalysis of global expvar {
	local varname = substr("`varanalysis'", strpos("`varanalysis'", ".")+1, .)
	local vartype = substr("`varanalysis'", 1, 1)
	
	di _n "`varanalysis'"
	
	** Continuous vars
	if "`vartype'"=="c" {
		di _col(5) "continuous var"
		qui: stcox `varanalysis'
		matrix A = r(table)
		
		local est = string(round(A[1, 1], 0.001), "%4.3f")
		local lb = string(round(A[5, 1], 0.001), "%4.3f")
		local ub = string(round(A[6, 1], 0.001), "%4.3f")
		local pval = string(round(A[4, 1], 0.001), "%4.3f")
		
		di _col(15) "`est' (`lb' to `ub')"
		
		frame table {
			qui: replace hr_crude = "`est' (`lb'-`ub')"  if varname=="`varname'"
			qui: replace hr_crude_p = "`pval'"  if varname=="`varname'"
		}

	}
	
	** Categorical vars
	if "`vartype'"=="i" {
		di _col(5) "categorical var"
		
		qui: stcox `varanalysis'
		matrix A = r(table)
		
		local x = 1
		qui: levelsof `varname'
		foreach subgrp in `r(levels)' {
			local est = string(round(A[1, `x'], 0.001), "%4.3f")
			local lb = string(round(A[5, `x'], 0.001), "%4.3f")
			local ub = string(round(A[6, `x'], 0.001), "%4.3f")
			local pval = string(round(A[4, `x'], 0.001), "%4.3f")
			
			di _col(10) "`subgrp': "  _col(15) "`est' (`lb' to `ub')"
			
			frame table {
				qui: replace hr_crude = "`est' (`lb'-`ub')"  if varname=="`varname'" & subgrp==`subgrp'
				qui: replace hr_crude_p = "`pval'"  if varname=="`varname'" & subgrp==`subgrp'
			}
			
			local x = `x'+1
		}
	}
	
	
}


*** Calculate Adjusted HR
foreach varanalysis of global expvar {
	local varname = substr("`varanalysis'", strpos("`varanalysis'", ".")+1, .)
	local vartype = substr("`varanalysis'", 1, 1)
	
	** Define adjusted model
	local varadjust = subinstr("$adjvar", "`varanalysis'", "", 1)
	
	di _n "`varanalysis' (adjusted for `varadjust')"
	
	** Continuous vars
	if "`vartype'"=="c" {
		di _col(5) "continuous var"
		qui: stcox `varanalysis' `varadjust'
		matrix A = r(table)
		
		local est = string(round(A[1, 1], 0.001), "%4.3f")
		local lb = string(round(A[5, 1], 0.001), "%4.3f")
		local ub = string(round(A[6, 1], 0.001), "%4.3f")
		local pval = string(round(A[4, 1], 0.001), "%4.3f")
		
		di _col(15) "`est' (`lb' to `ub')"
		
		frame table {
			qui: replace hr_adjust = "`est' (`lb'-`ub')"  if varname=="`varname'"
			qui: replace hr_adjust_p = "`pval'"  if varname=="`varname'"
		}

	}
	
	** Categorical vars
	if "`vartype'"=="i" {
		di _col(5) "categorical var"
		
		qui: stcox `varanalysis' `varadjust'
		matrix A = r(table)
		
		local x = 1
		qui: levelsof `varname'
		foreach subgrp in `r(levels)' {
			local est = string(round(A[1, `x'], 0.001), "%4.3f")
			local lb = string(round(A[5, `x'], 0.001), "%4.3f")
			local ub = string(round(A[6, `x'], 0.001), "%4.3f")
			local pval = string(round(A[4, `x'], 0.001), "%4.3f")
			
			di _col(10) "`subgrp': "  _col(15) "`est' (`lb' to `ub')"
			
			frame table {
				qui: replace hr_adjust = "`est' (`lb'-`ub')"  if varname=="`varname'" & subgrp==`subgrp'
				qui: replace hr_adjust_p = "`pval'"  if varname=="`varname'" & subgrp==`subgrp'
			}
			
			local x = `x'+1
		}
	}
}


*** Calculate median survival
foreach varanalysis of global expvar {
	local varname = substr("`varanalysis'", strpos("`varanalysis'", ".")+1, .)
	local vartype = substr("`varanalysis'", 1, 1)

	** Continuous vars
	// No median surv for continuous vars
	
	** Categorical vars
	if "`vartype'"=="i" {
		di _n "`varanalysis'"
		di _col(5) "categorical var"

		qui: levelsof `varname'
		foreach subgrp in `r(levels)' {
			qui: stci if `varname'==`subgrp', median
			local p50 = string(round(`r(p50)', 0.1), "%4.1f")
			qui: stci if `varname'==`subgrp', p(25)
			local p25 = string(round(`r(p25)', 0.1), "%4.1f")
			qui: stci if `varname'==`subgrp', p(75)
			local p75 = string(round(`r(p75)', 0.1), "%4.1f")
			
			di _col(10) "`subgrp': "  _col(15) "`p50' (IQR `p25'-`p75')"
			
			qui frame table: replace median = "`p50' (`p25'-`p75')"  if varname=="`varname'" & subgrp==`subgrp'
		}
	}
}


foreach varanalysis of global expvar {
	preserve
	local varname = substr("`varanalysis'", strpos("`varanalysis'", ".")+1, .)
	local vartype = substr("`varanalysis'", 1, 1)
	
	** Continuous vars
	// No 1-year surv for continuous vars
	
	** Categorical vars
	if "`vartype'"=="i" {
		di _n "`varanalysis'"		
		di _col(5) "categorical var"
		qui: levelsof `varname', local(subgrps)
		
		
		tempfile surv1
		qui: sts list, at(0 1) by(`varname') saving(`surv1', replace)
		qui: use `surv1', clear
		gen no = _n
		
		foreach subgrp of local subgrps {
			qui: su no if `varname'==`subgrp' & time==1
			local est = string(round(survivor[`r(max)']*100, 0.1), "%4.1f")
			local lb = string(round(lb[`r(max)']*100, 0.1), "%4.1f")
			local ub = string(round(ub[`r(max)']*100, 0.1), "%4.1f")
			
			di _col(10) "`subgrp': "  _col(15) "`est' (95%CI `lb'-`ub')"
			
			qui frame table: replace surv1 = "`est' (`lb'-`ub')"  if varname=="`varname'" & subgrp==`subgrp'
		}
	}
	restore
}


*** Export data
frame table {
	* First column 
	qui: gen rowname = varheader if _n!=1
	qui: replace rowname = "    " + subname if mi(rowname) 
	
	* Text edits
	ds, has(type string)
	foreach var in `r(varlist)' {
		qui: replace `var' = subinstr(`var', " (.-.)", "", 1) // remove empty 95CI for refs
		qui: replace `var' = "" if `var'=="."
	}
	
	gen row = _n
	qui: save results/TabProgByCancer_`columnvar'.dta, replace
}

}


*** Combine into one table
use data/Cohort_Dataset.dta, clear

* Store labels
levelsof cancertype, local(columnvars)
foreach columnvar of local columnvars {
	local collabel`columnvar' : label cancertype_ `columnvar'
}

* Append and reshape
qui: levelsof cancertype if cancertype!=1
qui: use results/TabProgByCancer_1.dta, clear
foreach columnvar in `r(levels)' {
	qui: append using results/TabProgByCancer_`columnvar'.dta
}
qui: reshape wide n hr_crude hr_crude_p hr_adjust hr_adjust_p median surv1, i(varanalysis subgrp) j(columnvar)
order varanalysis subgrp row varname vartype varheader subname rowname

* Add super column
newrow
qui: recode row (.=0) if _n==_N
sort row

foreach columnvar of local columnvars {
	foreach var in n hr_crude hr_adjust median surv1 {
		qui: replace `var'`columnvar' = "`collabel`columnvar''" if row==0
	}
}

* Save
qui: save results/TabProgByCancer_Combined.dta, replace