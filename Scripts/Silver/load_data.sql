USE Datawarehouse;

/*
    Load data into Silver layer tables from Bronze layer tables.
    ============================================================
    This script assumes that the tables in the Silver layer have already been created using the create_tables.sql script.
    ============================================================
    The script will first truncate the Silver layer tables to remove any existing data, 
        and then insert the cleaned and transformed data from the Bronze layer tables.   
*/

-- ===============================
-- Load data into (customer info table).
-- ===============================


TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info 
(
        cust_id,
        cust_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT 
        cust_id,
        cust_key,
        TRIM(cst_firstname), 
        TRIM(cst_lastname), 
        --
        CASE UPPER(TRIM(cst_marital_status))
            WHEN 'S' THEN 'Single'
            WHEN 'M' THEN 'Married'
            ELSE 'n/a' END,
        --
        CASE UPPER(TRIM(cst_gndr))
            WHEN 'M' THEN 'Male'
            WHEN 'F' THEN 'Female'
            ELSE 'n/a' END,
        --
        cst_create_date

    FROM (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY cst_create_date DESC) AS flag_last ,
            * 
        FROM bronze.crm_cust_info
        WHERE cust_id IS NOT NULL
        ) t
    WHERE flag_last = 1; -- Select the most recent record per customer


-- ===============================
-- Load data into (product info table).
-- ===============================

TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info
(
    prd_id,
    prd_key,
    cat_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT 
    prd_id,
    (SUBSTRING(prd_key, 7, LEN(prd_key))) AS prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,  -- first 5 characters of prd_key as id from table (bronze.px_cat_g1v2)
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost, -- replace null with 0;
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a' END AS prd_line,
    prd_start_dt,
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt
    FROM bronze.crm_prd_info;


-- ===============================
-- Load data into (sales details table).
-- ===============================

TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details
(
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
    
    CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
    ELSE CONVERT(DATE, CAST(sls_order_dt AS VARCHAR))
    END AS sls_order_dt ,

    CAST(CAST(sls_ship_dt AS varchar) AS DATE) AS sls_ship_dt,

    CAST(CAST(sls_due_dt AS varchar) AS DATE) AS sls_due_dt,

    CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales END AS sls_sales,

    sls_quantity,

    CASE WHEN sls_price <= 0 OR sls_price IS NULL
    THEN sls_sales / NULLIF(sls_quantity, 0) ELSE sls_price END AS sls_price

FROM bronze.crm_sales_details