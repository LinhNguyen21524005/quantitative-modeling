******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
*            Problem Set 3: Individual Retirements Accounts (IRAs)
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\ProblemSolving
                                       // change working directory
									    
use "401kParticipation.dta"            // Load Data
 
* Data Description 
summarize 

* OLS Estimation
regress pira p401k inc incsq age agesq
 	   
* Instrument Analysis	   
regress p401k e401k inc incsq age agesq	   

* Just-Identified IV Estimation	 
global xlistexo inc incsq age agesq
ivregress 2sls pira $xlistexo (p401k = e401k), first
ivregress 2sls pira $xlistexo (p401k = e401k), first vce(robust)
* Quality of Instruments
estat firststage
* Comparing OLS and IV Estimators (Hausman Test)
estat endogenous
