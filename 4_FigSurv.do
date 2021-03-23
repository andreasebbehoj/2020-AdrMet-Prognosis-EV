***** 4_FigSurv.do *****
use data/Cohort_Dataset.dta, clear


*** Set data
stset surv, failure(alive==0) scale(365.25)

*** Graphs
local ylab = `"0 "0%" 0.25 "25%" 0.50 "50%" 0.75 "75%" 1.00 "100%""'
local xtitle = `""Years from surgery""'
local ytitle = `""Survival""'
local risklayout = `", title("At risk", at(0))"' 

* Overall 
sts graph, ci ///
	risktable(0/10 `risklayout') ///
	tmax(10) ///
	title("All cancers", ring(0)) xtitle(`xtitle') ytitle(`ytitle') ///
	ylabel(`ylab') ///
	legend(off) ///
	name(grp_0, replace) ///
	$km0 // color settings
graph export results/FigSurvOverall${exportformat} ${exportoptions}


* By cancer type (separate)
local graphs = ""
levelsof cancertype
foreach subgrp in `r(levels)' {
    local lbl : label cancertype_ `subgrp'
	di "`lbl'"
	sts graph if cancertype==`subgrp', ci ///
		title("`lbl'", ring(0)) xtitle("") ytitle("") ///
		ylabel(`ylab') ///
		legend(off) ///
		risktable(0/5 `risklayout') ///
		tmax(5) ///
		name(grp_`subgrp', replace) ///
		${km`subgrp'}  // color settings
	graph export results/FigSurvCancer`subgrp'${exportformat} ${exportoptions}
	local graphs = "`graphs' grp_`subgrp'"
}
graph combine `graphs', ///
		xsize(1200pt) ysize(960pt) scale(0.7) ///
		l1title(`ytitle') b1title(`xtitle') ///
		name(grp_suball, replace) // 
graph export results/FigSurvCancerSubRt${exportformat} ${exportoptions}

graph combine grp_0 grp_suball, ///
		col(1) ///
		xsize(1200pt) ysize(1200pt) //
graph export results/FigSurvCancerAll${exportformat} ${exportoptions}

* By cancer origin - separate
sts graph, ci by(cancertype) separate ///
	 /// risktable(0/5 `risklayout') // Risk tables and by(grp) not allowed together
	tmax(5) ///
	title("") note("") caption("") ///
	xtitle(`xtitle')  xlabel(0(1)5) ///
	legend(off) ///
	ytitle(`ytitle') ylabel(`ylab') ///
	$km1 // color settings
graph export results/FigSurvCancerSubNoRt${exportformat} ${exportoptions}