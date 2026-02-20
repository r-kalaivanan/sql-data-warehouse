/*

Create Databases and Schemas

Script Purpose : This scripts creates a new database named 'data_warehouse' after checking if it already exists. If the database already exists it is droppes and recreated. Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.

Warning : Running this script will drop the entire 'data_warehouse' database if it exists. All data in the database will be permanenty deleted. Proceed with caution and ensure you have proper backups before running this script.

*/ 


USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'data_warehouse')
BEGIN
	ALTER DATABASE data_warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE  data_warehouse;
END;
GO

CREATE DATABASE data_warehouse;
GO

USE data_warehouse;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO