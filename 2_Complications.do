***** 2_Complications.do *****
clear 
import excel data/Complications_ALE_EHV.xlsx, first

*** Prepare data
* Remove blancks
drop if mi(record_id)

* Remove irr vars
drop notespt cause_death trans_cause transfer* 


** Format strings
* Define missing var
foreach time in during after postop {
	qui: replace compli_`time' = "1" if strpos(lower(compli_`time'), "yes")
	qui: replace compli_`time' = "0" if strpos(lower(compli_`time'), "no")
	qui: replace compli_`time' = ".a" if strpos(lower(compli_`time'), "missing")
}


* Destring
ds, has(type string)
foreach var in `r(varlist)' {
	qui: replace `var' = subinstr(`var', "-", "", 1)
	qui: replace `var' = trim(`var')
	qui: destring `var', replace
}


** Merge with cohort
tempfile comp
save `comp', replace

use data/Cohort_Dataset.dta, clear
keep record_id alive surv surgcat surgcat_simple
merge 1:1 record using `comp'

drop if _merge==2 // Not in final study cohort
drop _merge


** No with data
* Exclude missing
drop if surgcat==.a

* N patients
gen Npatients = 1
label var Npatients "No. of patients"

** Recode non-missing complications 
* During OP
foreach var in Bleeding Conversion Lesion_of_organs Tumour_Leakage Other {
	qui: recode `var' (.=0) if inlist(compli_during, 0, 1) // 
}

* Post OP (during hospitalization or up to 30days after surgery)
gen compli_post = 1 if inlist(1, compli_after, compli_postop)
recode compli_post (.=0) if inlist(0, compli_after, compli_postop)
drop compli_after compli_postop

foreach var in Infection Bleeding1 Reoperation Urinary Pulmonary Pneumonia Abdominalproblems Absces Woundtreat Woundinfection Delirium Otherhospi Pain Hernia Otherpostop Adrenalinsufficiency {
	qui: recode `var' (.=0) if inlist(compli_post, 0, 1)
}


*** Define major and minor complications
** PeriOP
* Organ lesions
assert inlist(Lesion_of_organs, 0, 1, 2, .)
recode Lesion_of_organs (1=1) (0 2=0) (.=.), gen(peri_minor_lesion)
label var peri_minor_lesion "Superficial lesion of kidney, spleen, liver, or diaphragm"

recode Lesion_of_organs (2=1) (0 1=0) (.=.), gen(peri_major_lesion)
label var peri_major_lesion "Lesion of organs" 

* Tumour leak
assert inlist(Tumour_Leakage, 0, 1, .)
recode Tumour_Leakage (1=1) (0=0) (.=.), gen(peri_minor_leak)
label var peri_minor_leak "Tumour leakage"

* Bleeding
assert inlist(Bleeding, 0, 1, 2, .)
recode Bleeding (2=1) (0 1=0) (.=.), gen(peri_major_bleed)
label var peri_major_bleed "Bleeding (>500 ml)"

* Conversion
assert inlist(Conversion, 0, 2, .)
recode Conversion (2=1) (0=0) (.=.), gen(peri_major_conv)
label var peri_major_conv "Conversion from laparoscopic to open surgery"

* Other major
assert inlist(Other, 0, 2, .)
recode Other (2=1) (0=0) (.=.), gen(peri_major_other)
label var peri_major_other "Other" // Details in Other_expla

* Any minor/major
egen peri_anyminor = rowmax(peri_minor_*)
label var peri_anyminor "Any minor"

egen peri_anymajor = rowmax(peri_major_*)
label var peri_anymajor "Any major"

** PostOP
* Wound infection
assert inlist(Woundinfection, 0, 1, .)
recode Woundinfection (1=1) (0=0) (.=.), gen(post_minor_infec)
label var post_minor_infec "Wound infection"

* Urinary
assert inlist(Urinary, 0, 1, .)
recode Urinary (1=1) (0=0) (.=.), gen(post_minor_urin)
label var post_minor_urin "Urinary retention or lower UTI"

* Abdominal
assert inlist(Abdominalproblems, 0, 1, .)
recode Abdominalproblems (1=1) (0=0) (.=.), gen(post_minor_abdo)
label var post_minor_abdo "Obstipation or diarrhoea"

* Pulmonary
assert inlist(Pulmonary, 0, 1, .)
recode Pulmonary (1=1) (0=0) (.=.), gen(post_minor_pulm)
label var post_minor_pulm "Lung oedema, pleura exudate, or atelectasis"

* Abscess 
assert inlist(Absces, 0, 1, .)
recode Absces (1=1) (0=0) (.=.), gen(post_minor_abscess)
label var post_minor_abscess "Abdominal abscess"


* Sepsis/pneumonia
assert inlist(Pneumonia, 0, 2, .)
recode Pneumonia (2=1) (0 1=0) (.=.), gen(post_major_seps)
recode post_major_seps (0=1) if Infection==2 // Urosepsis
label var post_major_seps "Sepsis or pneumonia"

* ReOP
assert inlist(Reoperation, 0, 2, .)
recode Reoperation (2=1) (0 1=0) (.=.), gen(post_major_reop)
label var post_major_reop "Re-operation"

* Delirium
assert inlist(Delirium, 0, 2, .)
recode Delirium (2=1) (0 1=0) (.=.), gen(post_major_deli)
label var post_major_deli "Delirium"

* AI
assert inlist(Adrenalinsufficiency, 0, 2, .)
recode Adrenalinsufficiency (2=1) (0=0) (.=.), gen(post_major_ai)
label var post_major_ai "Adrenal insufficiency"

* Other major
assert inlist(Otherhospi, 0, 1, 2, .)
recode Otherhospi (2=1) (0 1=0) (.=.), gen(post_major_other)
label var post_major_other "Other"


* Any minor/major
egen post_anyminor = rowmax(post_minor_*)
label var post_anyminor "Any minor"

egen post_anymajor = rowmax(post_major_*) // Excluding death which had full follow-up
label var post_anymajor "Any major (excl. death)"


** Death
gen compli_death = 1 // Vital status was available for all patients
label var compli_death "30-day mortality available"

gen death = 1 if surv<30 & alive==0 
recode death (.=0) // complete follow-up
label var death "Death within 30 days"


*** Rename and label
label var compli_during "Perioperative complications available"
label var compli_post "Postoperative complications available"
rename compli_during compli_peri


*** Check complications
qui: ds peri_* post_*
foreach var in `r(varlist)' {
	assert inlist(`var', 0, 1, .)
}


*** Save
keep record_id surgcat surgcat_simple Npatients ///
	compli_peri Lesion_expla Other_expla peri_* ///
	compli_post Otherhospi_expla post_* ///
	compli_death death 
save data/Cohort_Complications.dta, replace