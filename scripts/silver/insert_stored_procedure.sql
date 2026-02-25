/*

Purpose : Tranforms and strandadizes raw bronze data into structured, cleaned and analytics - ready silver tables.

Description : This procedure performs a full refresh of the silver layer by truncating existing silver tables and loading transformed data from the bronze layer.

*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @start_time DATETIME,
			@end_time DATETIME,
			@duration INT,
			@batch_start_time DATETIME,
			@batch_end_time DATETIME,
			@batch_duration INT;

	BEGIN TRY

		SET @batch_start_time = GETDATE();

		RAISERROR('==============================', 0,1) WITH NOWAIT;
		RAISERROR('Starting Silver Layer Load', 0, 1) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

		RAISERROR('Loading CRM Tables...', 0, 1) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

		SET @start_time = GETDATE();

		RAISERROR('>> Truncating Table : silver.crm_cust_info', 0, 1) WITH NOWAIT;
		TRUNCATE TABLE silver.crm_cust_info;
		RAISERROR('>> Inserting Data Into : silver.crm_cust_info', 0, 1) WITH NOWAIT;

		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)

		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE 
			WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
			WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
			ELSE 'n/a'
		END cst_material_status,
		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE 'n/a'
		END cst_gndr,
		cst_create_date
		FROM (
			SELECT *,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) latest
		WHERE flag_last = 1;

		SET @end_time = GETDATE();
		SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
		RAISERROR('Load Duartion : %d seconds', 0, 1, @duration) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

		SET @start_time = GETDATE();

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

		SET @end_time = GETDATE();
		SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
		RAISERROR('Load Duartion : %d seconds', 0, 1, @duration) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

		SET @start_time = GETDATE();

		RAISERROR('>> Truncating Table : silver.crm_sales_details', 0, 1) WITH NOWAIT;
		TRUNCATE TABLE silver.crm_sales_details;
		RAISERROR('>> Inserting Data Into : silver.crm_sales_details', 0, 1) WITH NOWAIT;

		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)

		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE
				WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;

		SET @end_time = GETDATE();
		SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
		RAISERROR('Load Duartion : %d seconds', 0, 1, @duration) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

		RAISERROR('Loading ERP Tables...', 0, 1) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

		SET @start_time = GETDATE();

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

		SET @end_time = GETDATE();
		SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
		RAISERROR('Load Duartion : %d seconds', 0, 1, @duration) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

		SET @start_time = GETDATE();

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

		SET @end_time = GETDATE();
		SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
		RAISERROR('Load Duartion : %d seconds', 0, 1, @duration) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

		SET @start_time = GETDATE();

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

		SET @end_time = GETDATE();
		SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
		RAISERROR('Load Duartion : %d seconds', 0, 1, @duration) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

		RAISERROR('Silver Layer Load Completed Successfully', 0, 1) WITH NOWAIT;

		SET @batch_end_time = GETDATE();
		SET @batch_duration = DATEDIFF(SECOND, @batch_start_time, @batch_end_time);
		RAISERROR('Batch Load Duration : %d seconds', 0 , 1, @batch_duration) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

	END TRY
	BEGIN CATCH
		
		DECLARE @ErrorMessage NVARCHAR(4000);
		
		SET @ErrorMessage = ERROR_MESSAGE();

		RAISERROR('ERROR OCCURED DURING SILVER LOAD', 16, 1);
		RAISERROR('%s', 16, 1, @ErrorMessage);

	END CATCH

END;