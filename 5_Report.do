***** 4_Report.do *****
clear
putdocx clear
file close _all

*** Setup document
putdocx begin, ///
	pagenum(decimal) ///
	footer(pfooter) ///
	pagesize(A4) ///
	margin(left, 0.5in) ///
	margin(right, 0.5in) ///
	font("Times new roman", 11, black)
putdocx paragraph, tofooter(pfooter)
putdocx text ("Page ")
putdocx pagenumber, bold
putdocx text (" of ")
putdocx pagenumber, totalpages bold

* Settings for headings
local fontHeading1 = `"font("Times new roman", 15, black)"'
local fontHeading2 = `"font("Times new roman", 13, black)"'



*** Figures
local figno = 0

putdocx paragraph, style(Heading1) `fontHeading1'
putdocx text ("Figures and Tables")

** Fig patientflow (text only, fig copy/paste)
local figno = `figno'+1
putdocx paragraph, style(Heading2) `fontHeading2'
putdocx text ("Figure `figno' - Flowchart")
putdocx paragraph, halign(center)
putdocx text ("Copy/paste")
putdocx paragraph


** Fig Inci during study period
local figno = `figno'+1
putdocx paragraph, style(Heading2) `fontHeading2'
putdocx text ("Figure `figno' - Adrenal Metastasectomy in Denmark, $firstyear-$lastyear")
putdocx paragraph, halign(center)
putdocx image results/FigInciByApproach${exportformat}, height(5 in)
putdocx paragraph

putdocx text ("Notes:"), bold
putdocx text  (" Frequency of adrenal metastasectomy in Denmark from $firstyear to $lastyear. Bars are coloured after the surgical approach. Note that the first column to the left only includes four years, while the remaining columns include five years. Laparoscopic surgery includes patients who were converted to open surgery perioperatively.")


** Fig Surv Overall
putdocx pagebreak
local figno = `figno'+1
putdocx paragraph, style(Heading2) `fontHeading2'
putdocx text ("Figure `figno' - Survival after Adrenal Metastasectomy A) Overall and B) by Primary Cancer")
putdocx paragraph, halign(center)
putdocx text ("A")
putdocx image results/FigSurvOverall${exportformat}, height(2.8 in)
putdocx paragraph, halign(center)
putdocx text ("B")
putdocx image results/FigSurvCancerSubRt${exportformat}, height(5 in)
putdocx paragraph
putdocx text ("Notes:"), bold
putdocx text  (" Kaplan-Meier curve showing survival after adrenal metastasectomy A) for all patients combined and B) by primary cancer. The faded area represents the 95% confidence interval. Patients at risk are shown below graphs. ")



*** Tables
local tabno = 0


** Tab - PatChar
local tabno = `tabno'+1
putdocx pagebreak
putdocx paragraph, style(Heading2) `fontHeading2'
putdocx text ("Table `tabno' - Patient and Tumour Characteristics and Surgical Management by Primary Cancer")

* Add and format data
use results/TabCharByCancer.dta, clear
ds cell_*
putdocx table tbl1 = data("rowname `r(varlist)'"), width(100%) layout(autofitcontents)
putdocx table tbl1(., .), ${tablecells} 
putdocx table tbl1(., 1), ${tablefirstcol}
putdocx table tbl1(1, .), ${tablefirstrow}
levelsof row if !mi(firstcol) & mi(seccol)
putdocx table tbl1(`r(levels)', .), ${tablerows}
putdocx paragraph
putdocx text ("Abbreviations and symbols:"), bold
putdocx text  (" BMI, body mass index; CCI, Charlson Comorbidity Index; IQR inter-quartile range; OP, operation; SD, standard deviation. ")
putdocx text ("Notes:"), bold
putdocx text  (`" For variables, where data could not be found for all 439 patients, the number of patients with available information is specified in brackets (e.g. [n=x]). Details on histopathological subtypes of renal, lung, and colorectal cancer are available in Supplementary 1. * Other types of cancers originated from ${Footnote_othercancers}. # Doctor’s delay is defined as the time from discovery of adrenal metastasis until surgery."')
// Confirm (n=x) numbers with EV


** Tab - Complications
local tabno = `tabno'+1
putdocx pagebreak
putdocx paragraph, style(Heading2) `fontHeading2'
putdocx text ("Table `tabno' - Minor and Major Surgical Complications by Surgical Approach")

* Add and format data
use results/TabComplications.dta, clear
levelsof row if mi(rowheader), sep(",")
replace rowname = "   " + rowname if inlist(row, `r(levels)')
replace cell_1 = subinstr(cell_1, "scopic", "scopic *", 1) if row==1 // Add * to laparoscopic
ds cell_*
putdocx table tbl1 = data("rowname `r(varlist)'"), width(100%) layout(autofitcontents)
putdocx table tbl1(., .), ${tablecells} 
putdocx table tbl1(., 1), ${tablefirstcol}
putdocx table tbl1(1, .), ${tablefirstrow}
levelsof row if rowheader==1
putdocx table tbl1(`r(levels)', .), ${tablerows}

putdocx paragraph
putdocx text ("Abbreviations and symbols:"), bold
putdocx text  (" UTI, urinary tract infection * Including patients converted from laparoscopic to open surgery. # Organ lesions included lesion of spleen (n=7), kidney (n=5), biliary ducts (n=4), pancreas (n=3), ventricle (n=1), and unspecified organ lesion (n=4). § Other minor complications includes X, Y, and Z other examples. ~ Other major complications includes X, Y, and Z other examples. ¤ $Footnote_complicationsdeath")
putdocx text ("Notes:"), bold
putdocx text  (`" Complications were classified in major and minor complications, based on severity, and as perioperative complications (during surgery) and post-operative complications (up to 30 days after surgery). Minor postoperative complications were only recorded if there was a need for intervention (e.g. obstipation requiring laxatives). Patients can be counted in more than category. Death within 30 days of surgery was considered a surgical complication, while death more than 30 days after surgery was not."')


** Tab - Prognostic overall
local tabno = `tabno'+1
putdocx pagebreak
putdocx paragraph, style(Heading2) `fontHeading2'
putdocx text ("Table `tabno' - Overall Prognostic Factors")

* Add and format data
use results/TabProgOverall.dta, clear
putdocx table tbl1 = data("rowname n hr_crude hr_adjust median surv1"), width(100%) layout(autofitcontents)
putdocx table tbl1(., .), ${tablecells} 
putdocx table tbl1(., 1), ${tablefirstcol}
putdocx table tbl1(1, .), ${tablefirstrow}
putdocx paragraph
putdocx text ("Abbreviations and symbols:"), bold
putdocx text  (" BMI, body mass index; CCI, Charlson Comorbidity Index; HRR, hazard rate ratio. *Adjusted for age, sex, and CCI. ")
putdocx text ("Notes:"), bold
putdocx text  (`" Cox proportional regression analysis for overall survival after adrenal metastasectomy."')


** Tab - Crude HRR for each cancer
local tabno = `tabno'+1
putdocx pagebreak
putdocx paragraph, style(Heading2) `fontHeading2'
putdocx text ("Table `tabno' - Prognostic Factors by Primary Cancer")

* Add and format data
use results/TabProgByCancer_Combined.dta, clear

local varlist = "hr_crude1 hr_crude2 hr_crude3 hr_crude4"
foreach var of local varlist {
	qui: replace `var' = `var' + "_p" + subinstr(`var'[2], "_p", " ", .) if _n==1
}
drop if _n==2

putdocx table tbl1 = data("rowname `varlist'"), width(100%) layout(autofitcontents)
putdocx table tbl1(., .), ${tablecells} 
putdocx table tbl1(., 1), ${tablefirstcol}
putdocx table tbl1(1, .), ${tablefirstrow}
putdocx paragraph
putdocx text ("Abbreviations and symbols:"), bold
putdocx text  (" BMI, body mass index; CCI, Charlson Comorbidity Index; HRR, hazard rate ratio. ")
putdocx text ("Notes:"), bold
putdocx text  (`" Cox proportional regression analysis for overall survival after adrenal metastasectomy for each primary cancer."')


** Tab - Median and 1-year survival for each cancer
local tabno = `tabno'+1
putdocx pagebreak
putdocx paragraph, style(Heading2) `fontHeading2'
putdocx text ("Table `tabno' - Median and 1-year survival by Primary Cancer")

* Add and format data
use results/TabProgByCancer_Combined.dta, clear

drop if vartype=="c" // No data for continuous vars

putdocx table tbl1 = data("rowname median1 surv11 median2 surv12 median3 surv13"), width(100%) layout(autofitcontents)
putdocx table tbl1(., .), ${tablecells} 
putdocx table tbl1(., 1), ${tablefirstcol}
putdocx table tbl1(1/2, .), ${tablefirstrow}
putdocx table tbl1(1, .), border(all, nil)
putdocx paragraph
putdocx text ("Notes:"), bold
putdocx text  (`" Median and 1-year survival after adrenal metastasectomy for renal, lung, and colorectal cancer."')



*** Save Figures and Tables report
putdocx save results/FigTablesCombined, replace



*** Combine and save text report
local files : dir "results" files "Text*.docx"
local textappend = ""
foreach file of local files {
	local textappend = "`textappend' results/`file'"
}
di "`textappend'"
putdocx append `textappend', saving(results/ReportCombined, replace)