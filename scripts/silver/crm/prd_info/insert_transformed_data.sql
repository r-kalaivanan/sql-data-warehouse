SET NOCOUNT ON;
RAISERROR('>> Truncating Table : silver.crm_prd_info', 0, 1) WITH NOWAIT;
TRUNCATE TABLE silver.crm_prd_info;
RAISERROR('>> Inserting Data Into : silver.crm_prd_info', 0, 1) WITH NOWAIT;

INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	prd_start_dt,
	LEAD(DATEADD(DAY, -1, prd_start_dt)) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt
FROM bronze.crm_prd_info;