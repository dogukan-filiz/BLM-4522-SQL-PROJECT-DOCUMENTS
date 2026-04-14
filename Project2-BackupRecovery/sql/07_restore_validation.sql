/*RESTORE FILELISTONLY
FROM DISK = 'C:\SQLBackups\Project2\full\AdventureWorks2022_Full_AfterRecovery.bak';
GO*/

/*USE master;
GO

IF DB_ID('AdventureWorks2022_RestoreTest') IS NOT NULL
BEGIN
    ALTER DATABASE AdventureWorks2022_RestoreTest SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AdventureWorks2022_RestoreTest;
END
GO

RESTORE DATABASE AdventureWorks2022_RestoreTest
FROM DISK = 'C:\SQLBackups\Project2\full\AdventureWorks2022_Full_AfterRecovery.bak'
WITH 
    MOVE 'AdventureWorks2022' TO 'D:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AdventureWorks2022_RestoreTest.mdf',
    MOVE 'AdventureWorks2022_log' TO 'D:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AdventureWorks2022_RestoreTest_log.ldf',
    REPLACE,
    RECOVERY,
    STATS = 10;
GO

USE AdventureWorks2022_RestoreTest;
GO

SELECT name
FROM sys.tables
WHERE name = 'DisasterRecoveryTest';
GO*/

USE master;
GO

IF DB_ID('AdventureWorks2022_RestoreTest') IS NOT NULL
BEGIN
    ALTER DATABASE AdventureWorks2022_RestoreTest SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AdventureWorks2022_RestoreTest;
END
GO

RESTORE DATABASE AdventureWorks2022_RestoreTest
FROM DISK = 'C:\SQLBackups\Project2\full\AdventureWorks2022_Full_PhoneTypeScenario.bak'
WITH 
    MOVE 'AdventureWorks2022' TO 'D:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AdventureWorks2022_RestoreTest.mdf',
    MOVE 'AdventureWorks2022_log' TO 'D:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AdventureWorks2022_RestoreTest_log.ldf',
    REPLACE,
    RECOVERY,
    STATS = 10;
GO

USE AdventureWorks2022_RestoreTest;
GO

SELECT PhoneNumberTypeID, Name, ModifiedDate
FROM Person.PhoneNumberType
ORDER BY PhoneNumberTypeID;
GO