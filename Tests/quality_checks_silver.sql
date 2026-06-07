
USE DataWarehouse;

-- Check if (cust_id) is duplicated or null.
SELECT 
    cust_id 
FROM silver.crm_cust_info
GROUP BY  cust_id 
HAVING COUNT(cust_id) > 1 OR cust_id is null


-- check if (cust_key) has white spaces.
SELECT 
    * 
FROM silver.crm_cust_info
WHERE cust_key != TRIM(cust_key) OR cust_key IS NULL;
 

-- check if (cst_firstname) has white spaces.
SELECT 
    cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


-- check if (cst_lastname) has white spaces.
SELECT cst_lastname FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;


-- Data Standardization & Consistency
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;


-- =======================================
-- Checks for (product info table).
-- =======================================


-- check if (prd_id) is duplicated or null.
SELECT 
    prd_id,
    COUNT(prd_id) AS cnt_prd_id
    FROM silver.crm_prd_info
    GROUP BY prd_id
    HAVING COUNT(prd_id) > 1 OR prd_id is null;


-- check if (prd_key) has white spaces or equals null.
SELECT 
    prd_key
FROM silver.crm_prd_info
WHERE prd_key != TRIM(prd_key) OR prd_key IS NULL;


-- check if (prd_key) has length less than 5 characters.
SELECT 
    prd_key
    FROM silver.crm_prd_info
    WHERE LEN(prd_key) < 5 ;


-- check if (prd_nm) has white spaces or equals null.
SELECT 
    prd_nm
    FROM silver.crm_prd_info
    WHERE prd_nm != TRIM(prd_nm) OR prd_nm IS NULL;


-- check if (prd_cost) is negative or equals null.
SELECT 
    prd_cost
    FROM silver.crm_prd_info
    WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Data Standardization & Consistency
SELECT DISTINCT prd_line FROM silver.crm_prd_info;


-- check if (prd_start_dt) is greater than (prd_end_dt) or start date is null.
SELECT 
    *
    FROM silver.crm_prd_info
    WHERE prd_start_dt > prd_end_dt OR prd_start_dt IS NULL ;


-- check for category id in (prd_key) if it exists in (silver.erp.px_cat_g1v2) table.
SELECT 
    cat_id   
    FROM silver.crm_prd_info
    WHERE cat_id NOT IN (SELECT DISTINCT ID FROM bronze.erp_px_cat_g1v2);



-- =======================================
-- Checks for (sales details table).
-- =======================================


-- check if poduct key exists in product info table (crm_prd_info)
SELECT 
    * 
FROM silver.crm_sales_details
WHERE  sls_prd_key NOT IN (SELECT DISTINCT prd_key FROM silver.crm_prd_info)


-- check if (product key , order number) are duplicated or have value (null).
SELECT 
    sls_ord_num,
    sls_prd_key,
    COUNT(*)
FROM silver.crm_sales_details
GROUP BY sls_ord_num , sls_prd_key
HAVING COUNT (*) > 1 OR sls_ord_num IS NULL OR sls_prd_key IS NULL;


-- check if customer id exists in customer table (crm_cust_info);
SELECT 
*
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT  cust_id FROM silver.crm_cust_info)


-- check if (sls_order_dt) is not valid.
SELECT 
    sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL
OR sls_order_dt < '1900-01-01'
OR sls_order_dt > '2050-01-01'


-- check if (sls_ship_dt) is not valid

SELECT 
    sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt IS NULL
OR sls_ship_dt < '1900-01-01'
OR sls_ship_dt > '2050-01-01'


-- check if (sls_ship_dt) is not valid
SELECT 
    sls_due_dt
FROM silver.crm_sales_details
WHERE  sls_due_dt IS NULL
OR sls_due_dt < '1900-01-01'
OR sls_due_dt > '2050-01-01'


-- check if sales less than 0 or null
SELECT 
    sls_sales
FROM silver.crm_sales_details
WHERE sls_sales < 0 OR sls_sales IS NULL


-- check if quantity is valid
SELECT 
sls_quantity
FROM silver.crm_sales_details
WHERE sls_quantity <= 0 OR sls_quantity IS NULL


-- check if price is valid
SELECT 
sls_price
FROM silver.crm_sales_details
WHERE sls_price < 0 OR sls_price IS NULL


-- check Data Consistency: Sales = Quantity * Price
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- =======================================
-- Checks for ( cust_az12 ).
-- =======================================

-- check if (CID) is duplicated or null.
SELECT 
    CID,
    COUNT(CID) AS cnt_CID
    FROM silver.erp_cust_az12
    GROUP BY CID
    HAVING COUNT(CID) > 1 OR CID IS NULL;


-- Check if (CID) is (cust_key) of (crm_cust_info) table.

SELECT 
    CID
    FROM silver.erp_cust_az12
    WHERE CID NOT IN (SELECT  cust_key FROM silver.crm_cust_info)
--
SELECT 
    SUBSTRING(CID, 1, 3)
    FROM silver.erp_cust_az12
    WHERE CID NOT IN (SELECT  cust_key FROM silver.crm_cust_info)
    GROUP BY SUBSTRING(CID, 1, 3)

            -- all the CID values in (bronze.erp_cust_az12) 
            -- table that start with 'NAS' not in (SELECT  cust_key FROM silver.crm_cust_info) 



-- Check if (BDATE) is not valid
SELECT
    BDATE
    FROM silver.erp_cust_az12
    WHERE BDATE IS NULL
    OR BDATE < '1900-01-01'
    OR BDATE > '2050-01-01';


-- Data Standardization & Consistency
SELECT DISTINCT GEN FROM silver.erp_cust_az12;


-- ===============================
-- Checks for (loc_a101).
-- ===============================

-- Check if (CID) is duplicated or null.
SELECT 
    CID,
    COUNT(CID) AS cnt_CID
    FROM silver.erp_loc_a101
    GROUP BY CID
    HAVING COUNT(CID) > 1 OR CID IS NULL;


-- Check if (CID) is (cust_key) of (crm_cust_info) table.
SELECT 
    CID
    FROM silver.erp_loc_a101
    WHERE CID NOT IN (SELECT  cust_key FROM silver.crm_cust_info)

            -- CID in erp_loc_a101 = cust_key in crm_cust_info
            -- but without dashes in CID values in erp_loc_a101
SELECT 
    CID 
    FROM silver.erp_loc_a101
    WHERE REPLACE(CID,'-','') NOT IN (SELECT  cust_key FROM silver.crm_cust_info)


-- Data Standardization & Consistency
SELECT DISTINCT cntry FROM silver.erp_loc_a101;

SELECT * FROM silver.erp_loc_a101



