USE AdventureWorks2022;
GO

DELETE FROM dbo.DisasterRecoveryTest
WHERE TestID IN (1,2,3);
GO

SELECT * FROM dbo.DisasterRecoveryTest;
GO