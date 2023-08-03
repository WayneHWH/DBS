---------------------------- INSERT Queries & Encryption ----------------------------
--Create Master Key
USE [APU Sports Equipment]
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QwErTy12345!@#$%'
SELECT * FROM sys.symmetric_keys

-- can use assym key to directly encrypted data or encrypt 
-- the symm key that will be used to encrypt the data

--Create Asym Key
CREATE ASYMMETRIC KEY AsymKey1 WITH ALGORITHM = RSA_2048
GRANT CONTROL ON ASYMMETRIC KEY::AsymKey1 TO [Member]
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