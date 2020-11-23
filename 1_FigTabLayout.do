***** 4_FigTabLayout.do *****

***** Graphs
** General
set scheme s2color
grstyle init graphlayout, replace
grstyle set plain // No plot region color, white background + other tweaks

** Size
grstyle set graphsize 560pt 1200pt // in pixels, default is 5.5 inches *72 pt/inch = 396pt
grstyle set symbolsize vlarge
grstyle set size 25pt: axis_title // X and Y axis text size

** Axis
grstyle anglestyle vertical_tick horizontal // Horizontal "tick"text on y-axis
grstyle color major_grid gs11 // colour of horizontal lines

** Legend
grstyle set legend ///
	2, /// clock position of legend (1-12).
	nobox /// no legend background
	inside // inside plotregion

** KM plots
global km0 = `"plotopt(color(gs6)) ciopt(recast(rarea) fcolor(gs6%50) lcolor(%0))"'
global km1 = `"plotopt(color(gs6)) ciopt(recast(rarea) fcolor(gs6%50) lcolor(%0))"'
global km2 = `"plotopt(color(gs6)) ciopt(recast(rarea) fcolor(gs6%50) lcolor(%0))"'
global km3 = `"plotopt(color(gs6)) ciopt(recast(rarea) fcolor(gs6%50) lcolor(%0))"'
global km4 = `"plotopt(color(gs6)) ciopt(recast(rarea) fcolor(gs6%50) lcolor(%0))"'

** Line graphs (size, colors and patterns)
grstyle set linewidth 3pt: p // line width (line and rcap)

global line1 = `"lpattern(solid) lcolor(black)"'
global line2 = `"lpattern(vshortdash) lcolor(black)"'
global line3 = `"lpattern("_") lcolor(black)"'
global line4 = `"lpattern("-") lcolor(black)"'

** Bar graphs (colors and outline pattern)
* Graphs with 1-2 colors
global bar1 = `"fcolor(gs6) lcolor(gs6)"'
global bar2 = `"fcolor(gs12) lcolor(gs12)"'

* Graphs with 3 colors
global bar3_1 = `"fcolor(gs6) lcolor(gs6)"'
global bar3_2 = `"fcolor(gs12) lcolor(gs12)"'
global bar3_3 = `" fcolor(white) lcolor(black) lalign(inside)"'

* Graphs with 4 colors
colorpalette HCL grays, n(4) nograph local(, prefix(c))
global bar4_1 = `" fcolor(`c1') lcolor(`c1') lalign(inside)"'
global bar4_2 = `" fcolor(`c2') lcolor(`c2') lalign(inside)"'
global bar4_3 = `" fcolor(`c3') lcolor(`c3') lalign(inside)"'
global bar4_4 = `" fcolor(white) lcolor(black) lalign(inside)"'

* Graphs with 5 colors
colorpalette HCL grays, n(5) nograph local(, prefix(c))
global bar5_1 = `" color(`c1') lcolor(`c1') lalign(inside)"'
global bar5_2 = `" color(`c2') lcolor(`c2') lalign(inside)"'
global bar5_3 = `" color(`c3') lcolor(`c3') lalign(inside)"'
global bar5_4 = `" color(`c4') lcolor(`c4') lalign(inside)"'
global bar5_5 = `" color(white) lcolor(black) lpattern(solid) lalign(inside)"'

* Graphs with 8 colors
colorpalette HCL grays, n(8) nograph local(, prefix(c))
global bar8_1 = `" fcolor(`c1') lcolor(`c1')"' // lpattern("vshortdash") lwidth(1) lalign(inside)"'
global bar8_2 = `" fcolor(`c3') lcolor(`c3')"'
global bar8_3 = `" fcolor(`c5') lcolor(`c5')"'
global bar8_4 = `" fcolor(`c7') lcolor(`c7')"' // lalign(inside) lwidth(0.4) lpattern(dot)"'
global bar8_5 = `" fcolor(`c2') lcolor(`c2')"'
global bar8_6 = `" fcolor(`c4') lcolor(`c4')"' // lalign(inside) lwidth(0.2) lpattern("-")"'
global bar8_7 = `" fcolor(`c6') lcolor(`c6')"'
global bar8_8 = `" fcolor(white) lcolor(black) lpattern(solid) lalign(inside)"'


** Export
graph set eps logo off
global exportformat = ".png"
global exportoptions = ", replace width(1200)"


***** Tables
global tablecells =  `"border(all, nil) halign(center) valign(center)"'
global tablefirstrow = `"border(bottom, single) bold shading(191 191 191)"' // First row bold, underlined and dark gray
global tabletotalrow = `"border(bottom, single, black, 1) border(top, single, black, 1) "' // Bottom total row, black lines top and bottom
global tablerows = `"shading(217 217 217)"' // Remaining subheaders light grey
global tablefirstcol = `"halign(left)"'

*** Significant numbers
// "string(round(X, 0.001), "%4.3f")"
global signo_percent = `", 1), "%4.0f" "' // Percent 
global signo_median = `", 1), "%4.0f" "' // Median, IQR and range
global signo_mean = `", 0.1), "%4.1f" "' // Mean and SD
global signo_cox = `", 0.01), "%4.2f" "' // Cox regression
global signo_medsurv = `", 0.1), "%4.1f" "' // Median survival
global signo_surv1 = `", 1), "%4.0f" "' // 1-year survival
global signo_pval = `", 0.001), "%4.3f" "' // P-values