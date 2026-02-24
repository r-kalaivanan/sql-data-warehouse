SELECT TOP(100) * FROM silver.erp_cust_az12;

-- Identify out-of-range Dates

SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Data Standardization & Consistency

SELECT DISTINCT gen
FROM silver.erp_cust_az12;