******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
*          Problem Set 4: Deciding Whether to See a Medical Doctor
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\ProblemSolving
                                       // change working directory
									    
use "HealthBinary.dta"                 // Load Data
 
* dmed: 1 if annual USD medical expenditure (excluding dental and outpatient 
*       mental expenditure) > 0, 0 otherwise
* linc: logarithm of annual USD family income  
* lc: log(coinsrate+1) where coinsurance rate is 0 to 100
* idp: 1 if individual deductible plan
* lpi: log(annual participation incentive payment) or 0 if no payment 
* fmde: log(max(medical deductible expenditure (mde))) if idp=1 and mde>1 
*       or 0 otherwise.
* ndisease: number of chronic diseases
* physlim: 1 if physical limitation
* hlthg: 1 if good health
* hlthf: 1 if good health
* hlthp: 1 if good health (omitted is excellent)
* lfam: log of family size
* educdec: years of schooling of decision maker
* age: exact age
* black: 1 if black
* female: 1 if female 
* child: 1 if child
* femchild: 1 if female child

* Data Description 
summarize 

* Define Dependent Variable List
global xlist1 linc lc lpi fmde idp ndisease physlim                      /// 
       hlthg hlthf hlthp lfam educdec age black female child femchild      

* Probit Model
probit dmed $xlist1
estimates store ProbitEst
* Average Marginal Effects 
margins, dydx(*)

* Logit Model
logit dmed $xlist1    
estimates store LogitEst
estimates table ProbitEst LogitEst, b
* Average Marginal Effects 
margins, dydx(*)
* Odds Ratios
logistic dmed $xlist1
