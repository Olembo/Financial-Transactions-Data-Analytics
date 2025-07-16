# Financial-Transactions-Data-Analytics

## Project Overview
This project analyzes over **44,000 financial transactions** from January 2022 to June 2025 across 8 countries. The aim is to simulate a real-world data analyst workflow, from raw data handling and cleansing to exploratory analysis and dashboard preparation.

We explored key metrics like transaction trends, fee impact, customer activity, and channel usage, with the final goal of building an interactive dashboard using Tableau or Power BI.

---

## Data Model Summary
The dataset contains **three linked tables**:

- `customers`: customer_id, name, country, join_date
- `accounts`: account_id, customer_id, account_type, open_date
- `transactions`: txn_id, account_id, txn_date, txn_type, amount, channel, note

Each transaction links to an account, and each account links to a customer. This star schema enables robust joins and segmentation.

---

## Data Quality & Cleaning Process
A total of **10+ issues** were documented and resolved. Highlights include:

- Typo fix: 'withdrl' corrected to 'Withdrawal'
- Standardized casing: 'atm', 'mobile', etc. unified to proper case
- Missing values: Removed or flagged nulls in amount, txn_date, note
- Categorical mix: Cleaned txn_type and channel
- Duplicate detection: Deduplicated rows by txn_type, amount, and date
- Outlier review: Flagged high-value Fees and Withdrawals using IQR
- Ambiguous logic: Added "Transfer In" and "Transfer Out" labels to clarify money direction

A full issues log is available in the workbook.

---

## Exploratory Data Analysis (EDA Highlights)

**1. Quantitative Overview**
- Total Transactions: 44,065
- Unique Accounts: 1,500
- Unique Customers: 999
- Date Range: Jan 2022 to Jun 2025

**2. Time Trends**
- Monthly transaction volume ranged between ~960 to ~1,100 per month
- Stable volume with minor seasonal dips

**3. Transaction Type Analysis**
- Deposits: 39.6% of all transactions
- Withdrawals: 40.2%
- Fees: ~10%, often small but impactful
- Transfers: 10% (now split into In and Out)

**4. Channel Usage**
- Usage evenly spread across ATM, Online, Mobile, and Branch
- Channel volume and patterns vary slightly by country

**5. Country Analysis**
- Countries with highest transaction volume: US, UK, Germany
- Negative totals driven by Fees and Withdrawals

**6. Outlier Behavior**
- ~8,700 transactions had high absolute values (>|4000|), especially Fees and Withdrawals
- These were reviewed, but retained to preserve data integrity

---

## Dashboard Preparation (in Progress)

12 Tableau worksheets were created, including:
- KPI Cards (total amount, total transactions, unique accounts)
- Line Charts for time trends
- Donut chart for txn type share
- Treemap for channel usage
- Map and bar chart for country trends

The dashboard layout is still in progress. Challenges with KPI alignment and visual space may lead to reworking layout or switching to Power BI.

---

## Recommendations

**1. Fee Monitoring**  
Recommend implementing automated alerts or thresholds to flag unusually large fees for review.

**2. Channel Optimization**  
Tailor promotions or support strategies based on regional channel preferences.

**3. Customer Behavior Tracking**  
Segment and retain customers with high withdrawal-to-deposit ratios.

**4. Data Integrity Checks**  
Improve validation to prevent typos and formatting errors.

**5. Outlier Policy**  
Define clear business rules to manage large transactions.

---

## Tools Used
- MySQL
- Excel
- Tableau
- Power BI (planned)

---

## Files Included
- 01_explore_transactions
- 02_explore_accounts
- 03_explore_customers
- 04_data_cleaning
- 05_Exploratory_Data_Analysis_(EDA)
- create_table
- insert_financial_data
- Financial_Data_Issues_Log.xlsx
- EDA_Output.xlsx
- Cleaned_Data_View (MySQL View)
- Tableau .twbx file (in progress)
- Report.pdf
- `Financial_Data_Issues_Log.xlsx`
- `EDA_Output.xlsx`
- `Cleaned_Data_View` (MySQL View)
- Tableau `.twbx` file (in progress)

---

##  Outcome & Next Steps
- Realistic messy data simulation  
- SQL-based cleaning  
- Structured EDA  
- Dashboard readiness

Next: Finalize Tableau dashboard or migrate to Power BI.
