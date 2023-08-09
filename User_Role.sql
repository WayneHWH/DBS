---------------------------- Create User Roles ----------------------------

--MEMBER USER LOGIN AND ROLE
CREATE LOGIN [100] WITH PASSWORD = 'QwErTy12345!@#$%'
CREATE LOGIN [104] WITH PASSWORD = 'QwErTy12345!@#$%'
SELECT [LoginName], createdate, dbname, hasaccess FROM SysLogins WHERE [LoginName] = '100'

USE [APU Sports Equipment]
CREATE USER [100] FOR LOGIN [100]
CREATE USER [104] FOR LOGIN [104]
CREATE USER [101] WITHOUT LOGIN
CREATE USER [102] WITHOUT LOGIN
SELECT [name],* FROM sys.sysusers 

CREATE ROLE [Member]
ALTER ROLE [Member] ADD MEMBER [100]
ALTER ROLE [Member] ADD MEMBER [101]
ALTER ROLE [Member] ADD MEMBER [102]
ALTER ROLE [Member] ADD MEMBER [104]

--STORE CLERK ROLE
--STORE CLERK ROLE
CREATE USER [Clerk01] WITHOUT LOGIN
CREATE LOGIN [Clerk02] WITH PASSWORD = 'QwErTy12345!@#$%'

CREATE USER [Clerk02] FOR LOGIN [Clerk02]

CREATE ROLE [Store Clerk]
ALTER ROLE [Store Clerk] ADD MEMBER [Clerk01]
ALTER ROLE [Store Clerk] ADD MEMBER [Clerk02]
SELECT [name],* FROM sys.sysusers

--DBA ROLE
CREATE LOGIN [DBA01] WITH PASSWORD = 'QwErTy12345!@#$%'

CREATE USER [DBA01] FOR LOGIN [DBA01]
CREATE USER [DBA02] WITHOUT LOGIN

CREATE ROLE [Database Administrator]
ALTER ROLE [Database Administrator] ADD MEMBER [DBA01]
ALTER ROLE [Database Administrator] ADD MEMBER [DBA02]
SELECT [name],* FROM sys.sysusers 

--Management ROLE
CREATE LOGIN [MG01] WITH PASSWORD = 'QwErTy12345!@#$%'
SELECT [LoginName], createdate, dbname, hasaccess FROM SysLogins WHERE [LoginName] = 'MG01'

CREATE USER [MG01] FOR LOGIN [MG01]
CREATE USER [MG02] WITHOUT LOGIN

CREATE ROLE [Management]
ALTER ROLE [Management] ADD MEMBER [MG01]
ALTER ROLE [Management] ADD MEMBER [MG02]
SELECT [name],* FROM sys.sysusers 

DROP ROLE [Member]
DROP ROLE [Store Clerk]
DROP ROLE [Database Administrator]
DROP ROLE [Management]

---------------------------- Permissions on User Roles ----------------------------
USE [APU Sports Equipment]

--- User Management ---

-- a. must be able to update their own membership details only

GRANT SELECT,  UPDATE ON [Member] TO [Member]

-- b. must be able to check, add, update and delete their own transactions only 
--Create View for Checking
CREATE VIEW [dbo].[Member Transaction Details View] WITH SCHEMABINDING
AS
SELECT [Transaction].Member_ID, [Transaction].Transaction_ID, [Transaction].Transaction_Date, 
Transaction_Details.Transaction_Details_ID, Equipment.Equipment_ID, Equipment.Equipment_Name,
Transaction_Details.Quantity, 
([Transaction_Details].Quantity * 
(Equipment.Unit_Price + (Equipment.Unit_Price * Country.Tax_Percentage)) * (1 - Category.Discounts)) AS Price_Payment
FROM [dbo].Transaction_Details
INNER JOIN [dbo].[Transaction] ON Transaction_Details.Transaction_ID = [Transaction].Transaction_ID
INNER JOIN [dbo].Equipment ON Transaction_Details.Equipment_ID = Equipment.Equipment_ID
INNER JOIN [dbo].Category ON Equipment.Category_ID = Category.Category_ID
INNER JOIN [dbo].Country ON Equipment.Country_ID = Country.Country_ID;


GRANT SELECT ON [Member Transaction Details View] TO [Member]

GRANT INSERT, DELETE ON [Transaction_Details] TO [Member]

GRANT SELECT(Transaction_Details_ID), UPDATE (Quantity) ON [Transaction_Details] TO [Member]

--- Store Clerk ---

-- a. must be able to manage (add, update, remove) all data except membership and transaction details
GRANT SELECT, INSERT, UPDATE, DELETE ON DATABASE:: [APU Sports Equipment] To [Store Clerk]

DENY INSERT, UPDATE, DELETE ON [Transaction_Details] To [Store Clerk]

DENY INSERT, UPDATE, DELETE ON [Transaction] To [Store Clerk]

DENY INSERT, UPDATE, DELETE ON [Member] To [Store Clerk]

-- b. must be able to view all transaction records (full details) but not modify them
GRANT SELECT ON [Transaction] TO [Store Clerk]

GRANT SELECT ON [Transaction_Details] TO [Store Clerk]

-- c. must be able to add new membership data
GRANT INSERT ON [Member] To [Store Clerk]

-- d. must be able to view and update non confidential membership data

GRANT SELECT ON [Member Transaction Details View] TO [Store Clerk];

GRANT SELECT, UPDATE ([Name], [Address], [Member_Status])
ON [Member] TO [Store Clerk];

-- e. should not be able to view any member’s confidential data

DENY SELECT ([IC/Passport_No]) ON [Member] TO [Management];

--- Database Administrator ---
-- Grant full control over the database
GRANT CONTROL ON DATABASE::[APU Sports Equipment] TO [Database Administrator];

GRANT CREATE TABLE, CREATE VIEW, ALTER ON DATABASE::[APU Sports Equipment] TO [Database Administrator];

GRANT SELECT, INSERT, UPDATE, DELETE ON DATABASE::[APU Sports Equipment] to [Database Administrator];

DENY SELECT ([IC/Passport_No]) ON [Member] TO [Database Administrator];

DENY CREATE TABLE, CREATE VIEW, ALTER ON DATABASE::[APU Sports Equipment] TO [Member], [Store_Clerk], [Management];

--- Management ---
-- a. Management staffs must be able to query all tables but not make any changes to it.  
GRANT SELECT ON DATABASE:: [APU Sports Equipment] To [Management]
-- b. Should not be able to view any member’s confidential data 
DENY SELECT ([IC/Passport_No]) ON [Member] TO [Management]