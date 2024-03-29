***** 4_TabProg.do *****


*** Preparing data analysis
use data/Cohort_Dataset.dta, clear

** Outcome var
stset surv, failure(alive==0) scale(30.4)

** Exposure vars
global expvar = "ib1.sex c.age ib1.agecat c.cci c.bmi ib1.cancertype ib1.sizecat c.patosize ib2.synvsmeta ib0.other_metastasis ib1.surgcat_simple ib0.radical"

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


*** Setup frame
capture: frame change default
capture: frame drop table

frame create table
frame table {
	set obs 1
	gen varanalysis = "Varanalysis"
	gen varname = "Varname"
	gen vartype = "Vartype"
	gen varheader = "Varheader"
	gen subgrp = .
	gen subname = "Subgrp name"
	gen n = "n died /_pn total"
	gen hr_crude = "Crude HRR_p(95%CI)"
	gen hr_crude_p = "P"
	gen hr_adjust = "Adjusted HRR_p(95%CI) *"
	gen hr_adjust_p = "P"
	gen median = "Median survival_pmonths (IQR)"
	gen surv1 = "1-year survival_p% (95%CI)"
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
		
		local est = string(round(A[1, 1]${signo_cox})
		local lb = string(round(A[5, 1]${signo_cox})
		local ub = string(round(A[6, 1]${signo_cox})
		local pval = string(round(A[4, 1]${signo_pval})
		
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
			local est = string(round(A[1, `x']${signo_cox})
			local lb = string(round(A[5, `x']${signo_cox})
			local ub = string(round(A[6, `x']${signo_cox})
			local pval = string(round(A[4, `x']${signo_pval})
			
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
		
		local est = string(round(A[1, 1] ${signo_cox})
		local lb = string(round(A[5, 1] ${signo_cox})
		local ub = string(round(A[6, 1] ${signo_cox})
		local pval = string(round(A[4, 1] ${signo_pval})
		
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
			local est = string(round(A[1, `x'] ${signo_cox})
			local lb = string(round(A[5, `x'] ${signo_cox})
			local ub = string(round(A[6, `x'] ${signo_cox})
			local pval = string(round(A[4, `x'] ${signo_pval})
			
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
			local p50 = string(round(`r(p50)' ${signo_medsurv})
			qui: stci if `varname'==`subgrp', p(25)
			local p25 = string(round(`r(p25)' ${signo_medsurv})
			qui: stci if `varname'==`subgrp', p(75)
			local p75 = string(round(`r(p75)' ${signo_medsurv})
			
			di _col(10) "`subgrp': "  _col(15) "`p50' (IQR `p25'-`p75')"
			
			qui frame table: replace median = "`p50' (`p25'-`p75')"  if varname=="`varname'" & subgrp==`subgrp'
		}
	}
}


*** Calculate 1-year survival
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
		qui: sts list, at(0 12) by(`varname') saving(`surv1', replace)
		qui: use `surv1', clear
		gen no = _n
		
		foreach subgrp of local subgrps {
			qui: su no if `varname'==`subgrp' & time==12
			local est = string(round(survivor[`r(max)']*100 ${signo_surv1})
			local lb = string(round(lb[`r(max)']*100 ${signo_surv1})
			local ub = string(round(ub[`r(max)']*100 ${signo_surv1})
			
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
	qui: replace rowname = "    " + subname if mi(rowname) & _n!=1
	
	* Text edits
	ds, has(type string)
	foreach var in `r(varlist)' {
		qui: replace `var' = subinstr(`var', " (.-.)", "", 1) // remove empty 95CI for refs
		qui: replace `var' = "" if `var'=="."
	}
	
	* Pvalues
	foreach var in hr_crude_p hr_adjust_p {
		qui: replace `var' = "<0.001" if `var'=="0.000"
	}
	
	gen row = _n
	qui: save results/TabProgOverall.dta, replace
}