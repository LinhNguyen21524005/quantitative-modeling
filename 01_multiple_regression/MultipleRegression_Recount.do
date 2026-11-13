******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
*                    Problem Set 2: Election Recount
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\ProblemSolving
                                       // change working directory
									    
use "Preselect.dta"                    // Load Data
 
* Data Description 
summarize 

* OLS Estimation
* First Model
regress BUCHANAN GORE
* Scatter Plot with OLS Regression Line
twoway (scatter BUCHANAN GORE) (lfitci BUCHANAN GORE, level(90)),         ///   
       title("67 Counties") name(scatterlfitci1, replace)
* Remove Outlier and redo regression analysis
destring OBS, generate(COUNTY)
drop if COUNTY == 50
* First Model
regress BUCHANAN GORE
* Scatter Plot with OLS Regression Line
twoway (scatter BUCHANAN GORE) (lfitci BUCHANAN GORE, level(90)),         ///   
       title("66 Counties") name(scatterlfitci2, replace)	   
	   
* Return to Full Data Set
clear            
use "Preselect.dta" 
destring OBS, generate(COUNTY)
* Create Dummy Variable for Palm Beach County
generate PBC = 0
replace PBC = 1 if COUNTY == 50
* Model
regress BUCHANAN GORE PBC
test _b[PBC]=975
display "H1: coef >= 975  p-value = " 1-ttail(r(df_r),sqrt(r(F)))

* Heteroskedasticity 
* Breusch-Pagan Test 
quietly regress BUCHANAN GORE 
estat hettest TOTAL, mtest          // iid normal disturbance terms
estat hettest TOTAL, iid            // iid disturbance terms
quietly regress BUCHANAN GORE PBC
estat hettest TOTAL, mtest
estat hettest TOTAL, iid

* Fraction of Votes
generate FBUCHANAN = BUCHANAN/TOTAL
generate FGORE = GORE/TOTAL
* First Model
regress FBUCHANAN FGORE
* Scatter Plot with OLS Regression Line
twoway (scatter FBUCHANAN FGORE) (lfitci FBUCHANAN FGORE, level(90)),    ///   
       title("67 Counties") name(scatterlfitci1, replace)
* Breusch-Pagan Test 
generate TOTALINV = TOTAL^(-1)
estat hettest TOTALINV, mtest
estat hettest TOTALINV, iid
* Second Model
regress FBUCHANAN FGORE PBC
estat hettest TOTALINV, mtest
estat hettest TOTALINV, iid
								  
* Feasible GLS Estimation
generate TOTAL2 = TOTAL^2
* First Model
regress BUCHANAN GORE [aw = 1/TOTAL2]  // variance of the i-th observation
                                       // is Var(eps)/TOTAL2; i-th observation 
                                       // is divided by TOTAL
regress BUCHANAN GORE [aw = 1/TOTAL2], vce(hc3)
* Second Model
regress BUCHANAN GORE PBC [aw = 1/TOTAL2]
regress BUCHANAN GORE PBC [aw = 1/TOTAL2], vce(hc3)
