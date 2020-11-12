***** 3_ImportPopDK.do *****
*** Total population by year
dstpop, clear ///
	year(1977/$lastyear) /// 
	area(total)

save data/popDK_year.dta, replace