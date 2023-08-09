-----------------------------------------------Login Logout Audit------------------------------------------------------------ 
USE master 
--CREATE SERVER AUDIT
CREATE SERVER AUDIT LoginLogout_Audit TO FILE ( FILEPATH = 'C:\Temp' ); 
-- Enable the server audit.  
ALTER SERVER AUDIT LoginLogout_Audit 
WITH (STATE = ON) 

CREATE SERVER AUDIT SPECIFICATION [LoginLogout_Audit_Specification ] 
FOR SERVER AUDIT LoginLogout_Audit 
--Indicates that a principal has successfully logged in to SQL Server. 
ADD (SUCCESSFUL_LOGIN_GROUP),
--Indicates that a principal has logged out of SQL Server
ADD (LOGOUT_GROUP),
--Indicates that a principal tried to log on to SQL Server and failed
ADD (FAILED_LOGIN_GROUP)
WITH (STATE=ON) 

DECLARE @AuditFilePath VARCHAR(8000);
Select @AuditFilePath = audit_file_path 
From sys.dm_server_audit_status where name = 'LoginLogout_Audit'
select event_time, server_principal_name, application_name, action_id
from sys.fn_get_audit_file(@AuditFilePath,default,default)
WHERE server_principal_name ='100'

-----------------------------------------------DDL Audit------------------------------------------------------------ 

CREATE SERVER AUDIT DDLActivities_Audit TO FILE ( FILEPATH = 'C:\Temp' ); 
-- Enable the server audit.  
ALTER SERVER AUDIT DDLActivities_Audit 
WITH (STATE = ON) 

ALTER SERVER AUDIT SPECIFICATION [DDLActivities_Audit_Specification]
WITH (STATE = OFF) 

CREATE SERVER AUDIT SPECIFICATION [DDLActivities_Audit_Specification] 
FOR SERVER AUDIT [DDLActivities_Audit] 
--This event is raised when a database is created, altered, or dropped. 
ADD (DATABASE_CHANGE_GROUP),
--This event is raised when a CREATE, ALTER, or DROP operation is performed on a schema
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
--This event is raised when principals, such as users, are created, altered, or dropped from a database
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP)
WITH (STATE=ON) 

DECLARE @AuditFilePath VARCHAR(8000);
Select @AuditFilePath = audit_file_path 
From sys.dm_server_audit_status where name = 'DDLActivities_Audit'
select event_time, database_name, database_principal_name, object_name, statement, action_id
from sys.fn_get_audit_file(@AuditFilePath,default,default)

-----------------------------------------------User Permission Audit------------------------------------------------------------ 

CREATE SERVER AUDIT UserPermission_Audit TO FILE ( FILEPATH = 'C:\Temp' ); 
-- Enable the server audit.  
ALTER SERVER AUDIT UserPermission_Audit 
WITH (STATE = ON) 

CREATE SERVER AUDIT SPECIFICATION [UserPermission_Audit_Specification] 
FOR SERVER AUDIT UserPermission_Audit 
--This event is raised whenever a GRANT, REVOKE, or DENY is issued for a statement permission by any principal in SQL Server 
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
--GRANT, REVOKE, or DENY has been issued for database objects
ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),
--This event is raised whenever a grant, deny, revoke is performed against a schema object.
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP)
WITH (STATE=ON) 

DECLARE @AuditFilePath VARCHAR(8000);
Select @AuditFilePath = audit_file_path 
From sys.dm_server_audit_status where name = 'UserPermission_Audit'
--select * from sys.fn_get_audit_file(@AuditFilePath,default,default)
select event_time, database_name, database_principal_name, object_name, statement
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
WHERE DATABASE_NAME = 'APU Sports Equipment' AND database_principal_name = '101'

