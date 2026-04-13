USE PerformanceProjectDB;
GO

SET NOCOUNT ON;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

PRINT 'Optimized Query 1 - Search by Email';
SELECT CustomerID, CustomerName, RegistrationDate
FROM Customers
WHERE Email = 'customer5000@example.com';
GO

PRINT 'Optimized Query 2 - Orders with date filter and customer join';
SELECT 
    c.CustomerName,
    o.OrderID,
    o.OrderDate,
    o.TotalAmount
FROM Orders o
INNER JOIN Customers c
    ON o.CustomerID = c.CustomerID
WHERE o.OrderDate >= DATEADD(MONTH, -3, GETDATE())
  AND o.OrderDate < GETDATE();
GO

PRINT 'Optimized Query 3 - Category based sales summary';
SELECT 
    p.Category,
    SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM OrderDetails od
INNER JOIN Products p
    ON od.ProductID = p.ProductID
INNER JOIN Orders o
    ON od.OrderID = o.OrderID
WHERE p.Category = 'Category 5'
  AND o.OrderDate >= DATEADD(MONTH, -6, GETDATE())
GROUP BY p.Category;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO