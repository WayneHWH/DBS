---------------------------- DDL Queries (Creating DB and Tables) ----------------------------
--DDL Commands
CREATE DATABASE [APU Sports Equipment];

USE [APU Sports Equipment]
CREATE TABLE Member (
	Member_ID INT IDENTITY(100,1) PRIMARY KEY,
	[IC/Passport_No] VARBINARY(MAX) NOT NULL,
	[Name] VARCHAR(100),
	[Address] VARCHAR(100),
	Member_Status VARCHAR(8) DEFAULT 'Active' check (Member_Status = 'Active' or Member_Status = 'Expired')
);

CREATE TABLE [Transaction] (
	Transaction_ID INT IDENTITY(200,1) PRIMARY KEY,
	[Transaction_Date] DATETIME DEFAULT GETDATE(),
	Member_ID INT,
	FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID)
);

CREATE TABLE Category
(
    Category_ID INT IDENTITY(500,1) PRIMARY KEY,
    Category_Name VARCHAR(100),
    Discounts DECIMAL(3, 2) CHECK (Discounts >= 0 AND Discounts <= 1)
)

CREATE TABLE [Country]
(
	Country_ID INT IDENTITY(600,1) PRIMARY KEY,
	Country_Name VARCHAR(100),
	Tax_Percentage DECIMAL(5, 2) CHECK (Tax_Percentage > 0)
)

CREATE TABLE Equipment
(
    Equipment_ID INT IDENTITY(400,1) PRIMARY KEY,
    Equipment_Name VARCHAR(100) Not null,
    Stock_Quantity INT DEFAULT 1 CHECK (Stock_Quantity > 0),
    Unit_Price DECIMAL(5, 2) CHECK (Unit_Price > 0),
    Country_ID INT REFERENCES Country(Country_ID),
    Category_ID INT REFERENCES Category(Category_ID)
)

CREATE TABLE [Transaction_Details] (
	Transaction_Details_ID INT IDENTITY(300,1) PRIMARY KEY,
	Transaction_ID INT,
	Equipment_ID INT,
	Quantity INT CHECK (Quantity > 0),
	Foreign Key (Transaction_ID) REFERENCES [Transaction](Transaction_ID),
	Foreign Key (Equipment_ID) REFERENCES Equipment(Equipment_ID)
);



---------------------------- INSERT Queries & Encryption ----------------------------
--Create Master Key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QwErTy12345!@#$%'
SELECT * FROM sys.symmetric_keys

-- can use assym key to directly encrypted data or encrypt 
-- the symm key that will be used to encrypt the data

--Create Asym Key
CREATE ASYMMETRIC KEY AsymKey1 WITH ALGORITHM = RSA_2048
SELECT * FROM sys.asymmetric_keys

-- Insert Values into Member Table
USE [APU Sports Equipment]
INSERT INTO Member([IC/Passport_No], [Name],[Address],[Member_Status])
Values
(EncryptByAsymKey(AsymKey_ID('AsymKey1'),'010416-10-3048'),'Wayne', 'Kuala Lumpur', 'Active'),
(EncryptByAsymKey(AsymKey_ID('AsymKey1'),'020329-14-7059'),'Kayzen', 'Cheras', 'Active'),
(EncryptByAsymKey(AsymKey_ID('AsymKey1'),'990615-07-4039'),'Vllim', 'Kajang', 'Active'),
(EncryptByAsymKey(AsymKey_ID('AsymKey1'),'980730-08-1029'),'Syramid', 'Cheras', 'Active'),
(EncryptByAsymKey(AsymKey_ID('AsymKey1'),'030831-09-8093'),'Jokor', 'Petaling Jaya', 'Expired')

--Insert Values into Transaction Table
INSERT INTO [Transaction] ([Transaction_Date],[Member_ID])
VALUES 
(GETDATE(), 100),
(GETDATE(), 101),
(GETDATE(), 102),
(GETDATE(), 103);

--Insert Values into Category Table
INSERT INTO [Category](Category_Name, Discounts)
VALUES
('Balls', '0.05'),
('Rackets','0.10'),
('Bats','0.20'),
('Nets','0.10');

--Insert Values into Country Table
INSERT INTO [Country](Country_Name, Tax_Percentage)
VALUES
('Malaysia', '0.10'),
('Singapore','0.20'),
('China','0.30'),
('Japan','0.40'),
('Korea','0.50'),
('Russia','0.80');

--Insert Values into Equipment Table
INSERT INTO Equipment(Equipment_Name, Stock_Quantity, Unit_Price, Country_ID, Category_ID)
VALUES
('Turbo_Ball', 10, 10.00, 600, 500),
('Super_Bolin', 12, 20.00, 605, 500),
('Fire_Racket', 10, 200.00, 602, 501),
('Batty_Bat', 5, 120.00, 603, 502),
('Spider_Net', 15, 50.00, 603, 503);

--Insert Values into Transaction Details Table
INSERT INTO [Transaction_Details] ([Transaction_ID], [Equipment_ID], [Quantity])
VALUES
(200, 400, 2),
(200, 401, 1),
(201, 402, 3),
(202, 403, 2),
(203, 403, 1);



---------------------------- SELECT Queries ----------------------------
--Select All Member
SELECT * FROM Member;

-- Select Member and decrypt IC/Passport
Select Member_ID, CONVERT (varchar, DecryptByAsymKey(AsymKey_ID('AsymKey1'),[IC/Passport_No])) As [IC/Passport_No], 
[Name], [Address], [Member_Status]
from Member

--Select Transaction from last 3 days
SELECT * FROM [Transaction]
WHERE Transaction_Date >= DATEADD(day,-3, GETDATE())

--Select Top 10 Transaction Details
SELECT TOP(10) * FROM Transaction_Details;

--Select Top 10 Category
SELECT TOP (10) [Category_ID]
      ,[Category_Name]
      ,[Discounts]
  FROM [Category];

--Select Top 10 Country

SELECT TOP (10) [Country_ID]
      ,[Country_Name]
      ,[Tax_Percentage]
  FROM Country;

--Select Top 10 Equipment
SELECT TOP (10) [Equipment_ID]
      ,[Equipment_Name]
      ,[Stock_Quantity]
      ,[Unit_Price]
      ,[Country_ID]
      ,[Category_ID]
  FROM [Equipment];



---------------------------- Individual Part A (SQL Query for Transaction Details) ----------------------------

--Calculate Final Price with Tax + Discount (Kayzen)
SELECT
  Equipment.Equipment_Name,
  Country.Country_Name,
  Equipment.Unit_Price,
  (Equipment.Unit_Price + (Equipment.Unit_Price * Country.Tax_Percentage)) * (1 - Category.Discounts) AS Final_Price
FROM
  Equipment
INNER JOIN
  Country ON Equipment.Country_ID = Country.Country_ID
INNER JOIN
  Category ON Equipment.Category_ID = Category.Category_ID;

-- Select Member and Transaction (Wi Liam)
Select Member.Member_ID, CONVERT (varchar, DecryptByAsymKey(AsymKey_ID('AsymKey1'),Member.[IC/Passport_No])) As [IC/Passport_No], 
Member.[Name], Member.[Address], Member.[Member_Status], [Transaction].Transaction_Date, [Transaction].Transaction_ID
from Member 
INNER JOIN 
[Transaction] ON Member.Member_ID = [Transaction].Member_ID WHERE Transaction_Date >= DATEADD(day,-31, GETDATE())

--SQL Query Total Sales of Each Category (Wayne)
SELECT
Category.Category_ID,
Category.Category_Name,
SUM([Transaction_Details].Quantity * 
(Equipment.Unit_Price + (Equipment.Unit_Price * Country.Tax_Percentage)) * (1 - Category.Discounts)) AS Total_Sales
FROM Equipment
INNER JOIN
    Category ON Equipment.Category_ID = Category.Category_ID
INNER JOIN
    [Transaction_Details] ON Equipment.Equipment_ID = [Transaction_Details].Equipment_ID
INNER JOIN
    Country ON Equipment.Country_ID = Country.Country_ID
GROUP BY
Category.Category_Name,
Category.Category_ID;


---------------------------- Create User Roles ----------------------------

--MEMBER USER LOGIN AND ROLE
CREATE LOGIN [100] WITH PASSWORD = 'QwErTy12345!@#$%'
CREATE LOGIN [104] WITH PASSWORD = 'QwErTy12345!@#$%'
SELECT [LoginName], * FROM SysLogins WHERE [LoginName] = '100'

USE [APU Sports Equipment]
CREATE USER [100] FOR LOGIN [100]
CREATE USER [101] WITHOUT LOGIN
CREATE USER [102] WITHOUT LOGIN
SELECT [name],* FROM sys.sysusers 

CREATE ROLE [Member]
ALTER ROLE [Member] ADD MEMBER [100]
ALTER ROLE [Member] ADD MEMBER [101]
ALTER ROLE [Member] ADD MEMBER [102]

--STORE CLERK ROLE
USE [APU Sports Equipment]
CREATE USER [Clerk01] WITHOUT LOGIN

CREATE ROLE [Store Clerk]
ALTER ROLE [Store Clerk] ADD MEMBER [Clerk01]
SELECT [name],* FROM sys.sysusers 

--DBA ROLE
USE [APU Sports Equipment]
CREATE USER [DBA01] WITHOUT LOGIN

CREATE ROLE [Database Administrator]
ALTER ROLE [Database Administrator] ADD MEMBER [DBA01]
SELECT [name],* FROM sys.sysusers 

--Management ROLE
USE [APU Sports Equipment]
CREATE USER [MG01] WITHOUT LOGIN

CREATE ROLE [Management]
ALTER ROLE [Management] ADD MEMBER [MG01]
SELECT [name],* FROM sys.sysusers 

DROP ROLE [Member]
DROP ROLE [Store Clerk]
DROP ROLE [Database Administrator]
DROP ROLE [Management]

---------------------------- Permissions on User Roles ----------------------------
use [APU Sports Equipment]

--- User Management ---

-- a. must be able to update their own membership details only
GRANT SELECT, UPDATE ON [Member] TO [Member]

-- b. must be able to check, add, update and delete their own transactions only 
--Create View for Checking
CREATE VIEW [Member Transaction Details View] AS
SELECT [Transaction].Member_ID, [Transaction].Transaction_ID, [Transaction].Transaction_Date, 
Transaction_Details.Transaction_Details_ID, Equipment.Equipment_ID, Equipment.Equipment_Name,
Transaction_Details.Quantity, 
([Transaction_Details].Quantity * 
(Equipment.Unit_Price + (Equipment.Unit_Price * Country.Tax_Percentage)) * (1 - Category.Discounts)) AS Price_Payment
FROM Transaction_Details
INNER JOIN [Transaction] ON Transaction_Details.Transaction_ID = [Transaction].Transaction_ID
INNER JOIN Equipment ON Transaction_Details.Equipment_ID = Equipment.Equipment_ID
INNER JOIN Category ON Equipment.Category_ID = Category.Category_ID
INNER JOIN Country ON Equipment.Country_ID = Country.Country_ID;


GRANT SELECT ON [Member Transaction Details View] TO [Member]

GRANT SELECT, INSERT, DELETE ON [Transaction_Details] TO [Member]

GRANT UPDATE (Quantity) ON [Transaction_Details] TO [Member]


--- Store Clerk ---

-- a. must be able to manage (add, update, remove) all data except membership and transaction details
GRANT INSERT, UPDATE, DELETE ON DATABASE:: [APU Sports Equipment] To [Store Clerk]

DENY INSERT, UPDATE, DELETE ON [Transaction_Details] To [Store Clerk]

DENY INSERT, UPDATE, DELETE ON [Transaction] To [Store Clerk]

DENY INSERT, UPDATE, DELETE ON [Member] To [Store Clerk]

-- b. must be able to view all transaction records (full details) but not modify them
GRANT SELECT ON [Transaction] TO [Store Clerk]

GRANT SELECT ON [Transaction_Details] TO [Store Clerk]

-- c. must be able to add new membership data
GRANT INSERT ON [Member] To [Store Clerk]

-- d. must be able to view and update non confidential membership data

GRANT SELECT, UPDATE ([Name], [Address], [Member_Status])
ON [Member] TO [Store Clerk];

-- e. should not be able to view any member’s confidential data

DENY SELECT ([IC/Passport_No]) ON [Member] TO [Store Clerk];

--- Database Administrator ---
GRANT ALTER, CREATE, DROP TO [Database Administrators];

--- Management ---
-- a. Management staffs must be able to query all tables but not make any changes to it.  
GRANT SELECT ON DATABASE:: [APU Sports Equipment] To [Management]
-- b. Should not be able to view any member’s confidential data 
 DENY SELECT ([IC/Passport_No]) ON [Member] TO [Management]

---------------------------- Triggers ----------------------------
-- (Wayne)
-- Trigger to prevent item refund after 3 days and to delete relevant records of transaction if not referenced
CREATE OR ALTER TRIGGER MemberRefundItem
ON [Transaction_Details]
INSTEAD OF 
DELETE
AS
BEGIN
    DECLARE @transactiondate DATE, @transactionid INT, @transactiondetailsid INT
    
    SELECT @transactionid = Transaction_ID,
           @transactiondetailsid = Transaction_Details_ID
    FROM DELETED
    
    SELECT @transactiondate = Transaction_Date
    FROM [Transaction]
    WHERE Transaction_ID = @transactionid
    
    IF DATEDIFF(DAY, @transactiondate, GETDATE()) > 4
    BEGIN
        PRINT 'Can only refund items within 3 days.'
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM [Transaction_Details] WHERE Transaction_ID = @transactionid AND Transaction_Details_ID <> @transactiondetailsid)
        BEGIN
            DELETE FROM [Transaction_Details]
            WHERE Transaction_Details_ID = @transactiondetailsid
        END
        ELSE
        BEGIN
            DELETE FROM [Transaction_Details]
            WHERE Transaction_Details_ID = @transactiondetailsid
            DELETE FROM [Transaction]
            WHERE Transaction_ID = @transactionid
        END
    END
END


CREATE TRIGGER Prevent_login 
ON ALL SERVER 
FOR LOGON AS 
BEGIN 
    DECLARE @LoginName sysname 
    SET @LoginName = ORIGINAL_LOGIN()

    IF EXISTS (SELECT 1 FROM [Member] WHERE Member_ID = @LoginName AND Member_Status = 'Expired')
    BEGIN
        ROLLBACK; -- Disconnect the session for expired members
        PRINT 'Your account has expired. Please contact the administrator for assistance.'
    END
END


-- (VLIMMA)
-- Validate Quantity &
-- Trigger for member purchasing item accessing transaction_details only, automatically insert values 
-- into transaction table and assign respective foreign key
CREATE OR ALTER TRIGGER [ValidateStockQuantity]
ON [Transaction_Details]
INSTEAD OF 
INSERT
AS 
BEGIN
    DECLARE @quantity_in_stock INT, @quantity_ordered INT, 
            @equipmentid VARCHAR(50), @transactionid INT,
            @memberid INT

    SELECT @transactionid = Transaction_ID,
           @equipmentid = Equipment_ID, 
           @quantity_ordered = Quantity, 
           @memberid = USER_NAME()
    FROM Inserted

    SELECT @quantity_in_stock = Stock_Quantity
    FROM Equipment
    WHERE Equipment_ID = @equipmentid

    IF @quantity_in_stock >= @quantity_ordered
    BEGIN
        -- Insert into the [Transaction] table with the current Member_ID
        INSERT INTO [Transaction] ([Transaction_Date], [Member_ID])
        VALUES (GETDATE(), @memberid)

        -- Get the newly generated Transaction_ID
        SET @transactionid = SCOPE_IDENTITY();

        -- Insert into the [Transaction_Details] table with the generated Transaction_ID
        INSERT INTO [Transaction_Details] (Transaction_ID, Equipment_ID, Quantity)
        SELECT @transactionid, Equipment_ID, Quantity
        FROM Inserted

        UPDATE Equipment
        SET Stock_Quantity = Stock_Quantity - @quantity_ordered
        WHERE Equipment_ID = @equipmentid
    END
    ELSE
    BEGIN
        PRINT 'Equipment of: ' + @equipmentid + ' is not enough. Transaction is Rejected.'
        PRINT 'Currently there is only ' + CONVERT(VARCHAR, @quantity_in_stock) + ' units of equipment'
    END
END

-- Avoid accidentally Table deletion
CREATE OR ALTER TRIGGER [Deletion Trigger] 
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    PRINT 'You must disable Trigger [Deletion Trigger] to drop tables!'
    ROLLBACK;
END



