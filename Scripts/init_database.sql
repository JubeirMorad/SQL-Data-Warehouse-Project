/*
    =============================
    Script: init_database.sql
    =============================

    Description: This script initializes the DataWarehouse database by 
    creating the necessary schemas for the bronze, silver, and gold layers. 
    
    =============================
    WARNING : If the database already exists, it will be dropped and recreated to ensure a clean setup.
    
*/



USE master; 


    -- Database already exists, Drop it before creating a new one
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
    BEGIN

        ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE DataWarehouse;

        PRINT 'Existing DataWarehouse database dropped.';
    END
GO


    -- Create the DataWarehouse database
CREATE DATABASE DataWarehouse;
GO


    -- Create schemas for bronze, silver, and gold layers
USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO