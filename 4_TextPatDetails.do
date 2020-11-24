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