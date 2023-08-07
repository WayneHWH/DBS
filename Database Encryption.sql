---------------------------- Database Encryption ----------------------------
---------------------------- Member Details View for Member, Store Clerk, Management ----------------------------
USE [APU Sports Equipment]
CREATE OR ALTER VIEW [dbo].[Member Decrypted Full Details] WITH SCHEMABINDING AS
SELECT Member_ID, CONVERT (varchar, DecryptByAsymKey(AsymKey_ID('AsymKey1'),[IC/Passport_No])) 
As [IC/Passport_No], [Name], [Address], Member_Status
FROM [dbo].[Member]

CREATE OR ALTER VIEW [dbo].[Member Encrypted Full Details] WITH SCHEMABINDING AS
SELECT Member_ID, [IC/Passport_No], [Name], [Address], Member_Status
FROM [dbo].[Member]

GRANT SELECT ON [Member Decrypted Full Details] TO [Member]

GRANT SELECT ON [Member Encrypted Full Details] TO [Store Clerk], [Management]

SELECT * FROM [Member Decrypted Full Details]


------------------------------------RLS------------------------------------------------
CREATE SCHEMA Security;
CREATE OR ALTER FUNCTION [Security].fn_securitypredicate (@UserName AS nvarchar(100)) 
RETURNS TABLE WITH SCHEMABINDING 
AS
	RETURN 
	SELECT 1 AS fn_securitypredicate_result 
	WHERE (@UserName = USER_NAME() AND IS_MEMBER('Member') = 1) 
	OR USER_NAME() = 'dbo' 
	OR IS_MEMBER('Store Clerk') = 1 
	OR IS_MEMBER('Database Administrator') = 1 
	OR IS_MEMBER('Management') = 1


CREATE SECURITY POLICY [MemberTablePolicy]   
ADD FILTER PREDICATE [Security].[fn_securitypredicate]([Member_ID]) 
ON [dbo].[Member]

CREATE SECURITY POLICY [MemberTransactionViewPolicy]   
ADD FILTER PREDICATE [Security].[fn_securitypredicate]([Member_ID]) 
ON [dbo].[Member Transaction Details View]

CREATE SECURITY POLICY [MemberDecryptedViewPolicy]   
ADD FILTER PREDICATE [Security].[fn_securitypredicate]([Member_ID]) 
ON [dbo].[Member Decrypted Full Details]



--------------------------------------- TDE ---------------------------------------------------
Use master
go
Create Certificate CertMasterDB
With Subject = 'CertmasterDB'
go

--encrypt db
Use [APU Sports Equipment]
go
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE CertMasterDB;
go
ALTER DATABASE [APU Sports Equipment1]
SET ENCRYPTION ON;

--check database encryption status
Use master
select b.name as [APU Sports Equipment1], a.encryption_state_desc, a.key_algorithm,
a.encryptor_type
from sys.dm_database_encryption_keys a
inner join sys.databases b on a.database_id = b.database_id
where b.name = 'APU Sports Equipment'