-- ============================================================
--  Section 1: Data Exploration Account Table
-- ============================================================

-- Preview sample rows
SELECT * FROM accounts LIMIT 20;

-- ==========================================================================================

-- Total row count
SELECT COUNT(*) total_row FROM accounts;
-- ==========================================================================================

-- check for NULLs in each columns
SELECT
SUM(customer_id IS NULL) AS null_customer_id,
SUM(account_type IS NULL) AS null_account_type,
SUM(open_date IS NULL) As null_open_date,
SUM(is_active IS NULL) AS null_is_active,
SUM(balance IS NULL) AS null_blance
FROM accounts;

-- ==========================================================================================
-- Distinct account types
SELECT DISTINCT account_type FROM accounts;

-- ==========================================================================================

-- Count by account type
SELECT account_type, COUNT(*) AS count
FROM accounts
GROUP BY account_type;

-- ==========================================================================================

-- Active vs inactiv e accounts
SELECT  is_active, COUNT(*) AS count
FROM accounts
group by is_active;

-- ==========================================================================================

-- Account balance stats
SELECT MIN(balance) AS min_balance,
		MAX(balance) AS max_balance,
        AVG(balance) AS avg_balance
FROM accounts;

-- ==========================================================================================

-- Account with negative or zero balance
Select *
from accounts
where balance <= 0;

-- ==========================================================================================

-- Account open date range
SELECT MIN(open_date) AS earliest, MAX(open_date)AS latest
FROM accounts;

-- ==========================================================================================

-- Account per customers
SELECT customer_id, COUNT(*) AS account_count
FROM accounts
GROUP BY customer_id
ORDER BY account_count DESC
Limit  20;