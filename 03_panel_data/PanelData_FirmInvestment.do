******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
*                 Problem Set 6: Firm Investment
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\ProblemSolving      // change working directory
									    
use "FirmPanel.dta"                    // Load Data
 
* Generate identifiers for cross-sectional and time-series observation numbers
generate id = [_n]
generate firm = 1 if id <= 20
replace firm = 2 if id > 20 & id < =40
replace firm = 3 if id > 40 & id < =60
replace firm = 4 if id > 60 & id < =80
replace firm = 5 if id > 80
generate t = _n if id <= 20
replace t = _n-20 if id > 20 & id < =40
replace t = _n-40 if id > 40 & id < =60
replace t = _n-60 if id > 60 & id < =80
replace t = _n-80 if id > 80

* Declare identifiers for cross-sectional and time-series observation numbers
xtset id t

* Data Description 
summarize I F C

* Generate Firm Dummies
generate Dum1 = ([_n] <= 20)
generate Dum2 = ([_n] >20 & [_n] <= 40)
generate Dum3 = ([_n] >40 & [_n] <= 60)
generate Dum4 = ([_n] >60 & [_n] <= 80)
generate Dum5 = ([_n] >80 & [_n] <= 100)
* Alternatively:
* drop Dum1 Dum2 Dum3 Dum4 Dum5
* tabulate firm, gen(Dum)

* Fixed Effects Model
* Least Suqares Dummy Variables
regress I Dum1 Dum2 Dum3 Dum4 Dum5 F C, nocons
regress I Dum1 Dum2 Dum3 Dum4 F C
* STATA Panel Data Command Syntax
xtreg I F C, fe i(firm)

* Random Effects Model
xtreg I F C, mle i(firm)
xtreg I F C, re i(firm)

* Hypothesis Testing
* Individual Effects
quietly regress I Dum1 Dum2 Dum3 Dum4 Dum5 F C, nocons
testparm Dum1-Dum5, equal
* Hausman Test
quietly xtreg I F C, fe i(firm)
estimates store fixed
quietly xtreg I F C, re i(firm)
estimates store random
hausman fixed random
