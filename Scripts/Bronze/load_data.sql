
/*
    This script will load data from data files (.csv) into tables in the database.
    ================================

    WARNING 1: This script will delete the contents of the table before loading the data.
    ================================

    WARNING 2: The current path may not work for data files , try typing the full path.
    ================================

    NOTE: Grant the SQL server permission to access the data files.
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN

    BEGIN TRY

        DECLARE @start_time DATETIME2 , @end_time DATETIME2 ;

        DECLARE @progress_start_time DATETIME2 = GETDATE() ;

        ----============================================================================

        PRINT 'Loading data into tables.';

        PRINT '
        =======================';
        PRINT 'Loading data into table "bronze.crm_cust_info".';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM 'D:\Programming\Projects\SQL-Data-Warehouse\src\Datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );

        SET @end_time = GETDATE();

        PRINT 'Duration time: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.';

        --============================================================================

        PRINT '
        =======================';
        PRINT 'Loading data into table "bronze.crm_prd_info".';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM 'D:\Programming\Projects\SQL-Data-Warehouse\src\Datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT 'Duration time: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.';

        --============================================================================

        PRINT '
        =======================';
        PRINT 'Loading data into table "bronze.crm_sales_details".';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_sales_details

        BULK INSERT bronze.crm_sales_details
        FROM 'D:\Programming\Projects\SQL-Data-Warehouse\src\Datasets\source_crm\sales_details.csv'
        WITH 
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );

        SET @end_time = GETDATE();

        PRINT 'Duration time: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.';

        --============================================================================
        
        PRINT '
        =======================';
        PRINT 'Loading data into table "bronze.erp_cust_az12".';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_cust_az12

        BULK INSERT bronze.erp_cust_az12
        FROM 'D:\Programming\Projects\SQL-Data-Warehouse\src\Datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT 'Duration time: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.';

        --============================================================================
        
        PRINT '
        =======================';
        PRINT 'Loading data into table "bronze.erp_loc_a101".';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_loc_a101

        BULK INSERT bronze.erp_loc_a101
        FROM 'D:\Programming\Projects\SQL-Data-Warehouse\src\Datasets\source_erp\LOC_A101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT 'Duration time: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.';

        --============================================================================

        PRINT '
        =======================';
        PRINT 'Loading data into table "bronze.erp_px_cat_g1v2".';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_px_cat_g1v2

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'D:\Programming\Projects\SQL-Data-Warehouse\src\Datasets\source_erp\PX_CAT_G1V2.csv'
        WITH 
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        ); 

        SET @end_time = GETDATE();

        PRINT 'Duration time: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.';

        PRINT '
        =======================';
        PRINT 'Loading data completed.';
        PRINT 'Duration time for all: ' + CAST(DATEDIFF(MILLISECOND, @progress_start_time, GETDATE()) AS NVARCHAR) + ' milliseconds.';
        PRINT ''


    END TRY


    BEGIN CATCH

        PRINT ''
        PRINT '=======ERROR ' + CAST(ERROR_NUMBER() AS NVARCHAR) + '=======';
        PRINT 'Error message: ' + ERROR_MESSAGE();
        PRINT 'Error number: ' +  CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT ''

    END CATCH

END
