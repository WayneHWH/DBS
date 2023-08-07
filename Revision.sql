
USE TestDB
Create Table RegistrationStatus ( 
	StatusID varchar(1) primary key, 
	StatusDescription varchar(10) unique 
)
-- IDENTITY(100,1) 

CREATE TABLE [Student] (
	StudentID VARCHAR(5) PRIMARY KEY,
	[Name] VARCHAR(100) NOT NULL,
	RegistrationDate DATE,
	CurrentYear INT,
	CONSTRAINT Check_CurrentYear CHECK (CurrentYear > 0 ),
	[Status] VARCHAR(1) DEFAULT '1',
	FOREIGN KEY ([Status]) REFERENCES RegistrationStatus(StatusID)
);

ALTER TABLE [Student] ADD [Address] VARCHAR(200);
ALTER TABLE [Student] DROP CONSTRAINT Check_CurrentYear;
ALTER TABLE [Student] ADD CONSTRAINT Check_CurrentYear CHECK (CurrentYear > 0);
ALTER TABLE [Student] ALTER COLUMN [Address] VARCHAR(300);

CREATE VIEW [Active Student] AS
SELECT [Name] AS [Student Name]
FROM [Student]


ALTER VIEW [Active Student] AS
SELECT [Name] AS [Student Name]
FROM [Student]
WHERE Status = 2;

SELECT * FROM [Active Student];

CREATE VIEW [Non Active Students] AS 
SELECT Student.[Name] AS [Student Name], 
RegistrationStatus.StatusDescription as [Registration Status] 
FROM student , RegistrationStatus 
WHERE Student.Status = RegistrationStatus.StatusID and not RegistrationStatus.StatusDescription = 'Active'
Use TestDB
DROP TABLE [course]

CREATE TABLE [course] (
	--[course id] VARCHAR(10) PRIMARY KEY,
	[course id] INT IDENTITY(100,100) PRIMARY KEY,
	[course title] VARCHAR(100),
	[course unit] SMALLINT,
	[money] int,
	[password] varbinary(max)
);

CREATE VIEW [Active Course] AS
SELECT [course id] AS [Course ID]
FROM [course]

SELECT * FROM [Active Course];

SELECT * FROM course

INSERT INTO course ([course id], [course title],[course unit]) 
VALUES ('100','Biology',3),
('200','Biology',3);

INSERT INTO course ([course title],[course unit], [money], [password]) 
VALUES ('Biology',3, 1000, '12345'),
('Chemistry',4, 5000, '52345'),
('Science',5, 6000, '62345');


SELECT [course title], sum([money]) AS Sum
FROM course
GROUP BY [course title]
ORDER BY Sum DESC

--Create the Database Master Key (DMK)
USE TestDB
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QwErTy12345!@#$%'
SELECT * FROM sys.symmetric_keys

--Create Certificate
CREATE CERTIFICATE Cert1 ENCRYPTION BY PASSWORD = 'QwErTy12345!@#$%' WITH SUBJECT = 'Cert1'
CREATE CERTIFICATE Cert2 WITH SUBJECT = 'Cert2'
SELECT * FROM sys.certificates

--Creating Asymmetric Key
CREATE ASYMMETRIC KEY Key1 WITH ALGORITHM = RSA_2048 ENCRYPTION BY PASSWORD = 'QwErTy12345!@#$%'

SELECT * FROM sys.asymmetric_keys

--Creating Symmetric Key
CREATE SYMMETRIC KEY SimKey1 WITH ALGORITHM = AES_256 ENCRYPTION BY ASYMMETRIC KEY Key1
CREATE SYMMETRIC KEY SimKey2 WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE Cert1
SELECT * FROM sys.symmetric_keys

--Enabling TDE
USE master
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QwErTy12345!@#$%'
CREATE CERTIFICATE CertMasterDB WITH SUBJECT = 'CertMasterDB'

USE TestDB
CREATE DATABASE ENCRYPTION KEY 
WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE CertMasterDB

ALTER DATABASE TestDB SET ENCRYPTION ON 

--Adding Encrypted Data
--Using AsymKey_ID
INSERT INTO course ([course title],[course unit], [money], [password]) 
VALUES ('Biology',3, 1000, EncryptByAsymKey(AsymKey_ID('Key1'),'12345')),
('Chemistry',4, 5000, EncryptByAsymKey(AsymKey_ID('Key1'), '54321')),
('Science',5, 6000, EncryptByAsymKey(AsymKey_ID('Key1'), '92846'));

--Using Cert_ID
INSERT INTO course ([course title],[course unit], [money], [password]) 
VALUES ('Biology',3, 1000, EncryptByCert(Cert_ID('Cert1'),'12345')),
('Chemistry',4, 5000, EncryptByCert(AsymKey_ID('Cert1'), '54321')),
('Science',5, 6000, EncryptByCert(AsymKey_ID('Cert1'), '92846'));

--Using Key_GUID
OPEN SYMMETRIC KEY SimKey2 
DECRYPTION BY CERTIFICATE Cert1 WITH PASSWORD = 'QwErTy12345!@#$%'
INSERT INTO course ([course title],[course unit], [money], [password]) 
VALUES ('Biology',3, 1000, EncryptByKey(Key_GUID('SimKey2'),'12345')),
('Chemistry',4, 5000, EncryptByKey(Key_GUID('SimKey2'),'65432')),
('Science',5, 6000, EncryptByKey(Key_GUID('SimKey2'),'12578'));

CLOSE SYMMETRIC KEY SimKey2

--Reading Encrypted Data
SELECT [course title] AS Course_Title, Convert(varchar, DecryptByAsymKey(AsymKey_ID('Key1'), [password])) AS Course_Password  
FROM [course]


-- TRIGGER
USE TestDB
Create Table Medicine( 
	MedicineID varchar(10) primary key, 
	MedicineName varchar(100), 
	QuantityInStock int ) 

SELECT * FROM Medicine
	
Create Table Prescription( 
	PresID integer identity (1000000,1) primary key, 
	MedicineID varchar(10) references Medicine(MedicineID), 
	Quantity int )


INSERT INTO Medicine (MedicineID, MedicineName, QuantityInStock)
VALUES ('M01', 'Painadol', 10),
('M02', 'Batuk Ubat', 20)


-----------------DML Trigger---------------------------
----------INSERTED TRIGGER------------------
CREATE TRIGGER PrescribedMedicine_Inserted
ON Prescription
AFTER
INSERT
AS
BEGIN
DECLARE @quantity int, @medicineid varchar(10)
SELECT @medicineid=MedicineID, @quantity=Quantity
FROM Inserted

UPDATE Medicine
SET QuantityInStock = QuantityInStock - @quantity
WHERE MedicineID = @medicineid
END;

--Now INSERT prescription so that quantity in medicine will reduce/update
INSERT INTO Prescription (MedicineID, Quantity)
VALUES ('M01', 10)
SELECT * FROM Medicine


------------DELETED TRIGGER-------------------------
CREATE OR ALTER TRIGGER PrescribedMedicine_Deleted
ON Prescription
AFTER
DELETE
AS
BEGIN
DECLARE @quantity int, @medicineid varchar(10)
SELECT @medicineid = MedicineID, @quantity = Quantity
FROM Deleted

UPDATE Medicine
SET QuantityInStock = QuantityInStock + @quantity
WHERE MedicineID = @medicineid
END;

SELECT * FROM Prescription

DELETE FROM Prescription
WHERE PresID = 1000004

SELECT * FROM Medicine

CREATE OR ALTER TRIGGER PrescribeMedicine_InsteadOfInsert 
ON Prescription
INSTEAD OF
INSERT
AS
BEGIN
DECLARE @quantity_in_stock int, @quantity_ins int, @medicineid varchar(10) 
SELECT  @medicineid=MedicineID, @quantity_ins = Quantity
FROM Inserted
SELECT @quantity_in_stock = QuantityInStock
FROM Medicine
WHERE MedicineID = @medicineid
IF @quantity_in_stock > @quantity_ins
BEGIN
INSERT INTO Prescription (MedicineID, Quantity)
VALUES (@medicineid, @quantity_ins)
END
ELSE
BEGIN
PRINT 'diu lei lou mou'
ROLLBACK;
END
END

SELECT * FROM Prescription
SELECT * FROM Medicine
--Now INSERT prescription so that error msg will prompt
INSERT INTO Prescription (MedicineID, Quantity)
VALUES ('M02', 1)


------------DDL Trigger-------------------------
CREATE OR ALTER TRIGGER [JUST WANNA BE SAFE]
ON DATABASE
FOR DROP_TABLE 
AS
PRINT 'why u so stupid'
ROLLBACK;



---------------Auditing--------------------------
USE master
CREATE SERVER AUDIT AllTables_DML TO FILE (FILEPATH = 'C:\Temp');

--Enable Server Audit
ALTER SERVER AUDIT AllTables_DML WITH (STATE = ON);

Use TestDB
CREATE DATABASE AUDIT SPECIFICATION AllTables_DML_Specifications
FOR SERVER AUDIT AllTables_DML
ADD (INSERT, UPDATE, DELETE, SELECT
ON DATABASE::[TestDB] BY PUBLIC)
WITH (STATE = ON)

--Read Audit File
Declare @AuditFilePath VARCHAR(8000)
Select @AuditFilePath = audit_file_path 
From sys.dm_server_audit_status 
where name = 'AllTables_DML'
select event_time, database_name, database_principal_name, object_name, statement 
from sys.fn_get_audit_file(@AuditFilePath,default,default)


Select Name, recovery_model_desc From sys.databases

BACKUP DATABASE TestDB
TO DISK = 'C:\Temp\BRTDiff.bak'
	WITH DIFFERENTIAL,
	NAME = 'TestDB'

BACKUP LOG TestDB 
TO DISK = 'C:\Temp\BRT.log'
WITH CHECKSUM, 
NAME = 'TestDB Log'; 


----------ROW LEVEL SECURITY--------------------
Use TestDB
Create Login [Biology] WITH PASSWORD = 'abc123'
CREATE USER [Biology] FOR LOGIN [Biology];
CREATE ROLE [Subjects]
ALTER ROLE [Subjects] ADD MEMBER [Biology]
GRANT SELECT ON DATABASE::[TestDB] to [Subjects]

Execute as User = 'Biology' Select * From course REVERT

CREATE SCHEMA Security;
ALTER FUNCTION Security.fn_securitypredicate(@Username AS nvarchar(100))
RETURNS TABLE WITH SCHEMABINDING
AS
	RETURN SELECT 1 AS fn_securitypredicate_result
	WHERE @username = USER_NAME() OR USER_NAME() = 'dbo';

ALTER SECURITY POLICY [TestSecurityPolicy]
ADD FILTER PREDICATE
[Security].[fn_securitypredicate]([course title])
ON [dbo].[course]



Execute as User = 'Biology' Select * From course REVERT