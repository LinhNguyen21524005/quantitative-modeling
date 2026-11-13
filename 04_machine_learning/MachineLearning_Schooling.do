******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
* This Do file illustrates essentials of multiple regression-related 
* machine learning analysis in STATA with an application examining 
* returns to schooling.
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\MachineLearning
                                       // change working directory
									    
use "ReturnsToSchooling.dta"           // Load Data

* smsa76: 1 if lived in smsa (metropolitan area) in 1976 
* nearc2: grew up near 2-year college
* nearc4: grew up near 4-year college 
* nearc4a: grew up near 4-year public college
* nearc4b: grew up near 4-year private college 
* ed76:	education in 1976
* age76: age in 1976
* age762: age76 squared
* daded: father's education (imputed average if missing) 
* nodaded: 1 if father's education imputed
* momed: mother's education
* nomomed: 1 if mother's education imputed
* momdad14:	1 if lived with mother and father at age 14 
* sinmom14: 1 if single mother at age 14
* step14: 1 if step parent at age 14 
* south76: 1 if lived in south in 1976
* wage76: wage in 1976 (raw, cents per hour) 
* lwage76: log wage in 1976 (outliers trimmed) 
* famed: mother-father education class (1-9) 
* black: 1 if black
* enroll76: 1 if enrolled in 1976
* kww: kww score
* iqscore:a normed IQ score
* mar76: marital status in 1976 (1 if married) 
* libcrd14: 1 if library card in home at age 14 
* exp76: experience in 1976
* exp762: exp76 squared

* Define Dependent Variable Lists
global xlistc exp76 kww daded momed
global xlistd mar76 black smsa76 south76
  	   
* Data Description 
summarize lwage76 ed76 $xlistc $xlistd
		 
* OLS Estimation
* Multiple Linear Regression
regress lwage76 ed76 $xlistc $xlistd
permreg lwage76 ed76 $xlistc $xlistd, aic
permreg lwage76 ed76 $xlistc $xlistd, bic
permreg lwage76 $xlistc $xlistd, fixedvars(ed76) bic

* Create Training and Fitting Samples
splitsample lwage76, generate(train) split(1 4) values(0 1) rseed(90210)
* training sample: train = 1
* fitting sample: train = 0
tabulate train

* Prediction Models
* Original Multiple Linear Regression
regress lwage76 ed76 $xlistc $xlistd if train==1
predict y_mlr, xb
* AIC Based Regression
regress lwage76 ed76 exp76 kww momed mar76 black smsa76 south76 if train==1
predict y_aic, xb
* SBIC Based Regression
regress lwage76 ed76 exp76 kww mar76 black smsa76 south76 if train==1
predict y_sbc, xb
* Compare Predictive Performance
foreach var of varlist y_mlr y_aic y_sbc {                          
   quietly generate `var'errorsq1 = (`var'-lwage76)^2                        
   quietly summarize `var'errorsq1 if train == 1                               
   quietly scalar mse`var'train1 = r(mean)                                   
   quietly summarize `var'errorsq1 if train == 0                               
   quietly scalar mse`var'test1 = r(mean)                                    
   display "Predictor: " "`var'" _col(21)                                    ///       
   " Train MSE = " %8.6f mse`var'train1 " Test MSE = " %8.6f mse`var'test1    
   }

* Machine Learning Models
* Create Regressor List With Interacting Variables (Second Order)
global rlist c.($xlistc)##c.($xlistc) i.($xlistd) c.($xlistc)#i.($xlistd)
*  i.: indicator variables
*  c.: continuous variables
*  #: operator to generate interactions
*  ##: operator to specify factorial interactions

* Ridge regression
elasticnet linear lwage76 ed76 $rlist if train==1, alpha(0)
lassoinfo
predict y_ridge, xb
* Lasso regression
lasso linear lwage76 ed76 $rlist if train==1
lassoinfo
predict y_lasso, xb
* Elastic Net regression
elasticnet linear lwage76 ed76 $rlist if train==1
lassoinfo

* Compare Predictive Performance
foreach var of varlist y_mlr y_aic y_sbc y_ridge y_lasso {                          
   quietly generate `var'errorsq2 = (`var'-lwage76)^2                        
   quietly summarize `var'errorsq2 if train == 1                               
   quietly scalar mse`var'train2 = r(mean)                                   
   quietly summarize `var'errorsq2 if train == 0                               
   quietly scalar mse`var'test2 = r(mean)                                    
   display "Predictor: " "`var'" _col(21)                                    ///       
   " Train MSE = " %8.6f mse`var'train2 " Test MSE = " %8.6f mse`var'test2    
   }

 * Partialing Out
 poregress lwage76 ed76, controls($rlist)
 lassoinfo
 
 * Partialing Out for Instrumental Variables
 global ivlist c.(age76)##c.(age76) i.(nearc4 nearc4b) c.(age76)#i.(nearc4 nearc4b)
 poivregress lwage76 (ed76=$ivlist), controls($rlist)
 lassoinfo
 
/*

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_000000.tmp"

. global xlistc exp76 kww daded momed

. global xlistd mar76 black smsa76 south76

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_000001.tmp"

. summarize lwage76 ed76 $xlistc $xlistd

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
     lwage76 |      3,010    6.261832    .4437976    4.60517   7.784889
        ed76 |      3,010    13.26346    2.676913          1         18
       exp76 |      3,010    8.856146    4.141672          0         23
         kww |      2,963    33.54067    8.611619          4         56
       daded |      3,010    9.988904    3.266501          0         18
-------------+---------------------------------------------------------
       momed |      3,010    10.33663     2.98751          0         18
       mar76 |      3,003    2.271395    2.066823          1          6
       black |      3,010    .2335548    .4231624          0          1
      smsa76 |      3,010    .7129568    .4524571          0          1
     south76 |      3,010    .4036545    .4907113          0          1

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_000002.tmp"

. regress lwage76 ed76 $xlistc $xlistd

      Source |       SS           df       MS      Number of obs   =     2,956
-------------+----------------------------------   F(9, 2946)      =    149.39
       Model |  180.322427         9  20.0358253   Prob > F        =    0.0000
    Residual |  395.100539     2,946  .134114236   R-squared       =    0.3134
-------------+----------------------------------   Adj R-squared   =    0.3113
       Total |  575.422966     2,955  .194728584   Root MSE        =    .36622

------------------------------------------------------------------------------
     lwage76 | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        ed76 |   .0525062   .0042927    12.23   0.000     .0440891    .0609232
       exp76 |   .0271614   .0024589    11.05   0.000       .02234    .0319827
         kww |    .007827   .0010937     7.16   0.000     .0056824    .0099716
       daded |  -.0024404   .0025527    -0.96   0.339    -.0074457    .0025649
       momed |   .0054719   .0028125     1.95   0.052    -.0000426    .0109865
       mar76 |  -.0342928   .0034107   -10.05   0.000    -.0409804   -.0276051
       black |  -.1115629   .0189956    -5.87   0.000     -.148809   -.0743168
      smsa76 |   .1613748   .0155083    10.41   0.000     .1309666    .1917829
     south76 |  -.1239598   .0149682    -8.28   0.000    -.1533091   -.0946106
       _cons |   5.069475   .0658705    76.96   0.000     4.940318    5.198632
------------------------------------------------------------------------------

. permreg lwage76 ed76 $xlistc $xlistd, aic
command permreg is unrecognized
r(199);

end of do-file

r(199);

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_000003.tmp"

. permreg lwage76 ed76 $xlistc $xlistd, aic
matsize too small
    You have attempted to create a matrix with too many rows or columns or attempted to fit a model with too many variables.  You need to increase
    matsize; it is currently 400.  Use set matsize; see help matsize.

    If you are using factor variables and included an interaction that has lots of missing cells, try set emptycells drop to reduce the required matrix
    size; see help set emptycells.

    If you are using factor variables, you might have accidentally treated a continuous variable as a categorical, resulting in lots of categories.
    Use the c. operator on such variables.
r(908);

end of do-file

r(908);

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_000004.tmp"

. regress lwage76 ed76 $xlistc $xlistd

      Source |       SS           df       MS      Number of obs   =     2,956
-------------+----------------------------------   F(9, 2946)      =    149.39
       Model |  180.322427         9  20.0358253   Prob > F        =    0.0000
    Residual |  395.100539     2,946  .134114236   R-squared       =    0.3134
-------------+----------------------------------   Adj R-squared   =    0.3113
       Total |  575.422966     2,955  .194728584   Root MSE        =    .36622

------------------------------------------------------------------------------
     lwage76 | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        ed76 |   .0525062   .0042927    12.23   0.000     .0440891    .0609232
       exp76 |   .0271614   .0024589    11.05   0.000       .02234    .0319827
         kww |    .007827   .0010937     7.16   0.000     .0056824    .0099716
       daded |  -.0024404   .0025527    -0.96   0.339    -.0074457    .0025649
       momed |   .0054719   .0028125     1.95   0.052    -.0000426    .0109865
       mar76 |  -.0342928   .0034107   -10.05   0.000    -.0409804   -.0276051
       black |  -.1115629   .0189956    -5.87   0.000     -.148809   -.0743168
      smsa76 |   .1613748   .0155083    10.41   0.000     .1309666    .1917829
     south76 |  -.1239598   .0149682    -8.28   0.000    -.1533091   -.0946106
       _cons |   5.069475   .0658705    76.96   0.000     4.940318    5.198632
------------------------------------------------------------------------------

. permreg lwage76 ed76 $xlistc $xlistd, aic
matsize too small
    You have attempted to create a matrix with too many rows or columns or attempted to fit a model with too many variables.  You need to increase
    matsize; it is currently 400.  Use set matsize; see help matsize.

    If you are using factor variables and included an interaction that has lots of missing cells, try set emptycells drop to reduce the required matrix
    size; see help set emptycells.

    If you are using factor variables, you might have accidentally treated a continuous variable as a categorical, resulting in lots of categories.
    Use the c. operator on such variables.
r(908);

end of do-file

r(908);

. set  matsize 5000
set matsize ignored.
    Matrix sizes are no longer limited by c(matsize) in modern Statas.  Matrix sizes are now limited by edition of Stata.  See limits for more details.

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_000005.tmp"

. permreg lwage76 ed76 $xlistc $xlistd, aic

AIC-based selection of regressors

  # of regressor permutations : 512
  Regressors, always included : 
  Regressors included         : ed76 exp76 kww momed mar76 black smsa76 south76
  Regressors not included     : daded

      Source |       SS           df       MS      Number of obs   =     2,956
-------------+----------------------------------   F(8, 2947)      =    167.96
       Model |  180.199854         8  22.5249818   Prob > F        =    0.0000
    Residual |  395.223112     2,947   .13411032   R-squared       =    0.3132
-------------+----------------------------------   Adj R-squared   =    0.3113
       Total |  575.422966     2,955  .194728584   Root MSE        =    .36621

------------------------------------------------------------------------------
     lwage76 | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        ed76 |   .0521566   .0042771    12.19   0.000     .0437703    .0605429
       exp76 |   .0273238    .002453    11.14   0.000      .022514    .0321335
         kww |   .0077562   .0010912     7.11   0.000     .0056166    .0098959
       momed |   .0043604   .0025608     1.70   0.089    -.0006608    .0093817
       mar76 |  -.0344089   .0034085   -10.09   0.000    -.0410922   -.0277256
       black |  -.1105879    .018968    -5.83   0.000    -.1477796   -.0733961
      smsa76 |   .1605707   .0154852    10.37   0.000     .1302078    .1909337
     south76 |  -.1235146   .0149608    -8.26   0.000    -.1528492     -.09418
       _cons |   5.062596   .0654753    77.32   0.000     4.934214    5.190978
------------------------------------------------------------------------------

. permreg lwage76 ed76 $xlistc $xlistd, bic

BIC-based selection of regressors

  # of regressor permutations : 512
  Regressors, always included : 
  Regressors included         : ed76 exp76 kww mar76 black smsa76 south76
  Regressors not included     : daded momed

      Source |       SS           df       MS      Number of obs   =     2,956
-------------+----------------------------------   F(7, 2948)      =    191.42
       Model |  179.811032         7  25.6872902   Prob > F        =    0.0000
    Residual |  395.611934     2,948  .134196721   R-squared       =    0.3125
-------------+----------------------------------   Adj R-squared   =    0.3109
       Total |  575.422966     2,955  .194728584   Root MSE        =    .36633

------------------------------------------------------------------------------
     lwage76 | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        ed76 |   .0532885   .0042264    12.61   0.000     .0450014    .0615756
       exp76 |   .0269758   .0024453    11.03   0.000     .0221812    .0317704
         kww |   .0079607    .001085     7.34   0.000     .0058334     .010088
       mar76 |  -.0341846   .0034071   -10.03   0.000     -.040865   -.0275041
       black |  -.1146409   .0188241    -6.09   0.000    -.1515505   -.0777312
      smsa76 |    .161289   .0154845    10.42   0.000     .1309275    .1916504
     south76 |  -.1251311   .0149354    -8.38   0.000     -.154416   -.0958461
       _cons |   5.089451   .0635678    80.06   0.000     4.964809    5.214093
------------------------------------------------------------------------------

. permreg lwage76 $xlistc $xlistd, fixedvars(ed76) bic

BIC-based selection of regressors

  # of regressor permutations : 256
  Regressors, always included : ed76
  Regressors included         : exp76 kww mar76 black smsa76 south76
  Regressors not included     : daded momed

      Source |       SS           df       MS      Number of obs   =     2,956
-------------+----------------------------------   F(7, 2948)      =    191.42
       Model |  179.811032         7  25.6872902   Prob > F        =    0.0000
    Residual |  395.611934     2,948  .134196721   R-squared       =    0.3125
-------------+----------------------------------   Adj R-squared   =    0.3109
       Total |  575.422966     2,955  .194728584   Root MSE        =    .36633

------------------------------------------------------------------------------
     lwage76 | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
       exp76 |   .0269758   .0024453    11.03   0.000     .0221812    .0317704
         kww |   .0079607    .001085     7.34   0.000     .0058334     .010088
       mar76 |  -.0341846   .0034071   -10.03   0.000     -.040865   -.0275041
       black |  -.1146409   .0188241    -6.09   0.000    -.1515505   -.0777312
      smsa76 |    .161289   .0154845    10.42   0.000     .1309275    .1916504
     south76 |  -.1251311   .0149354    -8.38   0.000     -.154416   -.0958461
        ed76 |   .0532885   .0042264    12.61   0.000     .0450014    .0615756
       _cons |   5.089451   .0635678    80.06   0.000     4.964809    5.214093
------------------------------------------------------------------------------

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_000006.tmp"

. splitsample lwage76, generate(train) split(1 4) values(0 1) rseed(90210)

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_000007.tmp"

. tabulate train

      train |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        602       20.00       20.00
          1 |      2,408       80.00      100.00
------------+-----------------------------------
      Total |      3,010      100.00

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_000008.tmp"

. * Prediction Models
. * Original Multiple Linear Regression
. regress lwage76 ed76 $xlistc $xlistd if train==1

      Source |       SS           df       MS      Number of obs   =     2,364
-------------+----------------------------------   F(9, 2354)      =    125.81
       Model |  148.439838         9  16.4933153   Prob > F        =    0.0000
    Residual |  308.593501     2,354  .131093246   R-squared       =    0.3248
-------------+----------------------------------   Adj R-squared   =    0.3222
       Total |  457.033339     2,363  .193412331   Root MSE        =    .36207

------------------------------------------------------------------------------
     lwage76 | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        ed76 |    .054636   .0047599    11.48   0.000      .045302      .06397
       exp76 |   .0268197   .0027137     9.88   0.000     .0214982    .0321413
         kww |   .0080531   .0012028     6.70   0.000     .0056944    .0104118
       daded |  -.0013949   .0028062    -0.50   0.619    -.0068978     .004108
       momed |   .0048137   .0030638     1.57   0.116    -.0011943    .0108217
       mar76 |  -.0309719   .0037661    -8.22   0.000    -.0383571   -.0235867
       black |   -.112125   .0210879    -5.32   0.000    -.1534777   -.0707722
      smsa76 |   .1511484   .0171383     8.82   0.000     .1175408    .1847561
     south76 |  -.1361166   .0165723    -8.21   0.000    -.1686143   -.1036188
       _cons |   5.039851   .0724741    69.54   0.000     4.897731     5.18197
------------------------------------------------------------------------------

. predict y_mlr, xb
(54 missing values generated)

. * AIC Based Regression
. regress lwage76 ed76 exp76 kww momed mar76 black smsa76 south76 if train==1

      Source |       SS           df       MS      Number of obs   =     2,364
-------------+----------------------------------   F(8, 2355)      =    141.55
       Model |  148.407446         8  18.5509307   Prob > F        =    0.0000
    Residual |  308.625893     2,355  .131051335   R-squared       =    0.3247
-------------+----------------------------------   Adj R-squared   =    0.3224
       Total |  457.033339     2,363  .193412331   Root MSE        =    .36201

------------------------------------------------------------------------------
     lwage76 | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        ed76 |   .0544021   .0047358    11.49   0.000     .0451153    .0636889
       exp76 |   .0269057   .0027078     9.94   0.000     .0215958    .0322156
         kww |   .0080142   .0012001     6.68   0.000     .0056609    .0103676
       momed |   .0042072   .0028099     1.50   0.134    -.0013029    .0097174
       mar76 |  -.0310079   .0037648    -8.24   0.000    -.0383906   -.0236253
       black |  -.1115668   .0210546    -5.30   0.000    -.1528542   -.0702793
      smsa76 |   .1507184   .0171137     8.81   0.000      .117159    .1842778
     south76 |  -.1359329   .0165655    -8.21   0.000    -.1684174   -.1034484
       _cons |   5.036028   .0720535    69.89   0.000     4.894733    5.177323
------------------------------------------------------------------------------

. predict y_aic, xb
(54 missing values generated)

. * SBIC Based Regression
. regress lwage76 ed76 exp76 kww mar76 black smsa76 south76 if train==1

      Source |       SS           df       MS      Number of obs   =     2,364
-------------+----------------------------------   F(7, 2356)      =    161.37
       Model |  148.113644         7  21.1590919   Prob > F        =    0.0000
    Residual |  308.919695     2,356  .131120414   R-squared       =    0.3241
-------------+----------------------------------   Adj R-squared   =    0.3221
       Total |  457.033339     2,363  .193412331   Root MSE        =    .36211

------------------------------------------------------------------------------
     lwage76 | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        ed76 |   .0555785   .0046714    11.90   0.000      .046418     .064739
       exp76 |   .0265912   .0027003     9.85   0.000     .0212959    .0318865
         kww |   .0082072   .0011934     6.88   0.000     .0058669    .0105475
       mar76 |  -.0307763   .0037626    -8.18   0.000    -.0381547   -.0233979
       black |   -.115195   .0209202    -5.51   0.000    -.1562189   -.0741711
      smsa76 |   .1509776   .0171173     8.82   0.000     .1174111    .1845441
     south76 |  -.1376417   .0165305    -8.33   0.000    -.1700575   -.1052259
       _cons |   5.061039   .0701091    72.19   0.000     4.923557     5.19852
------------------------------------------------------------------------------

. predict y_sbc, xb
(54 missing values generated)

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_000009.tmp"

. * Compare Predictive Performance
. foreach var of varlist y_mlr y_aic y_sbc {                          
  2.    quietly generate `var'errorsq1 = (`var'-lwage76)^2                        
  3.    quietly summarize `var'errorsq1 if train == 1                               
  4.    quietly scalar mse`var'train1 = r(mean)                                   
  5.    quietly summarize `var'errorsq1 if train == 0                               
  6.    quietly scalar mse`var'test1 = r(mean)                                    
  7.    display "Predictor: " "`var'" _col(21)                                    ///       
>    " Train MSE = " %8.6f mse`var'train1 " Test MSE = " %8.6f mse`var'test1    
  8.    }
Predictor: y_mlr     Train MSE = 0.130539 Test MSE = 0.147070
Predictor: y_aic     Train MSE = 0.130552 Test MSE = 0.147190
Predictor: y_sbc     Train MSE = 0.130677 Test MSE = 0.147367

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_00000a.tmp"

. global rlist c.($xlistc)##c.($xlistc) i.($xlistd) c.($xlistc)#i.($xlistd)

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_00000b.tmp"

. elasticnet linear lwage76 ed76 $rlist if train==1, alpha(0)

Evaluating up to 100 lambdas in grid ...
Grid value 1:     lambda = 1.94e+07   no. of nonzero coef. = 75
Grid value 2:     lambda = 176.7445   no. of nonzero coef. = 75
Grid value 3:     lambda =  161.043   no. of nonzero coef. = 75
Grid value 4:     lambda = 146.7364   no. of nonzero coef. = 75
Grid value 5:     lambda = 133.7007   no. of nonzero coef. = 75
Grid value 6:     lambda = 121.8231   no. of nonzero coef. = 75
Grid value 7:     lambda = 111.0007   no. of nonzero coef. = 75
Grid value 8:     lambda = 101.1397   no. of nonzero coef. = 75
Grid value 9:     lambda = 92.15473   no. of nonzero coef. = 75
Grid value 10:    lambda = 83.96796   no. of nonzero coef. = 75
Grid value 11:    lambda = 76.50847   no. of nonzero coef. = 75
Grid value 12:    lambda = 69.71167   no. of nonzero coef. = 75
Grid value 13:    lambda = 63.51868   no. of nonzero coef. = 75
Grid value 14:    lambda = 57.87586   no. of nonzero coef. = 75
Grid value 15:    lambda = 52.73432   no. of nonzero coef. = 75
Grid value 16:    lambda = 48.04955   no. of nonzero coef. = 75
Grid value 17:    lambda = 43.78096   no. of nonzero coef. = 75
Grid value 18:    lambda = 39.89158   no. of nonzero coef. = 75
Grid value 19:    lambda = 36.34772   no. of nonzero coef. = 75
Grid value 20:    lambda = 33.11869   no. of nonzero coef. = 75
Grid value 21:    lambda = 30.17652   no. of nonzero coef. = 75
Grid value 22:    lambda = 27.49572   no. of nonzero coef. = 75
Grid value 23:    lambda = 25.05308   no. of nonzero coef. = 75
Grid value 24:    lambda = 22.82743   no. of nonzero coef. = 75
Grid value 25:    lambda =  20.7995   no. of nonzero coef. = 75
Grid value 26:    lambda = 18.95173   no. of nonzero coef. = 75
Grid value 27:    lambda = 17.26811   no. of nonzero coef. = 75
Grid value 28:    lambda = 15.73406   no. of nonzero coef. = 75
Grid value 29:    lambda = 14.33629   no. of nonzero coef. = 75
Grid value 30:    lambda = 13.06269   no. of nonzero coef. = 75
Grid value 31:    lambda = 11.90224   no. of nonzero coef. = 75
Grid value 32:    lambda = 10.84488   no. of nonzero coef. = 75
Grid value 33:    lambda = 9.881449   no. of nonzero coef. = 75
Grid value 34:    lambda = 9.003609   no. of nonzero coef. = 75
Grid value 35:    lambda = 8.203753   no. of nonzero coef. = 75
Grid value 36:    lambda = 7.474954   no. of nonzero coef. = 75
Grid value 37:    lambda =   6.8109   no. of nonzero coef. = 75
Grid value 38:    lambda = 6.205838   no. of nonzero coef. = 75
Grid value 39:    lambda = 5.654529   no. of nonzero coef. = 75
Grid value 40:    lambda = 5.152196   no. of nonzero coef. = 75
Grid value 41:    lambda = 4.694489   no. of nonzero coef. = 75
Grid value 42:    lambda = 4.277444   no. of nonzero coef. = 75
Grid value 43:    lambda = 3.897447   no. of nonzero coef. = 75
Grid value 44:    lambda = 3.551209   no. of nonzero coef. = 75
Grid value 45:    lambda = 3.235729   no. of nonzero coef. = 75
Grid value 46:    lambda = 2.948276   no. of nonzero coef. = 75
Grid value 47:    lambda = 2.686359   no. of nonzero coef. = 75
Grid value 48:    lambda =  2.44771   no. of nonzero coef. = 75
Grid value 49:    lambda = 2.230263   no. of nonzero coef. = 75
Grid value 50:    lambda = 2.032132   no. of nonzero coef. = 75
Grid value 51:    lambda = 1.851603   no. of nonzero coef. = 75
Grid value 52:    lambda = 1.687112   no. of nonzero coef. = 75
Grid value 53:    lambda = 1.537234   no. of nonzero coef. = 75
Grid value 54:    lambda =  1.40067   no. of nonzero coef. = 75
Grid value 55:    lambda = 1.276238   no. of nonzero coef. = 75
Grid value 56:    lambda = 1.162861   no. of nonzero coef. = 75
Grid value 57:    lambda = 1.059555   no. of nonzero coef. = 75
Grid value 58:    lambda = .9654275   no. of nonzero coef. = 75
Grid value 59:    lambda = .8796615   no. of nonzero coef. = 75
Grid value 60:    lambda = .8015148   no. of nonzero coef. = 75
Grid value 61:    lambda = .7303105   no. of nonzero coef. = 75
Grid value 62:    lambda = .6654317   no. of nonzero coef. = 75
Grid value 63:    lambda = .6063166   no. of nonzero coef. = 75
Grid value 64:    lambda = .5524531   no. of nonzero coef. = 75
Grid value 65:    lambda = .5033747   no. of nonzero coef. = 75
Grid value 66:    lambda = .4586563   no. of nonzero coef. = 75
Grid value 67:    lambda = .4179105   no. of nonzero coef. = 75
Grid value 68:    lambda = .3807845   no. of nonzero coef. = 75
Grid value 69:    lambda = .3469566   no. of nonzero coef. = 75
Grid value 70:    lambda =  .316134   no. of nonzero coef. = 75
Grid value 71:    lambda = .2880495   no. of nonzero coef. = 75
Grid value 72:    lambda =   .26246   no. of nonzero coef. = 75
Grid value 73:    lambda = .2391438   no. of nonzero coef. = 75
Grid value 74:    lambda = .2178989   no. of nonzero coef. = 75
Grid value 75:    lambda = .1985413   no. of nonzero coef. = 75
Grid value 76:    lambda = .1809035   no. of nonzero coef. = 75
Grid value 77:    lambda = .1648325   no. of nonzero coef. = 75
Grid value 78:    lambda = .1501892   no. of nonzero coef. = 75
Grid value 79:    lambda = .1368468   no. of nonzero coef. = 75
Grid value 80:    lambda = .1246898   no. of nonzero coef. = 75
Grid value 81:    lambda = .1136127   no. of nonzero coef. = 75
Grid value 82:    lambda = .1035196   no. of nonzero coef. = 75
Grid value 83:    lambda = .0943232   no. of nonzero coef. = 75
Grid value 84:    lambda = .0859438   no. of nonzero coef. = 75
Grid value 85:    lambda = .0783088   no. of nonzero coef. = 75
Grid value 86:    lambda = .0713521   no. of nonzero coef. = 75
Grid value 87:    lambda = .0650133   no. of nonzero coef. = 75
Grid value 88:    lambda = .0592377   no. of nonzero coef. = 75
Grid value 89:    lambda = .0539752   no. of nonzero coef. = 75
Grid value 90:    lambda = .0491802   no. of nonzero coef. = 75
Grid value 91:    lambda = .0448112   no. of nonzero coef. = 75
Grid value 92:    lambda = .0408303   no. of nonzero coef. = 75
Grid value 93:    lambda =  .037203   no. of nonzero coef. = 75
Grid value 94:    lambda =  .033898   no. of nonzero coef. = 75
Grid value 95:    lambda = .0308866   no. of nonzero coef. = 75
Grid value 96:    lambda = .0281427   no. of nonzero coef. = 75
Grid value 97:    lambda = .0256426   no. of nonzero coef. = 75
Grid value 98:    lambda = .0233646   no. of nonzero coef. = 75
Grid value 99:    lambda = .0212889   no. of nonzero coef. = 75
Grid value 100:   lambda = .0193977   no. of nonzero coef. = 75

10-fold cross-validation with 100 lambdas ...
Fold  1 of 10:  10....20....30....40....50....60....70....80....90....100
Fold  2 of 10:  10....20....30....40....50....60....70....80....90....100
Fold  3 of 10:  10....20....30....40....50....60....70....80....90....100
Fold  4 of 10:  10....20....30....40....50....60....70....80....90....100
Fold  5 of 10:  10....20....30....40....50....60....70....80....90....100
Fold  6 of 10:  10....20....30....40....50....60....70....80....90....100
Fold  7 of 10:  10....20....30....40....50....60....70....80....90....100
Fold  8 of 10:  10....20....30....40....50....60....70....80....90....100
Fold  9 of 10:  10....20....30....40....50....60....70....80....90....100
Fold 10 of 10:  10....20....30....40....50....60....70....80....90....100
... cross-validation complete

Elastic net linear model                         No. of obs        =      2,364
                                                 No. of covariates =         75
Selection: Cross-validation                      No. of CV folds   =         10

-------------------------------------------------------------------------------
               |                               No. of      Out-of-      CV mean
               |                              nonzero       sample   prediction
alpha       ID |     Description      lambda    coef.    R-squared        error
---------------+---------------------------------------------------------------
0.000          |
             1 |    first lambda    193.9769       75      -0.0006      .193456
            87 |   lambda before    .0650133       75       0.3220     .1310821
          * 88 | selected lambda    .0592377       75       0.3220     .1310813
            89 |    lambda after    .0539752       75       0.3220      .131084
           100 |     last lambda    .0193977       75       0.3211     .1312561
-------------------------------------------------------------------------------
* alpha and lambda selected by cross-validation.

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_00000c.tmp"

. lassoinfo

    Estimate: active
     Command: elasticnet
---------------------------------------------------------------------------
            |                                                        No. of
  Dependent |           Selection  Selection                       selected
   variable |    Model     method  criterion     alpha    lambda  variables
------------+--------------------------------------------------------------
    lwage76 |   linear         cv    CV min.     0.000  .0592377         75
---------------------------------------------------------------------------

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_00000d.tmp"

. predict y_ridge, xb
(option penalized assumed; linear prediction with penalized coefficients)

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_00000e.tmp"

. * Lasso regression
. lasso linear lwage76 ed76 $rlist if train==1

10-fold cross-validation with 100 lambdas ...
Grid value 1:     lambda = .1939769   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1930747
Grid value 2:     lambda = .1767445   no. of nonzero coef. =  1
Folds: 1...5....10   CVF = .1872537
Grid value 3:     lambda =  .161043   no. of nonzero coef. =  1
Folds: 1...5....10   CVF = .1819406
Grid value 4:     lambda = .1467364   no. of nonzero coef. =  1
Folds: 1...5....10   CVF = .1775296
Grid value 5:     lambda = .1337007   no. of nonzero coef. =  2
Folds: 1...5....10   CVF = .1737888
Grid value 6:     lambda = .1218231   no. of nonzero coef. =  3
Folds: 1...5....10   CVF = .1701537
Grid value 7:     lambda = .1110007   no. of nonzero coef. =  3
Folds: 1...5....10   CVF = .1665078
Grid value 8:     lambda = .1011397   no. of nonzero coef. =  5
Folds: 1...5....10   CVF = .1629228
Grid value 9:     lambda = .0921547   no. of nonzero coef. =  7
Folds: 1...5....10   CVF = .1589512
Grid value 10:    lambda =  .083968   no. of nonzero coef. =  6
Folds: 1...5....10   CVF = .1546132
Grid value 11:    lambda = .0765085   no. of nonzero coef. =  7
Folds: 1...5....10   CVF = .1510149
Grid value 12:    lambda = .0697117   no. of nonzero coef. =  7
Folds: 1...5....10   CVF =  .148073
Grid value 13:    lambda = .0635187   no. of nonzero coef. =  7
Folds: 1...5....10   CVF = .1456679
Grid value 14:    lambda = .0578759   no. of nonzero coef. =  7
Folds: 1...5....10   CVF =  .143664
Grid value 15:    lambda = .0527343   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1418931
Grid value 16:    lambda = .0480496   no. of nonzero coef. =  9
Folds: 1...5....10   CVF = .1402947
Grid value 17:    lambda =  .043781   no. of nonzero coef. =  9
Folds: 1...5....10   CVF = .1388672
Grid value 18:    lambda = .0398916   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1376253
Grid value 19:    lambda = .0363477   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1365089
Grid value 20:    lambda = .0331187   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1355087
Grid value 21:    lambda = .0301765   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1346424
Grid value 22:    lambda = .0274957   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1339126
Grid value 23:    lambda = .0250531   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1333182
Grid value 24:    lambda = .0228274   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1328245
Grid value 25:    lambda = .0207995   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1324204
Grid value 26:    lambda = .0189517   no. of nonzero coef. =  9
Folds: 1...5....10   CVF = .1320873
Grid value 27:    lambda = .0172681   no. of nonzero coef. =  9
Folds: 1...5....10   CVF = .1318435
Grid value 28:    lambda = .0157341   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1316531
Grid value 29:    lambda = .0143363   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1315082
Grid value 30:    lambda = .0130627   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1313938
Grid value 31:    lambda = .0119022   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1313146
Grid value 32:    lambda = .0108449   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1312661
Grid value 33:    lambda = .0098814   no. of nonzero coef. = 14
Folds: 1...5....10   CVF = .1312225
Grid value 34:    lambda = .0090036   no. of nonzero coef. = 14
Folds: 1...5....10   CVF = .1311847
Grid value 35:    lambda = .0082038   no. of nonzero coef. = 15
Folds: 1...5....10   CVF = .1311349
Grid value 36:    lambda =  .007475   no. of nonzero coef. = 15
Folds: 1...5....10   CVF = .1310964
Grid value 37:    lambda = .0068109   no. of nonzero coef. = 15
Folds: 1...5....10   CVF = .1310525
Grid value 38:    lambda = .0062058   no. of nonzero coef. = 17
Folds: 1...5....10   CVF = .1310131
Grid value 39:    lambda = .0056545   no. of nonzero coef. = 19
Folds: 1...5....10   CVF = .1309835
Grid value 40:    lambda = .0051522   no. of nonzero coef. = 21
Folds: 1...5....10   CVF = .1309519
Grid value 41:    lambda = .0046945   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1309281
Grid value 42:    lambda = .0042774   no. of nonzero coef. = 20
Folds: 1...5....10   CVF = .1309125
Grid value 43:    lambda = .0038974   no. of nonzero coef. = 19
Folds: 1...5....10   CVF = .1309041
Grid value 44:    lambda = .0035512   no. of nonzero coef. = 21
Folds: 1...5....10   CVF =    .1309
Grid value 45:    lambda = .0032357   no. of nonzero coef. = 21
Folds: 1...5....10   CVF = .1309019
Grid value 46:    lambda = .0029483   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1309111
Grid value 47:    lambda = .0026864   no. of nonzero coef. = 21
Folds: 1...5....10   CVF = .1309217
Grid value 48:    lambda = .0024477   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1309512
Grid value 49:    lambda = .0022303   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1310109
Grid value 50:    lambda = .0020321   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1310742
Grid value 51:    lambda = .0018516   no. of nonzero coef. = 24
Folds: 1...5....10   CVF =  .131132
Grid value 52:    lambda = .0016871   no. of nonzero coef. = 28
Folds: 1...5....10   CVF = .1311944
... cross-validation complete ... minimum found

Lasso linear model                          No. of obs        =      2,364
                                            No. of covariates =         75
Selection: Cross-validation                 No. of CV folds   =         10

--------------------------------------------------------------------------
         |                                No. of      Out-of-      CV mean
         |                               nonzero       sample   prediction
      ID |     Description      lambda     coef.    R-squared        error
---------+----------------------------------------------------------------
       1 |    first lambda    .1939769         0       0.0013     .1930747
      43 |   lambda before    .0038974        19       0.3229     .1309041
    * 44 | selected lambda    .0035512        21       0.3229        .1309
      45 |    lambda after    .0032357        21       0.3229     .1309019
      52 |     last lambda    .0016871        28       0.3214     .1311944
--------------------------------------------------------------------------
* lambda selected by cross-validation.

. lassoinfo

    Estimate: active
     Command: lasso
-----------------------------------------------------------------
            |                                              No. of
  Dependent |           Selection  Selection             selected
   variable |    Model     method  criterion    lambda  variables
------------+----------------------------------------------------
    lwage76 |   linear         cv    CV min.  .0035512         21
-----------------------------------------------------------------

. predict y_lasso, xb
(option penalized assumed; linear prediction with penalized coefficients)

. * Elastic Net regression
. elasticnet linear lwage76 ed76 $rlist if train==1

alpha 1 of 3: alpha = 1

10-fold cross-validation with 109 lambdas ...
Grid value 1:     lambda = .3879537   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 2:     lambda =  .353489   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 3:     lambda =  .322086   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 4:     lambda = .2934728   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 5:     lambda = .2674015   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 6:     lambda = .2586358   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 7:     lambda = .2356593   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 8:     lambda =  .214724   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 9:     lambda = .1956485   no. of nonzero coef. =  0
Folds: 1...5....10   CVF =  .193324
Grid value 10:    lambda = .1939769   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1931555
Grid value 11:    lambda = .1767445   no. of nonzero coef. =  1
Folds: 1...5....10   CVF = .1872689
Grid value 12:    lambda =  .161043   no. of nonzero coef. =  1
Folds: 1...5....10   CVF = .1819613
Grid value 13:    lambda = .1467364   no. of nonzero coef. =  1
Folds: 1...5....10   CVF = .1775553
Grid value 14:    lambda = .1337007   no. of nonzero coef. =  2
Folds: 1...5....10   CVF = .1738653
Grid value 15:    lambda = .1218231   no. of nonzero coef. =  3
Folds: 1...5....10   CVF = .1702905
Grid value 16:    lambda = .1110007   no. of nonzero coef. =  3
Folds: 1...5....10   CVF = .1667071
Grid value 17:    lambda = .1011397   no. of nonzero coef. =  5
Folds: 1...5....10   CVF = .1631292
Grid value 18:    lambda = .0921547   no. of nonzero coef. =  7
Folds: 1...5....10   CVF = .1590813
Grid value 19:    lambda =  .083968   no. of nonzero coef. =  6
Folds: 1...5....10   CVF = .1548446
Grid value 20:    lambda = .0765085   no. of nonzero coef. =  7
Folds: 1...5....10   CVF = .1512282
Grid value 21:    lambda = .0697117   no. of nonzero coef. =  7
Folds: 1...5....10   CVF = .1483144
Grid value 22:    lambda = .0635187   no. of nonzero coef. =  7
Folds: 1...5....10   CVF = .1459042
Grid value 23:    lambda = .0578759   no. of nonzero coef. =  7
Folds: 1...5....10   CVF = .1439092
Grid value 24:    lambda = .0527343   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1421313
Grid value 25:    lambda = .0480496   no. of nonzero coef. =  9
Folds: 1...5....10   CVF = .1404343
Grid value 26:    lambda =  .043781   no. of nonzero coef. =  9
Folds: 1...5....10   CVF = .1389716
Grid value 27:    lambda = .0398916   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1376706
Grid value 28:    lambda = .0363477   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1365258
Grid value 29:    lambda = .0331187   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1355329
Grid value 30:    lambda = .0301765   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1347072
Grid value 31:    lambda = .0274957   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1340109
Grid value 32:    lambda = .0250531   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1334281
Grid value 33:    lambda = .0228274   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1329439
Grid value 34:    lambda = .0207995   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1325407
Grid value 35:    lambda = .0189517   no. of nonzero coef. =  9
Folds: 1...5....10   CVF = .1322069
Grid value 36:    lambda = .0172681   no. of nonzero coef. =  9
Folds: 1...5....10   CVF =  .131945
Grid value 37:    lambda = .0157341   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1317429
Grid value 38:    lambda = .0143363   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1315946
Grid value 39:    lambda = .0130627   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1314912
Grid value 40:    lambda = .0119022   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1314133
Grid value 41:    lambda = .0108449   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1313524
Grid value 42:    lambda = .0098814   no. of nonzero coef. = 14
Folds: 1...5....10   CVF = .1312947
Grid value 43:    lambda = .0090036   no. of nonzero coef. = 14
Folds: 1...5....10   CVF = .1312519
Grid value 44:    lambda = .0082038   no. of nonzero coef. = 15
Folds: 1...5....10   CVF = .1311891
Grid value 45:    lambda =  .007475   no. of nonzero coef. = 15
Folds: 1...5....10   CVF = .1311415
Grid value 46:    lambda = .0068109   no. of nonzero coef. = 15
Folds: 1...5....10   CVF = .1311127
Grid value 47:    lambda = .0062058   no. of nonzero coef. = 17
Folds: 1...5....10   CVF = .1310863
Grid value 48:    lambda = .0056545   no. of nonzero coef. = 19
Folds: 1...5....10   CVF = .1310618
Grid value 49:    lambda = .0051522   no. of nonzero coef. = 21
Folds: 1...5....10   CVF = .1310448
Grid value 50:    lambda = .0046945   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1310307
Grid value 51:    lambda = .0042774   no. of nonzero coef. = 20
Folds: 1...5....10   CVF =  .131009
Grid value 52:    lambda = .0038974   no. of nonzero coef. = 19
Folds: 1...5....10   CVF = .1309886
Grid value 53:    lambda = .0035512   no. of nonzero coef. = 21
Folds: 1...5....10   CVF = .1309767
Grid value 54:    lambda = .0032357   no. of nonzero coef. = 21
Folds: 1...5....10   CVF = .1309739
Grid value 55:    lambda = .0029483   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1309685
Grid value 56:    lambda = .0026864   no. of nonzero coef. = 21
Folds: 1...5....10   CVF = .1309658
Grid value 57:    lambda = .0024477   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1309825
Grid value 58:    lambda = .0022303   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1310073
Grid value 59:    lambda = .0020321   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1310451
Grid value 60:    lambda = .0018516   no. of nonzero coef. = 24
Folds: 1...5....10   CVF = .1311009
Grid value 61:    lambda = .0016871   no. of nonzero coef. = 28
Folds: 1...5....10   CVF = .1311558
Grid value 62:    lambda = .0015372   no. of nonzero coef. = 28
Folds: 1...5....10   CVF = .1312124
... cross-validation complete ... minimum found

alpha 2 of 3: alpha = 0.75

10-fold cross-validation with 109 lambdas ...
Grid value 1:     lambda = .3879537   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 2:     lambda =  .353489   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 3:     lambda =  .322086   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 4:     lambda = .2934728   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 5:     lambda = .2674015   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1935093
Grid value 6:     lambda = .2586358   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1931767
Grid value 7:     lambda = .2356593   no. of nonzero coef. =  1
Folds: 1...5....10   CVF = .1875987
Grid value 8:     lambda =  .214724   no. of nonzero coef. =  2
Folds: 1...5....10   CVF = .1824445
Grid value 9:     lambda = .1956485   no. of nonzero coef. =  2
Folds: 1...5....10   CVF = .1780553
Grid value 10:    lambda = .1939769   no. of nonzero coef. =  2
Folds: 1...5....10   CVF = .1776864
Grid value 11:    lambda = .1767445   no. of nonzero coef. =  3
Folds: 1...5....10   CVF = .1739197
Grid value 12:    lambda =  .161043   no. of nonzero coef. =  4
Folds: 1...5....10   CVF = .1702046
Grid value 13:    lambda = .1467364   no. of nonzero coef. =  5
Folds: 1...5....10   CVF = .1665627
Grid value 14:    lambda = .1337007   no. of nonzero coef. =  6
Folds: 1...5....10   CVF = .1628645
Grid value 15:    lambda = .1218231   no. of nonzero coef. =  8
Folds: 1...5....10   CVF = .1587655
Grid value 16:    lambda = .1110007   no. of nonzero coef. =  8
Folds: 1...5....10   CVF = .1546432
Grid value 17:    lambda = .1011397   no. of nonzero coef. =  7
Folds: 1...5....10   CVF =  .151123
Grid value 18:    lambda = .0921547   no. of nonzero coef. =  7
Folds: 1...5....10   CVF = .1482687
Grid value 19:    lambda =  .083968   no. of nonzero coef. =  7
Folds: 1...5....10   CVF =  .145905
Grid value 20:    lambda = .0765085   no. of nonzero coef. =  8
Folds: 1...5....10   CVF = .1439299
Grid value 21:    lambda = .0697117   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1421199
Grid value 22:    lambda = .0635187   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1404424
Grid value 23:    lambda = .0578759   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1389921
Grid value 24:    lambda = .0527343   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1376939
Grid value 25:    lambda = .0480496   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1365493
Grid value 26:    lambda =  .043781   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1355757
Grid value 27:    lambda = .0398916   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1347602
Grid value 28:    lambda = .0363477   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1340769
Grid value 29:    lambda = .0331187   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1335056
Grid value 30:    lambda = .0301765   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1330294
Grid value 31:    lambda = .0274957   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1326304
Grid value 32:    lambda = .0250531   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1323023
Grid value 33:    lambda = .0228274   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1320438
Grid value 34:    lambda = .0207995   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1318359
Grid value 35:    lambda = .0189517   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1316775
Grid value 36:    lambda = .0172681   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1315611
Grid value 37:    lambda = .0157341   no. of nonzero coef. = 13
Folds: 1...5....10   CVF = .1314727
Grid value 38:    lambda = .0143363   no. of nonzero coef. = 15
Folds: 1...5....10   CVF = .1314014
Grid value 39:    lambda = .0130627   no. of nonzero coef. = 15
Folds: 1...5....10   CVF = .1313343
Grid value 40:    lambda = .0119022   no. of nonzero coef. = 16
Folds: 1...5....10   CVF = .1312786
Grid value 41:    lambda = .0108449   no. of nonzero coef. = 16
Folds: 1...5....10   CVF = .1312126
Grid value 42:    lambda = .0098814   no. of nonzero coef. = 17
Folds: 1...5....10   CVF = .1311574
Grid value 43:    lambda = .0090036   no. of nonzero coef. = 19
Folds: 1...5....10   CVF = .1311193
Grid value 44:    lambda = .0082038   no. of nonzero coef. = 18
Folds: 1...5....10   CVF = .1310879
Grid value 45:    lambda =  .007475   no. of nonzero coef. = 20
Folds: 1...5....10   CVF = .1310621
Grid value 46:    lambda = .0068109   no. of nonzero coef. = 24
Folds: 1...5....10   CVF = .1310448
Grid value 47:    lambda = .0062058   no. of nonzero coef. = 25
Folds: 1...5....10   CVF = .1310301
Grid value 48:    lambda = .0056545   no. of nonzero coef. = 23
Folds: 1...5....10   CVF = .1310124
Grid value 49:    lambda = .0051522   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1309954
Grid value 50:    lambda = .0046945   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1309843
Grid value 51:    lambda = .0042774   no. of nonzero coef. = 23
Folds: 1...5....10   CVF = .1309845
Grid value 52:    lambda = .0038974   no. of nonzero coef. = 24
Folds: 1...5....10   CVF = .1309808
Grid value 53:    lambda = .0035512   no. of nonzero coef. = 23
Folds: 1...5....10   CVF = .1309805
Grid value 54:    lambda = .0032357   no. of nonzero coef. = 24
Folds: 1...5....10   CVF = .1309948
Grid value 55:    lambda = .0029483   no. of nonzero coef. = 24
Folds: 1...5....10   CVF = .1310208
Grid value 56:    lambda = .0026864   no. of nonzero coef. = 24
Folds: 1...5....10   CVF = .1310635
Grid value 57:    lambda = .0024477   no. of nonzero coef. = 26
Folds: 1...5....10   CVF = .1311184
Grid value 58:    lambda = .0022303   no. of nonzero coef. = 30
Folds: 1...5....10   CVF = .1311744
Grid value 59:    lambda = .0020321   no. of nonzero coef. = 30
Folds: 1...5....10   CVF = .1312296
... cross-validation complete ... minimum found

alpha 3 of 3: alpha = 0.5

10-fold cross-validation with 109 lambdas ...
Grid value 1:     lambda = .3879537   no. of nonzero coef. =  0
Folds: 1...5....10   CVF = .1932124
Grid value 2:     lambda =  .353489   no. of nonzero coef. =  2
Folds: 1...5....10   CVF = .1880077
Grid value 3:     lambda =  .322086   no. of nonzero coef. =  2
Folds: 1...5....10   CVF = .1829683
Grid value 4:     lambda = .2934728   no. of nonzero coef. =  2
Folds: 1...5....10   CVF = .1786743
Grid value 5:     lambda = .2674015   no. of nonzero coef. =  3
Folds: 1...5....10   CVF = .1747136
Grid value 6:     lambda = .2586358   no. of nonzero coef. =  3
Folds: 1...5....10   CVF = .1733467
Grid value 7:     lambda = .2356593   no. of nonzero coef. =  4
Folds: 1...5....10   CVF = .1695968
Grid value 8:     lambda =  .214724   no. of nonzero coef. =  5
Folds: 1...5....10   CVF = .1658885
Grid value 9:     lambda = .1956485   no. of nonzero coef. =  8
Folds: 1...5....10   CVF = .1620142
Grid value 10:    lambda = .1939769   no. of nonzero coef. =  8
Folds: 1...5....10   CVF = .1616487
Grid value 11:    lambda = .1767445   no. of nonzero coef. =  8
Folds: 1...5....10   CVF = .1575498
Grid value 12:    lambda =  .161043   no. of nonzero coef. =  8
Folds: 1...5....10   CVF = .1537607
Grid value 13:    lambda = .1467364   no. of nonzero coef. =  9
Folds: 1...5....10   CVF = .1505456
Grid value 14:    lambda = .1337007   no. of nonzero coef. =  8
Folds: 1...5....10   CVF = .1478353
Grid value 15:    lambda = .1218231   no. of nonzero coef. =  8
Folds: 1...5....10   CVF =  .145595
Grid value 16:    lambda = .1110007   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1436401
Grid value 17:    lambda = .1011397   no. of nonzero coef. = 10
Folds: 1...5....10   CVF = .1418211
Grid value 18:    lambda = .0921547   no. of nonzero coef. = 11
Folds: 1...5....10   CVF = .1402155
Grid value 19:    lambda =  .083968   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1387914
Grid value 20:    lambda = .0765085   no. of nonzero coef. = 12
Folds: 1...5....10   CVF =  .137532
Grid value 21:    lambda = .0697117   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1364327
Grid value 22:    lambda = .0635187   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1355026
Grid value 23:    lambda = .0578759   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1347216
Grid value 24:    lambda = .0527343   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1340681
Grid value 25:    lambda = .0480496   no. of nonzero coef. = 12
Folds: 1...5....10   CVF =   .13352
Grid value 26:    lambda =  .043781   no. of nonzero coef. = 13
Folds: 1...5....10   CVF = .1330623
Grid value 27:    lambda = .0398916   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1326888
Grid value 28:    lambda = .0363477   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1323808
Grid value 29:    lambda = .0331187   no. of nonzero coef. = 12
Folds: 1...5....10   CVF = .1321292
Grid value 30:    lambda = .0301765   no. of nonzero coef. = 13
Folds: 1...5....10   CVF = .1319323
Grid value 31:    lambda = .0274957   no. of nonzero coef. = 13
Folds: 1...5....10   CVF = .1317828
Grid value 32:    lambda = .0250531   no. of nonzero coef. = 14
Folds: 1...5....10   CVF = .1316599
Grid value 33:    lambda = .0228274   no. of nonzero coef. = 16
Folds: 1...5....10   CVF = .1315582
Grid value 34:    lambda = .0207995   no. of nonzero coef. = 16
Folds: 1...5....10   CVF = .1314715
Grid value 35:    lambda = .0189517   no. of nonzero coef. = 16
Folds: 1...5....10   CVF = .1313926
Grid value 36:    lambda = .0172681   no. of nonzero coef. = 18
Folds: 1...5....10   CVF = .1313256
Grid value 37:    lambda = .0157341   no. of nonzero coef. = 19
Folds: 1...5....10   CVF = .1312537
Grid value 38:    lambda = .0143363   no. of nonzero coef. = 20
Folds: 1...5....10   CVF = .1311923
Grid value 39:    lambda = .0130627   no. of nonzero coef. = 21
Folds: 1...5....10   CVF = .1311491
Grid value 40:    lambda = .0119022   no. of nonzero coef. = 21
Folds: 1...5....10   CVF = .1311193
Grid value 41:    lambda = .0108449   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1310897
Grid value 42:    lambda = .0098814   no. of nonzero coef. = 25
Folds: 1...5....10   CVF =  .131065
Grid value 43:    lambda = .0090036   no. of nonzero coef. = 25
Folds: 1...5....10   CVF = .1310485
Grid value 44:    lambda = .0082038   no. of nonzero coef. = 25
Folds: 1...5....10   CVF = .1310328
Grid value 45:    lambda =  .007475   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1310142
Grid value 46:    lambda = .0068109   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1310046
Grid value 47:    lambda = .0062058   no. of nonzero coef. = 22
Folds: 1...5....10   CVF = .1310039
Grid value 48:    lambda = .0056545   no. of nonzero coef. = 23
Folds: 1...5....10   CVF = .1309999
Grid value 49:    lambda = .0051522   no. of nonzero coef. = 24
Folds: 1...5....10   CVF = .1309975
Grid value 50:    lambda = .0046945   no. of nonzero coef. = 24
Folds: 1...5....10   CVF = .1310109
Grid value 51:    lambda = .0042774   no. of nonzero coef. = 24
Folds: 1...5....10   CVF = .1310389
Grid value 52:    lambda = .0038974   no. of nonzero coef. = 25
Folds: 1...5....10   CVF = .1310889
Grid value 53:    lambda = .0035512   no. of nonzero coef. = 28
Folds: 1...5....10   CVF = .1311377
Grid value 54:    lambda = .0032357   no. of nonzero coef. = 30
Folds: 1...5....10   CVF = .1311909
Grid value 55:    lambda = .0029483   no. of nonzero coef. = 32
Folds: 1...5....10   CVF = .1312362
... cross-validation complete ... minimum found

Elastic net linear model                         No. of obs        =      2,364
                                                 No. of covariates =         75
Selection: Cross-validation                      No. of CV folds   =         10

-------------------------------------------------------------------------------
               |                               No. of      Out-of-      CV mean
               |                              nonzero       sample   prediction
alpha       ID |     Description      lambda    coef.    R-squared        error
---------------+---------------------------------------------------------------
1.000          |
             1 |    first lambda    .3879537        0      -0.0009     .1935093
            55 |   lambda before    .0029483       22       0.3226     .1309685
          * 56 | selected lambda    .0026864       21       0.3226     .1309658
            57 |    lambda after    .0024477       22       0.3225     .1309825
            62 |     last lambda    .0015372       28       0.3213     .1312124
---------------+---------------------------------------------------------------
0.750          |
            63 |    first lambda    .3879537        0      -0.0009     .1935093
           121 |     last lambda    .0020321       30       0.3212     .1312296
---------------+---------------------------------------------------------------
0.500          |
           122 |    first lambda    .3879537        0       0.0006     .1932124
           176 |     last lambda    .0029483       32       0.3212     .1312362
-------------------------------------------------------------------------------
* alpha and lambda selected by cross-validation.

. lassoinfo

    Estimate: active
     Command: elasticnet
---------------------------------------------------------------------------
            |                                                        No. of
  Dependent |           Selection  Selection                       selected
   variable |    Model     method  criterion     alpha    lambda  variables
------------+--------------------------------------------------------------
    lwage76 |   linear         cv    CV min.     1.000  .0026864         21
---------------------------------------------------------------------------

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_00000f.tmp"

. * Compare Predictive Performance
. foreach var of varlist y_mlr y_aic y_sbc y_ridge y_lasso {                          
  2.    quietly generate `var'errorsq2 = (`var'-lwage76)^2                        
  3.    quietly summarize `var'errorsq2 if train == 1                               
  4.    quietly scalar mse`var'train2 = r(mean)                                   
  5.    quietly summarize `var'errorsq2 if train == 0                               
  6.    quietly scalar mse`var'test2 = r(mean)                                    
  7.    display "Predictor: " "`var'" _col(21)                                    ///       
>    " Train MSE = " %8.6f mse`var'train2 " Test MSE = " %8.6f mse`var'test2    
  8.    }
Predictor: y_mlr     Train MSE = 0.130539 Test MSE = 0.147070
Predictor: y_aic     Train MSE = 0.130552 Test MSE = 0.147190
Predictor: y_sbc     Train MSE = 0.130677 Test MSE = 0.147367
Predictor: y_ridge   Train MSE = 0.127824 Test MSE = 0.146241
Predictor: y_lasso   Train MSE = 0.128300 Test MSE = 0.146420

. 
end of do-file

. do "C:\Users\LINHNG~1\AppData\Local\Temp\STD6cd0_00000g.tmp"

.  * Partialing Out
.  poregress lwage76 ed76, controls($rlist)

Estimating lasso for lwage76 using plugin
Estimating lasso for ed76 using plugin

Partialing-out linear model          Number of obs                =      2,956
                                     Number of controls           =         74
                                     Number of selected controls  =         15
                                     Wald chi2(1)                 =     135.22
                                     Prob > chi2                  =     0.0000

------------------------------------------------------------------------------
             |               Robust
     lwage76 | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
        ed76 |   .0510831   .0043929    11.63   0.000     .0424732     .059693
------------------------------------------------------------------------------
Note: Chi-squared test is a Wald test of the coefficients of the variables
      of interest jointly equal to zero. Lassos select controls for model
      estimation. Type lassoinfo to see number of selected variables in each
      lasso.

.  lassoinfo

    Estimate: active
     Command: poregress
------------------------------------------------------
            |                                   No. of
            |           Selection             selected
   Variable |    Model     method    lambda  variables
------------+-----------------------------------------
    lwage76 |   linear     plugin   .076097         11
       ed76 |   linear     plugin   .076097          7
------------------------------------------------------

.  
.  * Partialing Out for Instrumental Variables
.  global ivlist c.(age76)##c.(age76) i.(nearc4 nearc4b) c.(age76)#i.(nearc4 nearc4b)

.  poivregress lwage76 (ed76=$ivlist), controls($rlist)

Estimating lasso for lwage76 using plugin
Estimating lasso for ed76 using plugin
Estimating lasso for pred(ed76) using plugin

Partialing-out IV linear model     Number of obs                  =      2,956
                                   Number of controls             =         74
                                   Number of instruments          =         10
                                   Number of selected controls    =         15
                                   Number of selected instruments =          1
                                   Wald chi2(1)                   =     135.22
                                   Prob > chi2                    =     0.0000

------------------------------------------------------------------------------
             |               Robust
     lwage76 | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
        ed76 |   .0510831   .0043929    11.63   0.000     .0424732     .059693
------------------------------------------------------------------------------
Endogenous: ed76
Note: Chi-squared test is a Wald test of the coefficients of the variables
      of interest jointly equal to zero. Lassos select controls for model
      estimation. Type lassoinfo to see number of selected variables in each
      lasso.

.  lassoinfo

    Estimate: active
     Command: poivregress
------------------------------------------------------
            |                                   No. of
            |           Selection             selected
   Variable |    Model     method    lambda  variables
------------+-----------------------------------------
    lwage76 |   linear     plugin   .076097         11
       ed76 |   linear     plugin   .076736          5
 pred(ed76) |   linear     plugin   .076097          7
------------------------------------------------------

. 
end of do-file

*/


 