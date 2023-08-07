USE [APU Sports Equipment]

EXECUTE AS USER = '101' REVERT
INSERT INTO [Transaction_Details] (Equipment_ID, Quantity)
VALUES (402, 1),
(403, 1),
(404, 1)

UPDATE [Transaction_Details]
SET Quantity = 1
WHERE Transaction_Details_ID = 306

EXECUTE AS USER = 'Clerk01' REVERT

INSERT INTO Member([Name],[Address],[Member_Status])
Values
('kekw', 'Kuala Lumpur', 'Active')

UPDATE [Member]
SET [IC/Passport_No] = CONVERT(varbinary(max), '010415-30-1033')

SELECT [Name],[Address],[Member_Status] FROM Member
SELECT * FROM [Member Transaction Details View]


SELECT * FROM [Member Decrypted Full Details]

SELECT * FROM [Member Encrypted Full Details]


SELECT * FROM [Transaction]
SELECT * FROM Equipment

DELETE FROM Transaction_Details
WHERE Transaction_Details_ID = 335


UPDATE Member
SET [IC/Passport_No] = '010413-09-9304'
WHERE Member_ID = 101

SELECT * FROM [Member Decrypted Full Details]






