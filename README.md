# SQL Data Warehouse

> A modern, enterprise-grade data warehouse built on SQL Server, featuring a medallion architecture (Bronze-Silver-Gold) for ETL processes, dimensional modeling, and business intelligence analytics.

[![SQL Server](https://img.shields.io/badge/SQL%20Server-2019+-CC2927?style=flat&logo=microsoft-sql-server)](https://www.microsoft.com/sql-server)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-Medallion-green.svg)]()

---

## Overview

This project implements a production-ready data warehouse solution that integrates data from multiple source systems (CRM and ERP) to provide a unified view for business intelligence and analytics. The warehouse follows the **Medallion Architecture** pattern with three distinct layers, ensuring data quality, scalability, and performance.

### Key Capabilities

- **Multi-Source Integration**: Combines CRM customer/sales data with ERP operational data
- **Data Quality Framework**: Automated quality checks and data validation at each layer
- **Dimensional Modeling**: Star schema design optimized for analytics and reporting
- **ETL Automation**: Stored procedures for automated data transformation and loading
- **Incremental Processing**: Handles full and incremental data loads efficiently

---

## Architecture

The data warehouse implements a **three-tier medallion architecture**:

```
┌─────────────────────────────────────────────────────────────────┐
│                         GOLD LAYER                               │
│              (Business-Ready Star Schema)                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ dim_customers   │  │  dim_products   │  │   fact_sales    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└───────────────────────────────────────┬─────────────────────────┘
                                        │
┌───────────────────────────────────────▼─────────────────────────┐
│                        SILVER LAYER                              │
│              (Cleansed & Standardized)                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ CRM Tables   │  │ ERP Tables   │  │ Quality      │          │
│  │ - Customers  │  │ - Demographics│ │ Checks       │          │
│  │ - Products   │  │ - Locations  │  │              │          │
│  │ - Sales      │  │ - Categories │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└───────────────────────────────────────┬─────────────────────────┘
                                        │
┌───────────────────────────────────────▼─────────────────────────┐
│                        BRONZE LAYER                              │
│              (Raw Ingestion Zone)                                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Source System Data (CRM & ERP)                          │   │
│  │  - Raw, unprocessed data                                 │   │
│  │  - Historical point-in-time snapshots                    │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Descriptions

#### Bronze Layer

- **Purpose**: Raw data ingestion from source systems
- **Characteristics**: Minimal transformation, preserves source data as-is
- **Sources**: CRM (customers, products, sales) and ERP (demographics, locations, categories)
- **Schema**: `bronze.crm_*` and `bronze.erp_*` tables

#### Silver Layer

- **Purpose**: Data cleansing, standardization, and quality assurance
- **Characteristics**:
  - Deduplication and data type standardization
  - Business rule application
  - Data quality checks and validation
  - Slow-changing dimension (SCD) handling
- **Schema**: `silver.crm_*` and `silver.erp_*` tables

#### Gold Layer

- **Purpose**: Business-ready dimensional model for analytics
- **Characteristics**:
  - Star schema design (dimensions + facts)
  - Optimized for query performance
  - Aggregated and enriched data
  - Ready for BI tools consumption
- **Schema**: `gold.dim_*` and `gold.fact_*` views

---

## Features

### Data Integration

- Multi-source data integration (CRM + ERP)
- Automated ETL pipelines with stored procedures
- Change data capture and historical tracking
- Data lineage and transformation documentation

### Data Quality

- Automated quality checks at each layer
- Null value handling and default value assignment
- Data validation rules and constraints
- Duplicate detection and resolution

### Analytics & Reporting

- Star schema dimensional model
- Pre-aggregated metrics for performance
- Time-series analysis capabilities
- Customer and product analytics

### Performance & Scalability

- Optimized query patterns
- Materialized views for frequently accessed data
- Incremental loading strategies
- Partition-ready design

---

## Prerequisites

Before setting up the data warehouse, ensure you have:

- **SQL Server 2019 or later** (Enterprise, Standard, or Developer Edition)
- **SQL Server Management Studio (SSMS)** 18.0 or later
- **Minimum Hardware**:
  - 8 GB RAM (16 GB recommended)
  - 50 GB available disk space
  - Multi-core processor
- **Permissions**:
  - `sysadmin` or `db_creator` role for database creation
  - Ability to execute DDL and DML statements

---

## Installation

Follow these steps to set up the data warehouse:

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/sql-data-warehouse.git
cd sql-data-warehouse
```

### Step 2: Initialize the Database

Run the initialization script to create the database and schemas:

```sql
-- Connect to SQL Server using SSMS or sqlcmd
sqlcmd -S localhost -i scripts/init_data_warehouse.sql
```

This creates:

- `data_warehouse` database
- Three schemas: `bronze`, `silver`, `gold`

### Step 3: Create Bronze Layer Tables

```sql
-- Create CRM tables
sqlcmd -S localhost -d data_warehouse -i scripts/bronze/create_bronze_crm_tables.sql

-- Create ERP tables
sqlcmd -S localhost -d data_warehouse -i scripts/bronze/create_bronze_erp_tables.sql
```

### Step 4: Create Silver Layer Tables

```sql
-- Create CRM silver tables
sqlcmd -S localhost -d data_warehouse -i scripts/silver/create_silver_crm_tables.sql

-- Create ERP silver tables
sqlcmd -S localhost -d data_warehouse -i scripts/silver/create_silver_erp_tables.sql

-- Create ETL stored procedure
sqlcmd -S localhost -d data_warehouse -i scripts/silver/insert_stored_procedure.sql
```

### Step 5: Create Gold Layer Views

```sql
-- Create dimensional model
sqlcmd -S localhost -d data_warehouse -i scripts/gold/ddl_gold.sql
```

### Step 6: Load Sample Data (Optional)

```sql
-- Insert sample data into bronze tables
sqlcmd -S localhost -d data_warehouse -i scripts/bronze/insert_bronze_crm_erp_tables.sql
```

### Step 7: Run ETL Process

```sql
-- Execute the silver layer ETL procedure
USE data_warehouse;
GO
EXEC silver.load_silver;
GO
```

---

## Project Structure

```
sql-data-warehouse/
│
├── README.md                          # This file
├── LICENSE                            # License information
│
├── docs/                              # Documentation
│   ├── gold_layer_data_catalog.md    # Gold layer data dictionary
│   ├── data_model.pdf                # Data model diagrams
│   ├── data_flow.pdf                 # Data flow documentation
│   ├── high_level_architecture.pdf   # Architecture overview
│   └── integration_model.pdf         # Integration patterns
│
├── datasets/                          # Sample datasets (optional)
│
├── scripts/                           # SQL scripts
│   ├── init_data_warehouse.sql       # Database initialization
│   │
│   ├── bronze/                       # Bronze layer scripts
│   │   ├── create_bronze_crm_tables.sql
│   │   ├── create_bronze_erp_tables.sql
│   │   └── insert_bronze_crm_erp_tables.sql
│   │
│   ├── silver/                       # Silver layer scripts
│   │   ├── create_silver_crm_tables.sql
│   │   ├── create_silver_erp_tables.sql
│   │   ├── insert_stored_procedure.sql
│   │   │
│   │   ├── crm/                      # CRM transformations
│   │   │   ├── cust_info/
│   │   │   │   ├── insert_transformed_data.sql
│   │   │   │   └── quality_check.sql
│   │   │   ├── prd_info/
│   │   │   │   ├── insert_transformed_data.sql
│   │   │   │   └── quality_check.sql
│   │   │   └── sales_details/
│   │   │       ├── insert_transformed_data.sql
│   │   │       └── quality_check.sql
│   │   │
│   │   └── erp/                      # ERP transformations
│   │       ├── cust_az12/
│   │       │   ├── insert_transformed_data.sql
│   │       │   └── quality_check.sql
│   │       ├── loc_a101/
│   │       │   ├── insert_transformed_data.sql
│   │       │   └── quality_check.sql
│   │       └── px_cat_g1v2/
│   │           ├── insert_transformed_data.sql
│   │           └── quality_check.sql
│   │
│   └── gold/                         # Gold layer scripts
│       └── ddl_gold.sql              # Dimensional model views
│
└── tests/                            # Test scripts
```

---

## Data Flow

### End-to-End Pipeline

```
1. Source Systems (CRM & ERP)
   │
   ├─→ Data Extraction
   │
2. Bronze Layer (Raw Ingestion)
   │
   ├─→ Data Cleansing & Standardization
   │   - Remove duplicates
   │   - Standardize data types
   │   - Apply business rules
   │
3. Silver Layer (Quality & Transformation)
   │
   ├─→ Data Integration & Enrichment
   │   - Join CRM and ERP data
   │   - Create surrogate keys
   │   - Build dimensions and facts
   │
4. Gold Layer (Star Schema)
   │
   └─→ BI Tools & Analytics
       - Power BI
       - Tableau
       - Custom Reports
```

### ETL Process

The `silver.load_silver` stored procedure orchestrates the entire ETL pipeline:

1. **Truncate Silver Tables**: Clears existing data for full refresh
2. **Transform CRM Data**:
   - Customer information (deduplication, standardization)
   - Product information (category parsing, null handling)
   - Sales details (date conversion, data validation)
3. **Transform ERP Data**:
   - Customer demographics
   - Location data
   - Product categories
4. **Data Quality Checks**: Validates transformed data
5. **Logging**: Records execution time and row counts

---

## Usage

### Querying the Data Warehouse

#### Example 1: Customer Sales Summary

```sql
SELECT
    dc.first_name,
    dc.last_name,
    dc.country,
    SUM(fs.sales_amount) AS total_sales,
    COUNT(DISTINCT fs.order_number) AS order_count
FROM gold.fact_sales fs
INNER JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key
GROUP BY dc.first_name, dc.last_name, dc.country
ORDER BY total_sales DESC;
```

#### Example 2: Product Performance by Category

```sql
SELECT
    dp.category,
    dp.subcategory,
    SUM(fs.sales_amount) AS total_revenue,
    SUM(fs.quantity) AS units_sold,
    AVG(fs.price) AS avg_price
FROM gold.fact_sales fs
INNER JOIN gold.dim_products dp ON fs.product_key = dp.product_key
GROUP BY dp.category, dp.subcategory
ORDER BY total_revenue DESC;
```

#### Example 3: Monthly Sales Trend

```sql
SELECT
    YEAR(fs.order_date) AS year,
    MONTH(fs.order_date) AS month,
    SUM(fs.sales_amount) AS monthly_sales,
    COUNT(DISTINCT fs.customer_key) AS unique_customers
FROM gold.fact_sales fs
GROUP BY YEAR(fs.order_date), MONTH(fs.order_date)
ORDER BY year, month;
```

### Running Quality Checks

Execute quality check scripts to validate data integrity:

```sql
-- Check customer data quality
:r scripts/silver/crm/cust_info/quality_check.sql

-- Check product data quality
:r scripts/silver/crm/prd_info/quality_check.sql

-- Check sales data quality
:r scripts/silver/crm/sales_details/quality_check.sql
```

### Refreshing the Data Warehouse

To refresh all silver layer data from bronze:

```sql
USE data_warehouse;
GO

-- Execute ETL procedure
EXEC silver.load_silver;
GO

-- Verify gold layer views
SELECT COUNT(*) FROM gold.dim_customers;
SELECT COUNT(*) FROM gold.dim_products;
SELECT COUNT(*) FROM gold.fact_sales;
```

---

## Documentation

Comprehensive documentation is available in the `docs/` folder:

- **[Gold Layer Data Catalog](docs/gold_layer_data_catalog.md)**: Complete data dictionary for all gold layer objects, including column specifications, data lineage, and usage examples

- **Data Model**: Entity-relationship diagrams and star schema design

- **Data Flow**: Visual representation of data movement through layers

- **High Level Architecture**: System architecture and component interactions

- **Integration Model**: Source system integration patterns

---

## Data Governance

### Data Quality Standards

- **Completeness**: All required fields must be populated
- **Accuracy**: Data validated against business rules
- **Consistency**: Standardized formats across sources
- **Timeliness**: Regular refresh schedule maintained

### Access Control

```sql
-- Grant read access to analysts
GRANT SELECT ON SCHEMA::gold TO analyst_role;

-- Grant ETL execution permissions
GRANT EXECUTE ON silver.load_silver TO etl_service_account;

-- Restrict bronze layer access
DENY SELECT ON SCHEMA::bronze TO analyst_role;
```

### Data Retention

- **Bronze Layer**: 90 days rolling retention
- **Silver Layer**: 2 years historical data
- **Gold Layer**: Full historical archive

---

## Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**: Follow SQL best practices and naming conventions
4. **Test thoroughly**: Validate all scripts before committing
5. **Document changes**: Update relevant documentation
6. **Submit a pull request**: Provide clear description of changes

### Coding Standards

- Use consistent indentation (4 spaces)
- Include comments for complex logic
- Follow naming conventions:
  - Tables: `schema_sourcesystem_tablename`
  - Views: `dim_*` or `fact_*`
  - Procedures: `verb_noun` (e.g., `load_silver`)
- Always include error handling in stored procedures

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact & Support

For questions, issues, or suggestions:

- **Email**: data-engineering@company.com
- **Issue Tracker**: [GitHub Issues](https://github.com/your-org/sql-data-warehouse/issues)
- **Documentation**: [Project Wiki](https://github.com/your-org/sql-data-warehouse/wiki)

---

## Acknowledgments

Special thanks to **Data with Barra** for the inspiration and knowledge shared through his YouTube channel.

-
