SET NOCOUNT ON;
RAISERROR('>> Truncating Table : silver.erp_cust_az12', 0, 1) WITH NOWAIT;
TRUNCATE TABLE silver.erp_cust_az12;
RAISERROR('>> Inserting Data Into : silver.erp_cust_az12', 0, 1) WITH NOWAIT;

INSERT INTO silver.erp_cust_az12 (
	cid,
	bdate,
	gen
)

SELECT
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END AS cid,
	CASE 
		WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END AS bdate,
	CASE
		WHEN gen = 'M' THEN 'Male'
		WHEN gen = 'F' THEN 'Female'
		WHEN TRIM(gen) = '' OR gen IS NULL THEN 'n/a'
		ELSE gen
	END AS gen
FROM bronze.erp_cust_az12;