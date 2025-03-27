-- Database Creation:
create database retail_db;

-- create schema
create schema retail_db_schema;
use database retail_db;
use schema retail_db_schema;


-- create tables
-- Dimension Table: DimDate
CREATE TABLE DimDate (
    DateID INT PRIMARY KEY,
    Date DATE,
    DayOfWeek VARCHAR(10),
    Month VARCHAR(10),
    Quarter INT,
    Year INT,
    IsWeekend BOOLEAN
);

-- Dimension Table: DimCustomer
CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY autoincrement start 1 increment 1,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender VARCHAR(10),
    DateOfBirth DATE,
    Email VARCHAR(100),
    PhoneNumber INT,
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Country VARCHAR(50),
    LoyaltyProgramID INT
);
-- Dimension Table: DimProduct
CREATE TABLE DimProduct (
    ProductID INT PRIMARY KEY autoincrement start 1 increment 1,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Brand VARCHAR(50),
    UnitPrice DECIMAL(10, 2)
);
-- Dimension Table: DimStore
CREATE TABLE DimStore (
    StoreID INT PRIMARY KEY autoincrement start 1 increment 1,
    StoreName VARCHAR(100),
    StoreType VARCHAR(50),
	StoreOpeningDate DATE,
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Country VARCHAR(50),
    Region VARCHAR (50),
    ManagerName VARCHAR(100)
);
-- Dimension Table: DimLoyaltyProgram
CREATE TABLE DimLoyaltyProgram (
    LoyaltyProgramID INT PRIMARY KEY,
    ProgramName VARCHAR(100),
    ProgramTier VARCHAR(50),
    PointsAccrued INT
);
-- Fact Table: FactOrders
CREATE TABLE FactOrders (
    OrderID INT PRIMARY KEY autoincrement start 1 increment 1,
    DateID INT,
    CustomerID INT,
    ProductID INT,
    StoreID INT,
    QuantityOrdered INT,
    OrderAmount DECIMAL(10, 2),
    DiscountAmount DECIMAL(10, 2),
    ShippingCost DECIMAL(10, 2),
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (DateID) REFERENCES DimDate(DateID),
    FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
    FOREIGN KEY (StoreID) REFERENCES DimStore(StoreID)
);

-- create file format
CREATE OR REPLACE FILE FORMAT source_file_format
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    DATE_FORMAT = 'YYYY-MM-DD'
    ON_ERROR = 'SKIP_ROW';
    
-- create stage for storing external files
CREATE OR REPLACE STAGE RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE;
-- load the files from local into stage using SnowSQL
-- PUT local_file_path Stage @db_name.schema_name.stage_name
-- Or directly upload
-- Copy data from stage into the tables
-- directly or using COPY INTO 
select * from DIMLOYALTYPROGRAM;
select * from factorders;
ALTER TABLE DimCustomer DROP COLUMN PhoneNumber;


copy into DIMCUSTOMER(FirstName,LastName,Gender,DateOfBirth,Email,Address,City,State,ZipCode,Country,LoyaltyProgramID)
from @RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimCustomer/DimCustomerdata.csv
file_format = (format_name = 'SOURCE_FILE_FORMAT');

copy into DIMDATE(DateID,Date,Dayofweek,Month,Quarter,Year,IsWeekend)
from @RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimDate/Dimdate.csv
file_format = (format_name = 'SOURCE_FILE_FORMAT');

COPY INTO DimProduct(StoreName, StoreType, Brand, UnitPrice)
from @RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimProduct/DimProductdata.csv
file_format = (format_name = 'SOURCE_FILE_FORMAT');

COPY INTO DimStore(StoreName, StoreType, StoreOpeningDate, Address, City, State,Zipcode, Country,Region,ManagerName)
from @RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimStore/DimStoredata.csv
file_format = (format_name = 'SOURCE_FILE_FORMAT');

COPY INTO FACTORDERS(DateID, CustomerID, ProductID, StoreID, QuantityOrdered, OrderAmount, DiscountAmount, ShippingCost, TotalAmount)
from @RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/FactOrders/factorders.csv
file_format = (format_name = 'SOURCE_FILE_FORMAT');

COPY INTO FACTORDERS(DateID, CustomerID, ProductID, StoreID, QuantityOrdered, OrderAmount, DiscountAmount, ShippingCost, TotalAmount)
from @RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/Landing_Directory
file_format = (format_name = 'SOURCE_FILE_FORMAT');

-- Creating new user for querying and PowerBI access
create or replace user powerBI_user
    PASSWORD = '*****'
    LOGIN_NAME = 'PowerBI_user1'
    DEFAULT_ROLE = 'ACCOUNTADMIN'
    DEFAULT_WAREHOUSE = 'COMPUTE_WH'
    MUST_CHANGE_PASSWORD = TRUE;    
grant role accountadmin to user powerBI_user   







