******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
* This Do file illustrates essentials of OLS-based multiple regression 
* analysis in STATA with an application examining health care expenditures.
******************************************************************************


cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd C:\Users\Linh Nguyen\OneDrive\Microeconometrics\Do file\Stata18\practice
                                       // change working directory
									    
use "HealthExpenditures.dta"           // Load Data

* lmed: logarithm of annual USD medical expenditure (excluding dental and
*       outpatient mental expenditure)
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
summarize lmed $xlist1

* Graphical Analysis
* Histograms
* Medical Expenditure
label variable lmed " "
histogram lmed, normal bin(100)                                      ///
title("Logarithm of Medical Expenditure for 4281 Households")        ///
      name(histlmed, replace)
graph export HistogramMedicalExpenditure.pdf, replace logo(off)      ///
             orientation(portrait)
* Income
label variable linc " "   
histogram linc, normal bin(100)                                      ///
title("Logarithm of Income for 4281 Households")                     ///
      name(histlinc, replace)
graph export HistogramIncome.pdf, replace logo(off)                  ///
             orientation(portrait)
* Scatter Plot Medical Expenditure vs. Income --> positive relationship?
label variable lmed "Medical Expenditure"
label variable linc "Income"
twoway (scatter lmed linc), title("4281 Households")                 ///
       name(scattermedcr, replace)
graph export ScatterMedicalExpenditureCR.pdf, replace logo(off)      ///
             orientation(portrait)
* Number of Chronic Diseases
label variable ndisease " "   
histogram ndisease, normal bin(30)                                   ///
title("Number of Chronic Diseases for 4281 Households")              ///
      name(histncd, replace)
graph export HistogramNCD.pdf, replace logo(off)                     ///
             orientation(portrait)
* Scatter Plot Medical Expenditure vs. Number of Chronic Diseases 
label variable lmed "Medical Expenditure"
label variable ndisease "Number of Chronic Diseases"
twoway (scatter lmed ndisease), title("4281 Households")             ///
       name(scattermedncd, replace)
graph export ScatterMedicalExpenditureNCD.pdf, replace logo(off)     ///
             orientation(portrait)
* Gender Female
label variable female " "   
histogram female, normal bin(10)                                     ///
title("Gender Female for 4281 Heads of Households")                  ///
      name(histfem, replace)
graph export HistogramFEM.pdf, replace logo(off)                     ///
             orientation(portrait)
* Scatter Plot Medical Expenditure vs. Gender Female 
label variable lmed "Medical Expenditure"
label variable ndisease "Female"
twoway (scatter lmed female), title("4281 Heads of Households")      ///
       name(scattermedfem, replace)
graph export ScatterMedicalExpenditureFEM.pdf, replace logo(off)     ///
             orientation(portrait)
			 
* OLS Estimation
* Multiple Linear Regression
regress lmed $xlist1
* Comparison: Simple Linear Regression
regress lmed linc

* Calculating Ceteris Paribus Effect (Frisch-Waugh Result)
* Auxiliary Regression 1
global xlistaux lc lpi fmde idp physlim ndisease                     /// 
       hlthg hlthf hlthp educdec age lfam female child femchild black
quietly regress lmed $xlistaux
predict residlmedadj, resid   
        // changes in lmed not driven by changes in xlistaux
* Auxiliary Regression 2
quietly regress linc $xlistaux
predict residlincadj, resid          
        // changes in linc not driven by changes in xlistaux 
* Ceteris Paribus Effect
regress residlmedadj residlincadj   
        // marginal effect of changes in linc on lmed

* Actual vs. Predicted Values
quietly regress lmed $xlist1
predict lmedhat, xb
label variable lmed "Actual Values"
label variable lmedhat "Predicted Values"
twoway (scatter lmedhat lmed), || (line lmed lmed),                  /// 
       legend(off)                                                   ///
       title("Predicted Medical Expenditure")                        ///
       ytitle("Actual Values")                                       ///
       xtitle("Predicted Values")                                    ///
       name(ScatterRegModel, replace)
graph export ScatterMedicalExpenditureActualPredicted.pdf,           ///
      replace logo(off)                                              ///
      orientation(portrait)	  
summarize lmedhat lmed
* Model Selection Using AIC and SBC
* global xlist1 linc lc lpi fmde idp physlim ndisease                   
*        hlthg hlthf hlthp educdec age lfam female child femchild black
* Considering the Inclusion of "ndisease" Among the Regressors
global xlist2 linc lc lpi fmde idp physlim                           /// 
       hlthg hlthf hlthp educdec age lfam female child femchild black
quietly regress lmed $xlist2
disp "Information Criteria for Model Excluding ndisease:"
estat ic
disp "Information Criteria for Model Including ndisease:"
quietly regress lmed $xlist1 
estat ic
/*

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
           . |      4,281  -7807.979  -7493.499      18      15023   15137.51
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. 

/*Note:
BIC or SBC is Schwarz Bayesian Information Criterion
*/

*/
* Considering the Inclusion of "age" Among the Regressors
global xlist3 linc lc lpi fmde idp physlim ndisease                  ///  
       hlthg hlthf hlthp educdec lfam female child femchild black
quietly regress lmed $xlist3
disp "Information Criteria for Model Excluding age:"
estat ic
disp "Information Criteria for Model Including age:"
quietly regress lmed $xlist1 
estat ic
