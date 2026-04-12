SET NOCOUNT ON;

-- Müşteri verisi ekle
DECLARE @i INT = 1;
WHILE @i <= 10000
BEGIN
    INSERT INTO Customers (CustomerName, Email, City, RegistrationDate)
    VALUES 
    ('Customer ' + CAST(@i AS NVARCHAR(10)), 
     'customer' + CAST(@i AS NVARCHAR(10)) + '@example.com', 
     'City ' + CAST((@i % 100) + 1 AS NVARCHAR(10)),
     DATEADD(DAY, -(@i % 365), GETDATE()));
    SET @i = @i + 1;
END;

-- Ürün verisi ekle
SET @i = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO Products (ProductName, Category, UnitPrice)
    VALUES
    ('Product ' + CAST(@i AS NVARCHAR(10)),
     'Category ' + CAST((@i % 20) + 1 AS NVARCHAR(10)),
     RAND() * 500 + 10);
    SET @i = @i + 1;
END;

-- Sipariş verisi ekle
SET @i = 1;
WHILE @i <= 100000
BEGIN
    INSERT INTO Orders (CustomerID, OrderDate)
    VALUES
    ((@i % 10000) + 1, -- 1 ile 10000 arası müşteri ID'si
     DATEADD(MINUTE, -(@i % 50000), GETDATE()));
    SET @i = @i + 1;
END;

-- Sipariş detayı verisi ekle
SET @i = 1;
WHILE @i <= 250000
BEGIN
    DECLARE @OrderID INT = (@i % 100000) + 1;
    DECLARE @ProductID INT = (@i % 1000) + 1;
    DECLARE @UnitPrice DECIMAL(10,2);
    
    SELECT @UnitPrice = UnitPrice FROM Products WHERE ProductID = @ProductID;

    INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
    VALUES
    (@OrderID,
     @ProductID,
     CAST(RAND() * 10 AS INT) + 1,
     @UnitPrice);
    SET @i = @i + 1;
END;
GO