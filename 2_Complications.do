***** 2_Complications.do *****
clear 
import excel data/Complications_ALE.xls, first

*** Prepare data
* Remove blancks
drop if mi(record_id)

* Remove irr vars
drop optype optime notespt hospitalization_days cause_death trans_cause transfer* hospitalization_complete surv


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
foreach var in Bleeding Conversion Lesion_of_organs Other {
	recode `var' (.=0) if inlist(compli_during, 0, 1) // 
}

* Post OP (during hospitalization)
foreach var in Infection Bleeding1 Reoperation Urinary Pulmonary Pneumonia Abdominalproblems Absces Woundtreat Woundinfection Delirium Otherhospi {
	recode `var' (.=0) if inlist(compli_after, 0, 1) // 
}

* Post OP (up to 30 days)
foreach var in Pain Hernia Otherpostop Adrenalinsufficiency  {
	recode `var' (.=0) if inlist(compli_postop, 0, 1) // 
}


*** Define major and minor complications
** PeriOP
* Organ lesions
recode Lesion_of_organs (1=1) (0 2=0) (.=.), gen(peri_minor_lesion)
label var peri_minor_lesion "Capsular lesion of kidney, spleen or liver"

recode Lesion_of_organs (2=1) (0 1=0) (.=.), gen(peri_major_lesion)
label var peri_major_lesion "Lesion of organs #"

capture: log off 
list record_id Lesion_of_organs compli_during_e1pla if Lesion_of_organs==2
capture: log on

* Tumour leak
gen peri_minor_leak = 1 if Other==1 & strpos(compli_during_e1pla, "leak")
recode peri_minor_leak (.=0) if inlist(compli_during, 0, 1)
label var peri_minor_leak "Tumour leakage"

* Bleeding
recode Bleeding (2=1) (0 1=0) (.=.), gen(peri_major_bleed)
label var peri_major_bleed "Bleeding (>500 ml)"

* Conversion
recode Conversion (2=1) (0=0) (.=.), gen(peri_major_conv)
label var peri_major_conv "Conversion from laparoscopic to open"

* Any minor/major
egen peri_anyminor = rowmax(peri_minor_*)
label var peri_anyminor "Any minor"

egen peri_anymajor = rowmax(peri_major_*)
label var peri_anymajor "Any major"


** PostOP
* Wound infection
recode Woundinfection (1=1) (0=0) (.=.), gen(post_minor_infec)
label var post_minor_infec "Wound infection"

* Urinary
recode Urinary (1=1) (0=0) (.=.), gen(post_minor_urin)
label var post_minor_urin "Urinary retension or lower UTI"

* Abdominal
recode Abdominalproblems (1=1) (0=0) (.=.), gen(post_minor_abdo)
label var post_minor_abdo "Obstipation or diarrhoea"

* Abscess 
recode Absces (1=1) (0=0) (.=.), gen(post_minor_abscess)
label var post_minor_abscess "Abscess"

* Other minor
recode Otherhospi (1=1) (0 2=0) (.=.), gen(post_minor_other)
recode post_minor_other (0=1) if Otherpostop==1
label var post_minor_other "Other §"

tab Otherhosp Otherpost, mi
// Error in code? Confirm with EV

capture: log off
list record_id  Otherh compli_postop_e1pla compli_e1pla Otherpostop compli_postop_e1pla if inlist(Otherh, 1, 2)
capture: log on

* Sepsis/pneumonia
recode Pneumonia (2=1) (0 1=0) (.=.), gen(post_major_seps)
label var post_major_seps "Sepsis or pneumonia"

* ReOP
recode Reoperation (2=1) (0 1=0) (.=.), gen(post_major_reop)
label var post_major_reop "Re-operation"

* Delirium
recode Delirium (2=1) (0 1=0) (.=.), gen(post_major_deli)
label var post_major_deli "Delirium"

* AI
gen post_major_ai = 1 if Adrenalinsufficiency==1 & inlist(compli_after, 0, 1)
recode post_major_ai (.=0) if inlist(Adrenalinsufficiency, 0, .) & inlist(compli_after, 0, 1) // fix error in redcap database logic
label var post_major_ai "Adrenal insufficiency"

// Error in code? Confirm with EV. 7 patients with AI less than anticipated


* Other major
recode Otherhospi (2=1) (0 1=0) (.=.), gen(post_major_other)
recode post_major_other (0=1) if Otherpostop==2
label var post_major_other "Other ~"

// Error in code? Confirm with EV

* Any minor/major
egen post_anyminor = rowmax(post_minor_*)
label var post_anyminor "Any minor"

egen post_anymajor = rowmax(post_major_*) // Excluding death which had full follow-up
label var post_anymajor "Any major (excl. death) ¤"


** Death
gen compli_death = 1 // Vital status was available for all patients
label var compli_death "30-day mortality available"

gen death = 1 if surv<(30/365.25) & alive==0 
recode death (.=0) // complete follow-up
label var death "Death within 30 days"



*** Save
label var compli_during "Peri-operative complications available"
label var compli_after "Post-operative complications available"

rename compli_during compli_peri
rename compli_after compli_post

keep record_id surgcat surgcat_simple Npatients compli_peri compli_post compli_postop compli_death peri_* post_* death
save data/Cohort_Complications.dta, replace