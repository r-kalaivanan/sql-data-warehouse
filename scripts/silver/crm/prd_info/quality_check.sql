SELECT TOP (100) * FROM silver.crm_prd_info;

-- Check for NULLs or Duplicates in Primary Key
-- Expectation : No Result

SELECT 
	prd_id,
	COUNT(*) AS count_of_product_id
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces
-- Expectation : No Results

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Numbers
-- Expectation : No Results

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standarization and Normalization

SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

 -- Check for Invalid Date Orders

 SELECT *
 FROM silver.crm_prd_info
 WHERE prd_end_dt < prd_start_dt;

 