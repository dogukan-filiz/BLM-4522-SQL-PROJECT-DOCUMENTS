USE SecurityProjectDB;
GO

/* Güvensiz dinamik SQL örneği */
DECLARE @UserInput NVARCHAR(100) = ''' OR 1=1 --';
DECLARE @UnsafeSQL NVARCHAR(MAX);

SET @UnsafeSQL = N'
SELECT EmployeeID, FirstName, LastName, Email
FROM dbo.Employees
WHERE Email = ''' + @UserInput + N'''';

PRINT 'Unsafe SQL:';
PRINT @UnsafeSQL;
EXEC(@UnsafeSQL);
GO

/* Güvenli parametreli sorgu örneği */
DECLARE @SafeInput NVARCHAR(100) = ''' OR 1=1 --';
DECLARE @SafeSQL NVARCHAR(MAX);

SET @SafeSQL = N'
SELECT EmployeeID, FirstName, LastName, Email
FROM dbo.Employees
WHERE Email = @Email';

PRINT 'Safe SQL:';
PRINT @SafeSQL;

EXEC sp_executesql
    @SafeSQL,
    N'@Email NVARCHAR(100)',
    @Email = @SafeInput;
GO