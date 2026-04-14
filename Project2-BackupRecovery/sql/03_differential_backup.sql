/*USE AdventureWorks2022;
GO

UPDATE TOP (5) Person.Person
SET ModifiedDate = GETDATE();
GO*/

USE master;
GO

BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\SQLBackups\Project2\diff\AdventureWorks2022_Diff.bak'
WITH 
    DIFFERENTIAL,
    INIT,
    NAME = 'AdventureWorks2022 Differential Backup',
    STATS = 10;
GO