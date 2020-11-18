***** 4_TabComplications.do *****
use data/Cohort_Complications.dta, clear

global colvar = "surgcat_simple"
levelsof $colvar
global subgrps = "`r(levels)'"


*** Setup frame
capture: frame change default
capture: frame drop table

* Column headers
frame create table
frame table {
	set obs 1
	gen var = ""
	gen rowname = ""
	gen cell_total = "Total _p n (%)"
	gen n_total = .
}

foreach subgrp of global subgrps {
	di "`subgrp'"
	local label : label ${colvar}_ `subgrp'
	frame table: gen cell_`subgrp' = "`label' _p n (%)"
	frame table: gen n_`subgrp' = .
}

* Row names
ds Npatients ///
	compli_peri peri_anyminor peri_minor_* peri_anymajor peri_major_* ///
	compli_post post_anyminor post_minor_* post_anymajor post_major_* ///
	compli_death death

foreach var in `r(varlist)' {
	newrow, frame(table)
	qui frame table: replace var = "`var'" if _n==_N
	local rowname : variable label `var'
	qui frame table: replace rowname = "`rowname'" if _n==_N
}

* Rownumber and rowheaders
qui frame table: gen row = _n
qui frame table: gen rowheader = 0 if _n==1
qui frame table: recode rowheader (.=1) if strpos(var, "compli_")
qui frame table: recode rowheader (.=2) if strpos(var, "_anym")

*** Count nonmissing
foreach var in Npatients compli_peri compli_post compli_death {
	* Total
	count if !mi(`var')
	local Ntotal_`var' = `r(N)'
	qui frame table: replace n_total = `Ntotal_`var'' if var=="`var'"
	qui frame table: replace cell_total = "`Ntotal_`var''" if var=="`var'"
	
	* By colvar
	foreach col of global subgrps {
		count if !mi(`var') & $colvar == `col'
		local N`col'_`var' = `r(N)'
		qui frame table: replace n_`col' = `N`col'_`var'' if var=="`var'"
		qui frame table: replace cell_`col' = "`N`col'_`var''" if var=="`var'"
	}
	
}

*** Count with complications
foreach time in peri post death {
	frame table: levelsof var if strpos(var, "`time'") & strpos(var, "compli_")==0, local(varlist)
	foreach var of local varlist {
		* Total
		qui: count if `var'==1
		qui frame table: replace n_total = `r(N)' if var=="`var'"
		* By colvar
		foreach col of global subgrps {
			qui: count if `var'==1 & $colvar == `col'
			qui frame table: replace n_`col' = `r(N)' if var=="`var'"
		}
	}
}

*** Calculate percent
* Total
foreach time in peri post death {
	frame table: levelsof var if strpos(var, "`time'") & strpos(var, "compli_")==0, local(varlist)
	foreach var of local varlist {
		* Total
		frame table {
			qui: su row if var=="`var'"
			local rowno = `r(max)'
			local n = n_total[`rowno']
			local p = string(round(100*`n'/`Ntotal_compli_`time'', 0.1), "%4.1f")
			qui: replace cell_total = "`n' (`p')" if var=="`var'"
		}
		* By colvar
		foreach col of global subgrps {
			*di "`var'- `col'"
			frame table {	
				local n = n_`col'[`rowno']
				local p = string(round(100*`n'/`N`col'_compli_`time'', 0.1), "%4.1f")
				qui: replace cell_`col' = "`n' (`p')" if var=="`var'"
			}
		}
	}
}

qui frame table: save results/TabComplications.dta, replace