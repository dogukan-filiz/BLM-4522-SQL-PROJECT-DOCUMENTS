# Proje 1 - Veritabanı Performans Optimizasyonu ve İzleme

## Youtube link: [YouTube](https://youtu.be/0W4Y35xwUUI)

## 1. Projenin Amacı

Bu projenin amacı, SQL Server üzerinde oluşturulan örnek bir satış veritabanı üzerinden performans problemi oluşturan sorguları belirlemek, bu sorguların execution plan ve istatistik çıktılarını incelemek, uygun indeksler ile sorgu performansını iyileştirmek ve elde edilen sonuçları raporlamaktır.

Bu kapsamda hem sorgu optimizasyonu hem de veritabanı izleme çalışmaları gerçekleştirilmiştir. Çalışmada `SET STATISTICS IO ON`, `SET STATISTICS TIME ON`, Actual Execution Plan ve DMV sorguları kullanılmıştır.

## 2. Kullanılan Ortam

* Veritabanı Yönetim Sistemi: Microsoft SQL Server
* Yönetim Aracı: SQL Server Management Studio (SSMS)
* Versiyon: SQL Server 2022 / SSMS
* Kaynak Kontrol: GitHub

## 3. Veritabanı Tasarımı

Projede performans testi yapabilmek amacıyla satış sistemi temelli bir örnek veritabanı oluşturulmuştur. Kullanılan tablolar şunlardır:

* `Customers`
* `Products`
* `Orders`
* `OrderDetails`

Bu tablolar arasında müşteri, sipariş, ürün ve sipariş detay ilişkileri kurulmuştur. Böylece hem tek tablo filtreleme sorguları hem de çoklu join ve aggregation içeren sorgular üzerinde test yapılabilmiştir.

## 4. Test Verisi Oluşturma Süreci

Veritabanına performans farklarını gözlemleyebilecek ölçekte test verisi eklenmiştir.

Eklenen veri büyüklükleri yaklaşık olarak şöyledir:

* Customers: 10.000 kayıt
* Products: 1.000 kayıt
* Orders: 100.000 kayıt
* OrderDetails: 250.000 kayıt

Sipariş tarihleri belirli bir zaman aralığına dağıtılmış, sipariş detayları üzerinden toplam sipariş tutarları hesaplanarak `Orders.TotalAmount` alanı güncellenmiştir.

Veri üretimi sırasında parent-child ilişkiler ve foreign key yapıları dikkate alınmıştır. Ayrıca `IDENTITY` alanları nedeniyle oluşan foreign key hataları `DBCC CHECKIDENT ... RESEED` kullanılarak çözülmüştür.

## 5. Optimizasyon Öncesi Yavaş Sorgular

Bu aşamada üç farklı sorgu belirlenmiş ve `SET STATISTICS IO ON` ile `SET STATISTICS TIME ON` komutları kullanılarak ölçüm yapılmıştır. Ayrıca Actual Execution Plan açılarak sorguların fiziksel çalışma planları incelenmiştir.

### Sorgu 1

Customers tablosunda `Email` alanı üzerinden eşitlik tabanlı arama yapılmıştır. Bu alanda başlangıçta indeks bulunmadığı için sorgu execution plan üzerinde `Clustered Index Scan` ile çalışmıştır. Ölçüm sonucunda `logical reads` değeri 141 olarak gözlemlenmiştir.

### Sorgu 2

Orders ve Customers tabloları arasında tarih filtresi içeren bir join sorgusu çalıştırılmıştır. Optimizasyon öncesinde execution plan üzerinde scan ağırlıklı bir yapı görülmüştür. Orders tablosunda 423 logical read oluşmuş, sorgu yaklaşık 217 ms sürede tamamlanmıştır. SQL Server ayrıca eksik indeks önerisi üretmiştir.

### Sorgu 3

OrderDetails, Products ve Orders tabloları kullanılarak kategori bazlı toplam satış hesaplanmıştır. Optimizasyon öncesi planda clustered index scan işlemleri baskındır. Ölçüm sonucunda Orders tablosunda 423, OrderDetails tablosunda 1056, Products tablosunda 11 logical read oluşmuştur. Sorgu süresi yaklaşık 46 ms olarak gözlemlenmiştir.

## 6. Uygulanan İndeks ve İyileştirmeler

Performans iyileştirmesi amacıyla aşağıdaki indeksler oluşturulmuştur:

* `IX_Customers_Email`
* `IX_Orders_OrderDate_CustomerID`
* `IX_Products_Category_ProductID`
* `IX_OrderDetails_ProductID_OrderID`

Bu indekslerin amacı sorgularda filtreleme, join ve aggregation maliyetini azaltmaktır.

## 7. Optimizasyon Sonrası Sonuçlar

### Sorgu 1

İndeks eklendikten sonra execution plan `Clustered Index Scan` yerine `Index Seek` ve `Key Lookup` içerecek şekilde değişmiştir. Logical read değeri 141’den 4’e düşmüştür. Bu sorgu, yapılan optimizasyonun en belirgin iyileşme sağladığı örnektir.

### Sorgu 2

Orders tablosu üzerinde indeks kullanımı ile execution plan içinde `Index Seek` gözlemlenmiştir. Orders tablosundaki logical read değeri 423’ten 99’a düşmüştür. Sorgu süresinde de sınırlı bir iyileşme görülmüştür. Bununla birlikte execution plan üzerinde hâlâ ek missing index önerisi bulunduğu için bu sorgunun daha ileri optimizasyona açık olduğu değerlendirilmiştir.

### Sorgu 3

Products ve OrderDetails tablolarında `Index Seek` kullanımı gözlemlenmiştir. Orders tablosundaki logical read değeri 423’ten 195’e, OrderDetails tablosundaki logical read değeri 1056’dan 234’e, Products tablosundaki logical read değeri ise 11’den 2’ye düşmüştür. Sorgu süresi yaklaşık 46 ms’den 14 ms’ye gerilemiştir. Bu sonuç, çoklu join ve aggregation içeren sorgularda uygun indekslerin ciddi performans kazancı sağlayabildiğini göstermektedir.

## 8. Karşılaştırma Tablosu

| Sorgu   | Önce                                                                                   | Sonra                                                                                      | Sonuç              |
| ------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ------------------ |
| Query 1 | Clustered Index Scan, 141 logical reads                                                | Index Seek, 4 logical reads                                                                | Çok güçlü iyileşme |
| Query 2 | Scan ağırlıklı plan, Orders 423 logical reads, 217 ms                                  | Index Seek, Orders 99 logical reads, 188 ms                                                | Kısmi iyileşme     |
| Query 3 | Scan ağırlıklı plan, Orders 423 / OrderDetails 1056 / Products 11 logical reads, 46 ms | Index Seek ağırlıklı plan, Orders 195 / OrderDetails 234 / Products 2 logical reads, 14 ms | Belirgin iyileşme  |

## 9. DMV ile İzleme Çalışmaları

SQL Server üzerinde yapılan performans çalışmasının yalnızca sorgu süreleri ile değil, dinamik yönetim görünümleri (DMV) üzerinden de izlenmesi amaçlanmıştır. Bu kapsamda en çok CPU tüketen sorgular, en çok logical read oluşturan sorgular, indeks kullanım istatistikleri ve eksik indeks önerileri incelenmiştir.

Test ortamının kısa süreli olması nedeniyle bazı DMV sorgularında sınırlı veri oluşmuştur. Buna karşılık indeks kullanım istatistikleri ve eksik indeks önerileri bölümleri anlamlı sonuç vermiştir.

DMV çıktılarında özellikle aşağıdaki indekslerin aktif olarak kullanıldığı gözlemlenmiştir:

* `IX_Customers_Email`
* `IX_Orders_OrderDate_CustomerID`
* `IX_Products_Category_ProductID`
* `IX_OrderDetails_ProductID_OrderID`

Ayrıca eksik indeks önerileri bölümünde `Orders` tablosu için ek indeks önerisi alınmıştır. Bu bulgu, yapılan optimizasyonların performansı iyileştirdiğini ancak sistemin daha ileri düzeyde ek iyileştirmelere açık olduğunu göstermektedir.

## 10. Karşılaşılan Hatalar ve Çözümler

Çalışma sırasında bazı teknik problemlerle karşılaşılmıştır.

İlk olarak SQL Server bağlantısı sırasında sertifika ve şifreleme kaynaklı bağlantı hataları alınmıştır. Bu problem, bağlantı ayarlarında uygun güven seçeneklerinin kullanılmasıyla aşılmıştır.

İkinci olarak veri üretimi aşamasında `OrderDetails` tablosuna veri eklenirken foreign key hatası alınmıştır. Bu problemin nedeni `Orders` tablosundaki `IDENTITY` alanının sıfırlanmamış olmasıdır. Sorun `DBCC CHECKIDENT ... RESEED` komutu ile çözülmüştür.

Son olarak optimizasyon öncesi ve sonrası karşılaştırmalar yapılırken indekslerin gerçekten silinip silinmediği kontrol edilmiş, before/after ekran görüntüleri buna göre yeniden düzenlenmiştir.

## 11. Sonuç

Bu projede SQL Server üzerinde performans problemi oluşturan sorgular analiz edilmiş, execution plan ve istatistik çıktıları incelenmiş ve uygun indeksler yardımıyla performans iyileştirmesi gerçekleştirilmiştir.

Özellikle `Email` alanı üzerinden yapılan aramada çok belirgin bir iyileşme sağlanmış, çoklu join ve aggregation içeren sorgularda da önemli ölçüde logical read ve süre azalması gözlemlenmiştir.

DMV sonuçları, indekslerin gerçekten kullanıldığını göstermiş ve sistemin ek iyileştirmelere açık olduğunu ortaya koymuştur.

Sonuç olarak, veritabanı performans optimizasyonunda doğru indeks tasarımı, execution plan analizi ve DMV tabanlı izleme araçlarının birlikte kullanılmasının önemli olduğu görülmüştür.
