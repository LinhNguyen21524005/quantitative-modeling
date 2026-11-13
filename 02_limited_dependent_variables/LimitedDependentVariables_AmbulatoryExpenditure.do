******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
*                 Problem Set 5: Ambulatory Expenditure
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\ProblemSolving
                                       // change working directory
									    
use "AmbulatoryExpenditure.dta"        // Load Data
 
* y: ambulatory expenditure
* lny: logarithm of ambulatory expenditure, with zeros replacing NA's
* dy: 1 if ambulatory expenditure is greater than zero
* educ: educational attainment, in years
* age: age / 10
* income: income
* female: 1 if female
* totch: number of chronic diseases
* blhisp: 1 if black or hispanic ethnicity
* ins: 1 if insured

* Data Description 
summarize 

* Define Dependent Variable List
global xlist1 ins totch age age2 educ blhisp      

* Tobit I Model
tobit y $xlist1 income, ll
* Marginal Effects: E(y|x,y>0)
margins, dydx(*) predict(ystar(0,.))

* Tobit II Model
heckman lny $xlist1 income, select (dy = $xlist1 income) 
* Marginal Effects: E(y|x,y>0)
margins, dydx(*) predict(ystar(0,.))

* Tobit II Model With Exclusion Restrictions
heckman lny $xlist1, select (dy = $xlist1 income) 
* Marginal Effects: E(y|x,y>0)
margins, dydx(*) predict(ystar(0,.))

* Tobit I Predictions
* Part 1: Probit
probit dy $xlist1 income          
predict probpart1, p          
* Part 2: OLS for lny corresponding to y>0
regress lny $xlist1 income if y>0
scalar sert1 = e(rmse)  
predict predlnaepos1, xb 
generate predaepos1 = exp(predlnaepos1+(sert1^2)/2)
generate predaeall1 = probpart1*predaepos1
* First Set of Tobit II Predictions 
heckman lny $xlist1 income, select (dy = $xlist1 income) 
scalar sert2 = e(sigma)
predict predlaepos2, ycond      
predict probpart2, psel
generate predaepos2 = exp(predlaepos2+(sert2^2)/2) 
generate predaeall2 = probpart2*predaepos2
* Second Set of Tobit II Predictions 
heckman lny $xlist1, select (dy = $xlist1 income) 
scalar shml3 = e(sigma)
predict predlaepos3, ycond      
predict probpart3, psel
generate predaepos3 = exp(predlaepos3+(shml3^2)/2) 
generate predaeall3 = probpart3*predaepos3
* Prediction Results
summarize y predaepos1 predaepos2 predaepos3 if y>0 
summarize y predaeall1 predaeall2 predaeall3
