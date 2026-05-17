USE master;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'AdminLogin')
    DROP LOGIN AdminLogin;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ReadOnlyLogin')
    DROP LOGIN ReadOnlyLogin;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'HRLogin')
    DROP LOGIN HRLogin;
GO

CREATE LOGIN AdminLogin WITH PASSWORD = 'StrongPassword123!';
CREATE LOGIN ReadOnlyLogin WITH PASSWORD = 'StrongPassword123!';
CREATE LOGIN HRLogin WITH PASSWORD = 'StrongPassword123!';
GO

USE SecurityProjectDB;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AdminUser')
    DROP USER AdminUser;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ReadOnlyUser')
    DROP USER ReadOnlyUser;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'HRUser')
    DROP USER HRUser;
GO

CREATE USER AdminUser FOR LOGIN AdminLogin;
CREATE USER ReadOnlyUser FOR LOGIN ReadOnlyLogin;
CREATE USER HRUser FOR LOGIN HRLogin;
GO

ALTER ROLE db_owner ADD MEMBER AdminUser;
ALTER ROLE db_datareader ADD MEMBER ReadOnlyUser;

GRANT SELECT ON dbo.Departments TO HRUser;
GRANT SELECT ON dbo.Employees TO HRUser;
DENY SELECT ON dbo.Payroll TO HRUser;
GO

SELECT dp.name AS UserName, sp.name AS LoginName
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp
    ON dp.sid = sp.sid
WHERE dp.name IN ('AdminUser', 'ReadOnlyUser', 'HRUser');
GO