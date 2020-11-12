***** 4_FigSurv.do *****
use data/Cohort_Dataset.dta, clear


*** Set data
stset surv, failure(alive==0)

*** Graph
sts graph, ci ///
	risktable(0/15) ///
	title("") xtitle("Years from surgery") ytitle("Survival in %") ///
	legend(off) ///
	plotopt(color(gs6)) ciopt(fcolor(gs6%50) lcolor(gs6%30)) 
