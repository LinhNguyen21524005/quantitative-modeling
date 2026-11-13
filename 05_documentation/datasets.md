# Datasets

This document provides an overview of the datasets referenced in the econometric and machine learning implementations in this repository.

The datasets are primarily used for applied exercises in microeconometrics, financial economics, labor economics, healthcare economics, and predictive modeling.

**Important:** The original datasets are not included in this repository. Most scripts require external Stata `.dta` files, while the panel wage analysis uses an Excel source file. Users must obtain the corresponding datasets separately before running the scripts.

## 1. Multiple Regression

| Dataset | Research Application | Main Variables |
|---|---|---|
| `401kParticipation.dta` | Retirement plan participation | IRA participation, 401(k) participation, income, age |
| `HealthExpenditures.dta` | Household medical expenditure | Medical expenditure, income, health status, demographics |
| `HousePrices.dta` | Housing price determinants | House prices, house size, bedrooms, lot size, assessed value |
| `Preselect.dta` | Election results and regression analysis | County-level election votes and total votes |

## 2. Limited Dependent Variable Models

| Dataset | Research Application | Main Variables |
|---|---|---|
| `UnemploymentBenefits.dta` | Unemployment insurance participation | Benefit application, replacement rate, employment history, demographics |
| `DoctorVisits.dta` | Healthcare utilization | Number of doctor visits, insurance, chronic conditions, demographics |
| `HealthBinary.dta` | Binary healthcare outcome analysis | Health outcome and individual characteristics |
| `HealthExpenditures_Tobit.dta` | Censored health expenditure analysis | Health expenditure and explanatory variables |
| `AmbulatoryExpenditure.dta` | Household ambulatory expenditure | Expenditure, income, insurance, education, age, chronic diseases |

## 3. Panel Data Econometrics

| Dataset | Research Application | Main Variables |
|---|---|---|
| `FirmPanel.dta` | Firm investment behavior | Investment, firm-specific identifiers, financial variables |
| `PSIDWagePanel` (Excel) | Wage determination and individual panel analysis | Log wages, education, experience, occupation, individual and time identifiers |

## 4. Machine Learning

| Dataset | Research Application | Main Variables |
|---|---|---|
| `401kParticipation.dta` | Retirement account participation prediction | IRA participation, 401(k) participation, income, age |
| `ReturnsToSchooling.dta` | Wage prediction and returns to education | Log wages, education, work experience, parental education, demographics |

## 5. Data Preparation and Reproducibility

The original scripts reference datasets stored in local directories. To improve portability and reproducibility, users should:

1. Obtain the original datasets from the relevant course materials or authorized data sources.
2. Place the datasets in an appropriate local data directory.
3. Update the working directory and file paths in the Stata scripts.
4. Verify variable names and dataset structures before executing the models.

### Data Availability and Usage

- No original datasets are redistributed in this repository.
- Dataset availability and access conditions depend on their respective sources.
- Users are responsible for obtaining appropriate access and complying with applicable data-use restrictions.
- Dataset names and variable descriptions are based on the original Stata scripts and may require verification against the actual data files.

---

*This repository focuses on econometric methodology and statistical implementation. Dataset documentation is provided to facilitate transparency and reproducibility.*
