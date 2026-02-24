SELECT TOP (1000) * FROM silver.crm_cust_info;

-- Check for NULLs or Duplicates in Primary Key
-- Expectation : No Result

SELECT
	cst_id,
	COUNT(*) AS count_of_customer_id
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces
-- Expectation : No Results

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Data Standardization and Consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;