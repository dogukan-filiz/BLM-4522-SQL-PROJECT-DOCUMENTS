USE SecurityProjectDB;
GO

IF OBJECT_ID('dbo.vw_EmployeePublicInfo', 'V') IS NOT NULL
    DROP VIEW dbo.vw_EmployeePublicInfo;
GO

CREATE VIEW dbo.vw_EmployeePublicInfo
AS
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName,
    e.Email
FROM dbo.Employees e
INNER JOIN dbo.Departments d
    ON e.DepartmentID = d.DepartmentID;
GO

GRANT SELECT ON dbo.vw_EmployeePublicInfo TO HRUser;
GO

EXECUTE AS USER = 'HRUser';
SELECT * FROM dbo.vw_EmployeePublicInfo;
SELECT * FROM dbo.Payroll;
REVERT;
GO