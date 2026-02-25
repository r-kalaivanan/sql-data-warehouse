# Gold Layer Data Catalog

**Database:** data_warehouse  
**Schema:** gold  

---

## Overview

The Gold layer represents the final, business-ready data model in the data warehouse. It implements a **Star Schema** design pattern consisting of dimension tables and fact tables optimized for analytics and reporting. The Gold layer views combine and transform data from the Silver layer to provide clean, enriched datasets ready for consumption by business intelligence tools and end users.

### Architecture

The Gold layer follows the Kimball dimensional modeling approach:

- **Dimension Tables**: Provide descriptive context for business analysis
- **Fact Tables**: Contain measurable business metrics and foreign keys to dimensions

---

## Data Objects

### 1. dim_customers (Customer Dimension)

**Object Type:** View  
**Description:** Customer dimension table providing a comprehensive view of customer information by integrating data from both CRM and ERP systems. This dimension enables customer-centric analysis and segmentation.

#### Column Specifications

| Column Name     | Data Type    | Description                          | Source                                  | Business Rules                                                                  |
| --------------- | ------------ | ------------------------------------ | --------------------------------------- | ------------------------------------------------------------------------------- |
| customer_key    | INT          | Surrogate key for customer dimension | Generated                               | Auto-generated sequential number using ROW_NUMBER()                             |
| customer_id     | INT          | Customer identifier from CRM system  | silver.crm_cust_info.cst_id             | Primary business key                                                            |
| customer_number | NVARCHAR(50) | Customer reference number            | silver.crm_cust_info.cst_key            | Used for joining with ERP data                                                  |
| first_name      | NVARCHAR(50) | Customer first name                  | silver.crm_cust_info.cst_firstname      |                                                                                 |
| last_name       | NVARCHAR(50) | Customer last name                   | silver.crm_cust_info.cst_lastname       |                                                                                 |
| country         | NVARCHAR(50) | Customer country of residence        | silver.erp_loc_a101.cntry               |                                                                                 |
| marital_status  | NVARCHAR(50) | Customer marital status              | silver.crm_cust_info.cst_marital_status |                                                                                 |
| gender          | NVARCHAR(50) | Customer gender                      | silver.erp_cust_az12.gen                | If CRM gender is 'n/a', keep it; otherwise use ERP gender with 'n/a' as default |
| birth_date      | DATE         | Customer date of birth               | silver.erp_cust_az12.bdate              |                                                                                 |
| create_date     | DATE         | Customer creation date in CRM        | silver.crm_cust_info.cst_create_date    |                                                                                 |

#### Data Lineage

```
bronze.crm_cust_info → silver.crm_cust_info ┐
                                             ├─→ gold.dim_customers
bronze.erp_cust_az12 → silver.erp_cust_az12 ┤
bronze.erp_loc_a101  → silver.erp_loc_a101  ┘
```

#### Transformation Logic

- **Customer Key Generation**: Surrogate key generated using `ROW_NUMBER() OVER (ORDER BY cst_id)`
- **Gender Enrichment**: Prioritizes ERP gender data when CRM gender is not 'n/a', defaulting to 'n/a' when ERP data is missing
- **Data Integration**: LEFT JOINs ensure all CRM customers are included even without matching ERP records

#### Relationships

- **Referenced By**: `gold.fact_sales` (via customer_key)
- **Join Key**: customer_number matches with ERP cid field

#### Data Quality Considerations

- Some customers may not have ERP data (gender, birth_date, country will be NULL)
- Gender field uses conditional logic to merge CRM and ERP values
- Customer_key is generated at query time and may change if source data order changes

---

### 2. dim_products (Product Dimension)

**Object Type:** View  
**Description:** Product dimension table providing detailed product information by combining CRM product data with ERP category and classification data. This dimension enables product performance analysis and category management.

#### Column Specifications

| Column Name        | Data Type    | Description                         | Source                             | Business Rules                                      |
| ------------------ | ------------ | ----------------------------------- | ---------------------------------- | --------------------------------------------------- |
| product_key        | INT          | Surrogate key for product dimension | Generated                          | Auto-generated sequential number using ROW_NUMBER() |
| product_id         | INT          | Product identifier from CRM system  | silver.crm_prd_info.prd_id         | Primary business key                                |
| product_number     | NVARCHAR(50) | Product reference number            | silver.crm_prd_info.prd_key        | Used for joining with sales transactions            |
| product_name       | NVARCHAR(50) | Product name                        | silver.crm_prd_info.prd_nm         |                                                     |
| category_id        | NVARCHAR(50) | Category identifier                 | silver.crm_prd_info.cat_id         | Foreign key to ERP category system                  |
| category           | NVARCHAR(50) | Product category                    | silver.erp_px_cat_g1v2.cat         |                                                     |
| subcategory        | NVARCHAR(50) | Product subcategory                 | silver.erp_px_cat_g1v2.subcat      |                                                     |
| maintenance        | NVARCHAR(50) | Maintenance classification          | silver.erp_px_cat_g1v2.maintenance |                                                     |
| product_cost       | INT          | Product cost                        | silver.crm_prd_info.prd_cost       |                                                     |
| product_line       | NVARCHAR(50) | Product line classification         | silver.crm_prd_info.prd_line       |                                                     |
| product_start_date | DATE         | Product introduction date           | silver.crm_prd_info.prd_start_dt   |                                                     |

#### Data Lineage

```
bronze.crm_prd_info   → silver.crm_prd_info      ┐
                                                  ├─→ gold.dim_products
bronze.erp_px_cat_g1v2 → silver.erp_px_cat_g1v2 ┘
```

#### Transformation Logic

- **Product Key Generation**: Surrogate key generated using `ROW_NUMBER() OVER (ORDER BY prd_start_dt, prd_key)`
- **Active Products Filter**: Only includes products where `prd_end_dt IS NULL` (currently active products)
- **Category Enrichment**: LEFT JOIN with ERP category data to add classification details

#### Relationships

- **Referenced By**: `gold.fact_sales` (via product_key)
- **Join Key**: product_number used to link with sales transactions

#### Data Quality Considerations

- Only active products (prd_end_dt IS NULL) are included
- Some products may not have category data (category, subcategory, maintenance will be NULL)
- Product_key ordering considers both start date and product key for consistent ordering

---

### 3. fact_sales (Sales Fact Table)

**Object Type:** View  
**Description:** Central fact table capturing sales transactions with foreign keys to customer and product dimensions. This fact table enables comprehensive sales analysis, trend identification, and performance reporting.

#### Column Specifications

| Column Name   | Data Type    | Description                       | Source                                | Business Rules         |
| ------------- | ------------ | --------------------------------- | ------------------------------------- | ---------------------- |
| order_number  | NVARCHAR(50) | Unique sales order identifier     | silver.crm_sales_details.sls_ord_num  | Primary key            |
| product_key   | INT          | Foreign key to product dimension  | gold.dim_products.product_key         | Links to dim_products  |
| customer_key  | INT          | Foreign key to customer dimension | gold.dim_customers.customer_key       | Links to dim_customers |
| order_date    | DATE         | Date order was placed             | silver.crm_sales_details.sls_order_dt |                        |
| shipping_date | DATE         | Date order was shipped            | silver.crm_sales_details.sls_ship_dt  |                        |
| due_date      | DATE         | Date order is due                 | silver.crm_sales_details.sls_due_dt   |                        |
| sales_amount  | INT          | Total sales amount                | silver.crm_sales_details.sls_sales    | Fact measure           |
| quantity      | INT          | Quantity of items sold            | silver.crm_sales_details.sls_quantity | Fact measure           |
| price         | INT          | Unit price                        | silver.crm_sales_details.sls_price    | Fact measure           |

#### Data Lineage

```
bronze.crm_sales_details → silver.crm_sales_details ┐
                                                     │
gold.dim_products (for product_key lookup)          ├─→ gold.fact_sales
                                                     │
gold.dim_customers (for customer_key lookup)        ┘
```

#### Transformation Logic

- **Dimension Key Lookup**: Joins with dimension views to replace business keys with surrogate keys
- **Product Mapping**: Matches `sls_prd_key` with `dim_products.product_number`
- **Customer Mapping**: Matches `sls_cust_id` with `dim_customers.customer_id`

#### Relationships

- **References**:
  - `gold.dim_products` (via product_key)
  - `gold.dim_customers` (via customer_key)

#### Grain

The grain of this fact table is one row per order line item.

#### Fact Types

- **Additive Facts**: sales_amount, quantity
- **Semi-Additive Facts**: price (can be averaged but not summed across products)

#### Data Quality Considerations

- LEFT JOINs with dimensions may result in NULL keys if matching records don't exist
- Order numbers should be unique per line item
- Date fields (order_date, shipping_date, due_date) enable time-series analysis

---

## Data Model Diagram

### Star Schema Relationships

```
                    ┌─────────────────────┐
                    │   dim_customers     │
                    │─────────────────────│
                    │ customer_key (PK)   │
                    │ customer_id         │
                    │ customer_number     │
                    │ first_name          │
                    │ last_name           │
                    │ country             │
                    │ marital_status      │
                    │ gender              │
                    │ birth_date          │
                    │ create_date         │
                    └──────────┬──────────┘
                               │
                               │
                               │ customer_key (FK)
                               │
                    ┌──────────▼──────────┐
                    │    fact_sales       │
                    │─────────────────────│
                    │ order_number (PK)   │
                    │ product_key (FK)    │
                    │ customer_key (FK)   │
                    │ order_date          │
                    │ shipping_date       │
                    │ due_date            │
                    │ sales_amount        │
                    │ quantity            │
                    │ price               │
                    └──────────▲──────────┘
                               │
                               │ product_key (FK)
                               │
                    ┌──────────┴──────────┐
                    │   dim_products      │
                    │─────────────────────│
                    │ product_key (PK)    │
                    │ product_id          │
                    │ product_number      │
                    │ product_name        │
                    │ category_id         │
                    │ category            │
                    │ subcategory         │
                    │ maintenance         │
                    │ product_cost        │
                    │ product_line        │
                    │ product_start_date  │
                    └─────────────────────┘
```

---

## Usage Examples

### Example 1: Total Sales by Customer

```sql
SELECT
    dc.first_name,
    dc.last_name,
    dc.country,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.quantity) AS total_quantity,
    COUNT(DISTINCT fs.order_number) AS order_count
FROM gold.fact_sales fs
INNER JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key
GROUP BY dc.first_name, dc.last_name, dc.country
ORDER BY total_sales DESC;
```

### Example 2: Sales by Product Category

```sql
SELECT
    dp.category,
    dp.subcategory,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.quantity) AS total_quantity,
    AVG(fs.price) AS avg_price
FROM gold.fact_sales fs
INNER JOIN gold.dim_products dp ON fs.product_key = dp.product_key
GROUP BY dp.category, dp.subcategory
ORDER BY total_sales DESC;
```

### Example 3: Monthly Sales Trend

```sql
SELECT
    YEAR(fs.order_date) AS order_year,
    MONTH(fs.order_date) AS order_month,
    SUM(fs.sales_amount) AS total_sales,
    COUNT(DISTINCT fs.order_number) AS order_count,
    COUNT(DISTINCT fs.customer_key) AS unique_customers
FROM gold.fact_sales fs
GROUP BY YEAR(fs.order_date), MONTH(fs.order_date)
ORDER BY order_year, order_month;
```

### Example 4: Customer Demographics Analysis

```sql
SELECT
    dc.country,
    dc.gender,
    dc.marital_status,
    COUNT(DISTINCT dc.customer_key) AS customer_count,
    AVG(DATEDIFF(YEAR, dc.birth_date, GETDATE())) AS avg_age
FROM gold.dim_customers dc
WHERE dc.birth_date IS NOT NULL
GROUP BY dc.country, dc.gender, dc.marital_status
ORDER BY customer_count DESC;
```

### Example 5: Product Performance Analysis

```sql
SELECT
    dp.product_name,
    dp.product_line,
    dp.category,
    SUM(fs.sales_amount) AS total_revenue,
    SUM(fs.quantity) AS units_sold,
    SUM(fs.sales_amount) / NULLIF(SUM(fs.quantity), 0) AS avg_selling_price,
    dp.product_cost,
    SUM(fs.sales_amount) - (dp.product_cost * SUM(fs.quantity)) AS gross_profit
FROM gold.fact_sales fs
INNER JOIN gold.dim_products dp ON fs.product_key = dp.product_key
GROUP BY dp.product_name, dp.product_line, dp.category, dp.product_cost
ORDER BY total_revenue DESC;
```

---

## Data Governance

### Data Ownership

- **Business Owner**: Sales and Marketing Department
- **Technical Owner**: Data Engineering Team
- **Data Steward**: Business Intelligence Team

### Data Refresh

- Views are refreshed in real-time based on underlying Silver layer tables
- Silver layer is updated through ETL processes from Bronze layer
- Bronze layer receives data from source systems (CRM and ERP)

### Data Retention

- Historical data is maintained in the Silver layer
- Gold layer views show current and historical data based on Silver layer content
- Product dimension shows only active products (prd_end_dt IS NULL)

### Data Quality Rules

1. **Referential Integrity**:
   - All fact_sales records should have valid product_key and customer_key
   - LEFT JOINs may create NULL keys requiring data quality monitoring

2. **Business Rules**:
   - Only active products appear in dim_products
   - Gender field uses specific merge logic between CRM and ERP
   - Surrogate keys are generated at query time

3. **Data Completeness**:
   - Monitor NULL values in customer country, gender, and birth_date
   - Monitor NULL values in product category information
   - Track unmatched dimension keys in fact_sales

---

## Access and Security

### Access Pattern

Gold layer views are designed for:

- Business Intelligence tools (Power BI, Tableau, etc.)
- Ad-hoc analytics queries
- Reporting applications
- Data science workloads

### Recommended Permissions

```sql
-- Grant SELECT permission to reporting users
GRANT SELECT ON gold.dim_customers TO reporting_users;
GRANT SELECT ON gold.dim_products TO reporting_users;
GRANT SELECT ON gold.fact_sales TO reporting_users;

-- Grant SELECT permission to BI service accounts
GRANT SELECT ON SCHEMA::gold TO bi_service_account;
```

---

## Performance Considerations

### Query Optimization Tips

1. **Indexing Strategy** (if materialized):
   - Create indexes on surrogate keys (customer_key, product_key)
   - Create indexes on frequently filtered columns (order_date, country, category)

2. **View Materialization**:
   - Consider materializing views as tables for large datasets
   - Implement incremental refresh strategy for materialized views

3. **Query Best Practices**:
   - Always join facts to dimensions (avoid Cartesian products)
   - Use appropriate date filters to limit result sets
   - Aggregate at the grain level before further calculations

### Current Limitations

- Views are not materialized, queries execute joins at runtime
- Surrogate keys regenerate on each query execution
- No indexes on view results
- Multiple nested views (fact_sales references dim_products and dim_customers)

---

## Change History

| Version | Date       | Author                | Changes                                     |
| ------- | ---------- | --------------------- | ------------------------------------------- |
| 1.0     | 2026-02-25 | Data Engineering Team | Initial creation of Gold layer data catalog |

---

## Related Documentation

- [High Level Architecture](high_level_architecture.pdf)
- [Data Model](data_model.pdf)
- [Data Flow](data_flow.pdf)
- [Integration Model](integration_model.pdf)

---

## Contact Information

For questions or issues related to the Gold layer data catalog:

- **Data Engineering Team**: data-engineering@company.com
- **BI Support**: bi-support@company.com
- **Project Repository**: [sql-data-warehouse](https://github.com/company/sql-data-warehouse)

---

_This document is maintained by the Data Engineering Team and should be updated whenever Gold layer schema changes occur._
