-- ============================================================
--  Section 1: Data Exploration Transactions
-- ============================================================

-- Preview sample rows
SELECT * 
FROM transactions LIMIT 30;
-- =========================================================================================

-- Total row count
SELECT COUNT(*) total_rows FROM transactions;
-- ==========================================================================================

-- Check for Null in each column
SELECT
	sum(txn_date IS NULL) AS null_txn_date,
    SUM(txn_type IS NULL) AS null_txn_type,
    SUM(amount IS NULL) AS null_amount,
    SUM(channel IS NULL) AS null_channel,
    SUM(note IS NULL) AS null_note
    FROM transactions;
    
-- ==========================================================================================

-- count distinct values per column
SELECT COUNT(DISTINCT txn_type) AS txn_type_values FROM transactions;
SELECT COUNT(DISTINCT channel) AS channel_values FROM transactions;

-- ==========================================================================================

-- Check for distinct values per column
SELECT DISTINCT txn_type FROM transactions;
SELECT DISTINCT channel FROM transactions;

-- ==========================================================================================

-- frenquency count for categorical columns
SELECT txn_type, COUNT(*) AS frequency FROM transactions GROUP BY txn_type;
SELECT channel, COUNT(*) AS frequency FROM transactions GROUP BY channel;

-- ==========================================================================================

-- Min, max, and range of amount per txn_type
SELECT txn_type, MIN(amount) AS min_amt, MAX(amount) AS max_amt
FROM transactions
GROUP BY txn_type;

-- ==========================================================================================

-- Outlier detection: High/Low values
SELECT * FROM transactions WHERE ABS(amount) > 4000;

-- ==========================================================================================

--  Count of negative and positive transactions by type
SELECT txn_type,
  SUM(CASE WHEN amount < 0 THEN 1 ELSE 0 END) AS negative_count,
  SUM(CASE WHEN amount > 0 THEN 1 ELSE 0 END) AS positive_count
FROM transactions
GROUP BY txn_type;

-- ==========================================================================================

-- Duplicate check by txn_type, amount, txn_date
SELECT txn_type, amount, txn_date, COUNT(*)
FROM transactions
GROUP BY txn_type, amount, txn_date
HAVING COUNT(*) > 1;

-- ==========================================================================================

-- Distribution over time
SELECT DATE_FORMAT(txn_date, '%Y-%m') AS month, COUNT(*) AS txn_count
FROM transactions
WHERE txn_date IS NOT NULL
GROUP BY month
ORDER BY month;

-- ==========================================================================================

--  Missing vs non-missing breakdown by channel
SELECT channel,
  SUM(txn_date IS NULL) AS missing_dates,
  COUNT(*) AS total_rows
FROM transactions
GROUP BY channel;

-- ==========================================================================================

--  Check if any txn_type is used with inconsistent amount sign
SELECT txn_type, amount
FROM transactions
WHERE (txn_type = 'Withdrawal' AND amount > 0)
   OR (txn_type = 'Deposit' AND amount < 0)
   OR (txn_type = 'Fee' AND amount > 0);
   
   -- ==========================================================================================
   
   -- Check if txn_date is within expected range
SELECT MIN(txn_date) AS earliest, MAX(txn_date) AS latest FROM transactions;

-- ==========================================================================================

--  Group by account: which accounts have the most transactions?
SELECT account_id, COUNT(*) AS txn_count
FROM transactions
GROUP BY account_id
ORDER BY txn_count DESC
LIMIT 10;