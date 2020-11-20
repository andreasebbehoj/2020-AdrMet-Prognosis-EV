***** 0_Master.do *****
/*
This do file runs the analysis for the paper on Survival and Prognostic Factors after Adrenal Metastasectomy by Vlk E et al, 2020

The do-file is split in four sections:
1) Stata setup
2) Import patient data and define study variables
3) Import and prepare other data (population data)
4) Analysis
5) Combine report
*/


***** 1) STATA SETUP
/*
This section:
- Clear memory
- Install necessary Stata program
- Define custom programs
- Defines common settings for figures and tables
*/
do 1_Setup.do

do 1_FigTabLayout.do


***** 2) PREPARE PATIENT DATA
/*
This section:
- Import clinical data from REDCap database
- Define study cohort and generate main variables for later analyses
- Import data on complications collected in spreadsheet
*/
do 2_ImportRedcap.do

do 2_CohortAndVars.do

do 2_Complications.do


***** 3) PREPARE OTHER DATA
/*
This section:
- Import data on Danish population from Statistics Denmark
- Import any other relevant data
*/
do 3_ImportPopDK.do



***** 4) Analysis
/*
This section:
- Makes calculations for text
- Export tables as dta files
- Export graphs
- Generate supplementary results
*/

** Patient Characteristics 
do 4_TabCharByCancer.do

do 4_FigInciByApproach.do

** Complications
do 4_TabComplications.do

** Survival
do 4_TextSurv.do

do 4_FigSurv.do

** Prognostic factors
do 4_TabProgOverall.do

do 4_TabProgByCancer.do

window manage close graph _all
file close _all


***** 5) Report
/*
This section:
- Add headers and footnotes to graphs and tables
- Combine all documents into FigTablesCombined and ReportCombined
*/
do 5_Report.do