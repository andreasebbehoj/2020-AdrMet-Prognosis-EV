***** 4_TabCancerTypes.do *****

*** Prepare data
use data/Cohort_Dataset.dta, clear

tab cancertype, mi

* Recode missing/unspecied
label list immunocancer_2_
recode immunocancer_2 (99 = 98) 
recode immunocancer_2 (. = 99) 

label define immunocancer_2_ ///
	0 "Total" ///
	98 "Unknown subtype" ///
	99 "Missing records" ///
	, modify
	

*** Calculations 
* Count N
contract cancertype immunocancer_2, freq(N) 

* Calculate percent
bysort cancertype: egen Ntotal = total(N)
gen perc = 100*N/Ntotal
drop Ntotal

* Calculate total N by grp
levelsof cancertype, local(grps)
foreach grp of local grps {
	local label`grp' : label cancertype_ `grp'
	qui: su N if cancertype==`grp'
	local total = `r(sum)'
	di "`label`grp'' (n=`total')"
	
	* Add total value
	newrow
	qui: replace immunocancer_2 = 0 if _n==_N
	qui: replace cancertype = `grp' if _n==_N
	qui: replace N = `total' if _n==_N
}

*** Prepare data for table
* Format to strings
decode immunocancer_2, gen(rowname)

gen text = string(N) /// N
			+ " (" ///
			+ string(round(perc ${signo_percent}) ///
			+ ")"
qui: replace text = subinstr(text , " (.)", "", 1)

* Sort data
gsort +cancertype -N +immunocancer_2
by cancertype: gen sort = _n

* Reshape data
drop N perc immunocancer_2

reshape wide rowname text , i(sort) j(cancertype)

* Add col headers
newrow
recode sort (.=0)
foreach grp of local grps {
	local n = text`grp'[1]
	* Group header
	qui: replace rowname`grp' = "`label`grp''_p(n=`n')" if sort==0
	* Sub headers
	qui: replace rowname`grp' = "Subtypes" if sort==1
	qui: replace text`grp' = "n (%)" if sort==1
	
}
sort sort

*** Export
save results/TabCancerTypes.dta, replace