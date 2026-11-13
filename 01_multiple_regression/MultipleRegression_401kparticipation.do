* Define Dependent Variable List
global xlist1 p401k inc incsq age agesq    

* Data Description 
summarize pira $xlist1

regress pira $xlist1

* Multiple Linear Regression per OLS
quietly regress pira $xlist1
predict pirahat, xb
summarize pirahat
histogram pirahat, normal bin(100)                                          ///
title("Predicted probabilities of a household holding an IRA") name(histy, replace)


regress p401k e401k inc incsq age agesq 


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
	global xlist1 p401k inc incsq age agesq    

* Data Description 
	summarize pira $xlist1

		Variable |        Obs        Mean    Std. dev.       Min        Max
	-------------+---------------------------------------------------------
			pira |      9,275    .2543396    .4355128          0          1
		   p401k |      9,275    .2762264    .4471543          0          1
			 inc |      9,275    39.25464       24.09     10.008    199.041
		   incsq |      9,275    2121.192    3001.469   100.1601   39617.32
			 age |      9,275    41.08022    10.29952         25         64
	-------------+---------------------------------------------------------
		   agesq |      9,275    1793.653    895.6488        625       4096


Question2
	regress pira $xlist1

		  Source |       SS           df       MS      Number of obs   =     9,275
	-------------+----------------------------------   F(5, 9269)      =    406.85
		   Model |  316.571004         5  63.3142007   Prob > F        =    0.0000
		Residual |  1442.44183     9,269  .155620005   R-squared       =    0.1800
	-------------+----------------------------------   Adj R-squared   =    0.1795
		   Total |  1759.01283     9,274  .189671429   Root MSE        =    .39449

	------------------------------------------------------------------------------
			pira | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
	-------------+----------------------------------------------------------------
		   p401k |   .0536598   .0095713     5.61   0.000     .0348978    .0724217
			 inc |   .0086788    .000511    16.98   0.000     .0076771    .0096806
		   incsq |  -.0000228   4.03e-06    -5.65   0.000    -.0000307   -.0000149
			 age |  -.0015936   .0033302    -0.48   0.632    -.0081216    .0049343
		   agesq |   .0001173   .0000382     3.07   0.002     .0000424    .0001922
		   _cons |  -.1977236   .0686446    -2.88   0.004    -.3322821   -.0631651
	------------------------------------------------------------------------------

	
Question 4:	
	regress p401k e401k inc incsq age agesq 



		  Source |       SS           df       MS      Number of obs   =     9,275
	-------------+----------------------------------   F(5, 9269)      =   2738.42
		   Model |  1105.75506         5  221.151013   Prob > F        =    0.0000
		Residual |  748.552862     9,269  .080758751   R-squared       =    0.5963
	-------------+----------------------------------   Adj R-squared   =    0.5961
		   Total |  1854.30792     9,274   .19994694   Root MSE        =    .28418

	------------------------------------------------------------------------------
		   p401k | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
	-------------+----------------------------------------------------------------
		   e401k |   .6888454   .0063506   108.47   0.000     .6763968    .7012941
			 inc |   .0011117   .0003706     3.00   0.003     .0003853    .0018381
		   incsq |   1.84e-06   2.92e-06     0.63   0.528    -3.88e-06    7.56e-06
			 age |  -.0047205   .0024031    -1.96   0.050    -.0094312   -9.87e-06
		   agesq |    .000052   .0000276     1.89   0.059    -2.04e-06    .0001061
		   _cons |   .0591493   .0495148     1.19   0.232    -.0379107    .1562093
	------------------------------------------------------------------------------
	
Question 5:	
		   
	quietly regress pira $xlist1
	predict pirahat, xb
	summarize pirahat
	histogram pirahat, normal bin(100)                                          ///
	title("Predicted probabilities of a household holding an IRA") name(histy, replace)		   
			   

		Variable |        Obs        Mean    Std. dev.       Min        Max
	-------------+---------------------------------------------------------
		 pirahat |      9,275    .2543396    .1847575  -.0792637   .9647846


Question 4

*/
