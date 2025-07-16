-- ============================================================
--  Section 3: Exploratory Data Analysis (EDA) 
-- ============================================================
-- ============================================================
--  1: Quantitative Overview 
-- ============================================================

-- Total number of transactions
SELECT COUNT(*) AS total_transactions
FROM transactions;

-- ==========================================================================================
-- number of unique accounts and customers involved
SELECT
	(SELECT COUNT(DISTINCT account_id) FROM transactions) AS unique_accounts,
    (SELECT COUNT(DISTINCT customer_id) FROM customers) AS unique_customers;
    
-- ==========================================================================================

-- Time range covered in the transaction
SELECT 
	MIN(txn_date) AS start_date,
    MAX(txn_date) AS end_date
FROM transactions
WHERE txn_date IS NOT NULL;
-- ==========================================================================================

-- Average transactions per customer and per account
SELECT 
    ROUND(COUNT(*) / COUNT(DISTINCT a.customer_id), 2) AS avg_txn_per_customer,
    ROUND(COUNT(*) / COUNT(DISTINCT t.account_id), 2) AS avg_txn_per_account
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id;
-- ==========================================================================================

-- Monthly transaction volume trend
SELECT
	DATE_FORMAT(txn_date, '%Y-%m') AS month,
    COUNT(*) AS transaction_count
FROM transactions
WHERE txn_date IS NOT NULL
GROUP BY month
ORDER BY month;

-- ============================================================
--  2: Transaction Analysis by Type 
-- ============================================================

-- Distribustion  and count of each txn_type
SELECT
	txn_type,
    COUNT(*) AS txn_count
FROM transactions
GROUP BY txn_type
ORDER BY txn_count DESC;
-- ==========================================================================================

-- Average and total amount per txn_type
SELECT
 txn_type,
    COUNT(*) AS txn_count,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY txn_type
ORDER BY total_amount DESC;
-- ==========================================================================================

-- Net Flow calculation
-- (Deposits + Transfer In) - (withdrawl + Transfers Out + fees)
SELECT 
    ROUND(COALESCE((SELECT SUM(amount) FROM transactions WHERE txn_type IN ('Deposit', 'Transfer In')), 0)
        - COALESCE((SELECT SUM(amount) FROM transactions WHERE txn_type IN ('Withdrawal', 'Transfer Out', 'Fee')), 0)
    , 2) AS net_flow_amount;
    
-- ==========================================================================================
-- Directionnality: Money In Vs Money Out summary
SELECT direction, ROUND(SUM(amount), 2) AS total_amount,
    COUNT(*) AS txn_count
FROM (
    SELECT 
        CASE 
            WHEN txn_type IN ('Deposit', 'Transfer In') THEN 'Money In'
            WHEN txn_type IN ('Withdrawal', 'Transfer Out', 'Fee') THEN 'Money Out'
            ELSE 'Other'
        END AS direction,
        amount
    FROM transactions
) AS classified
GROUP BY direction;

-- ============================================================
--  3: Customer Behavior 
-- ============================================================

-- Most active customers by numbre of transactions
SELECT
	a.customer_id,
    COUNT(*) AS txn_count
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
GROUP BY a.account_id
ORDER BY txn_count DESC
LIMIT 10;
-- ==========================================================================================

-- most active customers by total transaction amount
SELECT 
    a.customer_id,
    ROUND(SUM(t.amount), 2) AS total_amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
GROUP BY a.customer_id
ORDER BY total_amount DESC
LIMIT 10;

-- ==========================================================================================
-- Top depositors vs. top withdrawers
SELECT 
    a.customer_id,
    t.txn_type,
    ROUND(SUM(t.amount), 2) AS total_amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE t.txn_type IN ('Deposit', 'Withdrawal')
GROUP BY a.customer_id, t.txn_type
ORDER BY ABS(SUM(t.amount)) DESC
LIMIT 20;

-- ==========================================================================================
-- customers with high fee payments
SELECT 
    a.customer_id,
    ROUND(SUM(t.amount), 2) AS total_fees_paid
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE t.txn_type = 'Fee'
GROUP BY a.customer_id
ORDER BY total_fees_paid ASC
LIMIT 10;

-- ==========================================================================================
-- Potential churn: customers with no transactions in the last 6 months (before June 2025)
SELECT 
    a.customer_id,
    MAX(t.txn_date) AS last_txn_date
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
GROUP BY a.customer_id
HAVING last_txn_date < '2025-01-01'
ORDER BY last_txn_date;

-- ============================================================
--  4: Channel Analysis 
-- ============================================================

-- Distribution of transactions by channel
SELECT 
    channel, 
    COUNT(*) AS txn_count
FROM transactions
GROUP BY channel
ORDER BY txn_count DESC;

-- ==========================================================================================
-- Total and average amount processed per channel
SELECT 
    channel,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount
FROM transactions
GROUP BY channel
ORDER BY total_amount DESC;

-- ==========================================================================================
-- Monthly transaction trend by channel
SELECT 
    DATE_FORMAT(txn_date, '%Y-%m') AS month,
    channel,
    COUNT(*) AS txn_count
FROM transactions
WHERE txn_date IS NOT NULL
GROUP BY month, channel
ORDER BY month, channel;

-- ==========================================================================================
-- Channel preference by country
SELECT 
    c.country,
    t.channel,
    COUNT(*) AS txn_count
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY c.country, t.channel
ORDER BY c.country, txn_count DESC;

-- ============================================================
--  5: Geographic Patterns
-- ============================================================

-- Total Transactions and Amount by Country
SELECT 
    c.country,
    COUNT(*) AS txn_count,
    ROUND(SUM(t.amount), 2) AS total_amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_amount DESC;

-- ==========================================================================================
-- Total Fees Paid by Country
SELECT 
    c.country,
    ROUND(SUM(t.amount), 2) AS total_fees,
    COUNT(*) AS fee_txns,
    ROUND(SUM(t.amount) / COUNT(*), 2) AS avg_fee_per_txn
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.txn_type = 'Fee'
GROUP BY c.country
ORDER BY total_fees ASC;

-- ==========================================================================================
-- Transfers Between Countries
-- Note: We can’t track where the money is sent or received exactly because we don’t have sender and receiver IDs. So for now, we only count how many transfers happened in each country.
SELECT 
    c.country,
    t.txn_type,
    COUNT(*) AS transfer_txns,
    ROUND(SUM(t.amount), 2) AS total_transfer_amt
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.txn_type IN ('Transfer In', 'Transfer Out')
GROUP BY c.country, t.txn_type
ORDER BY c.country, t.txn_type;

-- ============================================================
--  6: Temporal Patterns
-- ============================================================
--  Month-over-month transaction trends (count and total amount)
SELECT 
    DATE_FORMAT(txn_date, '%Y-%m') AS month,
    COUNT(*) AS txn_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
WHERE txn_date IS NOT NULL
GROUP BY month
ORDER BY month;

-- ==========================================================================================
-- Month-over-month average transaction amount
SELECT 
    DATE_FORMAT(txn_date, '%Y-%m') AS month,
    ROUND(AVG(amount), 2) AS avg_amount
FROM transactions
WHERE txn_date IS NOT NULL
GROUP BY month
ORDER BY month;

-- ==========================================================================================
-- Month-over-month transaction trends by type (for spotting seasonal patterns)
SELECT 
    DATE_FORMAT(txn_date, '%Y-%m') AS month,
    txn_type,
    COUNT(*) AS txn_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
WHERE txn_date IS NOT NULL
GROUP BY month, txn_type
ORDER BY month, txn_type;

-- ============================================================
--  7: Account-Level Trends
-- ============================================================
-- Balance progression over time
WITH monthly_txns AS (
    SELECT 
        t.account_id,
        DATE_FORMAT(t.txn_date, '%Y-%m') AS month,
        SUM(t.amount) AS monthly_change
    FROM transactions t
    WHERE t.txn_date IS NOT NULL
    GROUP BY t.account_id, month
),

running_total AS (
    SELECT 
        m.account_id,
        m.month,
        SUM(m.monthly_change) OVER (PARTITION BY m.account_id ORDER BY m.month) AS cumulative_txn_amt
    FROM monthly_txns m
),

final_balance AS (
    SELECT 
        r.account_id,
        r.month,
        ROUND(a.balance + r.cumulative_txn_amt, 2) AS simulated_balance
    FROM running_total r
    JOIN accounts a ON r.account_id = a.account_id
)

SELECT * FROM final_balance
ORDER BY account_id, month;

-- ==========================================================================================
--  Accounts with frequent overdrafts or low balances
SELECT 
    a.account_id,
    c.customer_id,
    c.country,
    COUNT(*) AS txn_count,
    SUM(CASE WHEN a.balance < 0 THEN 1 ELSE 0 END) AS overdraft_count,
    SUM(CASE WHEN a.balance BETWEEN 0 AND 50 THEN 1 ELSE 0 END) AS low_balance_count
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN transactions t ON t.account_id = a.account_id
GROUP BY a.account_id, c.customer_id, c.country
ORDER BY overdraft_count DESC, low_balance_count DESC;

-- ==========================================================================================
--  Age of account vs. activity level (number of transactions)
SELECT 
    a.account_id,
    a.open_date,
    DATEDIFF(CURDATE(), a.open_date) AS account_age_days,
    COUNT(t.txn_id) AS txn_count
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, a.open_date
ORDER BY txn_count DESC;

-- ==========================================================================================
-- Large transactions flagged earlier during cleaning (IQR or threshold based)
-- Example threshold used before: ABS(amount) > 4000
SELECT *
FROM transactions
WHERE ABS(amount) > 4000
ORDER BY amount DESC;

-- ==========================================================================================
-- Accounts with skewed behavior: unusually high number of withdrawals or fees
SELECT 
    t.account_id,
    SUM(CASE WHEN txn_type = 'Withdrawal' THEN 1 ELSE 0 END) AS withdrawals,
    SUM(CASE WHEN txn_type = 'Fee' THEN 1 ELSE 0 END) AS fees,
    COUNT(*) AS total_txns
FROM transactions t
GROUP BY t.account_id
HAVING withdrawals > 50 OR fees > 30
ORDER BY withdrawals DESC, fees DESC;

-- ==========================================================================================

--  Inconsistent transaction directions (e.g., Deposit with negative amount)
SELECT *
FROM transactions
WHERE 
    (txn_type = 'Deposit' AND amount < 0)
    OR (txn_type = 'Withdrawal' AND amount > 0)
    OR (txn_type = 'Fee' AND amount > 0)
    OR (txn_type = 'Transfer In' AND amount < 0)
    OR (txn_type = 'Transfer Out' AND amount > 0)
ORDER BY txn_type, amount;
