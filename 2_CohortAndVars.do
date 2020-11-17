***** 3_CohortAndVars.do *****
use data/Redcap.dta, clear


*** Define cohort 
* Study period
global firstyear = 2000
global lastyear = 2018


** Report of Patient flow
putdocx clear
putdocx begin
putdocx paragraph, style(Heading2)
putdocx text ("Patient flow")

* Potentially eligible
putdocx paragraph
count
putdocx text (`"Patients registered with pathology code "T93*" and "M****6" from $firstyear to $lastyear (n=`r(N)')"')

putdocx paragraph, indent(left, 2cm)

count if exclu_diag!=0
putdocx text ("`r(N)' excluded due to:"), linebreak

count if exclu_diag==66
putdocx text ("Wrong pathology code (n=`r(N)')"), linebreak

count if inlist(exclu_diag, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 44, 88)
putdocx text ("No metastasis in adrenal gland (n=`r(N)')"), linebreak

count if inlist(exclu_diag, 55, 77)
putdocx text ("Inconclusive pathological examination (n=`r(N)')"), linebreak

keep if exclu_diag==0 

* Histologically verified mets
putdocx paragraph
count
putdocx text ("Patient with histologically verified adrenal metastases (n=`r(N)')"), linebreak

putdocx paragraph, indent(left, 2cm)
count if inlist(adrmet_disc, 1, 2) 
putdocx text ("`r(N)' excluded due to:"), linebreak

count if adrmet_disc==1
putdocx text ("Adrenal biopsy only (n=`r(N)')"), linebreak

count if adrmet_disc==2
putdocx text ("Autopsy only (n=`r(N)')"), linebreak

drop if inlist(adrmet_disc, 1, 2) 

* Adrenalectomy
putdocx paragraph
count
putdocx text ("Patient with adrenal metastases undergoing adrenalectomy (n=`r(N)')"), linebreak

putdocx paragraph, indent(left, 2cm)
count if curative==1 // debulking
putdocx text ("`r(N)' excluded due to planned partial adrenal metastasectomy (i.e. debulking)."), linebreak
drop if curative==1 // debulking 

* Study cohort
putdocx paragraph
count
global Ncohort = `r(N)'
putdocx text ("Patients included in study (n=$Ncohort)"), linebreak
putdocx save results/TextPatientFlow, replace



*** Define study variables

** Patient characteristics
* Index date and year
label var dateop "Date of surgery"
gen year_op = year(dateop)
label var year_op "Year of surgery"

* Sex
gen sex=gender
label var sex "Sex"
label copy gender_ sex_
label value sex sex_
drop gender

* Age at diagnosis
drop opage
gen age = (dateop-d_foddato)/365.25
label var age "Age at surgery"

* Age categories
recode age ///
	(0/59.999=1 "<60 years") ///
	(60/70=2 "60-70 years") ///
	(70.001/100=3 ">70 years") ///
	, gen(agecat) label(agecat_)
label var agecat "Age at surgery"

* BMI
label var bmi "BMI in kg/m2"

* CCI
label var cci "CCI"
replace cci=cci-1 if inrange(age, 50, 59.999) // remove age from cci
replace cci=cci-2 if inrange(age, 60, 69.999)
replace cci=cci-3 if inrange(age, 70, 79.999)
replace cci=cci-4 if inrange(age, 80, 100)

* Surgical delay
gen delay = dateop-adrenal_enlarge // Time from discovery of adrenal enlargement to OP
label var delay "Doctor's delay in days"


** Tumor characteristics
* Cancer origin
drop cancertype_2 
recode inclu_cancer ///
	(2 = 1 "Renal cancer") ///
	(1 = 2 "Lung cancer") ///
	(5 = 3 "Colorectal cancer") ///
	(3 4 6/99 = 4 "Other cancer") ///
	, gen(cancertype) label(cancertype_)
label var cancertype "Cancer origin"

* Tumor size
replace patosize = patosize * 10 // change from cm to mm
recode patosize ///
	(0/19.999=1 "<20 mm") ///
	(20/39.999=2 "20-39 mm") ///
	(40/59.999=3 "40-59 mm") ///
	(60/79.999=4 "60-79 mm") ///
	(80/1000=5 "≥80 mm") ///
	(.=.a "Missing records") ///
	, gen(sizecat) label(sizecat_)
label var patosize "Size in mm"
label var sizecat "Tumour size"

* Tumor laterality
label var loca_adrmet "Location of metastasis"

* Mode of discovery
label var synvsmeta "Mode of discovery"

* Extra adrenal mets
label var other_metastasis "Extra-adrenal metastases at time of surgery"


** Surgical variables
* Surgical approach
recode optype ///
	(1 2 =1 "Laparoscopic") ///
	(3=2 "Conversion to open") ///
	(4/7=3 "Open") ///
	, gen(surgcat) label(surgcat_)
label var surgcat "Surgical approach"

recode optype ///
	(1/3=1 "Laparoscopic") ///
	(4/7=2 "Open") ///
	, gen(surgcat_simple) label(surgcat_simple_)
label var surgcat "Surgical approach"
drop optype

* Surgical extent
recode removal ///
	(0=1 "Only adrenalectomized") ///
	(1=2 "Extended surgery") ///
	, gen(surgextent) label(surgextent_)
label var surgextent "Surgical extent"

* Duration of surgery
label var optime "Duration of surgery in min"

* Radicality of procedure
gen radical = .
recode radical (.=1) if radi_primary==1 & radi_pato==1 // R0
recode radical (.=2) if radi_primary==1 & radi_pato==99 // R1 uncertain micro but free macro
recode radical (.=3) if radi_primary==0 | radi_pato==0 // R2 not free resection (micro or macro)
label define radical_ ///
	1 "R0-resection" ///
	2 "R1-resection" ///
	3 "R2-resection" ///
	, replace
label values radical radical_
label var radical "Radicality of procedure"
drop radi_pato radi_primary
/* Is this correct? Check with EV*/



*** Define survival outcome
* Overall survival
gen surv = d_dod-dateop // Patients who died
replace surv = date("23jul2019", "DMY")-dateop if alive==1 // End of FU
replace surv = surv/365.25 // in years
drop days_alive* follow_up 
order dateop alive d_dod surv, after(adrenalectomy)


*** Save data
save data/Cohort_FullData.dta, replace

** Without irrelevant data
drop adrenalectomy exclu_diag adrmet_disc exclu_diag_other doubt /// exclusion criteria
	comment_diag expla_doubt ophospital expla_hospital onco_dep expla_onco registry_screening_enrollment_co /// vars for finding records 
	registry_screening_enrollment_co *_complete /// redcap var
	height weight // vars used for calculations above

save data/Cohort_Dataset.dta, replace