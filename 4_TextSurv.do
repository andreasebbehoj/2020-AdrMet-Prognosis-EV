***** 4_TextSurv.do *****
use data/Cohort_Dataset.dta, clear


*** Set data
stset surv, failure(alive==0) scale(365.25)


*** Descriptive data
putdocx clear
putdocx begin
putdocx paragraph, style(Heading2)
putdocx text ("Overall Survival Data")

putdocx paragraph

* N, failures + follow-up time mean, total, median and range
stdescribe
local nfail = `r(N_fail)'
local ntotal = `r(N_total)'
local pfail = string(round(`r(f_mean)'*100 ${signo_percent})
local futotal = string(round(`r(tr)', 0.1), "%4.1f")

* Follow-up IQR
gen surv_mn = surv/(30.4) // in months
su surv_mn, detail
local futotalinmonths = string(round(`r(sum)', 0.1), "%4.1f")
local fumean = string(round(`r(mean)', 0.1), "%4.1f")
local fumedian = string(round(`r(p50)', 0.1), "%4.1f")
local fumin = string(round(`r(min)', 0.1), "%4.1f")
local fumax = string(round(`r(max)', 0.1), "%4.1f")

local fup25 = string(round(`r(p25)', 0.1), "%4.1f")
local fup75 = string(round(`r(p75)', 0.1), "%4.1f")


putdocx text (`"At end of study, `nfail' (`pfail' %) of `ntotal' patients had died. Total follow-up time was `futotal' years (`futotalinmonths' months). Mean follow-up per subject was `fumean' months, median `fumedian' (IQR `fup25'-`fup75', range `fumin'-`fumax')."'), linebreak


*** Survival by 30 days and X years
* Calculate
tempfile surv
local d30 = 30/365.25
sts list, at(0 `d30' 1 5 10) saving(`surv', replace)
use `surv', clear

* Format
foreach var in survivor lb ub {
    gen string = string(round(`var'*100 ${signo_surv1}) // in %
	drop `var'
	rename string `var'
}
qui: gen survival = survivor + " (" + lb + "-" + ub + ")" if _n!=1
qui: replace survival = "100" if _n==1
keep time begin fail survival

* Export table
putdocx paragraph
putdocx text ("1-month, 1-year 5-year and 10-year survival:")
putdocx table tbl1 = data("time begin fail survival"), varnames width(100%) layout(autofitcontents)
putdocx table tbl1(., .), ${tablecells} 
putdocx table tbl1(., 1), ${tablefirstcol}
putdocx table tbl1(1, .), ${tablefirstrow}


*** Save report
putdocx save results/TextSurv, replace