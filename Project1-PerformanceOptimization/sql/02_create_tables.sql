USE PerformanceProjectDB;
GO
-- Müşteri tablosu
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    City NVARCHAR(50),
    RegistrationDate DATE NOT NULL
);

-- Ürün tablosu
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL
);

-- Siparişler tablosu
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    TotalAmount DECIMAL(18, 2),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Sipariş detayları tablosu
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO