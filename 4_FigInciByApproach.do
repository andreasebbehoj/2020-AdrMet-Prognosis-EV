***** 4_FigInciByApproach.do *****

*** Prepare data
use data/Cohort_Dataset.dta, clear

* Change missing to nonmiss category
conv_missing, var(surgcat_simple) combmiss("Missing") 

* Count N
keep period surgcat_simple
contract _all, freq(N) zero


*** Graph
** Reverse legend order
local legend = ""
qui: su surgcat
forvalues x = `r(max)'(-1)`r(min)' {
    local legend = "`legend' `x'"
}
di "`legend'"

** Bar appearance
local bar = ""
qui: su surgcat
forvalues x = `r(min)'(1)`r(max)' {
    local barlayout = `"`barlayout' bar(`x', ${bar`r(max)'_`x'})"'
}
di `"`barlayout'"'

** Graph 
graph bar (first) N, over(surgcat) over(period) ///
	asyvars stack ///
	legend(order(`legend') pos(11)) /// reverse legend order
	`barlayout' ///
	ytitle("N") ///
	ymtick(0(10)200) //ylabel(0/5)
graph export results/FigInciByApproach${exportformat} ${exportoptions}