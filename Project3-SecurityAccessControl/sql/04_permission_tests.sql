USE SecurityProjectDB;
GO

EXECUTE AS USER = 'ReadOnlyUser';
SELECT * FROM dbo.Departments;
SELECT * FROM dbo.Employees;
SELECT * FROM dbo.Payroll;
REVERT;
GO

EXECUTE AS USER = 'HRUser';
SELECT * FROM dbo.Departments;
SELECT * FROM dbo.Employees;
SELECT * FROM dbo.Payroll;
REVERT;
GO