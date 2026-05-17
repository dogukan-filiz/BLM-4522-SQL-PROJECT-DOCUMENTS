USE SecurityProjectDB;
GO

IF OBJECT_ID('dbo.AccessAuditLog', 'U') IS NOT NULL
    DROP TABLE dbo.AccessAuditLog;
GO

CREATE TABLE dbo.AccessAuditLog
(
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserName NVARCHAR(100) NOT NULL,
    ActionType NVARCHAR(100) NOT NULL,
    TableName NVARCHAR(100) NOT NULL,
    ActionTime DATETIME NOT NULL DEFAULT GETDATE()
);
GO

INSERT INTO dbo.AccessAuditLog (UserName, ActionType, TableName)
VALUES
('AdminUser', 'SELECT', 'Payroll'),
('ReadOnlyUser', 'SELECT', 'Employees'),
('HRUser', 'DENIED_SELECT', 'Payroll');
GO

SELECT * 
FROM dbo.AccessAuditLog
ORDER BY LogID;
GO