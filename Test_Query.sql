USE [APU Sports Equipment]

EXECUTE AS USER = '101' REVERT
INSERT INTO [Transaction_Details] (Equipment_ID, Quantity)
VALUES (401, 1),
(403, 1),
(404, 1)


UPDATE [Transaction_Details]
SET Quantity = 4
WHERE Transaction_Details_ID = 347

DELETE FROM [Transaction_Details]
WHERE Transaction_Details_ID = 347

EXECUTE AS USER = 'MG01' REVERT

INSERT INTO Member([Name],[Address],[Member_Status])
Values
('kekw', 'Kuala Lumpur', 'Active')

UPDATE [Member]
SET [IC/Passport_No] = CONVERT(varbinary(max), '010413-09-9304')

SELECT [Name],[Address],[Member_Status] FROM Member

SELECT * FROM [Member Transaction Details View]

SELECT * FROM [Member Decrypted Full Details]

SELECT * FROM [Member Encrypted Full Details]


SELECT * FROM [Transaction]
SELECT * FROM [Transaction_Details]
SELECT * FROM Equipment
SELECT * FROM Member

DELETE FROM Transaction_Details
WHERE Transaction_Details_ID = 344


UPDATE Members
SET [IC/Passport_No] = '010413-09-9304'
WHERE Member_ID = 101

SELECT * FROM [Member Decrypted Full Details]

EXECUTE AS USER = 'DBA01' REVERT

CREATE VIEW [dbo].[Member View] WITH SCHEMABINDING
AS
SELECT [IC/Passport_No], [Name],[Address],[Member_Status] 
From [dbo].Member


GRANT SELECT ON [Member View] TO [Member]
SELECT *
FROM sys.fn_my_permissions('dbo','schema')

SELECT * FROM [Member View]

SELECT * FROM Country

SELECT * FROM Category

SELECT * FROM Equipment

SELECT * FROM [Equipment with Final Price]









