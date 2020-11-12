***** 3_ImportPopDK.do *****
*** Total population by year
dstpop, clear ///
	year($firstyear/$lastyear) /// 
	area(total)

save data/popDK_year.dta, replace

*** Save Pop size in report
putdocx clear
putdocx begin
putdocx paragraph, style(Heading2)
putdocx text ("Population size")
putdocx paragraph


local popfirst = pop[1]
local poplast = pop[_N]
su pop
local popaverage= round(`r(mean)')

putdocx text ("Danish population was `popfirst' in $firstyear and `poplast' in $lastyear. Average population $firstyear to $lastyear was `popaverage'"), linebreak
putdocx save results/TextPopsize, replace
