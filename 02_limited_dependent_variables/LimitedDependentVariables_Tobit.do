******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
*         This Do file illustrates essentials of Tobit Modeling in STATA 
*             with an application examining health care expenditures.
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\LimitedDependentVariables
                                       // change working directory
									    
use "HealthExpenditures_Tobit.dta"     // Load Data

* med: Annual USD medical expenditure (excluding dental and outpatient mental
*      expenditure)
* dmed: 1 if med>0, 0 otherwise
* lmed: logarithm of annual USD medical expenditure (excluding dental and
*       outpatient mental expenditure) given med>0, missing otherwise
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

* Define Dependent Variable List
global xlist1 linc lc lpi fmde idp physlim ndisease                  /// 
       hlthg hlthf hlthp educdec age lfam female child femchild black
	   
* Data Description 
summarize med dmed lmed $xlist1

* Tobit I Model
tobit med $xlist1, ll
* Marginal Effects: E(y|x,y>0)
margins, dydx(*) predict(ystar(0,.))

* Obtain Predictions Using Two-Step Approach
* Part 1: Probit for whether med>0
probit dmed $xlist1          
predict probpart, p          // predicted probability for med>0 
* Part 2: OLS for lmed corresponding to med>0
regress lmed $xlist1 
scalar seols = e(rmse)       // standard error of regression
predict predlmed, xb         // predicted mean log medical expenditure 
                             // for med>0
* Create predictions of level of medical expenditures 
generate predmedpos = exp(predlmed+(seols^2)/2) 
   // if w is normally distributed with mean mu and variance sigma^2,
   // then v = exp(w) is log-normally distributed, with mean
   // exp(mu+sigma^2/2)
generate predmedall = probpart*predmedpos
* Compare predictions to actual medical expenditures for med > 0
summarize med predmedpos if med > 0 
corr med predmedpos if med > 0
* Compare predictions to actual medical expenditures, including med = 0
summarize dmed probpart med predmedall 
corr dmed probpart
corr med predmedall

* Tobit II Model: Maximum Likelihood Estimation
heckman lmed $xlist1, select (dmed = $xlist1) first 
scalar shml = e(sigma )     // standard error of regression 
                            // (participation effects)
* Create predictions of level of medical expenditures 
predict yposml, ycond       // predicted mean log medical expenditure for med>0
predict probselml, psel     // predicted probability for med>0
generate predmedposml = exp(yposml+(shml^2)/2) 
generate predmedallml = probselml*predmedposml
* Compare predictions to actual medical expenditures for med > 0
summarize med predmedposml if med > 0 
corr lmed yposml med predmedposml if med > 0
* Compare predictions to actual medical expenditures including med = 0
summarize dmed probselml med predmedallml 
corr dmed probselml
corr med predmedallml 

* Tobit II Model: Two Step Estimation 
heckman lmed $xlist1, select (dmed = $xlist1) twostep first
* Check for possible collinearity problems in two step estimation
predict invmill2s, mills
matrix accum xx = invmill2s $xlist1
matrix xxscaled = corr(xx)
matrix symeigen xxseigvec xxseigval = xxscaled 
scalar rowsxx = rowsof(xx) 
scalar condnum = sqrt(xxseigval[1,1]/xxseigval[1,rowsxx])
* Find the condition number without inverse mills ratio
matrix accum zz = $xlist1 
matrix zzscaled = corr(zz)
matrix symeigen zzseigvec zzseigval = zzscaled 
scalar rowszz = rowsof(zz) 
scalar condnumnoinvmills = sqrt(zzseigval[1,1]/zzseigval[1,rowszz])
* List condition numbers (condition numbers between 30 and 100 indicate 
* strong near-dependency)
scalar list condnum 
scalar list condnumnoinvmills 




/* Summarize variables
* Define Dependent Variable List
global xlist1 linc lc lpi fmde idp physlim ndisease                  /// 
       hlthg hlthf hlthp educdec age lfam female child femchild black
	   
* Data Description 
summarize med dmed lmed $xlist1


			Variable |        Obs        Mean    Std. dev.       Min        Max
		-------------+---------------------------------------------------------
				 med |      5,574    169.7247    802.8303          0   39182.02
				dmed |      5,574    .7680301    .4221277          0          1
				lmed |      4,281    4.069462    1.499372  -.5343859   10.57597
				linc |      5,574    8.696929    1.220592          0   10.28324
				  lc |      5,574    2.420739    2.043883          0   4.564348
		-------------+---------------------------------------------------------
				 lpi |      5,574    4.726834    2.681354          0   7.163699
				fmde |      5,574    4.065015    3.450558          0   8.294049
				 idp |      5,574     .261751    .4396272          0          1
			 physlim |      5,574    .1242463    .3233768          0          1
			ndisease |      5,574    11.20526    6.788959          0       58.6
		-------------+---------------------------------------------------------
			   hlthg |      5,574    .3649085    .4814477          0          1
			   hlthf |      5,574    .0782203     .268542          0          1
			   hlthp |      5,574    .0156082     .123965          0          1
			 educdec |      5,574     11.9466    2.837492          0         25
				 age |      5,574    25.57613    16.73011   .0253251   63.27515
		-------------+---------------------------------------------------------
				lfam |      5,574    1.241407    .5403965          0   2.564949
			  female |      5,574    .5184787    .4997032          0          1
			   child |      5,574    .4050951    .4909545          0          1
			femchild |      5,574    .1955508    .3966597          0          1
			   black |      5,574    .1859852    .3860055          0          1

*/
			   
/* Tobit I Model
tobit med $xlist1, ll
		Refining starting values:

		Grid node 0:  Log likelihood = -36296.563

		Fitting full model:

		Iteration 0:  Log likelihood = -36296.563  
		Iteration 1:  Log likelihood = -36063.721  
		Iteration 2:  Log likelihood = -36053.782  
		Iteration 3:  Log likelihood = -36053.754  
		Iteration 4:  Log likelihood = -36053.754  

		Tobit regression                                    Number of obs     =  5,574
																   Uncensored =  4,281
		Limits: Lower =    0                                    Left-censored =  1,293
				Upper = +inf                                   Right-censored =      0

															LR chi2(17)       = 414.03
															Prob > chi2       = 0.0000
		Log likelihood = -36053.754                         Pseudo R2         = 0.0057

		------------------------------------------------------------------------------
				 med | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
		-------------+----------------------------------------------------------------
				linc |   40.18061   12.44281     3.23   0.001     15.78783    64.57338
				  lc |   -37.6339   18.35832    -2.05   0.040    -73.62338   -1.644418
				 lpi |   13.35271   5.802958     2.30   0.021     1.976647    24.72878
				fmde |  -.2533782   10.76308    -0.02   0.981    -21.35322    20.84647
				 idp |   -40.9513   35.86032    -1.14   0.254    -111.2515    29.34894
			 physlim |   198.1232   42.56058     4.66   0.000     114.6878    281.5586
			ndisease |   9.389169   2.108403     4.45   0.000     5.255875    13.52246
			   hlthg |   39.47011   28.94471     1.36   0.173    -17.27284    96.21306
			   hlthf |   166.8121   53.10046     3.14   0.002      62.7144    270.9097
			   hlthp |   967.0607   106.0089     9.12   0.000     759.2418     1174.88
			 educdec |   15.81618   4.978339     3.18   0.001     6.056693    25.57567
				 age |    .709707   1.365135     0.52   0.603     -1.96649    3.385904
				lfam |  -56.04589   27.48096    -2.04   0.041    -109.9193   -2.172457
			  female |   102.3229   34.46049     2.97   0.003     34.76691     169.879
			   child |  -51.11863   53.70927    -0.95   0.341    -156.4098    54.17254
			femchild |  -94.79867   53.41124    -1.77   0.076    -199.5056    9.908252
			   black |  -230.2242   38.46363    -5.99   0.000    -305.6279   -154.8204
			   _cons |  -604.7429    129.942    -4.65   0.000      -859.48   -350.0059
		-------------+----------------------------------------------------------------
		   var(e.med)|   828544.4   18053.61                      793897.5    864703.4
		------------------------------------------------------------------------------

		
* Marginal Effects: E(y|x,y>0)
margins, dydx(*) predict(ystar(0,.))
		
		Average marginal effects                                 Number of obs = 5,574
		Model VCE: OIM

		Expression: E(med*|med>0), predict(ystar(0,.))
		dy/dx wrt:  linc lc lpi fmde idp physlim ndisease hlthg hlthf hlthp educdec age lfam female child femchild black

		------------------------------------------------------------------------------
					 |            Delta-method
					 |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
		-------------+----------------------------------------------------------------
				linc |    19.7987   6.133539     3.23   0.001     7.777183    31.82021
				  lc |  -18.54383   9.044853    -2.05   0.040    -36.27141   -.8162405
				 lpi |   6.579452    2.85953     2.30   0.021     .9748753    12.18403
				fmde |  -.1248502   5.303434    -0.02   0.981    -10.51939    10.26969
				 idp |  -20.17845   17.67017    -1.14   0.253    -54.81134    14.45443
			 physlim |   97.62375   20.97505     4.65   0.000     56.51342    138.7341
			ndisease |   4.626444   1.038768     4.45   0.000     2.590495    6.662393
			   hlthg |   19.44861   14.26349     1.36   0.173    -8.507319    47.40453
			   hlthf |   82.19542   26.17144     3.14   0.002     30.90034    133.4905
			   hlthp |    476.512   52.21075     9.13   0.000     374.1808    578.8432
			 educdec |   7.793308   2.453205     3.18   0.001     2.985114     12.6015
				 age |   .3497029   .6726642     0.52   0.603    -.9686947    1.668101
				lfam |   -27.6162   13.54301    -2.04   0.041    -54.16001   -1.072389
			  female |   50.41888   16.97538     2.97   0.003     17.14776    83.69001
			   child |  -25.18833   26.46761    -0.95   0.341     -77.0639    26.68724
			femchild |  -46.71135   26.31457    -1.78   0.076    -98.28696    4.864269
			   black |  -113.4413   18.94852    -5.99   0.000    -150.5797   -76.30286
		------------------------------------------------------------------------------
*/

/*	Obtain Predictions Using Two-Step Approach	

* Part 1: Probit for whether med>0
probit dmed $xlist1          
predict probpart, p          // predicted probability for med>0 		

		Iteration 0:  Log likelihood = -3019.1326  
		Iteration 1:  Log likelihood = -2695.0822  
		Iteration 2:  Log likelihood = -2690.5853  
		Iteration 3:  Log likelihood = -2690.5768  
		Iteration 4:  Log likelihood = -2690.5768  

		Probit regression                                       Number of obs =  5,574
																LR chi2(17)   = 657.11
																Prob > chi2   = 0.0000
		Log likelihood = -2690.5768                             Pseudo R2     = 0.1088

		------------------------------------------------------------------------------
				dmed | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
		-------------+----------------------------------------------------------------
				linc |   .0518413   .0168128     3.08   0.002     .0188889    .0847938
				  lc |   -.118708   .0269005    -4.41   0.000    -.1714319    -.065984
				 lpi |   .0283091   .0088793     3.19   0.001      .010906    .0457121
				fmde |   .0075319   .0161584     0.47   0.641     -.024138    .0392018
				 idp |  -.1279483   .0522351    -2.45   0.014    -.2303272   -.0255693
			 physlim |   .2732013   .0743761     3.67   0.000     .1274268    .4189758
			ndisease |   .0224861   .0035958     6.25   0.000     .0154384    .0295338
			   hlthg |   .0387516   .0438545     0.88   0.377    -.0472016    .1247049
			   hlthf |   .1920062   .0836688     2.29   0.022     .0280185     .355994
			   hlthp |   .6397294   .2126322     3.01   0.003     .2229779    1.056481
			 educdec |    .036307   .0076536     4.74   0.000     .0213062    .0513078
				 age |   .0002631   .0021606     0.12   0.903    -.0039715    .0044978
				lfam |  -.0335599    .041728    -0.80   0.421    -.1153452    .0482253
			  female |   .4451035    .054292     8.20   0.000     .3386932    .5515138
			   child |    .111489   .0808338     1.38   0.168    -.0469424    .2699203
			femchild |  -.4512845   .0799219    -5.65   0.000    -.6079284   -.2946405
			   black |  -.6057367   .0523148   -11.58   0.000    -.7082718   -.5032017
			   _cons |   -.271605   .1877345    -1.45   0.148    -.6395579    .0963478
		------------------------------------------------------------------------------

* Part 2: OLS for lmed corresponding to med>0
regress lmed $xlist1 
scalar seols = e(rmse)       // standard error of regression
predict predlmed, xb         // predicted mean log medical expenditure 
                             // for med>0		
		
			  Source |       SS           df       MS      Number of obs   =     4,281
		-------------+----------------------------------   F(17, 4263)     =     39.69
			   Model |  1314.70352        17   77.335501   Prob > F        =    0.0000
			Residual |  8307.23358     4,263  1.94868252   R-squared       =    0.1366
		-------------+----------------------------------   Adj R-squared   =    0.1332
			   Total |   9621.9371     4,280  2.24811614   Root MSE        =     1.396

		------------------------------------------------------------------------------
				lmed | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
		-------------+----------------------------------------------------------------
				linc |   .0931988   .0217849     4.28   0.000     .0504891    .1359085
				  lc |  -.0164006   .0312495    -0.52   0.600    -.0776658    .0448647
				 lpi |   .0027057   .0097138     0.28   0.781    -.0163383    .0217498
				fmde |  -.0306123   .0180695    -1.69   0.090    -.0660379    .0048134
				 idp |  -.0789998    .061796    -1.28   0.201    -.2001522    .0421526
			 physlim |   .2619829   .0687459     3.81   0.000     .1272052    .3967607
			ndisease |   .0198922   .0034441     5.78   0.000       .01314    .0266444
			   hlthg |   .1438008   .0483778     2.97   0.003     .0489553    .2386464
			   hlthf |   .3642649   .0881004     4.13   0.000     .1915422    .5369876
			   hlthp |   .7865099   .1700502     4.63   0.000      .453123    1.119897
			 educdec |  -5.66e-06   .0082599    -0.00   0.999    -.0161993     .016188
				 age |   .0055602    .002251     2.47   0.014     .0011471    .0099733
				lfam |  -.1408033    .046203    -3.05   0.002    -.2313852   -.0502214
			  female |   .3442509   .0571573     6.02   0.000     .2321929     .456309
			   child |  -.2677921   .0904307    -2.96   0.003    -.4450833   -.0905009
			femchild |  -.3512207   .0896517    -3.92   0.000    -.5269847   -.1754568
			   black |  -.1964412   .0677021    -2.90   0.004    -.3291725   -.0637099
			   _cons |   3.077182   .2213448    13.90   0.000      2.64323    3.511133
		------------------------------------------------------------------------------
		
* Create predictions of level of medical expenditures 
generate predmedpos = exp(predlmed+(seols^2)/2) 
   // if w is normally distributed with mean mu and variance sigma^2,
   // then v = exp(w) is log-normally distributed, with mean
   // exp(mu+sigma^2/2)
generate predmedall = probpart*predmedpos

* Compare predictions to actual medical expenditures for med > 0
summarize med predmedpos if med > 0 
corr med predmedpos if med > 0

		. summarize med predmedpos if med > 0 

			Variable |        Obs        Mean    Std. dev.       Min        Max
		-------------+---------------------------------------------------------
				 med |      4,281     220.987    909.9021   .5860291   39182.02
		  predmedpos |      4,281     183.462    126.0213   26.37827   1731.088

		. corr med predmedpos if med > 0
		(obs=4,281)

					 |      med predme~s
		-------------+------------------
				 med |   1.0000
		  predmedpos |   0.1669   1.0000

* Compare predictions to actual medical expenditures, including med = 0
summarize dmed probpart med predmedall 
corr dmed probpart
corr med predmedall
		. * Compare predictions to actual medical expenditures, including med = 0
		. summarize dmed probpart med predmedall 

			Variable |        Obs        Mean    Std. dev.       Min        Max
		-------------+---------------------------------------------------------
				dmed |      5,574    .7680301    .4221277          0          1
			probpart |      5,574    .7678377    .1457464   .1526731    .999246
				 med |      5,574    169.7247    802.8303          0   39182.02
		  predmedall |      5,574     140.966    120.2022   4.880651   1729.783

		. corr dmed probpart
		(obs=5,574)

					 |     dmed probpart
		-------------+------------------
				dmed |   1.0000
			probpart |   0.3467   1.0000


		. corr med predmedall
		(obs=5,574)

					 |      med predme~l
		-------------+------------------
				 med |   1.0000
		  predmedall |   0.1772   1.0000
*/

/*Tobit II Model: Maximum Likelihood Estimation
heckman lmed $xlist1, select (dmed = $xlist1) first 
scalar shml = e(sigma )     // standard error of regression 
                            // (participation effects)					

		. heckman lmed $xlist1, select (dmed = $xlist1) first 

		Iteration 0:  Log likelihood = -3019.1326  
		Iteration 1:  Log likelihood =  -2698.302  
		Iteration 2:  Log likelihood = -2690.6146  
		Iteration 3:  Log likelihood = -2690.5768  
		Iteration 4:  Log likelihood = -2690.5768  

		Probit regression                                       Number of obs =  5,574
																LR chi2(17)   = 657.11
																Prob > chi2   = 0.0000
		Log likelihood = -2690.5768                             Pseudo R2     = 0.1088

		------------------------------------------------------------------------------
				dmed | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
		-------------+----------------------------------------------------------------
				linc |   .0518413   .0168128     3.08   0.002     .0188889    .0847938
				  lc |   -.118708   .0269005    -4.41   0.000    -.1714319    -.065984
				 lpi |   .0283091   .0088793     3.19   0.001      .010906    .0457121
				fmde |   .0075319   .0161584     0.47   0.641     -.024138    .0392018
				 idp |  -.1279483   .0522351    -2.45   0.014    -.2303272   -.0255693
			 physlim |   .2732013   .0743761     3.67   0.000     .1274268    .4189758
			ndisease |   .0224861   .0035958     6.25   0.000     .0154384    .0295338
			   hlthg |   .0387516   .0438545     0.88   0.377    -.0472016    .1247049
			   hlthf |   .1920062   .0836688     2.29   0.022     .0280185     .355994
			   hlthp |   .6397294   .2126322     3.01   0.003      .222978    1.056481
			 educdec |    .036307   .0076536     4.74   0.000     .0213062    .0513078
				 age |   .0002631   .0021606     0.12   0.903    -.0039715    .0044978
				lfam |  -.0335599    .041728    -0.80   0.421    -.1153452    .0482253
			  female |   .4451035    .054292     8.20   0.000     .3386932    .5515138
			   child |    .111489   .0808338     1.38   0.168    -.0469424    .2699203
			femchild |  -.4512845   .0799219    -5.65   0.000    -.6079284   -.2946405
			   black |  -.6057367   .0523148   -11.58   0.000    -.7082718   -.5032017
			   _cons |   -.271605   .1877345    -1.45   0.148    -.6395579    .0963478
		------------------------------------------------------------------------------

		Iteration 0:  Log likelihood = -10183.753  (not concave)
		Iteration 1:  Log likelihood = -10183.676  (not concave)
		Iteration 2:  Log likelihood = -10183.593  (not concave)
		Iteration 3:  Log likelihood = -10183.525  (not concave)
		Iteration 4:  Log likelihood = -10183.467  (not concave)
		Iteration 5:  Log likelihood = -10183.408  (not concave)
		Iteration 6:  Log likelihood = -10183.311  (not concave)
		Iteration 7:  Log likelihood =  -10183.21  (not concave)
		Iteration 8:  Log likelihood = -10179.155  
		Iteration 9:  Log likelihood = -10176.799  
		Iteration 10: Log likelihood =  -10170.17  
		Iteration 11: Log likelihood =  -10170.11  
		Iteration 12: Log likelihood =  -10170.11  

		Heckman selection model                         Number of obs     =      5,574
		(regression model with sample selection)              Selected    =      4,281
															  Nonselected =      1,293

														Wald chi2(17)     =     805.17
		Log likelihood = -10170.11                      Prob > chi2       =     0.0000

		------------------------------------------------------------------------------
					 | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
		-------------+----------------------------------------------------------------
		lmed         |
				linc |   .1214009   .0230845     5.26   0.000     .0761562    .1666457
				  lc |  -.0760236   .0337456    -2.25   0.024    -.1421638   -.0098833
				 lpi |     .01493   .0105015     1.42   0.155    -.0056526    .0355127
				fmde |   -.023522   .0194745    -1.21   0.227    -.0616913    .0146474
				 idp |  -.1497199   .0661379    -2.26   0.024    -.2793478    -.020092
			 physlim |   .3548628   .0755425     4.70   0.000     .2068023    .5029233
			ndisease |   .0286474   .0037972     7.54   0.000     .0212051    .0360897
			   hlthg |   .1559173   .0521775     2.99   0.003     .0536513    .2581834
			   hlthf |   .4451223   .0955263     4.66   0.000     .2578942    .6323505
			   hlthp |   .9986065   .1878791     5.32   0.000     .6303701    1.366843
			 educdec |   .0175951   .0090183     1.95   0.051    -.0000805    .0352707
				 age |   .0057376   .0024426     2.35   0.019     .0009501    .0105251
				lfam |  -.1583018   .0497464    -3.18   0.001     -.255803   -.0608005
			  female |   .5503441   .0633313     8.69   0.000     .4262171    .6744711
			   child |  -.1976875    .097398    -2.03   0.042    -.3885841    -.006791
			femchild |  -.5653227   .0975292    -5.80   0.000    -.7564765    -.374169
			   black |  -.5358684   .0749191    -7.15   0.000    -.6827072   -.3890296
			   _cons |   2.107745   .2442285     8.63   0.000     1.629066    2.586424
		-------------+----------------------------------------------------------------
		dmed         |
				linc |   .0553122   .0166179     3.33   0.001     .0227416    .0878827
				  lc |  -.1068027   .0264766    -4.03   0.000    -.1586959   -.0549096
				 lpi |   .0294804   .0086214     3.42   0.001     .0125827    .0463781
				fmde |   .0007403   .0158738     0.05   0.963    -.0303719    .0318524
				 idp |   -.108769   .0509938    -2.13   0.033    -.2087149   -.0088231
			 physlim |   .2848256   .0722656     3.94   0.000     .1431877    .4264635
			ndisease |   .0210805   .0034967     6.03   0.000     .0142271     .027934
			   hlthg |   .0576901    .042799     1.35   0.178    -.0261945    .1415747
			   hlthf |   .2237238   .0814547     2.75   0.006     .0640755    .3833721
			   hlthp |   .7984291   .2048087     3.90   0.000     .3970114    1.199847
			 educdec |    .031499   .0074987     4.20   0.000     .0168018    .0461961
				 age |  -.0006072   .0021064    -0.29   0.773    -.0047357    .0035212
				lfam |   -.031201   .0402985    -0.77   0.439    -.1101846    .0477827
			  female |   .4093059   .0532548     7.69   0.000     .3049283    .5136834
			   child |   .0530643   .0786326     0.67   0.500    -.1010527    .2071813
			femchild |  -.3953421   .0783811    -5.04   0.000    -.5489662    -.241718
			   black |  -.5831049   .0520534   -11.20   0.000    -.6851277   -.4810822
			   _cons |  -.2141574   .1842169    -1.16   0.245    -.5752159     .146901
		-------------+----------------------------------------------------------------
			 /athrho |   .9408188   .0736303    12.78   0.000      .796506    1.085132
			/lnsigma |   .4511091   .0177227    25.45   0.000     .4163732     .485845
		-------------+----------------------------------------------------------------
				 rho |   .7355982   .0337886                      .6620789    .7950943
			   sigma |   1.570053   .0278256                      1.516452    1.625548
			  lambda |   1.154928   .0702985                      1.017145     1.29271
		------------------------------------------------------------------------------
		LR test of indep. eqns. (rho = 0): chi2(1) = 27.93        Prob > chi2 = 0.0000

		. scalar shml = e(sigma )     // standard error of regression 
							
							
							
* Create predictions of level of medical expenditures 
predict yposml, ycond       // predicted mean log medical expenditure for med>0
predict probselml, psel     // predicted probability for med>0
generate predmedposml = exp(yposml+(shml^2)/2) 
generate predmedallml = probselml*predmedposml
* Compare predictions to actual medical expenditures for med > 0
summarize med predmedposml if med > 0 
corr lmed yposml med predmedposml if med > 0

		. summarize med predmedposml if med > 0 

			Variable |        Obs        Mean    Std. dev.       Min        Max
		-------------+---------------------------------------------------------
				 med |      4,281     220.987    909.9021   .5860291   39182.02
		predmedposml |      4,281    240.4096    185.0424   42.00053    3505.48

		. corr lmed yposml med predmedposml if med > 0
		(obs=4,281)

					 |     lmed   yposml      med pred~sml
		-------------+------------------------------------
				lmed |   1.0000
			  yposml |   0.3690   1.0000
				 med |   0.4560   0.1592   1.0000
		predmedposml |   0.3202   0.8915   0.1617   1.0000


* Compare predictions to actual medical expenditures including med = 0
summarize dmed probselml med predmedallml 
corr dmed probselml
corr med predmedallml 

		. summarize dmed probselml med predmedallml 

			Variable |        Obs        Mean    Std. dev.       Min        Max
		-------------+---------------------------------------------------------
				dmed |      5,574    .7680301    .4221277          0          1
		   probselml |      5,574    .7674107    .1404707   .1737047   .9994534
				 med |      5,574    169.7247    802.8303          0   39182.02
		predmedallml |      5,574    184.5571    174.1649   8.814864   3503.564

		. corr dmed probselml
		(obs=5,574)

					 |     dmed probse~l
		-------------+------------------
				dmed |   1.0000
		   probselml |   0.3468   1.0000


		. corr med predmedallml 
		(obs=5,574)

					 |      med pred~lml
		-------------+------------------
				 med |   1.0000
		predmedallml |   0.1734   1.0000

*/

/*Tobit II Model: Two Step Estimation 
heckman lmed $xlist1, select (dmed = $xlist1) twostep first

		. heckman lmed $xlist1, select (dmed = $xlist1) twostep first

		Iteration 0:  Log likelihood = -3019.1326  
		Iteration 1:  Log likelihood =  -2698.302  
		Iteration 2:  Log likelihood = -2690.6146  
		Iteration 3:  Log likelihood = -2690.5768  
		Iteration 4:  Log likelihood = -2690.5768  

		Probit regression                                       Number of obs =  5,574
																LR chi2(17)   = 657.11
																Prob > chi2   = 0.0000
		Log likelihood = -2690.5768                             Pseudo R2     = 0.1088

		------------------------------------------------------------------------------
				dmed | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
		-------------+----------------------------------------------------------------
				linc |   .0518413   .0168128     3.08   0.002     .0188889    .0847938
				  lc |   -.118708   .0269005    -4.41   0.000    -.1714319    -.065984
				 lpi |   .0283091   .0088793     3.19   0.001      .010906    .0457121
				fmde |   .0075319   .0161584     0.47   0.641     -.024138    .0392018
				 idp |  -.1279483   .0522351    -2.45   0.014    -.2303272   -.0255693
			 physlim |   .2732013   .0743761     3.67   0.000     .1274268    .4189758
			ndisease |   .0224861   .0035958     6.25   0.000     .0154384    .0295338
			   hlthg |   .0387516   .0438545     0.88   0.377    -.0472016    .1247049
			   hlthf |   .1920062   .0836688     2.29   0.022     .0280185     .355994
			   hlthp |   .6397294   .2126322     3.01   0.003      .222978    1.056481
			 educdec |    .036307   .0076536     4.74   0.000     .0213062    .0513078
				 age |   .0002631   .0021606     0.12   0.903    -.0039715    .0044978
				lfam |  -.0335599    .041728    -0.80   0.421    -.1153452    .0482253
			  female |   .4451035    .054292     8.20   0.000     .3386932    .5515138
			   child |    .111489   .0808338     1.38   0.168    -.0469424    .2699203
			femchild |  -.4512845   .0799219    -5.65   0.000    -.6079284   -.2946405
			   black |  -.6057367   .0523148   -11.58   0.000    -.7082718   -.5032017
			   _cons |   -.271605   .1877345    -1.45   0.148    -.6395579    .0963478
		------------------------------------------------------------------------------

		Heckman selection model -- two-step estimates   Number of obs     =      5,574
		(regression model with sample selection)              Selected    =      4,281
															  Nonselected =      1,293

														Wald chi2(17)     =     366.05
														Prob > chi2       =     0.0000

		------------------------------------------------------------------------------
					 | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
		-------------+----------------------------------------------------------------
		lmed         |
				linc |   .0990973   .0251548     3.94   0.000     .0497948    .1483998
				  lc |  -.0279209    .039754    -0.70   0.482    -.1058373    .0499955
				 lpi |   .0052225   .0111057     0.47   0.638    -.0165442    .0269893
				fmde |  -.0295212   .0182427    -1.62   0.106    -.0652762    .0062339
				 idp |  -.0922898   .0680191    -1.36   0.175    -.2256048    .0410252
			 physlim |   .2814948   .0804535     3.50   0.000     .1238088    .4391808
			ndisease |    .021617   .0050395     4.29   0.000     .0117398    .0314943
			   hlthg |   .1474026   .0490497     3.01   0.003      .051267    .2435381
			   hlthf |   .3821683   .0961284     3.98   0.000       .19376    .5705765
			   hlthp |    .833294   .1974488     4.22   0.000     .4463015    1.220287
			 educdec |   .0033639   .0109501     0.31   0.759    -.0180979    .0248257
				 age |   .0055556   .0022549     2.46   0.014     .0011361    .0099751
				lfam |  -.1441358   .0468074    -3.08   0.002    -.2358766    -.052395
			  female |   .3846323   .1032799     3.72   0.000     .1822074    .5870573
			   child |  -.2565136   .0936771    -2.74   0.006    -.4401173   -.0729098
			femchild |   -.392146    .125089    -3.13   0.002     -.637316    -.146976
			   black |  -.2633649   .1577542    -1.67   0.095    -.5725574    .0458276
			   _cons |   2.882514   .4698969     6.13   0.000     1.961533    3.803495
		-------------+----------------------------------------------------------------
		dmed         |
				linc |   .0518413   .0168128     3.08   0.002     .0188889    .0847938
				  lc |   -.118708   .0269005    -4.41   0.000    -.1714319    -.065984
				 lpi |   .0283091   .0088793     3.19   0.001      .010906    .0457121
				fmde |   .0075319   .0161584     0.47   0.641     -.024138    .0392018
				 idp |  -.1279483   .0522351    -2.45   0.014    -.2303272   -.0255693
			 physlim |   .2732013   .0743761     3.67   0.000     .1274268    .4189758
			ndisease |   .0224861   .0035958     6.25   0.000     .0154384    .0295338
			   hlthg |   .0387516   .0438545     0.88   0.377    -.0472016    .1247049
			   hlthf |   .1920062   .0836688     2.29   0.022     .0280185     .355994
			   hlthp |   .6397294   .2126322     3.01   0.003      .222978    1.056481
			 educdec |    .036307   .0076536     4.74   0.000     .0213062    .0513078
				 age |   .0002631   .0021606     0.12   0.903    -.0039715    .0044978
				lfam |  -.0335599    .041728    -0.80   0.421    -.1153452    .0482253
			  female |   .4451035    .054292     8.20   0.000     .3386932    .5515138
			   child |    .111489   .0808338     1.38   0.168    -.0469424    .2699203
			femchild |  -.4512845   .0799219    -5.65   0.000    -.6079284   -.2946405
			   black |  -.6057367   .0523148   -11.58   0.000    -.7082718   -.5032017
			   _cons |   -.271605   .1877345    -1.45   0.148    -.6395579    .0963478
		-------------+----------------------------------------------------------------
		/mills       |
			  lambda |   .2358048   .5018117     0.47   0.638    -.7477282    1.219338
		-------------+----------------------------------------------------------------
				 rho |    0.16833
			   sigma |  1.4008246
		------------------------------------------------------------------------------

* Check for possible collinearity problems in two step estimation
predict invmill2s, mills
matrix accum xx = invmill2s $xlist1
matrix xxscaled = corr(xx)
matrix symeigen xxseigvec xxseigval = xxscaled 
scalar rowsxx = rowsof(xx) 
scalar condnum = sqrt(xxseigval[1,1]/xxseigval[1,rowsxx])
* Find the condition number without inverse mills ratio
matrix accum zz = $xlist1 
matrix zzscaled = corr(zz)
matrix symeigen zzseigvec zzseigval = zzscaled 
scalar rowszz = rowsof(zz) 
scalar condnumnoinvmills = sqrt(zzseigval[1,1]/zzseigval[1,rowszz])
* List condition numbers (condition numbers between 30 and 100 indicate 
* strong near-dependency)
scalar list condnum 
scalar list condnumnoinvmills

		. scalar list condnum 
		   condnum =  82.333696

		. scalar list condnumnoinvmills 
		condnumnoinvmills =  36.660119
 
*/