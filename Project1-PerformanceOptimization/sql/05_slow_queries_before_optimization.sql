USE PerformanceProjectDB;
GO

SET NOCOUNT ON;
GO

-- Performans ölçümü için
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

/* 
Sorgu 1
Amaç: Customers tablosunda Email alanı üzerinde indeks olmadan arama yapmak.
Beklenti: Tablo taraması (scan) görülebilir.
*/
PRINT 'Query 1 - Search by Email without index';
SELECT CustomerID, CustomerName, RegistrationDate
FROM Customers
WHERE Email = 'customer5000@example.com';
GO

/*
Sorgu 2
Amaç: Orders tablosunda tarih aralığı filtresi ve Customers ile JOIN işlemi.
Beklenti: OrderDate üzerinde uygun indeks yoksa maliyet artar.
*/
PRINT 'Query 2 - Orders with date filter and customer join';
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

                      /*
                      Sorgu 3
                      Amaç: Kategori bazlı satış toplamı hesaplamak.
                      Beklenti: Products ve OrderDetails tarafında uygun indeksler yoksa JOIN ve aggregation maliyeti yükselir.
                      */
                      PRINT 'Query 3 - Category based sales summary';
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

                                        -- Ölçüm kapatma
                                        SET STATISTICS IO OFF;
                                        SET STATISTICS TIME OFF;
                                        GO