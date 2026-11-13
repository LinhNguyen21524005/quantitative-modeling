******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
* This Do file illustrates essentials of panel-based multiple regression 
* analysis in STATA with an application examining the determinants of wages.
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\PanelData
                                       // change working directory
									    
* Load Data 
import excel using "PSIDWagePanel", first
save "PSIDWagePanel.dta", replace      // saving data in *.dta format

* id: ID for each individual
* lwage: log wage
* ed: years of education
* exp: years of full-time work experience
* exp2: years of experience squared
* wks: weeks worked
* occ: occupation; occ=1 if in a blue-collar occupation
* ind: type of industry: ind=1 if working in a manufacturing industry
* south: residence; south=1 if in the southern area
* smsa: smsa=1 if in the standard metropolitan statistical area
* ms: marital status
* fem: female or male
* union: if wage set be a union contract
* blk: black
* t: year index
* tdum1: t=1
* tdum2: t=2
* tdum3: t=3
* tdum4: t=4
* tdum5: t=5
* tdum6: t=6
* tdum7: t=7

* Define Dependent Variable List
global xlist1 ed exp exp2 wks occ ind south smsa ms fem union blk t
	   
* Data Description 
summarize lwage $xlist1

* Declare identifiers for cross-sectional and time-series observation numbers
xtset id t

* Graphical Analysis
label variable lwage " "
xtline lwage if id<50, overlay legend(off) name(WagePlot, replace)       ///  
       title("Logarithm of Wages Across Years, 50 Individuals")               

* Executing Commands Separately for Each Different Cross-Sectional Unit
by id: generate wagegr = 100*(lwage-lwage[_n-1])

* Regression Analysis
* Pooled OLS 
regress lwage $xlist1
* Fixed Effects
xtreg lwage $xlist1, fe i(id)
* Random Effects 
xtreg lwage $xlist1, re i(id)  
xtreg lwage $xlist1, mle i(id)

* Hausman test
* All Regressors
quietly xtreg lwage $xlist1, fe i(id)
estimates store fixed
quietly xtreg lwage $xlist1, re i(id)
estimates store random
hausman fixed random
* Subset of Regressors
quietly xtreg lwage exp exp2, fe i(id)
estimates store fixed2
quietly xtreg lwage exp exp2, re i(id)
estimates store random2
hausman fixed2 random2
