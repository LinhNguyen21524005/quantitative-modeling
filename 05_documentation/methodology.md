# Methodology

This document summarizes the econometric and statistical methodologies implemented in this repository using Stata. The scripts cover classical regression analysis, limited dependent variable models, panel data econometrics, and machine learning techniques applied to economic and financial datasets.

## 1. Multiple Linear Regression

### Methods
- Ordinary Least Squares (OLS) estimation
- Multiple regression and model specification
- Polynomial terms and interaction effects
- Variable selection and model comparison
- Residual analysis and partial regression
- Heteroskedasticity testing
- Feasible Generalized Least Squares (FGLS)
- Heteroskedasticity-robust standard errors

### Model Evaluation
- t-tests and F-tests
- Breusch-Pagan heteroskedasticity test
- Information criteria (AIC and BIC)
- Predicted values and residual diagnostics
- Model specification comparison

### Applications
- Household financial and retirement plan participation
- Medical and health expenditure determinants
- Housing price analysis
- County-level election data analysis

## 2. Limited Dependent Variable Models

This section explores econometric models designed for dependent variables with binary, censored, selected, or count outcomes.

### Binary Choice Models
- Logit regression
- Probit regression
- Odds ratios
- Predicted probabilities and classification analysis
- Average marginal effects (AME)
- Marginal effects at representative values

### Censored and Sample Selection Models
- Tobit regression
- Heckman sample selection model
- Two-step prediction procedures
- Selection equations and exclusion restrictions
- Conditional and unconditional outcome predictions

### Count Data Models
- Poisson regression
- Negative Binomial regression
- Maximum likelihood estimation
- Incidence rate ratios

### Applications
- Unemployment insurance participation
- Healthcare utilization and medical expenditure
- Doctor visit frequency
- Health insurance and individual healthcare outcomes

## 3. Panel Data Econometrics

This section examines longitudinal data and unobserved individual or firm-specific heterogeneity.

### Methods
- Pooled Ordinary Least Squares
- Fixed Effects (FE) estimation
- Random Effects (RE) estimation
- Least Squares Dummy Variable (LSDV) approach
- Maximum Likelihood estimation for panel models

### Model Selection and Testing
- Joint significance tests for individual effects
- Hausman specification test
- Comparison of Fixed Effects and Random Effects estimators

### Applications
- Firm investment behavior
- Wage determination and individual labor market outcomes

## 4. Machine Learning and Predictive Modeling

This section applies regularization and model selection techniques to economic prediction problems.

### Regularization Methods
- Ridge Regression (L2 regularization)
- LASSO Regression (L1 regularization)
- Elastic Net Regression (combined L1 and L2 regularization)

### Model Selection
- AIC-based variable selection
- BIC-based variable selection
- Permutation-based regression selection

### Predictive Evaluation
- Training and testing sample separation
- Mean Squared Error (MSE)
- Out-of-sample prediction comparison
- Benchmark comparison against conventional OLS models

### Additional Methods
- Post-double-selection regression
- Post-double-selection instrumental variable estimation
- Two-Stage Least Squares (2SLS)
- Endogeneity testing and first-stage diagnostics

### Applications
- Individual Retirement Account (IRA) participation
- Returns to schooling and wage prediction

## 5. Statistical Tools and Implementation

**Software:** Stata

**Core techniques:**
- Maximum Likelihood Estimation (MLE)
- Hypothesis testing and statistical inference
- Marginal effects estimation
- Model diagnostics and specification testing
- Prediction and model evaluation
- Instrumental variable estimation

All implementations are documented in their corresponding folders. Individual scripts contain the Stata commands and application-specific procedures.

---

*Note: This repository documents applied econometric and statistical modeling exercises developed through graduate-level coursework in Global Finance and Economics. The scripts demonstrate methodological implementations rather than production-ready modeling systems.*
