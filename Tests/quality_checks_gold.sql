/*
    ===============================================================================
    Quality Checks
    -------------------------------------------------------------------------------
    Script Purpose:
        This script performs quality checks to validate the integrity, consistency, 
        and accuracy of the Gold Layer. These checks ensure:
        - Uniqueness of surrogate keys in dimension tables.
        - Referential integrity between fact and dimension tables.
        - Validation of relationships in the data model for analytical purposes.

    Usage Notes:
        - Investigate and resolve any discrepancies found during the checks.
    ===============================================================================
*/



-- =================================
-- Checking 'gold.dim_customers'
-- =================================

-- Check if (customer_number) contains duplicate values
SELECT 
    customer_number, -- surrogate key
    COUNT (customer_number)  id_count
FROM gold.dim_customers
GROUP BY customer_number
HAVING COUNT(*) > 1 OR customer_number IS NULL


-- Data Standardization & Consistency
SELECT 
    DISTINCT gender
    FROM gold.dim_customers  


-- =================================
-- Checking 'gold.dim_current_products'
-- =================================
SELECT 
    product_number,
    COUNT(*)
FROM gold.dim_current_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- Data Standardization & Consistency
SELECT 
    DISTINCT category_name
    FROM gold.dim_current_products

--
SELECT 
    DISTINCT product_line
    FROM gold.dim_current_products

--
SELECT 
    DISTINCT maintenance
    FROM gold.dim_current_products


-- =================================
-- Checking 'gold.dim_history_products'
-- =================================
SELECT 
    product_number,
    COUNT(*)
FROM gold.dim_history_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- Data Standardization & Consistency
SELECT 
    DISTINCT category_name
    FROM gold.dim_history_products

--
SELECT 
    DISTINCT product_line
    FROM gold.dim_history_products

--
SELECT 
    DISTINCT maintenance
    FROM gold.dim_history_products


-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_number = f.customer_number
LEFT JOIN gold.dim_current_products p
ON p.product_number = f.product_number
WHERE p.product_number IS NULL OR c.customer_number IS NULL 