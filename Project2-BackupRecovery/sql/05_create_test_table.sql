USE AdventureWorks2022;
GO

IF OBJECT_ID('dbo.DisasterRecoveryTest', 'U') IS NOT NULL
    DROP TABLE dbo.DisasterRecoveryTest;
GO

CREATE TABLE dbo.DisasterRecoveryTest
(
    TestID INT PRIMARY KEY IDENTITY(1,1),
    TestData NVARCHAR(100),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

INSERT INTO dbo.DisasterRecoveryTest (TestData)
VALUES ('Record 1'), ('Record 2'), ('Record 3'), ('Record 4'), ('Record 5');
GO

SELECT * FROM dbo.DisasterRecoveryTest;
GO