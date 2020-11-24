***** 4_TabComplications.do *****
use data/Cohort_Complications.dta, clear

**** Footnotes for table
* Patients major complications and/or death
tab death post_anymajor, mi

count if inlist(post_anymajor, 0, 1)
local Navailable = `r(N)'

count if inlist(post_anymajor, 0, 1) & death==1
local Ndeath = `r(N)'

count if post_anymajor==0 & death==1
local Ndeath_nomajor = `r(N)'

count if post_anymajor==1 & death==1
local Ndeath_major = `r(N)'

count if inlist(post_anymajor, 0, 1) & death==1 | post_anymajor==1
local Ndeathormajor = `r(N)'
local Pdeathormajor = string(round(100*`Ndeathormajor'/`Navailable' ${signo_percent})

global Footnote_comp_death = "Of the `Navailable' with available data on postoperative complications, `Ndeath' died within 30 days (of whom `Ndeath_major' patients also had other major complications while `Ndeath_nomajor' patients did not). If including the `Ndeath_nomajor' patients who died but had no other major surgical complications, `Ndeathormajor' (`Pdeathormajor'%) died and/or had any other major complication."
di "${Footnote_comp_death}"

* Details on major organ lesions
assert mi(Lesion_expla) & inlist(peri_major_lesion, 0, .) | peri_major_lesion==1 // No details unless major lesion
label define Lesion_expla_ ///
	1 "Spleen" ///
	2 "Kidney" ///
	3 "Biliary duct" ///
	4 "Pancreas" ///
	5 "Ventricle" ///
	6 "Intestines/colon" ///
	7 "Diaphragm" ///
	8 "Liver" ///
	9 "Both spleen and colon" ///
	10 "Both spleen and kidney" ///
	11 "Both biliary duct and chylous leakage" ///
	99 "Unspecified organ lesion" ///
	, replace
label value Lesion_expla Lesion_expla_

global Footnote_comp_perimajorlesion = ""
qui: levelsof Lesion_expla, local(levels)
foreach cat of local levels {
	local label : label Lesion_expla_ `cat'
	qui: count if Lesion_expla==`cat'
	global Footnote_comp_perimajorlesion = "${Footnote_comp_perimajorlesion} " + lower("`label' (n=`r(N)'),")
}
di "${Footnote_comp_perimajorlesion}"

* Details on other major periOP complications
global Footnote_comp_perimajorother = ""
qui: levelsof Other_expla if peri_major_other==1, local(levels)
foreach cat of local levels {
	qui: count if Other_expla=="`cat'"
	global Footnote_comp_perimajorother = "${Footnote_comp_perimajorother} " + lower("`cat' (n=`r(N)'),")
}
di "${Footnote_comp_perimajorother}"

* Details on other major postOP complications
global Footnote_comp_postmajorother = ""
qui: levelsof Otherhospi_expla if post_major_other==1, local(levels)
foreach cat of local levels {
	qui: count if Otherhospi_expla=="`cat'"
	global Footnote_comp_postmajorother = "${Footnote_comp_postmajorother} " + lower("`cat' (n=`r(N)'),")
}
di "${Footnote_comp_postmajorother}"


* Format footnotes
foreach note in Footnote_comp_perimajorlesion Footnote_comp_perimajorother Footnote_comp_postmajorother {
	global `note' = reverse(substr(reverse("${`note'}"), 2, .)) // Remove last comma
	global `note' = reverse(subinstr(reverse("${`note'}"), ",", "dna ,", 1)) // Remove last comma
	di _n "${`note'}"
}



**** Table
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
	gen cell_total = "Total_pn (%)"
	gen n_total = .
}

foreach subgrp of global subgrps {
	di "`subgrp'"
	local label : label ${colvar}_ `subgrp'
	frame table: gen cell_`subgrp' = "`label'_pn (%)"
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
			local p = string(round(100*`n'/`Ntotal_compli_`time'' ${signo_percent})
			qui: replace cell_total = "`n' (`p')" if var=="`var'"
		}
		* By colvar
		foreach col of global subgrps {
			*di "`var'- `col'"
			frame table {	
				local n = n_`col'[`rowno']
				local p = string(round(100*`n'/`N`col'_compli_`time'' ${signo_percent})
				qui: replace cell_`col' = "`n' (`p')" if var=="`var'"
			}
		}
	}
}

qui frame table: save results/TabComplications.dta, replace