SET NOCOUNT ON;
RAISERROR('>> Truncating Table : silver.erp_px_cat_g1v2', 0, 1) WITH NOWAIT;
TRUNCATE TABLE silver.erp_px_cat_g1v2;
RAISERROR('>> Inserting Data Into : silver.erp_px_cat_g1v2', 0, 1) WITH NOWAIT;

INSERT INTO silver.erp_px_cat_g1v2 (
	id,
	cat,
	subcat,
	maintenance
)

SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;