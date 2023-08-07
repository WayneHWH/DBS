---------------------------- DDL Queries (Creating DB and Tables) ----------------------------
--DDL Commands
CREATE DATABASE [APU Sports Equipment];

USE [APU Sports Equipment]
CREATE TABLE Member (
	Member_ID INT IDENTITY(100,1) PRIMARY KEY,
	[IC/Passport_No] VARBINARY(MAX),
	[Name] VARCHAR(100) NOT NULL,
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
    Equipment_Name VARCHAR(100) NOT NULL,
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






















