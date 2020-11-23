***** 4_TextPatDetails.do *****


*** Other types of cancer (for TabPatChar footnote)
use data/Cohort_Dataset.dta, clear

keep if cancertype==4 
tab inclu_cancer
label list inclu_cancer_

** Loop over other category
global Footnote_othercancers = ""
levelsof inclu_cancer if cancertype==4 & inclu_cancer!=99
foreach cat in `r(levels)' {
    local label : label inclu_cancer_ `cat'
	qui: count if inclu_cancer==`cat'
	di "`label' (n=`r(N)')"
	global Footnote_othercancers = "${Footnote_othercancers} `label' (n=`r(N)'),"
}

di "${Footnote_othercancers}"

** Loop over comments for other subcategory
tab expla_other if inclu_cancer==99
levelsof expla_other if cancertype==4 & inclu_cancer==99
foreach cat in `r(levels)' {
    qui: count if expla_other=="`cat'"
	di "`cat' (n=`r(N)')"
	global Footnote_othercancers = "${Footnote_othercancers} `cat' (n=`r(N)'),"
}

di "${Footnote_othercancers}"

** Format footnote
global Footnote_othercancers = reverse(substr(reverse("${Footnote_othercancers}"), 2, .)) // Remove last comma
global Footnote_othercancers = reverse(subinstr(reverse("${Footnote_othercancers}"), ",", "dna ,", 1)) // Remove last comma
di "${Footnote_othercancers}"



*** Footnote on any major complications and/or death
use data/Cohort_Complications.dta, clear

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

global Footnote_complicationsdeath = "Of the `Navailable' with available data on postoperative complications, `Ndeath' died within 30 days (`Ndeath_major' patients also had other major complications while `Ndeath_nomajor' patients did not). If including the `Ndeath_nomajor' patients who died but had no other major surgical complications, `Ndeathormajor' (`Pdeathormajor'%) died and/or had any other major complication."
