SELECT name, recovery_model_desc
FROM sys.databases
WHERE name = 'AdventureWorks2022';
GO

ALTER DATABASE AdventureWorks2022
SET RECOVERY FULL;
GO

SELECT name, recovery_model_desc
FROM sys.databases
WHERE name = 'AdventureWorks2022';
GO

USE master;
GO

BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\SQLBackups\Project2\full\AdventureWorks2022_Full_AfterRecovery.bak'
WITH 
    INIT,
    FORMAT,
    NAME = 'AdventureWorks2022 Full Backup After Recovery Model Change',
    STATS = 10;
GO

USE master;
GO

BACKUP LOG AdventureWorks2022
TO DISK = 'C:\SQLBackups\Project2\log\AdventureWorks2022_Log.trn'
WITH 
    INIT,
    NAME = 'AdventureWorks2022 Transaction Log Backup',
    STATS = 10;
GO