/*

This procedure performs a full refresh of bronze layer tables by truncating ezisting data and bulk loading records from source csv files.
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN 
	SET NOCOUNT ON;

	DECLARE @start_time DATETIME,
			@end_time DATETIME,
			@duration INT;

	BEGIN TRY

		RAISERROR('=============================', 0,1) WITH NOWAIT;
		RAISERROR('Starting Bronze Layer Load', 0, 1) WITH NOWAIT;
        RAISERROR('==============================', 0, 1) WITH NOWAIT;

        RAISERROR('Loading CRM Tables...', 0, 1) WITH NOWAIT;
		RAISERROR('==============================', 0, 1) WITH NOWAIT;

		SET @start_time = GETDATE();

        RAISERROR('Truncating: bronze.crm_cust_info', 0, 1) WITH NOWAIT;
        TRUNCATE TABLE bronze.crm_cust_info;

        RAISERROR('Bulk Inserting: bronze.crm_cust_info', 0, 1) WITH NOWAIT;
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\prema\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        RAISERROR('Load Duration: %d seconds', 0, 1, @duration) WITH NOWAIT;
        RAISERROR('==============================', 0, 1) WITH NOWAIT;

        SET @start_time = GETDATE();

        RAISERROR('Truncating: bronze.crm_prd_info', 0, 1) WITH NOWAIT;
        TRUNCATE TABLE bronze.crm_prd_info;

        RAISERROR('Bulk Inserting: bronze.crm_prd_info', 0, 1) WITH NOWAIT;
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\prema\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        RAISERROR('Load Duration: %d seconds', 0, 1, @duration) WITH NOWAIT;
        RAISERROR('==============================', 0, 1) WITH NOWAIT;

        SET @start_time = GETDATE();

        RAISERROR('Truncating: bronze.crm_sales_details', 0, 1) WITH NOWAIT;
        TRUNCATE TABLE bronze.crm_sales_details;

        RAISERROR('Bulk Inserting: bronze.crm_sales_details', 0, 1) WITH NOWAIT;
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\prema\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        RAISERROR('Load Duration: %d seconds', 0, 1, @duration) WITH NOWAIT;
        RAISERROR('==============================', 0, 1) WITH NOWAIT;

        RAISERROR('Loading ERP Tables...', 0, 1) WITH NOWAIT;
        RAISERROR('==============================', 0, 1) WITH NOWAIT;

        SET @start_time = GETDATE();

        RAISERROR('Truncating: bronze.erp_cust_az12', 0, 1) WITH NOWAIT;
        TRUNCATE TABLE bronze.erp_cust_az12;

        RAISERROR('Bulk Inserting: bronze.erp_cust_az12', 0, 1) WITH NOWAIT;
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\prema\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        RAISERROR('Load Duration: %d seconds', 0, 1, @duration) WITH NOWAIT;
        RAISERROR('==============================', 0, 1) WITH NOWAIT;

        SET @start_time = GETDATE();

        RAISERROR('Truncating: bronze.erp_loc_a101', 0, 1) WITH NOWAIT;
        TRUNCATE TABLE bronze.erp_loc_a101;

        RAISERROR('Bulk Inserting: bronze.erp_loc_a101', 0, 1) WITH NOWAIT;
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\prema\Desktop\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        RAISERROR('Load Duration: %d seconds', 0, 1, @duration) WITH NOWAIT;
        RAISERROR('==============================', 0, 1) WITH NOWAIT;

        SET @start_time = GETDATE();

        RAISERROR('Truncating: bronze.erp_px_cat_g1v2', 0, 1) WITH NOWAIT;
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        RAISERROR('Bulk Inserting: bronze.erp_px_cat_g1v2', 0, 1) WITH NOWAIT;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\prema\Desktop\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        RAISERROR('Load Duration: %d seconds', 0, 1, @duration) WITH NOWAIT;
        RAISERROR('==============================', 0, 1) WITH NOWAIT;

        RAISERROR('Bronze Layer Load Completed Successfully', 0, 1) WITH NOWAIT;

    END TRY
    BEGIN CATCH

        DECLARE @ErrorMessage NVARCHAR(4000);

        SET @ErrorMessage = ERROR_MESSAGE();

        RAISERROR('ERROR OCCURRED DURING BRONZE LOAD', 16, 1);
        RAISERROR('%s', 16, 1, @ErrorMessage);

    END CATCH
END;