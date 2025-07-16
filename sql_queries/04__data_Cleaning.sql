-- ============================================================
--  Section 2: Data Cleaning
-- ============================================================

-- Delete duplicates, keeping the record with the smallest customer_id
-- Turn off safe updates
SET SQL_SAFE_UPDATES = 0;

-- ==========================================================================================

-- Now run your duplicate‐deletion
DELETE c1
FROM customers AS c1
JOIN customers AS c2
  ON c1.email = c2.email
 AND c1.customer_id > c2.customer_id;

-- verify no more duplicates remain
SELECT email, COUNT(*) AS freq
FROM customers
GROUP BY email
HAVING freq > 1;

-- ==========================================================================================

--  Fix the typo: change 'withdrl' to 'Withdrawal'
UPDATE transactions
SET txn_type = 'Withdrawal'
WHERE txn_type = 'withdrl';

-- Verify that the typo is gone
SELECT DISTINCT txn_type  FROM transactions;

-- ==========================================================================================

-- Standardize channel casing: capitalize first letter, lowercase the rest
UPDATE transactions
SET channel = CONCAT(
  UPPER(LEFT(channel, 1)),
  LOWER(SUBSTRING(channel, 2)))
  
WHERE channel <> CONCAT(
  UPPER(LEFT(channel, 1)),
  LOWER(SUBSTRING(channel, 2)));

-- Verify the fix
SELECT DISTINCT channel FROM transactions;

-- ==========================================================================================

-- Delete NUlls in txn_dat column
DELETE FROM transactions
WHERE txn_date IS NULL;

-- Verify none remain
SELECT COUNT(*) AS null_dates_remaining
FROM transactions
WHERE txn_date IS NULL;

-- ==========================================================================================

-- Remove all rows with missing amounts
DELETE FROM transactions
WHERE amount IS NULL;

-- Verify none remain
SELECT COUNT(*) AS null_amounts_remaining
FROM transactions
WHERE amount IS NULL;

-- ==========================================================================================

-- Handle amount Outliers
-- Add a flag column for outliers
ALTER TABLE transactions
ADD COLUMN outlier_flag TINYINT DEFAULT 0;

-- Mark rows where |amount| > 4000
UPDATE transactions
SET outlier_flag = 1
WHERE ABS(amount) > 4000;

-- Verify how many were flagged
SELECT COUNT(*) AS outliers_flagged
FROM transactions
WHERE outlier_flag = 1;

-- ==========================================================================================

-- -- Standardize txn_type casing to Title Case (e.g. 'Withdrawal', 'Deposit', etc.)
UPDATE transactions
SET txn_type = CONCAT(
    UCASE(LEFT(txn_type, 1)),
    LCASE(SUBSTR(txn_type, 2)))
WHERE txn_type IS NOT NULL;

-- Verify all distinct values now look correct
SELECT DISTINCT txn_type
FROM transactions;

-- ==========================================================================================

-- Delete duplicate rows, preserving the lowest txn_id for each group
-- Turn off safe updates
SET SQL_SAFE_UPDATES = 0;

-- Drop any existing dedup table
DROP TABLE IF EXISTS transactions_dedup;

-- Create a fresh dedup table with the same structure
CREATE TABLE transactions_dedup LIKE transactions;

-- Populate it with only the first row of each duplicate group
INSERT INTO transactions_dedup (
  txn_id,
  account_id,
  txn_date,
  txn_type,
  amount,
  channel,
  note,
  outlier_flag
)
SELECT
  txn_id,
  account_id,
  txn_date,
  txn_type,
  amount,
  channel,
  note,
  outlier_flag
FROM (
  SELECT
    txn_id,
    account_id,
    txn_date,
    txn_type,
    amount,
    channel,
    note,
    outlier_flag,
    ROW_NUMBER() OVER (
      PARTITION BY txn_type, amount, txn_date
      ORDER BY txn_id
    ) AS rn
  FROM transactions
) AS t
WHERE t.rn = 1;

-- Swap tables so you end up with only de-duplicated data
RENAME TABLE
  transactions TO transactions_old,
  transactions_dedup TO transactions;
  
DROP TABLE transactions_old;

-- verify
SELECT txn_type, amount, txn_date, COUNT(*) AS freq
FROM transactions
GROUP BY txn_type, amount, txn_date
HAVING freq > 1;

-- ==========================================================================================

SELECT DISTINCT txn_type
FROM transactions
ORDER BY txn_type;

