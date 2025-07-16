-- ============================================================
--  Section 1: Data Exploration Customers Table
-- ============================================================

-- preview sample rows
SELECT * FROM customers Limit 20;

-- ==========================================================================================

-- Total rows coun t
SELECT COUNT(*) AS total_rows FROM customers;

-- ==========================================================================================

-- check for NULLs in each column\
SELECT
	SUM(name IS NULL) AS null_name,
  SUM(email IS NULL) AS null_email,
  SUM(country IS NULL) AS null_country,
  SUM(join_date IS NULL) AS null_join_date
FROM customers;

-- ==========================================================================================

-- Distinct values counts
SELECT COUNT(DISTINCT country) AS unique_countries FROM customers;

-- ==========================================================================================

-- List unique countries
SELECT DISTINCT country FROM customers ORDER BY country;

-- ==========================================================================================

-- Validate join_date range
SELECT MIN(join_date) AS earliest, MAX(join_date) AS latest FROM customers;

-- ==========================================================================================

-- Check for duplicate emails
SELECT email, COUNT(*) AS freq FROM customers
GROUP BY email
HAVING freq > 1;

-- ==========================================================================================

-- Emails that don't contain '@'
SELECT * FROM customers WHERE email NOT LIKE '%@%';

-- ==========================================================================================

-- Join_date distribution (yearly trend)
SELECT YEAR(join_date) AS join_year, COUNT(*) AS user_count
FROM customers
GROUP BY join_year
ORDER BY join_year;