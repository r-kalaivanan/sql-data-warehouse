SELECT TOP (999) * FROM silver.crm_sales_details;

SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN
	(SELECT DISTINCT prd_key FROM silver.crm_prd_info);

SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN
	(SELECT DISTINCT cst_id FROM silver.crm_cust_info);

-- Check for invalid dates

SELECT 
	NULLIF(sls_due_dt,0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101;

SELECT *
FROM bronze.crm_sales_details
WHERE sls_ship_dt > sls_due_dt;

-- Check Data Consistency : Between Sales, Quantity, and Price 
-- >> Sales = Quantity * Price 
-- >> Values must not be NULL, Zero, or Negative.

SELECT 
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_price <= 0 OR sls_quantity <= 0;

