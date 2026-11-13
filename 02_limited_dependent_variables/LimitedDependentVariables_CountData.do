******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
*   This Do file illustrates essentials of Count Regression Modeling in STATA 
*     with an application examining individuals' decisions to visit doctors.
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\LimitedDependentVariables
                                       // change working directory
									    
use "DoctorVisits.dta"                 // Load Data

* docvis: number of doctor visits
* age : age in years / 10
* income: income in U.S. $ / 1000
* female: dummy, equal to 1 if female
* black: dummy, equal to 1 if black
* hispanic: dummy, equal to 1 if hispanic
* married: dummy, equal to 1 if married
* physlim: dummy, equal to 1 if physical limitation
* private: dummy, equal to 1 if private insurance
* chronic: dummy, equal to 1 if a chronic condition
  
* Data Description 
summarize docvis private chronic female income age black hispanic    ///
          married physlim  
		  
* Graphical Analysis
* Histograms
* Doctor Visits
label variable docvis " "
histogram docvis, normal bin(25)                                     ///
title("Number of Annual Doctor Visits for 4412 Households")          ///
      name(histdocvis, replace)
graph export HistogramDoctorVisits.pdf, replace logo(off)            ///
             orientation(portrait)

* Maximum Likelihood Estimation of Poisson Model
poisson docvis private chronic female income physlim, irr

* Maximum Likelihood Estimation of Negative Binomial Model
nbreg docvis private chronic female income physlim, irr








/*
* Data Description 
	/summarize docvis private chronic female income age black hispanic    ///
          married physlim  

		Variable |        Obs        Mean    Std. dev.       Min        Max
	-------------+---------------------------------------------------------
		  docvis |      4,412    3.957389    7.947601          0        134
		 private |      4,412    .7853581    .4106202          0          1
		 chronic |      4,412    .3263826    .4689423          0          1
		  female |      4,412    .4718948    .4992661          0          1
		  income |      4,412    34.34018    29.03987    -49.999    280.777
	-------------+---------------------------------------------------------
			 age |      4,412    4.083454    1.022545        2.5        6.4
		   black |      4,412    .0528105    .2236804          0          1
		hispanic |      4,412    .2452403    .4302783          0          1
		 married |      4,412    .6357661    .4812692          0          1
		 physlim |      4,412    .1656845    .3718393          0          1

* Graphical Analysis
* Histograms
* Doctor Visits
	/label variable docvis " "
	/histogram docvis, normal bin(25)                                     ///
	/title("Number of Annual Doctor Visits for 4412 Households")          ///
		  name(histdocvis, replace)
	/graph export HistogramDoctorVisits.pdf, replace logo(off)            ///
				 orientation(portrait)

* Maximum Likelihood Estimation of Poisson Model
	/poisson docvis private chronic female income physlim, irr
	
	Iteration 0:  Log likelihood = -18129.296  
	Iteration 1:  Log likelihood = -18127.875  
	Iteration 2:  Log likelihood = -18127.875  

	Poisson regression                                     Number of obs =   4,412
														   LR chi2(5)    = 9604.06
														   Prob > chi2   =  0.0000
	Log likelihood = -18127.875                            Pseudo R2     =  0.2094

	------------------------------------------------------------------------------
		  docvis |        IRR   Std. err.      z    P>|z|     [95% conf. interval]
	-------------+----------------------------------------------------------------
		 private |   2.174793   .0602837    28.03   0.000     2.059791    2.296215
		 chronic |   2.689708   .0438663    60.67   0.000     2.605091    2.777073
		  female |   1.636319   .0262025    30.75   0.000      1.58576    1.688489
		  income |   1.004158    .000243    17.15   0.000     1.003682    1.004634
		 physlim |   1.613908   .0274061    28.19   0.000     1.561077    1.668526
		   _cons |   .7433077     .02149   -10.26   0.000     .7023592    .7866436
	------------------------------------------------------------------------------
	Note: _cons estimates baseline incidence rate.

* Maximum Likelihood Estimation of Negative Binomial Model
	/nbreg docvis private chronic female income physlim, irr	
	Fitting Poisson model:

	Iteration 0:  Log likelihood = -18129.296  
	Iteration 1:  Log likelihood = -18127.875  
	Iteration 2:  Log likelihood = -18127.875  

	Fitting constant-only model:

	Iteration 0:  Log likelihood = -10996.725  
	Iteration 1:  Log likelihood = -10389.213  
	Iteration 2:  Log likelihood = -10388.913  
	Iteration 3:  Log likelihood = -10388.913  

	Fitting full model:

	Iteration 0:  Log likelihood = -9952.8436  
	Iteration 1:  Log likelihood =  -9849.848  
	Iteration 2:  Log likelihood = -9789.1672  
	Iteration 3:  Log likelihood = -9788.9917  
	Iteration 4:  Log likelihood = -9788.9916  

	Negative binomial regression                           Number of obs =   4,412
														   LR chi2(5)    = 1199.84
	Dispersion: mean                                       Prob > chi2   =  0.0000
	Log likelihood = -9788.9916                            Pseudo R2     =  0.0577

	------------------------------------------------------------------------------
		  docvis |        IRR   Std. err.      z    P>|z|     [95% conf. interval]
	-------------+----------------------------------------------------------------
		 private |   2.373389   .1394226    14.71   0.000      2.11527    2.663005
		 chronic |   2.858931   .1300716    23.09   0.000     2.615032    3.125579
		  female |   1.797432   .0795763    13.24   0.000      1.64804    1.960365
		  income |   1.005231   .0007972     6.58   0.000      1.00367    1.006795
		 physlim |   1.878274   .1068189    11.08   0.000      1.68016     2.09975
		   _cons |   .5913309   .0363241    -8.55   0.000     .5242557    .6669879
	-------------+----------------------------------------------------------------
		/lnalpha |   .5049058   .0292387                      .4475989    .5622127
	-------------+----------------------------------------------------------------
		   alpha |   1.656829   .0484436                      1.564551     1.75455
	------------------------------------------------------------------------------
	Note: Estimates are transformed only in the first equation to incidence-rate ratios.
	Note: _cons estimates baseline incidence rate.
	LR test of alpha=0: chibar2(01) = 1.7e+04              Prob >= chibar2 = 0.000

	 
	 
*/
