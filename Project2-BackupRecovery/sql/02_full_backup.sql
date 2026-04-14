USE master;
GO

BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\SQLBackups\Project2\full\AdventureWorks2022_Full.bak'
WITH 
    INIT,
    FORMAT,
    NAME = 'AdventureWorks2022 Full Backup',
    STATS = 10;
GO