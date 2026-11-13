******************************************************************************
*    Advanced Fundamentals of Microeconometrics and Data Science (AFMD)
*                      Vietnamese German University  
*                           Fall Semester 2024
*                       Prof. Michael Binder, Ph.D.
*
*                       Problem Set 1: House Prices
******************************************************************************

cls                                    // clear display in results window
clear                                  // clear previous work out of memory 
cd c:\stata\afmd24\ProblemSolving
                                       // change working directory
									    
use "HousePrices.dta"                  // Load Data
 
* Data Description 
summarize price housesize bdrms lotsize assess
* Histograms
* House Prices
label variable price " "
histogram price, normal bin(20)                                      ///
title("House Prices for 88 Homes")                                   ///
      name(histprices, replace)
* Housesize
label variable housesize " "
histogram housesize, normal bin(20)                                  ///
title("House Sizes for 88 Homes")                                    ///
      name(housesize, replace)
* Bedrooms
label variable bdrms " "
histogram bdrms, normal bin(20)                                      ///
title("Number of Bedrooms for 88 Homes")                             ///
      name(histbrms, replace)
* Lotsize
label variable lotsize " "
histogram lotsize, normal bin(20)                                    ///
title("Lot Sizes for 88 Homes")                                      ///
      name(histlotsize, replace)
* Assessment Value
label variable assess " "
histogram assess, normal bin(20)                                     ///
title("Assessment Values for 88 Homes")                              ///
      name(histassess, replace)

* OLS Estimation
* First Model
regress price housesize bdrms
predict pricehat1, xb
list price pricehat1 in 1
estat ic
* Second Model
regress price housesize bdrms lotsize assess
estat ic
predict pricehat2, xb
list price pricehat2 in 1

* Calculating Ceteris Paribus Effect (Frisch-Waugh Result)
* Auxiliary Regression 1
quietly regress price lotsize assess
predict residpriceadj, resid   
        // changes in price not driven by changes in lotsize and assess
* Auxiliary Regression 2a
quietly regress housesize lotsize assess
predict residhsadj, resid          
        // changes in housesize not driven by changes in lotsize and assess 
* Auxiliary Regression 2b
quietly regress bdrms lotsize assess
predict residbradj, resid          
        // changes in bdrms not driven by changes in lotsize and assess
* Ceteris Paribus Effect
regress residpriceadj residhsadj residbradj
        // marginal effect of changes in housesize and bedrooms on price
