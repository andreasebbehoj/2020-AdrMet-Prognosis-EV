***** 3_CohortAndVars.do *****
use data/Redcap.dta, clear


*** Define cohort
** Define important criteria
* End of study period
global firstyear = 1995
global lastyear = 2015


* Age categories
global agecat = `"(0/59.999=1 "<60 years")"' ///
				+ `" (60/70=2 "60-70 years")"' ///
				+ `" (70.001/100=3 "{&ge}70 years")"'



** Index date and year
gen date_index = xxxxxx
label var date_index "Index date"
format %d date_index

gen year_index = year(date_index)
label var year_index "Index year"


** Patient flow 
putdocx clear
putdocx begin
putdocx paragraph, style(Heading2)
putdocx text ("Patient flow")


* Potentially eligible
count

putdocx paragraph
putdocx text ("Patients registered with diagnosis codes $firstyear-$lastyear (n=`r(N)')")

putdocx paragraph, indent(left, 2cm)
count if inlist(exclude, 1, 2)
putdocx text ("`r(N)' excluded or refuted due to:"), newline
count if exclude==1
putdocx text ("Wrong diagnosis code (n=`r(N)')"), newline
count if exclude==2
putdocx text ("Refuted X disease (n=`r(N)')"), newline

drop if inlist(exclude, 1, 2)

* etc

* Study cohort
count
global Ncohort = `r(N)'

putdocx text ("Patients included in study (n=$Ncohort)"), linebreak
putdocx save results/TextPatientFlow, replace




*** Define study variables

** Patient characteristics
* Sex

* Age at diagnosis
gen age = (date_index-d_foddato)/365.25
label var age "Age in years"

* Age categories
recode age $agecat, gen(agecat) label(agecat_)
label var agecat "Age at diagnosis"



** Tumor characteristics
* Tumor size
egen sizemax = rowmax(tumo_size*)
recode sizemax ///
	(0/19.999=1 "<20 mm") ///
	(20/39.999=2 "20-39 mm") ///
	(40/59.999=3 "40-59 mm") ///
	(60/79.999=4 "60-79 mm") ///
	(80/1000=5 "{&ge}80 mm") ///
	(.=.a "Missing records") ///
	, gen(sizecat) label(sizecat_)
label var sizemax "Size in cm"
label var sizecat "Tumor size"



** Other variables



** Re