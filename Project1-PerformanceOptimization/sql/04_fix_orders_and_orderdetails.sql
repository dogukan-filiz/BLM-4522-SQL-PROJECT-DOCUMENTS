USE PerformanceProjectDB;
GO

SET NOCOUNT ON;

-- Eski verileri temizle
DELETE FROM OrderDetails;
DELETE FROM Orders;
GO

-- Identity'leri sıfırla
DBCC CHECKIDENT ('Orders', RESEED, 0);
DBCC CHECKIDENT ('OrderDetails', RESEED, 0);
GO

-- Siparişleri yeniden üret
DECLARE @i INT = 1;

WHILE @i <= 100000
BEGIN
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
    VALUES
    (
        ((@i - 1) % 10000) + 1,
        DATEADD(DAY, -((@i - 1) % 365), GETDATE()),
        0
    );

    SET @i += 1;
END;
GO

-- Sipariş detaylarını yeniden üret
DECLARE @i INT = 1;
DECLARE @OrderID INT;
DECLARE @ProductID INT;
DECLARE @UnitPrice DECIMAL(10,2);
DECLARE @Qty INT;

WHILE @i <= 250000
BEGIN
    SET @OrderID = ((@i - 1) % 100000) + 1;
    SET @ProductID = ((@i - 1) % 1000) + 1;

    SELECT @UnitPrice = UnitPrice
    FROM Products
    WHERE ProductID = @ProductID;

    SET @Qty = ABS(CHECKSUM(NEWID())) % 10 + 1;

    INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@OrderID, @ProductID, @Qty, @UnitPrice);

    SET @i += 1;
END;
GO

-- TotalAmount hesapla
UPDATE o
SET o.TotalAmount = x.TotalAmount
FROM Orders o
JOIN
(
    SELECT 
        od.OrderID,
        SUM(od.Quantity * od.UnitPrice) AS TotalAmount
    FROM OrderDetails od
    GROUP BY od.OrderID
) x
ON o.OrderID = x.OrderID;
GO