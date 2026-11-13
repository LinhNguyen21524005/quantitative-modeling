******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
*   This Do file illustrates essentials of Logit and Probit Modeling in STATA 
*  with an application examining individuals' decisions as to whether to apply
*                         for unemployment benefits.
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\LimitedDependentVariables
                                       // change working directory
									    
use "UnemploymentBenefits.dta"         // Load Data

* y: dummy, equal to 1 if applied for (and received) unemployment insurance
*    benefits
* rr: replacement rate (ratio of weekly unemployment insurance benefits to 
*     previous weekly earnings)
* rr2: rr^2
* stateur: state unemployment rate (in %)
* statemb: state maximum benefit level
* state: state of residence code
* slack: dummy, equal to 1 if job lost due to slack work
* abol:	dummy, equal to 1 if job lost because position was abolished
* seasonal:	dummy, equal to 1 if job lost because seasonal job ended
* yrdispl: year of job displacement (1982=1, ..., 1991=10)
* tenure: years of tenure in job lost
* age: age in years
* age2:	age^2
* school12:	dummy, equal to 1 if more than 12 years of school
* male:	dummy, equal to 1 if male
* nwhite: dummy, equal to 1 if non-white
* head:	dummy, equal to 1 if head of household
* married: dummy, equal to 1 if married
* dkids: dummy, equal to 1 if kids
* dykids: dummy, equal to 1 if young children (0-5 years)
* smsa:	dummy, equal to 1 if living in smsa (metropolitan area)  

* Define Dependent Variable List
global xlist1 rr rr2 statemb stateur slack abol seasonal yrdispl tenure  ///
       age age2 school12 male nwhite head married dkids dykids smsa    

* Data Description 
summarize y $xlist1

* Multiple Linear Regression per OLS
quietly regress y $xlist1
predict yhat, xb
summarize yhat
histogram yhat, normal bin(100)                                          ///
title("Predicted Probabilities of Filing for Benefits") name(histy, replace)

* Logit Model
logit y $xlist1    
* Summary Table of Predictions 
estat classification
scalar R2Pred = 1-(1300+171)/1542
scalar list R2Pred       // 1 - fraction of incorrect predictions
* Marginal Effects 
margins, dydx(_all)      // Averages

* Regression Using Odds Ratios
logistic y $xlist1
* Marginal Effects Plots
summarize stateur
quietly margins, at(stateur=(2.2(.1)18))
marginsplot, xlabel(2(2)18) recast(line) recastci(rarea) name(logitmep, replace)

* Probit Model
probit y $xlist1
* Marginal Effects 
margins, dydx(*)     // Averages
margins, dydx(*) atmeans
* Marginal Effects Plots
quietly margins, at(stateur=(2.2(.1)18))
marginsplot, xlabel(2(2)18) recast(line) recastci(rarea) name(probitmep, replace)



/*
* Define Dependent Variable List
	/global xlist1 rr rr2 statemb stateur slack abol seasonal yrdispl tenure  ///
		   age age2 school12 male nwhite head married dkids dykids smsa    


* Data Description 
	/summarize y $xlist1

		Variable |        Obs        Mean    Std. dev.       Min        Max
	-------------+---------------------------------------------------------
			   y |      4,877     .683822     .465031          0          1
			  rr |      4,877    .4383664    .1061945     .03861   .6911765
			 rr2 |      4,877    .2034401    .0846599   .0014907   .4777249
		 statemb |      4,877    180.6602    43.24159         84        293
		 stateur |      4,877    7.511031    2.500579        2.2         18
	-------------+---------------------------------------------------------
		   slack |      4,877    .4761124    .4994803          0          1
			abol |      4,877    .0824277    .2750435          0          1
		seasonal |      4,877    .0362928    .1870369          0          1
		 yrdispl |      4,877    5.203609    3.095116          1         10
		  tenure |      4,877    5.664138    6.279938          1         41
	-------------+---------------------------------------------------------
			 age |      4,877       36.13    10.60074         20         61
			age2 |      4,877    141.7729     83.8097         40      372.1
		school12 |      4,877    .1900759    .3924011          0          1
			male |      4,877    .7641993    .4245417          0          1
		  nwhite |      4,877    .1472217    .3543631          0          1
	-------------+---------------------------------------------------------
			head |      4,877    .6805413    .4663147          0          1
		 married |      4,877     .632766    .4821004          0          1
		   dkids |      4,877    .4857494    .4998481          0          1
		  dykids |      4,877    .2216527    .4154012          0          1
			smsa |      4,877    .6526553    .4761752          0          1


* Multiple Linear Regression per OLS
	/quietly regress y $xlist1
	/predict yhat, xb
	/summarize yhat


		Variable |        Obs        Mean    Std. dev.       Min        Max
	-------------+---------------------------------------------------------
			yhat |      4,877     .683822    .1202892   .3203552   1.163627


	/histogram yhat, normal bin(100)                                          ///
	/title("Predicted Probabilities of Filing for Benefits") name(histy, replace)
	
	(bin=100, start=.32035524, width=.00843271)
	
* Logit Model
logit y $xlist1    
* Summary Table of Predictions 
estat classification
scalar R2Pred = 1-(1300+171)/1542
scalar list R2Pred       // 1 - fraction of incorrect predictions
* Marginal Effects 
margins, dydx(_all)      // Averages

* Regression Using Odds Ratios
logistic y $xlist1
* Marginal Effects Plots
summarize stateur
quietly margins, at(stateur=(2.2(.1)18))
marginsplot, xlabel(2(2)18) recast(line) recastci(rarea) name(logitmep, replace)

* Probit Model
probit y $xlist1
* Marginal Effects 
margins, dydx(*)     // Averages
margins, dydx(*) atmeans
* Marginal Effects Plots
quietly margins, at(stateur=(2.2(.1)18))
marginsplot, xlabel(2(2)18) recast(line) recastci(rarea) name(probitmep, replace)
*/
