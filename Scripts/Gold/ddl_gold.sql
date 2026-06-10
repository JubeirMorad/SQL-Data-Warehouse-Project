/*
    ===============================================================================
    DDL Script: Create Gold Views
    -------------------------------------------------------------------------------
    Script Purpose:
        This script creates views for the Gold layer in the data warehouse. 
        The Gold layer represents the final dimension and fact tables (Star Schema)

        Each view performs transformations and combines data from the Silver layer 
        to produce a clean, enriched, and business-ready dataset.

    Usage:
        - These views can be queried directly for analytics and reporting.
    ===============================================================================
*/


--==============================================
-- Create dimension table : gold.dim_customers
--==============================================
IF OBJECT_ID('gold.dim_customers') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cust_id) AS customer_number, -- surrogate key
    ci.cust_id  AS customer_id,
    ci.cust_key AS customer_key,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    ci.cst_marital_status AS marital_status,

    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE ISNULL(ca.GEN, 'n/a')
    END AS gender,

    la.CNTRY AS country,

    ca.BDATE AS birthdate,

    ci.cst_create_date AS create_date
    
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ca.CID = ci.cust_key
LEFT JOIN silver.erp_loc_a101 la
ON la.CID = ci.cust_key

GO


--==============================================
-- Create dimension table : gold.dim_current_products
--==============================================
IF OBJECT_ID('gold.dim_current_products') IS NOT NULL
    DROP VIEW gold.dim_current_products;
GO

CREATE VIEW gold.dim_current_products AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY prd_start_dt , prd_id) AS product_number,
    pi.prd_id AS product_id,
    pi.prd_key AS product_key,
    pi.prd_nm AS produce_name,
    pi.cat_id AS category_id,

    ISNULL(cat.CAT, 'n/a') AS category_name,

    ISNULL(cat.SUBCAT, 'n/a') AS subcategory,

    pi.prd_cost AS cost,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS start_date,
    ISNULL(cat.MAINTENANCE, 'n/a') AS maintenance 

FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 cat
ON cat.ID = pi.cat_id
WHERE pi.prd_end_dt IS NULL
GO


--==============================================
-- Create dimension table : gold.dim_history_products
--==============================================
IF OBJECT_ID('gold.dim_history_products') IS NOT NULL
    DROP VIEW gold.dim_history_products;
GO

CREATE VIEW gold.dim_history_products AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY prd_start_dt , prd_id) AS product_number,
    pi.prd_id AS product_id,
    pi.prd_key AS product_key,
    pi.prd_nm AS produce_name,
    pi.cat_id AS category_id,

    ISNULL(cat.CAT, 'n/a') AS category_name,

    ISNULL(cat.SUBCAT, 'n/a') AS subcategory,

    pi.prd_cost AS cost,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS start_date,
    pi.prd_end_dt AS end_date,
    ISNULL(cat.MAINTENANCE, 'n/a') AS maintenance 

FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 cat
ON cat.ID = pi.cat_id
GO



--==============================================
-- Create dimension table : gold.fact_sales
--==============================================
IF OBJECT_ID('gold.fact_sales') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
       sd.sls_ord_num AS order_id

      ,pi.product_number

      ,ci.customer_number
      
      ,sd.sls_order_dt AS order_date
      ,sd.sls_ship_dt AS ship_date
      ,sd.sls_due_dt AS due_date
      ,sd.sls_sales AS sales
      ,sd.sls_quantity AS quantity
      ,sd.sls_price AS price
      
  FROM silver.crm_sales_details sd
  LEFT JOIN gold.dim_customers ci 
  ON ci.customer_id = sd.sls_cust_id
  LEFT JOIN gold.dim_current_products pi
  ON pi.product_key = sd.sls_prd_key

GO