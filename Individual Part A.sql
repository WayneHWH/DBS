---------------------------- Individual Part A (SQL Query for Transaction Details) ----------------------------
--Calculate Final Price with Tax + Discount (Kayzen)
USE [APU Sports Equipment]
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