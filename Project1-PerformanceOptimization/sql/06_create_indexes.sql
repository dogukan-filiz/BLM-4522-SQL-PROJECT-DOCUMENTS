USE PerformanceProjectDB;
GO

-- Query 1 için
CREATE NONCLUSTERED INDEX IX_Customers_Email
ON Customers(Email);
GO

-- Query 2 için
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate_CustomerID
ON Orders(OrderDate, CustomerID)
INCLUDE (TotalAmount);
GO

-- Query 3 için
CREATE NONCLUSTERED INDEX IX_Products_Category_ProductID
ON Products(Category, ProductID)
INCLUDE (UnitPrice);
GO

CREATE NONCLUSTERED INDEX IX_OrderDetails_ProductID_OrderID
ON OrderDetails(ProductID, OrderID)
INCLUDE (Quantity, UnitPrice);
GO