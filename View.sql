USE [APU Sports Equipment]
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

CREATE OR ALTER VIEW [dbo].[Member Decrypted Full Details] WITH SCHEMABINDING AS
SELECT Member_ID, CONVERT (varchar, DecryptByAsymKey(AsymKey_ID('AsymKey1'),[IC/Passport_No])) 
As [IC/Passport_No], [Name], [Address], Member_Status
FROM [dbo].[Member]


CREATE OR ALTER VIEW [dbo].[Member Encrypted Full Details] WITH SCHEMABINDING AS
SELECT Member_ID, [IC/Passport_No], [Name], [Address], Member_Status
FROM [dbo].[Member]

CREATE OR ALTER VIEW [Equipment with Final Price] AS
SELECT
    E.Equipment_ID,
    E.Equipment_Name,
    E.Stock_Quantity,
    E.Unit_Price,
    C.Category_Name,
    C.Discounts,
    CO.Country_Name,
    CO.Tax_Percentage,
    Final_Unit_Price = E.Unit_Price * (1 - C.Discounts) * (1 + CO.Tax_Percentage)
FROM
    Equipment E
JOIN
    Category C ON E.Category_ID = C.Category_ID
JOIN
    Country CO ON E.Country_ID = CO.Country_ID;

SELECT * FROM [Equipment with Final Price]

GRANT SELECT ON [Equipment with Final Price] TO [Store Clerk]

