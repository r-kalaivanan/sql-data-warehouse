SET NOCOUNT ON;
RAISERROR('>> Truncating Table : silver.erp_loc_a101', 0, 1) WITH NOWAIT;
TRUNCATE TABLE silver.erp_loc_a101;
RAISERROR('>> Inserting Data Into : silver.erp_loc_a101', 0, 1) WITH NOWAIT;

INSERT INTO silver.erp_loc_a101 (
	cid,
	cntry
)

SELECT
	REPLACE(cid, '-', '') AS cid,
	CASE 
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101;