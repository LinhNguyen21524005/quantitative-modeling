******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
*            Problem Set 7: Individual Retirements Accounts (IRAs)
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\ProblemSolving
                                       // change working directory
									    
use "401kParticipation.dta"            // Load Data
 
* Setting up Lists of Regressors
global xlistexo inc incsq age agesq
global rlist c.($xlistexo)##c.($xlistexo) 
* Note: STATA will remove redundant regressors
regress pira $rlist

* Predictions 
* Create Training and Prediction Samples
splitsample pira, generate(train) split(1 4) values(0 1) rseed(90210)
* training sample: train = 1
* fitting sample: train = 0
tabulate train
* Ridge
elasticnet linear pira p401k $rlist if train==1, alpha(0)
lassoinfo
predict y_ridge, xb
* Lasso
lasso linear pira p401k $rlist if train==1
lassoinfo
predict y_lasso, xb
* Elastic Net
elasticnet linear pira p401k $rlist if train==1
lassoinfo
predict y_elanet, xb
* Multiple Linear Regression Model
regress pira p401k $xlistexo
predict y_mlr, xb
* Compare Predictive Performance
foreach var of varlist y_ridge y_lasso y_elanet y_mlr {                          
   quietly generate `var'errorsq1 = (`var'-pira)^2                       
   quietly summarize `var'errorsq1 if train == 1                               
   quietly scalar mse`var'train1 = r(mean)                                   
   quietly summarize `var'errorsq1 if train == 0                               
   quietly scalar mse`var'test1 = r(mean)                                    
   display "Predictor: " "`var'" _col(21)                                    ///       
   " Train MSE = " %8.6f mse`var'train1 " Test MSE = " %8.6f mse`var'test1    
   }

* For Comparison: OLS Estimation of Multiple Linear Regression
regress pira p401k inc incsq age agesq
* Partialed-Out Lasso-OLS
poregress pira p401k, controls($rlist)
lassoinfo
predict y_lassools, xb
* For Comparison: IV Estimation of Multiple Linear Regression
ivregress 2sls pira  inc incsq age agesq (p401k = e401k)
* Partialed-Out Lasso-IV
poivregress pira (p401k=e401k), controls($rlist)
lassoinfo
predict y_lassoiv, xb
* Compare Predictive Performance
foreach var of varlist y_ridge y_lasso y_elanet y_mlr y_lassools y_lassoiv {    
   quietly generate `var'errorsq2 = (`var'-pira)^2                       
   quietly summarize `var'errorsq2 if train == 1                               
   quietly scalar mse`var'train2 = r(mean)                                   
   quietly summarize `var'errorsq2 if train == 0                               
   quietly scalar mse`var'test2 = r(mean)                                    
   display "Predictor: " "`var'" _col(21)                                    ///       
   " Train MSE = " %8.6f mse`var'train2 " Test MSE = " %8.6f mse`var'test2    
   }
