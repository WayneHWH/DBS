-----------------------------------------------DDL Audit------------------------------------------------------------ 
USE master 
CREATE SERVER AUDIT DDLActivities_Audit TO FILE ( FILEPATH = 'C:\Temp' ); 
-- Enable the server audit.  
ALTER SERVER AUDIT DDLActivities_Audit 
WITH (STATE = ON) 

ALTER SERVER AUDIT SPECIFICATION [DDLActivities_Audit_Specification ] 
WITH (STATE = OFF) 

CREATE SERVER AUDIT SPECIFICATION [DDLActivities_Audit_Specification ] 
FOR SERVER AUDIT [DDLActivities_Audit] 
--This event is raised when a database is created, altered, or dropped. 
ADD (DATABASE_CHANGE_GROUP),
--CREATE, ALTER, or DROP statement is executed on database objects
ADD (DATABASE_OBJECT_CHANGE_GROUP), 
--GRANT, REVOKE, or DENY has been issued for database objects
ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),
--GRANT, REVOKE, or DENY is issued for a statement permission by any principal in SQL Server
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
--This event is raised when principals, such as users, are created, altered, or dropped from a database
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
--Indicates that a principal has successfully logged in to SQL Server. 
ADD (SUCCESSFUL_LOGIN_GROUP),
--This event is raised when a contained database user logs out of a database
ADD (DATABASE_LOGOUT_GROUP)
WITH (STATE=ON) 

DECLARE @AuditFilePath VARCHAR(8000);
Select @AuditFilePath = audit_file_path 
From sys.dm_server_audit_status where name = 'DDLActivities_Audit'
--select * from sys.fn_get_audit_file(@AuditFilePath,default,default)
select event_time, database_name, database_principal_name, object_name, statement, action_id
from sys.fn_get_audit_file(@AuditFilePath,default,default)

-----------------------------------------------DML Audit------------------------------------------------------------ 
USE master 

CREATE SERVER AUDIT AllTables_DML TO FILE ( FILEPATH = 'C:\Temp' );
GO
-- Enable the server audit.
ALTER SERVER AUDIT AllTables_DML  WITH (STATE = ON) ;

USE [APU Sports Equipment]
CREATE DATABASE AUDIT SPECIFICATION AllTables_DML_Specifications
FOR SERVER AUDIT AllTables_DML
ADD ( INSERT, UPDATE, DELETE, SELECT
ON DATABASE::[APU Sports Equipment] BY PUBLIC)
WITH (STATE = ON);

--ALTER DATABASE AUDIT SPECIFICATION AllTables_DML_Specifications WITH (STATE = OFF)
--DROP DATABASE AUDIT SPECIFICATION AllTables_DML_Specifications

--to read back the audit data
DECLARE @AuditFilePath VARCHAR(8000);
SELECT @AuditFilePath = audit_file_path
FROM sys.dm_server_audit_status
WHERE NAME = 'AllTables_DML'
SELECT action_id, event_time, DATABASE_NAME, database_principal_name, object_name, statement
FROM sys.fn_get_audit_file(@AuditFilePath,default,default)
WHERE DATABASE_NAME = 'APU Sports Equipment'